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

	////////////////////////////////////////////////////////////
	//////////////////////////  PRE-COMPILER FUNCTIONS /////////
	////////////////////////////////////////////////////////////

    function integer CLogB2;
        input [31:0] Depth;
        integer i;

        begin
            i = Depth;      
            for(CLogB2 = 0; i > 0; CLogB2 = CLogB2 + 1)
            begin
                i = i >> 1;
            end
        end
    endfunction

////////////////////////////////////////////////////////////////////////////
// -- ADD USER PARAMETERS BELOW THIS LINE ------------
////////////////////////////////////////////////////////////////////////////

// -------------------- FUNCTION FSM0 DEFINITIONS 

localparam      C_STATE_BITS                          = 2;
localparam      [C_STATE_BITS-1:0]      INITIAL	      = 0,  					  
					H_ADDR_GEN    = 1,
					V_ADDR_GEN    = 2,
                                        DONE          = 3;

// -------------------- FUNCTION FSM1 DEFINITIONS

localparam C_STATE_BITS_FSM_1 = 4;
localparam [C_STATE_BITS_FSM_1-1:0]	S_IDLE = 0,		    // 
					S_START_FRAME = 1,	    // lock, start burst
					S_RD_REQUEST = 2,	    // Set MstAddr, Rd_Req; Wait for CmdAck
					S_RD_TRANSFER = 3,	    // Wait for MstCmplt
					S_BURST_LINE_RD_COMPLETE = 4,
					S_WR_REQUEST = 5,	    // Set MstAddr, Wr_Req; Wait for CmdAck
					S_WR_TRANSFER = 6,	    // Wait for MstCmplt
					S_BURST_LINE_WR_COMPLETE = 7,
					S_BURST_FRAME_COMPLETE = 8, // Add burst address, restart if not finished
					S_DONE = 9;		    // set line_done signals

// -------------------- PLB BURST MODE DEFINITIONS 

// Inherited From MPD file
parameter C_VIDEO_RAM_BASEADDR	= 32'h41000000; //32'h3FFEA000;//32'h3FFF9000; 32'h40000000; 32'h3FFF0000;
parameter C_BYTES_PER_LINE	= 2560;
parameter C_PLBV46_DWIDTH	= 64;

// Local
localparam    C_BE_BITS           	= (C_PLBV46_DWIDTH / 8);	
localparam    C_BURST_LENGTH		= 16;	// Always write 16 times per request (maximum per burst)
localparam    C_BYTES_PER_BURST		= C_BURST_LENGTH * 4;
localparam    C_LINES_PER_FRAME		= 480;
localparam    C_LINE_CNT_BITS		= CLogB2(C_LINES_PER_FRAME);
localparam    C_PIXELS_PER_LINE		= 640;

// there will be 40 bursts / line... ie...640 / 16 = 40
localparam    C_BURSTS_PER_LINE 	= C_PIXELS_PER_LINE / C_BURST_LENGTH;

// there will be 19200 bursts / frame... ie... 40 * 480 = 19200
localparam    C_BURSTS_PER_FRAME	= (C_PIXELS_PER_LINE / C_BURST_LENGTH) * 480;
localparam    C_BURST_CNT_BITS		= CLogB2(C_BURSTS_PER_LINE);

// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_SLV_DWIDTH                   = 32;
parameter C_MST_AWIDTH                   = 32;
parameter C_MST_DWIDTH                   = 32;
parameter C_NUM_REG                      = 14;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

///////////////////////////////////////////////////////////////////////
// -- ADD USER PORTS BELOW THIS LINE -----------------
//////////////////////////////////////////////////////////////////////

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


///////////////////////////////////////////////////////////////////////////////
//// --USER nets declarations added here, as needed for user logic
////////////////////////////////////////////////////////////////////////////////
//// USER nets for function portion of the block
//////////////////////////////////////////////////////////////////////////////

  reg				  x_enable;
  reg				  y_enable;
  reg				  done_pixel;
  reg				  done_line;
  reg				  done_frame;  
  reg	  [10:0]		  y_line_cnt;
  reg	  [9:0]			  x_pixel_cnt;
  
  reg				  new_line_in;
  reg				  new_frame_in;
  reg				  line_burst_done;

  reg	  [5:0]			  line_burst_rd_cnt;
  reg	  [5:0]			  line_burst_wr_cnt;
  reg	  [15:0]		  frame_burst_cnt;
  reg	  [31:0]		  burst_addr;
  
