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

   File       : YCrCb2RGB.v
   Company    : Xilinx, Inc.
   Created    : 2004/07/22
   Last Update: 2005/01/21
   Copyright  : (c) Xilinx Inc, 2005
-------------------------------------------------------------------------------
   Uses       : 
-------------------------------------------------------------------------------
   Used by    : VIDEO_CAPTURE.v
-------------------------------------------------------------------------------
  Description: This module converts the Y Cr Cb video data into the RGB color space
-------------------------------------------------------------------------------
*/

module YCrCb2RGB ( R, G, B, clk, rst, Y, Cr, Cb );

output [7:0]  R;
output [7:0]  G;
output [7:0]  B;
input clk;
input rst;
input[9:0] Y; 
input[9:0] Cr;
input[9:0] Cb;

wire [7:0] R;
wire [7:0] G;
wire [7:0] B;

reg [20:0] R_int,G_int,B_int,X_int,A_int,B1_int,B2_int,C_int; 
reg [9:0] const1,const2,const3,const4,const5;
reg[9:0] Y_reg, Cr_reg, Cb_reg;
 
//registering constants
always @ (posedge clk)
begin
 const1 = 10'b 0100101010; //1.164 = 01.00101010
 const2 = 10'b 0110011000; //1.596 = 01.10011000
 const3 = 10'b 0011010000; //0.813 = 00.11010000
 const4 = 10'b 0001100100; //0.392 = 00.01100100
 const5 = 10'b 1000000100; //2.017 = 10.00000100
end
/*
always @ (posedge clk or posedge rst)
   if (rst)
      begin
      Y_reg <= 0; Cr_reg <= 0; Cb_reg <= 0;
      end
   else  
      begin
	  Y_reg <= Y; Cr_reg <= Cr; Cb_reg <= Cb;
      end
*/

// restrict the Y to the valid range 64-940
always @ (posedge clk or posedge rst) begin
   if (rst)
      begin
      Y_reg <= 0; 
      end
   else if (Y > 940) begin
	Y_reg <= 940;
      	end
   else if (Y < 64) begin
	Y_reg <= 64;
	end
   else begin
	Y_reg <= Y;
      	end
   end
 
// restrict the Cr to the valid range 64-960
always @ (posedge clk or posedge rst)
   if (rst)
      begin
      Cr_reg <= 0;
      end
   else if (Cr > 960) begin
	Cr_reg <= 960;
	end
   else if (Cr < 64) begin
	Cr_reg <= 64;
	end
   else begin
	Cr_reg <= Cr;
      end
	
// restrict the Cb to the valid range 64-960
always @ (posedge clk or posedge rst)
   if (rst)
      begin
       Cb_reg <= 0;
      end
   else if (Cb > 960) begin
	Cb_reg <= 960;
	end
   else if (Cb < 64) begin
	Cb_reg <= 64;
	end
   else begin
	Cb_reg <= Cb;
      end

always @ (posedge clk or posedge rst)
   if (rst)
      begin
       A_int <= 0; B1_int <= 0; B2_int <= 0; C_int <= 0; X_int <= 0;
      end
   else  
     begin
     X_int <= (const1 * (Y_reg - 'd64)) ;
     A_int <= (const2 * (Cr_reg - 'd512));
     B1_int <= (const3 * (Cr_reg - 'd512));
     B2_int <= (const4 * (Cb_reg - 'd512));
     C_int <= (const5 * (Cb_reg - 'd512));
     end

always @ (posedge clk or posedge rst)
   if (rst)
      begin
       R_int <= 0; G_int <= 0; B_int <= 0;
      end
   else  
     begin
     R_int <= X_int + A_int;  
     G_int <= X_int - B1_int - B2_int; 
     B_int <= X_int + C_int; 
     end
	 


/* limit output to 0 - 4095, <0 equals o and >4095 equals 4095 */
assign R = (R_int[20]) ? 0 : (R_int[19:18] == 2'b0) ? R_int[17:10] : 8'b11111111;
assign G = (G_int[20]) ? 0 : (G_int[19:18] == 2'b0) ? G_int[17:10] : 8'b11111111;
assign B = (B_int[20]) ? 0 : (B_int[19:18] == 2'b0) ? B_int[17:10] : 8'b11111111;
endmodule




