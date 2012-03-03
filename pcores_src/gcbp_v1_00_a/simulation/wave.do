#add wave -noupdate -divider {gcbp_tb}
#add wave -noupdate -expand -group {Stimuli} -radix hexadecimal /gcbp_tb/i_*
#add wave -noupdate -expand -group {Outputs} -radix hexadecimal /gcbp_tb/o_*
#add wave -noupdate -divider {gcbp}
#add wave -noupdate -divider {sub blocks}


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


