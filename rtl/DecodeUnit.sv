// DecodeUnit.sv

`default_nettype none

module DecodeUnit # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,
  // Instruction Decode
  input var         [XLEN-1:0]  i_im_rdata,
  output var logic  [XLEN-1:0]  o_id_opcode,
  output var logic  [6:0]       o_id_funct7,
  output var logic  [2:0]       o_id_funct3,
  output var logic  [XLEN-1:0]  o_id_imm,

  // Register File
  output var logic  [XLEN-1:0]  o_rf_rs1_rdata,
  output var logic  [XLEN-1:0]  o_rf_rs2_rdata,
  input var         [XLEN-1:0]  i_rf_rd_wvalid,
  input var         [XLEN-1:0]  i_rf_rd_wdata
);


/* Instruction Decode */
logic [4:0] id_rs2_raddr;
logic [4:0] id_rs1_raddr;
logic [4:0] id_rd_raddr;
InstructionDecode # (.XLEN(XLEN)) u_ID (
  .i_im_rdata   (i_im_rdata),
  .o_opcode     (o_id_opcode),
  .o_funct7     (o_id_funct7),
  .o_funct3     (o_id_funct3),
  .o_imm        (o_id_imm),
  .o_rs2_raddr  (id_rs2_raddr),
  .o_rs2_raddr  (id_rs2_raddr),
  .o_rd_waddr   (id_rd_waddr)
);


/* Register File */
RegisterFile # (.XLEN(XLEN)) u_RF (
  .clk          (clk),
  .rstn         (rstn),
  .i_rs1_raddr  (id_rs1_raddr),
  .o_rs1_rdata  (o_rf_rs1_rdata),
  .i_rs2_raddr  (id_rs2_raddr),
  .o_rs2_rdata  (o_rf_rs2_rdata),
  .i_rd_wvalid  (i_rf_rd_wvalid),
  .i_rd_waddr   (id_rd_waddr),
  .i_rd_wdata   (i_rf_rd_wdata)
);


endmodule
