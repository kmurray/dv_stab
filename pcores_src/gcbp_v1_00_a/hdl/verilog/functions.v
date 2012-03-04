`ifndef gcbp_functions
`define gcbp_functions
/*
    Useful pre-synthesis functions

 */

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

`endif
