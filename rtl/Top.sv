// Top.sv

`default_nettype none

module Top # (

)(
  // System Clock and Reset
  input var sys_clk,
  input var sys_rstn//,

  // Serial Interface PHY
  // TODO: Serial Controller
);


/* System Signals */
logic clk;
assign clk = sys_clk;

logic rstn;
assign rstn = sys_rstn;


/* Memory Units */
// Instruction Memory
parameter int IMLEN = 1024;
parameter int IMALEN = $clog2(MLEN);

logic [31:0]              core_im_raddr;
logic [IMALEN-1:0]  im_raddr;
assign im_raddr = core_im_raddr[IMALEN-1:0];

MemoryDriver # (
  .BLEN (8),
  .WLEN (4),
  .MLEN (1024)
) u_IM (
  .clk      (clk),
  .rstn     (rstn),
  .i_wvalid (1'b0),
  .i_waddr  (0),
  .i_wdata  (0),
  .i_rvalid (1'b1),
  .i_raddr  (core_im_raddr),
  .o_rdata  (im_rdata)
);


// Memory Bus Driver
parameter int DMLEN = 4096;
parameter int DMALEN = $clog(DMLEN);

logic               core_dm_wvalid;
logic [31:0]        core_dm_addr;
logic [DMALEN-1:0]  dm_addr;
assign dm_addr = core_dm_addr[DMALEN-1:0];
logic               core_dm_wdata;
logic [31:0]        dm_rdata;

MemoryDriver # (
  .BLEN (8),
  .WLEN (4),
  .MLEN (4096)
) u_DM (
  .clk        (clk),
  .rstn       (rstn),
  .i_wvalid   (core_dm_wvalid),
  .i_waddr    (dm_addr),
  .i_wdata    (core_dm_wdata),
  .i_rvalid   (1'b1),
  .i_raddr    (dm_addr),
  .o_rdata    (dm_rdata)
);


// UART Controller


// RV32I Core
Core # (.XLEN(32)) u_CPU (
  .clk      (clk),
  .rstn     (rstn),
  .o_im_raddr   (core_im_raddr),
  .i_im_rdata   (im_rdata),
  .o_dm_addr    (core_dm_addr),
  .o_dm_wvalid  (core_dm_wvalid),
  .o_dm_wdata   (core_dm_wdata),
  .i_dm_rdata   (dm_rdata)
);


endmodule
