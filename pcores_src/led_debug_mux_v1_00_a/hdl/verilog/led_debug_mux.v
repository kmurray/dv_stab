/*###############################################
##      
##      LED Debux Mux for XUPV2P
##
##      Verilog Source File (.v)
##
##      Created By: Jeffrey Goeders
##
##      Date: January 19, 2010
##
###############################################*/

module led_debug_mux
    (
        IN_0, 
        IN_1, 
        IN_2, 
        IN_3, 
        IN_4, 
        IN_5, 
        IN_6, 
        IN_7, 
        IN_8, 
        IN_9, 
        IN_10, 
        IN_11, 
        IN_12, 
        IN_13, 
        IN_14, 
        IN_15,
        SELECTOR,
        LED_OUT
    );
    
    ////////////////////////////////////////////////////////////
	//////////////////////////  PRE-COMPILER FUNCTIONS /////////
	////////////////////////////////////////////////////////////

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
    
    
    ////////////////////////////////////////////////////////////
	////////////////////////// PARAMETERS //////////////////////
	////////////////////////////////////////////////////////////
    
    parameter C_NUM_INPUTS = 0; 
    
    localparam C_NUM_INPUT_BITS = CLogB2(C_NUM_INPUTS - 1);

    
    ////////////////////////////////////////////////////////////
	////////////////////////// PORTS ///////////////////////////
	////////////////////////////////////////////////////////////
        
    input [3:0] IN_0;
    input [3:0] IN_1;
    input [3:0] IN_2;
    input [3:0] IN_3;
    input [3:0] IN_4;
    input [3:0] IN_5;
    input [3:0] IN_6;
    input [3:0] IN_7;
    input [3:0] IN_8;
    input [3:0] IN_9;
    input [3:0] IN_10;
    input [3:0] IN_11;
    input [3:0] IN_12;
    input [3:0] IN_13;
    input [3:0] IN_14;
    input [3:0] IN_15;
    input [3:0] SELECTOR;
    output [3:0] LED_OUT;

    
    ////////////////////////////////////////////////////////////
	////////////////////////// DECLARATIONS ////////////////////
	////////////////////////////////////////////////////////////
    
    reg [3:0] c_LED_OUT;

    
    ////////////////////////////////////////////////////////////
	////////////////////////// ASSIGNMENTS /////////////////////
	////////////////////////////////////////////////////////////
    
    assign LED_OUT = ~c_LED_OUT;

    
    ////////////////////////////////////////////////////////////
	///////////////////// COMBINATIONAL LOGIC //////////////////
	////////////////////////////////////////////////////////////
    
    always @ (*)
    begin
        if ( C_NUM_INPUT_BITS == 0 )
        begin
            c_LED_OUT <= IN_0;
        end
        else
        begin
            case(~(SELECTOR[(C_NUM_INPUT_BITS-1):0]))
            0:
                c_LED_OUT <= IN_0;
            1:
                c_LED_OUT <= IN_1;
            2:
                c_LED_OUT <= IN_2;
            3:
                c_LED_OUT <= IN_3;
            4:
                c_LED_OUT <= IN_4;
            5:
                c_LED_OUT <= IN_5;
            6:
                c_LED_OUT <= IN_6;
            7:
                c_LED_OUT <= IN_7;
            8:
                c_LED_OUT <= IN_8;
            9:
                c_LED_OUT <= IN_9;
            10:
                c_LED_OUT <= IN_10;
            11:
                c_LED_OUT <= IN_11;
            12:
                c_LED_OUT <= IN_12;
            13:
                c_LED_OUT <= IN_13;
            14:
                c_LED_OUT <= IN_14;
            15:
                c_LED_OUT <= IN_15;
            endcase
        end
    end

endmodule
