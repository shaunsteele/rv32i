// if_axi_lite.sv

`default_nettype none

interface if_axi_lite # (
  parameter int AXILADDRLEN = 32,
  parameter int AXILDATALEN = 32,
  parameter int AXILSTRBLEN = AXILDATALEN / 8
) (
  input var aclk,
  input var aresetn
);


/* Signals */
// Write Address Channel
logic                    awvalid;
logic                    awready;
logic [AXILADDRLEN-1:0]  awaddr;
logic [1:0]              awprot;

// Write Data Channel
logic                    wvalid;
logic                    wready;
logic [AXILDATALEN-1:0]  wdata;
logic [AXILSTRBLEN-1:0]  wstrb;

// Write Response Channel
logic                    bvalid;
logic                    bready;

// Read Address Channel
logic                    arvalid;
logic                    arready;
logic [AXILADDRLEN-1:0]  araddr;
logic [1:0]              arprot;

// Read Data Channel
logic                    rvalid;
logic                    rready;
logic [AXILDATALEN-1:0]  rdata;


/* Modports */
modport M (
  input   aclk, aresetn,
  output  awvalid, awaddr, awprot,
  input   awready,
  output  wvalid, wdata, wstrb,
  input   wready,
  output  bready,
  input   bvalid, bresp,
  output  arvalid, araddr, arprot,
  input   arready,
  output  rready,
  input   rvalid, rdata, rresp
);

modport S (
  input   aclk, aresetn,
  input   awvalid, awaddr, awprot,
  output  awready,
  input   wvalid, wdata, wstrb,
  output  wready,
  input   bready,
  output  bvalid, bresp,
  input   arvalid, araddr, arprot,
  output  arready,
  input   rready,
  output  rvalid, rdata, rresp
);

modport MON (
  input aclk, aresetn,
  input awvalid, awaddr, awprot,
  input awready,
  input wvalid, wdata, wstrb,
  input wready,
  input bready,
  input bvalid, bresp,
  input arvalid, araddr, arprot,
  input arready,
  input rready,
  input rvalid, rdata, rresp
);


endinterface