// line buffer0 write and read addresses
  reg	  [10:0]		  lb_wr_addr0;
  wire	  [10:0]		  lb_rd_addr0;

// line buffer0 write and read enable signals
  reg				  lb_wr_e0;
  reg				  lb_rd_e0;

// rgb values to line buffer0
  wire	  [7:0]			  red_to_lb0;
  wire	  [7:0]			  green_to_lb0;
  wire	  [7:0]			  blue_to_lb0;

// rgb values from line buffer0
  wire	  [7:0]			  red_from_lb0;
  wire	  [7:0]			  green_from_lb0;
  wire	  [7:0]			  blue_from_lb0;

// line buffer1 write and read addresses
  wire    [10:0]		  lb_wr_addr1;
  reg	  [10:0]		  lb_rd_addr1;

// line buffer1 write and read enable signals
  reg				  lb_wr_e1;
  reg				  lb_rd_e1;

// rgb values to line buffer1
  wire	  [7:0]			  red_to_lb1;
  wire	  [7:0]			  green_to_lb1;
  wire	  [7:0]			  blue_to_lb1;

// gb values from line buffer1
  wire	  [7:0]			  red_from_lb1;
  wire	  [7:0]			  green_from_lb1;
  wire	  [7:0]			  blue_from_lb1;

  reg	  [3:0]			  wr_sof_eof_cnt;
//FSM0
    
  reg	  [C_STATE_BITS-1:0] curr_state;
  reg	  [C_STATE_BITS-1:0] next_state;

//FSM1

  reg	  [C_STATE_BITS_FSM_1-1:0] curr_state_1;
  reg	  [C_STATE_BITS_FSM_1-1:0] next_state_1;

// bypass reg

  reg	  [31:0]		    bypass;

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

/////////////////////////////////////////////////////////////////////////////
///////////////////////        ASSIGNMENTS
////////////////////////////////////////////////////////////////////////////

// --USER logic implementation added here

// -------------------------------- start of the function logic ----------------------

// ----- START OF FUNCTION LOGIC ----------------

// FSM0 next state logic

    always @ (*)
    begin
      case(curr_state)
	INITIAL:
	begin
	  done_pixel <= 0;
	  // must wait for line buffer finished loading until start FSM0
	  if (line_burst_done == 1 && x_pixel_cnt != 640)
	  begin
	    next_state <= H_ADDR_GEN;
	  end
	  else if (x_pixel_cnt == 640)
	  begin
	    next_state <= DONE;
	  end
	  else
	  begin
	    next_state <= INITIAL;
	  end
	end
        H_ADDR_GEN:
        begin
          if (x_done == 1 && x_pixel_cnt == 639)
          begin
            next_state <= V_ADDR_GEN;
          end
	  else if (x_done == 1 && x_pixel_cnt != 639)
	  begin
	    next_state <= DONE;
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
	  if ((x_done || y_done) == 1)
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

