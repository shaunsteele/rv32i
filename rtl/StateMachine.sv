// StateMachine.sv

`default_nettype none

`include "riscv.svh"

module StateMachine # (
  parameter int STATE_AMOUNT = 3
)(
  input var       clk,
  input var       rstn,

  output var logic    o_state_valid,
  input var           i_state_ready,
  output var state_e  o_state_data,

  output var logic    o_fu_fetch_valid,
  input var           i_fu_fetch_ready,

  input var           i_fu_instr_valid,
  output var logic    o_fu_instr_ready,

  output var logic    o_eu_execute_valid,
  input var           i_eu_execute_ready
);

// State Machine Enable Flag
logic state_en;
always_comb begin
  state_en = o_state_valid & i_state_ready;
end

// State Definitions
state_e next_state;
state_e curr_state;

assign o_state_data = curr_state;

// Current State Logic
always_ff @(posedge clk) begin
  if (!rstn) begin
    curr_state <= IDLE;
  end else begin
    curr_state <= next_state;
  end
end

// Next State Logic
logic fu_fetch_en;  // Fetch Accepted
always_comb begin
  fu_fetch_en = /*o_fu_fetch_valid &*/ i_fu_fetch_ready;
end

logic fu_instr_en;  // Instruction Ready
always_comb begin
  fu_instr_en = i_fu_instr_valid/* & o_fu_instr_ready*/;
end
 
logic eu_execute_en;  // Execute Complete
always_comb begin
  eu_execute_en = /*o_eu_execute_valid*/ & i_eu_execute_ready;
end

always_comb begin
  case (curr_state)
    IDLE: begin
      o_fu_fetch_valid = 1;
      o_fu_instr_ready = 0;
      o_eu_execute_valid = 0;
      if (!state_en) begin
        next_state = IDLE;
      end else begin
        if (fu_fetch_en) begin
          next_state = FETCH;
        end else begin
          next_state = IDLE;
        end
      end
    end

    FETCH: begin
      o_fu_fetch_valid = 0;
      o_fu_instr_ready = 1;
      o_eu_execute_valid = 0;
      if (!state_en) begin
        next_state = IDLE;
      end else begin
        if (fu_instr_en) begin
          next_state = EXECUTE;
        end else begin
          next_state = FETCH;
        end
      end
    end

    EXECUTE: begin
      o_fu_fetch_valid = 1;
      o_fu_instr_ready = 0;
      o_eu_execute_valid = 1;
      if (!state_en) begin
        next_state = IDLE;
      end else begin
        if (eu_execute_en) begin
          next_state = FETCH;
        end else begin
          next_state = EXECUTE;
        end
      end
    end

    default: begin
      o_fu_fetch_valid = 0;
      o_fu_instr_ready = 0;
      o_eu_execute_valid = 0;
      next_state = IDLE;
      $error(
        "Illegal state encountered: %s\t0x%0h", curr_state.name, curr_state
        );
    end
  endcase
end



endmodule
