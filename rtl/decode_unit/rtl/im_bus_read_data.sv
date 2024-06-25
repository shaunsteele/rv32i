// im_bus_read_data.sv

`default_nettype none

module im_bus_read_data # (
  parameter int DLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // AXI5-Lite Read Data Interface
  input var                     i_im_bus_rvalid,
  output var logic              o_im_bus_rready,
  input var         [DLEN-1:0]  i_im_bus_rdata,
  input var         [1:0]       i_im_bus_rresp,
  input var         [ILEN-1:0]  i_im_bus_rid,

  // Execute Unit Interface
  input var 
);



endmodule
