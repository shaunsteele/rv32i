// fetch_unit.sv

`default_nettype none

module fetch_unit import riscv_pkg::*;
# (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Program Counter
  input var         [PcOps-1:0] i_pc_op,
  input var         [XLEN-1:0]  i_id_immediate,
  input var         [XLEN-1:0]  i_alu_res,
  output var logic  [XLEN-1:0]  o_pc_branch_addr,
  output var logic  [XLEN-1:0]  o_pc_ret_addr,

  // Instruction Memory Bus
  output var logic              o_im_arvalid,
  input var logic               i_im_arready,
  output var logic  [XLEN-1:0]  o_im_araddr
);

logic             pc_en;
logic [XLEN-1:0]  pc_data;

program_counter # (.XLEN(XLEN)) u_PC (
  .clk            (clk),
  .rstn           (rstn),
  .i_en           (pc_en),
  .i_op           (i_pc_op),
  .i_id_immediate (i_id_immediate),
  .i_alu_res      (i_alu_res),
  .o_addr         (pc_data),
  .o_branch_addr  (o_pc_branch_addr),
  .o_ret_addr     (o_pc_ret_addr)
);


fetch_ctrl # (.XLEN(XLEN)) u_FC (
  .clk          (clk),
  .rstn         (rstn),
  .o_im_arvalid (o_im_arvalid),
  .i_im_arready (i_im_arready),
  .o_im_araddr  (o_im_araddr),
  .o_pc_en      (pc_en),
  .i_pc_addr    (pc_data)
);


endmodule
