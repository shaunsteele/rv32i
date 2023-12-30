// MemoryUnit.sv

`default_nettype none

module MemoryUnit # (
  parameter int XLEN = 32,
  parameter int AXILADDRLEN = 32,
  parameter int AXILDATALEN = 32,
  parameter int AXILSTRBLEN = AXILDATALEN / 8,
  parameter int RAM_DEPTH = 1
)(
  input var clk,
  input var rstn,

  input var         [AXILADDRLEN-1:0] i_addr,

  input var                           i_wen,
  input var         [AXILSTRBLEN-1:0] i_wstrb,
  input var         [XLEN-1:0]        i_wdata,
  output var logic                    o_wvalid,

  input var                           i_ren,
  output var logic  [AXILDATALEN-1:0] o_rdata,
  output var logic                    o_rvalid,

  if_axi_lite.M                       axi  // Interface to Data Memory
);

/* Input Buffer for Latching */
logic wen_q;
Fdre u_Wen_q (.clk(clk), .rstn(rstn), .d(i_wen), .q(wen_q));

logic ren_q;
Fdre u_Ren_q (.clk(clk), .rstn(rstn), .d(i_ren), .q(ren_q));


/* Write Address Channel */
// Latch Valid and Address until Ready is asserted independent of write enable
logic awvalid_q;
logic [AXILADDRLEN-1:0] awaddr_q;

always_comb begin
  if (i_wen) begin
    axi.awvalid = 1;
    axi.awaddr = i_addr;
  end else begin
    if (wen_q) begin
      axi.awvalid = awvalid_q & ~axi.awready;
      axi.awaddr = awaddr_q;
    end else begin
      axi.awvalid = 0;
      axi.awaddr = i_addr;
    end
  end
end

Fdre u_Awvalid_q (.clk(clk), .rstn(rstn), .d(axi.awvalid), .q(awvalid_q));

Fdre # (.W(AXILADDRLEN)) u_Awaddr_q (
  .clk(clk), .rstn(rstn), .d(axi.awaddr), .q(awaddr_q)
);

assign axi.awprot = 2'b00;


/* Write Data Channel */
// Latch Valid and Address until Ready is asserted independent of write enable
logic wvalid_q;
logic [AXILADDRLEN-1:0] wdata_q;
logic [AXILSTRBLEN-1:0] wstrb_q;

always_comb begin
  if (i_wen) begin
    axi.wvalid = 1;
    axi.wdata = i_wdata;
    axi.wstrb = i_wstrb;
  end else begin
    if (wen_q) begin
      axi.wvalid = wvalid_q & ~axi.wready;
      axi.wdata = wdata_q;
      axi.wstrb = wstrb_q;
    end else begin
      axi.wvalid = 0;
      axi.wdata = i_wdata;
      axi.wstrb = i_wstrb;
    end
  end
end

Fdre u_Wvalid_q (.clk(clk), .rstn(rstn), .d(axi.wvalid), .q(wvalid_q));

Fdre # (.W(AXILDATALEN)) u_Wdata_q (
  .clk(clk), .rstn(rstn), .d(axi.wdata), .q(wdata_q)
);

Fdre # (.W(AXILSTRBLEN)) u_Wstrb_q (
  .clk(clk), .rstn(rstn), .d(axi.wstrb), .q(wstrb_q)
);


/* Write Response Channel */
always_ff @(posedge clk) begin
  if (!rstn) begin
    axi.bready <= 0;
  end else begin
    axi.bready <= 1;
  end
end

always_comb begin
  if (axi.bready && axi.bvalid) begin
    o_w_valid = axi.bresp == 2'b00;
  end else begin
    o_w_valid = 0;
  end
end

/* Read Address Channel */
// Latch Valid and Address until Ready is asserted independent of write enable
logic arvalid_q;
logic [AXILADDRLEN-1:0] araddr_q;

always_comb begin
  if (i_ren) begin
    axi.arvalid = 1;
    axi.araddr = i_addr;
  end else begin
    if (ren_q) begin
      axi.arvalid = arvalid_q & ~axi.arready;
      axi.araddr = araddr_q;
    end else begin
      axi.arvalid = 0;
      axi.araddr = i_addr;
    end
  end
end

Fdre u_Awvalid_q (.clk(clk), .rstn(rstn), .d(axi.awvalid), .q(awvalid_q));

Fdre # (.W(AXILADDRLEN)) u_Awaddr_q (
  .clk(clk), .rstn(rstn), .d(axi.awaddr), .q(awaddr_q)
);

assign axi.awprot = 2'b00;


/* Read Data Channel */
always_ff @(posedge clk) begin
  if (!rstn) begin
    axi.rready <= 0;
  end else begin
    axi.rready <= 1;
  end
end

always_comb begin
  o_r_valid = axi.rready & axi.rvalid;
end

logic [AXILDATALEN-1:0] next_rdata;
always_comb begin
  if (o_rvalid) begin
    next_rdata = axi.rdata;
  end else begin
    next_rdata = o_rdata;
  end
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_rdata <= 0;
  end else begin
    o_rdata <= next_rdata;
  end
end

endmodule
