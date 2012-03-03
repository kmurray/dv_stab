

module GCBP_BRAM_WRITE_ENABLE_DEC(
    input[1:0] vert_subimage_cnt,
    input[1:0] hori_subimage_cnt,

    output [15:0] bram_array_wea
    );
    
    wire bram_num;

    //Convert two components (0-3) to single bram target (0-15) 
    assign bram_num = 4*vert_subimage_cnt + hori_subimage_cnt;

    // Decoder for "1 hot" encoded bram write enables
    always@(*)
    begin
        case(bram_num)
		0: bram_array_wea  = 16'b0000000000000001;
		1: bram_array_wea  = 16'b0000000000000010;
		2: bram_array_wea  = 16'b0000000000000100;
		3: bram_array_wea  = 16'b0000000000001000;
		4: bram_array_wea  = 16'b0000000000010000;
		5: bram_array_wea  = 16'b0000000000100000;
		6: bram_array_wea  = 16'b0000000001000000;
		7: bram_array_wea  = 16'b0000000010000000;
		8: bram_array_wea  = 16'b0000000100000000;
		9: bram_array_wea  = 16'b0000001000000000;
		10: bram_array_wea = 16'b0000010000000000;
		11: bram_array_wea = 16'b0000100000000000;
		12: bram_array_wea = 16'b0001000000000000;
		13: bram_array_wea = 16'b0010000000000000;
		14: bram_array_wea = 16'b0100000000000000;
		15: bram_array_wea = 16'b1000000000000000;
        default: bram_array_wea = 16'b0000000000000000;
        endcase
    end

endmodule
