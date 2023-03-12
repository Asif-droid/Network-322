

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
set val(ifq)            CMUPriQueue  ;# interface queue type for dsr CMUPriQueue 
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             40                         ;# number of mobilenodes
set val(rp)             DSR                      ;# routing protocol
set val(x)		500
set val(y)		500



set val(nam)		offline2.nam
set val(traffic)	exp                        ;# cbr/exp/ftp


# for 20 i=5 j=4
# for 40 i=8 j=5
# for 60 i=10 j=6
# for 80 i=10 j=8
# for 100 i=10 j=10


# Initialize Global Variables
set ns_		[new Simulator]
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
Phy/WirelessPhy set CSThresh_ $dist(30m)
Phy/WirelessPhy set RXThresh_ $dist(30m)

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
		-ifqType $val(ifq) \
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
	    -channel $chan_1_ 






set no_co 0
for {set i 0} {$i < 8 } {incr i} {
    for {set j 0} {$j < 5 } {incr j} {
        set node_($no_co) [$ns_ node]
        #$node_($no_co) random-motion 0       ;# disable random motion

        $node_($no_co) set X_ [expr (20 * $i) ]
        $node_($no_co) set Y_ [expr (20 * $j) ]
        $node_($no_co) set Z_ 0

        $ns_ initial_node_pos $node_($no_co) 20
        incr no_co

    }
    
}

#seed


set starttime 5
set motiongap 0.05
#speed/movement of the nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    	
	set xposnew [expr int($val(x)*rand()+1)] ;#random settings
	set yposnew [expr int($val(y)*rand()+1)] ;#random settings
    set speed [expr int(4.0*rand()+1.0)]
	$ns_ at [expr $starttime+$i*$motiongap] "$node_($i) setdest $xposnew $yposnew $speed"
	
}


set val(0)            0.0	;# in seconds 


set stopTime            100	;# in seconds 


set nf              20  ;# 20 for base case 



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
   eval \$expl($src) set rate_ 250k
   eval \$expl($src) attach-agent \$udp($src)
   eval $ns_ connect \$udp($src) \$null($dst)
   $ns_ at $starttime "$expl($src) start"
}
for {set i 0} { $i < $nf } { incr i } {

    set r_src [expr {(int(rand()*$val(nn))+1)%$val(nn)}]
    set r_dest [expr {(int(rand()*$val(nn))+1)%$val(nn)}]
    puts "$r_src"
    puts "$r_dest"
    if {$r_src==$r_dest} {
        set i [expr {$i-1}]
        continue 
    }
    exptraffic $r_src $r_dest 0.2 $val(0)
        
        
}




# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

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
