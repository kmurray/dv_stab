//-----------------------------------------------------------------------------
// $Id: iic_init.v,v 1.6.2.3 2008/07/17 12:59:17 pankajk Exp $
//-----------------------------------------------------------------------------
// iic_init.v   
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
// Filename:        iic_init.v
// Version:         v1.00a
// Description:     This module consists of logic to configur the Chrontel 
//                  CH-7301 DVI transmitter chip through I2C interface.
//
// Verilog-Standard: Verilog'2001
//-----------------------------------------------------------------------------
// Structure:   
//                  xps_tft.vhd
//                     -- plbv46_master_burst.vhd               
//                     -- plbv46_slave_single.vhd
//                     -- tft_controller.v
//                            -- tft_control.v
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
//    This module is included in the design only if DVI interface is selected.    
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
module iic_init( 
  Clk,                          // Clock input
  Reset_n,                      // Reset input
  SDA,                          // I2C data
  SCL,                          // I2C clock
  Done                          // I2C configuration done
  );

///////////////////////////////////////////////////////////////////////////////
// Parameter Declarations
///////////////////////////////////////////////////////////////////////////////
                 
parameter C_I2C_SLAVE_ADDR = "1110110";

parameter CLK_RATE_MHZ = 50,  
          SCK_PERIOD_US = 30, 
          TRANSITION_CYCLE = (CLK_RATE_MHZ * SCK_PERIOD_US) / 2,
          TRANSITION_CYCLE_MSB = 11;  


input  Clk;
input  Reset_n;
inout  SDA;
inout  SCL;
output Done;

  
          
localparam    IDLE           = 3'd0,
              INIT           = 3'd1,
              START          = 3'd2,
              CLK_FALL       = 3'd3,
              SETUP          = 3'd4,
              CLK_RISE       = 3'd5,
              WAIT           = 3'd6,
              START_BIT      = 1'b1,
              ACK            = 1'b1,
              WRITE          = 1'b0,
              REG_ADDR0      = 8'h49,
              REG_ADDR1      = 8'h21,
              REG_ADDR2      = 8'h33,
              REG_ADDR3      = 8'h34,
              REG_ADDR4      = 8'h36,
              DATA0          = 8'hC0,
              DATA1          = 8'h09,
              DATA2a         = 8'h06,
              DATA3a         = 8'h26,
              DATA4a         = 8'hA0,
              DATA2b         = 8'h08,
              DATA3b         = 8'h16,
              DATA4b         = 8'h60,
              STOP_BIT       = 1'b0,            
              SDA_BUFFER_MSB = 27; 
          
wire [6:0]    SLAVE_ADDR = C_I2C_SLAVE_ADDR ;
          

reg                          SDA_out; 
reg                          SCL_out;  
reg [TRANSITION_CYCLE_MSB:0] cycle_count;
reg [2:0]                    c_state;
reg [2:0]                    n_state;
reg                          Done;   
reg [2:0]                    write_count;
reg [31:0]                   bit_count;
reg [SDA_BUFFER_MSB:0]       SDA_BUFFER;
wire                         transition; 



// Generate I2C clock and data 
always @ (posedge Clk) 
begin : I2C_CLK_DATA
    if (~Reset_n || c_state == IDLE ) begin
        SDA_out <= 1'b1;
        SCL_out <= 1'b1;
    end
    else if (c_state == INIT && transition) begin 
        SDA_out <= 1'b0;
    end
    else if (c_state == SETUP) begin
        SDA_out <= SDA_BUFFER[SDA_BUFFER_MSB];
    end
    else if (c_state == CLK_RISE && cycle_count == TRANSITION_CYCLE/2 
                                 && bit_count == SDA_BUFFER_MSB) begin
        SDA_out <= 1'b1;
    end
    else if (c_state == CLK_FALL) begin
        SCL_out <= 1'b0;
    end
    
    else if (c_state == CLK_RISE) begin
        SCL_out <= 1'b1;
    end
end

assign SDA = SDA_out;
assign SCL = SCL_out;
                        

