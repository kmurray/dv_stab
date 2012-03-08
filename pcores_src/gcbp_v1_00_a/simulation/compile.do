vlib work
vlog +acc  "../hdl/verilog/gcbp_line_detect.v"
vlog +acc  "../hdl/verilog/gcbp_frame_detect.v"
vlog +acc  "../hdl/verilog/gcbp_line_gen.v"
vlog +acc  "../hdl/verilog/gcbp_bram_write_enable_dec.v"
vlog +acc  "../hdl/verilog/gcbp_bram_addr_dec.v"
vlog +acc  "../hdl/verilog/gcbp.v"
vlog +acc  "../hdl/verilog/gcbp_tb.v"
vlog +acc  "~/CAD/Xilinx/10.1/ISE/verilog/src/glbl.v"
#vsim -t 1ps   -L xilinxcorelib_ver -L unisims_ver -L unimacro_ver -L secureip -lib work gcbp_tb glbl
vsim -t 1ps -lib work gcbp_tb glbl
log -r /*
do wave.do
#run 6000ns
 # One line
#run 120000ns

# 10 lines
#run 1200000ns

# 100 lines
run 12000000ns

#1000 lines (~2.5 Frames)
run 120000000ns


