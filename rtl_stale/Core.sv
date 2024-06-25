// Core.sv

`default_nettype none

module Core import riscv_pkg::*;
# (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Instruction Memory Bus
  axi4_lite_if.M  axi_im,
  axi4_lite_if.S  axi_dm/*
  output var logic  [XLEN-1:0]  o_im_raddr,
  input var         [XLEN-1:0]  i_im_rdata,

  // Data Memory Bus
  output var logic  [XLEN-1:0]  o_dm_addr,
  output var logic              o_dm_wvalid,
  output var logic  [XLEN-1:0]  o_dm_wdata,
  input var         [XLEN-1:0]  i_dm_rdata*/
);



/* Fetch Unit */
// Inputs
logic [PcOps-1:0] cu_pc_op;
logic [XLEN-1:0]  du_immediate;

// Outputs
logic [XLEN-1:0]  fu_pc_branch_addr;
logic [XLEN-1:0]  fu_pc_ret_addr;

// Instantiation
fetch_unit #(.XLEN(XLEN)) u_FU (
  .clk              (clk),
  .rstn             (rstn),
  .i_pc_op          (cu_pc_op),
  .i_id_immediate   (du_immediate),
  .i_alu_res        (),
  .o_pc_branch_addr (fu_pc_branch_addr),
  .o_pc_ret_addr    (fu_pc_ret_addr),
  .o_im_arvalid     (axi_im.arvalid),
  .i_im_arready     (axi_im.arready),
  .o_im_araddr      (axi_im.araddr)
);



/* Decode Unit */
// Inputs

// Outputs
logic [6:0]       du_opcode;
logic [6:0]       du_funct7;
logic [2:0]       du_funct3;
logic [XLEN-1:0]  du_immediate;
logic [XLEN-1:0]  du_rf_rs1_rdata;
logic [XLEN-1:0]  du_rf_rs2_rdata;
logic             du_rf_rd_awvalid;

// Instantiation
decode_unit # (.XLEN(XLEN)) u_DU (
  .clk              (clk),
  .rstn             (rstn),
  .i_im_rvalid      (axi_im.rvalid),
  .o_im_rready      (axi_im.rready),
  .i_im_rdata       (axi_im.rdata),
  .o_opcode         (du_opcode),
  .o_funct7         (du_funct7),
  .o_funct3         (du_funct3),
  .o_immediate      (du_immediate),
  .o_rf_rs1_rdata   (du_rf_rs1_rdata),
  .o_rf_rs2_rdata   (du_rf_rs2_rdata),
  .o_rf_rd_awvalid  (du_rf_rd_awvalid),
  .i_rf_rd_wvalid   (),
  .i_rf_rd_wdata    ()
);

/* Execute Unit */
logic             cu_eu_alu_imm_sel;
logic [3:0]       cu_eu_alu_op_data;
logic             eu_alu_res_zero;
logic             cu_dm_cu_wvalid;
logic [2:0]       cu_eu_dm_op_data;
logic [2:0]       cu_wb_op_data;
logic             cu_eu_wb_dm_sel;
ExecuteUnit # (.XLEN(XLEN)) u_EU (
  .i_id_imm           (du_id_imm),
  .i_alu_rf_rs1_rdata (du_rf_rs1_rdata),
  .i_alu_rf_rs2_rdata (du_rf_rs2_rdata),
  .i_alu_imm_sel      (cu_eu_alu_imm_sel),
  .i_alu_op_data      (cu_eu_alu_op_data),
  .o_alu_res_data     (eu_alu_res_data),
  .o_alu_res_zero     (eu_alu_res_zero),
  .i_dm_cu_wvalid     (cu_dm_cu_wvalid),
  .i_dm_op_data       (cu_eu_dm_op_data),
  .o_dm_addr          (o_dm_addr),
  .o_dm_wvalid        (o_dm_wvalid),
  .o_dm_wdata         (o_dm_wdata),
  .i_dm_rdata         (i_dm_rdata),
  .i_wb_op_data       (cu_wb_op_data),
  .i_wb_pc_imm_data   (fu_pc_imm_data),
  .i_wb_pc_ret_data   (fu_pc_ret_data),
  .o_wb_rf_rd_wdata   (eu_wb_rf_rd_wdata)
);

assign dbg_eu_alu_res_data = eu_alu_res_data;
assign dbg_eu_alu_res_zero = eu_alu_res_zero;
assign dbg_eu_wb_rf_rd_wdata = eu_wb_rf_rd_wdata;


/* Control Unit */
ControlUnit u_CU (
  .i_du_id_opcode     (du_id_opcode),
  .i_du_id_funct7     (du_id_funct7),
  .i_du_id_funct3     (du_id_funct3),
  .i_eu_alu_res_zero  (eu_alu_res_zero),
  .o_fu_pc_op_data    (cu_fu_pc_op_data),
  .o_eu_alu_imm_sel   (cu_eu_alu_imm_sel),
  .o_eu_alu_op_data   (cu_eu_alu_op_data),
  .o_eu_lsu_store_op  (),
  .o_eu_lsu_store_en  (),
  .o_eu_lsu_load_op   (),
  // .o_eu_dm_wvalid     (cu_dm_cu_wvalid),
  // .o_eu_dm_op_data    (cu_eu_dm_op_data),
  .o_du_rf_rd_wvalid  (cu_du_rf_rd_wvalid),
  .o_eu_wb_op_data    (cu_wb_op_data)
);

assign dbg_pc_op_data = cu_fu_pc_op_data;
assign dbg_alu_imm_sel = cu_eu_alu_imm_sel;
assign dbg_alu_op_data = cu_eu_alu_op_data;
assign dbg_dm_op_data = cu_eu_dm_op_data;
assign dbg_rf_rd_wvalid = cu_du_rf_rd_wvalid;
assign dbg_wb_op_data = cu_wb_op_data;

endmodule
