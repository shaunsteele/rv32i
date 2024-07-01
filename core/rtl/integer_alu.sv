// integer_alu.sv

`default_nettype none

module integer_alu # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_en,
  input var         [9:0]       i_funct,
  input var         [XLEN-1:0]  i_src1,
  input var         [XLEN-1:0]  i_src2,

  input var                     i_stall,
  output var logic  [XLEN-1:0]  o_res
);

import riscv_pkg::*;

logic [XLEN-1:0]  res;

always_comb begin
  unique case (i_funct)
    AluADD:   res = i_src1 + i_src2;
    AluSUB:   res = i_src1 - i_src2;
    AluSLL:   res = i_src1 << i_src2;
    AluSLT:   res = $signed(i_src1) < $signed(i_src2);
    AluSLTU:  res = $unsigned(i_src1) < $unsigned(i_src2);
    AluXOR:   res = i_src1 ^ i_src2;
    AluSRL:   res = i_src1 >> i_src2;
    AluSRA:   res = $signed(i_src1) >>> i_src2;
    AluOR:    res = i_src1 | i_src2;
    AluAND:   res = i_src1 & i_src2;
    default: begin
      res = 0;
      $error("Unsupported ALU Opcode: 0b%03x", i_op);
    end
  endcase
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_res <= 0;
  end else begin
    if (i_en && !i_stall) begin
      o_res <= res;
    end else begin
      o_res <= o_res;
    end
  end
end


endmodule
