// ArithmeticLogicUnit.sv

`default_nettype none

module ArithmeticLogicUnit # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_op_valid,
  output var logic              o_op_ready,
  input var         [3:0]       i_op_data,

  input var                     i_a_valid,
  input var         [XLEN-1:0]  i_a_data,

  input var                     i_b_valid,
  input var         [XLEN-1:0]  i_b_data,

  output var logic              o_f_valid,
  input var logic               i_f_ready, // unused
  output var logic  [XLEN-1:0]  o_f_data,
  output var logic              o_z_valid
);

import riscvPkg::*;

// Opcode Input Logic
logic op_en;
always_comb begin
  op_en = i_op_valid & o_op_ready;
end
logic [3:0] op;
always_comb begin
  if (op_en) begin
    op = i_op_data;
  end else begin
    op = 0;
  end
end

// Input Data Logic
logic [XLEN-1:0] a;
logic [XLEN-1:0] b;

always_comb begin
  if (op_en) begin
    a = (i_a_valid) ? i_a_data : 0;
    b = (i_b_valid) ? i_b_data : 0;
  end else begin
    a = 0;
    b = 0;
  end
end


// Calculation
logic [XLEN-1:0] f;

always_comb begin
  case (i_op)
    AluAdd:   f = a + b;

    AluSub:   f = a - b;

    AluSll:   f = a << b;

    AluSlt:   f = $signed(a) < $signed(b);

    AluSltu:  f = $unsigned(a) < $unsigned(b);

    AluXor:   f = a ^ b;

    AluSrl:   f = a >> b;

    AluSra:   f = $signed(a) >>> b;

    AluOr:    f = a | b;

    AluAnd:   f = a & b;

    default: begin
      f = 0;
      $error("Unsupported ALU Opcode: 0b%04b", i_op);
    end
  endcase
end

// Output Data Logic
always_comb begin
  o_f_valid = op_en & i_a_valid & i_b_valid;
end

assign o_f_data = f;

always_comb begin
  o_z_valid = ~|f;
end

endmodule
