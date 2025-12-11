# Bonus: Differentiated Services RED (DS-RED) Test

## Overview

This test evaluates **Differentiated Services with Random Early Detection (DS-RED)** in a multi-class queuing environment. The simulation compares **WRED (Weighted RED)** and **RED** queue management algorithms in a network with traffic prioritization using **Token Bucket policers** to enforce committed information rates and burst sizes for different traffic classes.

## Project Structure

### Files

- **`test2.tcl`** - Main TCL simulation script implementing DS-RED with Token Bucket policing
- **`results.txt`** - Aggregated performance metrics comparing WRED and RED
- **`stat.txt`** - Detailed packet statistics and queue performance metrics
- **`test2_tr.tr`** - NS-2 trace file (generated during simulation)
- **`test2_an.nam`** - NAM animation file (generated during simulation)

## Network Topology

### Architecture

```
                              ------
                              |core|
                              ------
                             /      \
                            /        \
                   10Mb,5ms /          \ 2Mb,15ms
                  (DropTail)/            \(dsRED/core)
                          /                \
    ----                 /----    2Mb    ----           ------
    |s1|--------        |e1 |-----------|e2|-----------|dest|
    ----  10Mb,5ms     /----   15ms   ----   10Mb,5ms ------
          (DropTail)  /               (dsRED/edge)
    ----            /
    |s2|-----------
    ----  10Mb,5ms
         (DropTail)

    (s3, s4, s5 similar to s1, s2)

    Flow:  s1-s5 → e1 → core → e2 → dest
```

### Network Components

| Component | Bandwidth | Delay | Queue Type | Purpose |
|-----------|-----------|-------|------------|---------|
| Source → Edge1 (x5) | 10 Mbps | 5 ms | DropTail | Access links |
| Edge1 → Core | 2 Mbps | 15 ms | dsRED/edge | Bottleneck + Ingress |
| Core → Edge1 | 2 Mbps | 15 ms | dsRED/core | Return path + Egress |
| Core → Edge2 | 2 Mbps | 15 ms | dsRED/core | Core link |
| Edge2 → Core | 2 Mbps | 15 ms | dsRED/edge | Return core link |
| Edge2 → Destination | 10 Mbps | 5 ms | DropTail | Egress link |

## Differentiated Services Configuration

### Traffic Classes and Policing

Two traffic classes are defined using **Token Bucket** policers:

#### Traffic Class 1 (Premium/High Priority)
| Parameter | Value | Description |
|-----------|-------|-------------|
| **Sources** | s1, s3 | Premium sources |
| **CIR** | 1,000,000 bps | Committed Information Rate |
| **CBS** | 3,000 bytes | Committed Burst Size |
| **Policer ID** | 10 | Classification value |

#### Traffic Class 2 (Best-Effort/Low Priority)
| Parameter | Value | Description |
|-----------|-------|-------------|
| **Sources** | s2, s4, s5 | Best-effort sources |
| **CIR** | 1,000,000 bps | Committed Information Rate |
| **CBS** | 10,000 bytes | Committed Burst Size |
| **Policer ID** | 11 | Classification value |

### RED Queue Parameters

**Queue 0 (In-profile traffic - PHB 10):**
- Minimum threshold: 20 packets
- Maximum threshold: 40 packets
- Weight: 0.02 (faster response)
- Conservative dropping

**Queue 1 (Out-of-profile traffic - PHB 11):**
- Minimum threshold: 10 packets
- Maximum threshold: 20 packets
- Weight: 0.10 (aggressive response)
- Aggressive dropping for out-of-profile

## Simulation Configuration

### Traffic Generation

**Protocol**: UDP with CBR (Constant Bit Rate)

| Parameter | Value |
|-----------|-------|
| Packet Size | 1000 bytes |
| Data Rate | 2,000,000 bps (2 Mbps) |
| Start Time | 0.0 seconds |
| Stop Time | 85.0 seconds |
| Sources | 5 (s1 through s5) |
| Destination | 1 (dest) |

### Simulation Duration
- **Total Time**: 85.0 seconds
- **Warm-up Period**: 0-80 seconds (traffic running)
- **Statistics Collection**: At 80 seconds
- **Cool-down**: 80-85 seconds

## Queue Management Algorithms

### RED (Random Early Detection)
- All traffic classes treated equally
- Single probability function for dropping
- No differentiation between in-profile and out-of-profile traffic
- Baseline comparison for DS-RED

### WRED (Weighted Random Early Detection)
- Differentiated dropping based on traffic class
- In-profile traffic (PHB 10): Lower drop probability
- Out-of-profile traffic (PHB 11): Higher drop probability
- Maintains quality of service for premium traffic

## DS-RED Processing Pipeline

### Edge Router (e1 → core, e2 → core)

