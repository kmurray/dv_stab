`timescale 1ns / 1ps


module GCBP_LINE_DETECT(
    input   i_clk,
    input   i_resetn,
    input [9:0]  i_line_cnt,

    output  o_new_line
    );

    /***********************************************************
    *
    *  PARAM declarations
    *
    ***********************************************************/

    /***********************************************************
    *
    *  REG and WIRE declarations
    *
    ***********************************************************/
    //Previous cycle's line count
    reg [9:0]               r_prev_line_cnt;
    reg                     r_new_line;

    /***********************************************************
    *
    *  ASSIGNMENTS
    *
    ***********************************************************/
    //Output new frame status
    assign o_new_line = r_new_line;


    /***********************************************************
    *
    *  Combinational Logic
    *
    ***********************************************************/


    /***********************************************************
    *
    *  Clocked (Sequential) Logic
    *
    ***********************************************************/

    //Store the current line count for comparison on the next cycle
    always@(posedge i_clk)
    begin
        if(i_resetn)
            r_prev_line_cnt <= 0;
        else
            r_prev_line_cnt <= i_line_cnt;
    end

    //180 degree phase shift to negedge of clk
    always@(negedge i_clk)
    begin
        if(i_resetn)
            r_new_line <= 0;
        else
            r_new_line <= (r_prev_line_cnt != i_line_cnt);
    end

endmodule
