//-----------------------------------------------------------------
// lf_decode.v
//
// CCIR656 line/field identification module
//
//
//
//                  Author: Gregg C. Hawkes
//                  Senior Staff Applications Engineer
//
//                  Video Applications
//                  Advanced Products Division
//                  Xilinx, Inc.
//
//                  Copyright (c) 1999 Xilinx, Inc.
//                  All rights reserved
//
//                  Date:   Nov. 3, 2000
//                  For:    Video Demo Board
//
//                  RESTRICTED RIGHTS LEGEND
//
//      This software has not been published by the author, and 
//      has been disclosed to others for the purpose of enhancing 
//      and promoting design productivity in Xilinx products.
//
//      Therefore use, duplication or disclosure, now and in the 
//      future should give consideration to the productivity 
//      enhancements afforded the user of this code by the author's 
//      efforts.  Thank you for using our products !
//
// Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY 
//              WHATSOEVER AND XILINX SPECIFICALLY DISCLAIMS ANY 
//              IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
//              A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
//
//
// 
// Revision:
//          Nov. 3, 2000     Creation
//          July 1, 2001     Added pixel padding (helps 422to444)
//          Nov. 7, 2000     Clean up 
//
//
// Other modules instanced in this design:
//
//          None.

//
// BRIEF DESCRIPTION
/*

The video standard ITU-R BT.656 imbeds all video field and line timing
by using non-video related data values. This data, when decoded,
provides downstream designs all of the timing information related to the
video stream.

//
// DETAILED DESCRIPTION:
//


The reserved 8 bit values of 00h and FFh (consumer format) or 10 bits
values of 000 and 3FFh (studio format) are used to signal what is known
as a TRS - Timing Reference Symbol.  The TRS consists of the sequence FF


a special word XY that
resides in either the 8 bit consumer field or the upper 8 bits of the 10
bit studio field (the 2 lsbs undefined). 

This word, when decoded, combined with various counts, such as line 
count, can completely specify NTSC or PAL timing.

This module decodes this information and supplies timing control signals
to the video controller, frame buffer, and DAC.

The video standard ITU-R BT.656, defines the following:

   1. color space
   2. the number of samples
   3. where the samples are located in an image, also known
      as the sampling format
   4. how the pixels are stored in the frame buffer. 

The color space definition is known as YCbCr. YCbCr is a scaled and
offset version of the YUV color space. The 4:2:2 format has for every
horizontal Y (Luminance) sample a single Chrominance sample (either 
Cr or Cb). Cb and Cr are sampled less because the eye is more sensitive 
to luminance than chrominance, so storing pixels this way is more frame 
buffer efficient. 

Each sample is 8 bits (for consumer applications)and 10 bits for 
commercial studio quality. The Virtex II video board supports 10 bits
where the two extra bits are considered fractional.  The range of
values for each are:

   Y  = 16 to 235 or 040h to 3ACh (i.e. 220 values)
   Cr = 16 to 240 or 040h to 3C0h (i.e. 225 values)
   Cb = 16 to 240 or 040h to 3C0h (i.e. 225 values)
   note: for Cr and Cb 128 is "zero"

The video data words are conveyed as 27 million, 10 bit words, in the
following order: 

             1    2   3    4   5    6   7
             Cb0, Y0, Cr0, Y1, Cb2, Y2, Cr2

Field and frame timing is actually imbedded in the data stream by
reserving the values of 00h and FFh for field/line ID. The pattern FF 00
00 is used as a field ID and appears in every line. If a field ID is
detected then the next 8 bit pixel has different meaning depending on
it's value. I'll call the value XY. The 8 bit data stream is sampled on
the rising edge of the 27 MHz clock.

The terms SAV and EAV mean "start of active video" and "end of active
video", repectively. SAV is marked with a field ID followed by bit 4 in
the XY word low. Active pixels then follow. EAV is also marked with a
field ID where bit 4 in the XY word is high. Horizontal blanking
follows.

Field number and Field blanking are also conveyed by XY, following a
field ID. The "F bit" or bit position 6 and the "V bit" or bit position
5 are decoded as follows:

F = 0, denotes field 1, odd
F = 1, denotes field 2, even
V = 0, denotes no field blanking
V = 1, denotes field blanking

So a simple statement of this modules function is, for each line, find
the field ID pattern FF 00 00 XY then look at XY. XY will tell us what
field we are in, whether or not field blanking is active, and if XY
denotes a SAV, then we know we are at pixel 0.  Deciding which format
is being displayed is done by counting SAVs between field blanking.

To identify the format as NTSC (485 active lines or 525 total lines) or
as PAL (576 active lines or 625 total) you can look for the V bit to
signal active lines are starting (V was a 1, then transitioned to a 0)
and count SAVs until the V bit goes high or active lines have stopped.
This number is compared to the format line counts and NTSC or PAL flag
is set.

Design Information
------------------
xc2v1000-ff896-6

Slices       64  0%
FFs          57  1%
LUTs         76  1%
IO           14  3%
gates      1000

*/
//
//-----------------------------------------------------------------