1. **Policy Lookup**: Identify source-destination pair and apply policer
2. **Token Bucket Policing**: 
   - Check if packet conforms to CIR/CBS
   - Mark as in-profile (10) or out-of-profile (11)
3. **PHB Assignment**: Map color (policer output) to priority class
4. **Queue Selection**: Route to appropriate queue based on PHB
5. **RED Processing**: Apply RED algorithm based on queue depth

### Core Router (core → e1, core → e2)

1. **Queue Selection**: Forward packets to appropriate queue based on PHB
2. **RED Processing**: Apply RED algorithm
3. **Transmission**: Send packets on outgoing link

## Performance Metrics

From `results.txt`, four metrics are measured:

| Metric | Unit | Description |
|--------|------|-------------|
| **Throughput** | bytes/second | Data transfer rate |
| **Delay** | seconds | Average packet latency |
| **Delivery Ratio** | 0-1 | Fraction of packets delivered |
| **Drop Ratio** | 0-1 | Fraction of packets dropped |

## Results Analysis

### Test Results

#### WRED (Weighted RED)
```
Flow 1 (single source): 
  Throughput: 7,836 Kbps    Delay: 0.0124s   Delivery: 100%    Drops: 0%

Flow 2 (two concurrent):
  Throughput: 9,791 Kbps    Delay: 0.0280s   Delivery: 83.4%   Drops: 16.6%

Flow 3 (three concurrent):
  Throughput: 11,743 Kbps   Delay: 0.0367s   Delivery: 75.0%   Drops: 25.0%

Flow 4 (four concurrent):
  Throughput: 13,698 Kbps   Delay: 0.0323s   Delivery: 70.0%   Drops: 30.0%

Flow 5 (five concurrent):
  Throughput: 15,652 Kbps   Delay: 0.0290s   Delivery: 66.7%   Drops: 33.3%
```

#### RED (Non-Differentiated)
```
Flow 1 (single source):
  Throughput: 7,836 Kbps    Delay: 0.0124s   Delivery: 100%    Drops: 0%

Flow 2 (two concurrent):
  Throughput: 9,791 Kbps    Delay: 0.0286s   Delivery: 83.4%   Drops: 16.4%

Flow 3 (three concurrent):
  Throughput: 11,743 Kbps   Delay: 0.0371s   Delivery: 75.0%   Drops: 24.9%

Flow 4 (four concurrent):
  Throughput: 13,698 Kbps   Delay: 0.0326s   Delivery: 70.0%   Drops: 29.9%

Flow 5 (five concurrent):
  Throughput: 15,654 Kbps   Delay: 0.0292s   Delivery: 66.7%   Drops: 33.1%
```

### Key Observations

**Performance Comparison:**
- WRED and RED show **nearly identical performance** across all test cases
- Throughput scales similarly (7.8 Mbps → 15.6 Mbps)
- Delay remains relatively stable (0.012s → 0.037s)
- Delivery ratio decreases proportionally with number of flows

**Why Similar Performance?**
1. Token Bucket rates are the same for both classes
2. PHB queue parameters provide balanced service
3. Bottleneck (2 Mbps core link) limits throughput regardless of algorithm
4. Network is not severely congested in this scenario

**Bottleneck Effect:**
- 5 × 2 Mbps sources → 10 Mbps aggregate traffic
- 2 Mbps bottleneck link → ~20% of traffic dropped
- RED algorithms manage overflow similarly

## Queue Statistics (from stat.txt)

### Single Flow (s1 → dest)

**WRED Result:**
```
Total Packets:    19994
Transmitted:      19994
Ldrops (logic):   0
Edrops (early):   0
→ No packet loss, perfect delivery
```

### Multiple Flows (s1-s5 → dest)

**WRED at 80 seconds (five flows running):**
```
Class 10 (In-profile):
  Total:      50031  Transmitted: 19966  Drops: 29585 (59.1%)

Class 11 (Out-of-profile):
  Total:      49964  Transmitted: 73     Drops: 49884 (99.8%)
```

**RED at 80 seconds:**
```
Class 10:
  Total:      50031  Transmitted: 19921  Drops: 29655 (59.2%)

Class 11:
  Total:      49964  Transmitted: 118    Drops: 49835 (99.7%)
```

### Interpretation

- **Early Drops (edrops)**: RED probabilistic drops (~480-550 packets)
- **Logic Drops (ldrops)**: Queue overflow drops (~19000-20000 packets)
- **Out-of-profile traffic heavily dropped**: Maintains service for in-profile
- **Token Bucket enforcement effective**: Prevents bursty traffic

## Traffic Policing Behavior

### Token Bucket Algorithm

For each flow:
1. Token bucket starts with CBS tokens
2. Tokens accumulate at CIR rate
3. Each packet consumes tokens equal to its size
4. Conforming packets (tokens available): Marked as in-profile (PHB 10)
5. Non-conforming packets (no tokens): Marked as out-of-profile (PHB 11)

