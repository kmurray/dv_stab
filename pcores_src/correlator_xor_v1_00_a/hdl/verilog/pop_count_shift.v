`timescale 1ns / 1ps

//Which BRAM should we be writting?
module POP_COUNT_SHIFT(
    input [6:0] i_shift_command,
    input [127:0] i_data,

    output [127:0] o_shifted_data
    );
   

    //The shifted data
    reg [127:0] c_shifted_data;

    //Output the shifted data
    assign o_shifted_data = c_shifted_data;

    // Decoder for "1 hot" shift commands
    always@(*)
    begin
        case(i_shift_command)
        6'b0000001: c_shifted_data <= (i_data >> 1 );
        6'b0000010: c_shifted_data <= (i_data >> 2 );
        6'b0000100: c_shifted_data <= (i_data >> 4 );
        6'b0001000: c_shifted_data <= (i_data >> 8 );
        6'b0010000: c_shifted_data <= (i_data >> 16);
        6'b0100000: c_shifted_data <= (i_data >> 32);
        6'b1000000: c_shifted_data <= (i_data >> 64);
        default:    c_shifted_data <=  i_data;       //No shift
        endcase
    end

    end

endmodule
