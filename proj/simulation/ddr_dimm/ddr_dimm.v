/****************************************************************************************
*
*    File Name:  ddr_dimm.v
*
*  Description:  Micron SDRAM DDR (Double Data Rate) 184 pin dual in-line memory module (DIMM)
*
*   Limitation:  - SPD (Serial Presence-Detect) is not modeled
*
*   Disclaimer   This software code and all associated documentation, comments or other 
*  of Warranty:  information (collectively "Software") is provided "AS IS" without 
*                warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
*                DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
*                TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMPLIED WARRANTIES 
*                OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
*                WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
*                OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
*                FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
*                THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
*                ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
*                OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
*                ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
*                INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
*                WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
*                OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
*                THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
*                DAMAGES. Because some jurisdictions prohibit the exclusion or 
*                limitation of liability for consequential or incidental damages, the 
*                above limitation may not apply to you.
*
*                Copyright 2003 Micron Technology, Inc. All rights reserved.
*
****************************************************************************************/

`timescale 1ns / 1ps

`define DEBUG 0

module ddr_dimm (
    `ifdef ECC
    cb     ,
    `endif
    //scl    ,
    //sa     ,
    //sda    ,
	`ifdef RDIMM
    reset_n,
	`endif
    ck     ,
    ck_n   ,
    cke    ,
    s_n    ,
    ras_n  ,
    cas_n  ,
    we_n   ,
    ba     ,
    addr   ,
    dqs    ,
    dm	   ,
    dq     
);

`include "ddr_parameters.vh"

	`ifdef RDIMM
		input                  reset_n;
	`endif
    input            [2:0] ck     ;
    input            [2:0] ck_n   ;
	`ifdef DUAL_RANK
		input            [1:0] cke    ;
		input            [1:0] s_n    ;
	`else
		input            [0:0] cke    ;
		input            [0:0] s_n    ;
	`endif
    input                  ras_n  ;
    input                  cas_n  ;
    input                  we_n   ;
    input            [1:0] ba     ;
    input           [(ADDR_BITS-1):0] addr   ;
    inout           [7:0] dqs     ;
    inout	    [7:0] dm      ;
    inout           [63:0] dq     ;
    `ifdef ECC
		inout            [7:0] cb     ;
    `endif
    //input                  scl    ; // no connect
    //input            [2:0] sa     ; // no connect
    //inout                  sda    ; // no connect
`ifdef DUAL_RANK
    initial if (DEBUG) $display("%m: Dual Rank");
`else
    initial if (DEBUG) $display("%m: Single Rank");
`endif
`ifdef ECC
    initial if (DEBUG) $display("%m: ECC");
`else
    initial if (DEBUG) $display("%m: non ECC");
`endif
`ifdef RDIMM
    initial if (DEBUG) $display("%m: Registered DIMM");
    wire             [2:0] rck    = {3{ck[0]}};
    wire             [2:0] rck_n  = {3{ck_n[0]}};
    reg              [1:0] rcke   ;
    reg              [1:0] rs_n   ;
    reg                    rras_n ;
    reg                    rcas_n ;
    reg                    rwe_n  ;
    reg              [1:0] rba    ;
    reg             [13:0] raddr  ;

    always @(negedge reset_n or posedge ck[0]) begin
        if (!reset_n) begin
            rcke   <= 0;
            rs_n   <= 0;
            rras_n <= 0;
            rcas_n <= 0;
            rwe_n  <= 0;
            rba    <= 0;
            raddr  <= 0;
        end else begin
            rcke   <=   cke;
            rs_n   <=   s_n;
            rras_n <= ras_n;
            rcas_n <= cas_n;
            rwe_n  <=  we_n;
            rba    <=    ba;
            raddr  <=  addr;
        end
    end
`else
    initial if (DEBUG) $display("%m: Unbuffered DIMM");
    wire             [2:0] rck    = ck   ;
    wire             [2:0] rck_n  = ck_n ;
	`ifdef DUAL_RANK
		wire             [1:0] rs_n   = s_n  ;
		wire             [1:0] rcke   = cke  ;
	`else
		wire             [0:0] rs_n   = s_n  ;
		wire             [0:0] rcke   = cke  ;
	`endif
    wire                   rras_n = ras_n;
    wire                   rcas_n = cas_n;
    wire                   rwe_n  = we_n ;
    wire             [1:0] rba    = ba   ;
    wire            [13:0] raddr  = addr ;
`endif

    wire                   zero   = 1'b0;
    wire                   one    = 1'b1;

  //ddr      (ck    , ck_n    , cke    , cs_n   , ras_n , cas_n , we_n , ba , addr                , dm            , dq       , dqs           );