// FSM1 Next State Logic

    always @ (*)
    begin
      case(curr_state_1)
	S_IDLE:
	begin
	  if (on_off_reg == 1)
	  begin
	    next_state_1 <= S_START_FRAME;
	  end
	  else
	  begin
	    next_state_1 <= S_IDLE;
	  end
	end
	S_START_FRAME:
	begin
	  next_state_1 <= S_RD_REQUEST;
	end
	S_RD_REQUEST:
	begin
	  if (Bus2IP_Mst_CmdAck)
	  begin
	    next_state_1 <= S_RD_TRANSFER; 
	  end
	  else
	  begin
	    next_state_1 <= S_RD_REQUEST;
	  end
	end
	S_RD_TRANSFER:
	begin
	  if(Bus2IP_Mst_Cmplt)
	  begin
	    next_state_1 <= S_BURST_LINE_RD_COMPLETE;
	  end
	  else
	  begin
	    next_state_1 <= S_RD_TRANSFER;
	  end
	end
	S_BURST_LINE_RD_COMPLETE:
	begin
	  if ((line_burst_rd_cnt == 0 || line_burst_rd_cnt == 40) && done_line == 0)
	  begin
	    next_state_1 <= S_BURST_LINE_RD_COMPLETE;
	  end
	  else if (line_burst_rd_cnt == 0 && done_line == 1)
	  begin
	    next_state_1 <= S_WR_REQUEST;
	  end
	  else
	  begin
	    next_state_1 <= S_RD_REQUEST;
	  end
	end
	S_WR_REQUEST:
	begin
	  if (Bus2IP_Mst_CmdAck)
	  begin
	    next_state_1 <= S_WR_TRANSFER;
	  end
	  else
	  begin
	    next_state_1 <= S_WR_REQUEST;
	  end
	end
	S_WR_TRANSFER:
	begin
	  if(Bus2IP_Mst_Cmplt)
	  begin
	    next_state_1 <= S_BURST_LINE_WR_COMPLETE;
	  end
	  else
	  begin
	    next_state_1 <= S_WR_TRANSFER;
	  end
	end
	S_BURST_LINE_WR_COMPLETE:
	begin
	  if(line_burst_wr_cnt == 0)
	  begin
	    next_state_1 <= S_BURST_FRAME_COMPLETE;
	  end
	  else
	  begin
	    next_state_1 <= S_WR_REQUEST;
	  end
	end
	S_BURST_FRAME_COMPLETE:
	begin
	  if(frame_burst_cnt == 0)
	  begin
	    next_state_1 <= S_DONE;
	  end
	  else
	  begin
	    next_state_1 <= S_START_FRAME;
	  end
	end
	S_DONE:
	begin
	    next_state_1 <= S_IDLE;
	end
	default:
	begin
	  next_state_1 <= S_IDLE;
	end
      endcase
    end


