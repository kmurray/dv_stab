`timescale 1ns / 1ps

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
  x_done,
  y_done,
  new_x_addr,
  new_y_addr,  
  
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

//FSM

localparam      C_STATE_BITS                            = 2;
localparam      [C_STATE_BITS-1:0]      INITIAL		      = 0,
																				H_ADDR_GEN	    = 1,
                                        V_ADDR_GEN	    = 2,
                                        DONE            = 3;

// -- MPMC READ parameters definition 
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


// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_SLV_DWIDTH                   = 32;
parameter C_MST_AWIDTH                   = 32;
parameter C_MST_DWIDTH                   = 32;
parameter C_NUM_REG                      = 14;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------

output			x_done;
output	      [9:0]	new_x_addr;

output			y_done;
output	      [31:0]	new_y_addr;

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

  reg				  			x_enable;
  reg				  			y_enable;
  reg				  			done_pixel;
  reg				  			done_line;
  reg				  			done_frame;  
  reg	  [10:0]		  y_line_cnt;
  reg	  [9:0]			  x_pixel_cnt;

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

//FSM
    
  reg	  [C_STATE_BITS-1:0] curr_state;
  reg	  [C_STATE_BITS-1:0] next_state;

// Nets for user logic slave model s/w accessible register example for function portion of block
  reg        [0 : C_SLV_DWIDTH-1]           on_off_reg;		//toggle split on/off
  reg        [0 : C_SLV_DWIDTH-1]           status_reg;		//status reg
  reg        [0 : C_SLV_DWIDTH-1]           control_reg;	//control reg
  reg        [0 : C_SLV_DWIDTH-1]           fr_addr_src_reg;	//fr source addr
  reg        [0 : C_SLV_DWIDTH-1]	    fr_addr_dest_reg;	//fr dest addr
  reg        [0 : C_SLV_DWIDTH-1]	    xoff_reg;		//x offset reg
  reg        [0 : C_SLV_DWIDTH-1]           yoff_reg;		//y offset reg
  reg        [0 : C_SLV_DWIDTH-1]           x_dir_reg;		//direction of movement
								// 0 = left/up, 1 = right/down
  reg        [0 : C_SLV_DWIDTH-1]           y_dir_reg;		//blank
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg9;		//blank
  wire       [0 : 9]                        slv_reg_write_sel;
  wire       [0 : 9]                        slv_reg_read_sel;
  reg        [0 : C_SLV_DWIDTH-1]           slv_ip2bus_data;
  wire                                      slv_read_ack;
  wire                                      slv_write_ack;
  integer                                   byte_index, bit_index;

// -------------------------------READ MPMC-------------------------------

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

// set the initial value for reset 
  initial tft_rst_d1 = 1'b1;
  initial tft_rst_d2 = 1'b1;
  
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

// -- NEED TO IMPLEMENT READ FROM uB -- implement slave model register(s)
  always @( posedge Bus2IP_Clk )
    begin: SLAVE_REG_WRITE_PROC
      if ( Bus2IP_Reset == 1 )
        begin
          on_off_reg <= 0;
          status_reg <= 0;
          control_reg <= 0;
          fr_addr_src_reg <= 0;
          fr_addr_dest_reg <= 0;
					//Charles hardcoded these 4 values for testing
          xoff_reg <= 2'b10;
          yoff_reg <= 2'b10;
          x_dir_reg <= 1'b1;
          y_dir_reg <= 1'b0;
          slv_reg9 <= 0;
        end
      else
        case ( slv_reg_write_sel )
          default : ;
        endcase
    end // SLAVE_REG_WRITE_PROC

// --USER logic implementation added here

// ----------------------------------------- start of the function logic ----------------------


// FSM next state logic

    always @ (*)
    begin
      case(curr_state)
	INITIAL:
	begin
	  done_pixel <= 0;
	  next_state <= H_ADDR_GEN;
	end
        H_ADDR_GEN:
        begin
          if (x_done == 1)
          begin
            next_state <= V_ADDR_GEN;
          end
          else
          begin
            next_state <= H_ADDR_GEN;
          end
        end 
        V_ADDR_GEN:
        begin
          if (y_done == 1)
          begin
            next_state <= DONE;
          end
          else
          begin
            next_state <= V_ADDR_GEN;
          end
        end
        DONE:
        begin
	  if ((x_done && y_done) == 1)
	  begin 
	    done_pixel <= 1;
	    next_state <= INITIAL;
	  end
	  else 
	  begin
	    next_state <= INITIAL;
	  end
        end
        default:
        begin
          next_state <= INITIAL;
        end
      endcase
    end

// pixel counter

    //x-direction pixel counter
    always @ (posedge Bus2IP_Clk)
    begin
      //Reset on reset or a new line
      if(!Bus2IP_Reset || done_line)
      begin
	x_pixel_cnt <= 0;
	done_line <= 0;
      end
      // reset counter next cycle if at 1023 
      else if (x_pixel_cnt == 1022 && done_pixel == 1)
      begin
	x_pixel_cnt <= x_pixel_cnt + 1;
	done_line <= 1;
      end
      else if (done_pixel == 1)
      begin
	x_pixel_cnt <= x_pixel_cnt + 1;
      end
      else
      begin
      end
    end 

// line counter

    always @ (posedge Bus2IP_Clk) 
    begin
      //Reset on reset or new line
      if(!Bus2IP_Reset || done_frame)
      begin
	y_line_cnt <= 0;
	done_frame <= 0;
      end
      // reset counter next cycle if at 511
      else if (y_line_cnt == 511 && done_line == 1)
      begin
	y_line_cnt <= y_line_cnt + 1;
	done_frame <= 1;
      end
      else if (done_line == 1)
      begin
	y_line_cnt <= y_line_cnt + 1;
      end
      else
      begin
      end
    end

// combinational outputs based on FSM state

// FSM state update

    always @ (posedge Bus2IP_Clk)
    begin
      if (!Bus2IP_Reset)
      begin
        curr_state <= INITIAL;
      end
      else
      begin
        curr_state <= next_state;
      end
    end


  /////////////////////////////////////////////////////////////////////////////
  // MODULE DECLARATIONS
  ///////////////////////////////////////////////////////////////////////////// 

// declare two sub modules which calcualte the new address from the xoff and yoff registers
// output is new address from horiztonal and veritcal shifts
// xoff_reg and y_off_reg are slaves of uB

  H_ADDR_GEN H_ADDR_GEN_inst (

    .i_clk	(Bus2IP_Clk),
    .i_rst	(Bus2IP_Reset),
    .i_x_enable	(x_enable),
    .i_old_addr	(r_line_buffer_write_addr),
    .i_x_off	(xoff_reg),
    .i_dir	(x_dir_reg),
    .i_x_cnt	(x_pixel_cnt),
    .i_y_cnt	(y_line_cnt),
    .o_x_done	(x_done),
    .o_new_addr	(new_x_addr)
  );

  V_ADDR_GEN V_ADDR_GEN_inst (

    .i_clk	(Bus2IP_Clk),
    .i_rst	(Bus2IP_Reset),
    .i_y_enable	(y_enable),
    .i_old_addr (r_line_buffer_write_addr),
    .i_y_off	(yoff_reg),
    .i_dir	(y_dir_reg),
    .i_x_cnt	(x_pixel_cnt),
    .i_y_cnt	(y_line_cnt),
    .o_y_done	(y_done),
    .o_new_addr	(new_y_addr)
  );

// declare line_buffer to read from MPMC 
// will be within the split/compensate block interface portion next week

  /////////////////////////////////////////////////////////////////////////////
  // RGB_BRAM COMPONENT INSTANTIATION
  ///////////////////////////////////////////////////////////////////////////// 
             
  LINE_BUFFER LINE_BUFFER_inst
(
    .read_clk        (Bus2IP_Clk),
    .read_address    (r_line_buffer_read_addr),
    .read_enable     (w_read_buffer_0),
    .read_red_data   (w_line_buffer_read_Red_0),
    .read_green_data (w_line_buffer_read_Green_0),
    .read_blue_data  (w_line_buffer_read_Blue_0),
 
    .write_clk        (Bus2IP_Clk),
    .write_address    (r_line_buffer_write_addr),
    .write_enable     (w_write_buffer_0),
    .write_red_data   (w_Red_to_buffer),
    .write_green_data (w_Green_to_buffer),
    .write_blue_data  (w_Blue_to_buffer)
  );
/*
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
    slv_write_ack     = Bus2IP_WrCE[0] || Bus2IP_WrCE[1] || Bus2IP_WrCE[2] || Bus2IP_WrCE[3] || 
			Bus2IP_WrCE[4] || Bus2IP_WrCE[5] || Bus2IP_WrCE[6] || Bus2IP_WrCE[7] || 
			Bus2IP_WrCE[8] || Bus2IP_WrCE[9],
    slv_read_ack      = Bus2IP_RdCE[0] || Bus2IP_RdCE[1] || Bus2IP_RdCE[2] || Bus2IP_RdCE[3] || 
			Bus2IP_RdCE[4] || Bus2IP_RdCE[5] || Bus2IP_RdCE[6] || Bus2IP_RdCE[7] || 
			Bus2IP_RdCE[8] || Bus2IP_RdCE[9];

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
//Charles hardcoded these 4 values for testing
          xoff_reg <= 2'b10;
          yoff_reg <= 2'b10;
          x_dir_reg <= 1'b1;
          y_dir_reg <= 1'b0;
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
                  x_dir_reg[bit_index] <= Bus2IP_Data[bit_index];
          10'b0000000010 :
            for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  y_dir_reg[bit_index] <= Bus2IP_Data[bit_index];
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
fr_addr_dest_reg or xoff_reg or yoff_reg or x_dir_reg or y_dir_reg or slv_reg9 )
    begin: SLAVE_REG_READ_PROC

      case ( slv_reg_read_sel )
        10'b1000000000 : slv_ip2bus_data <= on_off_reg;
        10'b0100000000 : slv_ip2bus_data <= status_reg;
        10'b0010000000 : slv_ip2bus_data <= control_reg;
        10'b0001000000 : slv_ip2bus_data <= fr_addr_src_reg;
        10'b0000100000 : slv_ip2bus_data <= fr_addr_dest_reg;
        10'b0000010000 : slv_ip2bus_data <= xoff_reg;
        10'b0000001000 : slv_ip2bus_data <= yoff_reg;
        10'b0000000100 : slv_ip2bus_data <= x_dir_reg;
        10'b0000000010 : slv_ip2bus_data <= y_dir_reg;
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

*/
endmodule

