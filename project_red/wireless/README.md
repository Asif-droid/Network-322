# Wireless Network Simulation - RED Queue Management Testing

## Overview

This project performs network simulations using NS-2 (Network Simulator 2) to evaluate the performance of **RED (Random Early Detection)** and **WRED (Weighted Random Early Detection)** queue management algorithms in wireless networks using the **802.15.4** protocol.

## Project Structure

### Files

- **`run.sh`** - Main bash script that orchestrates all simulations with varying parameters
- **`red1-w.tcl`** - TCL script defining the wireless network simulation scenario
- **`results.txt`** - Output file containing aggregated performance metrics from all simulations
- **`stat1-w.txt`** - Detailed simulation logs and diagnostics
- **`parse.awk`** - AWK script for parsing trace files and extracting metrics

## Network Configuration

### Technology Stack
- **Protocol**: IEEE 802.15.4 (Zigbee/Low-Power Wireless)
- **MAC Layer**: `Mac/802_15_4`
- **PHY Layer**: `Phy/WirelessPhy/802_15_4`
- **Routing**: DSDV (Destination Sequenced Distance Vector)
- **Antenna**: Omnidirectional Antenna
- **Propagation Model**: Two-Ray Ground Reflection

### Simulation Parameters

| Parameter | Default Value | Purpose |
|-----------|---------------|---------|
| Grid Size | 500m × 500m | Simulation area |
| Initial Energy | 12 Joules | Node energy budget |
| Queue Type | Queue/RED | Interface queue discipline |
| Queue Length | 32 packets | Maximum queue size |
| Packet Size | 1024 bytes | MIN_PCKSIZE |
| Simulation Duration | 100 seconds | Total simulation time |
| Transmission Power | 1.0W | TX power |
| Idle Power | 1.0W | Idle state power |
| Sleep Power | 0.001W | Sleep mode power |

### RED Queue Parameters

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| Minimum Threshold | 15 packets | Start dropping packets probabilistically |
| Maximum Threshold | 45 packets | Drop packets with high probability |
| Weight (q_weight) | 0.002 | Exponential weighted average factor |
| Min Packet Size | 1024 bytes | For queue occupancy calculations |
| WRED Flag | 0 (RED) / 1 (WRED) | Queue discipline type |

## Simulation Scenarios

The `run.sh` script executes four test scenarios, each varying one parameter while keeping others constant:

### 1. Varying Number of Nodes
**Command**: `ns red1-w.tcl $val 500 1000 20 1`
- **Variable**: Number of nodes (20, 40, 60, 80, 100)
- **Fixed Parameters**: 
  - Grid size: 500m × 500m
  - Packets per second: 1000
  - Number of flows: 20
  - TX range multiplier: 1.0x
- **Purpose**: Evaluate scalability and network congestion

### 2. Varying Number of Flows
**Command**: `ns red1-w.tcl 40 500 1000 $val 1`
- **Variable**: Number of traffic flows (10, 20, 30, 40, 50)
- **Fixed Parameters**:
  - Number of nodes: 40
  - Grid size: 500m × 500m
  - Packets per second: 1000
  - TX range multiplier: 1.0x
- **Purpose**: Evaluate impact of traffic load

### 3. Varying Packet Rate (Packets Per Second)
**Command**: `ns red1-w.tcl 40 500 $val 20 1`
- **Variable**: Packet rate (100, 200, 300, 400, 500 pps)
- **Fixed Parameters**:
  - Number of nodes: 40
  - Grid size: 500m × 500m
  - Number of flows: 20
  - TX range multiplier: 1.0x
- **Purpose**: Evaluate sensitivity to traffic intensity

### 4. Varying Transmission Range
**Command**: `ns red1-w.tcl 40 500 1000 20 $i`
- **Variable**: TX range multiplier (1.0x, 2.0x, 3.0x, etc.)
- **Fixed Parameters**:
  - Number of nodes: 40
  - Grid size: 500m × 500m
  - Packets per second: 1000
  - Number of flows: 20
- **Purpose**: Evaluate impact of network topology density

## Node Placement

Nodes are placed in a grid pattern with random X-coordinate and sequential Y-coordinate positioning:

| Number of Nodes | Grid Dimensions | Pattern |
|-----------------|-----------------|---------|
| 20 | 5 × 4 | 5 rows, 4 columns |
| 40 | 8 × 5 | 8 rows, 5 columns |
| 60 | 10 × 6 | 10 rows, 6 columns |
| 80 | 10 × 8 | 10 rows, 8 columns |
| 100 | 10 × 10 | 10 rows, 10 columns |

## Traffic Generation

### Protocol
- **TCP (Newreno)** with FTP application
- Packet size: 1024 bytes
- Interval between packets: 0.2 seconds
- Start time: 1.0 second (after topology stabilization)

### Flow Selection
- Source node: `i % num_nodes`
- Destination node: Random (avoiding same-node flows)
- Number of flows: Configurable (default: 20)

