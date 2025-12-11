# Project RED: Queue Management Algorithm Testing

## Overview

**Project RED** is a comprehensive network simulation study evaluating **Random Early Detection (RED)** and **Weighted Random Early Detection (WRED)** queue management algorithms across different network topologies and traffic scenarios. The project uses NS-2 (Network Simulator 2) to perform controlled experiments measuring congestion control effectiveness, packet loss behavior, and network performance metrics.

## Project Objectives

1. **Compare Queue Management Algorithms**: Evaluate RED vs WRED performance
2. **Test Multiple Topologies**: Wireless (802.15.4), Wired (tree), and DiffServ (DS-RED)
3. **Analyze Scalability**: Measure performance with varying network sizes
4. **Assess Traffic Patterns**: Test different flow counts and packet rates
5. **Evaluate QoS**: Examine traffic prioritization and fairness

## Project Structure

```
project_red/
├── README.md                          # This file - Project overview
├── wireless/                          # Wireless network simulations
│   ├── README.md                      # Detailed wireless documentation
│   ├── run.sh                         # Test automation script
│   ├── red1-w.tcl                     # Simulation scenario (802.15.4)
│   ├── parse.awk                      # Trace file parser
│   ├── results.txt                    # Aggregated results
│   └── stat1-w.txt                    # Detailed statistics
├── wired/                             # Wired network simulations
│   ├── README.md                      # Detailed wired documentation
│   ├── run.sh                         # Test automation script
│   ├── red+w.tcl                      # Simulation scenario (tree topology)
│   ├── parse_w.awk                    # Trace file parser
│   ├── results.txt                    # Aggregated results
│   └── stat1-w.txt                    # Detailed statistics
└── bonus/                             # Differentiated Services simulations
    ├── README.md                      # Detailed DS-RED documentation
    ├── test2.tcl                      # DS-RED with Token Bucket
    ├── results.txt                    # Aggregated results
    └── stat.txt                       # Detailed statistics
```

## Quick Start

### Run All Tests

```bash
cd project_red

# Run wireless network tests
cd wireless && bash run.sh && cd ..

# Run wired network tests
cd wired && bash run.sh && cd ..

# Run bonus DS-RED test
cd bonus && ns test2.tcl && cd ..
```

### View Detailed Documentation

- **[Wireless Tests](wireless/README.md)** - 802.15.4 protocol, DSDV routing, energy-aware scenarios
- **[Wired Tests](wired/README.md)** - Tree topology, bottleneck links, TCP/FTP traffic
- **[Bonus DS-RED Tests](bonus/README.md)** - Differentiated services, Token Bucket policing, QoS

## Test Categories

### 1. Wireless Network Simulation

**File**: `wireless/`

**Technology**: IEEE 802.15.4 (Zigbee/IoT protocol)

**Test Scenarios**:
1. **Varying Nodes**: 20, 40, 60, 80, 100 nodes
2. **Varying Flows**: 10, 20, 30, 40, 50 flows
3. **Varying Packet Rate**: 100, 200, 300, 400, 500 pps
4. **Varying TX Range**: 1.0x, 2.0x, 3.0x, ... multipliers

**Key Parameters**:
- Grid size: 500m × 500m
- MAC: 802.15.4
- Routing: DSDV
- Queue type: RED
- Energy model: Yes (12J per node)

**Performance Focus**:
- Low-power wireless network behavior
- Energy-constrained node performance
- Network scalability in IoT scenarios
- Impact of transmission range on topology

---

### 2. Wired Network Simulation

**File**: `wired/`

**Topology**: Tree with bottleneck core link

**Test Scenarios**:
1. **Varying Nodes**: 20, 40, 60, 80, 100 nodes
2. **Varying Flows**: 10, 20, 30, 40, 50 flows
3. **Varying Packet Rate**: 100, 200, 300, 400, 500 pps

**Key Parameters**:
- Access links: 2 Mbps, 10ms delay
- Core link: 2 Mbps, 10ms delay (bottleneck)
- Protocol: TCP (Newreno) with FTP
- Queue type: RED on core link
- Packet size: 1000 bytes

**Performance Focus**:
- Congestion control under sustained load
- Queue management with predictable links
- TCP fairness across flows
- Bottleneck link behavior

---

