module correlator_core_tb(

    input [127:0] bram_read_data_0,
    output [`BRAM_ADDR_WIDTH-1:0] bram_read_addr

);

// Instantiate the module
user_logic instance_name (
    .bram_read_data_0(bram_read_data_0), 
    .bram_read_data_1(bram_read_data_1), 
    .bram_read_data_2(bram_read_data_2), 
    .bram_read_data_3(bram_read_data_3), 
    .bram_read_data_4(bram_read_data_4), 
    .bram_read_data_5(bram_read_data_5), 
    .bram_read_data_6(bram_read_data_6), 
    .bram_read_data_7(bram_read_data_7), 
    .bram_read_data_8(bram_read_data_8), 
    .bram_read_data_9(bram_read_data_9), 
    .bram_read_data_10(bram_read_data_10), 
    .bram_read_data_11(bram_read_data_11), 
    .bram_read_data_12(bram_read_data_12), 
    .bram_read_data_13(bram_read_data_13), 
    .bram_read_data_14(bram_read_data_14), 
    .bram_read_data_15(bram_read_data_15), 
    .bram_read_addr(bram_read_addr), 
    .curr_frame_bram_offset(curr_frame_bram_offset), 
    .prev_frame_bram_offset(prev_frame_bram_offset), 
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
    .IP2Bus_IntrEvent(IP2Bus_IntrEvent)
    );

endmodule
