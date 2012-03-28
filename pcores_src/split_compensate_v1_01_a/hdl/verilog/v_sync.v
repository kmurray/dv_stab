//-----------------------------------------------------------------------------
// $Id: v_sync.v,v 1.9.2.4 2008/07/17 12:59:17 pankajk Exp $
//-----------------------------------------------------------------------------
// v_sync.v   
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
// Filename:        v_sync.v
// Version:         v1.00a
// Description:     This is the VSYNC signal generator.  It generates
//                  the appropriate VSYNC signal for the target TFT display.
//                  The core of this module is a state machine that controls 
//                  4 counters and the VSYNC and V_DE signals.  
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
//   PVK           06/10/08    First Version
// ^^^^^^
//        
//         -- Input clock is (~HSYNC)
//         -- Input Rst is vsync_rst signal generated from the h_sync.v module.
//         -- V_DE and H_DE are used to generate DE signal for the TFT display.      
//         -- V_bp_cnt_tc and V_l_cnt_tc are the terminal count for the back 
//         -- porch time counter and Line time counter respectively and are 
//         -- used to generate get_line_start pulse.
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
module v_sync(
    Clk,          // Clock 
    Clk_stb,      // Hsync clock strobe
    Rst,          // Reset
    VSYNC,        // Vertical Sync output
    V_DE,         // Vertical Data enable
    V_bp_cnt_tc,  // Vertical back porch terminal count pulse
    V_l_cnt_tc);  // Vertical line terminal count pulse

///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
    input         Clk;
    input         Clk_stb;
    input         Rst;     
    output        VSYNC;
    output        V_DE;
    output        V_bp_cnt_tc;
    output        V_l_cnt_tc;

///////////////////////////////////////////////////////////////////////////////
// Signal Declaration
///////////////////////////////////////////////////////////////////////////////
    reg           V_DE;
    reg           VSYNC;
    reg   [0:1]   v_p_cnt;  // 2-bit counter (2   HSYNCs for pulse time)
    reg   [0:4]   v_bp_cnt; // 5-bit counter (31  HSYNCs for back porch time)
    reg   [0:8]   v_l_cnt;  // 9-bit counter (480 HSYNCs for line time)
    reg   [0:3]   v_fp_cnt; // 4-bit counter (12  HSYNCs for front porch time) 
    reg           v_p_cnt_clr;
    reg           v_bp_cnt_clr;
    reg           v_l_cnt_clr;
    reg           v_fp_cnt_clr;
    reg           v_p_cnt_tc;
    reg           V_bp_cnt_tc;
    reg           V_l_cnt_tc;
    reg           v_fp_cnt_tc;

///////////////////////////////////////////////////////////////////////////////
// VSYNC State Machine - State Declaration
///////////////////////////////////////////////////////////////////////////////

    parameter [0:4] SET_COUNTERS    = 5'b00001;
    parameter [0:4] PULSE           = 5'b00010;
    parameter [0:4] BACK_PORCH      = 5'b00100;
    parameter [0:4] LINE            = 5'b01000;
    parameter [0:4] FRONT_PORCH     = 5'b10000;     

    reg [0:4]       VSYNC_cs;
    reg [0:4]       VSYNC_ns;

///////////////////////////////////////////////////////////////////////////////
// clock enable State Machine - Sequential Block
///////////////////////////////////////////////////////////////////////////////

    reg clk_stb_d1;
    reg clk_ce_neg;
    reg clk_ce_pos;

    // posedge and negedge of clock strobe
    always @ (posedge Clk)
    begin : CLOCK_STRB_GEN
      clk_stb_d1 <=  Clk_stb;
      clk_ce_pos <=  Clk_stb & ~clk_stb_d1;
      clk_ce_neg <= ~Clk_stb & clk_stb_d1;
    end

///////////////////////////////////////////////////////////////////////////////
// VSYNC State Machine - Sequential Block
///////////////////////////////////////////////////////////////////////////////
    always @ (posedge Clk)
    begin : VSYNC_REG_STATE
      if (Rst) 
        VSYNC_cs = SET_COUNTERS;
      else if (clk_ce_pos) 
        VSYNC_cs = VSYNC_ns;
    end

