if {( $argc != 2 )} {
    echo "Error: must provide initial followed by logging run time"
    abort
}

# copy in the memory initialization file, so MODELSIM doens't crap out on brams
cp ../../pcores/bram_array_v1_00_a/hdl/verilog/bram.mif bram.mif

#Fix missing library refs
#alias s   "vsim -novopt -t ps -L XilinxCoreLib -L XilinxCoreLib_ver -L secureip -L unisims_ver system_tb glbl; set xcmds 1"
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

# Log all signals, will slow down sim and use more memory but enables access to all signals
nolog -all

run $1

#log -r /dut/video_to_ram_0/*
#log -r /dut/gcbp_0/*
#log -r /dut/bram_array_0/*
log -r /*


#Force the correlators to start on the partial frame, when the proc gets there
force sim:/system_tb/dut/correlator_xor_0/curr_frame_bram_offset 1
force sim:/system_tb/dut/correlator_xor_0/prev_frame_bram_offset 1

# $1 should be time time to run
run $2

echo "Grabbing processed image"
do ../imagesim/saveimagedata.do
