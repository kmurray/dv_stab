//-----------------------------------------------------------------------------
// Filename:        tft_controller.vhd
// Version:         v1.00a
// Description:     This is top level file for TFT controller. 
//                  This module generate the read request to the Video memory.
//                  It also generates the write request on the line buffer to
//                  store video data line.
//
// Verilog-Standard:   Verilog'2001
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

///////////////////////////////////////////////////////////////////////////////
// Module Declaration
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps
module tft_controller(
                                           
  // Master Interface
  MPLB_Clk,                   // Master Interface clock 
  MPLB_Rst,                   // Master Interface reset
  IP2Bus_MstRd_Req,           // IP to Bus master read request
  IP2Bus_Mst_Addr,            // IP to Bus master address bus
  IP2Bus_Mst_BE,              // IP to Bus master byte enables
  IP2Bus_Mst_Length,          // IP to Bus master transfer length
  IP2Bus_Mst_Type,            // IP to Bus master transfer type
  IP2Bus_Mst_Lock,            // IP to Bus master lock
  IP2Bus_Mst_Reset,           // IP to Bus master reset
  Bus2IP_Mst_CmdAck,          // Bus to IP master command acknowledgement
  Bus2IP_Mst_Cmplt,           // Bus to IP master transfer completion
  Bus2IP_MstRd_d,             // Bus to IP master read data bus
  Bus2IP_MstRd_eof_n,         // Bus to IP master read end of frame
  Bus2IP_MstRd_src_rdy_n,     // Bus to IP master read source ready
  IP2Bus_MstRd_dst_rdy_n,     // IP to Bus master read destination ready
  IP2Bus_MstRd_dst_dsc_n      // IP to Bus master read destination discontinue
 
); 


// -- parameters definition 
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

// PLB Master signals 
input                              MPLB_Clk;
input                              MPLB_Rst;
output                             IP2Bus_MstRd_Req;
output    [0 : C_MST_AWIDTH-1]     IP2Bus_Mst_Addr;
output    [0 : C_MST_DWIDTH/8-1]   IP2Bus_Mst_BE;
output    [0 : 11]                 IP2Bus_Mst_Length;
output                             IP2Bus_Mst_Type;
output                             IP2Bus_Mst_Lock;
output                             IP2Bus_Mst_Reset;
input                              Bus2IP_Mst_CmdAck;
input                              Bus2IP_Mst_Cmplt;
input     [0 : C_MST_DWIDTH-1]     Bus2IP_MstRd_d;
input                              Bus2IP_MstRd_eof_n;
input                              Bus2IP_MstRd_src_rdy_n;
output                             IP2Bus_MstRd_dst_rdy_n;
output                             IP2Bus_MstRd_dst_dsc_n;

