module bram_array(
	clk_in,
	clk_out,

	input  [  8:0]  bram_0_in_addr,
	input  [127:0]  bram_0_in_data,
	input           bram_0_wea,
	input  [  8:0]  bram_0_out_addr,
	output [  8:0]  bram_0_out_data,

	input  [  8:0]  bram_1_in_addr,
	input  [127:0]  bram_1_in_data,
	input           bram_1_wea,
	input  [  8:0]  bram_1_out_addr,
	output [  8:0]  bram_1_out_data,

	input  [  8:0]  bram_2_in_addr,
	input  [127:0]  bram_2_in_data,
	input           bram_2_wea,
	input  [  8:0]  bram_2_out_addr,
	output [  8:0]  bram_2_out_data,

	input  [  8:0]  bram_3_in_addr,
	input  [127:0]  bram_3_in_data,
	input           bram_3_wea,
	input  [  8:0]  bram_3_out_addr,
	output [  8:0]  bram_3_out_data,

	input  [  8:0]  bram_4_in_addr,
	input  [127:0]  bram_4_in_data,
	input           bram_4_wea,
	input  [  8:0]  bram_4_out_addr,
	output [  8:0]  bram_4_out_data,

	input  [  8:0]  bram_5_in_addr,
	input  [127:0]  bram_5_in_data,
	input           bram_5_wea,
	input  [  8:0]  bram_5_out_addr,
	output [  8:0]  bram_5_out_data,

	input  [  8:0]  bram_6_in_addr,
	input  [127:0]  bram_6_in_data,
	input           bram_6_wea,
	input  [  8:0]  bram_6_out_addr,
	output [  8:0]  bram_6_out_data,

	input  [  8:0]  bram_7_in_addr,
	input  [127:0]  bram_7_in_data,
	input           bram_7_wea,
	input  [  8:0]  bram_7_out_addr,
	output [  8:0]  bram_7_out_data,

	input  [  8:0]  bram_8_in_addr,
	input  [127:0]  bram_8_in_data,
	input           bram_8_wea,
	input  [  8:0]  bram_8_out_addr,
	output [  8:0]  bram_8_out_data,

	input  [  8:0]  bram_9_in_addr,
	input  [127:0]  bram_9_in_data,
	input           bram_9_wea,
	input  [  8:0]  bram_9_out_addr,
	output [  8:0]  bram_9_out_data,

	input  [  8:0]  bram_10_in_addr,
	input  [127:0]  bram_10_in_data,
	input           bram_10_wea,
	input  [  8:0]  bram_10_out_addr,
	output [  8:0]  bram_10_out_data,

	input  [  8:0]  bram_11_in_addr,
	input  [127:0]  bram_11_in_data,
	input           bram_11_wea,
	input  [  8:0]  bram_11_out_addr,
	output [  8:0]  bram_11_out_data,

	input  [  8:0]  bram_12_in_addr,
	input  [127:0]  bram_12_in_data,
	input           bram_12_wea,
	input  [  8:0]  bram_12_out_addr,
	output [  8:0]  bram_12_out_data,

	input  [  8:0]  bram_13_in_addr,
	input  [127:0]  bram_13_in_data,
	input           bram_13_wea,
	input  [  8:0]  bram_13_out_addr,
	output [  8:0]  bram_13_out_data,

	input  [  8:0]  bram_14_in_addr,
	input  [127:0]  bram_14_in_data,
	input           bram_14_wea,
	input  [  8:0]  bram_14_out_addr,
	output [  8:0]  bram_14_out_data,

	input  [  8:0]  bram_15_in_addr,
	input  [127:0]  bram_15_in_data,
	input           bram_15_wea,
	input  [  8:0]  bram_15_out_addr,
	output [  8:0]  bram_15_out_data,

	);

	 bram bram_0(
		.addra(bram_0_in_addr),
		.addrb(bram_0_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_0_in_data),
		.doutb(bram_0_out_addr),
		.wea  (bram_0_wea));

	 bram bram_1(
		.addra(bram_1_in_addr),
		.addrb(bram_1_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_1_in_data),
		.doutb(bram_1_out_addr),
		.wea  (bram_1_wea));

	 bram bram_2(
		.addra(bram_2_in_addr),
		.addrb(bram_2_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_2_in_data),
		.doutb(bram_2_out_addr),
		.wea  (bram_2_wea));

	 bram bram_3(
		.addra(bram_3_in_addr),
		.addrb(bram_3_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_3_in_data),
		.doutb(bram_3_out_addr),
		.wea  (bram_3_wea));

	 bram bram_4(
		.addra(bram_4_in_addr),
		.addrb(bram_4_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_4_in_data),
		.doutb(bram_4_out_addr),
		.wea  (bram_4_wea));

	 bram bram_5(
		.addra(bram_5_in_addr),
		.addrb(bram_5_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_5_in_data),
		.doutb(bram_5_out_addr),
		.wea  (bram_5_wea));

	 bram bram_6(
		.addra(bram_6_in_addr),
		.addrb(bram_6_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_6_in_data),
		.doutb(bram_6_out_addr),
		.wea  (bram_6_wea));

	 bram bram_7(
		.addra(bram_7_in_addr),
		.addrb(bram_7_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_7_in_data),
		.doutb(bram_7_out_addr),
		.wea  (bram_7_wea));

	 bram bram_8(
		.addra(bram_8_in_addr),
		.addrb(bram_8_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_8_in_data),
		.doutb(bram_8_out_addr),
		.wea  (bram_8_wea));

	 bram bram_9(
		.addra(bram_9_in_addr),
		.addrb(bram_9_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_9_in_data),
		.doutb(bram_9_out_addr),
		.wea  (bram_9_wea));

	 bram bram_10(
		.addra(bram_10_in_addr),
		.addrb(bram_10_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_10_in_data),
		.doutb(bram_10_out_addr),
		.wea  (bram_10_wea));

	 bram bram_11(
		.addra(bram_11_in_addr),
		.addrb(bram_11_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_11_in_data),
		.doutb(bram_11_out_addr),
		.wea  (bram_11_wea));

	 bram bram_12(
		.addra(bram_12_in_addr),
		.addrb(bram_12_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_12_in_data),
		.doutb(bram_12_out_addr),
		.wea  (bram_12_wea));

	 bram bram_13(
		.addra(bram_13_in_addr),
		.addrb(bram_13_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_13_in_data),
		.doutb(bram_13_out_addr),
		.wea  (bram_13_wea));

	 bram bram_14(
		.addra(bram_14_in_addr),
		.addrb(bram_14_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_14_in_data),
		.doutb(bram_14_out_addr),
		.wea  (bram_14_wea));

	 bram bram_15(
		.addra(bram_15_in_addr),
		.addrb(bram_15_out_addr),
		.clka (clk_in),
		.clkb (clk_out),
		.dina (bram_15_in_data),
		.doutb(bram_15_out_addr),
		.wea  (bram_15_wea));

endmodule
