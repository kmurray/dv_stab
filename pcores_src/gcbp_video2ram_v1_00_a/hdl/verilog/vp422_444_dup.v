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

   File       : p422_444_dup.v
   Company    : Xilinx, Inc.
   Created    : 2004/07/22
   Last Update: 2005/01/20
   Copyright  : (c) Xilinx Inc, 2005


-------------------------------------------------------------------------------
   Uses       : 
-------------------------------------------------------------------------------
   Used by    : VIDEO_CAPTURE.v

//-----------------------------------------------------------------

BRIEF DESCRIPTION

The process of 4:2:2 to 4:4:4 is simply creating the missing Cr and Cb
components. This version accomplishes this task by merely duplicating
the Cr and Cb information.

DETAILED DESCRIPTION

The video standard ITU-R BT.601 was introduced as the need for
transporting digital component video between countries and standards
increased. The analog component R'G'B' can be sampled in a very regular
way and converted from 4:4:4 to the digital 4:2:2 format, essentially
cutting in half the number of different components, Cr and Cb. 

The digital data is efficiently stored or transmitted to a destination
that reverses the process, i.e. converts back to 4:4:4 format, and
produces analog YUV or R'G'B' for display.


*/

module vp422_444_dup (
rst,
clk,
ycrcb_in,
ntsc_in, 
fi,
vi, 
hi,
ceo,
ntsc_out_o,
fo,  
vo,  
ho, 
y_out, 
cr_out, 
cb_out 
);

input		rst; 		//Reset and Clock input
input		clk;		//27Mhz for SDTV
input [9:0] ycrcb_in;	//data from the line field decoder
input		ntsc_in;	//from Line field decoder
input		fi;			//"FIELD" bit from Line field decoder 
input		vi;			//"VERTICAL BLANK" bit from Line field decoder 
input		hi;			//"HORIZONTAL BLANK" bit from Line field decoder
output		ceo;		//output enable valid out put 1/2 ycrcb_in rate
output		ntsc_out_o;	//high = NTSC format detected delayed to match 422-444 pipe length 
output  	fo;			//high = field one (even) delayed to match 422-444 pipe length 
output  	vo;			//high = vertical blank delayed to match 422-444 pipe length 
output  	ho;			//low = active video delayed to match 422-444 pipe length 
output [9:0]y_out;		// 4:4:4 luma data 
output [9:0]cr_out; 	// 4:4:4 chroma data
output [9:0]cb_out; 	// 4:4:4 chroma data 

reg [1:0] state_cnt;

reg [9:0] ycrcb_in_reg;

reg [4:0] pipe_fo;
reg [4:0] pipe_ntsc;
reg [4:0] pipe_vo;
reg [4:0] pipe_ho;

reg [9:0] Y_rg1;			// luma pipe line register
reg [9:0] Y_rg2;
reg [9:0] Y_rg3;
reg [9:0] Y_rg4;


reg [9:0] chroma_red_rg1;	//Cr pipe line register
reg [9:0] chroma_red_rg2;
reg [9:0] chroma_red_rg3;
reg [9:0] chroma_red_rg4;


reg [9:0] chroma_blue_rg1;	//Cb pipe line register
reg [9:0] chroma_blue_rg2;
reg [9:0] chroma_blue_rg3;
reg [9:0] chroma_blue_rg4;
reg [9:0] chroma_blue_rg5;

wire h_falling;
wire blanking;
reg vi_reg;
reg hi_reg;
reg ntsc_reg;
reg fi_reg;
wire ena_luma_reg;
wire ena_chroma_red_reg;
wire ena_chroma_blue_reg;

assign h_falling 			=  (hi_reg & ~hi);
assign ceo 					=  ((~pipe_ho[0] & ~pipe_vo[0]) & ena_luma_reg);
assign ena_luma_reg 		=  ((state_cnt[0] & ~state_cnt[1]) | (state_cnt[1] & state_cnt[0]));//counts 1, 3
assign ena_chroma_blue_reg 	=  (~state_cnt[0] & ~state_cnt[1]);                                 //count 0
assign ena_chroma_red_reg  	=  (~state_cnt[0] &  state_cnt[1]);                                 //count 2

