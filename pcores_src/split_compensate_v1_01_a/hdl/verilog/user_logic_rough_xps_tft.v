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


// Block Name:	      split/crop compensation block
// Written By:	      Charles (Chung Peng) Huang
// For:		      ECE532 Design Project Image Stabalization
// Version:           1.01.a
// Description:       User logic module.
// Date:              Wed Feb 15 13:13:48 2012 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------

module user_logic
(
  // -- ADD USER PORTS BELOW THIS LINE ---------------
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
  IP2Bus_MstRd_Req,               // IP to Bus master read request
  IP2Bus_MstWr_Req,               // IP to Bus master write request
  IP2Bus_Mst_Addr,                // IP to Bus master address bus
  IP2Bus_Mst_BE,                  // IP to Bus master byte enables
  IP2Bus_Mst_Length,              // IP to Bus master transfer length
  IP2Bus_Mst_Type,                // IP to Bus master transfer type
  IP2Bus_Mst_Lock,                // IP to Bus master lock
  IP2Bus_Mst_Reset,               // IP to Bus master reset
  Bus2IP_Mst_CmdAck,              // Bus to IP master command acknowledgement
  Bus2IP_Mst_Cmplt,               // Bus to IP master transfer completion
  Bus2IP_Mst_Error,               // Bus to IP master error response
  Bus2IP_Mst_Rearbitrate,         // Bus to IP master re-arbitrate
  Bus2IP_Mst_Cmd_Timeout,         // Bus to IP master command timeout
  Bus2IP_MstRd_d,                 // Bus to IP master read data bus
  Bus2IP_MstRd_rem,               // Bus to IP master read remainder
  Bus2IP_MstRd_sof_n,             // Bus to IP master read start of frame
  Bus2IP_MstRd_eof_n,             // Bus to IP master read end of frame
  Bus2IP_MstRd_src_rdy_n,         // Bus to IP master read source ready
  Bus2IP_MstRd_src_dsc_n,         // Bus to IP master read source discontinue
  IP2Bus_MstRd_dst_rdy_n,         // IP to Bus master read destination ready
  IP2Bus_MstRd_dst_dsc_n,         // IP to Bus master read destination discontinue
  IP2Bus_MstWr_d,                 // IP to Bus master write data bus
  IP2Bus_MstWr_rem,               // IP to Bus master write remainder
  IP2Bus_MstWr_sof_n,             // IP to Bus master write start of frame
  IP2Bus_MstWr_eof_n,             // IP to Bus master write end of frame
  IP2Bus_MstWr_src_rdy_n,         // IP to Bus master write source ready
  IP2Bus_MstWr_src_dsc_n,         // IP to Bus master write source discontinue
  Bus2IP_MstWr_dst_rdy_n,         // Bus to IP master write destination ready
  Bus2IP_MstWr_dst_dsc_n          // Bus to IP master write destination discontinue
  // -- DO NOT EDIT ABOVE THIS LINE ------------------
); // user_logic

// -- ADD USER PARAMETERS BELOW THIS LINE ------------

