




set cir0  1000000
set cbs0     3000
set rate0 2000000
set cir1  1000000
set cbs1    10000
set rate1 3000000

set packetSize 1000



# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;#Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_11 
set val(ifq1)           Queue/DropTail/PriQueue    ;# interface queue type for dsr CMUPriQueue
set val(ifq)            Queue/dsRED/edge  
set val(ifq2)            Queue/dsRED/edge 
set val(ifq_core)            Queue/dsRED/core      ;# interface queue type for dsr CMUPriQueue 
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         2                         ;# max packet in ifq
set val(nn)             6                         ;# number of mobilenodes
set val(rp)            AODV                     ;# routing protocol
set val(x)		500
set val(y)		500



set val(nam)		offline2.nam
set val(traffic)	cbr                        ;# cbr/exp/ftp














# for 20 i=5 j=4
# for 40 i=8 j=5
# for 60 i=10 j=6
# for 80 i=10 j=8
# for 100 i=10 j=10


# Initialize Global Variables
set ns_		[new Simulator]
# $ns_ use-modules [list $val(rp) Mac LL $val(ll) Queue $val(ifq) Antenna $val(ant) Propagation $val(prop) $val(netif)]

set tracefd     [open ./offline2.tr w]
$ns_ trace-all $tracefd
if { "$val(nam)" == "offline2.nam" } {
        set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}

$ns_ puts-nam-traceall {# nam4wpan #}		;# inform nam that this is a trace file for wpan (special handling needed)

Mac/802_15_4 wpanNam namStatus on		;# default = off (should be turned on before other 'wpanNam' commands can work)



set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
set dist(45m) 9.47701e-08
set dist(50m) 7.56701e-08
set dist(55m) 6.13401e-08

Phy/WirelessPhy set CSThresh_ $dist(55m)
Phy/WirelessPhy set RXThresh_ $dist(55m)

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create God
set god_ [create-god $val(nn)]

set chan_1_ [new $val(chan)]

# configure node

$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq1)\
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
		-movementTrace OFF \
        -channel $chan_1_\
                #-energyModel "EnergyModel" \
                #-initialEnergy 1 \
                #-rxPower 0.3 \
                #-txPower 0.3 \
	    #-channel $chan_1_ ifqType $val(ifq)




set node_(0) [$ns_ node]
$node_(0) random-motion 0 
$node_(0) set X_ 100
$node_(0) set Y_ 100
$node_(0) set Z_ 0
$ns_ initial_node_pos $node_(0) 20



set node_(2) [$ns_ node]
$node_(2)  random-motion 0
$node_(2)   set X_ 200
$node_(2)   set Y_ 100
$node_(2)   set Z_ 0
$ns_ initial_node_pos $node_(2)  20




$val(ifq) meanPktSize $packetSize
$val(ifq) set numQueues_ 1
$val(ifq) setNumPrec 1
$val(ifq) setMREDMode WRED
$val(ifq) addPolicyEntry [$node_(0) id] [$node_(2) id] TokenBucket 10 $cir0 $cbs0
$val(ifq) addPolicyEntry [$node_(2) id] [$node_(0) id] TokenBucket 10 $cir0 $cbs0
$val(ifq) addPolicerEntry TokenBucket 10 11
$val(ifq) addPHBEntry 10 0 0
$val(ifq) addPHBEntry 11 0 1
$val(ifq) configQ 0 0 20 40 0.02
$val(ifq) configQ 0 1 10 20 0.10


$val(ifq2) meanPktSize $packetSize
$val(ifq2) set numQueues_ 1
$val(ifq2) setNumPrec 1
$val(ifq2) setMREDMode WRED
$val(ifq2) addPolicyEntry [$node_(2) id] [$node_(0) id] TokenBucket 10 $cir0 $cbs0
$val(ifq2) addPolicyEntry [$node_(0) id] [$node_(2) id] TokenBucket 10 $cir0 $cbs0
$val(ifq2) addPolicerEntry TokenBucket 10 11
$val(ifq2) addPHBEntry 10 0 0
$val(ifq2) addPHBEntry 11 0 1
$val(ifq2) configQ 0 0 20 40 0.02
$val(ifq2) configQ 0 1 10 20 0.10



$val(ifq_core) meanPktSize $packetSize
$val(ifq_core) set numQueues_ 1
$val(ifq_core) setNumPrec 1
$val(ifq_core) setMREDMode WRED
$val(ifq_core) addPHBEntry 10 0 0
$val(ifq_core) addPHBEntry 11 0 1
$val(ifq_core) configQ 0 0 20 40 0.02
$val(ifq_core) configQ 0 1 10 20 0.10


