onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {}
add wave -noupdate -divider {GCBP_BRAM_ADDR_DEC - Inputs}
add wave -noupdate -label i_clk -radix hexadecimal /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/i_clk
add wave -noupdate -label i_resetn -radix hexadecimal /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/i_resetn
add wave -noupdate -label i_line_cnt -radix unsigned /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/i_line_cnt
add wave -noupdate -label i_new_frame -radix hexadecimal /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/i_new_frame

add wave -noupdate -divider {GCBP_BRAM_ADDR_DEC - Counters and State}
add wave -noupdate -height 16 -label r_curr_state -radix unsigned /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/r_curr_state
add wave -noupdate -label c_next_state -radix unsigned /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/c_next_state
    
add wave -noupdate -divider {GCBP_BRAM_ADDR_DEC - Outputs}
add wave -noupdate -label o_next_frame_loc -radix unsigned /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/o_next_frame_loc
add wave -noupdate -label o_curr_frame_loc -radix unsigned /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/o_curr_frame_loc
add wave -noupdate -label o_prev_frame_loc -radix unsigned /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/o_prev_frame_loc
add wave -noupdate -label o_bram_array_write_addr -radix unsigned /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/o_bram_array_write_addr

add wave -noupdate -divider {}
add wave -noupdate -divider {GCBP_WEA_DEC - inputs}
add wave -noupdate -label i_gcbp_line_ready -radix hexadecimal /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/i_gcbp_line_ready
add wave -noupdate -label i_vert_subimage_cnt -radix unsigned /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/i_vert_subimage_cnt
add wave -noupdate -label i_hori_subimage_cnt -radix unsigned /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/i_hori_subimage_cnt
add wave -noupdate -divider {GCBP_LINE_GEN - outputs and internals}
add wave -noupdate -label w_bram_num -radix unsigned /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/w_bram_num
add wave -noupdate -label r_write_enable -radix binary /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/r_write_enable
add wave -noupdate -label o_bram_array_wea -radix binary /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/o_bram_array_wea
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {GCBP_LINE_GEN - inputs}
add wave -noupdate -label i_clk -radix hexadecimal /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_clk
add wave -noupdate -label i_resetn -radix hexadecimal /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_resetn
add wave -noupdate -label i_luma_data -radix hexadecimal /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_luma_data
add wave -noupdate -label i_new_line -radix hexadecimal /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_new_line
add wave -noupdate -label i_luma_data_valid -radix hexadecimal /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_luma_data_valid
add wave -noupdate -divider {GCBP_LINE_GEN - Counters and State}
add wave -noupdate -label r_hori_pixel_cnt -radix unsigned /gcbp_tb/uut/GCBP_LINE_GEN_inst/r_hori_pixel_cnt
add wave -noupdate -label c_subimage_done_cnt -radix unsigned /gcbp_tb/uut/GCBP_LINE_GEN_inst/c_subimage_done_cnt
add wave -noupdate -label o_hori_subimage_cnt -radix unsigned /gcbp_tb/uut/GCBP_LINE_GEN_inst/o_hori_subimage_cnt
add wave -noupdate -label r_curr_state -radix unsigned /gcbp_tb/uut/GCBP_LINE_GEN_inst/r_curr_state
add wave -noupdate -label c_next_state -radix unsigned /gcbp_tb/uut/GCBP_LINE_GEN_inst/c_next_state
add wave -noupdate -divider {GCBP_LINE_GEN - Outputs}
add wave -noupdate -label o_gcbp_line_valid -radix hexadecimal /gcbp_tb/uut/GCBP_LINE_GEN_inst/o_gcbp_line_valid
add wave -noupdate -label r_gcbp_line_shift_reg -radix hexadecimal /gcbp_tb/uut/GCBP_LINE_GEN_inst/r_gcbp_line_shift_reg
add wave -noupdate -label o_gcbp_line -radix hexadecimal /gcbp_tb/uut/GCBP_LINE_GEN_inst/o_gcbp_line
add wave -noupdate /gcbp_tb/uut/i_clk
add wave -noupdate /gcbp_tb/uut/i_resetn
add wave -noupdate /gcbp_tb/uut/i_luma_data
add wave -noupdate /gcbp_tb/uut/i_new_line
add wave -noupdate /gcbp_tb/uut/i_luma_data_valid
add wave -noupdate /gcbp_tb/uut/i_line_cnt
add wave -noupdate /gcbp_tb/uut/i_new_frame
add wave -noupdate /gcbp_tb/uut/o_bram_array_write_addr
add wave -noupdate /gcbp_tb/uut/o_bram_array_write_data
add wave -noupdate /gcbp_tb/uut/o_bram_array_write_enable
add wave -noupdate /gcbp_tb/uut/o_next_frame_loc
add wave -noupdate /gcbp_tb/uut/o_curr_frame_loc
add wave -noupdate /gcbp_tb/uut/o_prev_frame_loc
add wave -noupdate /gcbp_tb/uut/r_curr_state
add wave -noupdate /gcbp_tb/uut/c_next_state
add wave -noupdate /gcbp_tb/uut/c_vert_subimage_cnt
add wave -noupdate /gcbp_tb/uut/c_subimage_done_row_cnt
add wave -noupdate /gcbp_tb/uut/w_hori_subimage_cnt
add wave -noupdate /gcbp_tb/uut/w_gcbp_subimage_line_valid
add wave -noupdate /gcbp_tb/uut/w_gcbp_subimage_line
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6907500000 ps} 0}
configure wave -namecolwidth 340
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {5911764705 ps} {9061764705 ps}
