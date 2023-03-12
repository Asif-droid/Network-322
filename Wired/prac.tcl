#Create a simulator object
set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red
#Open the NAM file and trace file
set nam_file [open animation.nam w]
set trace_file [open trace.tr w]
$ns namtrace-all $nam_file
$ns trace-all $trace_file


#Create two nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]


#Create links between the nodes
# ns <link-type> <node1> <node2> <bandwidth> <delay> <queue-type>
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2Mb 10ms DropTail
$ns duplex-link $n3 $n4 2Mb 10ms DropTail
$ns duplex-link $n2 $n4 2Mb 10ms DropTail


#Set Queue Size of link (n0-n1) to 20
#$ns queue-limit $n0 $n1 10


#Setup a TCP connection
#Setup a flow
set tcp1 [new Agent/TCP]
$ns attach-agent $n0 $tcp1

set tcp2 [new Agent/TCP]
$ns attach-agent $n4 $tcp2

set sink1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink1

set sink2 [new Agent/TCPSink]
$ns attach-agent $n1 $sink2

$ns connect $tcp1 $sink1
$ns connect $tcp2 $sink2
$tcp1 set fid_ 1
$tcp2 set fid_ 2




#Setup a FTP Application over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP


#Schedule events for the CBR and FTP agents
$ns at 1.0 "$ftp1 start"
$ns at 40.0 "$ftp1 stop"
$ns at 1.0 "$ftp2 start"
$ns at 40.0 "$ftp2 stop"



#Call the finish procedure after 5 seconds of simulation time
$ns at 50.0 "finish"

#Define a 'finish' procedure
proc finish {} {
    global ns nam_file trace_file
    $ns flush-trace 
    #Close the NAM trace file
    close $nam_file
    close $trace_file
    #Execute NAM on the trace file
    # exec nam out.nam &
    puts "Finishing Simulation"
    exit 0
}



#Run the simulation
$ns run
