#add wave -noupdate -divider {gcbp_tb}
#add wave -noupdate -expand -group {Stimuli} -radix hexadecimal /gcbp_tb/i_*
#add wave -noupdate -expand -group {Outputs} -radix hexadecimal /gcbp_tb/o_*
#add wave -noupdate -divider {gcbp}
#add wave -noupdate -divider {sub blocks}

########################
# GCBP
########################
add wave -noupdate -divider {}
add wave -noupdate -divider {GCBP - Inputs}
add wave -noupdate -radix hexadecimal -label i_clk /gcbp_tb/uut/i_clk
add wave -noupdate -radix hexadecimal -label i_resetn /gcbp_tb/uut/i_resetn
add wave -noupdate -radix binary -label i_new_line /gcbp_tb/uut/i_new_line
add wave -noupdate -radix binary -label i_luma_data_valid /gcbp_tb/uut/i_luma_data_valid
add wave -noupdate -radix unsigned -label i_line_cnt /gcbp_tb/uut/i_line_cnt
add wave -noupdate -radix binary -label i_new_frame /gcbp_tb/uut/i_new_frame

add wave -noupdate -divider {GCBP - Counters and State}
add wave -noupdate -radix unsigned -label c_vert_subimage_cnt /gcbp_tb/uut/c_vert_subimage_cnt
add wave -noupdate -radix unsigned -label c_subimage_done_row_cnt /gcbp_tb/uut/c_subimage_done_row_cnt
add wave -noupdate -radix unsigned -label w_hori_subimage_cnt /gcbp_tb/uut/w_hori_subimage_cnt
add wave -noupdate -radix unsigned -label w_gcbp_subimage_line_valid /gcbp_tb/uut/w_gcbp_subimage_line_valid
add wave -noupdate -radix unsigned -label w_valid_subimage_line /gcbp_tb/uut/w_valid_subimage_line
add wave -noupdate -radix unsigned -label r_curr_state /gcbp_tb/uut/r_curr_state
add wave -noupdate -radix unsigned -label c_next_state /gcbp_tb/uut/c_next_state

add wave -noupdate -divider {GCBP - Outputs}
add wave -noupdate -radix unsigned -label o_bram_array_write_addr /gcbp_tb/uut/o_bram_array_write_addr
add wave -noupdate -radix binary -label o_bram_array_write_enable /gcbp_tb/uut/o_bram_array_write_enable
add wave -noupdate -radix hexadecimal -label o_bram_array_write_data /gcbp_tb/uut/o_bram_array_write_data
add wave -noupdate -radix unsigned -label o_next_frame_loc /gcbp_tb/uut/o_next_frame_loc
add wave -noupdate -radix unsigned -label o_curr_frame_loc /gcbp_tb/uut/o_curr_frame_loc
add wave -noupdate -radix unsigned -label o_prev_frame_loc /gcbp_tb/uut/o_prev_frame_loc

########################
# GCBP_BRAM_ADDR_DEC
########################
add wave -noupdate -divider {}
add wave -noupdate -divider {GCBP_BRAM_ADDR_DEC - Inputs}
add wave -noupdate -radix hexadecimal -label i_clk /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/i_clk
add wave -noupdate -radix hexadecimal -label i_resetn /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/i_resetn
add wave -noupdate -radix hexadecimal -label i_valid_subimage_line /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/i_valid_subimage_line
add wave -noupdate -radix hexadecimal -label i_new_line /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/i_new_line
add wave -noupdate -radix hexadecimal -label i_new_frame /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/i_new_frame


add wave -noupdate -divider {GCBP_BRAM_ADDR_DEC - Counters and State}
add wave -noupdate -radix unsigned -label r_subimage_line_cnt /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/r_subimage_line_cnt
add wave -noupdate -radix unsigned -label r_curr_state /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/r_curr_state
add wave -noupdate -radix unsigned -label c_next_state /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/c_next_state

