// FetchUnit.sv

`default_nettype none

module FetchUnit # (
  parameter int XLEN = 32
)(
  input var clk,
  input var rstn,

  // Program Counter
  input var         [2:0]       i_pc_op,
  input var         [XLEN-1:0]  i_pc_id_imm_data,
  input var         [XLEN-1:0]  i_pc_alu_res_data,
  output var logic  [XLEN-1:0]  o_pc_data,
  output var logic  [XLEN-1:0]  o_pc_imm_data,
  output var logic  [XLEN-1:0]  o_pc_ret_data,

  // Instruction Memory Bus
  output var logic  [XLEN-1:0]  o_im_raddr
);


/* Program Counter */
ProgramCounter # (.XLEN(XLEN)) u_PC (
  .clk            (clk),
  .rstn           (rstn),
  .i_op           (i_pc_op),
  .i_id_imm_data  (i_pc_id_imm_data),
  .i_alu_res_data (i_pc_alu_res_data),
  .i_incr_data    (i_pc_incr_data),
  .o_data         (o_pc_data),
  .o_imm_data     (o_pc_imm_data),
  .o_ret_data     (o_pc_ret_data)
);


/* Instruction Memory Bus */
assign o_im_raddr = pc_data;


endmodule
