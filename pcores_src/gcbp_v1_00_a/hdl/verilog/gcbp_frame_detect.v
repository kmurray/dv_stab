`timescale 1ns / 1ps


module GCBP_FRAME_DETECT(
    input   i_clk,
    input   i_resetn,
    input   i_field_0,

    output  o_new_frame
    );

    /***********************************************************
    *
    *  PARAM declarations
    *
    ***********************************************************/

    //FSM states
  	localparam						C_STATE_BITS 	    = 2;
	localparam	[C_STATE_BITS-1:0]	S_FIELD_0       	= 0,
									S_FIELD_1          	= 1,
									S_NEW_FRAME         = 2;

    /***********************************************************
    *
    *  REG and WIRE declarations
    *
    ***********************************************************/

    //FSM
    reg  [C_STATE_BITS-1:0] r_curr_state;
    reg  [C_STATE_BITS-1:0] c_next_state;

    //Indicates new frame
    reg                     c_new_frame;

    /***********************************************************
    *
    *  ASSIGNMENTS
    *
    ***********************************************************/
    //Output new frame status
    assign o_new_frame = c_new_frame;


    /***********************************************************
    *
    *  Combinational Logic
    *
    ***********************************************************/

    //Combinational outputs based on FSM state
    always@(*)
    begin
        case (r_curr_state)
        S_FIELD_0:
        begin
            c_new_frame <= 0;
        end
        S_FIELD_1:
        begin
            c_new_frame <= 0;
        end
        S_NEW_FRAME:
        begin
            c_new_frame <= 1;
        end
        default:
        begin
            c_new_frame <= 0;
        end
        endcase
    end
    
    /*
        FSM

               On field trans          On Field transition
        S_FIELD_0 -------> S_FIELD_1 -----
         ^                               |
         |                               |
         |-----------S_NEW_FRAME <--------
          on next CLK

          In S_NEW_FRAME indicate new frame (for one clk cycle)
     */


    //   FSM next state logic
	always @ (*)
	begin
		case(r_curr_state)
		S_FIELD_0:
		begin
            if ( !i_field_0 )
            begin
                c_next_state <= S_FIELD_1;
            end
            else
            begin
                c_next_state <= S_FIELD_0;
            end
		end
		S_FIELD_1:
		begin
            if ( i_field_0 )
            begin
                c_next_state <= S_NEW_FRAME;
            end
            else
            begin
                c_next_state <= S_FIELD_1;
            end
		end
		S_NEW_FRAME:
		begin
            //Pass through state used to indicate the start of a new frame
            c_next_state <= S_FIELD_0;
		end
		default:
		begin
			c_next_state <= S_FIELD_0;
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
        if(i_resetn)
            r_curr_state <= S_FIELD_0;
        else
            r_curr_state <= c_next_state;
    end

endmodule