### Class 1 vs Class 2 Differences

**Class 1 Sources (s1, s3):**
- Smaller CBS (3,000 bytes) → smaller burst tolerance
- Stricter burst limit → fewer out-of-profile packets initially

**Class 2 Sources (s2, s4, s5):**
- Larger CBS (10,000 bytes) → larger burst tolerance
- More flexible burst limit → more out-of-profile packets

## Running the Simulation

### Prerequisites
```bash
# Install NS-2
sudo apt-get install ns2 nam
```

### Execute Simulation
```bash
# Run the main test
ns test2.tcl

# This will generate:
# - test2_tr.tr (trace file)
# - test2_an.nam (animation file)
```

### Visualization
```bash
# View network animation
nam test2_an.nam &
```

### Extract Statistics
The simulation prints statistics at 80 seconds showing:
- Packet counts per class
- Transmitted packets
- Logic drops (buffer overflow)
- Early drops (RED algorithm)

## Simulation Architecture

### DS-RED Queue Class

The `dsRED` queue class implements:

1. **Two-queue structure**: Separate queues for two priority classes
2. **Token Bucket Policing**: Input traffic classification
3. **PHB (Per-Hop Behavior)**: Mapping of colors to queues
4. **Configurable RED parameters**: Per-queue threshold and weight settings
5. **Statistics collection**: Track drops and transmissions

### Policy Entries

Policy entries define source-destination pairs and their policing parameters:
```tcl
addPolicyEntry [src_id] [dest_id] TokenBucket 10 [CIR] [CBS]
```

### PHB Entries

PHB entries map policer outputs to queue indices:
```tcl
addPHBEntry [color] [queue] [queue_index]
# color: 10 (in-profile) or 11 (out-of-profile)
# queue: 0 (for both)
# queue_index: 0 (in-profile queue) or 1 (out-of-profile queue)
```

## Customization

### Modify Traffic Rates

Edit `test2.tcl` lines 9-16:
```tcl
set cir0  1000000       ;# Class 1 committed rate (bps)
set cbs0     3000       ;# Class 1 burst size (bytes)
set rate0 2000000       ;# Class 1 traffic rate (bps)
set cir1  1000000       ;# Class 2 committed rate (bps)
set cbs1    10000       ;# Class 2 burst size (bytes)
set rate1 3000000       ;# Class 2 traffic rate (bps)
```

### Modify RED Parameters

Edit `test2.tcl` lines for queue configuration:
```tcl
$qE1C configQ 0 0 20 40 0.02    ;# Queue 0: thresh=20, maxthresh=40, weight=0.02
$qE1C configQ 0 1 10 20 0.10    ;# Queue 1: thresh=10, maxthresh=20, weight=0.10
```

### Change WRED to Standard Mode

Comment/uncomment line in `test2.tcl`:
```tcl
# $qE1C setMREDMode WRED        ;# Uncomment to enable WRED
```

### Add More Sources

Add additional source nodes and traffic connections:
```tcl
set s6 [$ns node]
$ns duplex-link $s6 $e1 10Mb 5ms DropTail
udptraffic $s6 $dest
```

## Key Insights

1. **DS-RED enables QoS**: Different treatment for in-profile vs out-of-profile traffic
2. **Token Bucket enforcement**: Controls burst size and average rate
3. **Early dropping effective**: RED algorithm prevents buffer overflow
4. **Fairness**: All flows share bottleneck, but in-profile traffic prioritized
5. **Scalability**: Works well with multiple flows and sources

## Related Concepts

- **Differentiated Services (DiffServ)**: RFC 2474, RFC 2598
- **Token Bucket**: Traffic shaping and policing mechanism
- **Per-Hop Behavior (PHB)**: AF (Assured Forwarding), EF (Expedited Forwarding)
- **RED Algorithm**: Jacobson & Floyd (1993)
- **WRED**: Weighted version of RED for multiple classes

## References

- Floyd, S., & Jacobson, V. (1993). "Random Early Detection Gateways for Congestion Avoidance"
- Blake, S., et al. (1998). "An Architecture for Differentiated Services" (RFC 2475)
- Heinanen, J., et al. (1999). "Assured Forwarding PHB Group" (RFC 2597)
- NS-2 Documentation: http://www.isi.edu/nsnam/ns/

## Observations

This bonus test demonstrates how **differentiated services with RED** can manage traffic congestion while maintaining service quality for priority traffic. Although WRED and RED show similar aggregate performance in this scenario, the internal queue management differs significantly—WRED protects in-profile traffic from out-of-profile drops, which is crucial in real networks with mixed QoS requirements.

The Token Bucket policer effectively enforces contracted rates, ensuring that traffic exceeding the CIR is marked accordingly and subject to more aggressive dropping when congestion occurs.
