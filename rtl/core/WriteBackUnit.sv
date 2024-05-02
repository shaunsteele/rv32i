// WriteBackUnit.sv

`default_nettype none

module WriteBackUnit # (
  parameter int XLEN = 32
)(
  input var         [2:0]       i_cu_wb_op,
  input var         [XLEN-1:0]  i_alu_res_data,
  input var         [XLEN-1:0]  i_id_imm,
  input var         [XLEN-1:0]  i_pc_imm_data,
  input var         [XLEN-1:0]  i_pc_ret_data,
  input var         [XLEN-1:0]  i_lsu_load_data,
  output var logic  [XLEN-1:0]  o_rf_rd_wdata
);

always_comb begin
  unique case (i_cu_wb_op)
    WbAlu:    o_rf_rd_wdata = alu_res_data;
    WbImm:    o_rf_rd_wdata = i_id_imm;
    WbPcImm:  o_rf_rd_wdata = i_pc_imm_data;
    WbPcRet:  o_rf_rd_wdata = i_wb_pc_ret_data;
    WbLsu:    o_rf_rd_wdata = i_lsu_load_data;
    default: begin
      o_rf_rd_wdata = 0;
      $warning("Unsupported Write-back Opcode: 0b%02b", i_cu_wb_op);
    end
  endcase
end

endmodule
