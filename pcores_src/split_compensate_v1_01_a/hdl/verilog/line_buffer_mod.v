//-----------------------------------------------------------------------------
// $Id: line_buffer.v,v 1.7.2.4 2008/07/17 12:59:17 pankajk Exp $
//-----------------------------------------------------------------------------
// line_buffer.v  
//-----------------------------------------------------------------------------
//
//  ***************************************************************************
//  **  Copyright(C) 2008 by Xilinx, Inc. All rights reserved.               **
//  **                                                                       **
//  **  This text contains proprietary, confidential                         **
//  **  information of Xilinx, Inc. , is distributed by                      **
//  **  under license from Xilinx, Inc., and may be used,                    **
//  **  copied and/or disclosed only pursuant to the terms                   **
//  **  of a valid license agreement with Xilinx, Inc.                       **
//  **                                                                       **
//  **  Unmodified source code is guaranteed to place and route,             **
//  **  function and run at speed according to the datasheet                 **
//  **  specification. Source code is provided "as-is", with no              **
//  **  obligation on the part of Xilinx to provide support.                 **
//  **                                                                       **
//  **  Xilinx Hotline support of source code IP shall only include          **
//  **  standard level Xilinx Hotline support, and will only address         **
//  **  issues and questions related to the standard released Netlist        **
//  **  version of the core (and thus indirectly, the original core source). **
//  **                                                                       **
//  **  The Xilinx Support Hotline does not have access to source            **
//  **  code and therefore cannot answer specific questions related          **
//  **  to source HDL. The Xilinx Support Hotline will only be able          **
//  **  to confirm the problem in the Netlist version of the core.           **
//  **                                                                       **
//  **  This copyright and support notice must be retained as part           **
//  **  of this text at all times.                                           **
//  ***************************************************************************
//
//-----------------------------------------------------------------------------
// Filename:        line_buffer.v
// Version:         v1.00a
// Description:     
//
//    -- This module contains 1 RAMB16_S18_S36 for line storage.
//    -- The RGB BRAMs hold one line of the 480 lines required for 640x480
//       resolution.
//    -- Data is written to the PORT B of the BRAM by the PLB bus.
//    -- Data is read from the  PORT A of the BRAM by the TFT 
//
//                                   
// Verilog-Standard: Verilog'2001
//-----------------------------------------------------------------------------
// Structure:   
//                  xps_tft.vhd
//                     -- plbv46_master_burst.vhd               
//                     -- plbv46_slave_single.vhd
//                     -- tft_controller.v
//                            -- line_buffer.v
//                            -- v_sync.v
//                            -- h_sync.v
//                            -- slave_register.v
//                            -- tft_interface.v
//                                -- iic_init.v
//-----------------------------------------------------------------------------
// Author:          PVK
// History:
//   PVK          06/10/08    First Version
// ^^^^^^
//        
//  TFT READ LOGIC    
//    -- BRAM_TFT_rd is generated two clock cycles early wrt DE      
//    -- BRAM_TFT_oe is generated one clock cycles early wrt DE
//    -- These two signals control the TFT side read from BRAM to HW
//  PLB WRITE LOGIC
//    -- BRAM Write Enables and Data are controlled by the tft_controller.v
//    -- module.  
// ~~~~~~~~
//-----------------------------------------------------------------------------
// Naming Conventions:
//      active low signals:                     "*_n"
//      clock signals:                          "clk", "clk_div#", "clk_#x" 
//      reset signals:                          "rst", "rst_n" 
//      parameters:                             "C_*" 
//      user defined types:                     "*_TYPE" 
//      state machine next state:               "*_ns" 
//      state machine current state:            "*_cs" 
//      combinatorial signals:                  "*_com" 
//      pipelined or register delay signals:    "*_d#" 
//      counter signals:                        "*cnt*"
//      clock enable signals:                   "*_ce" 
//      internal version of output port         "*_i"
//      device pins:                            "*_pin" 
//      ports:                                  - Names begin with Uppercase 
//      component instantiations:               "<MODULE>I_<#|FUNC>
//-----------------------------------------------------------------------------


///////////////////////////////////////////////////////////////////////////////
// Module Declaration
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps
module line_buffer_mod(


  // BRAM_TFT READ PORT A clock and reset
  TFT_Clk,           // TFT Clock 
  TFT_Rst,           // TFT Reset

  // PLB_BRAM WRITE PORT B clock and reset
  PLB_Clk,           // PLB Clock
  PLB_Rst,           // PLB Reset

  // BRAM_TFT READ Control
  BRAM_TFT_rd,       // TFT BRAM read   
  BRAM_TFT_oe,       // TFT BRAM output enable
	BRAM_rd_addr, 
	tc, 

  // PLB_BRAM Write Control
  PLB_BRAM_data,     // PLB BRAM Data
  PLB_BRAM_we,       // PLB BRAM write enable

  // RGB Outputs
  RED,               // TFT Red pixel data  
  GREEN,             // TFT Green pixel data  
  BLUE               // TFT Blue pixel data  
);
///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////

  input        TFT_Clk;
  input        TFT_Rst;
  input        PLB_Clk;
  input        PLB_Rst;
  input        BRAM_TFT_rd;
  input        BRAM_TFT_oe;
	input				 BRAM_rd_addr;
	input				 tc;
  input [0:63] PLB_BRAM_data;
  input        PLB_BRAM_we;
  output [5:0] RED,GREEN,BLUE;

