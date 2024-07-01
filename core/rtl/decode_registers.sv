// decode_registers.sv

`default_nettype none

module decode_registers # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // instruction bus read data
  input var                     i_im_rvalid,
  output var logic              o_im_rready,
  input var         [XLEN-1:0]  i_im_rdata,
  input var         [1:0]       i_im_rresp,

  // control transfer
  output var logic  [2:0]       o_ct_funct3,
  output var logic  [XLEN-1:0]  o_ct_rs1_rdata,
  output var logic  [XLEN-1:0]  o_ct_rs2_rdata,
  output var logic  [XLEN-1:0]  o_ct_immediate,
  output var logic              o_ct_br_en,
  output var logic              o_ct_jump_en,
  output var logic              o_ct_jump_reg_sel,

  // integer alu
  output var logic              o_int_en,
  output var logic  [9:0]       o_int_funct,
  output var logic  [XLEN-1:0]  o_int_src1,
  output var logic  [XLEN-1:0]  o_int_src2,

  // upper
  input var                     i_ct_up_pc_valid,
  input var logic   [XLEN-1:0]  i_ct_up_pc,
  output var logic              o_up_en,
  output var logic  [XLEN-1:0]  o_up_imm,
  output var logic              o_up_pc_sel,
  output var logic  [XLEN-1:0]  o_up_pc,

  // load store
  output var logic  [XLEN-1:0]  o_lsu_base,
  output var logic  [XLEN-1:0]  o_lsu_offset,
  output var logic  [2:0]       o_lsu_width,
  input var                     i_load_stall,
  output var logic              o_load_en,
  output var logic              o_store_en,
  output var logic  [XLEN-1:0]  o_store_src,
  input var                     i_store_stall,               

  // write back
  output var logic              o_wb_jump_en,
  output var logic  [4:0]       o_wb_waddr,
  input var                     i_rf_rd_wvalid,
  input var         [4:0]       i_rf_rd_waddr,
  input var         [XLEN-1:0]  i_rf_rd_wdata
);

// Instruction Decoder
logic [6:0]       id_opcode;
logic             id_br_en;
logic             id_jump_en;
logic             id_jump_reg_sel;
logic             id_int_en;
logic             id_up_en;
logic             id_up_pc_sel;
logic             id_load_en;
logic [6:0]       id_funct7;
logic [2:0]       id_funct3;
logic             id_rs1_rvalid;
logic [4:0]       id_rs1_raddr;
logic             id_rs2_rvalid;
logic [4:0]       id_rs2_raddr;
logic             id_rd_wvalid;
logic [4:0]       id_rd_waddr;
logic [XLEN-1:0]  id_immediate;

instruction_decoder # (.XLEN(XLEN)) u_ID (
  .i_instruction  (i_im_rdata),
  .o_opcode       (id_opcode),
  .o_br_en        (id_br_en),
  .o_jump_en      (id_jump_en),
  .o_jump_reg_sel (id_jump_reg_sel),
  .o_int_en       (id_int_en),
  .o_up_en        (id_up_en),
  .o_up_pc_sel    (id_up_pc_sel),
  .o_load_en      (id_load_en),
  .o_store_en     (id_store_en),
  .o_id_funct7    (id_funct7),
  .o_id_funct3    (id_funct3),
  .o_rs1_rvalid   (id_rs1_rvalid)
  .o_rs1_raddr    (id_rs1_raddr),
  .o_rs2_rvalid   (id_rs2_rvalid),
  .o_rs2_raddr    (id_rs2_raddr),
  .o_rd_wvalid    (id_rd_wvalid),
  .o_rd_waddr     (id_rd_waddr),
  .o_immediate    (id_immediate)
);


// register file
logic [XLEN-1:0]  rf_rs1_rdata;
logic             rf_rs1_hazard;
logic [XLEN-1:0]  rf_rs2_rdata;
logic             rf_rs2_hazard;

register_file # (.XLEN(XLEN)) u_RF (
  .clk            (clk),
  .rstn           (rstn),
  .i_rs1_raddr    (id_rs1_raddr),
  .o_rs1_rdata    (rf_rs1_rdata),
  .o_rs1_rhazard  (rf_rs1_hazard),
  .i_rs2_raddr    (id_rs2_raddr),
  .o_rs2_rdata    (rf_rs2_rdata),
  .o_rs2_rhazard  (rf_rs2_hazard),
  .i_rd_hdvalid   (id_rd_wvalid),
  .i_rd_hdaddr    (id_rd_waddr),
  .i_rd_wvalid    (i_rf_rd_wvalid),
  .i_rd_waddr     (i_rf_rd_waddr),
  .i_rd_wdata     (i_rf_rd_wdata)
);


// Instruction Memory Bus Read Data
logic im_rready;
always_comb begin
  im_rready = ~(i_load_stall | (id_rs1_rvalid & rf_rs1_hazard) | (id_rs2_rvalid & rf_rs2_hazard));
end

logic             im_rvalid;
logic [1:0]       im_rresp;
logic [XLEN-1:0]  im_rdata;
skid_buffer #(.DLEN(XLEN + 2)) u_SB (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (i_im_rvalid),
  .o_ready  (o_im_rready),
  .i_data   ({i_im_rresp, i_im_rdata}),
  .o_valid  (im_rvalid),
  .i_ready  (im_rready),
  .o_data   (im_rdata)
);


// Control Transfer
always_comb begin
  o_ct_br_en = id_br_en & im_rvalid;
  o_ct_jump_en = id_jump_en & im_rvalid;
  o_ct_jump_reg_sel = id_jump_reg_sel & im_rvalid;
end
assign o_ct_funct = id_funct3,
assign o_ct_rs1_rdata = rf_rs1_rdata;
assign o_ct_rs2_rdata = rf_rs2_rdata;
assign o_ct_immediate = id_immediate;

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_wb_jump_en <= 0;
  end else begin
    o_wb_jump_en <= o_ct_jump_en;
  end
end


// Integer ALU
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_int_en <= 0;
  end else begin
    o_int_en <= id_int_en & im_rvalid;
  end
end

always_ff @(posedge clk) begin
  o_int_funct <= {id_funct7, id_funct3};
  o_int_src1 <= rf_rs1_rdata;
  o_int_src2 <= rf_rs2_rdata;
end


// Upper Instructions
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_up_en <= 0;
  end else begin
    o_up_en <= id_up_en & im_rvalid;
  end
end

always_ff @(posedge clk) begin
  o_up_imm <= id_immediate;
  o_up_pc_sel <= id_up_pc_sel,
end

// pc forwarding for jump and auipc rd source
logic [XLEN-1:0]  ct_pc;
always_ff @(posedge clk) begin
  if (i_ct_up_pc_valid) begin
    ct_pc <= i_ct_up_pc;
  end else begin
    ct_pc <= ct_pc;
  end
end

always_ff @(posedge clk) begin
  if (id_jump_en || id_up_en) begin
    o_up_pc <= ct_pc;
  end else begin
    o_up_pc <= o_up_pc;
  end
end

// load store instructions
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_load_en <= 0;
    o_store_en <= 0;
  end else begin
    o_load_en <= id_load_en;
    o_store_en <= id_store_en;
  end
end

always_ff @(posedge clk) begin
  o_lsu_base <= rf_rs1_rdata;
  o_lsu_offset <= id_immediate;
  o_lsu_width <= id_funct3;
  o_store_src <= rf_rs2_rdata;
end

endmodule
