// execute_unit.sv

`default_nettype none

module execute_unit # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Decode Integer Unit Interface
  input var                     i_alu_en,
  input var         [9:0]       i_alu_op,
  input var         [XLEN-1:0]  i_alu_src1,
  input var         [XLEN-1:0]  i_alu_src1,
  input var         [4:0]       i_alu_waddr,

  // Decode Write Back Interface
  output var logic              o_wb_rd_wvalid,
  output var logic  [4:0]       o_wb_rd_waddr,
  output var logic  [XLEN-1:0]  o_wb_rd_wdata
);

//
logic alu_valid;
logic [4:0] alu_wb_waddr;
logic [XLEN-1:0]  alu_res;
integer_unit # (.XLEN(XLEN)) u_IU (
  .clk        (clk),
  .rstn       (rstn),
  .i_en       (i_alu_en),
  .i_op       (i_alu_op),
  .i_src1     (i_alu_src1),
  .i_src2     (i_alu_src2),
  .i_waddr    (i_alu_waddr),
  .o_valid    (alu_valid),
  .o_wb_waddr (alu_wb_waddr),
  .o_res      (alu_res)
);

// Writ Back Registers
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_wb_rd_wvalid <= 0;
  end else begin
    o_wb_rd_wvalid <= alu_valid;
  end
end

always_ff @(posedge clk) begin
  o_wb_rd_waddr <= alu_wb_waddr;
  o_wb_rd_wdata <= alu_res;
end

endmodule
