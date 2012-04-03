`timescale 1ns / 1ps


module H_ADDR_GEN (

    i_clk,
    i_rst,
    i_x_enable,
    i_old_addr,
    i_x_off,
    i_dir,
    i_x_cnt,
    i_y_cnt,
    o_x_done,
    o_new_addr

);

// param declarations and fsm states

    localparam      C_STATE_BITS				  = 2;
    localparam      [C_STATE_BITS-1:0]      INITIAL	          = 0,
                                            H_ADDR_GEN	          = 1,
					    DONE		  = 2;
// inputs and outputs

    input		  i_clk;
    input		  i_rst;
    input		  i_x_enable;
    input   	  [10:0]  i_old_addr;
    input	  [31:0]  i_x_off;
    input	  [31:0]  i_dir;
    input	  [9:0]   i_x_cnt;
    input	  [10:0]  i_y_cnt;
   
    output  reg	  	  o_x_done; 
    output  reg	  [9:0]  o_new_addr;

// REG and wire declarations

   // assign o_x_done = x_done;
   // assign o_new_addr = new_addr;

//FSM
    reg  [C_STATE_BITS-1:0] curr_state;
    reg  [C_STATE_BITS-1:0] next_state;

    //Addr generation is just combinational logic
    always@(*)
    begin
        if (i_dir == 0)
        begin
            o_new_addr <= (i_x_cnt - i_x_off);
        end
        else
        begin
            o_new_addr <= (i_x_cnt + i_x_off);
        end
    end

// fsm next state logic

    always @ (*)
    begin
      case(curr_state)
	INITIAL:
	begin
	  if (i_x_off != 0)
	  begin
	    next_state <= H_ADDR_GEN;
	  end
	  else 
	  begin
	    next_state <= DONE;
	  end
	end
	H_ADDR_GEN:
	begin
	  next_state <= DONE;
	end
	DONE:
	begin
	  next_state <= INITIAL;
	end
	default:
	begin
	  next_state <= INITIAL;
	end
      endcase
    end


// combinational outputs based on FSM state
// dir = 0, left shift
// dir = 1, right shift
  
    always @ (*)
    begin
      case (curr_state)
        INITIAL:
        begin
            o_x_done <= 0;
        end
        H_ADDR_GEN:
        begin
            o_x_done <= 0;
        end
        DONE:
        begin
            o_x_done <= 1;
        end
        default:
        begin
            o_x_done <= 0;
        end
      endcase
    end



// fsm state update

    always @ (posedge i_clk)
    begin
        if (i_rst)
        begin
            curr_state <= INITIAL;
        end
        else
        begin
            curr_state <= next_state;
        end
    end


endmodule

