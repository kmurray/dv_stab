vlib work
vlog +acc  "sum_of_3bit_pair.v"
vlog +acc  "six_three_comp.v"
vlog +acc  "twelve_four_comp.v"
vlog +acc  "ternary_add.v"
vlog +acc  "sum_of_64.v"
vlog +acc  "bitsum_comp.v"
vlog +acc  "correlator_xor.v"
vlog +acc  "correlator_tb.v"
vlog +acc  "bram.v"
vlog +acc  "C:/Xilinx/10.1/ISE/verilog/src/glbl.v"
vsim -t 1ps   -L xilinxcorelib_ver -L unisims_ver -L unimacro_ver -L secureip -lib work correlator_tb glbl
do wave.do
run 6000ns

