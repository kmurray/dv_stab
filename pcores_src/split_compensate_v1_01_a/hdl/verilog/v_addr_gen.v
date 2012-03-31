`timescale 1ns / 1ps


module V_ADDR_GEN (

    i_clk,
    i_rst,
    i_y_enable,
    i_new_frame_base_addr,
    i_y_off,
    i_dir,
    i_x_cnt,
    i_y_cnt,
    o_y_done,
    o_new_addr

);

// param declarations and fsm states

    localparam	    VIDEO_BASE_ADDR				  = 32'h3FFEA000;//32'h3FFF9000; 32'h40000000; 32'h3FFF0000;
    localparam      C_STATE_BITS				  = 2;
    localparam      [C_STATE_BITS-1:0]      INITIAL	          = 0,
                                            V_ADDR_GEN            = 1,
					    DONE		  = 2;
// inputs and outputs

    input		  i_clk;
    input		  i_rst;
    input		  i_y_enable;
    input   	  [31:0]  i_new_frame_base_addr;
    input   	  [31:0]  i_y_off;
    input	  [31:0]  i_dir;
    input	  [9:0]   i_x_cnt;
    input	  [10:0]  i_y_cnt;
    output  reg		  o_y_done; 
    output  reg   [31:0]  o_new_addr;

// REG and wire declarations

// FSM
    reg  [C_STATE_BITS-1:0] curr_state;
    reg  [C_STATE_BITS-1:0] next_state;

// fsm next state logic

    always @ (*)
    begin
      case(curr_state)
	INITIAL:
	begin
	  if (i_y_off != 0)
	  begin
	    next_state <= V_ADDR_GEN;
	  end
	  else 
	  begin
	    next_state <= DONE;
	  end
	end
	V_ADDR_GEN:
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
// dir = 0, up shift
// dir = 1, down shift
  
    always @ (*)
    begin
      case (curr_state)
	INITIAL:
	begin
	  o_y_done <= 0;
	end
	V_ADDR_GEN:
	begin
	  // multiple by 1024 * 4 because video memory in MPMC is byte addressable
	  // each pixel is 32 bits (or 4 bytes)
	  // each line has 1024 pixels
	  if (i_dir == 0)
	  begin
	    o_new_addr <= (i_new_frame_base_addr + 4096*((i_y_cnt-1) - i_y_off));
	  end
	  else 
	  begin
	    o_new_addr <= (i_new_frame_base_addr + 4096*((i_y_cnt-1) + i_y_off));
	  end
	end
	DONE:
	begin
	  o_y_done <= 1;
	end
	default:
	begin
	  o_y_done <= 0;
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

