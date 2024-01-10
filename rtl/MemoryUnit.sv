// MemoryUnit.sv

`default_nettype none

module MemoryUnit # (
  parameter int XLEN = 32,
  parameter int DMADDRLEN = 32,
  parameter int DMDATALEN = XLEN,
  parameter int DMSTRBLEN = DMDATALEN / 8
)(
  input var                         clk,
  input var                         rstn,

  input var         [DMADDRLEN-1:0] i_axaddr,

  input var                         i_awvalid,
  output var logic                  o_awready,

  input var                         i_arvalid,
  output var logic                  o_arready,

  input var                         i_wvalid,
  output var logic                  o_wready,
  input var         [DMDATALEN-1:0] i_wdata,
  input var         [DMSTRBLEN-1:0] i_wstrb,

  output var logic                  o_rvalid,
  input var                         i_rready,
  output var logic  [DMDATALEN-1:0] o_rdata,

  if_axi_lite.M                     m_axi
);

logic aw_en;
always_comb begin
  aw_en = i_awvalid & o_awready;
end

assign m_axi.awvalid = i_awvalid;
assign o_awready = m_axi.awready;

always_comb begin
  if (aw_en) begin
    m_axi.awaddr = i_axaddr;
  end else begin
    m_axi.awaddr = 0;
  end
end

logic ar_en;
always_comb begin
  ar_en = i_arvalid & o_arready;
end

assign m_axi.arvalid = i_arvalid;
assign o_arready = m_axi.arready;

always_comb begin
  if (ar_en) begin
    m_axi.araddr = i_axaddr;
  end else begin
    m_axi.araddr = 0;
  end
end

logic w_en;
always_comb begin
  w_en = i_wvalid & o_wdata;
end

assign m_axi.wvalid = i_wvalid;
assign o_wready = m_axi.wready;
assign m_axi.wstrb = i_wstrb;

always_comb begin
  if (w_en) begin
    m_axi.wdata = i_wdata;
  end else begin
    m_axi.wdata = 0;
  end
end

assign m_axi.bready = 1;

assign o_rvalid = m_axi.rrvalid;
assign m_axi.rready = 1;


endmodule
