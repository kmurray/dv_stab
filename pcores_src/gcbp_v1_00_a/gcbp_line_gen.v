`include "params.v"

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


module GCBP_LINE_GEN (
    i_clk,
    i_resetn,
    i_luma_data,
    i_line_ready,
    i_luma_data_valid,

    o_gcbp_line,
    o_gcbp_line_valid,
    o_hori_subimage_cnt
    );

    /***********************************************************
    *
    *  PARAM declarations
    *
    ***********************************************************/

    //FSM states
  	localparam						C_STATE_BITS 			= 3;
	localparam	[C_STATE_BITS-1:0]	S_INIT 			        = 0,
									S_SUBIMAGE_0			= 1,
									S_SUBIMAGE_1  			= 2,
									S_SUBIMAGE_2			= 3,	
									S_SUBIMAGE_3        	= 4;

    //Sub image width info
    localparam C_SUBIMAGE_WIDTH                 = BRAM_DATA_WIDTH //128
    localparam C_NUM_HORI_SUBIMAGES             = 4;

    //Horizontal Frame width: 720
    localparam C_PIXELS_PER_LINE                = 720;
    // 4 sub images of 128 bit width => 720 - 4*128 = 208 pixels of empty space
    // 5 gaps between sub images/frame edges
    // 208 = 2*41 + 3*42
    //       `Edges  `btw sub images
    localparam C_HORI_FRAME_EDGE_TO_SUBIMAGE    = 41;
    localparam C_HORI_SUBIMAGE_TO_SUBIMAGE      = 42;

    //Bits needed to count pixels in a line
    localparam C_PIXELS_PER_LINE_CNT_BITS       = ClogB2(PIXELS_PER_LINE);

    //Bits needed to count sub images in a line
    localparam C_SUBIMAGES_PER_LINE_CNT_BITS    = CLogB2(C_NUM_HORI_SUBIMAGES);

    /***********************************************************
    *
    *  INPUT and OUTPUT declarations
    *
    ***********************************************************/

    input          i_clk;
    input          i_resetn;
    input          i_luma_data;
    input          i_line_ready;
    input          i_luma_data_valid;

    //A single line of the GCBP, used to fill a BRAM word
    output [C_SUBIMAGE_WIDTH-1:0]     o_gcbp_line; 
    //Indicates that o_gcbp_line is valid
    output                            o_gcbp_line_valid;

    //Which sub image is being output
    output [1:0]                      o_hori_subimage_cnt;


    /***********************************************************
    *
    *  REG and WIRE declarations
    *
    ***********************************************************/


    //Which pixel in the line we are processing
    reg [C_LINE_PER_FRAME_CNT_BITS-1:0] r_hori_pixel_cnt;

    //FSM state
    reg [C_STATE_BITS-1:0] r_curr_state;
    reg [C_STATE_BITS-1:0] c_next_state;

    //At what pixel count is the current subimage complete?
    reg [C_LINE_PER_FRAME_CNT_BITS-1:0] c_subimage_done_cnt;

    //A shift register used to store one line of a sub image
    reg [C_SUBIMAGE_WIDTH-1:0]   r_gcbp_line_shift_reg;

    /***********************************************************
    *
    *  Combinational Logic
    *
    ***********************************************************/


    /*
        The layout of a frame with four horizontal sub images.
        This indicates the spacing and sizes, along with the 
        associate FSM states

                                    720px
        ------------------------------------------------------------
        | 41px  128px  42px  128px  42px  128px  42px  128px  41px |
        |      -------      -------      -------      -------      |
        |      |     |      |     |      |     |      |     |      | 
        |      |  0  |      |  1  |      |  2  |      |  3  |      | 
        |      -------      -------      -------      -------      |
        |                                                          |

        '------------'------------'------------'------------'
         S_SUBIMAGE_0 S_SUBIMAGE_1 S_SUBIMAGE_2 S_SUBIMAGE_3         <-- FSM states


     */
     

    /*
        Set the 'sub_image_done_cnt' appropriately for each sub image
        This is used by the FSM state logic

        Also set the output sub image count
    */
    always@(*)
    begin
        case (r_curr_state)
        S_INIT:
        begin
            c_subimage_done_cnt = 0;
            o_hori_subimage_cnt = 0;
        end
        S_SUBIMAGE_0:
        begin
            c_subimage_done_cnt = C_HORI_FRAME_EDGE_TO_SUBIMAGE + C_SUBIMAGE_WIDTH;
            o_hori_subimage_cnt = 0;
        end
        S_SUBIMAGE_1:
        begin
            c_subimage_done_cnt = C_HORI_FRAME_EDGE_TO_SUBIMAGE + C_HORI_SUBIMAGE_TO_SUBIMAGE + 2*C_SUBIMAGE_WIDTH;
            o_hori_subimage_cnt = 1;
        end
        S_SUBIMAGE_2:
        begin
            c_subimage_done_cnt = C_HORI_FRAME_EDGE_TO_SUBIMAGE + 2*C_HORI_SUBIMAGE_TO_SUBIMAGE + 3*C_SUBIMAGE_WIDTH;
            o_hori_subimage_cnt = 2;
        end
        S_SUBIMAGE_3:
        begin
            c_subimage_done_cnt = C_HORI_FRAME_EDGE_TO_SUBIMAGE + 3*C_HORI_SUBIMAGE_TO_SUBIMAGE + 4*C_SUBIMAGE_WIDTH;
            o_hori_subimage_cnt = 3;
        end
        default:
        begin
            c_subimage_done_cnt = 0;
            o_hori_subimage_cnt = 0;
        end
    end

    /* 
       FSM logic
        Move to next state once we finish the current one, 
        based on the r_hori_pixel_cnt 
    */  
	always @ (*)
	begin
		case(r_curr_state)
		S_INIT:
		begin
            //Initial state, wait for line buffer to indicate ready
			if ( i_line_ready == 1'b1 )
			begin
				c_next_state <= S_SUBIMAGE_0;
			end
			else
			begin
				c_next_state <= S_INIT;
			end
		end
		S_SUBIMAGE_0:
		begin
            //First sub image
            if ( r_hori_pixel_cnt == c_subimage_done_cnt)
            begin
                c_next_state <= S_MID_LINE;
            end
            else
            begin
                c_next_state <= S_SUBIMAGE_0;
            end
		end
		S_SUBIMAGE_1:
		begin
            //2nd sub image (first middle)
            if ( r_hori_pixel_cnt == c_subimage_done_cnt)
            begin
                c_next_state <= S_SUBIMAGE_2;
            end
            else
            begin
                c_next_state <= S_SUBIMAGE_1;
            end
		end
		S_SUBIMAGE_2:
		begin
            //3rd sub image (second middle)
            if ( r_hori_pixel_cnt == c_subimage_done_cnt)
            begin
                c_next_state <= S_SUBIMAGE_3;
            end
            else
            begin
                c_next_state <= S_SUBIMAGE_2;
            end
		end
		S_SUBIMAGE_3:
		begin
            //4th sub image (final)
            if ( r_hori_pixel_cnt == c_subimage_done_cnt)
            begin
                c_next_state <= S_INIT;
            end
            else
            begin
                c_next_state <= S_SUBIMAGE_3;
            end
		end
        //Init for default
		default:
		begin
			c_next_state <= S_INIT;
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
            r_curr_state <= S_INIT;
        else
            r_curr_state <= c_next_state;
    end


    //Horizontal pixel counter
    always@(posedge i_clk)
    begin
        if(!i_resetn)
            hori_pixel_count <= 0;
        else
        begin
            /* 
             * Since we are piggy backing on the line buffer reads feeding the PLB/DDR
             * in video2ram, the rate of new data arriving is based on the PLB burst 
             * protocol
             * To avoid grabbing the same data over again (if video2ram is currently 
             * not bursting on the PLB, we follow this valid data indicator
             */
            if (i_luma_data_valid)
            begin
                //Don't counter more than the line width
                if (horiz_pixel_count != C_PIXELS_PER_LINE)
                    horiz_pixel_count <= horiz_pixel_count + 1; 
                else
                    horiz_pixel_count <= 0;
            end
        end
    end

    //Indicate gcbp_line ready to store in bram
    always@(posedge i_clk)
    begin
        if(!i_resetn)
            o_gcbp_line_valid <= 0;
            o_gcbp_line <= 0;
        else
        begin
            /* 
               Indicate that the gcbp_line reg contains valid
               data for storing in sub image BRAM. This occurs when
               we have recieved the last pixel in the sub image

               We know this has occured when horiz_pixel_count 
               matches the done count for the subimage
            */
            if (horiz_pixel_count == c_subimage_done_cnt) // and c_subimage_done_cnt > 0 ???
                o_gcbp_line_valid <= 1;
                o_gcbp_line <= r_gcbp_line_shift_reg;
            else
                0_gcbp_line_valid <= 0;
                o_gcbp_line <= 0;
        end
    end


    /*
        Read one bit (extracting the 'bit plane' from the line buffered luma 
        data.  This is then shifted in as the LSB of the r_gcbp_line register

        We only do this when i_luma_data_valid is set, since otherwise we would be
        getting stale data
    */
    always@(posedge i_clk)
    begin
        if (!i_resetn)
            r_gcbp_line_shift_reg = 128'b0;
        else
        begin
            if(i_luma_data_valid)
            begin
                //Shift the gcbp line data, and add in the newest bit
                r_gcbp_line_shift_reg = {r_gcbp_line_shift_reg[126:0],i_luma_data[0]};
            end
            else
            begin
                //Keep state (reg)
                r_gcbp_line_shift_reg = r_gcbp_line_shift_reg;
            end
        end
    end
    

endmodule
