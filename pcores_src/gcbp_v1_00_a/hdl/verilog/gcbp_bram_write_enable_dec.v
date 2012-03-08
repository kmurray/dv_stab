`timescale 1ns / 1ps

//Which BRAM should we be writting?
module GCBP_BRAM_WRITE_ENABLE_DEC(
    input i_gcbp_line_ready,
    input i_valid_subimage_line,
    input[1:0] i_vert_subimage_cnt,
    input[1:0] i_hori_subimage_cnt,

    output reg [15:0] o_bram_array_wea
    );
    
    wire [3:0] w_bram_num;

    //Convert two components (0-3) to single bram target (0-15) 
    assign w_bram_num = 4*i_vert_subimage_cnt + i_hori_subimage_cnt;

    reg [15:0] r_write_enable;

    // Decoder for "1 hot" encoded bram write enables
    always@(*)
    begin
        case(w_bram_num)
		0: r_write_enable  = 16'b0000000000000001;
		1: r_write_enable  = 16'b0000000000000010;
		2: r_write_enable  = 16'b0000000000000100;
		3: r_write_enable  = 16'b0000000000001000;
		4: r_write_enable  = 16'b0000000000010000;
		5: r_write_enable  = 16'b0000000000100000;
		6: r_write_enable  = 16'b0000000001000000;
		7: r_write_enable  = 16'b0000000010000000;
		8: r_write_enable  = 16'b0000000100000000;
		9: r_write_enable  = 16'b0000001000000000;
		10: r_write_enable = 16'b0000010000000000;
		11: r_write_enable = 16'b0000100000000000;
		12: r_write_enable = 16'b0001000000000000;
		13: r_write_enable = 16'b0010000000000000;
		14: r_write_enable = 16'b0100000000000000;
		15: r_write_enable = 16'b1000000000000000;
        default: r_write_enable = 16'b0000000000000000;
        endcase
    end

    //Only active the write if the line is signalled ready, and
    //vertically falls into a sub image
    always@(*)
    begin
        if (i_gcbp_line_ready && i_valid_subimage_line)
            o_bram_array_wea = r_write_enable;
        else
            o_bram_array_wea = 16'b0000000000000000;
    end

endmodule
