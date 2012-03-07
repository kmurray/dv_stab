if {( $argc != 2 )} {
    echo "Error: must provide run time and time unit (e.g. '1 ms')"
    abort
}

# copy in the memory initialization file, so MODELSIM doens't crap out on brams
cp ../../pcores/bram_array_v1_00_a/hdl/verilog/bram.mif bram.mif

#Fix missing library refs
alias s   "vsim -novopt -t ps -L XilinxCoreLib -L XilinxCoreLib_ver -L secureip -L unisims_ver system_tb glbl; set xcmds 1"




# Add the ddr dim
echo "Adding dim"
do ../ddr_dimm/add_dimm.do

echo "Adding video images"
do ../videoin/setvideoin.do ../videoin/lenna.png ../videoin/test.png

echo "Compiling"
c

echo "Starting"
s

echo "Config wave window"
w

echo "Running sim for $1 $2"
# $1 should be time time to run
# $2 should be the unit of time
run $1 $2

echo "Grabbing processed image"
do ../imagesim/saveimagedata.do
