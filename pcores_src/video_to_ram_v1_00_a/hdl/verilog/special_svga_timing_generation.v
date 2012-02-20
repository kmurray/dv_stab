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

   File       : SPECIAL_SVGA_TIMING_GENERATION.v
   Company    : Xilinx, Inc.
   Created    : 2004/07/22
   Last Update: 2005/01/20
   Copyright  : (c) Xilinx Inc, 2005
-------------------------------------------------------------------------------
    Uses       : SVGA_DEFINES.v
-------------------------------------------------------------------------------
   Used by    : VIDEO_CAPTURE.v
-------------------------------------------------------------------------------
   Description: This module creates the timing and control signals for the 
		VGA output. The module provides character-mapped addressing
	 	in addition to the control signals for the DAC and the VGA output connector. 
		The design supports screen resolutions up to 1024 x 768. The user will have
	 	to add the charcater memory RAM and the character generator ROM and create
	 	the required pixel clock.

		The video mode used is defined in the svga_defines.v file.

Revised Jan 20 2005 by Rick Ballantyne

For use in the video capture design the vertical line counter is reset to be 
inside the vertical blanking interval. This is because the "FIELD" bit in the decoded
601/656 digital video data stream transitions on line 4 and active video starts on line 20.
This design assumes that the first active pixel is pixel 0 of line 0 so the
counters must be reset properly to account for this offset.

	Conventions:
		All external port signals are UPPER CASE.
		All internal signals are LOWER CASE and are active HIGH.


-----------------------------------------------------------------------------
*/


//`include "SVGA_DEFINES.v"

// DEFINE THE VARIOUS PIPELINE DELAYS

`define ZBT_PIPELINE_DELAY      0               // not required for XUP-V2Pro
`define ZBT_INTERFACE_DELAY     0       // not required for XUP-V2Pro
`define CHARACTER_DECODE_DELAY  4       // not required for XUP-V2Pro

//  720 X 480 @ 60Hz with a 27MHz pixel clock for NTSC video capture
`define H_ACTIVE                720     // pixels
`define H_FRONT_PORCH   7       // pixels
`define H_SYNCH                 62      // pixels
`define H_BACK_PORCH    69      // pixels
`define H_TOTAL             858 // pixels

`define V_ACTIVE                487     // lines
`define V_FRONT_PORCH   4       // lines
`define V_SYNCH                 4       // lines
`define V_BACK_PORCH    30      // lines
`define V_TOTAL                 525     // lines


module SPECIAL_SVGA_TIMING_GENERATION (
pixel_clock,
reset,
h_synch_delay,
v_synch_delay,
comp_synch,
blank,
char_line_count,
char_address,
char_pixel,
pixel_count,
line_count_out
);

input 		pixel_clock;		// pixel clock 
input 		reset;			// reset
output 		h_synch_delay;		// horizontal synch for VGA connector
output 		v_synch_delay;		// vertical synch for VGA connector
output 		comp_synch;		// composite synch for DAC
output		blank;			// composite blanking 
output 	[2:0]	char_line_count;	// line counter for char gen rom 
output 	[13:0]	char_address;		// character mode address			
output 	[2:0]	char_pixel;		// pixel position within the character
output 	[10:0]	pixel_count;		// counts the pixels in a line
output [9:0] line_count_out; 

reg	[9:0]	line_count;		// counts the display lines
reg 	[10:0]	pixel_count;		// counts the pixels in a line	
reg		h_synch;		// horizontal synch
reg		v_synch;		// vertical synch
reg		h_synch_delay;		// h_synch delayed 2 clocks to line up with DAC pipeline
reg		v_synch_delay;		// v_synch delayed 2 clocks to line up with DAC pipeline
reg		h_synch_delay0;		// h_synch delayed 1 clock
reg		v_synch_delay0;		// v_synch delayed 1 clock

reg		h_c_synch;		// horizontal component of comp synch
reg		v_c_synch;		// vertical component of comp synch
reg		comp_synch;		// composite synch for DAC
reg		h_blank;		// horizontal blanking
reg		v_blank;		// vertical blanking
reg		blank;			// composite blanking
	

reg 	[2:0] 	char_line_count;	// identifies the line number within a character block
reg 	[16:0] 	char_count;		// a counter used to define the character block number
reg 	[16:0] 	line_start_address;	// register to store the starting character number for a line of chars
reg 		reset_char_count; 	// flag to reset the character count during VBI
reg 		hold_char_count;	// flag to hold the character count during HBI
reg 	[13:0] 	char_address;		// the actual character address
reg 	[2:0]   char_pixel;		// pixel position within the character

assign line_count_out = line_count; 


// CREATE THE HORIZONTAL LINE PIXEL COUNTER
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin					// on reset set pixel counter to 0
			pixel_count <= 11'h000;
		end

	else if (pixel_count == (`H_TOTAL - 1))
 		begin					// last pixel in the line
			pixel_count <= 11'h000;		// reset pixel counter
		end

	else 	begin
			pixel_count <= pixel_count +1;		
		end
	end

