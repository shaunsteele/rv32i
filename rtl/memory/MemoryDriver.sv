// MemoryDriver.sv

`default_nettype none

module MemoryDriver # (
  parameter int BLEN = 8,
  parameter int WLEN = 4,
  parameter int DLEN = BLEN * WLEN,
  parameter int MLEN = 1024,
  parameter int ALEN = $clog2(MLEN)
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_wvalid,
  input var         [ALEN-1:0]  i_waddr,
  input var         [DLEN-1:0]  i_wdata,

  input var                     i_rvalid,
  input var         [ALEN-1:0]  i_raddr,
  output var logic  [DLEN-1:0]  o_rdata
);


SdpRam1 # (
  .BLEN (BLEN),
  .WLEN (WLEN),
  .MLEN (MLEN)
) u_RAM (
  .clk    (clk),
  .i_wvalid (i_wvalid),
  .i_waddr  (i_waddr),
  .i_wdata  (i_wdata),
  .i_rvalid (i_rvalid),
  .i_waddr  (i_waddr),
  .o_rdata  (o_rdata)
);


endmodule
