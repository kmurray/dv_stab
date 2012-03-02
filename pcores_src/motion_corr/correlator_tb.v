`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:33:04 02/29/2012
// Design Name:   correlator_xor
// Module Name:   C:/Dropbox/ece532/PROJECT_TEST/correlator/correlator_proj/motion_corr/correlator_tb.v
// Project Name:  motion_corr
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: correlator_xor
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module correlator_tb;

	// Inputs
	reg clk;
	reg resetn;
	reg go;
	wire [127:0] bram_data;
	reg [5:0] x_offset;
	reg [5:0] y_offset;
	reg curr_frame_bram_offset_sel;

	// Outputs
	wire [8:0] bram_addr;
	wire [15:0] corr_sum;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	correlator_xor correlator_xor (
		.clk(clk), 
		.resetn(resetn), 
		.go(go), 
		.bram_data(bram_data), 
		.bram_addr(bram_addr), 
		.x_offset(x_offset), 
		.y_offset(y_offset), 
		.curr_frame_bram_offset_sel(curr_frame_bram_offset_sel), 
		.corr_sum(corr_sum), 
		.done(done)
	);

    //instantiate bram
    bram bram1 (
        .addra(bram_addr), // Bus [8 : 0] 
        .addrb(bram_addr), // Bus [8 : 0] 
        .clka(clk),
        .clkb(clk),
        .dina(128'h0), // Bus [127 : 0] 
        .doutb(bram_data), // Bus [127 : 0] 
        .wea(1'b0)
    );


	initial begin
		// Initialize Inputs
		clk = 0;
		resetn = 0;
		go = 0;
		x_offset = 0;
		y_offset = 0;
		curr_frame_bram_offset_sel = 0;

		#50;

	end
    
    //clock
    always
        #5 clk = !clk;
      
    
    initial begin

        //offsets setup
        x_offset = 16-4;
        y_offset = 16-1;
        curr_frame_bram_offset_sel = 0;

        #20

        //start the module
        resetn = 1;
        go = 1;

    end

endmodule

