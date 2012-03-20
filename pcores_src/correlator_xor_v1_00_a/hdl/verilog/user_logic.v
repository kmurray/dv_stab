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
// Date:              Fri Mar 16 19:45:56 2012 (by Create and Import Peripheral Wizard)
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

// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_SLV_DWIDTH                   = 32;
parameter C_NUM_REG                      = 25;
parameter C_NUM_INTR                     = 1;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
// --USER ports added here 
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
  reg        [0 : C_SLV_DWIDTH-1]           cntrl_reg0;
  reg        [0 : C_SLV_DWIDTH-1]           x_offest_reg1;
  reg        [0 : C_SLV_DWIDTH-1]           y_offest_reg2;
  reg        [0 : C_SLV_DWIDTH-1]           status_reg3;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_0_reg4;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_1_reg5;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_2_reg6;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_3_reg7;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_4_reg8;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_5_reg9;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_6_reg10;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_7_reg11;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_8_reg12;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_9_reg13;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_10_reg14;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_11_reg15;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_12_reg16;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_13_reg17;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_14_reg18;
  reg        [0 : C_SLV_DWIDTH-1]           corr_value_15_reg19;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg20;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg21;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg22;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg23;
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg24;
  wire       [0 : 24]                       slv_reg_write_sel;
  wire       [0 : 24]                       slv_reg_read_sel;
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
    slv_reg_write_sel = Bus2IP_WrCE[0:24],
    slv_reg_read_sel  = Bus2IP_RdCE[0:24],
    slv_write_ack     = Bus2IP_WrCE[0] || Bus2IP_WrCE[1] || Bus2IP_WrCE[2] || Bus2IP_WrCE[3] || Bus2IP_WrCE[4] || Bus2IP_WrCE[5] || Bus2IP_WrCE[6] || Bus2IP_WrCE[7] || Bus2IP_WrCE[8] || Bus2IP_WrCE[9] || Bus2IP_WrCE[10] || Bus2IP_WrCE[11] || Bus2IP_WrCE[12] || Bus2IP_WrCE[13] || Bus2IP_WrCE[14] || Bus2IP_WrCE[15] || Bus2IP_WrCE[16] || Bus2IP_WrCE[17] || Bus2IP_WrCE[18] || Bus2IP_WrCE[19] || Bus2IP_WrCE[20] || Bus2IP_WrCE[21] || Bus2IP_WrCE[22] || Bus2IP_WrCE[23] || Bus2IP_WrCE[24],
    slv_read_ack      = Bus2IP_RdCE[0] || Bus2IP_RdCE[1] || Bus2IP_RdCE[2] || Bus2IP_RdCE[3] || Bus2IP_RdCE[4] || Bus2IP_RdCE[5] || Bus2IP_RdCE[6] || Bus2IP_RdCE[7] || Bus2IP_RdCE[8] || Bus2IP_RdCE[9] || Bus2IP_RdCE[10] || Bus2IP_RdCE[11] || Bus2IP_RdCE[12] || Bus2IP_RdCE[13] || Bus2IP_RdCE[14] || Bus2IP_RdCE[15] || Bus2IP_RdCE[16] || Bus2IP_RdCE[17] || Bus2IP_RdCE[18] || Bus2IP_RdCE[19] || Bus2IP_RdCE[20] || Bus2IP_RdCE[21] || Bus2IP_RdCE[22] || Bus2IP_RdCE[23] || Bus2IP_RdCE[24];

  // implement slave model register(s)
  always @( posedge Bus2IP_Clk )
    begin: SLAVE_REG_WRITE_PROC

      if ( Bus2IP_Reset == 1 )
        begin
          cntrl_reg0 <= 0;
          x_offest_reg1 <= 0;
          y_offest_reg2 <= 0;
        /*
          status_reg3 <= 0;
          corr_value_0_reg4 <= 0;
          corr_value_1_reg5 <= 0;
          corr_value_2_reg6 <= 0;
          corr_value_3_reg7 <= 0;
          corr_value_4_reg8 <= 0;
          corr_value_5_reg9 <= 0;
          corr_value_6_reg10 <= 0;
          corr_value_7_reg11 <= 0;
          corr_value_8_reg12 <= 0;
          corr_value_9_reg13 <= 0;
          corr_value_10_reg14 <= 0;
          corr_value_11_reg15 <= 0;
          corr_value_12_reg16 <= 0;
          corr_value_13_reg17 <= 0;
          corr_value_14_reg18 <= 0;
          corr_value_15_reg19 <= 0;
        */
          slv_reg20 <= 0;
          slv_reg21 <= 0;
          slv_reg22 <= 0;
          slv_reg23 <= 0;
          slv_reg24 <= 0;
        end
      else
        case ( slv_reg_write_sel )
          25'b1000000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  cntrl_reg0[bit_index] <= Bus2IP_Data[bit_index];
          25'b0100000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  x_offest_reg1[bit_index] <= Bus2IP_Data[bit_index];
          25'b0010000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  y_offest_reg2[bit_index] <= Bus2IP_Data[bit_index];
        /*
          25'b0001000000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  status_reg3[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000100000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_0_reg4[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000010000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_1_reg5[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000001000000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_2_reg6[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000100000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_3_reg7[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000010000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_4_reg8[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000001000000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_5_reg9[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000100000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_6_reg10[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000010000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_7_reg11[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000001000000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_8_reg12[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000100000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_9_reg13[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000010000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_10_reg14[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000001000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_11_reg15[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000000100000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_12_reg16[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000000010000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_13_reg17[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000000001000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_14_reg18[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000000000100000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  corr_value_15_reg19[bit_index] <= Bus2IP_Data[bit_index];
       */
          25'b0000000000000000000010000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg20[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000000000001000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg21[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000000000000100 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg22[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000000000000010 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg23[bit_index] <= Bus2IP_Data[bit_index];
          25'b0000000000000000000000001 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg24[bit_index] <= Bus2IP_Data[bit_index];
          default : ;
        endcase

    end // SLAVE_REG_WRITE_PROC

  // implement slave model register read mux
  always @(*)
    begin: SLAVE_REG_READ_PROC

      case ( slv_reg_read_sel )
        25'b1000000000000000000000000 : slv_ip2bus_data <= cntrl_reg0;
        25'b0100000000000000000000000 : slv_ip2bus_data <= x_offest_reg1;
        25'b0010000000000000000000000 : slv_ip2bus_data <= y_offest_reg2;
        25'b0001000000000000000000000 : slv_ip2bus_data <= status_reg3;
        25'b0000100000000000000000000 : slv_ip2bus_data <= corr_value_0_reg4;
        25'b0000010000000000000000000 : slv_ip2bus_data <= corr_value_1_reg5;
        25'b0000001000000000000000000 : slv_ip2bus_data <= corr_value_2_reg6;
        25'b0000000100000000000000000 : slv_ip2bus_data <= corr_value_3_reg7;
        25'b0000000010000000000000000 : slv_ip2bus_data <= corr_value_4_reg8;
        25'b0000000001000000000000000 : slv_ip2bus_data <= corr_value_5_reg9;
        25'b0000000000100000000000000 : slv_ip2bus_data <= corr_value_6_reg10;
        25'b0000000000010000000000000 : slv_ip2bus_data <= corr_value_7_reg11;
        25'b0000000000001000000000000 : slv_ip2bus_data <= corr_value_8_reg12;
        25'b0000000000000100000000000 : slv_ip2bus_data <= corr_value_9_reg13;
        25'b0000000000000010000000000 : slv_ip2bus_data <= corr_value_10_reg14;
        25'b0000000000000001000000000 : slv_ip2bus_data <= corr_value_11_reg15;
        25'b0000000000000000100000000 : slv_ip2bus_data <= corr_value_12_reg16;
        25'b0000000000000000010000000 : slv_ip2bus_data <= corr_value_13_reg17;
        25'b0000000000000000001000000 : slv_ip2bus_data <= corr_value_14_reg18;
        25'b0000000000000000000100000 : slv_ip2bus_data <= corr_value_15_reg19;
        25'b0000000000000000000010000 : slv_ip2bus_data <= slv_reg20;
        25'b0000000000000000000001000 : slv_ip2bus_data <= slv_reg21;
        25'b0000000000000000000000100 : slv_ip2bus_data <= slv_reg22;
        25'b0000000000000000000000010 : slv_ip2bus_data <= slv_reg23;
        25'b0000000000000000000000001 : slv_ip2bus_data <= slv_reg24;
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



  /* Custom log instanciation */



  //NOTE: SLV_REG bits are reversed