///////////////////////////////////////////////////////////////////////////////
// VSYNC State Machine - Combinatorial Block 
///////////////////////////////////////////////////////////////////////////////
    always @ (VSYNC_cs or v_p_cnt_tc or V_bp_cnt_tc or V_l_cnt_tc or 
              v_fp_cnt_tc)
    begin : VSYNC_SM_CMB 
      case (VSYNC_cs)
        /////////////////////////////////////////////////////////////
        //      SET COUNTERS STATE
        // -- Clear and de-enable all counters on frame_start signal 
        /////////////////////////////////////////////////////////////
        SET_COUNTERS: begin
          v_p_cnt_clr  = 1;
          v_bp_cnt_clr = 1;
          v_l_cnt_clr  = 1;
          v_fp_cnt_clr = 1;
          VSYNC        = 1;
          V_DE         = 0;                               
          VSYNC_ns     = PULSE;
        end
        /////////////////////////////////////////////////////////////
        //      PULSE STATE
        // -- Enable pulse counter
        // -- De-enable others
        /////////////////////////////////////////////////////////////
        PULSE: begin
          v_p_cnt_clr  = 0;
          v_bp_cnt_clr = 1;
          v_l_cnt_clr  = 1;
          v_fp_cnt_clr = 1;
          VSYNC        = 0;
          V_DE         = 0;
          
          if (v_p_cnt_tc == 0) 
            VSYNC_ns = PULSE;                     
          else 
            VSYNC_ns = BACK_PORCH;
        end
        /////////////////////////////////////////////////////////////
        //      BACK PORCH STATE
        // -- Enable back porch counter
        // -- De-enable others
        /////////////////////////////////////////////////////////////
        BACK_PORCH: begin
          v_p_cnt_clr  = 1;
          v_bp_cnt_clr = 0;
          v_l_cnt_clr  = 1;
          v_fp_cnt_clr = 1;
          VSYNC        = 1;
          V_DE         = 0;                               
          
          if (V_bp_cnt_tc == 0) 
            VSYNC_ns = BACK_PORCH;                                                 
          else 
            VSYNC_ns = LINE;
        end
        /////////////////////////////////////////////////////////////
        //      LINE STATE
        // -- Enable line counter
        // -- De-enable others
        /////////////////////////////////////////////////////////////
        LINE: begin
          v_p_cnt_clr  = 1;
          v_bp_cnt_clr = 1;
          v_l_cnt_clr  = 0;
          v_fp_cnt_clr = 1;
          VSYNC        = 1;
          V_DE         = 1;  
          
          if (V_l_cnt_tc == 0) 
            VSYNC_ns = LINE;                                                      
          else 
            VSYNC_ns = FRONT_PORCH;
        end
        /////////////////////////////////////////////////////////////
        //      FRONT PORCH STATE
        // -- Enable front porch counter
        // -- De-enable others
        // -- Wraps to PULSE state
        /////////////////////////////////////////////////////////////
        FRONT_PORCH: begin
          v_p_cnt_clr  = 1;
          v_bp_cnt_clr = 1;
          v_l_cnt_clr  = 1;
          v_fp_cnt_clr = 0;
          VSYNC        = 1;
          V_DE         = 0;       
          
          if (v_fp_cnt_tc == 0) 
            VSYNC_ns = FRONT_PORCH;                                                
          else 
            VSYNC_ns = PULSE;
        end
        /////////////////////////////////////////////////////////////
        //      DEFAULT STATE
        /////////////////////////////////////////////////////////////
        // added coverage off to disable the coverage for default state
        // as state machine will never enter in defualt state while doing
        // verification. 
        // coverage off
        default: begin
          v_p_cnt_clr  = 1;
          v_bp_cnt_clr = 1;
          v_l_cnt_clr  = 1;
          v_fp_cnt_clr = 0;
          VSYNC        = 1;      
          V_DE         = 0;
          VSYNC_ns     = SET_COUNTERS;
        end
        // coverage on         
      endcase
    end

///////////////////////////////////////////////////////////////////////////////
//      Vertical Pulse Counter - Counts 2 clocks(~HSYNC) for pulse time                                                                                                                                 
///////////////////////////////////////////////////////////////////////////////
        always @(posedge Clk)
        begin : VSYNC_PULSE_CNTR
          if (Rst || v_p_cnt_clr ) 
            begin
              v_p_cnt = 2'b0;
              v_p_cnt_tc = 0;
            end
          else if (clk_ce_neg) 
            begin
              if (v_p_cnt == 1) 
                begin
                  v_p_cnt = v_p_cnt + 1;
                  v_p_cnt_tc = 1;
                end
              else 
                begin
                  v_p_cnt = v_p_cnt + 1;
                  v_p_cnt_tc = 0;
                end
            end
        end

///////////////////////////////////////////////////////////////////////////////
//      Vertical Back Porch Counter - Counts 31 clocks(~HSYNC) for pulse time                                                                   
///////////////////////////////////////////////////////////////////////////////
        always @(posedge Clk)
        begin : VSYNC_BP_CNTR
          if (Rst || v_bp_cnt_clr) 
            begin
              v_bp_cnt = 5'b0;
              V_bp_cnt_tc = 0;
            end
          else if (clk_ce_neg) 
            begin
              if (v_bp_cnt == 30)
                begin
                  v_bp_cnt = v_bp_cnt + 1;
                  V_bp_cnt_tc = 1;
                end
              else 
                begin
                  v_bp_cnt = v_bp_cnt + 1;
                  V_bp_cnt_tc = 0;
                end
            end
        end

///////////////////////////////////////////////////////////////////////////////
//      Vertical Line Counter - Counts 480 clocks(~HSYNC) for pulse time                                                                                                                                
///////////////////////////////////////////////////////////////////////////////                                                                                                                                 
        always @(posedge Clk)
        begin : VSYNC_LINE_CNTR
          if (Rst || v_l_cnt_clr) 
            begin
              v_l_cnt = 9'b0;
              V_l_cnt_tc = 0;
            end
          else if (clk_ce_neg) 
            begin
              if (v_l_cnt == 479) 
                begin
                  v_l_cnt = v_l_cnt + 1;
                  V_l_cnt_tc = 1;
                end
              else 
                begin
                  v_l_cnt = v_l_cnt + 1;
                  V_l_cnt_tc = 0;
                end
            end
        end

///////////////////////////////////////////////////////////////////////////////
//      Vertical Front Porch Counter - Counts 12 clocks(~HSYNC) for pulse time
///////////////////////////////////////////////////////////////////////////////
        always @(posedge Clk)
        begin : VSYNC_FP_CNTR
          if (Rst || v_fp_cnt_clr) 
            begin
              v_fp_cnt = 4'b0;
              v_fp_cnt_tc = 0;
            end
          else if (clk_ce_neg) 
            begin
              if (v_fp_cnt == 11) 
                begin
                  v_fp_cnt = v_fp_cnt + 1;
                  v_fp_cnt_tc = 1;
                end
              else 
                begin
                  v_fp_cnt = v_fp_cnt + 1;
                  v_fp_cnt_tc = 0;
                end
            end
        end
endmodule