// CREATE THE HORIZONTAL SYNCH PULSE
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin					// on reset
			h_synch <= 1'b0;		// remove h_synch
		end

	else if (pixel_count == (`H_ACTIVE + `H_FRONT_PORCH -1)) 
	  	begin					// start of h_synch
			h_synch <= 1'b1;
		end

	else if (pixel_count == (`H_TOTAL - `H_BACK_PORCH -1))
 	 	begin					// end of h_synch
			h_synch <= 1'b0;
		end
	end


// CREATE THE VERTICAL FRAME LINE COUNTER
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin					// on reset set line counter to 0
//			line_count <= 10'h000;
			line_count <= (`V_TOTAL -33);
			end

	else if ((line_count == (`V_TOTAL - 1))&& (pixel_count == (`H_TOTAL - 1)))
		begin					// last pixel in last line of frame 
			line_count <= 10'h000;		// reset line counter
		end

	else if ((pixel_count == (`H_TOTAL - 1)))
		begin					// last pixel but not last line
			line_count <= line_count + 1;	// increment line counter
		end
	end

// CREATE THE VERTICAL SYNCH PULSE
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin					// on reset
			v_synch = 1'b0;			// remove v_synch
		end

	else if ((line_count == (`V_ACTIVE + `V_FRONT_PORCH -1) &&
		   (pixel_count == `H_TOTAL - 1))) 
	  	begin					// start of v_synch
			v_synch = 1'b1;
		end
	
	else if ((line_count == (`V_TOTAL - `V_BACK_PORCH - 1))	&&
		   (pixel_count == (`H_TOTAL - 1)))
	 	begin					// end of v_synch
			v_synch = 1'b0;
		end
	end

// ADD TWO PIPELINE DELAYS TO THE SYNCHs COMPENSATE FOR THE DAC PIPELINE DELAY
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin					
			h_synch_delay0 <= 1'b0;
			v_synch_delay0 <= 1'b0;
			h_synch_delay  <= 1'b0;
			v_synch_delay  <= 1'b0;

		end
	else 
		begin
			h_synch_delay0 <= h_synch;
			v_synch_delay0 <= v_synch;
			h_synch_delay  <= h_synch_delay0;
			v_synch_delay  <= v_synch_delay0;
		end
	end



// CREATE THE HORIZONTAL BLANKING SIGNAL
// the "-2" is used instead of "-1" because of the extra register delay
// for the composite blanking signal 
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin					// on reset
			h_blank <= 1'b0;		// remove the h_blank
		end

	else if (pixel_count == (`H_ACTIVE -2)) 
	  	begin					// start of HBI
			h_blank <= 1'b1;
		end
	
	else if (pixel_count == (`H_TOTAL -2))
 	 	begin					// end of HBI
			h_blank <= 1'b0;
		end
	end


// CREATE THE VERTICAL BLANKING SIGNAL
// the "-2" is used instead of "-1"  in the horizontal factor because of the extra
// register delay for the composite blanking signal 
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin						// on reset
//			v_blank <= 1'b0;			// remove v_blank
			v_blank <= 1'b1;			// the FIELD bit that resets the counters transitions during V_BLANK
		end

	else if ((line_count == (`V_ACTIVE - 1) &&
		   (pixel_count == `H_TOTAL - 2))) 
	  	begin						// start of VBI
			v_blank <= 1'b1;
		end
	
	else if ((line_count == (`V_TOTAL - 1)) &&
		   (pixel_count == (`H_TOTAL - 2)))
	 	begin						// end of VBI
			v_blank <= 1'b0;
		end
	end


// CREATE THE COMPOSITE BANKING SIGNAL
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		begin						// on reset
			blank <= 1'b0;				// remove blank
		end

	else if (h_blank || v_blank)				// blank during HBI or VBI
		 begin
			blank <= 1'b1;
		end
	else begin
			blank <= 1'b0;				// active video do not blank
		end
	end
		
// CREATE THE HORIZONTAL COMPONENT OF COMP SYNCH
// the "-2" is used instead of "-1" because of the extra register delay
// for the composite synch
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin						// on reset
			h_c_synch <= 1'b0;			// remove h_c_synch
		end

	else if (pixel_count == (`H_ACTIVE + `H_FRONT_PORCH -2)) 
	  	begin						// start of h_c_synch
			h_c_synch <= 1'b1;
		end


	else if (pixel_count == (`H_TOTAL - `H_BACK_PORCH -2))
 	 	begin						// end of h_c_synch
			h_c_synch <= 1'b0;
		end
	end

