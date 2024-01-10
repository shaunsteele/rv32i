// ProgramCounter.sv

`default_nettype none

module ProgramCounter #(
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_incr_valid,
  output var logic              o_incr_ready,
  input var         [1:0]       i_incr_op,
  input var         [XLEN-1:0]  i_incr_data,

  output var logic              o_pc_valid,
  output var logic  [XLEN-1:0]  o_pc_data
);

import riscvPkg::*;

// Opcode Handshake
logic incr_en;
always_comb begin
  incr_en = i_incr_valid & o_incr_ready;
end

// Program Counter Logic
logic [XLEN-1:0] next_pc;

always_comb begin
  if (incr_en) begin
    case (i_incr_op)
      PcIncr: begin
        next_pc = o_pc + 4;
      end

      PcJump: begin
        next_pc = i_incr_data;
      end

      PcBranch: begin
        next_pc = o_pc + i_incr_data;
      end

      PcRsvd: begin
        next_pc = o_pc;
        $warning("Unsupported PC Opcode: 0b%02b", i_incr_op);
      end

      default: begin
        next_pc = o_pc;
        $error("Illegal PC Opcode: 0b%02b", i_incr_op);
      end
    endcase
  end else begin
    next_pc = o_pc;
  end
end

// Program Counter Register
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_pc <= 0;
  end else begin
    o_pc <= next_pc;
  end
end

// Address Valid
always_ff @(posedge clk) begin
  o_pc_valid <= rstn;
end


endmodule