$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq)\
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
		-movementTrace OFF \
        -channel $chan_1_\
                #-energyModel "EnergyModel" \
                #-initialEnergy 1 \
                #-rxPower 0.3 \
                #-txPower 0.3 \
	    #-channel $chan_1_ ifqType $val(ifq)






set node_(1) [$ns_ node]
$node_(1)  random-motion 0 
$node_(1)  set X_ 120
$node_(1)  set Y_ 100
$node_(1)  set Z_ 0
$ns_ initial_node_pos $node_(1) 20

$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq_core)\
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
		-movementTrace OFF \
        -channel $chan_1_\
                #-energyModel "EnergyModel" \
                #-initialEnergy 1 \
                #-rxPower 0.3 \
                #-txPower 0.3 \
	    #-channel $chan_1_ ifqType $val(ifq)






set core [$ns_ node]
$core  random-motion 0 
$core  set X_ 150
$core  set Y_ 100
$core  set Z_ 0
$ns_ initial_node_pos $core 20


$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq2)\
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
		-movementTrace OFF \
        -channel $chan_1_\
                #-energyModel "EnergyModel" \
                #-initialEnergy 1 \
                #-rxPower 0.3 \
                #-txPower 0.3 \
	    #-channel $chan_1_ ifqType $val(ifq)



set node_(3) [$ns_ node]
$node_(3)  random-motion 0 
$node_(3)  set X_ 180
$node_(3)  set Y_ 100
$node_(3)  set Z_ 0
$ns_ initial_node_pos $node_(3) 20




set val(0)            0.0	;# in seconds 


set stopTime            80	;# in seconds 


set nf              2  ;# 20 for base case 



puts "$ns_ $node_(0)"


proc exptraffic { src dst interval starttime } {
   global ns_ node_
   set udp($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp($src)
   set null($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null($dst)
   set expl($src) [new Application/Traffic/Exponential]
   eval \$expl($src) set packetSize_ 64
   eval \$expl($src) set burst_time_ 0
   eval \$expl($src) set idle_time_ [expr $interval*1000.0-70.0*8/250]ms	;# idle_time + pkt_tx_time = interval
   eval \$expl($src) set rate_ 64k      ;#250k
   eval \$expl($src) attach-agent \$udp($src)
   eval $ns_ connect \$udp($src) \$null($dst)
   $ns_ at $starttime "$expl($src) start"
}

proc cbrtraffic { src dst interval starttime } {
   global ns_ node_
   set udp($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp($src)
   set null($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null($dst)
   set cbr($src) [new Application/Traffic/CBR]
   eval \$cbr($src) set packetSize_ 70
   eval \$cbr($src) set interval_ $interval
   eval \$cbr($src) set random_ 0
   #eval \$cbr($src) set maxpkts_ 10000
   eval \$cbr($src) attach-agent \$udp($src)
   eval $ns_ connect \$udp($src) \$null($dst)
   $ns_ at $starttime "$cbr($src) start"
}
# for {set i 0} { $i < $nf } { incr i } {

#     # set r_src [expr {(int(rand()*$val(nn))+1)%$val(nn)}]
#     # set r_dest [expr {(int(rand()*$val(nn))+1)%$val(nn)}]
#     # puts "$r_src"
#     # puts "$r_dest"
#     # if {$r_src==$r_dest} {
#     #     set i [expr {$i-1}]
#     #     continue 
#     # }
#     cbrtraffic 0  0.2 $val(0)
        
        
# }

puts "here"

set udp0 [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packet_size_ $packetSize
$udp0 set packetSize_ $packetSize
$cbr0 set rate_ $rate0
set null0 [new Agent/Null]
$ns_ attach-agent $node_(2) $null0
$ns_ connect $udp0 $null0


# cbrtraffic 0 2 0.2 $val(0)
#  cbrtraffic 1 2 0.2 $val(0)




# Tell nodes when the simulation ends
# for {set i 0} {$i < $val(nn) } {incr i} {
#     $ns_ at $stopTime "$node_($i) reset";
# }


$ns_ at 0.0 "$cbr0 start"

$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"\nNS EXITING...\""
$ns_ at $stopTime "$ns_ halt"

proc stop {} {
    global ns_ tracefd val env
    $ns_ flush-trace
    close $tracefd
    set hasDISPLAY 0
    foreach index [array names env] {
        #puts "$index: $env($index)"
        if { ("$index" == "DISPLAY") && ("$env($index)" != "") } {
                set hasDISPLAY 1
        }
    }
    if { ("$val(nam)" == "offline2.nam") && ("$hasDISPLAY" == "1") } {
	    exec nam offline2.nam &
    }
}

puts "\nStarting Simulation..."
$ns_ run
