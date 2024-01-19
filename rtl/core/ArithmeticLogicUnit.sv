// ArithmeticLogicUnit.sv

`default_nettype none

`include "core.svh"

module ArithmeticLogicUnit # (
  parameter int XLEN = 32
)(
  input var         [XLEN-1:0]  i_id_imm,

  input var         [XLEN-1:0]  i_rf_rs1_rdata,
  input var         [XLEN-1:0]  i_rf_rs2_rdata,

  input var                     i_imm_sel,
  input var         [3:0]       i_op_data,

  output var logic  [XLEN-1:0]  o_res_data,
  output var logic              o_res_zero
);


/* ALU A Input */
logic [XLEN-1:0]  a;
assign a = i_rf_rs1_rdata;


/* ALU B Input */
logic [XLEN-1:0]  b;
always_comb begin
  if (i_imm_sel) begin
    b = i_id_imm;
  end else begin
    b = i_rf_rs2_rdata;
  end
end


/* ALU Operation */
logic [XLEN-1:0]  res;
always_comb begin
  unique case (i_op_data)
    AluAdd:   res = a + b;
    AluSub:   res = a - b;
    AluSlt:   res = {31'b0, $signed(a) < $signed(b)};
    AluSltu:  res = {31'b0, $unsigned(a) < $unsigned(b)};
    AluXor:   res = a ^ b;
    AluOr:    res = a | b;
    AluAnd:   res = a & b;
    AluSll:   res = a << b;
    AluSra:   res = $signed(a) >>> b;
    default: begin
      res = 0;
      $error("Unsupported ALU Opcode: 0b%04b", i_op_data);
    end
  endcase
end

assign o_res_data = res;
assign o_res_zero = ~|res;


endmodule