/*
// -- parameters definition from xps_tft for interface portion of this block
parameter  integer C_DCR_SPLB_SLAVE_IF      = 1;
parameter  integer C_TFT_INTERFACE          = 1;
parameter          C_I2C_SLAVE_ADDR         = "1110110";
parameter          C_DEFAULT_TFT_BASE_ADDR  = "11110000000";
parameter          C_DCR_BASEADDR           = "0010000000";
parameter          C_DCR_HIGHADDR           = "0010000001";
parameter  integer C_IOREG_STYLE            = 1;

parameter          C_FAMILY                 = "virtex5";
parameter  integer C_SLV_DWIDTH             = 32;
parameter  integer C_MST_AWIDTH             = 32;
parameter  integer C_MST_DWIDTH             = 64;
parameter  integer C_NUM_REG                = 4;
parameter  integer C_TRANS_INIT             = 19;
parameter  integer C_LINE_INIT              = 479;
*/
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_SLV_DWIDTH                   = 32;
parameter C_MST_AWIDTH                   = 32;
parameter C_MST_DWIDTH                   = 32;
parameter C_NUM_REG                      = 14;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
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
output                                    IP2Bus_MstRd_Req;
output                                    IP2Bus_MstWr_Req;
output     [0 : C_MST_AWIDTH-1]           IP2Bus_Mst_Addr;
output     [0 : C_MST_DWIDTH/8-1]         IP2Bus_Mst_BE;
output     [0 : 11]                       IP2Bus_Mst_Length;
output                                    IP2Bus_Mst_Type;
output                                    IP2Bus_Mst_Lock;
output                                    IP2Bus_Mst_Reset;
input                                     Bus2IP_Mst_CmdAck;
input                                     Bus2IP_Mst_Cmplt;
input                                     Bus2IP_Mst_Error;
input                                     Bus2IP_Mst_Rearbitrate;
input                                     Bus2IP_Mst_Cmd_Timeout;
input      [0 : C_MST_DWIDTH-1]           Bus2IP_MstRd_d;
input      [0 : C_MST_DWIDTH/8-1]         Bus2IP_MstRd_rem;
input                                     Bus2IP_MstRd_sof_n;
input                                     Bus2IP_MstRd_eof_n;
input                                     Bus2IP_MstRd_src_rdy_n;
input                                     Bus2IP_MstRd_src_dsc_n;
output                                    IP2Bus_MstRd_dst_rdy_n;
output                                    IP2Bus_MstRd_dst_dsc_n;
output     [0 : C_MST_DWIDTH-1]           IP2Bus_MstWr_d;
output     [0 : C_MST_DWIDTH/8-1]         IP2Bus_MstWr_rem;
output                                    IP2Bus_MstWr_sof_n;
output                                    IP2Bus_MstWr_eof_n;
output                                    IP2Bus_MstWr_src_rdy_n;
output                                    IP2Bus_MstWr_src_dsc_n;
input                                     Bus2IP_MstWr_dst_rdy_n;
input                                     Bus2IP_MstWr_dst_dsc_n;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------

  // --USER nets declarations added here, as needed for user logic

  // USER nets for function portion of the block

  wire				  clk_13;

  //Line Buffers
  reg                             r_write_buffer_0;
  wire                            w_read_buffer_0;
  wire                            w_write_buffer_0;
  wire                            w_read_buffer_1;
  wire                            w_write_buffer_1;
  reg     [10:0]                  r_line_buffer_write_addr;
  reg     [10:0]                  r_line_buffer_read_addr;   
  wire    [7:0]                   w_line_buffer_read_Red_0;
  wire    [7:0]                   w_line_buffer_read_Green_0;
  wire    [7:0]                   w_line_buffer_read_Blue_0;
  wire    [7:0]                   w_line_buffer_read_Red_1;
  wire    [7:0]                   w_line_buffer_read_Green_1;
  wire    [7:0]                   w_line_buffer_read_Blue_1;
  wire    [7:0]                   w_Red_to_buffer;
  wire    [7:0]                   w_Green_to_buffer;
  wire    [7:0]                   w_Blue_to_buffer;
  reg     [7:0]                   r_Red_from_buffer;
  reg     [7:0]                   r_Green_from_buffer;
  reg     [7:0]                   r_Blue_from_buffer;
  reg                             r_line_ready;