assign y_out[9:0]  = Y_rg4[9:0];
assign cr_out[9:0] = chroma_red_rg3[9:0];
assign cb_out[9:0] = chroma_blue_rg5[9:0];

assign vo =  pipe_vo[0];
assign fo =  pipe_fo[0];

assign ho       =  pipe_ho[0];
assign ntsc_out_o =  pipe_ntsc[0];

// create a counter to keep track of the Cb, Y, Cr Y data stream contents
always @ (posedge clk ) begin
  	if (rst | h_falling) begin
      state_cnt <= 2'b00;
	  end
    else begin 
      state_cnt <= state_cnt + 1;
      end
  end 

//register the inputs 
always @ (posedge clk ) begin
  	if (rst) begin 
		  	vi_reg    <=  1'b0;
  	  		hi_reg    <=  1'b0;
      		fi_reg    <=  1'b0;
      		ntsc_reg  <=  1'b0;
      		ycrcb_in_reg  <=  8'h00;
			end
    else begin
      		vi_reg    <= vi;
 	    	hi_reg    <= hi;
      		fi_reg    <= fi;
      		ntsc_reg  <= ntsc_in;
      		ycrcb_in_reg[9:0]  <= ycrcb_in[9:0];
			end
	end 

//pipe line delay F, V, H, NTSC to match delay of 444 dup
always @ (posedge clk) begin 
    pipe_vo[4]    	<= vi_reg;
    pipe_vo[3:0]    <= pipe_vo[4:1]; 
    pipe_fo[4]      <= fi_reg; 
    pipe_fo[3:0]    <= pipe_fo[4:1];  
    pipe_ho[4]      <= hi_reg;
    pipe_ho[3:0]    <= pipe_ho[4:1];
    pipe_ntsc[4]    <= ntsc_reg;
    pipe_ntsc[3:0]  <= pipe_ntsc[4:1];  
  	end

// process the luna data
always @ (posedge clk) begin
    if (ena_luma_reg) begin
     	Y_rg1[9:0] <= ycrcb_in_reg[9:0]; 
   	     end
    else begin
		Y_rg1[9:0] <= Y_rg1[9:0];   
    	end
  	end

always @ (posedge clk) begin
    Y_rg2[9:0] <= Y_rg1[9:0];                 //3 clock delay
    Y_rg3[9:0] <= Y_rg2[9:0]; 
    Y_rg4[9:0] <= Y_rg3[9:0];
  	end 


// process the Cr data
always @ (posedge clk) begin
    if (rst) begin
      chroma_red_rg1[9:0] <= 8'h00;
	  end
    else if (ena_chroma_red_reg) begin
      chroma_red_rg1[9:0] <= ycrcb_in_reg[9:0];
 	  end
    else begin
	  chroma_red_rg1[9:0] <= chroma_red_rg1[9:0];
      end
  end

always @ (posedge clk) begin
     chroma_red_rg2[9:0] <= chroma_red_rg1[9:0];    //3 clock delay
     chroma_red_rg3[9:0] <= chroma_red_rg2[9:0];  
     chroma_red_rg4[9:0] <= chroma_red_rg3[9:0];
	 end


// process the Cb data
always @ (posedge clk) begin
    if (rst) begin
      chroma_blue_rg1[9:0] <= 8'h00;
	  end
    else if (ena_chroma_blue_reg) begin
      chroma_blue_rg1[9:0] <= ycrcb_in_reg[9:0];
	  end
   	else begin
	  chroma_blue_rg1[9:0] <= chroma_blue_rg1[9:0];   
      end
  end

always @ (posedge clk) begin
    chroma_blue_rg2[9:0] <= chroma_blue_rg1[9:0];  //4 clock delay
    chroma_blue_rg3[9:0] <= chroma_blue_rg2[9:0];  
	chroma_blue_rg4[9:0] <= chroma_blue_rg3[9:0];
    chroma_blue_rg5[9:0] <= chroma_blue_rg4[9:0];
	end

endmodule

