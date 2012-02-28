`timescale 100ps / 100ps

`default_nettype none

module ADV7183B (
      nRESET,
      LLC1,
      P15_8,
      SCLK,
      SDA
  );

parameter NUM_FRAMES = 1;
parameter FRAME_SIZE = 900900;

input wire nRESET; 
output reg LLC1;
output wire [15:8] P15_8;
input wire SCLK;
inout wire SDA;

initial
begin
	LLC1 = 1'b0;
	forever #185 LLC1 = ~LLC1;
end

reg [7:0] vidstream [0:(NUM_FRAMES*FRAME_SIZE-1)];
initial
begin
	$readmemh("input.vid",vidstream);
	//$stop;
end

integer vidaddr = 0;

always @(negedge LLC1, negedge nRESET)
begin
	if (nRESET==1'b0)
		vidaddr = 0;
	else if (vidaddr==(NUM_FRAMES*FRAME_SIZE-1))
		vidaddr = 0;
	else
		vidaddr = vidaddr + 1;
end

assign P15_8 = vidstream[vidaddr];

//------------ I2C ---------------------
wire i2c_start;
wire i2c_stop;
reg dSDA,dSCLK;

always @(posedge LLC1, negedge nRESET)
begin
	if (nRESET==1'b0)
		dSDA <= 1'b1;
	else
		dSDA <= SDA;
end

always @(posedge LLC1, negedge nRESET)
begin
	if (nRESET==1'b0)
		dSCLK <= 1'b0;
	else
		dSCLK <= SCLK;
end

assign i2c_start = SCLK & dSCLK & dSDA & ~SDA;
assign i2c_stop  = SCLK & dSCLK & SDA & ~dSDA;

reg i2c_active;

always @(posedge LLC1, negedge nRESET)
begin
	if (nRESET==1'b0)
		i2c_active <= 1'b0;
	else if (i2c_start)
		i2c_active <= 1'b1;
	else if (i2c_stop)
		i2c_active <= 1'b0;
end

reg [3:0] bitcnt;

always @(posedge LLC1, negedge nRESET)
begin
	if (nRESET==1'b0)
		bitcnt <= 4'b0000;
	else if (i2c_start | i2c_stop)
		bitcnt <= 4'b0000;
	else if (dSCLK & ~SCLK)
	begin
		if (bitcnt==4'b1001)
			bitcnt <= 4'b0001;
		else
			bitcnt <= bitcnt + 1;
	end
end

assign SDA = (bitcnt==4'b1001) ? 1'b0 : 1'bZ;
wire SDAdrive;
assign SDAdrive = (bitcnt==4'b1001) ? 1'b0 : 1'bZ;

endmodule


