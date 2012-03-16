`timescale 1ns / 1ps

module pop_count(
    i_clk,
    i_reset,
    i_data,

    o_sum
    );
    /***********************************************************
    *
    *  PARAM declarations
    *
    ***********************************************************/

    //FSM states
  	localparam						C_STATE_BITS 			= 3;
	localparam	[C_STATE_BITS-1:0]	S_DONE                  = 0,
									S_INIT             		= 1,
									S_SHIFT_1       		= 2,
									S_SHIFT_2       		= 3,
									S_SHIFT_4       		= 4,
									S_SHIFT_8       		= 5,
									S_SHIFT_16       		= 6,
									S_SHIFT_32       		= 7,
									S_SHIFT_64       		= 8;

    /* 
        The magic numbers.

        See: http://en.wikipedia.org/wiki/Hamming_weight
     */
    localparam C_M1  = 128'h55555555555555555555555555555555; //binary: 0101...
    localparam C_M2  = 128'h33333333333333333333333333333333; //binary: 00110011..
    localparam C_M4  = 128'h0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f; //binary:  4 zeros,  4 ones ...
    localparam C_M8  = 128'h00ff00ff00ff00ff00ff00ff00ff00ff; //binary:  8 zeros,  8 ones ...
    localparam C_M16 = 128'h0000ffff0000ffff0000ffff0000ffff; //binary: 16 zeros, 16 ones ...
    localparam C_M32 = 128'h00000000ffffffff00000000ffffffff; //binary: 32 zeros, 32 ones ...
    localparam C_M64 = 128'h0000000000000000ffffffffffffffff; //binary: 64 zeros, 64 ones

    /***********************************************************
    *
    *  INPUTs and OUTPUTs
    *
    ***********************************************************/
    input           i_clk;
    input           i_reset;
    input [127:0]   i_data;

    output [127:0]  o_sum;

    
    /***********************************************************
    *
    *  REG and WIRE declarations
    *
    ***********************************************************/
    //FSM
    reg  [C_STATE_BITS-1:0] r_curr_state;
    reg  [C_STATE_BITS-1:0] c_next_state;

    //The Count
    reg [127:0] r_count;

    //Control Signals
    reg         c_load_data;
    
    /*
        One hot encoded shift command
        e.g.
            6'b000001 -> shift by one
            6'b000010 -> shift by two
            6'b000100 -> shift by four
               ...
    */
    reg [6:0]   c_shift_command;

    wire [127:0] w_shifted_count;
    reg  [127:0] c_magic_number;

    /***********************************************************
    *
    *  ASSIGNMENTS
    *
    ***********************************************************/
    assign o_sum = r_count;

    /***********************************************************
    *
    *  MODULE INSTANTIATIONS
    *
    ***********************************************************/
    POP_COUNT_SHIFT POP_COUNT_SHIFT_inst(
                        .i_shift_command    (c_shift_command),
                        .i_data             (r_count),
                        .o_shifted_data     (w_shifted_count)
                    );


    /***********************************************************
    *
    *  Combinational Logic
    *
    ***********************************************************/

    //Combinational outputs based on FSM state
    always@(*)
    begin
        case (r_curr_state)
		S_DONE:
		begin
           c_load_data          <= 0; 
           c_shift_command      <= 7'b0000000;
           c_magic_number       <= 0; 
        end
        S_INIT:
        begin
           c_load_data          <= 1;           //Load the input into the count reg
           c_shift_command      <= 7'b0000000;
           c_magic_number       <= 0; 
        end
		S_SHIFT_1:
		begin
           c_load_data          <= 0; 
           c_shift_command      <= 7'b0000001;
           c_magic_number       <= C_M1;
        end
		S_SHIFT_2:
		begin
           c_load_data          <= 0; 
           c_shift_command      <= 7'b0000010;
           c_magic_number       <= C_M2;
		end
		S_SHIFT_4:
		begin
           c_load_data          <= 0; 
           c_shift_command      <= 7'b0000100;
           c_magic_number       <= C_M4;
		end
		S_SHIFT_8:
		begin
           c_load_data          <= 0; 
           c_shift_command      <= 7'b0001000;
           c_magic_number       <= C_M8;
		end
		S_SHIFT_16:
		begin
           c_load_data          <= 0; 
           c_shift_command      <= 7'b0010000;
           c_magic_number       <= C_M16;
		end
		S_SHIFT_32:
		begin
           c_load_data          <= 0; 
           c_shift_command      <= 7'b0100000;
           c_magic_number       <= C_M32;
		end
		S_SHIFT_64:
		begin
           c_load_data          <= 0; 
           c_shift_command      <= 7'b1000000;
           c_magic_number       <= C_M64;
		end
        default:
        begin
           c_load_data          <= 0; 
           c_shift_command      <= 6'b000000;
        end
        endcase
    end


    //FSM next state logic
	always @ (*)
	begin
		case(r_curr_state)
		S_DONE:
		begin
            if (i_start)
                c_next_state <= S_INIT;
            else
                c_next_state <= S_DONE;
		end
		S_INIT:
		begin
            c_next_state <= S_SHIFT_1;
		end
		S_SHIFT_1:
		begin
            c_next_state <= S_SHIFT_2;
		end
		S_SHIFT_2:
		begin
            c_next_state <= S_SHIFT_4;
		end
		S_SHIFT_4:
		begin
            c_next_state <= S_SHIFT_8;
		end
		S_SHIFT_8:
		begin
            c_next_state <= S_SHIFT_16;
		end
		S_SHIFT_16:
		begin
            c_next_state <= S_SHIFT_32;
		end
		S_SHIFT_32:
		begin
            c_next_state <= S_SHIFT_64;
		end
		S_SHIFT_64:
		begin
            c_next_state <= S_DONE;
		end
        default:
        begin
            c_next_state <= S_DONE;
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
        if (i_reset)
            r_curr_state <= S_DONE;
        else
            r_curr_state <= c_next_state;
    end

    //Load data into r_count
    always@(posedge i_clk)
    begin
        if (c_load_data)
            r_count <= i_data;
        else
            r_count <= r_count;
    end

    //Perform one stage of the pop count per cycle, unless in init or done states
    always@(posedge clk)
    begin
        if ( (r_curr_state == S_INIT) || (r_curr_state == S_DONE) )
            //No change
            r_count <= r_count;
        else
            //Calculate next stage
            r_count <= (r_count & c_magic_number)  + ((w_shifted_count) & c_magic_number);
    end



endmodule
