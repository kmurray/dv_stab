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

   File       : SVGA_DEFINES.v
   Company    : Xilinx, Inc.
   Created    : 2004/07/22
   Last Update: 2005/01/20
   Copyright  : (c) Xilinx Inc, 2005
-------------------------------------------------------------------------------
   Uses       : 
-------------------------------------------------------------------------------
   Used by    : SPECIAL_SVGA_TIMING_GENERATION.v
-------------------------------------------------------------------------------
  Description: This module defines the video timing parameters for the 
	       video output required.

	       The user must remove the comments in this file to enable the 
	       required video mode AND set the DCM clock generation module 
	       properties to create the required pixel clock for the specified

-------------------------------------------------------------------------------
*/

// DEFINE THE VARIOUS PIPELINE DELAYS

`define ZBT_PIPELINE_DELAY 	0		// not required for XUP-V2Pro
`define ZBT_INTERFACE_DELAY  	0	// not required for XUP-V2Pro
`define CHARACTER_DECODE_DELAY  4	// not required for XUP-V2Pro

//  720 X 480 @ 60Hz with a 27MHz pixel clock for NTSC video capture
`define H_ACTIVE		720	// pixels
`define H_FRONT_PORCH	7	// pixels
`define H_SYNCH			62	// pixels
`define H_BACK_PORCH	69	// pixels
`define H_TOTAL		    858	// pixels

`define V_ACTIVE		487	// lines
`define V_FRONT_PORCH	4	// lines
`define V_SYNCH			4	// lines
`define V_BACK_PORCH	30	// lines
`define V_TOTAL			525	// lines


/*
//  640 X 480 @ 60Hz with a 25.175MHz pixel clock
`define H_ACTIVE		640	// pixels
`define H_FRONT_PORCH	16	// pixels
`define H_SYNCH			96	// pixels
`define H_BACK_PORCH	48	// pixels
`define H_TOTAL			800	// pixels

`define V_ACTIVE		480	// lines
`define V_FRONT_PORCH	11	// lines
`define V_SYNCH			2	// lines
`define V_BACK_PORCH	31	// lines
`define V_TOTAL			524	// lines
*/

/*
//  640 X 480 @ 72Hz with a 31.500MHz pixel clock
`define H_ACTIVE		640	// pixels
`define H_FRONT_PORCH	24	// pixels
`define H_SYNCH			40	// pixels
`define H_BACK_PORCH	128	// pixels
`define H_TOTAL			832	// pixels

`define V_ACTIVE		480	// lines
`define V_FRONT_PORCH	9	// lines
`define V_SYNCH			3	// lines
`define V_BACK_PORCH	28	// lines
`define V_TOTAL			520	// lines
*/

/*
//  640 X 480 @ 75Hz with a 31.500MHz pixel clock
`define H_ACTIVE		640	// pixels
`define H_FRONT_PORCH	16	// pixels
`define H_SYNCH			96	// pixels
`define H_BACK_PORCH	48	// pixels
`define H_TOTAL			800	// pixels

`define V_ACTIVE		480	// lines
`define V_FRONT_PORCH	11	// lines
`define V_SYNCH			2	// lines
`define V_BACK_PORCH	32	// lines
`define V_TOTAL			525	// lines
*/

/*
// 640 X 480 @ 85Hz with a 36.000MHz pixel clock
`define H_ACTIVE		640	// pixels
`define H_FRONT_PORCH	32	// pixels
`define H_SYNCH			48	// pixels
`define H_BACK_PORCH	112	// pixels
`define H_TOTAL			832	// pixels

`define V_ACTIVE		480	// lines
`define V_FRONT_PORCH	1	// lines
`define V_SYNCH			3	// lines
`define V_BACK_PORCH	25	// lines
`define V_TOTAL			509	// lines
*/

/*
// 800 X 600 @ 56Hz with a 38.100MHz pixel clock
`define H_ACTIVE		800	// pixels
`define H_FRONT_PORCH	32	// pixels
`define H_SYNCH			128	// pixels
`define H_BACK_PORCH	128	// pixels
`define H_TOTAL			1088// pixels