add wave -noupdate -divider {GCBP_BRAM_ADDR_DEC - Outputs}
add wave -noupdate -radix unsigned -label o_next_frame_loc /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/o_next_frame_loc
add wave -noupdate -radix unsigned -label o_curr_frame_loc /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/o_curr_frame_loc
add wave -noupdate -radix unsigned -label o_prev_frame_loc /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/o_prev_frame_loc
add wave -noupdate -radix unsigned -label o_bram_array_write_addr /gcbp_tb/uut/GCBP_BRAM_ADDR_DEC_inst/o_bram_array_write_addr



########################
# GCBP_BRAM_WRITE_ENABLE_DEC
########################
add wave -noupdate -divider {}
add wave -noupdate -divider {GCBP_WEA_DEC - inputs}
add wave -noupdate -radix hexadecimal -label i_gcbp_line_ready /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/i_gcbp_line_ready
add wave -noupdate -radix hexadecimal -label i_valid_subimage_liney /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/i_valid_subimage_line
add wave -noupdate -radix unsigned -label i_vert_subimage_cnt /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/i_vert_subimage_cnt
add wave -noupdate -radix unsigned -label i_hori_subimage_cnt /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/i_hori_subimage_cnt

add wave -noupdate -divider {GCBP_LINE_GEN - outputs and internals}
add wave -noupdate -radix unsigned -label w_bram_num /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/w_bram_num
add wave -noupdate -radix binary -label r_write_enable /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/r_write_enable
add wave -noupdate -radix binary -label o_bram_array_wea /gcbp_tb/uut/GCBP_BRAM_WRITE_ENABLE_DEC_inst/o_bram_array_wea


########################
# GCBP_LINE_GEN
########################

add wave -noupdate -divider {}
add wave -noupdate -divider {GCBP_LINE_GEN - inputs}
add wave -noupdate -radix hexadecimal -label i_clk  /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_clk
add wave -noupdate -radix hexadecimal -label i_resetn /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_resetn
add wave -noupdate -radix hexadecimal -label i_luma_data /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_luma_data
add wave -noupdate -radix hexadecimal -label i_new_line /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_new_line
add wave -noupdate -radix hexadecimal -label i_luma_data_valid /gcbp_tb/uut/GCBP_LINE_GEN_inst/i_luma_data_valid


add wave -noupdate -divider {GCBP_LINE_GEN - Counters and State}
add wave -noupdate -radix unsigned -label r_hori_pixel_cnt /gcbp_tb/uut/GCBP_LINE_GEN_inst/r_hori_pixel_cnt
add wave -noupdate -radix unsigned -label c_subimage_done_cnt /gcbp_tb/uut/GCBP_LINE_GEN_inst/c_subimage_done_cnt
add wave -noupdate -radix unsigned -label o_hori_subimage_cnt /gcbp_tb/uut/GCBP_LINE_GEN_inst/o_hori_subimage_cnt
add wave -noupdate -radix unsigned -label r_curr_state /gcbp_tb/uut/GCBP_LINE_GEN_inst/r_curr_state
add wave -noupdate -radix unsigned -label c_next_state /gcbp_tb/uut/GCBP_LINE_GEN_inst/c_next_state

add wave -noupdate -divider {GCBP_LINE_GEN - Outputs}
add wave -noupdate -radix hexadecimal -label o_gcbp_line_valid /gcbp_tb/uut/GCBP_LINE_GEN_inst/o_gcbp_line_valid
add wave -noupdate -radix hexadecimal -label r_gcbp_line_shift_reg /gcbp_tb/uut/GCBP_LINE_GEN_inst/r_gcbp_line_shift_reg
add wave -noupdate -radix hexadecimal -label o_gcbp_line /gcbp_tb/uut/GCBP_LINE_GEN_inst/o_gcbp_line


configure wave -namecolwidth 340
WaveRestoreZoom {0 ps} {126 us}