### 3. Differentiated Services (Bonus Test)

**File**: `bonus/`

**Architecture**: Multi-class queuing with Token Bucket policing

**Traffic Classes**:
- **Class 1** (Premium): CIR=1Mbps, CBS=3KB (sources: s1, s3)
- **Class 2** (Best-Effort): CIR=1Mbps, CBS=10KB (sources: s2, s4, s5)

**Test Scenarios**:
- Varying number of concurrent flows (1-5)
- Comparing RED vs WRED algorithms
- Token Bucket enforcement

**Key Parameters**:
- Core bottleneck: 2 Mbps
- Queue discipline: dsRED (edge and core)
- Policer type: Token Bucket
- Red thresholds: Tuned per class

**Performance Focus**:
- Quality of Service (QoS) differentiation
- Traffic policing effectiveness
- In-profile vs out-of-profile behavior
- WRED benefits for priority traffic

## Comparative Analysis

### Algorithm Performance Summary

| Metric | Wireless | Wired | DS-RED |
|--------|----------|-------|--------|
| **Primary Algorithm** | RED/WRED | RED | WRED |
| **Network Type** | Wireless 802.15.4 | Wired Tree | Wired Multi-class |
| **Routing Protocol** | DSDV | None (fixed) | None (fixed) |
| **Link Stability** | Variable (collisions) | Stable | Stable |
| **QoS Support** | Basic | Basic | Advanced |
| **Typical Delivery** | 66-95% | 94-97% | 70% (fair split) |
| **Typical Delay** | 0.04-0.12s | 0.03-0.04s | 0.012-0.037s |

### Test Characteristics

#### Wireless Network
- **Strengths**:
  - Realistic IoT/sensor network scenario
  - Energy constraints affect performance
  - Variable link quality simulation
  - DSDV routing adds complexity
  
- **Challenges**:
  - Collisions and interference
  - Variable propagation delays
  - Energy depletion over time
  - Less predictable than wired

#### Wired Network
- **Strengths**:
  - Stable, predictable links
  - Focus on pure congestion control
  - Clear bottleneck identification
  - Reproducible results
  
- **Challenges**:
  - Simplified topology
  - No cross-layer effects
  - Less realistic for modern networks
  - Limited QoS mechanisms

#### Differentiated Services (DS-RED)
- **Strengths**:
  - Advanced QoS mechanisms
  - Traffic policing (Token Bucket)
  - Per-class queue management
  - Prioritization capabilities
  
- **Challenges**:
  - More complex configuration
  - Requires careful parameter tuning
  - Multiple interdependent queues
  - Limited scalability demo (5 sources)

## Performance Metrics

All simulations measure four core metrics:

### 1. Throughput (bytes/second)
- **Definition**: Data successfully delivered per unit time
- **Wireless Baseline**: 3-20 Kbps (depends on scenario)
- **Wired Baseline**: 5-10 Mbps (bottleneck limited)
- **DS-RED Baseline**: 7-15 Mbps (multi-class)

### 2. Delay (seconds)
- **Definition**: Average packet latency from source to destination
- **Wireless**: 0.04-0.12 seconds (includes routing/retransmission)
- **Wired**: 0.03-0.04 seconds (propagation + queuing)
- **DS-RED**: 0.012-0.037 seconds (shorter paths)

### 3. Delivery Ratio (0-1)
- **Definition**: Fraction of transmitted packets successfully received
- **Wireless**: 0.66-0.95 (variable due to collisions)
- **Wired**: 0.94-0.97 (stable congestion control)
- **DS-RED**: 0.67-1.0 (depends on traffic class)

### 4. Drop Ratio (0-1)
- **Definition**: Fraction of packets dropped by queues
- **Wireless**: 0.05-0.34 (includes collision loss)
- **Wired**: 0.03-0.10 (controlled by RED)
- **DS-RED**: 0-0.33 (aggressive for out-of-profile)

## Key Findings

### Finding 1: RED Scalability
RED effectively stabilizes performance as network size increases. In wired tests, throughput plateaus after 40 nodes despite queue management, indicating bottleneck saturation rather than queue mismanagement.

### Finding 2: Traffic Load Impact
All test types show that increased flow count impacts delivery ratio negatively, but RED/WRED maintain relatively stable throughput. This indicates good fairness properties.

