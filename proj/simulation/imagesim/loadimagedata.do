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
    echo "Filename of input PNG:"
    set f "input.png"
} else {
    echo "Filename of input PNG:"
    set f $2
}

convert -size 1024x480 -depth 8 ../imagesim/$f rgb:input.raw
echo "Converted PNG to RAW"

../imagesim/rawtodram -s 0 -n 8 -i input.raw -o U1.binl U2.binl U3.binl U4.binl U6.binl U7.binl U8.binl U9.binl
echo "Split RAW data into chip files"

mem load -infile U1.binl -format bin /system_tb/dram/U1/mem_array -startaddress $sadr -endaddress $eadr
mem load -infile U2.binl -format bin /system_tb/dram/U2/mem_array -startaddress $sadr -endaddress $eadr
mem load -infile U3.binl -format bin /system_tb/dram/U3/mem_array -startaddress $sadr -endaddress $eadr
mem load -infile U4.binl -format bin /system_tb/dram/U4/mem_array -startaddress $sadr -endaddress $eadr
mem load -infile U6.binl -format bin /system_tb/dram/U6/mem_array -startaddress $sadr -endaddress $eadr
mem load -infile U7.binl -format bin /system_tb/dram/U7/mem_array -startaddress $sadr -endaddress $eadr
mem load -infile U8.binl -format bin /system_tb/dram/U8/mem_array -startaddress $sadr -endaddress $eadr
mem load -infile U9.binl -format bin /system_tb/dram/U9/mem_array -startaddress $sadr -endaddress $eadr
echo "Loaded chip files into simulation"
