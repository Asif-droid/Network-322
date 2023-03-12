BEGIN {
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0;
    received_bytes = 0;
    
    start_time = 1000000;
    end_time = 0;

    # constants
    header_bytes = 20;

    energyPerNode = 12;
    numberOfNodes = 100;

    for (i = 0; i < numberOfNodes; i++) {
        energyOfNode[i] = energyPerNode;
    }
}


{
    event = $1;
    time_sec = $2;
    node = $3;
    layer = $4;
    packet_id = $6;
    packet_type = $7;
    packet_bytes = $8;
    energyValue = $7


    sub(/^_*/, "", node);
	sub(/_*$/, "", node);

    # set start time for the first line
    if(start_time > time_sec) {
        start_time = time_sec;
    }

# packet_type == "tcp" || packet_type == "udp" || packet_type == "cbr"
    if (layer == "AGT" && (packet_type == "tcp" || packet_type == "udp" || packet_type == "cbr")) {
        
        if(event == "s") {
            sent_time[packet_id] = time_sec;
            sent_packets += 1;
        }

        else if(event == "r") {
            delay = time_sec - sent_time[packet_id];
            
            total_delay += delay;


            bytes = (packet_bytes - header_bytes);
            received_bytes += bytes;

            
            received_packets += 1;
        }
    }
    if (event == "N"){
        energyOfNode[$5] = energyValue;
        # print "energy of node ",$5," is ",energyValue;
    }

    if ((packet_type == "tcp" || packet_type == "udp" || packet_type == "cbr") && event == "D") {
        dropped_packets += 1;
    }
}


END {
    end_time = time_sec;
    simulation_time = end_time - start_time;

    totalConsumedEnergy = energyPerNode * numberOfNodes;
    for(i = 0; i < numberOfNodes; i++){
        totalConsumedEnergy = totalConsumedEnergy - energyOfNode[i];
        
    }

    # print "Sent Packets: ", sent_packets;
    # print "Dropped Packets: ", dropped_packets;
    # print "Received Packets: ", received_packets;

    # print "-------------------------------------------------------------";
    # print "Throughput: ", (received_bytes * 8) / simulation_time, "bits/sec";
    # print "Average Delay: ", (total_delay / received_packets), "seconds";
    # print "Delivery ratio: ", (received_packets / sent_packets);
    # print "Drop ratio: ", (dropped_packets / sent_packets);
    # print "Energy Consumption: ", totalConsumedEnergy, "Joules";

    Throughput = (received_bytes * 8) / simulation_time;
    AverageDelay = (total_delay / received_packets);
    Deliveryratio = (received_packets / sent_packets);
    Dropratio = (dropped_packets / sent_packets);

    print Throughput,"," AverageDelay,"," Deliveryratio,"," Dropratio,"," totalConsumedEnergy;
}