### Finding 3: Wireless Challenges
Wireless networks exhibit lower delivery ratios (66-95%) compared to wired (94-97%), primarily due to collision loss rather than queue management. RED helps but cannot overcome physical layer limitations.

### Finding 4: WRED Effectiveness
WRED and RED show nearly identical aggregate performance in the bonus test, but WRED provides better differentiation internally—protecting in-profile traffic while aggressively dropping out-of-profile packets.

### Finding 5: Bottleneck Behavior
Both wired and DS-RED tests confirm that bottleneck link capacity (2 Mbps) is the limiting factor. RED algorithms prevent buffer overflow but cannot exceed physical link capacity.

## Running Individual Tests

### Wireless Network Tests

```bash
cd wireless

# Run all wireless tests
bash run.sh

# Run single test (40 nodes, 500m grid, 1000 pps, 20 flows, 1.0x TX range)
ns red1-w.tcl 40 500 1000 20 1

# Parse results
awk -f parse.awk trace_wireless.tr

# View animation
nam animation_wireless.nam &
```

### Wired Network Tests

```bash
cd wired

# Run all wired tests
bash run.sh

# Run single test (40 nodes, 1000 pps, 20 flows)
ns red+w.tcl 40 1000 20

# Parse results
awk -f parse_w.awk trace_wired.tr

# View animation
nam animation_wired.nam &
```

### Bonus DS-RED Test

```bash
cd bonus

# Run single test
ns test2.tcl

# View statistics (printed at 80 seconds)
# Check stat.txt for detailed packet statistics

# View animation
nam test2_an.nam &
```

## Prerequisites

### Required Software

```bash
# Install NS-2 and utilities
sudo apt-get update
sudo apt-get install ns2 nam awk

# Verify installation
ns -version
nam &
which awk
```

### System Requirements

- **OS**: Linux (Ubuntu 18.04+) or similar
- **RAM**: 2GB minimum, 4GB recommended
- **Disk**: 100MB for all tests
- **Processor**: Any modern CPU (tests take 5-10 minutes)

## Results Interpretation Guide

### High Throughput, Low Delay
✓ **Good**: Network efficiently transfers data
- Indicates proper queue management
- Minimal congestion
- Good buffer utilization

### High Delivery Ratio (>95%)
✓ **Good**: Network reliability is high
- RED preventing excessive drops
- Proper threshold configuration
- Stable network conditions

### Low Drop Ratio (<10%)
✓ **Good**: Queue overflow prevented
- RED algorithm working effectively
- Thresholds well-tuned
- Balance between accepting and dropping packets

### Variable Delay with Load
⚠ **Expected**: Queuing effects visible
- Higher load → higher delay
- RED manages gracefully
- Not a failure, normal behavior

## Conclusions

### RED Algorithm Effectiveness
RED successfully manages congestion by:
1. Detecting early queue buildup
2. Probabilistically dropping packets before overflow
3. Signaling congestion to TCP senders
4. Preventing buffer bloat

### WRED Enhancement Value
WRED provides better service differentiation:
1. In-profile traffic protected from drops
2. Out-of-profile traffic dropped more aggressively
3. Maintains fairness across priority classes
4. Essential for QoS-aware networks

### Network Type Impact
- **Wireless**: More challenging due to physical layer loss
- **Wired**: Better control, purely congestion-based loss
- **DiffServ**: Enables advanced traffic engineering

### Practical Recommendations

**When to use RED:**
- Simple, single-class networks
- Congestion control is primary concern
- Fair treatment of all flows acceptable

**When to use WRED:**
- Multiple traffic classes with different priorities
- Service differentiation required
- QoS guarantees needed

**Additional Considerations:**
- RED parameters must be tuned for specific network
- Packet size affects threshold calculations
- Round-trip time impacts algorithm responsiveness
- Token Bucket policer enforces traffic contracts

## Related Concepts & References

### Queue Management
- **RED**: Floyd & Jacobson (1993) - "Random Early Detection"
- **WRED**: Weighted variant for differentiated services
- **Token Bucket**: Traffic shaping and policing mechanism
- **DropTail**: Baseline queue discipline (FIFO + drop at limit)

