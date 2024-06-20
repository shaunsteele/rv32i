// if_pc.sv

`default_nettype none

interface if_pc # (
  parameter int XLEN = 32,
  parameter int SETUP = 1,
  parameter int HOLD = 1
)(
  input var clk,
  input var rstn
);

// Control Signal
logic [2:0]       op;

// Jump/Branch Input values
logic [XLEN-1:0]  dec_imm;
logic [XLEN-1:0]  alu_res;

// Outputs
logic [XLEN-1:0]  data;
logic [XLEN-1:0]  branch;
logic [XLEN-1:0]  ret;

// Clocking Block
clocking cb @(posedge clk);
  default input #SETUP output #HOLD;
  output op;
  output dec_imm;
  output alu_res;
  input data;
  input branch;
  input ret;
endclocking

modport DUT (
  input clk, rstn,
  clocking cb
);


endinterface
