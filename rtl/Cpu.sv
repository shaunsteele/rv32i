// Cpu.sv

`default_nettype none

module Cpu # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Instruction Memory Bus
  output var logic  [XLEN-1:0]  o_im_raddr,
  input var         [XLEN-1:0]  i_im_rdata,

  // Data Memory Bus
  output var logic  [XLEN-1:0]  o_dm_addr,
  output var logic              o_dm_wvalid,
  output var logic  [XLEN-1:0]  o_dm_wdata,
  input var         [XLEN-1:0]  i_dm_rdata
);


/* Fetch Unit */
logic [2:0]       cu_fu_pc_op_data;
logic [XLEN-1:0]  du_id_imm;
logic [XLEN-1:0]  eu_alu_res_data;
logic [XLEN-1:0]  fu_pc_data;
logic [XLEN-1:0]  fu_pc_imm_data;
logic [XLEN01:0]  fu_pc_ret_data;
FetchUnit # (.XLEN(XLEN)) u_FU (
  .clk                (clk),
  .rstn               (rstn),
  .i_pc_op            (cu_fu_pc_op_data),
  .i_pc_id_imm_data   (du_id_imm),
  .i_pc_alu_res_data  (eu_alu_res_data),
  .o_pc_data          (fu_pc_data),
  .o_pc_imm_data      (fu_pc_imm_data),
  .o_pc_ret_data      (fu_pc_ret_data),
  .o_im_raddr         (o_im_raddr)
);


/* Decode Unit */
logic [6:0]       du_id_opcode;
logic [6:0]       du_id_funct7;
logic [2:0]       du_id_funct3;
logic [XLEN-1:0]  du_id_imm;
logic [XLEN-1:0]  du_rf_rs1_rdata;
logic [XLEN-1:0]  du_rf_rs2_rdata;
logic             cu_dU_rf_rd_wvalid;
logic [XLEN-1:0]  eu_wb_rf_rd_wdata;
DecodeUnit # (.XLEN(XLEN)) u_DU (
  .clk            (clk),
  .rstn           (rstn),
  .i_im_rdata     (i_im_rdata),
  .o_id_opcode    (du_id_opcode),
  .o_id_funct7    (du_id_funct7),
  .o_id_funct3    (du_id_funct3),
  .o_id_imm       (du_id_imm),
  .o_rf_rs1_rdata (du_rf_rs1_rdata),
  .o_rf_rs2_rdata (du_rf_rs2_rdata),
  .i_rf_rd_wvalid (cu_du_rf_rd_wvalid),
  .i_rf_rd_wdata  (eu_wb_rf_rd_wdata)
);


/* Execute Unit */
logic             cu_eu_alu_imm_sel;
logic [3:0]       cu_eu_alu_op_data;
logic             eu_alu_res_zero;
logic             cu_dm_cu_wvalid;
logic [2:0]       cu_wb_op_data;
logic             cu_eu_wb_dm_sel;
ExecuteUnit # (.XLEN(XLEN)) u_EU (
  .i_alu_id_imm       (du_id_imm),
  .i_alu_rf_rs1_rdata (du_rf_rs1_rdata),
  .i_alu_rf_rs2_rdata (du_rf_rs2_rdata),
  .i_alu_imm_sel      (cu_eu_alu_imm_sel),
  .i_alu_op_data      (cu_eu_alu_op_data),
  .o_alu_res_data     (eu_alu_res_data),
  .o_alu_res_zero     (eu_alu_res_zero),
  .i_dm_cu_wvalid     (cu_dm_cu_wvalid),
  .o_dm_addr          (o_dm_addr),
  .o_dm_wvalid        (o_dm_wvalid),
  .o_dm_wdata         (o_dm_wdata),
  .i_dm_rdata         (i_dm_rdata),
  .i_wb_op_data       (cu_wb_op_data),
  .i_wb_pc_imm_data   (fu_pc_imm_data),
  .i_wb_pc_ret_data   (fu_pc_ret_data),
  .o_wb_rf_wdata      (eu_wb_rf_rd_wdata)
);


/* Control Unit */
ControlUnit u_CU (
  .i_du_id_opcode     (du_id_opcode),
  .i_du_id_funct7     (du_id_funct7),
  .i_du_id_funct3     (du_id_funct3),
  .i_eu_alu_res_zero  (eu_alu_res_zero),
  .o_fu_pc_op_data    (cu_fu_pc_op_data),
  .o_eu_alu_imm_sel   (cu_eu_alu_imm_sel),
  .o_eu_alu_op_data   (cu_eu_alu_op_data),
  .o_eu_dm_wvalid     (cu_dm_cu_wvalid),
  .o_eu_dm_op_data    (cu_eu_dm_op_data),
  .o_du_rf_rd_wvalid  (cu_du_rf_rd_wvalid),
  .o_eu_wb_op_data    (cu_wb_op_data)
);


endmodule