`define V_ACTIVE		600	// lines
`define V_FRONT_PORCH	1	// lines
`define V_SYNCH			4	// lines
`define V_BACK_PORCH	14	// lines
`define V_TOTAL			619	// lines
*/

/*
// 800 X 600 @ 60Hz with a 40.000MHz pixel clock
`define H_ACTIVE		800	// pixels
`define H_FRONT_PORCH	40	// pixels
`define H_SYNCH			128	// pixels
`define H_BACK_PORCH	88	// pixels
`define H_TOTAL			1056// pixels

`define V_ACTIVE		600	// lines
`define V_FRONT_PORCH	1	// lines
`define V_SYNCH			4	// lines
`define V_BACK_PORCH	23	// lines
`define V_TOTAL			628	// lines
*/

/*
// 800 X 600 @ 72Hz with a 50.000MHz pixel clock
`define H_ACTIVE		800	// pixels
`define H_FRONT_PORCH	56	// pixels
`define H_SYNCH			120	// pixels
`define H_BACK_PORCH	64	// pixels
`define H_TOTAL			1040// pixels

`define V_ACTIVE		600	// lines
`define V_FRONT_PORCH	37	// lines
`define V_SYNCH			6	// lines
`define V_BACK_PORCH	23	// lines
`define V_TOTAL			666	// lines
*/

/*
// 800 X 600 @ 75Hz with a 49.500MHz pixel clock
`define H_ACTIVE		800	// pixels
`define H_FRONT_PORCH	16	// pixels
`define H_SYNCH			80	// pixels
`define H_BACK_PORCH	160	// pixels
`define H_TOTAL			1056// pixels

`define V_ACTIVE		600	// lines
`define V_FRONT_PORCH	1	// lines
`define V_SYNCH			2	// lines
`define V_BACK_PORCH	21	// lines
`define V_TOTAL			624	// lines
*/

/*
// 800 X 600 @ 85Hz with a 56.250MHz pixel clock
`define H_ACTIVE		800	// pixels
`define H_FRONT_PORCH	32	// pixels
`define H_SYNCH			64	// pixels
`define H_BACK_PORCH	152	// pixels
`define H_TOTAL			1048// pixels

`define V_ACTIVE		600	// lines
`define V_FRONT_PORCH	1	// lines
`define V_SYNCH			3	// lines
`define V_BACK_PORCH	27	// lines
`define V_TOTAL			631	// lines
*/

/*
// 1024 X 768 @ 60Hz with a 65.000MHz pixel clock
`define H_ACTIVE		1024// pixels
`define H_FRONT_PORCH	24	// pixels
`define H_SYNCH			136	// pixels
`define H_BACK_PORCH	160	// pixels
`define H_TOTAL			1344// pixels

`define V_ACTIVE		768	// lines
`define V_FRONT_PORCH	3	// lines
`define V_SYNCH			6	// lines
`define V_BACK_PORCH	29	// lines
`define V_TOTAL			806	// lines
*/

/*
// 1024 X 768 @ 70Hz with a 75.000MHz pixel clock
`define H_ACTIVE		1024// pixels
`define H_FRONT_PORCH	24	// pixels
`define H_SYNCH			136	// pixels
`define H_BACK_PORCH	144	// pixels
`define H_TOTAL			1328// pixels

`define V_ACTIVE		768	// lines
`define V_FRONT_PORCH	3	// lines
`define V_SYNCH			6	// lines
`define V_BACK_PORCH	29	// lines
`define V_TOTAL			806	// lines
*/

/*
// 1024 X 768 @ 75Hz with a 78.750MHz pixel clock
`define H_ACTIVE		1024// pixels
`define H_FRONT_PORCH	16	// pixels
`define H_SYNCH			96	// pixels
`define H_BACK_PORCH	176	// pixels
`define H_TOTAL			1312// pixels

`define V_ACTIVE		768	// lines
`define V_FRONT_PORCH	1	// lines
`define V_SYNCH			3	// lines
`define V_BACK_PORCH	28	// lines
`define V_TOTAL			800	// lines
*/

/*
// 1024 X 768 @ 85Hz with a 94.500MHz pixel clock
`define H_ACTIVE		1024// pixels
`define H_FRONT_PORCH	48	// pixels
`define H_SYNCH			96	// pixels
`define H_BACK_PORCH	208	// pixels
`define H_TOTAL			1376// pixels

`define V_ACTIVE		768	// lines
`define V_FRONT_PORCH	1	// lines
`define V_SYNCH			3	// lines
`define V_BACK_PORCH	36	// lines
`define V_TOTAL			808	// lines

*/
