// integer_unit.sv

`default_nettype none

module integer_unit # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_en,
  input var         [9:0]       i_op,
  input var         [XLEN-1:0]  i_src1,
  input var         [XLEN-1:0]  i_src2,
  input var         [4:0]       i_waddr,

  output var logic              o_valid,
  output var logic  [XLEN-1:0]  o_res,
  output var logic  [4:0]       o_wb_waddr
);

import riscv_pkg::*;

logic [XLEN-1:0]  res;

always_comb begin
  unique case (i_op)
    AluAdd:   res = i_src1 + i_src2;
    AluSub:   res = i_src1 - i_src2;
    AluSlt:   res = {31'b0, $signed(i_src1) < $signed(i_src2)};
    AluSltu:  res = {31'b0, $unsigned(i_src1) < $unsigned(i_src2)};
    AluXor:   res = i_src1 ^ i_src2;
    AluOr:    res = i_src1 | i_src2;
    AluAnd:   res = i_src1 & i_src2;
    AluSll:   res = i_src1 << i_src2;
    AluSrl:   res = i_src1 >> i_src2;
    AluSra:   res = $signed(i_src1) >>> i_src2;
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
    if (i_en) begin
      o_res <= res;
    end else begin
      o_res <= o_res;
    end
  end
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_valid <= 0;
  end else begin
    o_valid <= i_en;
  end
end

logic [XLEN-1:0]  mem_buf_res;
logic [4:0]       mem_buf_waddr;
logic             mem_valid;

always_ff @(posedge clk) begin
  
end

always_ff @(posedge clk) begin
  o_wb_waddr <= i_waddr;
end

endmodule