`timescale 1ns / 1ns


module lf_decode (
rst,           // Reset and Clock input
clk,           // 27Mhz for SDTV

YCrCb_in,      // data from the input video stream

YCrCb_out,     // data delayed by pipe length

NTSC_out,      // high = NTSC format detected

Fo,            // high = field one (even)
Vo,            // high = vertical blank
Ho            // low = active video
);


input rst; 
input clk;
input [9:0] YCrCb_in;

output [9:0] YCrCb_out;
output NTSC_out;
output Fo;
output Vo;
output Ho;


//-----------------------
// Data type declarations
//-----------------------

reg [9:0] YCrCb_rg1;
reg [9:0] YCrCb_rg2;
reg [9:0] YCrCb_rg3;
reg [9:0] YCrCb_rg4;
reg [9:0] YCrCb_rg5;

wire TRS;

reg [4:0] H_rg;
reg Fo, Vo;
wire Ho;

wire V_rising, V_falling, H_rising;

reg [4:0] format_count;
reg [4:0] format_count_max;

wire NTSC_out;

wire [9:0] YCrCb_out;


//-----------------------------------------------------------------------
//
//  TRS - Timing Reference Symbol = FF0, in succession.
//
//                   all zeros         all zeros            all ones
//                       |                 |                    |
//                       V                 V                    V
assign TRS = ((~|YCrCb_rg2[9:2]) & (~|YCrCb_rg3[9:2]) & (&YCrCb_rg4[9:2]));

always @ (posedge clk) begin
  if (rst) begin
    YCrCb_rg1 <= 0;
    YCrCb_rg2 <= 0; 
    YCrCb_rg3 <= 0; 
    YCrCb_rg4 <= 0; 
    YCrCb_rg5 <= 0;
  end
  else begin
    YCrCb_rg1 <= YCrCb_in;    // 1 clock delay
    YCrCb_rg2 <= YCrCb_rg1;   // 2 clock delay
    YCrCb_rg3 <= YCrCb_rg2;   // 3 clock delay
    YCrCb_rg4 <= YCrCb_rg3;   // 4 clock delay
    YCrCb_rg5 <= YCrCb_rg4;   // 5 clock delay
  end
end

assign YCrCb_out = YCrCb_rg5;


//-----------------------------------------------------------------------
//
//
//
always @ (posedge clk) begin
  if (rst) begin Fo <= 0; Vo <= 0; H_rg <= 0; end
  else if (TRS) begin
    Fo <= YCrCb_rg1[8];
    Vo <= YCrCb_rg1[7];
    H_rg[4:0] <= {H_rg[4:1], YCrCb_rg1[6]};
  end
  else begin
    Fo <= Fo;
    Vo <= Vo;
    H_rg[4:0] <= {H_rg[3:0], H_rg[0]};
  end
end

assign Ho = H_rg[0] | H_rg[4];

assign H_rising = H_rg[0] & ~H_rg[1];
assign V_rising =  (TRS &  YCrCb_rg1[7]) & ~Vo;
assign V_falling = (TRS & ~YCrCb_rg1[7]) &  Vo;


//-----------------------------------------------------------------------
//
// Format detection counter
/*
This counter has really only one purpose. To continuously detect the
video format expressed by counting video lines from V_rising to
V_falling (i.e. during the blanking period) and storing the maximum
count reached. NTSC has 19 lines during this period and PAL has 24.
*/
always @ (posedge rst or posedge clk) begin
  if (rst) begin format_count <= 0; format_count_max <= 19; end
  else if (V_rising & H_rising) begin
    format_count <= 1;
    format_count_max <= format_count_max;
  end
  else if (V_falling & H_rising) begin
    format_count <= 1;
    format_count_max <= format_count;
  end
  else if (~V_rising & H_rising) begin
    format_count <= format_count + 1;
    format_count_max <= format_count_max;
  end
  else begin
    format_count <= format_count;
    format_count_max <= format_count_max;
  end
end

assign NTSC_out = (format_count_max == 19);


endmodule


