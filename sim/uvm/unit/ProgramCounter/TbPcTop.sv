// TbPcTop.sv

`default_nettype none

module TbPcTop;


`include "uvm.sv"
import uvm_pkg::*;


/* Clock & Reset Generation */
parameter real PERIOD = 10.0;
bit clk;
initial begin
  clk = 0;
  #PERIOD;
  forever #(PERIOD/2) clk = ~clk;
end

parameter int RESET_CYCLES = 10;
bit rstn;
initial begin
  rstn = 0;
  repeat (RESET_CYCLES) @(negedge clk);
  rstn = 1;
end


/* Interface Instantiations */
if_pc u_pc (.clk(clk), .rstn(rstn));


/* DUT Instantiation */
ProgramCounter # (.XLEN(XLEN)) u_DUT (
  .clk            (clk),
  .rstn           (rstn),
  .i_op           (u_pc.op),
  .i_id_imm_data  (u_pc.dec_imm),
  .i_alu_res_data (u_pc.alu_res),
  .o_data         (u_pc.data),
  .o_imm_data     (u_pc.branch),
  .o_ret_data     (u_pc.ret)
);

/* Dump Waves */
initial begin
  $dumpfile("waves.vcd");
  $dumpvars(u_pc);
  $dumpvars(u_DUT);
end
endmodule