/*
  // USER nets from xps_tft for interface portion of this block
  reg                              PLB_BRAM_we_i;
  // DE GENERATION
  wire                             H_DE_i;
  wire                             V_DE_i;
  wire                             DE_i;
  // TFT READ FROM BRAM
  wire                             BRAM_TFT_rd;
  wire                             BRAM_TFT_oe;
  // get line pulse
  reg                              get_line;
  // TFT controller Registers
  wire   [0:10]                    tft_base_addr_i;
  reg    [0:10]                    tft_base_addr_d1;
  reg    [0:10]                    tft_base_addr_d2;
  reg    [0:10]                    tft_base_addr;
  reg                              tft_on_reg;
  wire                             tft_on_reg_i;
  // TFT control signals
  reg                              tft_on_reg_plb_d1;
  reg                              v_bp_cnt_tc_d1;
  reg                              v_bp_cnt_tc_d2;
  reg                              tft_on_reg_bram_d1;
  reg                              tft_on_reg_bram_d2;
  wire                             v_bp_cnt_tc;
  wire                             get_line_start;
  reg                              get_line_start_d1;
  reg                              get_line_start_d2;
  reg                              get_line_start_d3;
  wire                             v_l_cnt_tc;
  // TFT Reset signals                   
  wire                             tft_rst;
  reg                              tft_rst_d1;
  reg                              tft_rst_d2;
  // plb reset signals
  wire                             plb_rst_d1;
  wire                             plb_rst_d2;
  wire                             plb_rst_d3;
  wire                             plb_rst_d4;
  wire                             plb_rst_d5;
  wire                             plb_rst_d6;
  reg                              IP2Bus_MstRd_Req;
  reg                              IP2Bus_Mst_Type;
  reg                              IP2Bus_MstRd_dst_rdy;
  reg                              eof_n;
  reg                              trans_cnt_tc_pulse_i;
  wire                             eof_pulse;
  wire                             master_rst;
  // PLBv46 Master Interface signals
  assign IP2Bus_MstRd_dst_rdy_n	    = ~IP2Bus_MstRd_dst_rdy;
  assign IP2Bus_MstRd_dst_dsc_n     = 1'b1;
  assign IP2Bus_Mst_Length          = 12'b000010000000;
  assign IP2Bus_Mst_BE              = 4'b0;
  assign IP2Bus_Mst_Lock            = 1'b0;
  assign IP2Bus_Mst_Reset           = ~tft_on_reg;
  assign IP2Bus_Mst_Addr[0:10]      = tft_base_addr;
  assign IP2Bus_Mst_Addr[11:19]     = line_cnt_i;
  assign IP2Bus_Mst_Addr[20:24]     = trans_cnt_i;
*/
  // Nets for user logic slave model s/w accessible register example for function portion of block
  reg        [0 : C_SLV_DWIDTH-1]           on_off_reg;		//toggle split on/off
  reg        [0 : C_SLV_DWIDTH-1]           status_reg;		//status reg
  reg        [0 : C_SLV_DWIDTH-1]           control_reg;	//control reg
  reg        [0 : C_SLV_DWIDTH-1]           fr_addr_src_reg;	//fr source addr
  reg        [0 : C_SLV_DWIDTH-1]	    fr_addr_dest_reg;	//fr dest addr
  reg        [0 : C_SLV_DWIDTH-1]	    xoff_reg;		//x offset reg
  reg        [0 : C_SLV_DWIDTH-1]           yoff_reg;		//y offset reg
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg7;		//blank
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg8;		//blank
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg9;		//blank
  wire       [0 : 9]                        slv_reg_write_sel;
  wire       [0 : 9]                        slv_reg_read_sel;
  reg        [0 : C_SLV_DWIDTH-1]           slv_ip2bus_data;
  wire                                      slv_read_ack;
  wire                                      slv_write_ack;
  integer                                   byte_index, bit_index;

  // --USER logic implementation added here

// ----------------------------------------- start of the function logic ----------------------

