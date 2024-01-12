//  Core.sv
//    Hierarchical Module instantiating datapath units

`default_nettype none

`include "riscv.svh"

module Core # (
  parameter int XLEN = 32,
  parameter int IMADDRLEN = 8,
  parameter int IMDATALEN = XLEN,
  parameter int DMADDRLEN = 8,
  parameter int DMDATALEN = XLEN,
  parameter int DMSTRBLEN = DMDATALEN / 8
)(
  input var       clk,
  input var       rstn,

  if_axi4_lite.M  im_if,  // Instruction Memory Interface
  // if_axi_lite.M dm_if   // Data Memory Interface

  // Debug Signals
  output var logic              o_dbg_state_valid,
  input var                     i_dbg_state_ready,
  output var state_e            o_dbg_state_data,
  output var logic  [XLEN-1:0]  o_dbg_instr_data,
  input var         [XLEN-1:0]  i_dbg_imm_data,
  output var logic  [XLEN-1:0]  o_dbg_pc_data
);


/* Fetch Unit */
logic             cu_fetch_valid;
logic             eu_pc_valid;
logic             fu_fetch_ready;
logic [XLEN-1:0]  eu_pc_data;
logic             sb_fetch_valid;
logic             sb_fetch_ready;
logic [XLEN-1:0]  sb_fetch_addr;

SkidBuffer # (XLEN) u_FETCH_BUF (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (cu_fetch_valid & eu_pc_valid),
  .o_ready  (fu_fetch_ready),
  .i_data   (eu_pc_data),
  .o_valid  (sb_fetch_valid),
  .i_ready  (sb_fetch_ready),
  .o_data   (sb_fetch_addr)
);

logic             fu_instr_valid;
logic             cu_instr_ready;
logic [XLEN-1:0]  fu_instr_data;
FetchUnit # (
  .XLEN       (XLEN),
  .IMDATALEN  (IMDATALEN)
) u_FU (
  .clk            (clk),
  .rstn           (rstn),
  .i_fetch_valid  (sb_fetch_valid),
  .o_fetch_ready  (sb_fetch_ready),
  .i_fetch_addr   (sb_fetch_addr),
  .o_instr_valid  (fu_instr_valid),
  .i_instr_ready  (cu_instr_ready),
  .o_instr_data   (o_dbg_instr_data),
  .m_axi          (im_if)
);



/* Execute Unit */
logic       cu_execute_valid;
logic       eu_execute_ready;
logic [1:0] cu_pc_incr_op;
ExecuteUnit # (
  .XLEN (XLEN)
) u_EU (
  .clk              (clk),
  .rstn             (rstn),
  .i_execute_valid  (cu_execute_valid),
  .o_execute_ready  (eu_execute_ready),
  .i_imm_data       (i_dbg_imm_data),
  .i_pc_incr_op     (cu_pc_incr_op),
  .o_pc_valid       (eu_pc_valid),
  .o_pc_data        (o_dbg_pc_data)
);


/* Control Unit */
ControlUnit # (.XLEN(XLEN)) u_CU (
  .clk                  (clk),
  .rstn                 (rstn),
  .o_sm_state_valid     (o_dbg_state_valid),
  .i_sm_state_ready     (i_dbg_state_ready),
  .o_sm_state_data      (o_dbg_state_data),
  // Fetch Unit
  .o_fu_fetch_valid     (cu_fetch_valid),
  .i_fu_fetch_ready     (fu_fetch_ready),
  .i_fu_instr_valid     (fu_instr_valid),
  .o_fu_instr_ready     (cu_instr_ready),
  // Execute Unit - Program Counter
  .o_eu_execute_valid   (cu_execute_valid),
  .i_eu_execute_ready   (eu_execute_ready),
  .o_eu_pc_incr_op      (cu_pc_incr_op)
);

endmodule