wire [`FRAME_BITSUM_WIDTH-1:0] corr_0_corr_sum, corr_1_corr_sum, corr_2_corr_sum, corr_3_corr_sum, corr_4_corr_sum, corr_5_corr_sum, corr_6_corr_sum, corr_7_corr_sum, corr_8_corr_sum, corr_9_corr_sum, corr_10_corr_sum, corr_11_corr_sum, corr_12_corr_sum, corr_13_corr_sum, corr_14_corr_sum, corr_15_corr_sum;
wire corr_0_done;

correlator_core corr_0(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_0),
    .bram_addr(bram_read_addr),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

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
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_1),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_1_corr_sum),
    .done()
    );


correlator_core corr_2(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_2),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_2_corr_sum),
    .done()
    );

correlator_core corr_3(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_3),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_3_corr_sum),
    .done()
    );

correlator_core corr_4(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_4),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_4_corr_sum),
    .done()
    );

correlator_core corr_5(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_5),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_5_corr_sum),
    .done()
    );

correlator_core corr_6(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_6),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_6_corr_sum),
    .done()
    );

correlator_core corr_7(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_7),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_7_corr_sum),
    .done()
    );

correlator_core corr_8(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_8),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_8_corr_sum),
    .done()
    );

correlator_core corr_9(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_9),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_9_corr_sum),
    .done()
    );

correlator_core corr_10(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_10),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_10_corr_sum),
    .done()
    );

correlator_core corr_11(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_11),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_11_corr_sum),
    .done()
    );
correlator_core corr_12(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_12),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_12_corr_sum),
    .done()
    );

correlator_core corr_13(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_13),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_13_corr_sum),
    .done()
    );

correlator_core corr_14(
    .clk(Bus2IP_Clk),
    .resetn(~Bus2IP_Reset), 
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_14),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

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
    .go(cntrl_reg0[C_SLV_DWIDTH-1]),
    //bram data and address
    .bram_data(bram_read_data_15),
    .bram_addr(),

    //x & y offsets
    .x_offset(x_offest_reg1[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),
    .y_offset(y_offest_reg2[C_SLV_DWIDTH-`MAX_OFFSET_WIDTH:C_SLV_DWIDTH-1]),

    //bram addr offsets
    .curr_frame_bram_offset(curr_frame_bram_offset),
    .prev_frame_bram_offset(prev_frame_bram_offset),

    //final correlation sum
    .corr_sum(corr_15_corr_sum),
    .done()
    );
