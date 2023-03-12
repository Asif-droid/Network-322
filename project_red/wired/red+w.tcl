#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Open the NAM file and trace file
set nam_file [open animation_wired.nam w]
set trace_file [open trace_wired.tr w]
$ns namtrace-all $nam_file
$ns trace-all $trace_file

#Define a 'finish' procedure
proc finish {} {
    global ns nam_file trace_file
    $ns flush-trace 
    #Close the NAM trace file
    close $nam_file
    close $trace_file
    #Execute NAM on the trace file
    # exec nam out.nam &
    exit 0
}

#Create four nodes



set val(nn)           [lindex $argv 0]

set val(pps)          [lindex $argv 1]
set val(nf)      [lindex $argv 2]

set val(qthresh)      15
set val(qmaxthresh)   45
set val(qweight)      0.002
set val(qminpcksize)  1000
set val(redtype)      0               ;#  0: RED, 1: WRED


Queue/RED set thresh_ $val(qthresh)
Queue/RED set maxthresh_ $val(qmaxthresh)
Queue/RED set q_weight_ $val(qweight)
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set min_pcksize_ $val(qminpcksize)
Queue/RED set wred $val(redtype)


if { $val(nn) == 20 } {
    set row 5
    set col 4
}
if { $val(nn) == 40 } {
    set row 8
    set col 5
}
if { $val(nn) == 60 } {
    set row 10
    set col 6
}
if { $val(nn) == 80 } {
    set row 10
    set col 8
}
if { $val(nn) == 100 } {
    set row 10
    set col 10
}

#Create links between the nodes
# ns <link-type> <node1> <node2> <bandwidht> <delay> <queue-type-of-node2>

set x1 [$ns node]
set x2 [$ns node]
set half [expr $val(nn)/2]
for {set i 0} {$i < $val(nn)} {incr i} {
    if {$i<$half} {
        set node($i) [$ns node]
        $ns duplex-link $x1 $node($i) 2Mb 10ms DropTail
        $ns queue-limit $x1 $node($i) 20
        
    } else {
        set node($i) [$ns node]
        $ns duplex-link $x2 $node($i) 2Mb 10ms DropTail
        $ns queue-limit $x2 $node($i) 20
        
    }
}

$ns duplex-link $x1 $x2 2Mb 10ms RED


#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $x1 $x2 20

#Give node position (for NAM)
#$ns duplex-link-op $n0 $n2 orient right-down
#$ns duplex-link-op $n1 $n2 orient right-up
#$ns duplex-link-op $n2 $n3 orient right

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $x1 $x2 queuePos 0.5

#tcptraffic function
proc tcptraffic {src dest} {
    global ns node val
    set tcp [new Agent/TCP]
    $ns attach-agent $node($src) $tcp
    set sink [new Agent/TCPSink]
    $ns attach-agent $node($dest) $sink
    #set pktsize_ 1000
    $tcp set packetSize_ $val(qminpcksize)
    #set window_ 1000
    $tcp set window_ [expr 10 *($val(pps) / 100)]
    $ns connect $tcp $sink
    $tcp set fid_ 1
    set ftp [new Application/FTP]
    $ftp attach-agent $tcp
    $ftp set type_ FTP
    $ns at 0.1 "$ftp start"
    $ns at 4.5 "$ftp stop"
    $ns at 4.7 "$ns detach-agent $node($src) $tcp ; $ns detach-agent $node($dest) $sink"
}





set j [expr $val(nn)/2]
for {set i 0} {$i < $val(nf)} {incr i} {
    set src [expr $i%$val(nn)]
    set dest [expr ($i + $j)%$val(nn)]

    tcptraffic $src $dest
}


puts "$val(nn) $val(pps) $val(nf) \n"

#Detach tcp and sink agents (not really necessary)
# $ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"


#Run the simulation
$ns run
