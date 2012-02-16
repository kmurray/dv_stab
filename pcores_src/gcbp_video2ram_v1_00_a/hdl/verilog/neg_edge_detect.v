//     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
//     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR
//     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION
//     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION
//     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS
//     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
//     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
//     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
//     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
//     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
//     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//     FOR A PARTICULAR PURPOSE.
//
//     (c) Copyright 2005 Xilinx, Inc.
//     All rights reserved.
//
/*
-------------------------------------------------------------------------------
   Title      : VIDEO CAPTURE FROM THE VDEC1 DAUGHTER BOARD FOR THE XUP-V2Pro
   Project    : XUP-V2Pro 
-------------------------------------------------------------------------------

   File       : NEG_EDGE_DETECT.v
   Company    : Xilinx, Inc.
   Created    : 2004/07/22
   Last Update: 2005/01/20
   Copyright  : (c) Xilinx Inc, 2005
-------------------------------------------------------------------------------
   Uses       : 
-------------------------------------------------------------------------------
   Used by    : VIDEO_CAPTURE.v
-------------------------------------------------------------------------------
  Description: This module creates a one clock wide pulse on the negative 
  			   transition of the "data_in" signal. This is used to reset
			   the vertical line counter in the SPECIAL_SVGA_TIMING_GENERATION
		       module on the transition of the "FIELD" bit in the timing reference code.


-------------------------------------------------------------------------------
*/

module NEG_EDGE_DETECT
(
clk,
data_in,
reset,
one_shot_out
);

input clk, data_in, reset;
output one_shot_out;	// signal will be high for one clock cycle after the input transitions high to low

reg [1:0]	PRESENT_STATE;
reg [1:0]	NEXT_STATE;

wire one_shot_out;

parameter
START 	= 2'b00,
LOW		= 2'b01,
HIGH	= 2'b10;


always @ (posedge clk or posedge reset) begin
	if (reset) begin
	PRESENT_STATE <= START;
	end
	else begin
    PRESENT_STATE <= NEXT_STATE;
    end
	end

always @ (PRESENT_STATE or data_in) begin
    case (PRESENT_STATE)
START:begin
	if (!data_in) begin
    	NEXT_STATE = LOW;
    	end
	else begin
	  	NEXT_STATE = START;
    	end
	end

LOW:begin
    	NEXT_STATE = HIGH;
    	end

HIGH:begin
	if (!data_in) begin
    	NEXT_STATE = HIGH;
    	end
	else begin
	  	NEXT_STATE = START;
    	end
	end
	default:begin
    NEXT_STATE = START;
    end
endcase
end

assign one_shot_out = PRESENT_STATE[0];
endmodule