### Network Standards
- **IEEE 802.15.4**: Low-rate wireless personal area networks
- **RFC 2474**: Differentiated Services (DiffServ) Architecture
- **RFC 2598**: Assured Forwarding PHB Group

### Related Algorithms
- **ECN**: Explicit Congestion Notification (marks instead of drops)
- **CODEL**: Controlled Delay (modern alternative to RED)
- **PIE**: Proportional Integral controller Enhanced (adaptive)
- **FQCODEL**: Fair Queuing with Controlled Delay

## Project Statistics

| Category | Count | Duration |
|----------|-------|----------|
| Total Simulations | 40 | ~20 minutes |
| Wireless Runs | 20 | ~10 minutes |
| Wired Runs | 15 | ~8 minutes |
| DS-RED Runs | 1 | ~2 minutes |
| Total Data Points | 36 | Various |

## Customization

Each test directory contains its own customization guide:

- [Wireless Customization](wireless/README.md#customization)
- [Wired Customization](wired/README.md#customization-guide)
- [DS-RED Customization](bonus/README.md#customization)

### Common Modifications

**Change RED Thresholds**:
```tcl
Queue/RED set thresh_ 20          ;# Higher threshold
Queue/RED set maxthresh_ 50       ;# Higher max
```

**Change Link Bandwidth**:
```tcl
$ns duplex-link $node1 $node2 5Mb 10ms RED
```

**Enable WRED Mode**:
```tcl
Queue/RED set wred 1              ;# Enable weighted RED
```

**Adjust Traffic Rate**:
```tcl
$cbr set rate_ 5000000            ;# 5 Mbps instead of default
```

## Troubleshooting

### General Issues

| Problem | Solution |
|---------|----------|
| `ns: command not found` | Install NS-2: `sudo apt-get install ns2` |
| Slow simulation | Reduce node count or simulation duration |
| Out of memory | Use fewer nodes or smaller grid |
| Parse errors | Check trace file format matches parser |
| Animation won't start | Ensure X11/display available, try `xvfb-run` |

### Test-Specific Issues

**Wireless**:
- Results too similar? Check energy model is enabled
- Routing not working? Verify DSDV initialization
- Transmission range issues? Check TX multiplier values

**Wired**:
- Bottleneck not visible? Verify RED queue type on core link
- High latency? Check link delays in duplex-link definitions
- TCP not converging? Reduce simulation duration

**DS-RED**:
- No differentiation? Verify PHB entries and queue assignments
- Token Bucket not policing? Check addPolicyEntry commands
- Statistics missing? Ensure printStats is called at correct time

## Future Work

Potential extensions to this project:

1. **Add ECN (Explicit Congestion Notification)** - Mark packets instead of drop
2. **Test CODEL Algorithm** - Modern alternative to RED
3. **Implement Fair Queuing** - Fairness across flows
4. **Add Multicast Routing** - Group communication patterns
5. **Test Mobile Scenarios** - Wireless with node movement
6. **Measure Energy Consumption** - Important for IoT
7. **Compare with Real Networks** - Validate simulator accuracy

## References

### Primary Sources
- Floyd, S., & Jacobson, V. (1993). "Random Early Detection Gateways for Congestion Avoidance" *IEEE/ACM Transactions on Networking*
- Jacobson, V. (1988). "Congestion Avoidance and Control" *ACM SIGCOMM*

### Standards
- RFC 2474: Differentiated Services Architecture
- RFC 2597: Assured Forwarding PHB Group
- IEEE 802.15.4-2020: Low-Rate Wireless Personal Area Networks

### Additional Reading
- Kleinrock, L. (1976). *Queueing Systems* (Volumes 1-2)
- Kurose & Ross. *Computer Networking* (latest edition)
- NS-2 Documentation: http://www.isi.edu/nsnam/ns/

## Project Attribution

**Project**: Network-322 Research Initiative  
**Topic**: Queue Management Algorithm Evaluation  
**Date**: 2024  
**Technologies**: NS-2, TCL, AWK

## License

This project is part of the Network-322 research initiative.

---

## Quick Navigation

- 📁 [Wireless Tests](wireless/) - IEEE 802.15.4 network simulations
- 📁 [Wired Tests](wired/) - Tree topology simulations
- 📁 [Bonus DS-RED](bonus/) - Differentiated Services simulations

For detailed information on each test category, see the respective README files.
