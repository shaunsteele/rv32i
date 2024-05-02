// execute_unit.sv

`default_nettype none

module execute_unit import riscv_pkg::*;
# (
  parameter int XLEN = 32
)(
  input var           clk,
  input var           rstn,

  // Upstream Decoder Handshake
  input var           i_du_valid,
  output var logic    o_ex_ready,

  // Integer Unit

  // Load
)