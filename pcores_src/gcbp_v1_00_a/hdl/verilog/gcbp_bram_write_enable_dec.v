module GCBP_BRAM_WRITE_ENABLE_DEC(
    input[1:0] vert_subimage_cnt,
    input[1:0] hori_subimage_cnt,

    output [15:0] bram_array_wea
    );
    
    wire bram_num;

    //Convert two components (0-3) to single bram target (0-15) 
    assign bram_num = 4*vert_subimage_cnt + hori_subimage_cnt;

    // Decoder for "1 hot" encoded bram write enables
    always(*)
    begin
        case(bram_num)
		0: bram_array_wea  = 16'b0000 0000 0000 0001;
		1: bram_array_wea  = 16'b0000 0000 0000 0010;
		2: bram_array_wea  = 16'b0000 0000 0000 0100;
		3: bram_array_wea  = 16'b0000 0000 0000 1000;
		4: bram_array_wea  = 16'b0000 0000 0001 0000;
		5: bram_array_wea  = 16'b0000 0000 0010 0000;
		6: bram_array_wea  = 16'b0000 0000 0100 0000;
		7: bram_array_wea  = 16'b0000 0000 1000 0000;
		8: bram_array_wea  = 16'b0000 0001 0000 0000;
		9: bram_array_wea  = 16'b0000 0010 0000 0000;
		10: bram_array_wea = 16'b0000 0100 0000 0000;
		11: bram_array_wea = 16'b0000 1000 0000 0000;
		12: bram_array_wea = 16'b0001 0000 0000 0000;
		13: bram_array_wea = 16'b0010 0000 0000 0000;
		14: bram_array_wea = 16'b0100 0000 0000 0000;
		15: bram_array_wea = 16'b1000 0000 0000 0000;
        default: bram_array_wea = 16'b0000 0000 0000 0000;
    end

endmodule
