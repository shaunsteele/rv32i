// execute_unit.sv

`default_nettype none

module execute_unit # (
  parameter int XLEN = 32
)(
  // ALU
  input var         [XLEN-1:0]  i_id_imm,
  input var         [XLEN-1:0]  i_alu_rf_rs1_rdata,
  input var         [XLEN-1:0]  i_alu_rf_rs2_rdata,
  input var                     i_alu_imm_sel,
  input var         [3:0]       i_alu_op_data,
  output var logic  [XLEN-1:0]  o_alu_res_data,
  output var logic              o_alu_res_zero,

  // Load Store Unit
  input var         [2:0]       i_cu_lsu_store_op,
  input var                     i_cu_lsu_store_en,
  input var         [1:0]       i_cu_lsu_load_op,

  // Data Memory Bus
  output var logic  [XLEN-1:0]  o_lsu_dm_addr,
  output var logic              o_lsu_dm_wvalid,
  output var logic  [XLEN-1:0]  o_lsu_dm_wdata,
  input var         [XLEN-1:0]  i_lsu_dm_rdata,

  // Write-back Signals
  input var         [2:0]       i_wb_op_data,
  input var         [XLEN-1:0]  i_wb_pc_imm_data,
  input var         [XLEN-1:0]  i_wb_pc_ret_data,
  output var logic  [XLEN-1:0]  o_wb_rf_rd_wdata
);


/* Integer Arithmetic Logic Unit */
logic [XLEN-1:0]  alu_res_data;
ArithmeticLogicUnit # (.XLEN(XLEN)) u_ALU (
  .i_id_imm       (i_id_imm),
  .i_rf_rs1_rdata (i_alu_rf_rs1_rdata),
  .i_rf_rs2_rdata (i_alu_rf_rs2_rdata),
  .i_imm_sel      (i_alu_imm_sel),
  .i_op_data      (i_alu_op_data),
  .o_res_data     (alu_res_data),
  .o_res_zero     (o_alu_res_zero)
);


/* Load Store Unit */
logic [XLEN-1:0]  lsu_wb_load_data;
LoadStoreUnit # (.XLEN(XLEN)) u_LSU (
  .i_cu_store_op      (i_cu_lsu_store_op),
  .i_cu_store_en      (i_cu_lsu_store_en),
  .i_cu_load_op       (i_cu_lsu_load_op),
  .i_alu_res_data     (alu_res_data),
  .i_alu_rf_rs2_rdata (i_alu_rf_rs2_rdata),
  .o_addr             (o_lsu_dm_addr),
  .o_wvalid           (o_lsu_dm_wvalid),
  .o_wdata            (o_lsu_dm_wdata),
  .i_rdata            (i_lsu_dm_rdata),
  .o_wb_load_data     (lsu_wb_load_data)
);


/* Write-back Logic */
// TODO: Finish connecting signals between LSU WBU and CU
WriteBackUnit # (.XLEN(XLEN)) u_WBU (
  .i_cu_wb_op       (i_cu_wb_op),
  .i_alu_res_data   (alu_res_data),
  .i_id_imm         (i_id_imm),
  .i_pc_imm_data    (i_wb_pc_imm_data),
  .i_pc_ret_data    (i_wb_pc_ret_data),
  .i_lsu_load_data  (lsu_wb_load_data),
  .o_rf_rd_wdata    (o_wb_rf_rd_wdata)
);

// always_comb begin
//   unique case (i_wb_op_data)
//     WbAlu:    o_wb_rf_rd_wdata = alu_res_data;
//     WbImm:    o_wb_rf_rd_wdata = i_id_imm;
//     WbPcImm:  o_wb_rf_rd_wdata = i_wb_pc_imm_data;
//     WbPcRet:  o_wb_rf_rd_wdata = i_wb_pc_ret_data;
//     WbDm:     o_wb_rf_rd_wdata = dm_rdata;
//     default: begin
//       o_wb_rf_rd_wdata = 0;
//       $warning("Unsupported Write-back Opcode: 0b%02b", i_wb_op_data);
//     end
//   endcase
// end


endmodule