// bypass

    always @ (posedge Bus2IP_Clk)
    begin
      if (Bus2IP_Reset)
      begin
    	bypass <= 0;
      end
      else if (curr_state_1 == S_START_FRAME && bypass < 10'd100)
      begin
	    bypass <= bypass + 1;
      end
      else if (curr_state_1 == S_RD_REQUEST && bypass < 10'd100)
      begin
    	bypass <= bypass + 1;
      end
      else if (bypass == 10'd100)
      begin
	    bypass <= fr_addr_src_reg;
      end
      else if ((curr_state_1 == S_BURST_LINE_RD_COMPLETE) && (line_burst_rd_cnt == 0))
      begin
        bypass <= burst_addr + 21'd64 + 21'd1536;
      end
    end

// pixel counter

    //x-direction pixel counter
    always @ (posedge Bus2IP_Clk)
    begin
      //Reset on reset or a new line
      if(Bus2IP_Reset)
      begin
	    x_pixel_cnt <= 0;
	    done_line <= 0;
      end
      else if (curr_state_1 == S_WR_REQUEST)
      begin
        done_line <= 0;
      end
      else if (done_line == 1)
      begin
	    x_pixel_cnt <= 0;
      end
      // reset counter next cycle if at 639 
      else if (x_pixel_cnt == 639 && done_pixel == 1)
      begin
	    x_pixel_cnt <= x_pixel_cnt + 1;
      end
      else if (x_pixel_cnt == 640)
      begin
	    done_line <= 1;
      end
      else if (done_pixel == 1)
      begin
	    x_pixel_cnt <= x_pixel_cnt + 1;
      end
    end 

// line counter

    always @ (posedge Bus2IP_Clk) 
    begin
      //Reset on reset or new line
      if(Bus2IP_Reset || done_frame)
      begin
	y_line_cnt <= 0;
	done_frame <= 0;
      end
      // reset counter next cycle if at 479
      else if (y_line_cnt == 479 && done_line == 1)
      begin
	y_line_cnt <= y_line_cnt + 1;
	done_frame <= 1;
      end
      else if (done_line == 1 && curr_state_1 != S_WR_REQUEST)
      begin
	y_line_cnt <= y_line_cnt + 1;
      end
      else
      begin
      end
    end

// burst line counter ... burst 40 times = 1 line
// both for read and write from/to MPMC

    always @ (posedge Bus2IP_Clk)
    begin
      if(Bus2IP_Reset)
      begin
	line_burst_rd_cnt <= 0;
	line_burst_wr_cnt <= 0;
      end
      else if (curr_state_1 == S_BURST_LINE_RD_COMPLETE)
      begin
	if (line_burst_rd_cnt == 6'd40)
	begin
	  line_burst_rd_cnt <= 0;
	end
      end
      else if (done_pixel == 1)
      begin
	line_burst_rd_cnt <= 0;
      end
      else if (next_state_1 == S_BURST_LINE_RD_COMPLETE)
      begin
	if (done_line == 1)
	begin
	  line_burst_rd_cnt <= 0;
	end
	else if (line_burst_rd_cnt < 6'd40)
	begin
	  line_burst_rd_cnt <= line_burst_rd_cnt + 1;
	end
      end
      else if (next_state_1 == S_BURST_LINE_WR_COMPLETE)
      begin
	if (line_burst_wr_cnt == 6'd39)
	begin
	  line_burst_wr_cnt <= 0;
	end
	else
	begin
	  line_burst_wr_cnt <= line_burst_wr_cnt + 1;
	end
      end
    end

// burst frame counter ... burst 19200 times = 1 frame

    always @ (posedge Bus2IP_Clk)
    begin
      if (Bus2IP_Reset)
      begin
	frame_burst_cnt <= 0;
      end
      else if (next_state_1 == S_BURST_LINE_WR_COMPLETE)
      begin
	if (frame_burst_cnt == 15'd19199)
	begin
	  frame_burst_cnt <= 0;
	end
	else
	begin
	  frame_burst_cnt <= frame_burst_cnt + 1;
	end
      end
    end

// load new burst address
// add 64 because finished bursting 16 bytes...therefore move on
// add 64 + 1536 after finish line because account for 1024-640 = 384

  always @ (posedge Bus2IP_Clk)
  begin
    if (Bus2IP_Reset)
    begin
      burst_addr <= fr_addr_src_reg;
      //lb_wr_addr0 <= 0;
      //lb_rd_addr1 <= 0;
    end
    else if (burst_addr == 0)
    begin
      burst_addr <= fr_addr_src_reg;
    end
    else if (curr_state_1 == S_START_FRAME && burst_addr != 0)
    begin
      burst_addr <= bypass;
    end
    else if (curr_state_1 == S_BURST_LINE_RD_COMPLETE)
    begin
      if (line_burst_rd_cnt == 0)
      begin
        // 1536 bytes = 384 pixels
        // 64 bytes = 16 pixels
        //bypass <= burst_addr + 21'd64 + 21'd1536;
      end
      else if (line_burst_rd_cnt != 0 && line_burst_rd_cnt < 11'd40)
      begin
        // 64 bytes = 16 pixels
        burst_addr <= burst_addr + 21'd64;
      end
    end
    else if (curr_state_1 == S_WR_REQUEST)
    begin
      if (line_burst_wr_cnt == 0)
      begin
	burst_addr <= new_y_addr;
      end
    end
    else if (curr_state_1 == S_BURST_LINE_WR_COMPLETE)
    begin
      if (line_burst_wr_cnt == 0)
      begin
	    //lb_rd_addr1 <= 0;
      end
      else if (line_burst_wr_cnt != 0)
      begin
	    burst_addr <= burst_addr + 21'd64;
	    //lb_rd_addr1 <= lb_rd_addr1 + 11'd40;
      end
    end
  end



//lb0 write address calculation
always @(posedge Bus2IP_Clk)
begin
  if (line_burst_done == 1'b1)
  begin
    lb_wr_addr0 <= 0; 
  end
  else if (lb_wr_e0)
  begin
    lb_wr_addr0 <= lb_wr_addr0 + 1; 
  end 
  else
  begin
    lb_wr_addr0 <= lb_wr_addr0;
  end
end

//lb1 read address calculation
always @(posedge Bus2IP_Clk)
begin
  if (line_burst_done == 1'b1)
  begin
    lb_rd_addr1 <= 0; 
  end
  else if (lb_rd_e1 && !Bus2IP_MstWr_dst_rdy_n)
  begin
    lb_rd_addr1 <= lb_rd_addr1 + 1; 
  end 
  else
  begin
    lb_rd_addr1 <= lb_rd_addr1;
  end
end

// ----- END OF FUNCTIONAL LOGIC -----------

// -------------------- COMBINATIONAL OUTPUTS FUNCTIONL FSM0 and FSM1

// FSM0 state update

    always @ (posedge Bus2IP_Clk)
    begin
      if (Bus2IP_Reset)
      begin
        curr_state <= INITIAL;
      end
      else
      begin
        curr_state <= next_state;
      end
    end

// FSM1 state update

    always @ (posedge Bus2IP_Clk)
    begin
      if (Bus2IP_Reset)
      begin
	curr_state_1 <= S_IDLE;
      end
      else
      begin
	curr_state_1 <= next_state_1;
      end
    end

// -------------------- COMBINATIONAL OUTPUTS BASED ON FSM STATE

// FSM0
    always @ (*)
    begin
      case (curr_state)
	INITIAL:
	begin
	 // lb_wr_addr0 <= 11'h000;
	  lb_wr_e0 <= 0;
	  lb_rd_e0 <= 0;
	  lb_rd_e1 <= 0;
	  lb_wr_e1 <= 0;
	end
	H_ADDR_GEN:
	begin
	// set first line buffer to read from 
	  lb_wr_e0 <= 0;
	  lb_rd_e0 <= 1;

	// set second line buffer to write to
	  lb_rd_e1 <= 0;
	  lb_wr_e1 <= 1;
	end
	V_ADDR_GEN:
	begin
	  lb_wr_e0 <= 0;
	  lb_rd_e0 <= 0;
	  lb_rd_e1 <= 0;
	  lb_wr_e1 <= 0;
	// write to second line buffer from first line buffer
	// read from the original unshifted x address
	// write to the shifted x address
	end
	default:
	begin
	  lb_wr_e0 <= 0;
	  lb_rd_e0 <= 0;
	  lb_rd_e1 <= 0;
	  lb_wr_e1 <= 0;
	end
      endcase

      case(curr_state_1)
	S_RD_TRANSFER:
	begin
	  lb_rd_e0 <= 0;

	  //Only write if data is valid
	  if (Bus2IP_MstRd_src_rdy_n == 1'b0)
	    lb_wr_e0 <= 1;
	  else
	    lb_wr_e0 <= 0;

	  lb_wr_e1 <= 0;
	  lb_rd_e1 <= 0;

	  line_burst_done <= 0;
	end
	S_BURST_LINE_RD_COMPLETE:
	begin
	  // wr/rd enables are set explicitly in FM0, which runs in this state
	  if (line_burst_rd_cnt == 6'd40)
	  begin
	    line_burst_done <= 1;
	  end
	end
	S_WR_REQUEST:
	begin
	  lb_rd_e0 <= 0;
	  lb_wr_e0 <= 0;

	  lb_wr_e1 <= 0;
	  lb_rd_e1 <= 0;

	  line_burst_done <= 0;
    
	  //Explict reset of done_line
	  //done_line <= 0;
	end
	S_WR_TRANSFER:
	begin
	  lb_rd_e0 <= 0;
	  lb_wr_e0 <= 0;

	  lb_wr_e1 <= 0;
	  lb_rd_e1 <= 1;

	  line_burst_done <= 0;
	end
	S_BURST_FRAME_COMPLETE:
	begin
	  lb_rd_e0 <= 0;
	  lb_wr_e0 <= 0;

	  lb_wr_e1 <= 0;
	  lb_rd_e1 <= 0;

	  line_burst_done <= 0;
	end
	default:
	begin
	  lb_rd_e0 <= 0;
	  lb_wr_e0 <= 0;

	  lb_wr_e1 <= 0;
	  lb_rd_e1 <= 0;
	  line_burst_done <= 0;
	end
      endcase
    end

// -------------------- LOGIC FOR HANDLING READ/WRITE TO/FROM MPMC
// -------------------- ASSIGN STATEMENTS FOR BURST MODES

// shift in the new red, green, and blue data
  assign red_to_lb1 = red_from_lb0;
  assign green_to_lb1 = green_from_lb0;
  assign blue_to_lb1 = blue_from_lb0;

  assign lb_rd_addr0 = x_pixel_cnt; 
  assign lb_wr_addr1 = new_x_addr;

// asserts for read/write from/to MPMC

  assign IP2Bus_Mst_Type = 1'b1;	// always burst
  assign IP2Bus_Mst_Length = 12'd64;	// always burst 16 words of 4 bytes
  assign IP2Bus_Mst_BE = 4'b1111;
  assign IP2Bus_Mst_Lock = 1'b0;
  assign IP2Bus_Mst_Reset = 1'b0;

  assign IP2Bus_MstWr_Req = (curr_state_1 == S_WR_REQUEST) ? 1'b1 : 1'b0;
  assign IP2Bus_MstRd_Req = (curr_state_1 == S_RD_REQUEST && (bypass > 2'b10)) ? 1'b1 : 1'b0;

  assign IP2Bus_Mst_Addr = burst_addr;

// assign line buffer1 out put to PLB bus to MPMC

  assign IP2Bus_MstWr_d[0:31] = { 8'b0, red_from_lb1[7:2], 2'b0, green_from_lb1[7:2],
				  2'b0, blue_from_lb1[7:2], 2'b0 };

  assign IP2Bus_MstWr_src_rdy_n = !((curr_state_1 == S_WR_TRANSFER || curr_state_1 == S_WR_REQUEST) ? 1'b1 : 1'b0); 
  assign IP2Bus_MstWr_src_dsc_n = 1'b1;

// assert sof at wr_sof_eof_cnt = 0
// assert eof at wr_sof_eof_cnt = 1
    always @ (posedge Bus2IP_Clk)
    begin
      if (Bus2IP_Reset)
      begin
	wr_sof_eof_cnt <= 4'b0000;
      end
      else if (!IP2Bus_MstWr_src_rdy_n & !Bus2IP_MstWr_dst_rdy_n)
      begin
	wr_sof_eof_cnt <= wr_sof_eof_cnt + 1;
      end
    end

  assign IP2Bus_MstWr_sof_n = (!IP2Bus_MstWr_src_rdy_n && (wr_sof_eof_cnt==4'b0000)) ? 1'b0 : 1'b1;
  assign IP2Bus_MstWr_eof_n = (!IP2Bus_MstWr_src_rdy_n && (wr_sof_eof_cnt==4'b1111)) ? 1'b0 : 1'b1;

// assign line buffer0 receives input from PLB Bus from MPMC
  assign red_to_lb0 = Bus2IP_MstRd_d[8:15];
  assign green_to_lb0 = Bus2IP_MstRd_d[16:23];
  assign blue_to_lb0 = Bus2IP_MstRd_d[24:31];

  assign IP2Bus_MstRd_dst_rdy_n = !((curr_state_1 == S_RD_TRANSFER || curr_state_1 == S_RD_REQUEST) ? 1'b1 : 1'b0);
  assign IP2Bus_MstRd_dst_dsc_n = 1'b1;

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
    .i_old_addr	(lb_wr_addr0),
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
    .i_new_frame_base_addr (fr_addr_dest_reg),
    .i_y_off	(yoff_reg),
    .i_dir	(y_dir_reg),
    .i_x_cnt	(x_pixel_cnt),
    .i_y_cnt	(y_line_cnt),
    .o_y_done	(y_done),
    .o_new_addr	(new_y_addr)
  );

// declare line_buffer0 to read from MPMC
// line_buffer0 feeds into line_buffer1 

  LINE_BUFFER_VIDEO LB_inst_0
  (
    .read_clk        (Bus2IP_Clk),
    .read_address    (lb_rd_addr0),
    .read_enable     (lb_rd_e0),
    .read_red_data   (red_from_lb0),
    .read_green_data (green_from_lb0),
    .read_blue_data  (blue_from_lb0),

    .write_clk        (Bus2IP_Clk),
    .write_address    (lb_wr_addr0), 
    .write_enable     (lb_wr_e0),
    .write_red_data   (red_to_lb0),
    .write_green_data (green_to_lb0),
    .write_blue_data  (blue_to_lb0)
  );

// takes input from line_buffer0
// bursts data back into MPMC

  LINE_BUFFER_VIDEO LB_inst_1
  (
    .read_clk	      (Bus2IP_Clk),
    .read_address     (lb_rd_addr1),
    .read_enable      (lb_rd_e1),
    .read_red_data    (red_from_lb1),
    .read_green_data  (green_from_lb1),
    .read_blue_data   (blue_from_lb1),

    .write_clk	      (Bus2IP_Clk),
    .write_address    (lb_wr_addr1),
    .write_enable     (lb_wr_e1),
    .write_red_data   (red_to_lb1),
    .write_green_data (green_to_lb1),
    .write_blue_data  (blue_to_lb1)
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
//Charles hardcoded these 6 values for testing
          fr_addr_src_reg <= C_VIDEO_RAM_BASEADDR;
          fr_addr_dest_reg <= C_VIDEO_RAM_BASEADDR;
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

endmodule