// Fill the SDA buffer 
always @ (posedge Clk) 
begin : SDA_BUF
  //reset or end condition
  if(~Reset_n) begin
    SDA_BUFFER  <= {SLAVE_ADDR,WRITE,ACK,REG_ADDR0,ACK,DATA0,ACK,STOP_BIT};
    cycle_count <= 0;
  end
  //setup sda for sck rise
  else if ( c_state==SETUP && cycle_count==TRANSITION_CYCLE)begin
    SDA_BUFFER <= {SDA_BUFFER[SDA_BUFFER_MSB-1:0],1'b0};
    cycle_count <= 0; 
  end
  //reset count at end of state
  else if ( cycle_count==TRANSITION_CYCLE)
    cycle_count <= 0; 
  //reset sda_buffer   
  else if (c_state==WAIT )begin
    case(write_count)
      0:SDA_BUFFER <= {SLAVE_ADDR,WRITE,ACK,REG_ADDR1,ACK,DATA1, ACK,STOP_BIT};
      1:SDA_BUFFER <= {SLAVE_ADDR,WRITE,ACK,REG_ADDR2,ACK,DATA2b,ACK,STOP_BIT};
      2:SDA_BUFFER <= {SLAVE_ADDR,WRITE,ACK,REG_ADDR3,ACK,DATA3b,ACK,STOP_BIT};
      3:SDA_BUFFER <= {SLAVE_ADDR,WRITE,ACK,REG_ADDR4,ACK,DATA4b,ACK,STOP_BIT};
    default: SDA_BUFFER <=28'dx;
    endcase 
    cycle_count <= cycle_count+1;
  end
  else
    cycle_count <= cycle_count+1;
end


// Generate write_count signal
always @ (posedge Clk)
begin : GEN_WRITE_CNT
 if(~Reset_n)
   write_count<=3'd0;
 else if (c_state == WAIT && cycle_count == TRANSITION_CYCLE)
   write_count <= write_count+1;
end    

// Transaction done signal                        
always @ (posedge Clk) 
begin : TRANS_DONE
    if(~Reset_n)
      Done <= 1'b0;
    else if (c_state == IDLE)
      Done <= 1'b1;
end
 
       
// Generate bit_count signal
always @ (posedge Clk) 
begin : BIT_CNT
    if(~Reset_n || (c_state == WAIT)) 
       bit_count <= 0;
    else if ( c_state == CLK_RISE && cycle_count == TRANSITION_CYCLE)
       bit_count <= bit_count+1;
end    

// Next state block
always @ (posedge Clk) 
begin : NEXT_STATE
    if(~Reset_n)
       c_state <= INIT;
    else 
       c_state <= n_state;
end    

// generate transition for I2C
assign transition = (cycle_count == TRANSITION_CYCLE); 
              
//Next state              
always @ (*) 
begin : I2C_SM_CMB
   case(c_state) 
       //////////////////////////////////////////////////////////////
       //  IDLE STATE
       //////////////////////////////////////////////////////////////
       IDLE: begin
          if(~Reset_n) n_state = INIT;
          else n_state = IDLE;
       end
       //////////////////////////////////////////////////////////////
       //  INIT STATE
       //////////////////////////////////////////////////////////////
       INIT: begin
          if (transition) n_state = START;
          else n_state = INIT;
       end
       //////////////////////////////////////////////////////////////
       //  START STATE
       //////////////////////////////////////////////////////////////
       START: begin
          if( transition) n_state = CLK_FALL;
          else n_state = START;
       end
       //////////////////////////////////////////////////////////////
       //  CLK_FALL STATE
       //////////////////////////////////////////////////////////////
       CLK_FALL: begin
          if( transition) n_state = SETUP;
          else n_state = CLK_FALL;
       end
       //////////////////////////////////////////////////////////////
       //  SETUP STATE
       //////////////////////////////////////////////////////////////
       SETUP: begin
          if( transition) n_state = CLK_RISE;
          else n_state = SETUP;
       end
       //////////////////////////////////////////////////////////////
       //  CLK_RISE STATE
       //////////////////////////////////////////////////////////////
       CLK_RISE: begin
          if( transition && bit_count == SDA_BUFFER_MSB) 
             n_state = WAIT;
          else if (transition )
             n_state = CLK_FALL;  
          else n_state = CLK_RISE;
       end  
       //////////////////////////////////////////////////////////////
       //  WAIT STATE
       //////////////////////////////////////////////////////////////
       WAIT: begin
          if((transition && write_count != 3'd4)) 
             n_state = INIT;
          else if (transition )
             n_state = IDLE;  
          else n_state = WAIT;
       end 
       default: n_state = IDLE;
     
   endcase
end


endmodule
