// TbFetch.sv

`default_nettype none

module TbFetch # (
  parameter int XLEN = 32,
  parameter int IMADDRLEN = 32,
  parameter int IMDATALEN = XLEN,
  parameter int IMSTRBLEN = IMDATALEN / 8
)(
  input var                         clk,
  input var                         rstn,

  output var logic                  im_awvalid,
  input var                         im_awready,
  output var logic  [IMADDRLEN-1:0] im_awaddr,
  output var logic  [7:0]           im_awlen,
  output var logic  [2:0]           im_awsize,
  output var logic  [1:0]           im_awburst,
  output var logic  [2:0]           im_awprot,

  output var logic                  im_wvalid,
  input var                         im_wready,
  output var logic  [IMDATALEN-1:0] im_wdata,

  output var logic                  im_arvalid,
  input var                         im_arready,
  output var logic  [IMADDRLEN-1:0] im_araddr,
  output var logic  [7:0]           im_arlen,
  output var logic  [2:0]           im_arsize,
  output var logic  [1:0]           im_arburst,
  output var logic  [2:0]           im_arprot,

  input var                         im_rvalid,
  output var logic                  im_rready,
  input var         [IMDATALEN-1:0] im_rdata,
  input var                         im_rlast,


  output var logic                  o_dbg_state_valid,
  input var                         i_dbg_state_ready,
  output var state_e                o_dbg_state_data,
  output var logic  [IMDATALEN-1:0] o_dbg_instr_data,
  input var         [XLEN-1:0]      i_dbg_imm_data,
  input var         [1:0]           i_dbg_pc_incr_op,
  output var logic  [XLEN-1:0]      o_dbg_pc_data
);

assign im_awvalid = 0;
assign im_awaddr = 0;
assign im_awlen = 0;
assign im_awsize = 0;
assign im_awburst = 0;
assign im_awprot = 0;
assign im_wvalid = 0;
assign im_wdata = 0;

assign im_arlen = 0;
assign im_arsize = 3'b010;
assign im_arburst = 0;

if_axi4_lite # (
  .AXILADDRLEN  (IMADDRLEN),
  .AXILDATALEN  (IMDATALEN)
) u_axi_im(clk, rstn);

assign im_arvalid = u_axi_im.arvalid;
assign u_axi_im.arready = im_arready;
assign im_araddr = u_axi_im.araddr;
assign im_arprot = 3'b100; // instruction access
assign u_axi_im.rvalid = im_rvalid;
assign im_rready = u_axi_im.rready;
assign u_axi_im.rdata = im_rdata;

Core # (
  .XLEN       (XLEN),
  .IMADDRLEN  (IMADDRLEN),
  .IMDATALEN  (IMDATALEN)
) u_DUT (
  .clk                (clk),
  .rstn               (rstn),
  .im_if              (u_axi_im),
  .o_dbg_state_valid  (o_dbg_state_valid),
  .i_dbg_state_ready  (i_dbg_state_ready),
  .o_dbg_state_data   (o_dbg_state_data),
  .o_dbg_instr_data   (o_dbg_instr_data),
  .i_dbg_imm_data     (i_dbg_imm_data),
  .i_dbg_pc_incr_op   (i_dbg_pc_incr_op),
  .o_dbg_pc_data      (o_dbg_pc_data)
);

initial begin
  $dumpfile("waves.vcd");
  $dumpvars(0, u_axi_im);
  $dumpvars(0, u_DUT);
end

endmodule
