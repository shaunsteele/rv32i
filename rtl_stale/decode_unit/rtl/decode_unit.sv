// decode_unit.sv

`default_nettype none

module decode_unit # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // AXI5-Lite Read Data Interface
  input var                     i_im_bus_rvalid,
  output var logic              o_im_bus_rready,
  input var         [DLEN-1:0]  i_im_bus_rdata,
  input var         [1:0]       i_im_bus_rresp,
  input var         [ILEN-1:0]  i_im_bus_rid,

  // Execute Integer ALU Interface
  output var logic              o_alu_en,
  output var logic  [9:0]       o_alu_op,
  output var logic  [XLEN-1:0]  o_alu_src1,
  output var logic  [XLEN-1:0]  o_alu_src2,
  output var logic  [4:0]       o_alu_waddr,

  // Execute Load Unit Interace
  output var logic              o_load_en,
  output var logic  [4:0]       o_load_dest,
  output var logic  [2:0]       o_load_width,
  output var logic  [XLEN-1:0]  o_load_base,
  output var logic  [XLEN-1:0]  o_load_offset,

  // Execute Store Unit Interface
  output var logic              o_store_en,
  output var logic  [2:0]       o_store_width,
  output var logic  [XLEN-1:0]  o_store_base,
  output var logic  [XLEN-1:0]  o_store_src,
  output var logic  [XLEN-1:0]  o_store_offset,

  // Write Back Interace
  input var logic               i_wb_rd_wvalid,
  input var logic   [4:0]       i_wb_rd_waddr,
  input var logic   [XLEN-1:0]  i_wb_rd_wdata,

  // Fetch Jump Interace
  input var                     i_im_bus_arvalid,
  input var         [XLEN-1:0]  i_im_bus_araddr,
  output var logic              o_jump_en,
  output var logic              o_jump_ren,
  output var logic  [4:0]       o_jump_dest,
  output var logic  [XLEN-1:0]  o_jump_base,
  output var logic  [XLEN-1:0]  o_jump_offset,

  // Fetch Branch Unit Interface
  output var logic              o_branch_en,
  output var logic  [2:0]       o_branch_op,
  output var logic  [XLEN-1:0]  o_branch_src1,
  output var logic  [XLEN-1:0]  o_branch_src2,
  output var logic  [XLEN-1:0]  o_branch_offset
);


/* Instruction Decoder */
logic [31:0]  im_bus_rdata;
logic [6:0] id_opcode;
logic [6:0] id_funct7;
logic [2:0] id_funct3;
logic [4:0] id_rs1_raddr;
logic [4:0] id_rs2_raddr;
logic [4:0] id_rd_waddr;
logic [XLEN-1:0]  id_immedate;

// Formats IM bus read data
instruction_decoder # (.XLEN(XLEN)) u_ID (
  .i_instruction  (im_bus_rdata),
  .o_opcode       (id_opcode),
  .o_funct7       (id_funct7),
  .o_funct3       (id_funct3),
  .o_rs1_raddr    (id_rs1_raddr),
  .o_rs2_raddr    (id_rs2_raddr),
  .o_rd_waddr     (id_rd_waddr),
  .o_immediate    (id_immediate)
);


/* Register File */
logic [XLEN-1:0]  rf_rs1_rdata;
logic             rf_rs1_hazard;
logic [XLEN-1:0]  rf_rs2_rdata;
logic             rf_rs2_hazard;

// Data registers with read before write hazard detection
register_file # (.XLEN(XLEN)) u_RF (
  .clk          (clk),
  .rstn         (rstn),
  .i_rs1_raddr  (id_rs1_raddr),
  .o_rs1_rdata  (rf_rs1_rdata),
  .o_rs1_hazard (rf_rs1_hazard),
  .i_rs2_raddr  (id_rs2_raddr),
  .o_rs2_rdata  (rf_rs2_rdata),
  .o_rs2_hazard (rf_rs2_hazard),
  .i_rd_hdvalid (im_bus_rvalid),
  .i_rd_hdaddr  (id_rd_waddr),
  .i_rd_wvalid  (i_wb_rd_wvalid),
  .i_rd_waddr   (i_wb_rd_waddr),
  .i_rd_wdata   (i_wb_rd_wdata)
);


/* Execute Unit */
// ALU Registers
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_alu_en <= 0;
  end else begin
    if (id_opcode == OpRInt) begin
      o_alu_en <= ~(rf_rs1_hazard | rf_rs2_hazard) & i_im_bus_rvalid;
    end else if (id_opcode == OpIInt) begin
      o_alu_en <= ~rf_rs1_hazard & i_im_bus_rvalid;
    end else begin
      o_alu_en <= 0;
    end
  end
end

always_ff @(posedge clk) begin
  o_alu_op <= {id_funct7, id_funct3};
  o_alu_src1 <= rf_rs1_rdata;

  if (id_opcode == OpIInt) begin
    o_alu_src2 <= id_immediate;
  end else begin
    o_alu_src2 <= rf_rs2_rdata;
  end
end


// Load Unit Registers
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_load_en <= 0;
  end else begin
    o_load_en <= ~rf_rs1_hazard && id_opcode == OpILoad & i_im_bus_rvalid;
  end
end

always_ff @(posedge clk) begin
  o_load_dest <= id_rd_waddr;
  o_load_width <= id_funct3;
  o_load_base <= rf_rs1_rdata;
  o_load_offset <= id_immediate;
end


// Store Unit Registers
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_store_en <= 0;
  end else begin
    o_store_en <= ~(rf_rs1_hazard | rf_rs2_hazard) && id_opcode == OpSStore & i_im_bus_rvalid;
  end
end

always_ff @(posedge clk) begin
  o_store_width <= id_funct3;
  o_store_base <= rf_rs1_rdata;
  o_store_src <= rf_rs2_rdata;
  o_store_offset <= id_immediate;
end


/* Fetch Unit */
// Jump Connections
always_comb begin
  o_jump_en = id_opcode == OpUJump & i_im_bus_rvalid;
  o_jump_ren = ~rf_rs1_hazard && id_opcode == OpIJump & i_im_bus_rvalid;
end

assign o_jump_dest = id_rd_waddr;
assign o_jump_base = id_rs1_rdata;
assign o_jump_offset = id_immediate;


// Branch Connections
always_comb begin
  o_branch_en = ~(rf_rs1_hazard | rf_rs2_hazard) && id_opcode == OpSBranch & i_im_bus_rvalid;
end

assign o_branch_op = id_funct3;
assign o_branch_src1 = id_rs1;
assign o_branch_src2 = id_rs2;
assign o_branch_offset = id_immediate;


endmodule
