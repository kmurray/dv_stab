`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:34:16 03/07/2012
// Design Name:   user_logic
// Module Name:   /home/gq777/ece532/system/Video_To_RAM_System_256MB/pcores/split_compensate_v1_01_a/hdl/verilog//user_logic_tb.v
// Project Name:  user_logic
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: user_logic
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module user_logic_tb;

	// Inputs
	reg Bus2IP_Clk;
	reg Bus2IP_Reset;
	reg [0:31] Bus2IP_Data;
	reg [0:3] Bus2IP_BE;
	reg [0:13] Bus2IP_RdCE;
	reg [0:13] Bus2IP_WrCE;
	reg Bus2IP_Mst_CmdAck;
	reg Bus2IP_Mst_Cmplt;
	reg Bus2IP_Mst_Error;
	reg Bus2IP_Mst_Rearbitrate;
	reg Bus2IP_Mst_Cmd_Timeout;
	reg [0:31] Bus2IP_MstRd_d;
	reg [0:3] Bus2IP_MstRd_rem;
	reg Bus2IP_MstRd_sof_n;
	reg Bus2IP_MstRd_eof_n;
	reg Bus2IP_MstRd_src_rdy_n;
	reg Bus2IP_MstRd_src_dsc_n;
	reg Bus2IP_MstWr_dst_rdy_n;
	reg Bus2IP_MstWr_dst_dsc_n;

	// Outputs
	wire x_done;
	wire y_done;
	wire [9:0] new_x_addr;
	wire [31:0] new_y_addr;
	wire [0:31] IP2Bus_Data;
	wire IP2Bus_RdAck;
	wire IP2Bus_WrAck;
	wire IP2Bus_Error;
	wire IP2Bus_MstRd_Req;
	wire IP2Bus_MstWr_Req;
	wire [0:31] IP2Bus_Mst_Addr;
	wire [0:3] IP2Bus_Mst_BE;
	wire [0:11] IP2Bus_Mst_Length;
	wire IP2Bus_Mst_Type;
	wire IP2Bus_Mst_Lock;
	wire IP2Bus_Mst_Reset;
	wire IP2Bus_MstRd_dst_rdy_n;
	wire IP2Bus_MstRd_dst_dsc_n;
	wire [0:31] IP2Bus_MstWr_d;
	wire [0:3] IP2Bus_MstWr_rem;
	wire IP2Bus_MstWr_sof_n;
	wire IP2Bus_MstWr_eof_n;
	wire IP2Bus_MstWr_src_rdy_n;
	wire IP2Bus_MstWr_src_dsc_n;

	// Instantiate the Unit Under Test (UUT)
	user_logic uut (
		.x_done(x_done), 
		.y_done(y_done), 
		.new_x_addr(new_x_addr), 
		.new_y_addr(new_y_addr), 
		.Bus2IP_Clk(Bus2IP_Clk), 
		.Bus2IP_Reset(Bus2IP_Reset), 
		.Bus2IP_Data(Bus2IP_Data), 
		.Bus2IP_BE(Bus2IP_BE), 
		.Bus2IP_RdCE(Bus2IP_RdCE), 
		.Bus2IP_WrCE(Bus2IP_WrCE), 
		.IP2Bus_Data(IP2Bus_Data), 
		.IP2Bus_RdAck(IP2Bus_RdAck), 
		.IP2Bus_WrAck(IP2Bus_WrAck), 
		.IP2Bus_Error(IP2Bus_Error), 
		.IP2Bus_MstRd_Req(IP2Bus_MstRd_Req), 
		.IP2Bus_MstWr_Req(IP2Bus_MstWr_Req), 
		.IP2Bus_Mst_Addr(IP2Bus_Mst_Addr), 
		.IP2Bus_Mst_BE(IP2Bus_Mst_BE), 
		.IP2Bus_Mst_Length(IP2Bus_Mst_Length), 
		.IP2Bus_Mst_Type(IP2Bus_Mst_Type), 
		.IP2Bus_Mst_Lock(IP2Bus_Mst_Lock), 
		.IP2Bus_Mst_Reset(IP2Bus_Mst_Reset), 
		.Bus2IP_Mst_CmdAck(Bus2IP_Mst_CmdAck), 
		.Bus2IP_Mst_Cmplt(Bus2IP_Mst_Cmplt), 
		.Bus2IP_Mst_Error(Bus2IP_Mst_Error), 
		.Bus2IP_Mst_Rearbitrate(Bus2IP_Mst_Rearbitrate), 
		.Bus2IP_Mst_Cmd_Timeout(Bus2IP_Mst_Cmd_Timeout), 
		.Bus2IP_MstRd_d(Bus2IP_MstRd_d), 
		.Bus2IP_MstRd_rem(Bus2IP_MstRd_rem), 
		.Bus2IP_MstRd_sof_n(Bus2IP_MstRd_sof_n), 
		.Bus2IP_MstRd_eof_n(Bus2IP_MstRd_eof_n), 
		.Bus2IP_MstRd_src_rdy_n(Bus2IP_MstRd_src_rdy_n), 
		.Bus2IP_MstRd_src_dsc_n(Bus2IP_MstRd_src_dsc_n), 
		.IP2Bus_MstRd_dst_rdy_n(IP2Bus_MstRd_dst_rdy_n), 
		.IP2Bus_MstRd_dst_dsc_n(IP2Bus_MstRd_dst_dsc_n), 
		.IP2Bus_MstWr_d(IP2Bus_MstWr_d), 
		.IP2Bus_MstWr_rem(IP2Bus_MstWr_rem), 
		.IP2Bus_MstWr_sof_n(IP2Bus_MstWr_sof_n), 
		.IP2Bus_MstWr_eof_n(IP2Bus_MstWr_eof_n), 
		.IP2Bus_MstWr_src_rdy_n(IP2Bus_MstWr_src_rdy_n), 
		.IP2Bus_MstWr_src_dsc_n(IP2Bus_MstWr_src_dsc_n), 
		.Bus2IP_MstWr_dst_rdy_n(Bus2IP_MstWr_dst_rdy_n), 
		.Bus2IP_MstWr_dst_dsc_n(Bus2IP_MstWr_dst_dsc_n)
	);

	initial begin
		// Initialize Inputs
		Bus2IP_Clk = 0;
		Bus2IP_Reset = 0;
		Bus2IP_Data = 0;
		Bus2IP_BE = 0;
		Bus2IP_RdCE = 0;
		Bus2IP_WrCE = 0;
		Bus2IP_Mst_CmdAck = 0;
		Bus2IP_Mst_Cmplt = 0;
		Bus2IP_Mst_Error = 0;
		Bus2IP_Mst_Rearbitrate = 0;
		Bus2IP_Mst_Cmd_Timeout = 0;
		Bus2IP_MstRd_d = 0;
		Bus2IP_MstRd_rem = 0;
		Bus2IP_MstRd_sof_n = 0;
		Bus2IP_MstRd_eof_n = 0;
		Bus2IP_MstRd_src_rdy_n = 0;
		Bus2IP_MstRd_src_dsc_n = 0;
		Bus2IP_MstWr_dst_rdy_n = 0;
		Bus2IP_MstWr_dst_dsc_n = 0;

    // Wait 100 ns for global reset to finish
      #100;

    // set constants

      Bus2IP_Reset = 1;
        
    // Add stimulus here

    end

    always
      #10 Bus2IP_Clk = !Bus2IP_Clk;
      
   // always
   // begin
     // #10000 Bus2IP_Data = 2'b10;
     // #10000 Bus2IP_WrCE = 10'b0000010000;
     // #10010 Bus2IP_Data = 2'b01;
     // #10010 Bus2IP_WrCE = 10'b0000000100;

     // #10020 Bus2IP_Data = 2'b10;
     // #10020 Bus2IP_WrCE = 10'b0000001000;
     // #10030 Bus2IP_Data = 2'b01;
     // #10030 Bus2IP_WrCE = 10'b0000000010;
   // end
endmodule

