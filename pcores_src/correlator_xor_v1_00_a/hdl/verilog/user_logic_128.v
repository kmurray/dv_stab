//----------------------------------------------------------------------------
// user_logic.vhd - module
//----------------------------------------------------------------------------
//
// ***************************************************************************
// ** Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.            **
// **                                                                       **
// ** Xilinx, Inc.                                                          **
// ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
// ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
// ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
// ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
// ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
// ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
// ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
// ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
// ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
// ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
// ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
// ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
// ** FOR A PARTICULAR PURPOSE.                                             **
// **                                                                       **
// ***************************************************************************
//
//----------------------------------------------------------------------------
// Filename:          user_logic.vhd
// Version:           1.00.a
// Description:       User logic module.
// Date:              Tue Mar 06 17:41:28 2012 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------
`include "params.v"


module user_logic
(
  // -- ADD USER PORTS BELOW THIS LINE ---------------
  // --USER ports added here

  bram_read_data_0,
  bram_read_data_1,
  bram_read_data_2,
  bram_read_data_3,
  bram_read_data_4,
  bram_read_data_5,
  bram_read_data_6,
  bram_read_data_7,
  bram_read_data_8,
  bram_read_data_9,
  bram_read_data_10,
  bram_read_data_11,
  bram_read_data_12,
  bram_read_data_13,
  bram_read_data_14,
  bram_read_data_15,
  bram_read_addr,
  curr_frame_bram_offset,
  prev_frame_bram_offset,
  // -- ADD USER PORTS ABOVE THIS LINE ---------------

  // -- DO NOT EDIT BELOW THIS LINE ------------------
  // -- Bus protocol ports, do not add to or delete 
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Reset,                   // Bus to IP reset
  Bus2IP_Data,                    // Bus to IP data bus
  Bus2IP_BE,                      // Bus to IP byte enables
  Bus2IP_RdCE,                    // Bus to IP read chip enable
  Bus2IP_WrCE,                    // Bus to IP write chip enable
  IP2Bus_Data,                    // IP to Bus data bus
  IP2Bus_RdAck,                   // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,                   // IP to Bus write transfer acknowledgement
  IP2Bus_Error,                   // IP to Bus error response
  IP2Bus_IntrEvent                // IP to Bus interrupt event
  // -- DO NOT EDIT ABOVE THIS LINE ------------------
); // user_logic

// -- ADD USER PARAMETERS BELOW THIS LINE ------------
// --USER parameters added here 
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_SLV_DWIDTH                   = 32;
parameter C_NUM_REG                      = 128;
parameter C_NUM_INTR                     = 1;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
// --USER ports added here 

input [`BRAM_DATA_WIDTH-1:0] bram_read_data_0;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_1;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_2;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_3;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_4;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_5;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_6;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_7;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_8;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_9;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_10;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_11;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_12;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_13;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_14;
input [`BRAM_DATA_WIDTH-1:0] bram_read_data_15;
output [`BRAM_ADDR_WIDTH-1:0] bram_read_addr;
input [1:0] curr_frame_bram_offset;
input [1:0] prev_frame_bram_offset;

