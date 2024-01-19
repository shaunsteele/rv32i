// ExecuteUnit.sv

`default_nettype none

module ExecuteUnit # (
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

  // Data Memory Bus
  input var logic               i_dm_cu_wvalid,
  input var logic   [2:0]       i_dm_op_data,
  output var logic  [XLEN-1:0]  o_dm_addr,
  output var logic              o_dm_wvalid,
  output var logic  [XLEN-1:0]  o_dm_wdata,
  input var         [XLEN-1:0]  i_dm_rdata,

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


/* Memory Unit */
assign o_dm_wvalid = i_dm_cu_wvalid;
assign o_dm_addr = alu_res_data;
always_comb begin
  unique case (i_dm_op_data)
    MemW:         o_dm_wdata  = i_alu_rf_rs2_rdata;
    MemH, MemHU:  o_dm_wdata  = {
                                  {(XLEN-16){i_alu_rf_rs2_rdata[15]}},
                                  i_alu_rf_rs2_rdata[15:0]
                                };
    MemB, MemBU:  o_dm_wdata  = {
                                  {(XLEN-7){i_alu_rf_rs2_rdata[7]}},
                                  i_alu_rf_rs2_rdata[7:0]
                                };
    default: begin
      o_dm_wdata = 0;
      $warning("Unsupported Memory Write Opcode: 0b%02b", i_dm_op_data);
    end
  endcase
end

logic [XLEN-1:0] dm_rdata;
always_comb begin
  unique case (i_dm_op_data)
    MemW:   dm_rdata  = i_dm_rdata;
    MemH:   dm_rdata  = {
                          {(XLEN-16){i_dm_rdata[15]}},
                          i_dm_rdata[15:0]
                        };
    MemHU:  dm_rdata  = {
                          {(XLEN-16){1'b0}},
                          i_dm_rdata[15:0]
                        };
    MemB:   dm_rdata  = {
                          {(XLEN-8){i_dm_rdata[7]}},
                          i_dm_rdata[7:0]
                        };
    MemBU:  dm_rdata  = {
                          {(XLEN-8){1'b0}},
                          i_dm_rdata[7:0]
                        };
    default: begin
      dm_rdata = 0;
      $warning("Unsupported Memory Read Opcode: 0b%02b", i_dm_op_data);
    end
  endcase
end


/* Write-back Logic */
always_comb begin
  unique case (i_wb_op_data)
    WbAlu:    o_wb_rf_rd_wdata = alu_res_data;
    WbImm:    o_wb_rf_rd_wdata = i_id_imm;
    WbPcImm:  o_wb_rf_rd_wdata = i_wb_pc_imm_data;
    WbPcRet:  o_wb_rf_rd_wdata = i_wb_pc_ret_data;
    WbDm:     o_wb_rf_rd_wdata = dm_rdata;
    default: begin
      o_wb_rf_rd_wdata = 0;
      $warning("Unsupported Write-back Opcode: 0b%02b", i_wb_op_data);
    end
  endcase
end


endmodule
