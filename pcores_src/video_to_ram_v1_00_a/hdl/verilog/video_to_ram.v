/*###############################################
##      
##      Video to RAM for XUPV2P
##
##      Verilog Source File (.v)
##
##      Created By: Jeffrey Goeders
##
##      Date: January 22, 2010
##
##      Modified By: Kevin Murray
##
##      Date: February 16, 2012
##
###############################################*/

module video_to_ram
(
	// System
    i_sys_rst,
    i_clk_100_bus,
	
	// Video Input
    i_LLC_CLOCK,    
    i_YCrCb,
	
	// Bus Master
	o_M_abort,
    o_M_ABus,
    o_M_BE,
    o_M_busLock,
    o_M_TAttribute,
    o_M_lockErr,
    o_M_mSize,
    o_M_priority,
    o_M_rdBurst,
    o_M_request,
    o_M_RNW,
    o_M_size,
    o_M_type,
    o_M_wrBurst,
    o_M_wrDBus,
    i_PLB_MAddrAck,
    i_PLB_MBusy,
    i_PLB_MRdErr,
    i_PLB_MWrErr,
    i_PLB_MRdBTerm,
    i_PLB_MRdDAck,
    i_PLB_MRdDBus,
    i_PLB_MRdWdAddr,
    i_PLB_MRearbitrate,
    i_PLB_MSSize,
    i_PLB_MWrBTerm,
    i_PLB_MWrDAck,
    i_PLB_MTimeout,
    i_PLB_PAValid,
    i_Sl_addrAck,
    i_Sl_wrDAck,
    i_Sl_wrComp,
    
    //MPMC
    i_MPMC_Done_Init,
    
    //Debug
    o_DBG_fsm_cs,
    o_DBG_general_purpose,
    i_DBG_new_line
);
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
	
	
	////////////////////////////////////////////////////////////
	////////////////////////// PARAMETERS //////////////////////
	////////////////////////////////////////////////////////////

	// Assigned by Xilinx Tools
	parameter   					C_PLBV46_NUM_SLAVES 	= 1;
	parameter   					C_PLBV46_DWIDTH     	= 64;
	
	// Inherited From MPD file
	parameter   					C_VIDEO_RAM_BASEADDR	= 32'h00000000;
	parameter						C_BYTES_PER_LINE		= 4096;

	// Local
	localparam  					C_BE_BITS           	= (C_PLBV46_DWIDTH / 8);
	
	localparam						C_BURST_LENGTH			= 16;	// Always write 16 times per request (maximum per burst)
	localparam						C_BYTES_PER_BURST		= C_BURST_LENGTH * 4;
	localparam						C_LINES_PER_FRAME		= 480;
	localparam						C_LINE_CNT_BITS			= CLogB2(C_LINES_PER_FRAME);
	localparam						C_PIXELS_PER_LINE		= 720;
	localparam						C_BURSTS_PER_LINE 		= C_PIXELS_PER_LINE / C_BURST_LENGTH;
	localparam						C_BURST_CNT_BITS		= CLogB2(C_BURSTS_PER_LINE);

    //FSM States
	localparam						C_STATE_BITS 			= 3;
	localparam	[C_STATE_BITS-1:0]	S_INIT 			        = 0,
									S_START_LINE			= 1,
									S_WRITE_REQUEST			= 2,
									S_WRITE					= 3,	
									S_WRITE_COMPLETE		= 4;
                                    
    /*
    In Simulation Debug mode, external inputs are used for some of the
    video timing signals as actually simulating video input is difficult
    and time consuming.
    
    Specifically, the H_444 (new line) signal used to indicate that a switch
    between the buffers has occurred becomes externally driven for debugging
    purposes.  Also the data written to RAM (c_M_wrDBus) is driven to 
    a constant debug value of 0x12345678.
    */
    localparam                      C_SIMULATION_DEBUG_MODE = 0;


	////////////////////////////////////////////////////////////
	////////////////////////// PORTS ///////////////////////////
	////////////////////////////////////////////////////////////

	// System
	input                           		i_sys_rst;
	input                           		i_clk_100_bus;

	// Video 
	input                           		i_LLC_CLOCK;     	// Line Locked Clock (27MHz) from VDEC1 daughter board
	input   [9:2]                   		i_YCrCb;            // YCrCb digital video data from VDEC1 daughter board

	// PLB Master
	output                                  o_M_abort;
	output  [0:31]                          o_M_ABus;
	output  [0:(C_BE_BITS-1)]               o_M_BE;
	output                                  o_M_busLock;
	output  [0:15]                          o_M_TAttribute;
	output                                  o_M_lockErr;
	output  [0:1]                           o_M_mSize;
	output  [0:1]                           o_M_priority;
	output                                  o_M_rdBurst;
	output                                  o_M_request;
	output                                  o_M_RNW;
	output  [0:3]                           o_M_size;
	output  [0:2]                           o_M_type;
	output                                  o_M_wrBurst;
	output  [0:(C_PLBV46_DWIDTH-1)]         o_M_wrDBus;
	input                                   i_PLB_MAddrAck;
	input                                   i_PLB_MBusy;
	input                                   i_PLB_MRdErr;
	input                                   i_PLB_MWrErr;
	input                                   i_PLB_MRdBTerm;
	input                                   i_PLB_MRdDAck;
	input   [0:(C_PLBV46_DWIDTH-1)]         i_PLB_MRdDBus;
	input   [0:3]                           i_PLB_MRdWdAddr;
	input                                   i_PLB_MRearbitrate;
	input   [0:1]                           i_PLB_MSSize;
	input                                   i_PLB_MWrBTerm;
	input                                   i_PLB_MWrDAck;
	input                                   i_PLB_MTimeout;
	input                                   i_PLB_PAValid;
	input   [0:(C_PLBV46_NUM_SLAVES-1)]     i_Sl_addrAck;
	input   [0:(C_PLBV46_NUM_SLAVES-1)]     i_Sl_wrDAck;
	input   [0:(C_PLBV46_NUM_SLAVES-1)]     i_Sl_wrComp;

    //MPMC
    input                                   i_MPMC_Done_Init;
    
    //Debug
    input                                   i_DBG_new_line;
    output  [3:0]                           o_DBG_fsm_cs;
    output  [3:0]                           o_DBG_general_purpose;
    
	////////////////////////////////////////////////////////////
	////////////////////////// DECLARATIONS ////////////////////
	////////////////////////////////////////////////////////////

    //Clocks
	wire							clk_13;
	wire                            clk_27;
	wire                            clk_ceo_444;

    //Input Video Processing
	wire    [9:0]                   w_concat_YCrCb;
	wire    [9:0]                   w_YCrCb_422;
	wire                            w_NTSC_out;
	wire                            w_F_422;
	wire                            w_V_422;
	wire                            w_H_422;
	wire                            w_F_444;
	wire                            w_V_444;
	wire                            w_H_444;
    reg                             w_H_444_with_DBG;
	wire    [9:0]                   w_Y;
	wire    [9:0]                   w_Cr;
	wire    [9:0]                   w_Cb;


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
	wire    [7:0]                   w_line_buffer_read_Luma_0;

	wire    [7:0]                   w_line_buffer_read_Red_1;
	wire    [7:0]                   w_line_buffer_read_Green_1;
	wire    [7:0]                   w_line_buffer_read_Blue_1;
	wire    [7:0]                   w_line_buffer_read_Luma_1;

	wire    [7:0]                   w_Red_to_buffer;
	wire    [7:0]                   w_Green_to_buffer;
	wire    [7:0]                   w_Blue_to_buffer;
	wire    [7:0]                   w_Luma_to_buffer;

	reg     [7:0]                   r_Red_from_buffer;
	reg     [7:0]                   r_Green_from_buffer;
	reg     [7:0]                   r_Blue_from_buffer;
	reg     [7:0]                   r_Luma_from_buffer;
    reg                             r_line_ready;
    
	//Special Timing Generation
	wire							w_one_shot_out;
	wire							w_rst_timing_generation;
	wire	[9:0]					w_vga_timing_line_count;

	// Memory Write State Machine
	reg		[C_STATE_BITS-1:0]		r_cs;
	reg		[C_STATE_BITS-1:0]		c_ns;

    // PLB Master Write
	reg		[0:31]					r_M_ABus;
	reg		[C_BURST_CNT_BITS-1:0]	r_burst_cnt;
	wire							w_M_request;
	reg								c_M_wrBurst;
    reg     [0:(C_PLBV46_DWIDTH-1)]	c_M_wrDBus;

    //Debug
    reg     [3:0]                   c_DBG_fsm_cs;
    wire    [3:0]                   w_DBG_general_purpose;

	////////////////////////////////////////////////////////////
	////////////////////////// ASSIGNMENTS /////////////////////
	////////////////////////////////////////////////////////////

    // Video Processing
	assign 	w_concat_YCrCb 			= {i_YCrCb[9:2],2'B00};	
	
    // Line Buffers
	assign 	w_read_buffer_0			= !r_write_buffer_0;
	assign 	w_write_buffer_0		= r_write_buffer_0;
	assign	w_read_buffer_1			= r_write_buffer_0;
	assign 	w_write_buffer_1		= !r_write_buffer_0;

    // Special Timing Generation
    assign 	w_rst_timing_generation	= ( i_sys_rst || w_one_shot_out );
    
    // Output to PLB Bus
	assign 	o_M_abort				= 1'b0;						// Not Used
	assign	o_M_ABus				= r_M_ABus;
	assign	o_M_BE					= C_BURST_LENGTH - 1;		// Burst Length
	assign	o_M_busLock				= 1'b0;						// Not Used
	assign	o_M_TAttribute			= 16'b0;					// Not Used
	assign 	o_M_lockErr				= 1'b0;						// Not Used
	assign 	o_M_mSize				= 2'b0;						// 32-bit bus size
	assign 	o_M_priority			= 2'b11;					// Always highest priority
	assign 	o_M_rdBurst				= 1'b0;						// Never requesting read operations
	assign 	o_M_request				= w_M_request;	
	assign 	o_M_RNW					= 1'b0;						// Never reading, always writing
	assign 	o_M_size				= 4'hA;						// Burst of Word Size (32-bit) Transfers
	assign 	o_M_type				= 3'b000;					// Standard Memory Transfer
	assign	o_M_wrBurst				= c_M_wrBurst;		
	assign 	o_M_wrDBus				= c_M_wrDBus;
	
    // PLB Signal Logic
    assign	w_M_request				= ( r_cs == S_WRITE_REQUEST );
	
    //Debug 
    assign  w_DBG_general_purpose   = { w_M_request, 1'b0, i_Sl_addrAck, i_PLB_PAValid };
    assign  o_DBG_fsm_cs            = c_DBG_fsm_cs;
    assign  o_DBG_general_purpose   = w_DBG_general_purpose;

	////////////////////////////////////////////////////////////
	///////////////////// COMBINATIONAL LOGIC //////////////////
	////////////////////////////////////////////////////////////

	// c_ns
	always @ (*)
	begin
		case(r_cs)
		S_INIT:
		begin
			if ( i_MPMC_Done_Init == 1'b1 )
			begin
				c_ns <= S_START_LINE;
			end
			else
			begin
				c_ns <= S_INIT;
			end
		end
		S_START_LINE:
		begin
            if ( r_line_ready == 1'b1)
            begin
                c_ns <= S_WRITE_REQUEST;
            end
            else
            begin
                c_ns <= S_START_LINE;
            end
		end
		S_WRITE_REQUEST:
		begin
			if ( i_Sl_addrAck == 1'b1 && i_PLB_PAValid == 1'b1 )
			begin
				c_ns <= S_WRITE;
			end
			else
			begin
				c_ns <= S_WRITE_REQUEST;
			end
		end
		S_WRITE:
		begin
			if ( i_Sl_wrComp == 1'b1 )
			begin
				c_ns <= S_WRITE_COMPLETE;
			end
			else
			begin
				c_ns <= S_WRITE;
			end
		end
		S_WRITE_COMPLETE:
		begin			
			if (r_burst_cnt == C_BURSTS_PER_LINE) // Line Done
			begin
				c_ns <= S_START_LINE;
			end
			else // Line Incomplete
			begin
				c_ns <= S_WRITE_REQUEST;
			end
		end
		default:
		begin
			c_ns <= S_INIT;
		end
		endcase
	end
	
	//c_M_wrBurst
	always @ (*)
	begin
		if ( r_cs == S_WRITE_REQUEST )
		begin
			c_M_wrBurst <= 1'b1;
		end
		else if ( (r_cs == S_WRITE)	&& (i_Sl_wrComp == 1'b0) )
		begin
			c_M_wrBurst <= 1'b1;
		end
		else
		begin
			c_M_wrBurst <= 1'b0;
		end
	end

    //c_DBG_fsm_cs
    always @ (*)
    begin
        case (r_cs)
        S_INIT:
        begin
            c_DBG_fsm_cs <= 0;
        end        
        S_START_LINE:
        begin
            c_DBG_fsm_cs <= 1;  
        end
        S_WRITE_REQUEST:
        begin
            c_DBG_fsm_cs <= 2;
        end
        S_WRITE:
        begin
            c_DBG_fsm_cs <= 3;
        end
        S_WRITE_COMPLETE:
        begin
            c_DBG_fsm_cs <= 4;
        end
        default
        begin
            c_DBG_fsm_cs <= 5;
        end
        endcase
    end
    
    //w_H_444_with_DBG
    //c_M_wrDBus
    always @ (*)
    begin
        if ( C_SIMULATION_DEBUG_MODE == 1 )
        begin
            w_H_444_with_DBG    <= i_DBG_new_line;
            c_M_wrDBus	        <= 32'h12345678;
        end
        else
        begin
            w_H_444_with_DBG    <= w_H_444;
            c_M_wrDBus		    <= { 8'b0, r_Red_from_buffer[7:2], 2'b0, r_Green_from_buffer[7:2], 
                                    2'b0, r_Blue_from_buffer[7:2], 2'b0 };
           	
        end
    end
  
    
	////////////////////////////////////////////////////////////
	///////////////////// CLOCKED ASSIGNMENTS //////////////////
	////////////////////////////////////////////////////////////

	// r_cs
	always @ (posedge i_sys_rst or posedge i_clk_100_bus)
	begin
		if ( i_sys_rst == 1'b1 )
		begin
			r_cs <= S_INIT;
		end
		else
		begin
			r_cs <= c_ns;
		end
	end

	// r_write_buffer_0
	always @ (posedge w_H_444_with_DBG or posedge i_sys_rst) 
	begin
		if ( i_sys_rst == 1'b1 ) 
		begin
			r_write_buffer_0 <= 1'b1;
		end
		else
		begin
			r_write_buffer_0 <= !r_write_buffer_0;
		end
	end
	   
	// r_line_buffer_write_addr
	always @ (posedge clk_13 or posedge w_H_444_with_DBG) 
	begin
		if ( w_H_444_with_DBG == 1'b1 ) 
		begin
			r_line_buffer_write_addr <= 11'h000;
		end
		else 
		begin
			r_line_buffer_write_addr <= r_line_buffer_write_addr + 1;
		end
	end

	// r_line_buffer_read_addr
	always @ (posedge i_clk_100_bus)
	begin
		if ( r_cs == S_START_LINE )
		begin
			r_line_buffer_read_addr <= 11'h00A; //10 Pixel Offset to align frame
		end
		else if ( r_cs == S_WRITE )
		begin
			r_line_buffer_read_addr <= r_line_buffer_read_addr + 1;
		end
	end
	
	// r_Red_from_buffer, r_Green_from_buffer, r_Blue_from_buffer
	always @ (posedge i_clk_100_bus or posedge i_sys_rst) 
	begin
		if ( i_sys_rst == 1'b1 ) 
		begin
			r_Red_from_buffer   <= 8'h00;
			r_Green_from_buffer <= 8'h00;
			r_Blue_from_buffer  <= 8'h00;
			r_Luma_from_buffer  <= 8'h00;
		end
		else if ( w_read_buffer_0 == 1'b1 ) 
		begin
			r_Red_from_buffer   <= w_line_buffer_read_Red_0;
			r_Green_from_buffer <= w_line_buffer_read_Green_0;
			r_Blue_from_buffer  <= w_line_buffer_read_Blue_0;
			r_Luma_from_buffer  <= w_line_buffer_read_Luma_0;
		end
		else 
		begin
			r_Red_from_buffer   <= w_line_buffer_read_Red_1;
			r_Green_from_buffer <= w_line_buffer_read_Green_1;
			r_Blue_from_buffer  <= w_line_buffer_read_Blue_1;
			r_Luma_from_buffer  <= w_line_buffer_read_Luma_1;
		end
	end

	//r_burst_cnt
	always @ (posedge i_clk_100_bus)
	begin
		if (r_cs == S_START_LINE)
		begin
			r_burst_cnt <= {C_BURST_CNT_BITS{1'b0}};
		end
		else if ( (r_cs == S_WRITE_REQUEST) && (c_ns == S_WRITE) )
		begin
			r_burst_cnt <= r_burst_cnt + 1;
		end			
	end
	
	//r_M_ABus
	always @ (posedge i_clk_100_bus)
	begin
		if ( r_cs == S_START_LINE  )
		begin
			r_M_ABus <= C_VIDEO_RAM_BASEADDR + C_BYTES_PER_LINE * w_vga_timing_line_count;
		end
		else if ( r_cs == S_WRITE_COMPLETE )
		begin
			r_M_ABus <= r_M_ABus + C_BYTES_PER_BURST;
		end
	end
    
     //r_line_ready
     always @ (posedge w_H_444_with_DBG or posedge i_clk_100_bus)
     begin
        if ( w_H_444_with_DBG == 1'b1)
        begin
            r_line_ready <= 1'b1;
        end
        else if ( r_cs == S_WRITE_COMPLETE )
        begin
            r_line_ready <= 1'b0;
        end
     end
	
	////////////////////////////////////////////////////////////
	////////////////////////// INSTANTIATIONS //////////////////
	////////////////////////////////////////////////////////////

	// instantiate the clock input buffers for the line locked clock
	IBUFG LLC_INPUT_BUF 
	(
		.O (clk_27),
		.I (i_LLC_CLOCK)
	);

	// instantiate the clock input buffers for the internal clocks
	BUFG CLK_13MHZ_BUF 
	(
		.O  (clk_13),
		.I  (clk_ceo_444)
	);

	// instantiare a DDR output flip flop to center the clock in the pixel data
	OFDDRRSE  PIXEL_CLOCK_DDR_FF
	(
		.Q   (),
		.C0  (clk_27),
		.C1  (!clk_27),
		.CE  (1'b1),
		.D0  (1'b0),
		.D1  (1'b1),
		.R   (),
		.S   (1'b0)
	);

	// INSTANTIATE THE LINE FIELD DECODER
	// THIS EXTRACTS THE H,V,F BITS FROM THE
	// TIMING REFERENCE CODES
	lf_decode lf_decode_i
	(
		.rst       (i_sys_rst),             // Reset and Clock input
		.clk       (clk_27),                // 27Mhz for SDTV
		.YCrCb_in  (w_concat_YCrCb),        // data from the input video stream
		.YCrCb_out (w_YCrCb_422),           // data delayed by pipe length
		.NTSC_out  (w_NTSC_out),            // high = NTSC format detected
		.Fo        (w_F_422),               // high = field one (even)
		.Vo        (w_V_422),               // high = vertical blank
		.Ho        (w_H_422)                // low = active video
	);

	// CONVERT FROM 4:2:2 DATA TO 4:4:4 DATA
	vp422_444_dup vp422_444_dup_i
	(
		.rst          (i_sys_rst),          // resets input data register and control
		.clk          (clk_27),             // video component rate clock, 27Mhz for SDTV
		.ycrcb_in     (w_YCrCb_422),        // video component data
		.ntsc_in      (w_NTSC_out),     
		.fi           (w_F_422),            // Low to High signals start of Field One
		.vi           (w_V_422),            // High signals Vertical Blanking
		.hi           (w_H_422),            // High signals Horizontal Blanking
		.ceo          (clk_ceo_444),        // output data rate is 1/2 the clock rate
		.ntsc_out_o   (),   
		.fo           (w_F_444),            // Field signal delayed by pipe length
		.vo           (w_V_444),            // Vertical signal delayed by pipe length
		.ho           (w_H_444),            // Horizontal signal delayed by pipe length
		.y_out        (w_Y),                // Y out
		.cr_out       (w_Cr),               // Cr out
		.cb_out       (w_Cb)                // Cb out
	);

	// INSTANTIATE THE COLOR SPACE CONVERTER
	YCrCb2RGB YCrCb2RGB_i
	(
		.R    (w_Red_to_buffer),       
		.G    (w_Green_to_buffer),     
		.B    (w_Blue_to_buffer),      
		.clk  (clk_13),    
		.rst  (i_sys_rst),       
		.Y    (w_Y),  
		.Cr   (w_Cr), 
		.Cb   (w_Cb)  
	); 


	// INSTANTIATE TWO VIDEO LINE BUFFERS. THESE LINE BUFFERS SWITCH
	// FROM READ TO WRITE AT THE END OF EACH HORIZONTAL BLANKING INTERVAL
	// THESE BUFFERS RESIDE IN BRAMs
	LINE_BUFFER LB0
	(
	.read_clk        (i_clk_100_bus),
	.read_address    (r_line_buffer_read_addr),
	.read_enable     (w_read_buffer_0),
	.read_red_data   (w_line_buffer_read_Red_0),
	.read_green_data (w_line_buffer_read_Green_0),
	.read_blue_data  (w_line_buffer_read_Blue_0),
	.read_luma_data  (w_line_buffer_read_Luma_0),

	.write_clk        (clk_13),
	.write_address    (r_line_buffer_write_addr), 
	.write_enable     (w_write_buffer_0),
	.write_red_data   (w_Red_to_buffer),
	.write_green_data (w_Green_to_buffer),
	.write_blue_data  (w_Blue_to_buffer),
	.write_luma_data  (w_Luma_to_buffer)
	);

	LINE_BUFFER LB1
	(
	.read_clk         (i_clk_100_bus),
	.read_address     (r_line_buffer_read_addr),
	.read_enable      (w_read_buffer_1),
	.read_red_data    (w_line_buffer_read_Red_1),
	.read_green_data  (w_line_buffer_read_Green_1),
	.read_blue_data   (w_line_buffer_read_Blue_1),
	.read_luma_data   (w_line_buffer_read_Luma_1),

	.write_clk        (clk_13),
	.write_address    (r_line_buffer_write_addr),  
	.write_enable     (w_write_buffer_1),
	.write_red_data   (w_Red_to_buffer),
	.write_green_data (w_Green_to_buffer),
	.write_blue_data  (w_Blue_to_buffer),
	.write_luma_data  (w_Luma_to_buffer)
	);

	// INSTANTIATE A ONE SHOT TO DETECT THE FALLING EDGS OF THE FIELD
	// BIT IN THE TIMING REFERENCE CODE. THIS PULSE RESETS THE
	// SVGA TIMING GENERATION MODULE TO SYNCH THE OUTPUT VIDEO WITH
	// THE VIDEO SOURCE
	NEG_EDGE_DETECT NEG_EDGE_DETECT_i
	(
		.clk          (clk_27),     
		.data_in      (w_F_444),     
		.reset        (i_sys_rst),        
		.one_shot_out (w_one_shot_out)
	);

	// INSTANTIATE THE SVGA TIMING GENERATION MODULE
    // This module is used for the line count generates
    // It handles the interlaced video and correctly outputs the 
    // appropriate line numbere
	SPECIAL_SVGA_TIMING_GENERATION SPECIAL_SVGA_TIMING_GENERATION
	(
		.pixel_clock          (clk_27),           
		.reset                (w_rst_timing_generation), 
		.h_synch_delay        (),    
		.v_synch_delay        (),    
		.comp_synch           (),       
		.blank                (),            
		.char_line_count      (),  
		.char_address         (),     
		.char_pixel           (),       
		.pixel_count          (),      
		.line_count_out       (w_vga_timing_line_count)
	);

	
endmodule

module IBUFG(O, I); // synthesis syn_black_box
	output O;
	input I;
endmodule

module BUFG(O, I); // synthesis syn_black_box
	output O;
	input I;
endmodule

module OFDDRRSE (Q, C0, C1, CE, D0, D1, R, S); // synthesis syn_black_box
    output Q;
    input  C0, C1, CE, D0, D1, R, S;
endmodule