// -- ADD USER PORTS ABOVE THIS LINE -----------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol ports, do not add to or delete
input                                     Bus2IP_Clk;
input                                     Bus2IP_Reset;
input      [0 : C_SLV_DWIDTH-1]           Bus2IP_Data;
input      [0 : C_SLV_DWIDTH/8-1]         Bus2IP_BE;
input      [0 : C_NUM_REG-1]              Bus2IP_RdCE;
input      [0 : C_NUM_REG-1]              Bus2IP_WrCE;
output     [0 : C_SLV_DWIDTH-1]           IP2Bus_Data;
output                                    IP2Bus_RdAck;
output                                    IP2Bus_WrAck;
output                                    IP2Bus_Error;
output     [0 : C_NUM_INTR-1]             IP2Bus_IntrEvent;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------

  // --USER nets declarations added here, as needed for user logic

  // Nets for user logic slave model s/w accessible register example
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg0;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg1;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg2;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg3;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg4;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg5;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg6;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg7;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg8;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg9;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg10;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg11;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg12;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg13;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg14;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg15;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg16;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg17;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg18;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg19;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg20;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg21;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg22;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg23;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg24;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg25;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg26;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg27;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg28;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg29;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg30;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg31;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg32;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg33;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg34;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg35;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg36;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg37;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg38;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg39;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg40;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg41;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg42;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg43;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg44;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg45;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg46;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg47;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg48;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg49;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg50;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg51;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg52;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg53;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg54;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg55;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg56;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg57;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg58;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg59;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg60;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg61;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg62;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg63;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg64;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg65;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg66;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg67;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg68;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg69;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg70;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg71;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg72;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg73;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg74;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg75;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg76;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg77;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg78;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg79;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg80;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg81;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg82;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg83;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg84;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg85;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg86;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg87;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg88;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg89;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg90;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg91;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg92;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg93;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg94;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg95;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg96;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg97;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg98;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg99;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg100;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg101;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg102;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg103;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg104;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg105;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg106;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg107;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg108;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg109;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg110;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg111;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg112;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg113;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg114;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg115;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg116;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg117;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg118;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg119;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg120;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg121;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg122;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg123;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg124;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg125;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg126;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg127;
  wire       [0 : 127]                      slv_reg_write_sel;
  wire       [0 : 127]                      slv_reg_read_sel;
  reg        [0 : C_SLV_DWIDTH-1]           slv_ip2bus_data;
  wire                                      slv_read_ack;
  wire                                      slv_write_ack;
  integer                                   byte_index, bit_index;

  // --USER logic implementation added here

  // ------------------------------------------------------
  // Example code to read/write user logic slave model s/w accessible registers
  // 
  // Note:
  // The example code presented here is to show you one way of reading/writing
  // software accessible registers implemented in the user logic slave model.
  // Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  // to one software accessible register by the top level template. For example,
  // if you have four 32 bit software accessible registers in the user logic,
  // you are basically operating on the following memory mapped registers:
  // 
  //    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  //                     "1000"   C_BASEADDR + 0x0
  //                     "0100"   C_BASEADDR + 0x4
  //                     "0010"   C_BASEADDR + 0x8
  //                     "0001"   C_BASEADDR + 0xC
  // 
  // ------------------------------------------------------

  assign
    slv_reg_write_sel = Bus2IP_WrCE[0:127],
    slv_reg_read_sel  = Bus2IP_RdCE[0:127],
    slv_write_ack     = Bus2IP_WrCE[0] || Bus2IP_WrCE[1] || Bus2IP_WrCE[2] || /*Bus2IP_WrCE[3] || Bus2IP_WrCE[4] || Bus2IP_WrCE[5] || Bus2IP_WrCE[6] || Bus2IP_WrCE[7] || Bus2IP_WrCE[8] || Bus2IP_WrCE[9] || Bus2IP_WrCE[10] || Bus2IP_WrCE[11] || */ Bus2IP_WrCE[12] || Bus2IP_WrCE[13] || Bus2IP_WrCE[14] || Bus2IP_WrCE[15] || Bus2IP_WrCE[16] || Bus2IP_WrCE[17] || Bus2IP_WrCE[18] || Bus2IP_WrCE[19] || Bus2IP_WrCE[20] || Bus2IP_WrCE[21] || Bus2IP_WrCE[22] || Bus2IP_WrCE[23] || Bus2IP_WrCE[24] || Bus2IP_WrCE[25] || Bus2IP_WrCE[26] || Bus2IP_WrCE[27] || Bus2IP_WrCE[28] || Bus2IP_WrCE[29] || Bus2IP_WrCE[30] || Bus2IP_WrCE[31] || Bus2IP_WrCE[32] || Bus2IP_WrCE[33] || Bus2IP_WrCE[34] || Bus2IP_WrCE[35] || Bus2IP_WrCE[36] || Bus2IP_WrCE[37] || Bus2IP_WrCE[38] || Bus2IP_WrCE[39] || Bus2IP_WrCE[40] || Bus2IP_WrCE[41] || Bus2IP_WrCE[42] || Bus2IP_WrCE[43] || Bus2IP_WrCE[44] || Bus2IP_WrCE[45] || Bus2IP_WrCE[46] || Bus2IP_WrCE[47] || Bus2IP_WrCE[48] || Bus2IP_WrCE[49] || Bus2IP_WrCE[50] || Bus2IP_WrCE[51] || Bus2IP_WrCE[52] || Bus2IP_WrCE[53] || Bus2IP_WrCE[54] || Bus2IP_WrCE[55] || Bus2IP_WrCE[56] || Bus2IP_WrCE[57] || Bus2IP_WrCE[58] || Bus2IP_WrCE[59] || Bus2IP_WrCE[60] || Bus2IP_WrCE[61] || Bus2IP_WrCE[62] || Bus2IP_WrCE[63] || Bus2IP_WrCE[64] || Bus2IP_WrCE[65] || Bus2IP_WrCE[66] || Bus2IP_WrCE[67] || Bus2IP_WrCE[68] || Bus2IP_WrCE[69] || Bus2IP_WrCE[70] || Bus2IP_WrCE[71] || Bus2IP_WrCE[72] || Bus2IP_WrCE[73] || Bus2IP_WrCE[74] || Bus2IP_WrCE[75] || Bus2IP_WrCE[76] || Bus2IP_WrCE[77] || Bus2IP_WrCE[78] || Bus2IP_WrCE[79] || Bus2IP_WrCE[80] || Bus2IP_WrCE[81] || Bus2IP_WrCE[82] || Bus2IP_WrCE[83] || Bus2IP_WrCE[84] || Bus2IP_WrCE[85] || Bus2IP_WrCE[86] || Bus2IP_WrCE[87] || Bus2IP_WrCE[88] || Bus2IP_WrCE[89] || Bus2IP_WrCE[90] || Bus2IP_WrCE[91] || Bus2IP_WrCE[92] || Bus2IP_WrCE[93] || Bus2IP_WrCE[94] || Bus2IP_WrCE[95] || Bus2IP_WrCE[96] || Bus2IP_WrCE[97] || Bus2IP_WrCE[98] || Bus2IP_WrCE[99] || Bus2IP_WrCE[100] || Bus2IP_WrCE[101] || Bus2IP_WrCE[102] || Bus2IP_WrCE[103] || Bus2IP_WrCE[104] || Bus2IP_WrCE[105] || Bus2IP_WrCE[106] || Bus2IP_WrCE[107] || Bus2IP_WrCE[108] || Bus2IP_WrCE[109] || Bus2IP_WrCE[110] || Bus2IP_WrCE[111] || Bus2IP_WrCE[112] || Bus2IP_WrCE[113] || Bus2IP_WrCE[114] || Bus2IP_WrCE[115] || Bus2IP_WrCE[116] || Bus2IP_WrCE[117] || Bus2IP_WrCE[118] || Bus2IP_WrCE[119] || Bus2IP_WrCE[120] || Bus2IP_WrCE[121] || Bus2IP_WrCE[122] || Bus2IP_WrCE[123] || Bus2IP_WrCE[124] || Bus2IP_WrCE[125] || Bus2IP_WrCE[126] || Bus2IP_WrCE[127],
    slv_read_ack      = Bus2IP_RdCE[0] || Bus2IP_RdCE[1] || Bus2IP_RdCE[2] || Bus2IP_RdCE[3] || Bus2IP_RdCE[4] || Bus2IP_RdCE[5] || Bus2IP_RdCE[6] || Bus2IP_RdCE[7] || Bus2IP_RdCE[8] || Bus2IP_RdCE[9] || Bus2IP_RdCE[10] || Bus2IP_RdCE[11] || Bus2IP_RdCE[12] || Bus2IP_RdCE[13] || Bus2IP_RdCE[14] || Bus2IP_RdCE[15] || Bus2IP_RdCE[16] || Bus2IP_RdCE[17] || Bus2IP_RdCE[18] || Bus2IP_RdCE[19] || Bus2IP_RdCE[20] || Bus2IP_RdCE[21] || Bus2IP_RdCE[22] || Bus2IP_RdCE[23] || Bus2IP_RdCE[24] || Bus2IP_RdCE[25] || Bus2IP_RdCE[26] || Bus2IP_RdCE[27] || Bus2IP_RdCE[28] || Bus2IP_RdCE[29] || Bus2IP_RdCE[30] || Bus2IP_RdCE[31] || Bus2IP_RdCE[32] || Bus2IP_RdCE[33] || Bus2IP_RdCE[34] || Bus2IP_RdCE[35] || Bus2IP_RdCE[36] || Bus2IP_RdCE[37] || Bus2IP_RdCE[38] || Bus2IP_RdCE[39] || Bus2IP_RdCE[40] || Bus2IP_RdCE[41] || Bus2IP_RdCE[42] || Bus2IP_RdCE[43] || Bus2IP_RdCE[44] || Bus2IP_RdCE[45] || Bus2IP_RdCE[46] || Bus2IP_RdCE[47] || Bus2IP_RdCE[48] || Bus2IP_RdCE[49] || Bus2IP_RdCE[50] || Bus2IP_RdCE[51] || Bus2IP_RdCE[52] || Bus2IP_RdCE[53] || Bus2IP_RdCE[54] || Bus2IP_RdCE[55] || Bus2IP_RdCE[56] || Bus2IP_RdCE[57] || Bus2IP_RdCE[58] || Bus2IP_RdCE[59] || Bus2IP_RdCE[60] || Bus2IP_RdCE[61] || Bus2IP_RdCE[62] || Bus2IP_RdCE[63] || Bus2IP_RdCE[64] || Bus2IP_RdCE[65] || Bus2IP_RdCE[66] || Bus2IP_RdCE[67] || Bus2IP_RdCE[68] || Bus2IP_RdCE[69] || Bus2IP_RdCE[70] || Bus2IP_RdCE[71] || Bus2IP_RdCE[72] || Bus2IP_RdCE[73] || Bus2IP_RdCE[74] || Bus2IP_RdCE[75] || Bus2IP_RdCE[76] || Bus2IP_RdCE[77] || Bus2IP_RdCE[78] || Bus2IP_RdCE[79] || Bus2IP_RdCE[80] || Bus2IP_RdCE[81] || Bus2IP_RdCE[82] || Bus2IP_RdCE[83] || Bus2IP_RdCE[84] || Bus2IP_RdCE[85] || Bus2IP_RdCE[86] || Bus2IP_RdCE[87] || Bus2IP_RdCE[88] || Bus2IP_RdCE[89] || Bus2IP_RdCE[90] || Bus2IP_RdCE[91] || Bus2IP_RdCE[92] || Bus2IP_RdCE[93] || Bus2IP_RdCE[94] || Bus2IP_RdCE[95] || Bus2IP_RdCE[96] || Bus2IP_RdCE[97] || Bus2IP_RdCE[98] || Bus2IP_RdCE[99] || Bus2IP_RdCE[100] || Bus2IP_RdCE[101] || Bus2IP_RdCE[102] || Bus2IP_RdCE[103] || Bus2IP_RdCE[104] || Bus2IP_RdCE[105] || Bus2IP_RdCE[106] || Bus2IP_RdCE[107] || Bus2IP_RdCE[108] || Bus2IP_RdCE[109] || Bus2IP_RdCE[110] || Bus2IP_RdCE[111] || Bus2IP_RdCE[112] || Bus2IP_RdCE[113] || Bus2IP_RdCE[114] || Bus2IP_RdCE[115] || Bus2IP_RdCE[116] || Bus2IP_RdCE[117] || Bus2IP_RdCE[118] || Bus2IP_RdCE[119] || Bus2IP_RdCE[120] || Bus2IP_RdCE[121] || Bus2IP_RdCE[122] || Bus2IP_RdCE[123] || Bus2IP_RdCE[124] || Bus2IP_RdCE[125] || Bus2IP_RdCE[126] || Bus2IP_RdCE[127];

  // implement slave model register(s)
  always @( posedge Bus2IP_Clk )
    begin: SLAVE_REG_WRITE_PROC

      if ( Bus2IP_Reset == 1 )
        begin
          slv_reg0 <= 0;
          slv_reg1 <= 0;
          slv_reg2 <= 0;
          /*
          slv_reg3 <= 0;
          slv_reg4 <= 0;
          slv_reg5 <= 0;
          slv_reg6 <= 0;
          slv_reg7 <= 0;
          slv_reg8 <= 0;
          slv_reg9 <= 0;
          slv_reg10 <= 0;
          slv_reg11 <= 0;
          slv_reg12 <= 0;
          slv_reg13 <= 0;
          slv_reg14 <= 0;
          slv_reg15 <= 0;
          slv_reg16 <= 0;
          slv_reg17 <= 0;
          slv_reg18 <= 0;
          slv_reg19 <= 0;
          */
          slv_reg20 <= 0;
          slv_reg21 <= 0;
          slv_reg22 <= 0;
          slv_reg23 <= 0;
          slv_reg24 <= 0;
          slv_reg25 <= 0;
          slv_reg26 <= 0;
          slv_reg27 <= 0;
          slv_reg28 <= 0;
          slv_reg29 <= 0;
          slv_reg30 <= 0;
          slv_reg31 <= 0;
          slv_reg32 <= 0;
          slv_reg33 <= 0;
          slv_reg34 <= 0;
          slv_reg35 <= 0;
          slv_reg36 <= 0;
          slv_reg37 <= 0;
          slv_reg38 <= 0;
          slv_reg39 <= 0;
          slv_reg40 <= 0;
          slv_reg41 <= 0;
          slv_reg42 <= 0;
          slv_reg43 <= 0;
          slv_reg44 <= 0;
          slv_reg45 <= 0;
          slv_reg46 <= 0;
          slv_reg47 <= 0;
          slv_reg48 <= 0;
          slv_reg49 <= 0;
          slv_reg50 <= 0;
          slv_reg51 <= 0;
          slv_reg52 <= 0;
          slv_reg53 <= 0;
          slv_reg54 <= 0;
          slv_reg55 <= 0;
          slv_reg56 <= 0;
          slv_reg57 <= 0;
          slv_reg58 <= 0;
          slv_reg59 <= 0;
          slv_reg60 <= 0;
          slv_reg61 <= 0;
          slv_reg62 <= 0;
          slv_reg63 <= 0;
          slv_reg64 <= 0;
          slv_reg65 <= 0;
          slv_reg66 <= 0;
          slv_reg67 <= 0;
          slv_reg68 <= 0;
          slv_reg69 <= 0;
          slv_reg70 <= 0;
          slv_reg71 <= 0;
          slv_reg72 <= 0;
          slv_reg73 <= 0;
          slv_reg74 <= 0;
          slv_reg75 <= 0;
          slv_reg76 <= 0;
          slv_reg77 <= 0;
          slv_reg78 <= 0;
          slv_reg79 <= 0;
          slv_reg80 <= 0;
          slv_reg81 <= 0;
          slv_reg82 <= 0;
          slv_reg83 <= 0;
          slv_reg84 <= 0;
          slv_reg85 <= 0;
          slv_reg86 <= 0;
          slv_reg87 <= 0;
          slv_reg88 <= 0;
          slv_reg89 <= 0;
          slv_reg90 <= 0;
          slv_reg91 <= 0;
          slv_reg92 <= 0;
          slv_reg93 <= 0;
          slv_reg94 <= 0;
          slv_reg95 <= 0;
          slv_reg96 <= 0;
          slv_reg97 <= 0;
          slv_reg98 <= 0;
          slv_reg99 <= 0;
          slv_reg100 <= 0;
          slv_reg101 <= 0;
          slv_reg102 <= 0;
          slv_reg103 <= 0;
          slv_reg104 <= 0;
          slv_reg105 <= 0;
          slv_reg106 <= 0;
          slv_reg107 <= 0;
          slv_reg108 <= 0;
          slv_reg109 <= 0;
          slv_reg110 <= 0;
          slv_reg111 <= 0;
          slv_reg112 <= 0;
          slv_reg113 <= 0;
          slv_reg114 <= 0;
          slv_reg115 <= 0;
          slv_reg116 <= 0;
          slv_reg117 <= 0;
          slv_reg118 <= 0;
          slv_reg119 <= 0;
          slv_reg120 <= 0;
          slv_reg121 <= 0;
          slv_reg122 <= 0;
          slv_reg123 <= 0;
          slv_reg124 <= 0;
          slv_reg125 <= 0;
          slv_reg126 <= 0;
          slv_reg127 <= 0;
        end
      else
        case ( slv_reg_write_sel )
          128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg0[bit_index] <= Bus2IP_Data[bit_index];
          128'b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg1[bit_index] <= Bus2IP_Data[bit_index];
          128'b00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg2[bit_index] <= Bus2IP_Data[bit_index];
