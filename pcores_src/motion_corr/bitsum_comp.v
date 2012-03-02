// compute sum of 96 bit lines

`include "params.v"

module bitsum_comp (
    input [`SEARCH_AREA_W-1:0] data,
    output [7:0] sum
);
    
wire [6:0] sum_h, sum_l;
sum_of_64 sum64l (
    .data(data[63:0]),
    .sum(sum_l)
);

sum_of_64 sum64h (
    //TODO hardcoded
    .data({32'h0, data[`SEARCH_AREA_W-1:64]}),
    .sum(sum_h)
);

assign sum = sum_h + sum_l;

endmodule
