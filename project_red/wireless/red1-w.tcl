# simulator
set ns [new Simulator]


# ======================================================================
# Define options

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/RED  ;# Interface queue type
set val(ifqlen)       32                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy/802_15_4         ;# network interface type 802_15_4 
set val(mac)          Mac/802_15_4             ;# MAC type 802_15_4
set val(rp)           DSDV                     ;# ad-hoc routing protocol 
set val(nn)           [lindex $argv 0]                       ;# number of mobilenodes

set val(len)            [lindex $argv 1]

set val(energymodel)    EnergyModel		;# Energy Model
set val(initialenergy)  12   	        ;# value

set val(pps)           [lindex $argv 2]                    ;# packets per second

set val(nf)         [lindex $argv 3]               ;# number of flows

set val(tx)   [lindex $argv 4]               ;# tx of simulation



set val(qthresh)      15
set val(qmaxthresh)   45
set val(qweight)      0.002
set val(qminpcksize)  1024
set val(redtype)      0             ;#  0: RED, 1: WRED
# =======================================================================

set tx_range_ [Phy/WirelessPhy set Pt_]

set next_range [expr $tx_range_ * $val(tx)* $val(tx)]

Phy/WirelessPhy set Pt_ $next_range


# trace file
set trace_file [open trace_wireless.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open animation_wireless.nam w]
$ns namtrace-all-wireless $nam_file $val(len) $val(len)

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $val(len) $val(len) ;# 500m x 500m area


# general operation director for mobilenodes
create-god $val(nn)


# node configs
# ======================================================================

# $ns node-config -addressingType flat or hierarchical or expanded
#                  -adhocRouting   DSDV or DSR or TORA
#                  -llType	   LL
#                  -macType	   Mac/802_11
#                  -propType	   "Propagation/TwoRayGround"
#                  -ifqType	   "Queue/DropTail/PriQueue"
#                  -ifqLen	   50
#                  -phyType	   "Phy/WirelessPhy"
#                  -antType	   "Antenna/OmniAntenna"
#                  -channelType    "Channel/WirelessChannel"
#                  -topoInstance   $topo
#                  -energyModel    "EnergyModel"
#                  -initialEnergy  (in Joules)
#                  -rxPower        (in W)
#                  -txPower        (in W)
#                  -agentTrace     ON or OFF
#                  -routerTrace    ON or OFF
#                  -macTrace       ON or OFF
#                  -movementTrace  ON or OFF

# ======================================================================

Queue/RED set thresh_ $val(qthresh)
Queue/RED set maxthresh_ $val(qmaxthresh)
Queue/RED set q_weight_ $val(qweight)
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set min_pcksize_ $val(qminpcksize)
Queue/RED set wred $val(redtype)

set chan_1_ [new $val(chan)]


$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -channel $chan_1_\
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF \
                -energyModel $val(energymodel) \
        -initialEnergy $val(initialenergy) \
        -rxPower 1.0 \
        -txPower 1.0 \
        -idlePower 1.0 \
        -sleepPower 0.001 




# ======================================================================

# for 20 i=5 j=4
# for 40 i=8 j=5
# for 60 i=10 j=6
# for 80 i=10 j=8
# for 100 i=10 j=10



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

# create nodes
expr srand(87)
set no_co 0
for {set i 0} {$i < $row } {incr i} {
    for {set j 0} {$j < $col } {incr j} {
        set node($no_co) [$ns node]
        $node($no_co) random-motion 0       ;# disable random motion

        $node($no_co) set X_ [expr (rand() * $val(len)) ]
        $node($no_co) set Y_ [expr (20 * $j) ]
        $node($no_co) set Z_ 0

        $ns initial_node_pos $node($no_co) 20
        incr no_co

    }
    
} 





# Traffic



$ns color 1 Blue



proc cbrtraffic { src dst interval starttime } {
   global ns node val
   set udp($src) [new Agent/UDP]
   eval $ns attach-agent \$node($src) \$udp($src)
   set null($dst) [new Agent/Null]
   eval $ns attach-agent \$node($dst) \$null($dst)
   set cbr($src) [new Application/Traffic/CBR]
   eval \$cbr($src) set packetSize_ $val(qminpcksize)
   eval \$cbr($src) set interval_ $interval
   eval \$cbr($src) set random_ 0
   #eval \$cbr($src) set maxpkts_ 10000
   eval \$cbr($src) attach-agent \$udp($src)
   eval $ns connect \$udp($src) \$null($dst)
   $ns at $starttime "$cbr($src) start"
}
#function to send tcp traffic
proc tcptraffic { src dst interval starttime } {
   global ns node val
   set tcp($src) [new Agent/TCP/Newreno]
   eval $ns attach-agent \$node($src) \$tcp($src)
   $tcp($src) set packetSize_ $val(qminpcksize)
   $tcp($src) set maxseq_ $val(pps)
   set null($dst) [new Agent/TCPSink]
   eval $ns attach-agent \$node($dst) \$null($dst)
   set ftp($src) [new Application/FTP]
   eval \$ftp($src) attach-agent \$tcp($src)
   eval $ns connect \$tcp($src) \$null($dst)
   $ns at $starttime "$ftp($src) start"
}


set j [expr $val(nn)/2]



for {set i 0} {$i < $val(nf)} {incr i} {
    set src [expr $i%$val(nn)]
    set dest [expr int(rand()*$val(nn))]
    if { $dest == $src } {
        set dest [expr ($dest + 1)%$val(nn)]
    }
        

    # cbrtraffic $src $dest 0.2 1.0
    tcptraffic $src $dest 0.2 1.0

    # Traffic config
    # create agent
    # set udp [new Agent/UDP]

    # # Traffic generator
    # set ftp [new Application/FTP]
    # # attach to agent
    # $ftp attach-agent $udp


    # set udp_sink [new Agent/Null]
    # # attach to nodes
    # $ns attach-agent $node($src) $udp
    # $ns attach-agent $node($dest) $udp_sink
    # # connect agents
    # $ns connect $udp $udp_sink
    # # $udp set fid_ $i


    
    # # start traffic generation
    # $ns at 1.0 "$ftp start"
}



# End Simulation

# Stop nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at 50.0 "$node($i) reset"
}

# call final function
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
    # exec nam animation_wireless.nam &
}


$ns at 100.0001 "finish"
$ns at 100.0002 "halt_simulation"




# Run simulation
puts "Simulation starting"
$ns run

