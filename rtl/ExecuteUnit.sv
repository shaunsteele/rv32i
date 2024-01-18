// ExecuteUnit.sv

`default_nettype none

module ExecuteUnit # (
  parameter int XLEN = 32
)(
  // ALU
  input var         [XLEN-1:0]  i_alu_id_imm,
  input var         [XLEN-1:0]  i_alu_rf_rs1_rdata,
  input var         [XLEN-1:0]  i_alu_rf_rs2_rdata,
  input var                     i_alu_imm_sel,
  input var         [3:0]       i_alu_op_data,
  output var logic  [XLEN-1:0]  o_alu_res_data,
  output var logic              o_alu_res_zero,

  // Data Memory Bus
  output var logic  [XLEN-1:0]  o_dm_addr,
  output var logic              o_dm_wvalid,
  output var logic  [XLEN-1:0]  o_dm_wdata,
  input var         [XLEN-1:0]  i_dm_rdata,

  // Write-back Signals
  input var         [XLEN-1:0]  i_wb_pc_ret_data,
  input var                     i_wb_mem_sel,
  output var logic  [XLEN-1:0]  o_wb_rf_rd_wdata
);


/* Integer Arithmetic Logic Unit */
logic [XLEN-1:0]  alu_res_data;
ArithmeticLogicUnit # (.XLEN(XLEN)) u_ALU (
  .i_id_imm       (i_alu_id_imm),
  .i_rf_rs1_rdata (i_alu_rf_rs1_rdata),
  .i_rf_rs2_rdata (i_alu_rf_rs2_rdata),
  .i_imm_sel      (i_alu_imm_sel),
  .i_op_data      (i_alu_op_data),
  .o_res_data     (alu_res_data),
  .o_res_zero     (o_alu_res_zero)
);


/* Memory Unit */
assign o_mem_addr = alu_res_data;
assign o_mem_wdata = i_alu_rf_rs2_data;


/* Write-back Logic */
always_comb begin
  if (i_wb_mem_sel) begin
    o_wb_rf_rd_wdata = i_mem_rdata;
  end else begin
    o_wb_rf_rd_wdata = alu_res_data;
  end
end


endmodule
