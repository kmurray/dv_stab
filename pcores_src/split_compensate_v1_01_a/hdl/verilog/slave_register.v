//-----------------------------------------------------------------------------
// $Id: slave_register.v,v 1.7.2.4 2008/07/17 12:59:17 pankajk Exp $
//-----------------------------------------------------------------------------
// slave_register.v   
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
// Filename:        slave_register.v
// Version:         v1.00a
// Description:     This module contains TFT control register and provides
//                  PLB or DCR interface to access those registers.
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
//   PVK           06/10/08    First Version
// ^^^^^^
//    --  Added PLB slave and DCR slave interface to access TFT Registers. 
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

`timescale 1 ps / 1 ps

///////////////////////////////////////////////////////////////////////////////
// Module Declaration
///////////////////////////////////////////////////////////////////////////////

module slave_register(
  // DCR BUS
  DCR_Clk,       // DCR clock
  DCR_Rst,       // DCR reset
  DCR_ABus,      // DCR Address bus
  DCR_Sl_DBus,   // DCR slave data bus
  DCR_Read,      // DCR read request
  DCR_Write,     // DCR write request
  Sl_DCRAck,     // Slave DCR data ack
  Sl_DCRDBus,    // Slave DCR data bus

  // PLB Slave Interface
  PLB_Clk,       // Slave Interface clock
  PLB_Rst,       // Slave Interface reset
  Bus2IP_Data,   // Bus to IP data bus
  Bus2IP_RdCE,   // Bus to IP read chip enable
  Bus2IP_WrCE,   // Bus to IP write chip enable
  Bus2IP_BE,     // Bus to IP byte enable
  IP2Bus_Data,   // IP to Bus data bus
  IP2Bus_RdAck,  // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,  // IP to Bus write transfer acknowledgement
  IP2Bus_Error,  // IP to Bus error response

  // Registers
  TFT_base_addr, // TFT Base Address reg    
  TFT_dps_reg,   // TFT display scan reg
  TFT_on_reg     // TFT display on reg
  );


///////////////////////////////////////////////////////////////////////////////
// Parameter Declarations
///////////////////////////////////////////////////////////////////////////////

  parameter integer C_DCR_SPLB_SLAVE_IF      = 1;          
  parameter         C_DCR_BASEADDR           = "0010000000";
  parameter         C_DEFAULT_TFT_BASE_ADDR  = "11110000000";
  parameter integer C_SLV_DWIDTH             = 32;
  parameter integer C_NUM_REG                = 4;

///////////////////////////////////////////////////////////////////////////////
// Port Declarations
/////////////////////////////////////////////////////////////////////////////// 

  input                         DCR_Clk;
  input                         DCR_Rst;
  input  [0:9]                  DCR_ABus;
  input  [0:31]                 DCR_Sl_DBus;
  input                         DCR_Read;
  input                         DCR_Write;
  output                        Sl_DCRAck;
  output [0:31]                 Sl_DCRDBus;
  input                         PLB_Clk;
  input                         PLB_Rst;
  input  [0 : C_SLV_DWIDTH-1]   Bus2IP_Data;
  input  [0 : C_NUM_REG-1]      Bus2IP_RdCE;
  input  [0 : C_NUM_REG-1]      Bus2IP_WrCE;
  input  [0 : C_SLV_DWIDTH/8-1] Bus2IP_BE;
  output [0 : C_SLV_DWIDTH-1]   IP2Bus_Data;
  output                        IP2Bus_RdAck;
  output                        IP2Bus_WrAck;
  output                        IP2Bus_Error;
  output [0:10]                 TFT_base_addr;
  output                        TFT_dps_reg;
  output                        TFT_on_reg;

///////////////////////////////////////////////////////////////////////////////
// Signal Declaration
///////////////////////////////////////////////////////////////////////////////
  reg                           TFT_dps_reg;
  reg                           TFT_on_reg;
  reg  [0:10]                   TFT_base_addr;
  reg  [0:C_SLV_DWIDTH-1]       IP2Bus_Data; 
  wire                          dcr_addr_hit;
  wire [0:9]                    dcr_base_addr;
  wire [0:31]                   Sl_DCRDBus;
  reg                           dcr_read_access;
  reg  [0:31]                   dcr_read_data;
  reg                           Sl_DCRAck;

///////////////////////////////////////////////////////////////////////////////
// TFT Register Interface 
///////////////////////////////////////////////////////////////////////////////
//---------------------
// Register         DCR  PLB  
//-- AR  - offset - 00 - 00
//-- CR  -        - 01 - 04
//-- Reserved     - 02 - 08
//-- Reserved     - 03 - 0C
//---------------------
//-- TFT Address Register(AR)
//-- BSR bits
//-- bit 0:10  - 11 MSB of Video Memory Address
//-- bit 11:31 - Undefined
//---------------------
//-- TFT Control Register(CR)
//-- BSR bits
//-- bit 0:29  - Undefined
//-- bit 30    - Display scan control bit
//-- bit 31    - TFT Display enable bit
///////////////////////////////////////////////////////////////////////////////
  initial  Sl_DCRAck = 1'b0;

  generate 
    if (C_DCR_SPLB_SLAVE_IF == 1)
      begin : gen_plb_if
 
      /////////////////////////////////////////////////////////////////////////
      // PLB Interface 
      /////////////////////////////////////////////////////////////////////////
        wire bus2ip_rdce_or;
        wire bus2ip_wrce_or;
        wire bus2ip_rdce_pulse;
        wire bus2ip_wrce_pulse;
        reg  bus2ip_rdce_d1;
        reg  bus2ip_rdce_d2;
        reg  bus2ip_wrce_d1;
        reg  bus2ip_wrce_d2;
        wire word_access; 
        wire Sl_DCRAck;
       
        // oring of bus2ip_rdce and wrce
        assign bus2ip_rdce_or = Bus2IP_RdCE[0] | Bus2IP_RdCE[1] | 
                                Bus2IP_RdCE[2] | Bus2IP_RdCE[3];

        assign bus2ip_wrce_or = Bus2IP_WrCE[0] | Bus2IP_WrCE[1] | 
                                Bus2IP_WrCE[2] | Bus2IP_WrCE[3];

        assign word_access    = (Bus2IP_BE == 4'b1111)? 1'b1 : 1'b0; 
        
        //---------------------------------------------------------------------
        //-- register combinational rdce 
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : REG_CE
          if (PLB_Rst)
            begin 
              bus2ip_rdce_d1 <= 1'b0; 
              bus2ip_rdce_d2 <= 1'b0;               
              bus2ip_wrce_d1 <= 1'b0; 
              bus2ip_wrce_d2 <= 1'b0;               
            end
          else 
            begin
              bus2ip_rdce_d1 <= bus2ip_rdce_or; 
              bus2ip_rdce_d2 <= bus2ip_rdce_d1;               
              bus2ip_wrce_d1 <= bus2ip_wrce_or; 
              bus2ip_wrce_d2 <= bus2ip_wrce_d1;               
            end
        end
           
        // generate pulse for bus2ip_rdce & bus2ip_wrce
        assign bus2ip_rdce_pulse = bus2ip_rdce_d1 & ~bus2ip_rdce_d2;
        assign bus2ip_wrce_pulse = bus2ip_wrce_d1 & ~bus2ip_wrce_d2;

        
        //---------------------------------------------------------------------
        //-- Generating the acknowledgement signals
        //---------------------------------------------------------------------
        assign IP2Bus_RdAck = bus2ip_rdce_pulse;
        
        assign IP2Bus_WrAck = bus2ip_wrce_pulse;
        
        assign IP2Bus_Error = ((bus2ip_rdce_pulse | bus2ip_wrce_pulse) && 
                                 (word_access == 1'b0))? 1'b1 : 1'b0;
        
        //---------------------------------------------------------------------
        //-- Writing to TFT Registers
        //---------------------------------------------------------------------
        // writing AR
        always @(posedge PLB_Clk)
        begin : WRITE_AR
          if (PLB_Rst)
            begin 
              TFT_base_addr <= C_DEFAULT_TFT_BASE_ADDR; 
            end
          else if (Bus2IP_WrCE[0] == 1'b1 & word_access == 1'b1)
            begin
              TFT_base_addr <= Bus2IP_Data[0:10];
            end
        end
        
        //---------------------------------------------------------------------
        // Writing CR
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : WRITE_CR
          if (PLB_Rst)
            begin 
              TFT_dps_reg   <= 1'b0; 
              TFT_on_reg    <= 1'b1; 
            end
          else if (Bus2IP_WrCE[1] == 1'b1 & word_access == 1'b1)
            begin
              TFT_dps_reg   <= Bus2IP_Data[30]; 
              TFT_on_reg    <= Bus2IP_Data[31]; 
            end
        end
        
        
        //---------------------------------------------------------------------
        //-- Reading from TFT Registers
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : READ_REG
          
          IP2Bus_Data[11:29] <= 19'b0;
          
          if (PLB_Rst | ~word_access ) 
            begin 
              IP2Bus_Data[0:10]  <= 11'b0;
              IP2Bus_Data[30:31] <= 2'b0;
            end
          else if (Bus2IP_RdCE[0] == 1'b1)
            begin
              IP2Bus_Data[0:10]  <= TFT_base_addr;
              IP2Bus_Data[30:31] <= 2'b0;
            end
          else if (Bus2IP_RdCE[1] == 1'b1)
            begin
              IP2Bus_Data[30]   <= TFT_dps_reg; 
              IP2Bus_Data[31]   <= TFT_on_reg;
              IP2Bus_Data[0:10] <= 11'b0;
            end
          else 
            begin
              IP2Bus_Data  <= 32'b0;
            end
        end

        
        // Drive Zero on DCR Output Ports
        assign Sl_DCRDBus = 32'b0; 		    
        assign Sl_DCRAck  = 1'b0; 

        
      end  // End generate PLB Interface
  
    else                                  // if DCR interface is selected
      begin : gen_dcr_if                  // C_DCR_SPLB_SLAVE_IF=0
      
        // Define the DCR interface signals
    
        ///////////////////////////////////////////////////////////////////////
        // DCR Interface 
        ///////////////////////////////////////////////////////////////////////
        assign dcr_base_addr = C_DCR_BASEADDR;
        assign dcr_addr_hit  = (DCR_ABus[0:7] == dcr_base_addr[0:7]);
        
        //---------------------------------------------------------------------
        //-- DCR control logic
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : DCR_CONTROL_LOG
          if (DCR_Rst)
            begin 
              dcr_read_access <= 1'b0;
              Sl_DCRAck       <= 1'b0;
            end
          else         
            begin 
              dcr_read_access <= DCR_Read               & dcr_addr_hit;
              Sl_DCRAck       <= (DCR_Read | DCR_Write) & dcr_addr_hit;
            end
        end
          
        

        //---------------------------------------------------------------------
        //-- Writing to TFT Registers
        //---------------------------------------------------------------------
        // writing AR
        always @(posedge DCR_Clk)
        begin : WRITE_AR
          if (DCR_Rst)
            TFT_base_addr <= C_DEFAULT_TFT_BASE_ADDR;
          else if (DCR_Write & ~Sl_DCRAck & dcr_addr_hit & 
                                                      (DCR_ABus[8:9] == 2'b00))
            TFT_base_addr <= DCR_Sl_DBus[0:10];
        end
        //---------------------------------------------------------------------
        // writing CR
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : WRITE_CR
          if (DCR_Rst) 
            begin
              TFT_dps_reg <= 1'b0;
              TFT_on_reg  <= 1'b1;
            end
          else if (DCR_Write & ~Sl_DCRAck & dcr_addr_hit & 
                                                (DCR_ABus[8:9] == 2'b01)) 
            begin
              TFT_dps_reg <= DCR_Sl_DBus[30];
              TFT_on_reg  <= DCR_Sl_DBus[31];
            end
        end
        
        //---------------------------------------------------------------------
        //-- Reading from TFT Registers
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : DCR_READ_DATA
          if (DCR_Read & dcr_addr_hit & ~Sl_DCRAck)
            dcr_read_data <= (DCR_ABus[8:9] == 2'b00)? {TFT_base_addr, 21'b0} :
                         (DCR_ABus[8:9] == 2'b01)? {30'b0, TFT_dps_reg, 
                                                              TFT_on_reg} : 
                                                   {32'b0} ;
        end
        
        assign Sl_DCRDBus = (dcr_read_access)? dcr_read_data : DCR_Sl_DBus;
        
     end // end DCR interface ;
      
  endgenerate // end generate     


endmodule
