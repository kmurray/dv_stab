`timescale 1ns/1ps


// A parameterized, inferable, simple dual-port, dual-clock block RAM in Verilog.
// Based on:  http://danstrother.com/2010/09/11/inferring-rams-in-fpgas/
module bram #(
    parameter DATA = 128,
    parameter ADDR = 9
) (
    // Port A - write
    input   wire                clka,
    input   wire                wea,
    input   wire    [ADDR-1:0]  addra,
    input   wire    [DATA-1:0]  dina,
     
    // Port B - read
    input   wire                clkb,
    input   wire    [ADDR-1:0]  addrb,
    output  reg     [DATA-1:0]  doutb
);
 
    // Shared memory
    reg [DATA-1:0] mem [(2**ADDR)-1:0];
     
    // Port A
    always @(posedge clka) begin
        if(wea) begin
            mem[addra] <= dina;
        end
    end
     
    // Port B
    always @(posedge clkb) begin
        doutb      <= mem[addrb];
    end

endmodule

