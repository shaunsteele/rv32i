// store_unit.sv

`default_nettype none

module store_unit import riscv_pkg::*;
# (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // AXI4-Lite Data Memory Write Address Channel
  output var logic              o_dm_awvalid,
  input var                     i_dm_awready,
  output var logic  [XLEN-1:0]  o_dm_awaddr,

  // AXI4-Lite Data Memory Write Data Channel
  output var logic              o_dm_wvalid,
  input var                     i_dm_wready,
  output var logic  [XLEN-1:0]  o_dm_wdata,

  // Decode Unit
  input var                     i_du_valid,
  output var logic              o_su_ready,
  input var         [6:0]       i_du_opcode,
  input var         [2:0]       i_du_funct3,
  input var         [XLEN-1:0]  i_du_immediate,
  input var         [XLEN-1:0]  i_du_rf_rs1_rdata,
  input var         [XLEN-1:0]  i_du_rf_rs2_rdata
);

always_comb begin
  o_su_ready = i_dm_awready & i_dm_wready;
end

// 
always_ff @(posedge clk) begin
  if (!rstn) begin
    
  end
end

endmodule