// declare line_buffer to read from MPMC 
// will be within the split/compensate block interface portion next week


  /////////////////////////////////////////////////////////////////////////////
  // RGB_BRAM COMPONENT INSTANTIATION
  /////////////////////////////////////////////////////////////////////////////              

  LINE_BUFFER LB0
  (
    .read_clk        (Bus2IP_Clk),
    .read_address    (r_line_buffer_read_addr),
    .read_enable     (w_read_buffer_0),
    .read_red_data   (w_line_buffer_read_Red_0),
    .read_green_data (w_line_buffer_read_Green_0),
    .read_blue_data  (w_line_buffer_read_Blue_0),
 
    .write_clk        (clk_13),
    .write_address    (r_line_buffer_write_addr),
    .write_enable     (w_write_buffer_0),
    .write_red_data   (w_Red_to_buffer),
    .write_green_data (w_Green_to_buffer),
    .write_blue_data  (w_Blue_to_buffer)
  );



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
    slv_reg_write_sel = Bus2IP_WrCE[0:9],
    slv_reg_read_sel  = Bus2IP_RdCE[0:9],
    slv_write_ack     = Bus2IP_WrCE[0] || Bus2IP_WrCE[1] || Bus2IP_WrCE[2] || Bus2IP_WrCE[3] || Bus2IP_WrCE[4] || Bus2IP_WrCE[5] || Bus2IP_WrCE[6] || Bus2IP_WrCE[7] || Bus2IP_WrCE[8] || Bus2IP_WrCE[9],
    slv_read_ack      = Bus2IP_RdCE[0] || Bus2IP_RdCE[1] || Bus2IP_RdCE[2] || Bus2IP_RdCE[3] || Bus2IP_RdCE[4] || Bus2IP_RdCE[5] || Bus2IP_RdCE[6] || Bus2IP_RdCE[7] || Bus2IP_RdCE[8] || Bus2IP_RdCE[9];

  // implement slave model register(s)
  always @( posedge Bus2IP_Clk )
    begin: SLAVE_REG_WRITE_PROC

      if ( Bus2IP_Reset == 1 )
        begin
          on_off_reg <= 0;
          status_reg <= 0;
          control_reg <= 0;
          fr_addr_src_reg <= 0;
          fr_addr_dest_reg <= 0;
          xoff_reg <= 0;
          yoff_reg <= 0;
          slv_reg7 <= 0;
          slv_reg8 <= 0;
          slv_reg9 <= 0;
        end
      else
        case ( slv_reg_write_sel )
          10'b1000000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  on_off_reg[bit_index] <= Bus2IP_Data[bit_index];
          10'b0100000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  status_reg[bit_index] <= Bus2IP_Data[bit_index];
          10'b0010000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  control_reg[bit_index] <= Bus2IP_Data[bit_index];
          10'b0001000000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  fr_addr_src_reg[bit_index] <= Bus2IP_Data[bit_index];
          10'b0000100000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  fr_addr_dest_reg[bit_index] <= Bus2IP_Data[bit_index];
          10'b0000010000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  xoff_reg[bit_index] <= Bus2IP_Data[bit_index];
          10'b0000001000 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  yoff_reg[bit_index] <= Bus2IP_Data[bit_index];
          10'b0000000100 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg7[bit_index] <= Bus2IP_Data[bit_index];
          10'b0000000010 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg8[bit_index] <= Bus2IP_Data[bit_index];
          10'b0000000001 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg9[bit_index] <= Bus2IP_Data[bit_index];
          default : ;
        endcase

    end // SLAVE_REG_WRITE_PROC

  // implement slave model register read mux
  always @( slv_reg_read_sel or on_off_reg or status_reg or control_reg or fr_addr_src_reg or 
fr_addr_dest_reg or xoff_reg or yoff_reg or slv_reg7 or slv_reg8 or slv_reg9 )
    begin: SLAVE_REG_READ_PROC

      case ( slv_reg_read_sel )
        10'b1000000000 : slv_ip2bus_data <= on_off_reg;
        10'b0100000000 : slv_ip2bus_data <= status_reg;
        10'b0010000000 : slv_ip2bus_data <= control_reg;
        10'b0001000000 : slv_ip2bus_data <= fr_addr_src_reg;
        10'b0000100000 : slv_ip2bus_data <= fr_addr_dest_reg;
        10'b0000010000 : slv_ip2bus_data <= xoff_reg;
        10'b0000001000 : slv_ip2bus_data <= yoff_reg;
        10'b0000000100 : slv_ip2bus_data <= slv_reg7;
        10'b0000000010 : slv_ip2bus_data <= slv_reg8;
        10'b0000000001 : slv_ip2bus_data <= slv_reg9;
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


// ------------------------------------------ start of the interface logic ---------------------
  // 1) read from MPMC (similarly to xps_tft)
  // 2) modify the line with respect to information passed in from uB (vectors)
  // 3) after line is modified, place back into MPMC
  // 4) xps_tft will then read the modified line and output
  //
  // Will implement Double-Double buffering
  // If required to read and process in the same cycle, might need to implement double M-PLB

  //  +---------+
  //  |		|
  //  |	  fr 0	|
  //  |		|
  //  +---------+
  //  +---------+
  //  |         |
  //  |   fr 1	|
  //  |         |
  //  +---------+
  //  +---------+
  //  |         |
  //  |   fr 2	|
  //  |         |
  //  +---------+
  //  +---------+
  //  |         |
  //  |   fr 3	|
  //  |         |
  //  +---------+
  //  +---------+
  //  |         |
  //  |   fr 4	|
  //  |         |
  //  +---------+
  //  +---------+
  //  |         |
  //  |   fr 5	|
  //  |         |
  //  +---------+ 

  /////////////////////////////////////////////////////////////////////////////                                                   
  // REQUEST LOGIC for PLB 
  /////////////////////////////////////////////////////////////////////////////


