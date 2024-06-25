// decode_unit.sv

`default_nettype none

module decode_unit import riscv_pkg::*;
# (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // AXI4-Lite Instruction Bus Master Read Channel
  input var                     i_im_rvalid,
  output var logic              o_im_rready,
  input var logic   [XLEN-1:0]  i_im_rdata,

  // Fetch Unit
  input var         [XLEN-1:0]  i_pc_ret_addr,

  // Execute Unit
  output var logic              o_du_valid,
  input var                     i_ex_ready,

  // Instruction Decode
  output var logic  [6:0]       o_opcode,
  output var logic  [6:0]       o_funct7,
  output var logic  [2:0]       o_funct3,
  output var logic  [XLEN-1:0]  o_immediate,

  // Register File
  output var logic  [XLEN-1:0]  o_rf_rs1_rdata,
  output var logic  [XLEN-1:0]  o_rf_rs2_rdata,
  output var logic  [4:0]       o_rf_rd_waddr,
  input var                     i_rf_rd_wvalid,
  input var         [XLEN-1:0]  i_rf_rd_wdata
);

// Buffer in instruction data
// Decode data into format values
//// Register File outputs values
////// rs1 and rs2 valid signals?
//// Register values to pass to execute unit
//// Data Hazard handling
////// rd busy flag set
////// check rs1 and rs2 busy flag
////// reset valid signal to ex until busy flag reset
//// Control Hazard Handling
////// take function, compare rs1 and rs2, determine branch
////// immediate sent to fetch unit buffer
//////// added with pc then sent to im

// Opcode decodes which block is enabled
//// Integer Block
////// select input values
////// perform action on values according to function
////// send out to write back register
////// clear rd flag
//// Load Block
////// calculate address, read address
////// read data, byte select from function, send to write back register
////// clear rd flag
//// Store Block
////// calculate address, write address and data
////// send response to write back register for error record
//// Branch and Jump
//////// Jump
////// JAL sends rd as wb addr, pc+4 wb data
////// JALR calclates jump address with pc and offset, pc+4 wb data
////// Look into return address stack
////// send address data to fetch unit
////// clear rd flag
//////// Branch
////// select function, compare branch
////// if branch, send offset to fetch unit
////// 

logic [XLEN-1:0]  instruction;
skid_buffer # (.DLEN(XLEN)) u_SB (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (i_im_rvalid),
  .o_ready  (o_im_rready),
  .i_data   (i_im_rdata),
  .o_valid  (o_du_valid),
  .i_ready  (i_ex_ready),
  .o_data   (instruction)
);


/* Instruction Decode */
logic [6:0]       id_opcode;
logic [6:0]       id_funct7;
logic [2:0]       id_funct3;
logic [XLEN-1:0]  id_immediate;
logic [4:0]       id_rs1_raddr;
logic [4:0]       id_rs2_raddr;
logic [4:0]       id_rd_waddr;

instruction_decode # (.XLEN(XLEN)) u_ID (
  .rstn           (rstn),
  .i_instruction  (instruction),
  .o_opcode       (id_opcode),
  .o_funct7       (id_funct7),
  .o_funct3       (id_funct3),
  .o_immediate    (id_immediate),
  .o_rs1_raddr    (id_rs1_raddr),
  .o_rs2_raddr    (id_rs2_raddr),
  .o_rd_waddr     (id_rd_waddr)
);

// opcode decoder
always_ff @(posedge clk) begin
  if (!rstn) begin
    iu_valid <= 0;
  end else begin
    unique case (id_opcode)
      OpRInt: begin
        iu_valid <= 1;
        rd_valid <= 1;
        o_pc_op <= PcIncr;
      end

      OpIInt: begin
        iu_valid <= 1;
        rd_valid <= 1;
        o_pc_op <= PcIncr;
      end

      OpIJump: begin
        iu_valid <= 0;
        // rd set to receive pc+4
        // rd_wvalid is set to 1
        // if rd flag is set, reset im_rready flag
        // TODO: buffer pc+4 until rd_busy resets
      end
    endcase
  end
end

logic du_en;
always_comb begin
  du_en = o_du_valid & i_ex_ready;
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_opcode <= 0;
    o_funct7 <= 0;
    o_funct3 <= 0;
    o_immediate <= 0;
    o_rf_rd_waddr <= 0;
  end else begin
    if (du_en) begin
      o_opcode <= id_opcode;
      o_funct7 <= id_funct7;
      o_funct3 <= id_funct3;
      o_immediate <= id_immediate;
      o_rf_rd_waddr <= id_rd_waddr;
    end else begin
      o_opcode <= o_opcode;
      o_funct7 <= o_funct7;
      o_funct3 <= o_funct3;
      o_immediate <= o_immediate;
      o_rf_rd_waddr <= o_rf_rd_waddr;
    end
  end
end

/* Register File */
logic [XLEN-1:0]  rf_rs1_rdata;
logic [XLEN-1:0]  rf_rs2_rdata;
register_file # (.XLEN(XLEN)) u_RF (
  .clk          (clk),
  .rstn         (rstn),
  .i_rs_ren     (du_en),
  .i_rs1_raddr  (id_rs1_raddr),
  .o_rs1_rdata  (rf_rs1_rdata),
  .i_rs2_raddr  (id_rs2_raddr),
  .o_rs2_rdata  (rf_rs2_rdata),
  .i_rd_waddr   (o_rf_rd_waddr),
  .i_rd_wvalid  (i_rf_rd_wvalid),
  .i_rd_wdata   (i_rf_rd_wdata)
);

// rd data hazard flags
logic [31:0]  rd_busy;
always_ff @(posedge clk) begin
  if (!rstn) begin
    rd_busy <= 0;
  end else begin
    rd_busy[id_waddr] <= rd_valid;
  end
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_rf_rs1_rdata <= 0;
    o_rf_rs2_rdata <= 0;
  end else begin
    if (du_en) begin
      o_rf_rs1_rdata <= rf_rs1_rdata;
      o_rf_rs2_rdata <= rf_rs2_rdata;
    end else begin
      o_rf_rs1_rdata <= o_rf_rs1_rdata;
      o_rf_rs2_rdata <= o_rf_rs2_rdata;
    end
  end
end


endmodule