// CREATE THE VERTICAL COMPONENT OF COMP SYNCH 
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin						// on reset
			v_c_synch <= 1'b0;			// remove v_c_synch
		end

	else if ((line_count == (`V_ACTIVE + `V_FRONT_PORCH - 1) &&
		   (pixel_count == `H_TOTAL - 2))) 
	  	begin						// start of v_c_synch
			v_c_synch <= 1'b1;
		end
	
	else if ((line_count == (`V_TOTAL - `V_BACK_PORCH - 1))	&&
		   (pixel_count == (`H_TOTAL - 2)))
	 	begin						// end of v_c_synch
			v_c_synch <= 1'b0;
		end
	end

// CREATE THE COMPOSITE SYNCH SIGNAL
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin						// on reset
			comp_synch <= 1'b0;			// remove comp_synch
		end
	else begin
		comp_synch <= (v_c_synch ^ h_c_synch);
		end
	end


/* 
   CREATE THE CHARACTER COUNTER.
   CHARACTERS ARE DEFINED WITHIN AN 8 x 8 PIXEL BLOCK.

	A 640  x 480 video mode will display 80  characters on 60 lines.
	A 800  x 600 video mode will display 100 characters on 75 lines.
	A 1024 x 768 video mode will display 128 characters on 96 lines.

	"char_line_count" identifies the row in the 8 x 8 block.
	"char_pixel" identifies the column in the 8 x 8 block.
	"char_address" identifies the character in the total diaplay "0"
	is the top left character.
*/


// CREATE THE VERTICAL FRAME LINE COUNTER
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin							// on reset set line counter to 0
			char_line_count <= 3'b000;
		end

	else if  ((line_count == (`V_TOTAL - 1)) && (pixel_count == (`H_TOTAL - 1)-`CHARACTER_DECODE_DELAY)) 
		begin							
			char_line_count <= 3'b000;			// reset line counter
		end

	else if (pixel_count == (`H_TOTAL - 1)-`CHARACTER_DECODE_DELAY)
		begin							
			char_line_count <= line_count + 1;		// increment line counter
		end
	end

always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		begin
			char_count <= 17'h00000;
			line_start_address <= 17'h00000;
		end
	else if (reset_char_count)					// reset the char count during the VBI
		begin
			char_count <= 17'h00000;
			line_start_address <= 17'h00000;
		end
	else if (!hold_char_count)
			begin
				char_count <= char_count +1;
				line_start_address <= line_start_address;
			end
	else 		// hold the character counter during the HBI
 		begin
			if (char_line_count == 3'b111)				// last line in the character block 
				begin
					char_count <= char_count;
					line_start_address <= char_count; 	// update the line start address
				end
			else							// not the last line in the char block
				begin
					char_count <= line_start_address;	// restore the line start address
					line_start_address <= line_start_address;
				end
			end
		end
	
always @ (char_count) begin
	char_address[13:0] = char_count[16:3];
	end

// char_pixel defines the pixel within the character line
always @ (posedge pixel_clock or posedge reset) begin
	if (reset) begin
		char_pixel <= 3'b101;		// reset to 5 so that the first character data can be latched
		end
	else if (pixel_count == ((`H_TOTAL - 1)-`CHARACTER_DECODE_DELAY))begin
		char_pixel <= 3'b101;		// reset to 5 so that the first character data can be latched
		end
	else begin
		char_pixel <= char_pixel +1;
		end
	end


// CREATE THE CONTROL SIGNALS FOR THE CHARACTER ADDRESS COUNTER
/* 	The HOLD and RESET signals are advanced from the beginning and end
	of HBI and VBI to compensate for the internal character generation
	pipeline.
*/
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		begin
			reset_char_count <= 1'b0;
		end
	else if (line_count == (`V_ACTIVE - 1) &&
		   pixel_count == ((`H_ACTIVE - 1) - `CHARACTER_DECODE_DELAY))
	  	begin								// start of VBI
				reset_char_count <= 1'b1;
		end
	
	else if (line_count == (`V_TOTAL - 1) &&
		   pixel_count == ((`H_TOTAL - 1) - `CHARACTER_DECODE_DELAY))
	 	begin								// end of VBI					
			reset_char_count <= 1'b0;
		end
	end


always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
		begin
			hold_char_count <= 1'b0;
		end
	else if (pixel_count == ((`H_ACTIVE -1) - `CHARACTER_DECODE_DELAY)) 
	  	begin								// start of HBI
 			hold_char_count <= 1'b1;
		end
 	else if (pixel_count == ((`H_TOTAL -1) - `CHARACTER_DECODE_DELAY ))
	 	begin								// end of HBI
			hold_char_count <= 1'b0;
		end
	end


endmodule //SPECIAL_SVGA_TIMING_GENERATION