## Performance Metrics

The simulation collects the following metrics (parsed from trace files):

1. **Throughput** (bytes/second) - Data delivery rate
2. **Delay** (seconds) - Average packet latency
3. **Delivery Ratio** (0-1) - Fraction of packets successfully delivered
4. **Drop Ratio** (0-1) - Fraction of packets dropped
5. **Jitter** (seconds) - Variation in packet arrival time

## Running the Simulation

### Prerequisites
```bash
# Install NS-2
sudo apt-get install ns2
```

### Execute All Simulations
```bash
bash run.sh
```

This will:
1. Run 20 simulations (4 test scenarios × 5 parameter variations)
2. Generate trace files: `trace_wireless.tr` and `animation_wireless.nam`
3. Parse results and append to `results.txt`
4. Log detailed output to `stat1-w.txt`

### Execute Single Scenario
```bash
# Example: Test with 40 nodes
ns red1-w.tcl 40 500 1000 20 1

# Parse results
awk -f parse.awk trace_wireless.tr
```

### Visualization
```bash
# View NAM animation
nam animation_wireless.nam &
```

## Output Format

### results.txt Format
```
metric1, metric2, metric3, metric4, metric5
```

Example:
```
3726.92, 0.104251, 0.936688, 0.0324675, 460.676
```

### stat1-w.txt Contents
- Simulation start/end events
- Node count
- Queue discipline (RED/WRED)
- Antenna height and communication range
- Diagnostic messages

## Interpretation of Results

### Key Observations

**Varying Nodes**: 
- As node count increases, network congestion rises
- RED queue management helps prevent buffer overflow
- Delivery ratio may decrease with higher node density

**Varying Flows**:
- More flows increase contention for bandwidth
- RED performs better when queue depth approaches limits
- Delay typically increases with flow count

**Varying Packet Rate**:
- Higher packet rates stress the queue management algorithm
- RED's probabilistic dropping prevents buffer saturation
- Throughput plateaus after a critical packet rate

**Varying TX Range**:
- Larger transmission range improves connectivity
- May increase collision probability
- Network topology becomes more dense

## Queue Management Comparison

### RED (Random Early Detection)
- All flows treated equally
- Probabilistic packet dropping
- Prevents buffer saturation
- Lower latency for responsive flows

### WRED (Weighted RED)
- Differentiated service based on packet priority
- Better QoS for priority traffic
- More complex configuration
- Enables traffic prioritization

## TCL Script Parameters

The TCL script accepts 5 command-line arguments:

```tcl
set val(nn)    [lindex $argv 0]  ;# Number of nodes
set val(len)   [lindex $argv 1]  ;# Grid size (meters)
set val(pps)   [lindex $argv 2]  ;# Packets per second
set val(nf)    [lindex $argv 3]  ;# Number of flows
set val(tx)    [lindex $argv 4]  ;# TX range multiplier
```

## Customization

### Modify Queue Parameters
Edit `red1-w.tcl` lines 83-90:
```tcl
Queue/RED set thresh_ 15          ;# Minimum threshold
Queue/RED set maxthresh_ 45       ;# Maximum threshold
Queue/RED set q_weight_ 0.002     ;# Weight factor
Queue/RED set min_pcksize_ 1024   ;# Minimum packet size
Queue/RED set wred 0              ;# 0=RED, 1=WRED
```

### Add New Test Scenario
Add a loop to `run.sh`:
```bash
echo "New test scenario\n" >>results.txt
for i in {1..5}
do
    val=$((i*parameter))
    echo "Running $val"
    ns red1-w.tcl <args> >>stat1-w.txt
    awk -f parse.awk trace_wireless.tr >> results.txt
done
```

### Change Traffic Type
Replace TCP with CBR in `red1-w.tcl` (line 244):
```tcl
# Original (TCP):
tcptraffic $src $dest 0.2 1.0

# Alternative (CBR):
cbrtraffic $src $dest 0.2 1.0
```

## Troubleshooting

**Issue**: Trace files not generated
- **Solution**: Ensure NS-2 is installed and `ns` command is in PATH

**Issue**: Results appear identical across runs
- **Solution**: Check if traffic generation is starting correctly (start time: 1.0s)

**Issue**: Simulation too slow
- **Solution**: Reduce simulation duration or number of nodes

**Issue**: Out of memory
- **Solution**: Reduce grid size or packet rate

## References

- **NS-2 Documentation**: http://www.isi.edu/nsnam/ns/
- **IEEE 802.15.4**: Low-Rate Wireless Personal Area Networks
- **RED Algorithm**: Floyd & Jacobson, "Random Early Detection Gateways for Congestion Avoidance"
- **DSDV Routing**: Perkins & Bhagwat, "Highly Dynamic Destination-Sequenced Distance-Vector"

## Author Notes

This simulation provides insights into queue management behavior in low-power wireless networks. The 802.15.4 protocol is commonly used in IoT and sensor network applications where energy efficiency is critical.
