
# to execute tcl file in for loop

echo "results for wired varying node\n" >>results.txt

for i in {1..5}
do
    
    val=$((i*20))
    echo "Running $val"
    ns red+w.tcl $val 1000 20 >>stat1-w.txt
    awk -f parse_w.awk trace_wired.tr >> results.txt
done
echo "results for wired varying flow\n" >>results.txt
for i in {1..5}
do
    
    val=$((i*10))
    echo "Running $val"
    ns red+w.tcl 40 1000 $val >>stat1-w.txt
    awk -f parse_w.awk trace_wired.tr >> results.txt
done
echo "results for wired varying packet no \n" >>results.txt
for i in {1..5}
do
    
    val=$((i*100))
    echo "Running $val"
    ns red+w.tcl 40 $val 20 >>stat1-w.txt
    awk -f parse_w.awk trace_wired.tr >> results.txt
done

