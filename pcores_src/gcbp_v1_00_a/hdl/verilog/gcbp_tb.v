`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:35:50 03/02/2012
// Design Name:   GCBP
// Module Name:   gcbp_tb.v
// Project Name:  gcbp
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: GCBP
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module gcbp_tb;

	// Inputs
	reg i_clk;
	reg i_resetn;
	reg [8:0] i_luma_data;
	reg i_new_line;
	reg i_luma_data_valid;
	reg [8:0] i_line_cnt;
	reg i_new_frame;

	// Outputs
	wire [8:0] o_bram_array_write_addr;
	wire [127:0] o_bram_array_write_data;
	wire [15:0] o_bram_array_write_enable;
	wire [1:0] o_next_frame_loc;
	wire [1:0] o_curr_frame_loc;
	wire [1:0] o_prev_frame_loc;

	// Instantiate the Unit Under Test (UUT)
	gcbp uut (
		.i_clk(i_clk), 
		.i_resetn(i_resetn), 
		.i_luma_data(i_luma_data), 
		.i_new_line(i_new_line), 
		.i_luma_data_valid(i_luma_data_valid), 
		.i_line_cnt(i_line_cnt), 
		.i_new_frame(i_new_frame), 
		.o_bram_array_write_addr(o_bram_array_write_addr), 
		.o_bram_array_write_data(o_bram_array_write_data), 
		.o_bram_array_write_enable(o_bram_array_write_enable), 
		.o_next_frame_loc(o_next_frame_loc), 
		.o_curr_frame_loc(o_curr_frame_loc), 
		.o_prev_frame_loc(o_prev_frame_loc) 
	);

	initial begin
		// Initialize Inputs
		i_clk = 0;
		i_resetn = 0;
		i_luma_data = 0;
		i_new_line = 0;
		i_luma_data_valid = 0;
		i_line_cnt = 0;
		i_new_frame = 0;

		// Wait 100 ns for global reset to finish
		#100;

        //Set constants
        i_resetn = 1;
        i_luma_data = 8'b00010000;
        //Initial stimuli
        #3;
        i_new_line = 1;
        i_new_frame = 1;
        #8;
        i_new_line = 0;
        i_new_frame = 0;

    end

        
    //clock
    always
        #5 i_clk = !i_clk;

    //Indicate luma data is ready
    always
    begin
        #138 i_luma_data_valid = 1;
        #10 i_luma_data_valid = 0;
    end

    //Swap luma data for each sub image (horizontal)
/*  always
    begin
        #25005 i_luma_data = 8'b00000000;
        #50165 i_luma_data = 8'b00010000;
        #75325 i_luma_data = 8'b00000000;

    end
*/

    //Indicate the start of a new line of the frame
    always
    begin
        #107150 i_new_line = 1;
        #10 i_new_line = 0;
    end

    //Start of a new frame
    always
    begin
        #57600000 i_new_frame = 1;
        #10 i_new_frame = 0;
    end

    //Line counter
    always
    begin
        #107150 i_line_cnt = i_line_cnt + 1;
    end
    
      
endmodule

