// ProgramCounter.sv

`default_nettype none

module ProgramCounter #(
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_incr_valid,
  input var         [1:0]       i_incr_op,
  input var         [XLEN-1:0]  i_incr_data,

  output var logic              o_pc_valid,
  output var logic  [XLEN-1:0]  o_pc_data
);

import pkgRiscV::*;

// Opcode Handshake
logic incr_en;
always_comb begin
  incr_en = i_incr_valid;
end

// Program Counter Logic
logic [XLEN-1:0] next_pc;
logic [XLEN-1:0] pc;

always_comb begin
  if (incr_en) begin
    case (i_incr_op)
      PcIncr: begin
        next_pc = pc + 4;
      end

      PcJump: begin
        next_pc = i_incr_data;
      end

      PcBranch: begin
        next_pc = pc + i_incr_data;
      end

      PcRsvd: begin
        next_pc = pc;
        $warning("Unsupported PC Opcode: 0b%02b", i_incr_op);
      end

      default: begin
        next_pc = pc;
        $error("Illegal PC Opcode: 0b%02b", i_incr_op);
      end
    endcase
  end else begin
    next_pc = pc;
  end
end

// Program Counter Register
always_ff @(posedge clk) begin
  if (!rstn) begin
    pc <= 0;
  end else begin
    pc <= next_pc;
  end
end

assign o_pc_data = pc;

// Address Valid
always_ff @(posedge clk) begin
  o_pc_valid <= rstn;
end


endmodule
