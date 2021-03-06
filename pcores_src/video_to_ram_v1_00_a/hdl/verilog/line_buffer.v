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

   File       : LINE_BUFFER.v
   Company    : Xilinx, Inc.
   Created    : 2004/07/22
   Last Update: 2005/01/20
   Copyright  : (c) Xilinx Inc, 2005
-------------------------------------------------------------------------------
   Uses       : 
-------------------------------------------------------------------------------
   Used by    : VIDEO_CAPTURE.v
-------------------------------------------------------------------------------
  Description: This module defines the video line buffer RAM with a seperate
  			BRAM for each of the RGB or YCrCb data values. PortA is the write port
			with the data coming from the 601/656 video pipeline and port B is
			the read port with the data going to they display.

-------------------------------------------------------------------------------
*/

module LINE_BUFFER
(
read_clk,
read_address,
read_enable,
read_red_data,
read_green_data,
read_blue_data,
read_luma_data,

write_clk,
write_address,
write_enable,
write_red_data,
write_green_data,
write_blue_data,
write_luma_data
);

input 			read_clk;
input [10:0] 	read_address;
input 			read_enable;
output [7:0] 	read_red_data;
output [7:0] 	read_green_data;
output [7:0] 	read_blue_data;
output [7:0] 	read_luma_data;

input write_clk;
input [10:0] 	write_address;
input 			write_enable;
input [7:0] 	write_red_data;
input [7:0] 	write_green_data;
input [7:0] 	write_blue_data;
input [7:0] 	write_luma_data;

// instantiate the BRAMS
RAMB16_S9_S9 RED_DATA_RAM(
.DOA(),
.DOPA(), 
.ADDRA(write_address[10:0]), 
.CLKA(write_clk), 
.DIA(write_red_data[7:0]), 
.DIPA(1'b0),
.ENA(write_enable), 
.WEA(1'b1),
.SSRA(1'b0),

.DOB(read_red_data[7:0]), 
.DOPB(), 
.ADDRB(read_address[10:0]), 
.CLKB(read_clk), 
.DIB(8'h00), 
.DIPB(1'b0), 
.ENB(read_enable), 
.SSRB(1'b0), 
.WEB(1'b0)
);

RAMB16_S9_S9 GREEN_DATA_RAM(
.DOA(),
.DOPA(), 
.ADDRA(write_address[10:0]), 
.CLKA(write_clk), 
.DIA(write_green_data[7:0]), 
.DIPA(1'b0),
.ENA(write_enable), 
.WEA(1'b1),
.SSRA(1'b0),

.DOB(read_green_data[7:0]), 
.DOPB(), 
.ADDRB(read_address[10:0]), 
.CLKB(read_clk), 
.DIB(8'h00), 
.DIPB(1'b0), 
.ENB(read_enable), 
.SSRB(1'b0), 
.WEB(1'b0)
);

RAMB16_S9_S9 BLUE_DATA_RAM(
.DOA(),
.DOPA(), 
.ADDRA(write_address[10:0]), 
.CLKA(write_clk), 
.DIA(write_blue_data[7:0]), 
.DIPA(1'b0),
.ENA(write_enable), 
.WEA(1'b1),
.SSRA(1'b0),

.DOB(read_blue_data[7:0]), 
.DOPB(), 
.ADDRB(read_address[10:0]), 
.CLKB(read_clk), 
.DIB(8'h00), 
.DIPB(1'b0), 
.ENB(read_enable), 
.SSRB(1'b0), 
.WEB(1'b0)
);

//Store the luma data aswell
RAMB16_S9_S9 LUMA_DATA_RAM(
.DOA(),
.DOPA(), 
.ADDRA(write_address[10:0]), 
.CLKA(write_clk), 
.DIA(write_luma_data[7:0]), 
.DIPA(1'b0),
.ENA(write_enable), 
.WEA(1'b1),
.SSRA(1'b0),

.DOB(read_luma_data[7:0]), 
.DOPB(), 
.ADDRB(read_address[10:0]), 
.CLKB(read_clk), 
.DIB(8'h00), 
.DIPB(1'b0), 
.ENB(read_enable), 
.SSRB(1'b0), 
.WEB(1'b0)
);
endmodule


module RAMB16_S9_S9 (DOA, DOB, DOPA, DOPB, ADDRA, ADDRB, CLKA, CLKB, DIA, DIB, DIPA, DIPB, ENA, ENB, SSRA, SSRB, WEA, WEB) /* synthesis syn_black_box */ ;

    parameter INIT_A = 9'h0;
    parameter INIT_B = 9'h0;
    parameter SRVAL_A = 9'h0;
    parameter SRVAL_B = 9'h0;
    parameter WRITE_MODE_A = "WRITE_FIRST";
    parameter WRITE_MODE_B = "WRITE_FIRST";
    parameter INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;

    output [7:0] DOA;
    output [0:0] DOPA;
    input [10:0] ADDRA;
    input [7:0] DIA;
    input [0:0] DIPA;
    input ENA, CLKA, WEA, SSRA;
    output [7:0] DOB;
    output [0:0] DOPB;
    input [10:0] ADDRB;
    input [7:0] DIB;
    input [0:0] DIPB;
    input ENB, CLKB, WEB, SSRB;
endmodule