/*
         128'b00010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
           for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
             if ( Bus2IP_BE[byte_index] == 1 )
               for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                 slv_reg3[bit_index] <= Bus2IP_Data[bit_index];
         128'b00001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
           for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
             if ( Bus2IP_BE[byte_index] == 1 )
               for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                 slv_reg4[bit_index] <= Bus2IP_Data[bit_index];
         128'b00000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
           for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
             if ( Bus2IP_BE[byte_index] == 1 )
               for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                 slv_reg5[bit_index] <= Bus2IP_Data[bit_index];
         128'b00000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
           for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
             if ( Bus2IP_BE[byte_index] == 1 )
               for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                 slv_reg6[bit_index] <= Bus2IP_Data[bit_index];
         128'b00000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
           for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
             if ( Bus2IP_BE[byte_index] == 1 )
               for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                 slv_reg7[bit_index] <= Bus2IP_Data[bit_index];
         128'b00000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
           for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
             if ( Bus2IP_BE[byte_index] == 1 )
               for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                 slv_reg8[bit_index] <= Bus2IP_Data[bit_index];
         128'b00000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
           for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
             if ( Bus2IP_BE[byte_index] == 1 )
               for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                 slv_reg9[bit_index] <= Bus2IP_Data[bit_index];
         128'b00000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
           for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
             if ( Bus2IP_BE[byte_index] == 1 )
               for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                 slv_reg10[bit_index] <= Bus2IP_Data[bit_index];
         128'b00000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
           for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
             if ( Bus2IP_BE[byte_index] == 1 )
               for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                 slv_reg11[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg12[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg13[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg14[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg15[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg16[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg17[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg18[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg19[bit_index] <= Bus2IP_Data[bit_index];
*/
          128'b00000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg20[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg21[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg22[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg23[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg24[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg25[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg26[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg27[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg28[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg29[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg30[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg31[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg32[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg33[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg34[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg35[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg36[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg37[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg38[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg39[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg40[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg41[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg42[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg43[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg44[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg45[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg46[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg47[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg48[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg49[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg50[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg51[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg52[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg53[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg54[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg55[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg56[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg57[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg58[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg59[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg60[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg61[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg62[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg63[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg64[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg65[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg66[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg67[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg68[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg69[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg70[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg71[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg72[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg73[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg74[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg75[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg76[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg77[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg78[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg79[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg80[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg81[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg82[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg83[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg84[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg85[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg86[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg87[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg88[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg89[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg90[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg91[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg92[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg93[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg94[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg95[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg96[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg97[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg98[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg99[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg100[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg101[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg102[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg103[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg104[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg105[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg106[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg107[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg108[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg109[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg110[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg111[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg112[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg113[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg114[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg115[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg116[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg117[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg118[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg119[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg120[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg121[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg122[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg123[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg124[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg125[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg126[bit_index] <= Bus2IP_Data[bit_index];
          128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg127[bit_index] <= Bus2IP_Data[bit_index];
          default : ;
        endcase

    end // SLAVE_REG_WRITE_PROC

  // implement slave model register read mux
  always @( slv_reg_read_sel or slv_reg0 or slv_reg1 or slv_reg2 or slv_reg3 or slv_reg4 or slv_reg5 or slv_reg6 or slv_reg7 or slv_reg8 or slv_reg9 or slv_reg10 or slv_reg11 or slv_reg12 or slv_reg13 or slv_reg14 or slv_reg15 or slv_reg16 or slv_reg17 or slv_reg18 or slv_reg19 or slv_reg20 or slv_reg21 or slv_reg22 or slv_reg23 or slv_reg24 or slv_reg25 or slv_reg26 or slv_reg27 or slv_reg28 or slv_reg29 or slv_reg30 or slv_reg31 or slv_reg32 or slv_reg33 or slv_reg34 or slv_reg35 or slv_reg36 or slv_reg37 or slv_reg38 or slv_reg39 or slv_reg40 or slv_reg41 or slv_reg42 or slv_reg43 or slv_reg44 or slv_reg45 or slv_reg46 or slv_reg47 or slv_reg48 or slv_reg49 or slv_reg50 or slv_reg51 or slv_reg52 or slv_reg53 or slv_reg54 or slv_reg55 or slv_reg56 or slv_reg57 or slv_reg58 or slv_reg59 or slv_reg60 or slv_reg61 or slv_reg62 or slv_reg63 or slv_reg64 or slv_reg65 or slv_reg66 or slv_reg67 or slv_reg68 or slv_reg69 or slv_reg70 or slv_reg71 or slv_reg72 or slv_reg73 or slv_reg74 or slv_reg75 or slv_reg76 or slv_reg77 or slv_reg78 or slv_reg79 or slv_reg80 or slv_reg81 or slv_reg82 or slv_reg83 or slv_reg84 or slv_reg85 or slv_reg86 or slv_reg87 or slv_reg88 or slv_reg89 or slv_reg90 or slv_reg91 or slv_reg92 or slv_reg93 or slv_reg94 or slv_reg95 or slv_reg96 or slv_reg97 or slv_reg98 or slv_reg99 or slv_reg100 or slv_reg101 or slv_reg102 or slv_reg103 or slv_reg104 or slv_reg105 or slv_reg106 or slv_reg107 or slv_reg108 or slv_reg109 or slv_reg110 or slv_reg111 or slv_reg112 or slv_reg113 or slv_reg114 or slv_reg115 or slv_reg116 or slv_reg117 or slv_reg118 or slv_reg119 or slv_reg120 or slv_reg121 or slv_reg122 or slv_reg123 or slv_reg124 or slv_reg125 or slv_reg126 or slv_reg127 )
    begin: SLAVE_REG_READ_PROC

      case ( slv_reg_read_sel )
        128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg0;
        128'b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg1;
        128'b00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg2;
        128'b00010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg3;
        128'b00001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg4;
        128'b00000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg5;
        128'b00000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg6;
        128'b00000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg7;
        128'b00000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg8;
        128'b00000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg9;
        128'b00000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg10;
        128'b00000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg11;
        128'b00000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg12;
        128'b00000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg13;
        128'b00000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg14;
        128'b00000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg15;
        128'b00000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg16;
        128'b00000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg17;
        128'b00000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg18;
        128'b00000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg19;
        128'b00000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg20;
        128'b00000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg21;
        128'b00000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg22;
        128'b00000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg23;
        128'b00000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg24;
        128'b00000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg25;
        128'b00000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg26;
        128'b00000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg27;
        128'b00000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg28;
        128'b00000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg29;
        128'b00000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg30;
        128'b00000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg31;
        128'b00000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg32;
        128'b00000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg33;
        128'b00000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg34;
        128'b00000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg35;
        128'b00000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg36;
        128'b00000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg37;
        128'b00000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg38;
        128'b00000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg39;
        128'b00000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg40;
        128'b00000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg41;
        128'b00000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg42;
        128'b00000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg43;
        128'b00000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg44;
        128'b00000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg45;
        128'b00000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg46;
        128'b00000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg47;
        128'b00000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg48;
        128'b00000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg49;
        128'b00000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg50;
        128'b00000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg51;
        128'b00000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg52;
        128'b00000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg53;
        128'b00000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg54;
        128'b00000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg55;
        128'b00000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg56;
        128'b00000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg57;
        128'b00000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg58;
        128'b00000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg59;
        128'b00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg60;
        128'b00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg61;
        128'b00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg62;
        128'b00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg63;
        128'b00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg64;
        128'b00000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg65;
        128'b00000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg66;
        128'b00000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg67;
        128'b00000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg68;
        128'b00000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg69;
        128'b00000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg70;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg71;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg72;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg73;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg74;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg75;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg76;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg77;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg78;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg79;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg80;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg81;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg82;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg83;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg84;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg85;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg86;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg87;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg88;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg89;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg90;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg91;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg92;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg93;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000 : slv_ip2bus_data <= slv_reg94;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000 : slv_ip2bus_data <= slv_reg95;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000 : slv_ip2bus_data <= slv_reg96;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000 : slv_ip2bus_data <= slv_reg97;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000 : slv_ip2bus_data <= slv_reg98;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000 : slv_ip2bus_data <= slv_reg99;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000 : slv_ip2bus_data <= slv_reg100;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000 : slv_ip2bus_data <= slv_reg101;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000 : slv_ip2bus_data <= slv_reg102;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000 : slv_ip2bus_data <= slv_reg103;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000 : slv_ip2bus_data <= slv_reg104;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000 : slv_ip2bus_data <= slv_reg105;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000 : slv_ip2bus_data <= slv_reg106;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000 : slv_ip2bus_data <= slv_reg107;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000 : slv_ip2bus_data <= slv_reg108;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000 : slv_ip2bus_data <= slv_reg109;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000 : slv_ip2bus_data <= slv_reg110;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000 : slv_ip2bus_data <= slv_reg111;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000 : slv_ip2bus_data <= slv_reg112;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000 : slv_ip2bus_data <= slv_reg113;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000 : slv_ip2bus_data <= slv_reg114;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000 : slv_ip2bus_data <= slv_reg115;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000 : slv_ip2bus_data <= slv_reg116;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000 : slv_ip2bus_data <= slv_reg117;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000 : slv_ip2bus_data <= slv_reg118;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000 : slv_ip2bus_data <= slv_reg119;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000 : slv_ip2bus_data <= slv_reg120;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000 : slv_ip2bus_data <= slv_reg121;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000 : slv_ip2bus_data <= slv_reg122;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000 : slv_ip2bus_data <= slv_reg123;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000 : slv_ip2bus_data <= slv_reg124;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100 : slv_ip2bus_data <= slv_reg125;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010 : slv_ip2bus_data <= slv_reg126;
        128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001 : slv_ip2bus_data <= slv_reg127;
        default : slv_ip2bus_data <= 0;
      endcase

    end // SLAVE_REG_READ_PROC

  // ------------------------------------------------------------
  // Example code to drive IP to Bus signals
  // ------------------------------------------------------------

  assign IP2Bus_Data    = slv_ip2bus_data;
  assign IP2Bus_WrAck   = slv_write_ack;
  assign IP2Bus_RdAck   = slv_read_ack;
  assign IP2Bus_Error   = 0;


