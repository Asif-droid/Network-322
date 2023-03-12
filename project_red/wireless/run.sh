# to execute tcl file in for loop

echo "results for wireless varying nodes\n" >>results.txt

for i in {1..5}
do
    
    val=$((i*20))
    echo "Running $val"
    ns red1-w.tcl $val 500 1000 20 1 >>stat1-w.txt
    awk -f parse.awk trace_wireless.tr >> results.txt
done 

echo "results for wireless varying no of flows\n" >>results.txt
for i in {1..5}
do
    
    val=$((i*10))
    echo "Running $val"
    ns red1-w.tcl 40 500 1000 $val 1 >>stat1-w.txt
    awk -f parse.awk trace_wireless.tr >> results.txt
done
echo "results for wireless varying no of packets\n" >>results.txt
for i in {1..5}
do
    
    val=$((i*100))
    echo "Running $val"
    ns red1-w.tcl 40 500 $val 20 1 >>stat1-w.txt
    awk -f parse.awk trace_wireless.tr >> results.txt
done
echo "results for wireless varying txRange\n" >>results.txt
for i in {1..5}
do
    
    
    echo "Running $i"
    ns red1-w.tcl 40 500 1000 20 $i >>stat1-w.txt
    awk -f parse.awk trace_wireless.tr >> results.txt
done
