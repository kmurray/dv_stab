`timescale 1ns / 1ps


module GCBP_BRAM_ADDR_DEC(
        i_clk,
        i_resetn,
        i_valid_subimage_line,
        i_new_line,
        i_new_frame,

        o_curr_frame_loc,
        o_prev_frame_loc,
        o_next_frame_loc,

        o_bram_array_write_addr
    );


    /***********************************************************
    *
    *  PARAM declarations
    *
    ***********************************************************/

    //FSM states
  	localparam						C_STATE_BITS 			= 2;
	localparam	[C_STATE_BITS-1:0]	S_WRITE_LOC_0	        = 0,
									S_WRITE_LOC_1    		= 1,
									S_WRITE_LOC_2    		= 2;


    /*
        How far a part the various frames are in BRAM 
        address space (BRAMs are word addressable).

        Since each sub image only requires 64 words,
        twice that size leaves more than sufficient 
        space between them, while not over-running
        the BRAM
    */
    localparam C_SUBIMAGE_OFFSET_IN_BRAM    = 128;

    /***********************************************************
    *
    *  INPUTs and OUTPUTs
    *
    ***********************************************************/
    input           i_clk;
    input           i_resetn;

    //Is the line part of a valid subimage (vertically)
    input           i_valid_subimage_line;

    //Indicates the start of a new line
    input           i_new_line;

    //Indicates the start of a new frame
    input           i_new_frame;

    //Which BRAM memory locations represent which frame?
    output reg [1:0]    o_curr_frame_loc;
    output reg [1:0]    o_prev_frame_loc;
    output reg [1:0]    o_next_frame_loc;

    //Write address for the current line
    output [8:0]    o_bram_array_write_addr;
    
    /***********************************************************
    *
    *  REG and WIRE declarations
    *
    ***********************************************************/

    //FSM
    reg  [C_STATE_BITS-1:0] r_curr_state;
    reg  [C_STATE_BITS-1:0] c_next_state;

    //The line of the subimage being worked on (64 total lines per sub image)
    reg  [5:0] r_subimage_line_cnt;

    /***********************************************************
    *
    *  ASSIGNMENTS
    *
    ***********************************************************/
    /* 
        BRAM address calculation
        
            BRAMs are 128bit ride with 512 entries.

            Subimages are 128px by 64px. The GCBP encoding uses 
            only one bit per pixel.

            Therefore, it takes 64 128bit words per sub frame.

                BRAM
            ------------- 0     <- Write Location 0 start address
            | Frame A   |
            |           |
            ------------- 64
            |           |
            |           |
            ------------- 128   <- Write Location 1 start address
            | Frame B   |
            |           |
            ------------- 192
            |           |
            |           |
            ------------- 256   <- Write Location 2 start address
            | Frame C   |
            |           |
            ------------- 320
            |           |
            |           |
            ------------- 384
            |           |
            |           |
            ------------- 448
            |           |
            |           |
            ------------- 512

            '-----------'
               128bits


        We need to store 3 frames in each BRAM:
        
            1) The Previous Frame
            2) The Current Frame
            3) The Next Frame

        The 3rd (Next Frame) is required so that the (dual ported)
        BRAM can be updated with the next frame while the correlator is
        working with the Previous and Current Frames.  This basically amounts
        to double buffering.

        Note however, that we only need to double buffer the Current frame. The
        current frame will become the previous frame on the next cycle.  This
        is accomplished solely with a pointer flip, so no double buffering is
        required for the Previous frame.

        This module handles the flipping between three frames using the state
        machine outlined below.

        This module outputs three signals:

            1) o_prev_frame_loc
            2) o_curr_frame_loc
            3) o_next_frame_loc
            
        Which indicate which location is serving in what role at the current time.

        The address a line 'line_num' in the of the relevant line in calculated as:
            address_of_current_frame_line42 = o_curr_frame_loc*128 + 42
                                                                |     |
                                                                |   Line number  
                                                                |
                                                             Storage offest (constant)

    */


    /* 
        The GCBP module is writting the 'next' frame to BRAMs,
        r_subimage_line_cnt represents the current line of the sub image
    */
    assign o_bram_array_write_addr = o_next_frame_loc*C_SUBIMAGE_OFFSET_IN_BRAM + r_subimage_line_cnt;

    /***********************************************************
    *
    *  Combinational Logic
    *
    ***********************************************************/

    //Combinational outputs based on FSM state
    always@(*)
    begin
        case (r_curr_state)
        S_WRITE_LOC_0:
        begin
            o_next_frame_loc = 0;
            o_curr_frame_loc = 1;
            o_prev_frame_loc = 2;
        end
        S_WRITE_LOC_1:
        begin
            o_next_frame_loc = 2;
            o_curr_frame_loc = 0;
            o_prev_frame_loc = 1;
        end
        S_WRITE_LOC_2:
        begin
            o_next_frame_loc = 1;
            o_curr_frame_loc = 2;
            o_prev_frame_loc = 0;
        end
        default:
        begin
            //S_WRITE_LOC_0
            o_next_frame_loc = 0;
            o_curr_frame_loc = 1;
            o_prev_frame_loc = 2;
        end
        endcase
    end


    //FSM next state logic
	always @ (*)
	begin
		case(r_curr_state)
		S_WRITE_LOC_0:
		begin
            //First location
            if (i_new_frame)
            begin
                c_next_state <= S_WRITE_LOC_1;
            end
            else
            begin
                c_next_state <= S_WRITE_LOC_0;
            end
		end
		S_WRITE_LOC_1:
		begin
            //2nd location
            if (i_new_frame)
            begin
                c_next_state <= S_WRITE_LOC_2;
            end
            else
            begin
                c_next_state <= S_WRITE_LOC_1;
            end
		end
		S_WRITE_LOC_2:
		begin
            //3rd location
            if (i_new_frame)
            begin
                c_next_state <= S_WRITE_LOC_0;
            end
            else
            begin
                c_next_state <= S_WRITE_LOC_2;
            end
		end
        default:
        begin
            c_next_state <= S_WRITE_LOC_0;
        end
        endcase
    end


    /***********************************************************
    *
    *  Clocked (Sequential) Logic
    *
    ***********************************************************/
    //FSM state update
    always@(posedge i_clk)
    begin
        if(!i_resetn)
            r_curr_state <= S_WRITE_LOC_0;
        else
            r_curr_state <= c_next_state;
    end

    always@(posedge i_clk)
    begin
        if(!i_resetn)
            r_subimage_line_cnt <= 0;
        else if (i_valid_subimage_line && i_new_line)
            r_subimage_line_cnt <= r_subimage_line_cnt + 1;
        else
            r_subimage_line_cnt <= r_subimage_line_cnt;
    end

endmodule


