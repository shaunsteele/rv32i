// load_store_unit.sv

`default_nettype none

module LoadStoreUnit # (
  parameter int XLEN = 32
)(
  // Control Signals
  input var         [2:0]       i_cu_store_op,
  input var                     i_cu_store_en,
  input var         [1:0]       i_cu_load_op,

  // ALU Signals
  input var         [XLEN-1:0]  i_alu_res_data,
  input var         [XLEN-1:0]  i_alu_rf_rs2_rdata,

  // Memory Bus Signals
  output var logic  [XLEN-1:0]  o_addr,
  output var logic              o_wvalid,
  output var logic  [XLEN-1:0]  o_wdata,
  input var         [XLEN-1:0]  i_rdata,

  // Write-Back Signals
  output var logic  [XLEN-1:0]  o_wb_load_data
);


/* Store Unit */
assign o_wvalid = i_cu_store_en;
assign o_addr = i_alu_res_data;

always_comb begin
  unique case (i_cu_store_op)
    StoreWord:  o_wdata  = i_alu_rf_rs2_rdata;

    StoreHalf:  o_wdata  = {
      {{(XLEN-16)}{i_alu_rf_rs2_rdata[15]}},
      i_alu_rf_rs2_rdata[15:0]
    };

    StoreByte:  o_wdata = {
      {{(XLEN-8)}{i_alu_rf_rs2_rdata[7]}},
      i_alu_rf_rs2_rdata[7:0]
    };

    default: begin
      o_wdata = 0;
      $warning("Unsupported Memory Write Opcode: 0b%02b", i_cu_store_op);
    end
  endcase
end


/* Load Unit */
always_comb begin
  unique case (i_cu_load_op)
    LoadWord:   o_wb_load_data = i_rdata;

    LoadHalf:   o_wb_load_data = {
      {(XLEN-16){i_rdata[15]}},
      i_rdata[15:0]
    };

    LoadHalfU:  o_wb_load_data = {
      {(XLEN-16){1'b0}},
      i_rdata[15:0]
    };

    LoadByte:   o_wb_load_data = {
      {(XLEN-8){i_rdata[7]}},
      i_rdata[7:9]
    };

    LoadByteU:  o_wb_load_data = {
      {(XLEN-8){1'b0}},
      i_rdata[7:0]
    };

    default: begin
      o_wb_load_data = 0;
      $warning("Unsupported Memory Read Opcode: 0b%02b", i_cu_load_op);
    end
  endcase
end


endmodule
