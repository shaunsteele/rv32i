//  ExecuteUnit.sv
//    Program Counter and ALU

`default_nettype none

module ExecuteUnit # (
  parameter int XLEN = 32,
  parameter int IMADDRLEN = 32,
  parameter int PC_INCR = 4,
  parameter int PC_INIT = 0
)(
  input var                         clk,
  input var                         rstn,

  input var                         i_pc_wen,       // PC Write Enable
  input var                         i_calc_bj_addr, // Calculate Branch/Jump Addr Flag
  input var         [IMADDRLEN-1:0] o_pc,           // Program Counter

  input var         [XLEN-1:0]      i_rf_src1,      // Reg File Source 1
  input var         [XLEN-1:0]      i_rf_src2,      // Reg File Source 2

  input var                         i_imm_sel,      // Immediate Select
  input var         [XLEN-1:0]      i_immediate,    // Immediate

  input var         [3:0]           i_alu_op,       // ALU Opcode
  output var logic  [XLEN-1:0]      o_alu_out,      // ALU Output Register
  output var logic                  o_alu_zero      // ALU Zero Output Register
);


/* Program Counter Logic */
// PC Increment Counter
logic [IMADDRLEN-1:0] incr_pc;

always_comb begin
  incr_pc = o_pc + PC_INCR;
end

// Branch/Jump Address Calculation
logic [IMADDRLEN-1:0] bj_pc;

always_comb begin
  bj_pc = o_pc + i_immediate;
end

// Program Counter Register
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_pc <= PC_INIT;
  end else begin
    if (i_pc_wen) begin
      if (i_calc_bj_addr) begin
        o_pc <= bj_pc;
      end else begin
        o_pc <= incr_pc;
      end
    end else begin
      o_pc <= o_pc;
    end
  end
end


/* ALU Logic */
// Inputs
logic [XLEN-1:0] alu_a;
logic [XLEN-1:0] alu_b;

assign alu_a = i_rf_src1;

always_comb begin
  if (i_imm_sel) begin
    alu_b = i_immediate;
  end else begin
    alu_b = i_rf_src2;
  end
end

logic [XLEN-1:0]  alu_f;
logic             alu_z;
ArithmeticLogicUnit #(
  .XLEN (XLEN)
) u_ALU (
  .i_op (i_alu_op),
  .i_a  (alu_a),
  .i_b  (alu_b),
  .o_f  (alu_f),
  .o_z  (alu_z)
);

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_alu_out <= 0;
    o_alu_zero <= 0;
  end else begin
    o_alu_out <= alu_f;
    o_alu_zero <= alu_z;
  end
end


endmodule