///////////////////////////////////////////////////////////////////////////////
// Implementation
///////////////////////////////////////////////////////////////////////////////

  // PLB_IF to RGB_BRAM  
  reg    [0:63]                    PLB_BRAM_data_i;
  reg                              PLB_BRAM_we_i;

  // HSYNC and VSYNC to TFT_IF
  wire                             HSYNC_i;
  wire                             VSYNC_i;

  // DE GENERATION
  wire                             H_DE_i;
  wire                             V_DE_i;
  wire                             DE_i;

  // RGB_BRAM to TFT_IF
  wire   [5:0]                     RED_i;
  wire   [5:0]                     GREEN_i;
  wire   [5:0]                     BLUE_i;
  wire                             I2C_done;

  // VSYNC RESET
  wire                             vsync_rst;

  // TFT READ FROM BRAM
  wire                             BRAM_TFT_rd;
  wire                             BRAM_TFT_oe;

  // Hsync|Vsync terminal counts                                   
  wire                             h_bp_cnt_tc;
  wire                             h_bp_cnt_tc2;  
  wire                             h_pix_cnt_tc;
  wire                             h_pix_cnt_tc2;
  reg    [0:4]                     trans_cnt;
  reg    [0:4]                     trans_cnt_i;
  wire                             trans_cnt_tc;
  reg    [0:8]                     line_cnt;
  reg    [0:8]                     line_cnt_i;
  wire                             line_cnt_ce;
  wire                             mn_request_set;
  wire                             trans_cnt_tc_pulse;
  wire                             mn_request;

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
  assign IP2Bus_MstRd_dst_rdy_n = ~IP2Bus_MstRd_dst_rdy;
  assign IP2Bus_MstRd_dst_dsc_n     = 1'b1;                             
  assign IP2Bus_Mst_Length          = 12'b000010000000;
  assign IP2Bus_Mst_BE              = 4'b0;   
  assign IP2Bus_Mst_Lock            = 1'b0;   
  assign IP2Bus_Mst_Reset           = ~tft_on_reg; 
  assign IP2Bus_Mst_Addr[0:10]      = tft_base_addr; 
  assign IP2Bus_Mst_Addr[11:19]     = line_cnt_i;
  assign IP2Bus_Mst_Addr[20:24]     = trans_cnt_i;
  assign IP2Bus_Mst_Addr[25:31]     = 7'b0000000; 
  assign mn_request_set = get_line;
  assign line_cnt_ce = 1'b1;
  assign get_line_start = 1'b1;    
 

  /////////////////////////////////////////////////////////////////////////////                                                   
  // REQUEST LOGIC for PLB 
  /////////////////////////////////////////////////////////////////////////////

  
  /////////////////////////////////
  // Generate Master read request 
  // for master burst interface
  /////////////////////////////////
  always @(posedge MPLB_Clk)
  begin : MST_REQ
    if (Bus2IP_Mst_CmdAck | master_rst) 
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
  always @(posedge MPLB_Clk)
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
  always @(posedge MPLB_Clk)
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
  always @(posedge MPLB_Clk)
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
                          

  /////////////////////////////////////////////////////////////////////////////
  // Generate PLB memory addresses
  /////////////////////////////////////////////////////////////////////////////    

  // load tft_base_addr from tft address register after completing 
  // the current frame only
  always @(posedge MPLB_Clk)
  begin : MST_BASE_ADDR_GEN
    if (master_rst) 
      begin
        tft_base_addr <= C_DEFAULT_TFT_BASE_ADDR;
      end
  end 

  // Load line counter and trans counter if the master request is set
  always @(posedge MPLB_Clk)
  begin : MST_LINE_ADDR_GEN
    if (master_rst) 
      begin 
        line_cnt_i      <= 9'b0;
      end  
    else if (mn_request_set) 
      begin
        line_cnt_i      <= line_cnt;
      end 
  end 

  /////////////////////////////////////////////////////////////////////////////
  // Line Counter - Counts 0-479 (d)  C_LINE_INIT
  /////////////////////////////////////////////////////////////////////////////      

  // Generate trans_count_tc 

  
  // Line_count counter.
  // Update the counter after every line is received 
  // from the master burst interface.
  always @(posedge MPLB_Clk)
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
  
  /////////////////////////////////////////////////////////////////////////////
  // Generate line buffer write enable signal and register the PLB data
  /////////////////////////////////////////////////////////////////////////////    
  always @(posedge MPLB_Clk)
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
  // Generate Get line start signal to fetch the video data from PLB attached
  // video memory
  /////////////////////////////////////////////////////////////////////////////
  // get line start logic
 
      
  // Synchronize the get line signal w.r.t. MPLB clock
  always @(posedge SYS_TFT_Clk)
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
  always @(posedge MPLB_Clk)
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
  // RGB_BRAM COMPONENT INSTANTIATION
  /////////////////////////////////////////////////////////////////////////////              
  line_buffer LINE_BUFFER_U4
    (
    .TFT_Clk(SYS_TFT_Clk),
    .TFT_Rst(tft_rst),
    .PLB_Clk(MPLB_Clk),
    .PLB_Rst(master_rst),
    .BRAM_TFT_rd(BRAM_TFT_rd), 
    .BRAM_TFT_oe(BRAM_TFT_oe), 
    .PLB_BRAM_data(PLB_BRAM_data_i),
    .PLB_BRAM_we(PLB_BRAM_we_i),
    .RED(RED_i),.GREEN(GREEN_i), .BLUE(BLUE_i)
  );              



endmodule
