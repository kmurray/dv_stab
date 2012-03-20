`timescale 1ns / 1ps

module pop_count_tb;

	// Inputs
	reg i_clk;
	reg i_reset;
	reg [127:0] i_data;

	// Outputs
	wire [127:0] o_sum;

	// Instantiate the Unit Under Test (UUT)
	pop_count uut (
		.i_clk(i_clk), 
		.i_reset(i_reset), 
		.i_data(i_data), 
		.o_sum(o_sum)
	);

	initial begin
		// Initialize Inputs
		i_clk = 0;
		i_reset = 0;
		i_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        #i_data = 128'h55555555555555555555555555555555; //binary: 0101... => 64 ones
	end


    always
    begin
        #5 i_clk = !i_clk;
        #10 i_done = 1;
        #11 i_done = 0;
    end
      
endmodule

