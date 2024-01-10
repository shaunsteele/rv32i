//  Core.sv
//    Hierarchical Module instantiating datapath units

`default_nettype none

`include "riscvPkg.sv"

module Core # (
  parameter int XLEN = 32,
  parameter int IMADDRLEN = 8,
  parameter int IMDATALEN = XLEN,
  parameter int DMADDRLEN = 8,
  parameter int DMDATALEN = XLEN,
  parameter int DMSTRBLEN = DMDATALEN / 8
)(
  input var     clk,
  input var     rstn,

  if_axi_lite.M im_if,  // Instruction Memory Interface
  if_axi_lite.M dm_if   // Data Memory Interface
);


/* Fetch Unit */
logic cu_fetch_valid;
logic fu_fetch_ready;
logic [XLEN-1:0] eu_pc_data;
logic fetch_valid;
logic fetch_ready;
logic [XLEN-1:0] fetch_addr;
SkidBuffer # (XLEN) u_FU_FETCH_BUF (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (cu_fetch_valid),
  .o_ready  (fu_fetch_ready),
  .i_data   (eu_pc_data),
  .o_valid  (fetch_valid),
  .i_ready  (fetch_ready),
  .o_data   (fetch_addr)
);

logic fu_instr_valid;
logic fu_instr_ready;
logic [DMDATALEN-1:0] fu_instr_data;
FetchUnit # (
  .XLEN       (XLEN),
  .IMADDRLEN  (IMADDRLEN)
) u_FU (
  .clk            (clk),
  .rstn           (rstn),
  .i_fetch_valid  (fetch_valid),
  .o_fetch_ready  (fetch_ready),
  .i_fetch_addr   (fetch_addr),
  .o_instr_valid  (fu_instr_valid),
  .i_instr_ready  (fu_instr_ready),
  .o_instr_data   (fu_instr_data),
  .m_axi          (im_if)
);

/* Decode Unit */
logic id_instr_valid;
logic id_instr_ready;
logic [XLEN-1:0] id_instr_data;
logic cu_instr_ready;
SkidBuffer # (XLEN) u_ID_INSTR_BUF (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (fu_instr_valid),
  .o_ready  (fu_instr_ready),
  .i_data   (fu_instr_data),
  .o_valid  (id_instr_valid),
  .i_ready  (id_instr_ready & cu_instr_ready),  // Confirm Logic
  .o_data   (id_instr_data)
);

logic             id_dec_valid;
logic             id_dec_ready;
logic [6:0]       id_dec_opcode;
logic [6:0]       id_dec_funct7;
logic [2:0]       id_dec_funct3;
logic [XLEN-1:0]  id_dec_imm;
logic [4:0]       id_dec_rs2;
logic [4:0]       id_dec_rs1;
logic [4:0]       id_dec_rd;
InstructionDecoder # (
  .XLEN (XLEN)
) u_ID (
  .clk            (clk),
  .rstn           (rstn),
  .i_instr_valid  (id_instr_valid),
  .o_instr_ready  (id_instr_ready),
  .i_instr_data   (id_instr_data),
  .o_dec_valid    (id_dec_valid),
  .i_dec_ready    (id_dec_ready),
  .o_dec_opcode   (id_dec_opcode),
  .o_dec_funct7   (id_dec_funct7),
  .o_dec_funct3   (id_dec_funct3),
  .o_dec_imm      (id_dec_imm),
  .o_dec_rs2      (id_dec_rs2),
  .o_dec_rs1      (id_dec_rs1),
  .o_dec_rd       (id_dec_rd)   
);

/* Register File */
logic [32+XLEN-1:0] id_dec_data;
assign id_dec_data = {
  id_dec_imm,
  id_dec_opcode,
  id_dec_funct7,
  id_dec_funct3,
  id_dec_rs2,
  id_dec_rs1,
  id_dec_rd
};

logic rf_dec_valid;
logic rf_dec_ready;
logic [32+XLEN-1:0] rf_dec_data;
SkidBuffer # (32 + XLEN) u_RF_ADDR_BUF (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (id_dec_valid),
  .o_ready  (id_dec_ready),
  .i_data   (id_dec_data),
  .o_valid  (),
  .i_ready  (),
  .o_data   (rf_dec_data)
);

logic [XLEN-1:0]  rf_imm;
assign rf_imm = rf_dec_data[32+XLEN-1:32];

logic [6:0]       rf_opcode;
assign rf_opcode = rf_dec_data[31:25];

logic [6:0]       rf_funct7;
assign rf_funct7 = rf_dec_data[24:18];

logic [2:0]       rf_funct3;
assign rf_funct3 = rf_dec_data[17:15];

logic [4:0]       rf_rs2;
assign rf_rs2 = rf_dec_data[14:10]

logic [4:0]       rf_rs1;
assign rf_rs1 = rf_dec_data[9:5];

logic [4:0]       rf_rd;
assign rf_rd = rf_dec_data[4:0]

RegisterFile # (
  .XLEN (XLEN)
) u_RF (
  .clk            (clk),
  .rstn           (rstn),
  .i_rs_arvalid   (rf_dec_valid),
  .o_rs_arready   (rf_dec_ready),
  .i_rs2_ardata   (rf_rs2),
  .i_rs1_ardata   (rf_rs1),
  .o_rs2_rvalid   (),
  .i_rs2_rready   (),
  .o_rs2_rdata    (),
  .o_rs1_rvalid   (),
  .i_rs1_rready   (),
  .o_rs1_rdata    (),
  .i_rd_wvalid    (),
  .o_rd_wready    (),
  .i_rd_waddr     (),
);


/* Execute Unit */
ExecuteUnit # (
  .XLEN (XLEN)
) u_EU (
  .clk                (clk),
  .rstn               (rstn),
  .i_imm_valid        (),
  .o_imm_ready        (),
  .i_imm_data         (),
  .i_rs2_rvalid       (),
  .o_rs2_rready       (),
  .i_rs2_rdata        (),
  .i_rs1_rvalid       (),
  .o_rs1_rready       (),
  .i_rs1_rdata        (),
  .i_pc_incr_valid    (),
  .o_pc_incr_ready    (),
  .i_pc_incr_op       (),
  .i_pc_incr_alu_sel  (),
  .o_pc_valid         (),
  .o_pc_data          (),
  .i_alu_op_valid     (),
  .o_alu_op_ready     (),
  .i_alu_op_data      (),
  .i_alu_a_pc_sel     (),
  .i_alu_b_imm_sel    (),
  .o_alu_f_valid      (),
  .o_alu_f_ready      (),
  .o_alu_f_data       (),
  .o_alu_z_valid      (),
  .o_eu_mem_wvalid    (),
  .i_eu_mem_wready    (),
  .o_eu_mem_wstrb     (),
  .o_eu_mem_arvalid   (),
  .i_eu_mem_arready   (),
  .o_eu_mem_arsize    (),
  .o_eu_mem_arsign    (),
  .i_eu_mem_rvalid    (),
  .o_eu_mem_rready    ()
);


/* Control Unit */
ControlUnit # (.XLEN(XLEN)) u_CU (
  .clk  (clk),
  .rstn (rstn),
  .o_state_valid  (),
  .i_state_ready  (1),
  .o_state_data   (),
  .o_fu_fetch_valid (cu_fetch_valid),
  .i_fu_fetch_ready (fu_fetch_ready),
  .i_fu_instr_valid (fu_instr_valid),
  .o_fu_instr_ready (cu_instr_ready),
  .i_fu_instr_data  (fu_instr_data),
)
endmodule