/*
  assign mn_request_set = ((get_line & (trans_cnt == 0)) |
                           (Bus2IP_Mst_Cmplt & trans_cnt != 0));

  /////////////////////////////////
  // Generate Master read request 
  // for master burst interface
  /////////////////////////////////
  always @(posedge Bus2IP_Clk)
  begin : MST_REQ
    if (Bus2IP_Mst_CmdAck | master_rst | trans_cnt_tc_pulse)
      begin
        IP2Bus_MstRd_Req <= 1'b0;
      end
    else if (mn_request_set)
      begin
        IP2Bus_MstRd_Req <= 1'b1;
      end
   end

  /////////////////////////////////
  // Generate Master Type signal 
  // for master burst interface
  /////////////////////////////////
  always @(posedge Bus2IP_Clk)
  begin : MST_TYPE
    if (Bus2IP_Mst_CmdAck | master_rst)
      begin
        IP2Bus_Mst_Type <= 1'b0;
      end
    else if (mn_request_set)
      begin
        IP2Bus_Mst_Type <= 1'b1;
      end
   end

  //////////////////////////////////////////
  // Generate Master read destination ready 
  // for master burst interface
  //////////////////////////////////////////
  always @(posedge Bus2IP_Clk)
  begin : MST_DST_RDY
    if (master_rst | eof_pulse)
      begin
        IP2Bus_MstRd_dst_rdy <= 1'b0;
      end
    else if (mn_request_set)
      begin
        IP2Bus_MstRd_dst_rdy <= 1'b1;
      end
   end

  /////////////////////////////////////////////////////////////////////////////
  // Generate control signals for line count and trans count
  /////////////////////////////////////////////////////////////////////////////    
  // Generate end of frame from Master burst interface 
  always @(posedge Bus2IP_Clk)
  begin : EOF_GEN
    if (master_rst)
      begin
        eof_n <= 1'b1;
      end
    else
      begin
        eof_n <= Bus2IP_MstRd_eof_n;
      end
  end

  // Generate one shot pulse for end of frame  
  assign eof_pulse = ~eof_n & Bus2IP_MstRd_eof_n;


  // Registering trans_cnt_tc to generate one shot pulse 
  // for trans_counter terminal count  
  always @(posedge Bus2IP_Clk)
  begin : TRANS_CNT_TC
    if (master_rst)
      begin
        trans_cnt_tc_pulse_i <= 1'b0;
      end
    else
      begin
        trans_cnt_tc_pulse_i <= trans_cnt_tc;
      end
  end

  // Generate one shot pulse for trans_counter terminal count  
  assign trans_cnt_tc_pulse = trans_cnt_tc_pulse_i & ~trans_cnt_tc;

  /////////////////////////////////////////////////////////////////////////////
  // Generate PLB memory addresses
  /////////////////////////////////////////////////////////////////////////////    

  // load tft_base_addr from tft address register after completing 
  // the current frame only
  always @(posedge Bus2IP_Clk)
  begin : MST_BASE_ADDR_GEN
    if (master_rst)
      begin
        tft_base_addr <= C_DEFAULT_TFT_BASE_ADDR;
      end
    else if (v_bp_cnt_tc_d2)
      begin
        tft_base_addr <= tft_base_addr_d2;
      end
  end

  // Load line counter nad trans counter if the master request is set
  always @(posedge Bus2IP_Clk)
  begin : MST_LINE_ADDR_GEN
    if (master_rst)
      begin
        line_cnt_i      <= 9'b0;
        trans_cnt_i     <= 5'b0;
      end
    else if (mn_request_set)
      begin
        line_cnt_i      <= line_cnt;
        trans_cnt_i     <= trans_cnt;
      end
  end


  /////////////////////////////////////////////////////////////////////////////
  // Transaction Counter - Counts 0-19 (d) C_TRANS_INIT
  /////////////////////////////////////////////////////////////////////////////      

  // Generate trans_count_tc 
  assign trans_cnt_tc = (trans_cnt == C_TRANS_INIT);

  // Trans_count counter.
  // Update the counter after every 128 byte frame 
  // received from the master burst interface.
  always @(posedge Bus2IP_Clk)
  begin : TRANS_CNT
    if(master_rst)
      begin
        trans_cnt = 5'b0;
      end
    else if (eof_pulse)
      begin
        if (trans_cnt_tc)
          begin
            trans_cnt = 5'b0;
          end
        else
          begin
            trans_cnt = trans_cnt + 1;
          end
      end
  end

  /////////////////////////////////////////////////////////////////////////////
  // Line Counter - Counts 0-479 (d)  C_LINE_INIT
  /////////////////////////////////////////////////////////////////////////////      

  // Generate trans_count_tc 
  assign line_cnt_ce = trans_cnt_tc_pulse;

  // Line_count counter.
  // Update the counter after every line is received 
  // from the master burst interface.
  always @(posedge Bus2IP_Clk)
  begin : LINE_CNT
    if (master_rst)
      begin
        line_cnt = 9'b0;
      end
    else if (line_cnt_ce)
      begin
        if (line_cnt == C_LINE_INIT)
          begin
            line_cnt = 9'b0;
          end
        else
          begin
            line_cnt = line_cnt + 1;
          end
      end
  end

  // BRAM_TFT_rd and BRAM_TFT_oe start the read process. These are constant
  // signals through out a line read.  
  assign BRAM_TFT_rd = ((DE_i ^ h_bp_cnt_tc ^ h_bp_cnt_tc2 ) & V_DE_i);
  assign BRAM_TFT_oe = ((DE_i ^ h_bp_cnt_tc) & V_DE_i);

  /////////////////////////////////////////////////////////////////////////////
  // Generate line buffer write enable signal and register the PLB data
  /////////////////////////////////////////////////////////////////////////////    
  always @(posedge Bus2IP_Clk)
  begin : BRAM_DATA_WE
    if(master_rst)
      begin
        PLB_BRAM_data_i  <= 64'b0;
        PLB_BRAM_we_i    <= 1'b0;
      end
    else
      begin
        PLB_BRAM_data_i  <= Bus2IP_MstRd_d;
        PLB_BRAM_we_i    <= ~Bus2IP_MstRd_src_rdy_n;
      end
  end

  /////////////////////////////////////////////////////////////////////////////
  // Generate Get line start signal to fetch the video data from PLB  attached
  // video memory
  /////////////////////////////////////////////////////////////////////////////
  // get line start logic
  assign get_line_start = ((h_pix_cnt_tc && v_bp_cnt_tc) || // 1st get line
                           (h_pix_cnt_tc && DE_i) &&     // 2nd,3rd,...get line
                           (~v_l_cnt_tc));               // No get_line on last line      

  // Generate DE for HW
  assign DE_i = (H_DE_i & V_DE_i);


  // Synchronize the get line signal w.r.t. MPLB clock
  always @(posedge Bus2IP_Clk)
  begin : GET_LINE_START
    if (tft_rst)
      begin
        get_line_start_d1 <= 1'b0;
      end
    else
      begin
        get_line_start_d1 <= get_line_start;
      end
  end

  // Synchronize the get line signal w.r.t. MPLB clock
  always @(posedge Bus2IP_Clk)
  begin : GET_LINE_REG
    if (master_rst)
      begin
        get_line_start_d2 <= 1'b0;
        get_line_start_d3 <= 1'b0;
        get_line          <= 1'b0;
      end
    else
      begin
        get_line_start_d2 <= get_line_start_d1;
        get_line_start_d3 <= get_line_start_d2;
        get_line          <= get_line_start_d2 & ~get_line_start_d3;
      end
  end

  /////////////////////////////////////////////////////////////////////////////

  // Generate master interface reset from the MPLB reset
  assign master_rst = Bus2IP_Reset;

  /////////////////////////////////////////////////////////////////////////////
  // RGB_BRAM COMPONENT INSTANTIATION
  /////////////////////////////////////////////////////////////////////////////              
  line_buffer LINE_BUFFER_U4
    (
    .TFT_Clk(Bus2IP_Clk),
    .TFT_Rst(master_rst),
    .PLB_Clk(Bus2IP_Clk),
    .PLB_Rst(master_rst),
    .BRAM_TFT_rd(BRAM_TFT_rd),
    .BRAM_TFT_oe(BRAM_TFT_oe),
    .PLB_BRAM_data(PLB_BRAM_data_i),
    .PLB_BRAM_we(PLB_BRAM_we_i),
    .RED(RED_i),.GREEN(GREEN_i), .BLUE(BLUE_i)
  );
*/
endmodule