//NOTE: SLV_REG bits are reversed
wire [`FRAME_BITSUM_WIDTH-1:0] corr_0_corr_sum, corr_1_corr_sum, corr_2_corr_sum, corr_3_corr_sum, corr_4_corr_sum, corr_5_corr_sum, corr_6_corr_sum, corr_7_corr_sum, corr_8_corr_sum, corr_9_corr_sum, corr_10_corr_sum, corr_11_corr_sum, corr_12_corr_sum, corr_13_corr_sum, corr_14_corr_sum, corr_15_corr_sum;
wire corr_0_done, corr_1_done, corr_2_done, corr_3_done, corr_4_done, corr_5_done, corr_6_done, corr_7_done, corr_8_done, corr_9_done, corr_10_done, corr_11_done, corr_12_done, corr_13_done, corr_14_done, corr_15_done;

/*
correlator_core corr_0(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_0),
    .bram_addr(bram_read_addr),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_0_corr_sum),
    .done(corr_0_done)
    );


correlator_core corr_1(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_1),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_1_corr_sum),
    .done(corr_1_done)
    );


correlator_core corr_2(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_2),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_2_corr_sum),
    .done(corr_2_done)
    );

correlator_core corr_3(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_3),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_3_corr_sum),
    .done(corr_3_done)
    );

correlator_core corr_4(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_4),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_4_corr_sum),
    .done(corr_4_done)
    );

correlator_core corr_5(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_5),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_5_corr_sum),
    .done(corr_5_done)
    );

correlator_core corr_6(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_6),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_6_corr_sum),
    .done(corr_6_done)
    );

correlator_core corr_7(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_7),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_7_corr_sum),
    .done(corr_7_done)
    );

correlator_core corr_8(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_8),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_8_corr_sum),
    .done(corr_8_done)
    );

correlator_core corr_9(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_9),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_9_corr_sum),
    .done(corr_9_done)
    );

correlator_core corr_10(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_10),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_10_corr_sum),
    .done(corr_10_done)
    );

correlator_core corr_11(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_11),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_11_corr_sum),
    .done(corr_11_done)
    );
correlator_core corr_12(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_12),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_12_corr_sum),
    .done(corr_12_done)
    );

correlator_core corr_13(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_13),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_13_corr_sum),
    .done(corr_13_done)
    );

correlator_core corr_14(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_14),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_14_corr_sum),
    .done(corr_14_done)
    );

correlator_core corr_15(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(slv_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_15),
    .bram_addr(),

    //x & y offsets
    .x_offset(slv_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(slv_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_15_corr_sum),
    .done(corr_15_done)
    );
*/
always @(posedge Bus2IP_Clk) begin
    if ( Bus2IP_Reset == 1 )
    begin
        slv_reg3 <= 0;
        slv_reg4 <= 0;
        slv_reg5 <= 0;
        slv_reg6 <= 0;
        slv_reg7 <= 0;
        slv_reg8 <= 0;
        slv_reg9 <= 0;
        slv_reg10 <= 0;
        slv_reg11 <= 0;
        slv_reg12 <= 0;
        slv_reg13 <= 0;
        slv_reg14 <= 0;
        slv_reg15 <= 0;
        slv_reg16 <= 0;
        slv_reg17 <= 0;
        slv_reg18 <= 0;
        slv_reg19 <= 0;
    end
    else
    begin
        slv_reg3 <= {31'h0, corr_0_done}; //all done signals assert at the same time
        slv_reg4 <= {17'h0, corr_0_corr_sum};
        slv_reg5 <= {17'h0, corr_1_corr_sum};
        slv_reg6 <= {17'h0, corr_2_corr_sum};
        slv_reg7 <= {17'h0, corr_3_corr_sum};
        slv_reg8 <= {17'h0, corr_4_corr_sum};
        slv_reg9 <= {17'h0, corr_5_corr_sum};
        slv_reg10 <= {17'h0, corr_6_corr_sum};
        slv_reg11 <= {17'h0, corr_7_corr_sum};
        slv_reg12 <= {17'h0, corr_8_corr_sum};
        slv_reg13 <= {17'h0, corr_9_corr_sum};
        slv_reg14 <= {17'h0, corr_10_corr_sum};
        slv_reg15 <= {17'h0, corr_11_corr_sum};
        slv_reg16 <= {17'h0, corr_12_corr_sum};
        slv_reg17 <= {17'h0, corr_13_corr_sum};
        slv_reg18 <= {17'h0, corr_14_corr_sum};
        slv_reg19 <= {17'h0, corr_15_corr_sum};
    end
end

endmodule
