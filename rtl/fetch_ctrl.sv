// fetch_ctrl.sv

`default_nettype none

module fetch_ctrl import riscv_pkg::*;
# (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,
  
  // AXI4-Lite Master Read Address Channel
  output var logic              o_im_arvalid,
  input var logic               i_im_arready,
  output var logic  [XLEN-1:0]  o_im_araddr,

  // Program Counter
  output var logic              o_pc_en,
  input var         [XLEN-1:0]  i_pc_addr
);


always_comb begin
  o_pc_en = o_im_arvalid & i_im_arready;
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_im_arvalid <= 0;
  end else begin
    o_im_arvalid <= 1;
  end
end

assign o_im_araddr = i_pc_addr;

endmodule
