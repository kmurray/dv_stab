if {$argc < 1} {
    echo "Start address per chip:"
    set sadr 0
} else {
    echo "Start address per chip:"
    set sadr [expr {$1 >> 3}]
}

echo "End address per chip:"
set eadr [expr {$sadr + 245759}]

if {$argc < 2} {
    echo "Filename of output PNG:"
    set f "output.png"
} else {
    echo "Filename of output PNG:"
    set f $2
}

mem save -outfile U1.bins -format bin -noaddress /system_tb/dram/U1/mem_array -startaddress $sadr -endaddress $eadr -wordsperline 8
mem save -outfile U2.bins -format bin -noaddress /system_tb/dram/U2/mem_array -startaddress $sadr -endaddress $eadr -wordsperline 8
mem save -outfile U3.bins -format bin -noaddress /system_tb/dram/U3/mem_array -startaddress $sadr -endaddress $eadr -wordsperline 8
mem save -outfile U4.bins -format bin -noaddress /system_tb/dram/U4/mem_array -startaddress $sadr -endaddress $eadr -wordsperline 8
mem save -outfile U6.bins -format bin -noaddress /system_tb/dram/U6/mem_array -startaddress $sadr -endaddress $eadr -wordsperline 8
mem save -outfile U7.bins -format bin -noaddress /system_tb/dram/U7/mem_array -startaddress $sadr -endaddress $eadr -wordsperline 8
mem save -outfile U8.bins -format bin -noaddress /system_tb/dram/U8/mem_array -startaddress $sadr -endaddress $eadr -wordsperline 8
mem save -outfile U9.bins -format bin -noaddress /system_tb/dram/U9/mem_array -startaddress $sadr -endaddress $eadr -wordsperline 8
echo "Stored chip files from simulation"

../imagesim/dramtoraw -s 0 -f 8 -b 245760 -o output.raw -i U1.bins U2.bins U3.bins U4.bins U6.bins U7.bins U8.bins U9.bins
echo "Collected chip data into RAW file"

convert -size 1024x480 -depth 8 rgb:output.raw ../imagesim/$f
echo "Converted RAW to PNG"

display ../imagesim/$f