/*
*/

always @(posedge Bus2IP_Clk) begin
    if ( Bus2IP_Reset == 1 )
    begin
        status_reg3 <= 0;
        corr_value_0_reg4 <= 0;
        corr_value_1_reg5 <= 0;
        corr_value_2_reg6 <= 0;
        corr_value_3_reg7 <= 0;
        corr_value_4_reg8 <= 0;
        corr_value_5_reg9 <= 0;
        corr_value_6_reg10 <= 0;
        corr_value_7_reg11 <= 0;
        corr_value_8_reg12 <= 0;
        corr_value_9_reg13 <= 0;
        corr_value_10_reg14 <= 0;
        corr_value_11_reg15 <= 0;
        corr_value_12_reg16 <= 0;
        corr_value_13_reg17 <= 0;
        corr_value_14_reg18 <= 0;
        corr_value_15_reg19 <= 0;
    end
    else
    begin
        //TODO: check endianess of bram offests
        status_reg3 <= {12'h000, curr_frame_bram_offset, prev_frame_bram_offset, 2'b00, 12'h000, corr_0_done}; //all done signals assert at the same time
        corr_value_0_reg4 <= {17'h0, corr_0_corr_sum};
        corr_value_1_reg5 <= {17'h0, corr_1_corr_sum};
        corr_value_2_reg6 <= {17'h0, corr_2_corr_sum};
        corr_value_3_reg7 <= {17'h0, corr_3_corr_sum};
        corr_value_4_reg8 <= {17'h0, corr_4_corr_sum};
        corr_value_5_reg9 <= {17'h0, corr_5_corr_sum};
        corr_value_6_reg10 <= {17'h0, corr_6_corr_sum};
        corr_value_7_reg11 <= {17'h0, corr_7_corr_sum};
        corr_value_8_reg12 <= {17'h0, corr_8_corr_sum};
        corr_value_9_reg13 <= {17'h0, corr_9_corr_sum};
        corr_value_10_reg14 <= {17'h0, corr_10_corr_sum};
        corr_value_11_reg15 <= {17'h0, corr_11_corr_sum};
        corr_value_12_reg16 <= {17'h0, corr_12_corr_sum};
        corr_value_13_reg17 <= {17'h0, corr_13_corr_sum};
        corr_value_14_reg18 <= {17'h0, corr_14_corr_sum};
        corr_value_15_reg19 <= {17'h0, corr_15_corr_sum};
    end
end




endmodule