`ifdef x4
    initial if (DEBUG) $display("%m: Component Width = x4");
    ddr U1   (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[ 3: 0], dqs[  0]      );
    ddr U2   (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[11: 8], dqs[  1]      );
    ddr U3   (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[19:16], dqs[  2]      );
    ddr U4   (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[27:24], dqs[  3]      );
    ddr U6   (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[35:32], dqs[  4]      );
    ddr U7   (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[43:40], dqs[  5]      );
    ddr U8   (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[51:48], dqs[  6]      );
    ddr U9   (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[59:56], dqs[  7]      );
    `ifdef ECC               
    ddr U5   (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , cb[ 3: 0], dqs[  8]      );
    `endif
    ddr U18  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[ 7: 4], dqs[  9]      );
    ddr U17  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[15:12], dqs[ 10]      );
    ddr U16  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[23:20], dqs[ 11]      );
    ddr U15  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[31:28], dqs[ 12]      );
    ddr U13  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[39:36], dqs[ 13]      );
    ddr U12  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[47:44], dqs[ 14]      );
    ddr U11  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[55:52], dqs[ 15]      );
    ddr U10  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[63:60], dqs[ 16]      );
    `ifdef ECC               
    ddr U14  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , cb[ 7: 4], dqs[ 17]      );
    `endif
    `ifdef DUAL_RANK
    ddr U1t  (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[ 3: 0], dqs[  0]      );
    ddr U2t  (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[11: 8], dqs[  1]      );
    ddr U3t  (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[19:16], dqs[  2]      );
    ddr U4t  (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[27:24], dqs[  3]      );
    ddr U6t  (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[35:32], dqs[  4]      );
    ddr U7t  (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[43:40], dqs[  5]      );
    ddr U8t  (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[51:48], dqs[  6]      );
    ddr U9t  (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[59:56], dqs[  7]      );
        `ifdef ECC               
    ddr U5t  (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , cb[ 3: 0], dqs[  8]      );
        `endif
    ddr U18t (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[ 7: 4], dqs[  9]      );
    ddr U17t (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[15:12], dqs[ 10]      );
    ddr U16t (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[23:20], dqs[ 11]      );
    ddr U15t (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[31:28], dqs[ 12]      );
    ddr U13t (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[39:36], dqs[ 13]      );
    ddr U12t (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[47:44], dqs[ 14]      );
    ddr U11t (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[55:52], dqs[ 15]      );
    ddr U10t (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , dq[63:60], dqs[ 16]      );
        `ifdef ECC           
    ddr U14t (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], zero          , cb[ 7: 4], dqs[ 17]      );
        `endif
    `endif
`else `ifdef x8
    initial if (DEBUG) $display("%m: Component Width = x8");
    ddr U1   (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[0]       , dq[ 7: 0], dqs[  0]      );
    ddr U2   (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[1]       , dq[15: 8], dqs[  1]      );
    ddr U3   (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[2]       , dq[23:16], dqs[  2]      );
    ddr U4   (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[3]       , dq[31:24], dqs[  3]      );
    ddr U6   (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[4]       , dq[39:32], dqs[  4]      );
    ddr U7   (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[5]       , dq[47:40], dqs[  5]      );
    ddr U8   (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[6]       , dq[55:48], dqs[  6]      );
    ddr U9   (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[7]       , dq[63:56], dqs[  7]      );
    `ifdef ECC        
    ddr U5   (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[8]       , cb[ 7: 0], dqs[  8]      );
    `endif
    `ifdef DUAL_RANK
    ddr U18  (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[0]       , dq[ 7: 0], dqs[  0]      );
    ddr U17  (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[1]       , dq[15: 8], dqs[  1]      );
    ddr U16  (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[2]       , dq[23:16], dqs[  2]      );
    ddr U15  (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[3]       , dq[31:24], dqs[  3]      );
    ddr U13  (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[4]       , dq[39:32], dqs[  4]      );
    ddr U12  (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[5]       , dq[47:40], dqs[  5]      );
    ddr U11  (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[6]       , dq[55:48], dqs[  6]      );
    ddr U10  (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[7]       , dq[63:56], dqs[  7]      );
        `ifdef ECC
    ddr U14  (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dm[8]       , cb[ 7: 0], dqs[  8]      );
        `endif
    `endif
`else `ifdef x16
    initial if (DEBUG) $display("%m: Component Width = x16");
    ddr U1   (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dqs[10: 9]    , dq[15: 0], dqs[1:0]      );
    ddr U2   (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dqs[12:11]    , dq[31:16], dqs[3:2]      );
    ddr U4   (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dqs[14:13]    , dq[47:32], dqs[5:4]      );
    ddr U5   (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dqs[16:15]    , dq[63:48], dqs[7:6]      );
    `ifdef ECC
    ddr U3   (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], {one, dqs[17]}, {{8{zero}}, cb}, {zero, dqs[8]});
    `endif
    `ifdef DUAL_RANK
    ddr U10  (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dqs[10: 9]    , dq[15: 0], dqs[1:0]      );
    ddr U9   (rck[1], rck_n[1], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dqs[12:11]    , dq[31:16], dqs[3:2]      );
    ddr U7   (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dqs[14:13]    , dq[47:32], dqs[5:4]      );
    ddr U6   (rck[2], rck_n[2], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], dqs[16:15]    , dq[63:48], dqs[7:6]      );
        `ifdef ECC
    ddr U8   (rck[0], rck_n[0], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, rba, raddr[ADDR_BITS-1:0], {one, dqs[17]}, {{8{zero}}, cb}, {zero, dqs[8]});
        `endif
    `endif
`endif `endif `endif

endmodule