///////////////////////////////////////////////////////////////////////////////
// Signal Declaration
///////////////////////////////////////////////////////////////////////////////
  
  wire [5:0]  BRAM_TFT_R_data;
  wire [5:0]  BRAM_TFT_G_data;
  wire [5:0]  BRAM_TFT_B_data;  
  reg  [0:9]  BRAM_TFT_addr;
  reg  [0:8]  BRAM_PLB_addr;
  //reg         tc;
  reg  [5:0]  RED,GREEN,BLUE;
/*
///////////////////////////////////////////////////////////////////////////////
// READ Logic BRAM Address Generator TFT Side
///////////////////////////////////////////////////////////////////////////////

  // BRAM_TFT_addr Counter (0-639d)
  always @(posedge TFT_Clk)
  begin : TFT_ADDR_CNTR
    if (TFT_Rst | ~BRAM_TFT_rd) 
      begin
        BRAM_TFT_addr = 10'b0;
        tc = 1'b0;
      end
    else 
      begin
        if (tc == 0) 
          begin
            if (BRAM_TFT_addr == 10'd639) 
              begin
                BRAM_TFT_addr = 10'b0;
                tc = 1'b1;
              end
            else 
              begin
                BRAM_TFT_addr = BRAM_TFT_addr + 1;
                tc = 1'b0;
              end
          end
      end
  end
*/
///////////////////////////////////////////////////////////////////////////////
// WRITE Logic for the BRAM PLB Side
///////////////////////////////////////////////////////////////////////////////

  // BRAM_PLB_addr Counter (0-319d)
  always @(posedge PLB_Clk)
  begin : PLB_ADDR_CNTR
    if (PLB_Rst) 
      begin
        BRAM_PLB_addr = 9'b0;
      end
    else 
      begin
        if (PLB_BRAM_we) 
          begin
            if (BRAM_PLB_addr == 9'd319) 
              begin
                BRAM_PLB_addr = 9'b0;
              end
            else 
              begin
                BRAM_PLB_addr = BRAM_PLB_addr + 1;
              end
          end
      end
  end

///////////////////////////////////////////////////////////////////////////////
// BRAM
///////////////////////////////////////////////////////////////////////////////
/*
RAMB16_S18_S36 LINE_BUFFER (
  // TFT Side Port A
  .ADDRA (BRAM_TFT_addr),                                           // I [9:0]
  .CLKA  (TFT_Clk),                                                 // I
  .DIA   (16'b0),                                                   // I [15:0]
  .DIPA  (2'b0),                                                    // I [1:0]
  .DOA   ({BRAM_TFT_R_data, BRAM_TFT_G_data, BRAM_TFT_B_data[5:2]}),// O [15:0]
  .DOPA  (BRAM_TFT_B_data[1:0]),                                    // O [1:0]
  .ENA   (BRAM_TFT_rd),                                             // I
  .SSRA  (TFT_Rst | ~BRAM_TFT_rd | tc),                             // I 
  .WEA   (1'b0),                                                    // I
  // PLB Side Port B
  .ADDRB (BRAM_PLB_addr),                                           // I [8:0]
  .CLKB  (PLB_Clk),                                                 // I
  .DIB   ({PLB_BRAM_data[40:45], PLB_BRAM_data[48:53], PLB_BRAM_data[56:59],
           PLB_BRAM_data[8:13],  PLB_BRAM_data[16:21], PLB_BRAM_data[24:27]}),
                                                                    // I [31:0]
  .DIPB  ({PLB_BRAM_data[60:61], PLB_BRAM_data[28:29]}),            // I [3:0]
  .DOB   (),                                                        // O [31:0]
  .DOPB  (),                                                        // O [3:0]
  .ENB   (PLB_BRAM_we),                                             // I
  .SSRB  (1'b0),                                                    // I
  .WEB   (PLB_BRAM_we)                                              // I
  );
*/
///////////////////////////////////////////////////////////////////////////////
// Register RGB BRAM output data
///////////////////////////////////////////////////////////////////////////////
  always @(posedge TFT_Clk)
  begin : BRAM_OUT_DATA 
    if (TFT_Rst)
      begin
        RED   = 6'b0;
        GREEN = 6'b0;
        BLUE  = 6'b0; 
      end
    else
      begin
        RED   = BRAM_TFT_R_data;
        GREEN = BRAM_TFT_G_data;
        BLUE  = BRAM_TFT_B_data;
      end
   end   

endmodule

