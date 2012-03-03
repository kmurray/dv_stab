`include functions.v

/*
    About naming convetions:

    Signal prefixes *should* indicate type:
        
        i_: module input
        o_: module output
        r_: registered signal (NOTE: a flop, not just a verilog 'reg' type)
        w_: wire
        c_: combinational signal
        C_: param/localparam constant
        S_: param/localparam defining an FSM state
*/


module GCBP (
    i_clk,
    i_resetn,
    i_luma_data,
    i_line_ready,
    i_luma_data_valid,
    i_line_cnt,
    i_new_frame,

    o_bram_array_write_addr,
    o_bram_array_write_data,
    o_bram_array_write_enable,

    o_next_frame_loc,
    o_curr_frame_loc,
    o_prev_frame_loc,

    );

    /***********************************************************
    *
    *  PARAM declarations
    *
    ***********************************************************/

    //FSM states
  	localparam						C_STATE_BITS 	    = 2;
	localparam	[C_STATE_BITS-1:0]	S_SUBIMAGE_ROW_0	= 0,
									S_SUBIMAGE_ROW_1   	= 1,
									S_SUBIMAGE_ROW_2    = 2,
									S_SUBIMAGE_ROW_3	= 3;	

    //Sub image height info
    localparam C_SUBIMAGE_HEIGHT                = 64;
    localparam C_NUM_VERT_SUBIMAGES             = 4;

    //Vertical Frame height: 640
    localparam C_LINES_PER_FRAME                = 480;
    // 4 sub images of 64 bit height => 640 - 4*64 = 224 pixels of empty space
    // 5 gaps between sub images/frame edges
    // 224 = 2*46 + 3*44
    //       `Edges  `btw sub images
    localparam C_VERT_FRAME_EDGE_TO_SUBIMAGE    = 46;
    localparam C_VERT_SUBIMAGE_TO_SUBIMAGE      = 44;

    //Bits needed to count lines in a frame
    localparam C_LINES_PER_FRAME_CNT_BITS		= CLogB2(C_LINES_PER_FRAME);


    //Bits needed to count sub images in a line
    localparam C_SUBIMAGES_PER_LINE_CNT_BITS    = CLogB2(C_NUM_VERT_SUBIMAGES);



    /***********************************************************
    *
    *  INPUTs and OUTPUTs
    *
    ***********************************************************/
    input          i_clk;
    input          i_resetn;
    input  [  8:0] i_luma_data;
    input          i_line_ready;
    input          i_luma_data_valid;
    input  [  8:0] i_line_cnt;
    input          i_new_frame;

    //Write address for BRAM array
    output reg [  8:0]  o_bram_array_write_addr;
    //Write data for BRAM array
	output [127:0]  o_bram_array_write_data;
    //1 hot write enables for BRAM array
	output [ 15:0]  o_bram_array_write_enable;

    //Location of three frametypes in each BRAM
    output [1:0]  o_next_frame_loc;
    output [1:0]  o_curr_frame_loc;
    output [1:0]  o_prev_frame_loc;


    /***********************************************************
    *
    *  REG and WIRE declarations
    *
    ***********************************************************/

    //FSM
    reg  [C_STATE_BITS-1:0] r_curr_state;
    reg  [C_STATE_BITS-1:0] c_next_state;

    //The current vertical row of sub images being worked on
    reg  [C_SUBIMAGES_PER_LINE_CNT_BITS-1:0]    c_vert_subimage_cnt;
    reg  [C_LINES_PER_FRAME_CNT_BITS:0]         c_subimage_done_row_cnt;

    //The current subimage in a row being worked on
    wire [1:0] w_hori_subimage_cnt;

    //Write enables for the BRAM array
    wire [15:0] w_bram_array_wea;

    //Data from GCBP_LINE_GEN is valid
    wire w_gcbp_subimage_line_valid;

    //Data from GCBP_LINE_GEN
    wire w_gcbp_subimage_line;

    /***********************************************************
    *
    *  ASSIGNMENTS
    *
    ***********************************************************/


    /***********************************************************
    *
    *  MODULE INSTANTIATIONS
    *
    ***********************************************************/

    // Generates sub images at the line level
    GCBP_LINE_GEN GCBP_LINE_GEN_inst(
                    .i_clk                  (i_clk),
                    .i_resetn               (i_resetn),
                    .i_luma_data            (i_luma_data),
                    .i_line_ready           (i_line_ready),
                    .i_luma_data_valid      (i_luma_data_valid),

                    .o_gcbp_line            (w_gcbp_subimage_line),
                    .o_gcbp_line_valid      (w_gcbp_subimage_line_valid),
                    .o_hori_subimage_cnt    (w_hori_subimage_cnt)
                  );

    // Generates the "1 hot" encoding for the write enables in bram_array
    GCBP_BRAM_WRITE_ENABLE_DEC GCBP_BRAM_WRITE_ENABLE_DEC_inst(
                                .vert_subimage_cnt  (c_vert_subimage_cnt),
                                .hori_subimage_cnt  (w_hori_subimage_cnt),
                                .bram_array_wea     (w_bram_array_wea) 
                               );

    /*
        Generates BRAM write address based on i_line_cnt, and performing
        double buffering as appropriate.
        
        It also indicates where the various frames are currently located 
        in the BRAM address space
     */ 
    GCBP_BRAM_ADDR_DEC GCBP_BRAM_ADDR_DEC_inst(
                            .i_clk                  (i_clk),
                            .i_resetn               (i_resetn),
                            .i_line_cnt           (i_line_cnt),
                            .i_new_frame            (),

                            .o_curr_frame_loc       (o_curr_frame_loc),
                            .o_prev_frame_loc       (o_prev_frame_loc),
                            .o_next_frame_loc       (o_next_frame_loc),

                            .o_bram_array_write_addr(o_bram_array_write_addr)
                          );



    /***********************************************************
    *
    *  Combinational Logic
    *
    ***********************************************************/

    /* 
        Move to next state once we have gone through both the 'frame to 
        sub image border' (45px) and the 'sub image width' (64px)

                ----------------    -
                | 46px              |
                |      -------      | 
                |      |     |      | S_SUBIMAGE_ROW_0
                | 64px |  0  |  ... |
                |      |     |      |
                |      -------      -
                | 44px              |
                |      -------      | 
                |      |     |      | S_SUBIMAGE_ROW_1
                | 64px |  1  |  ... |
                |      |     |      |
                |      -------      -
         480px  | 44px              |
                |      -------      | 
                |      |     |      | S_SUBIMAGE_ROW_2
                | 64px |  2  |  ... |
                |      |     |      |
                |      -------      -
                | 44px              |
                |      -------      | 
                |      |     |      | S_SUBIMAGE_ROW_3
                | 64px |  3  |  ... |
                |      |     |      |
                |      -------      -
                | 46px         
                ----------------

    */  

    //Combinational outputs based on FSM state
    always@(*)
    begin
        case (r_curr_state)
        S_SUBIMAGE_ROW_0:
        begin
            c_subimage_done_row_cnt = C_VERT_FRAME_EDGE_TO_SUBIMAGE + C_SUBIMAGE_HEIGHT;
            c_vert_subimage_cnt = 0;
        end
        S_SUBIMAGE_ROW_1:
        begin
            c_subimage_done_row_cnt = C_VERT_FRAME_EDGE_TO_SUBIMAGE + C_VERT_SUBIMAGE_TO_SUBIMAGE + 2*C_SUBIMAGE_HEIGHT;
            c_vert_subimage_cnt = 1;
        end
        S_SUBIMAGE_ROW_2:
        begin
            c_subimage_done_row_cnt = C_VERT_FRAME_EDGE_TO_SUBIMAGE + 2*C_VERT_SUBIMAGE_TO_SUBIMAGE + 3*C_SUBIMAGE_HEIGHT;
            c_vert_subimage_cnt = 2;
        end
        S_SUBIMAGE_ROW_3:
        begin
            c_subimage_done_row_cnt = C_VERT_FRAME_EDGE_TO_SUBIMAGE + 3*C_VERT_SUBIMAGE_TO_SUBIMAGE + 4*C_SUBIMAGE_HEIGHT;
            c_vert_subimage_cnt = 3;
        end
        default:
        begin
            c_subimage_done_row_cnt = 0;
            c_vert_subimage_cnt = 0;
        end
        endcase
    end
    



    //   FSM next state logic
	always @ (*)
	begin
		case(r_curr_state)
		S_SUBIMAGE_ROW_0:
		begin
            //First row
            if ( i_line_cnt == c_subimage_done_row_cnt)
            begin
                c_next_state <= S_SUBIMAGE_ROW_1;
            end
            else
            begin
                c_next_state <= S_SUBIMAGE_ROW_0;
            end
		end
		S_SUBIMAGE_ROW_1:
		begin
            //2nd row
            if ( i_line_cnt == c_subimage_done_row_cnt)
            begin
                c_next_state <= S_SUBIMAGE_ROW_2;
            end
            else
            begin
                c_next_state <= S_SUBIMAGE_ROW_1;
            end
		end
		S_SUBIMAGE_ROW_2:
		begin
            //3rd row
            if ( i_line_cnt == c_subimage_done_row_cnt)
            begin
                c_next_state <= S_SUBIMAGE_ROW_3;
            end
            else
            begin
                c_next_state <= S_SUBIMAGE_ROW_2;
            end
		end
		S_SUBIMAGE_ROW_3:
		begin
            //4th row
            if ( i_line_cnt == c_subimage_done_row_cnt)
            begin
                c_next_state <= S_SUBIMAGE_ROW_0;
            end
            else
            begin
                c_next_state <= S_SUBIMAGE_ROW_3;
            end
		end
		default:
		begin
			c_next_state <= S_SUBIMAGE_ROW_0;
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
            r_curr_state <= S_SUBIMAGE_ROW_0;
        else
            r_curr_state <= c_next_state;
    end

endmodule
