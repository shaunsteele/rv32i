// InstructionDecoder.sv

`default_nettype none

module InstructionDecoder # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Incoming Instruction
  input var                     i_instr_valid,
  output var logic              o_instr_ready,
  input var         [31:0]      i_instr_data,

  // Outgoing Decoded Control
  output var logic              o_dec_valid,
  input var logic               i_dec_ready,

  // Outgoing Decoded Type Data
  output var logic  [6:0]       o_dec_opcode,
  output var logic  [6:0]       o_dec_funct7,
  output var logic  [2:0]       o_dec_funct3,

  // Outgoing Decoded Information
  output var logic  [XLEN-1:0]  o_dec_imm,
  output var logic  [4:0]       o_dec_rs2,
  output var logic  [4:0]       o_dec_rs1,
  output var logic  [4:0]       o_dec_rd
);

// Incoming Instruction Logic
logic instr_en;
always_comb begin
  instr_en = i_instr_valid & o_instr_ready;
end

logic [31:0] instr;
always_comb begin
  if (instr_en) begin
    instr = i_instr_data;
  end else begin
    instr = 0;
  end
end

// Outgoing Decoded Logic
assign o_dec_opcode = inst[6:0];
assign o_dec_ready = 0;

always_comb begin
  case (o_dec_opcode)
    // Register Format
    OpRInt: begin
      o_dec_valid = 1;
      o_imm       = 0;
      o_funct7    = instr[31:25];
      o_rs2       = instr[24:20];
      o_rs1       = instr[19:15];
      o_funct3    = instr[14:12];
      o_rd        = instr[11:7];
    end

    // Immediate Format
    OpIInt, OpIJump, OpILoad: begin
      o_dec_valid = 1;
      o_imm       = {
        { (XLEN-11) { instr[31] } },
        instr[30:20],
        1'b0
      };
      o_funct7    = instr[31:25];
      o_rs2       = 0;
      o_rs1       = instr[19:15];
      o_funct3    = instr[14:12];
      o_rd        = instr[11:7];
    end

    // Store Format
    OpSBranch: begin
      o_dec_valid = 1;
      o_imm       = {
        { (XLEN-12) { instr[31] } },
        instr[7],
        instr[30:25],
        instr[11:8],
        1'b0
      };
      o_funct7    = instr[31:25];
      o_rs2       = instr[24:20];
      o_rs1       = instr[19:15];
      o_funct3    = instr[14:12];
      o_rd        = 0;
    end

    OpSStore: begin
      o_dec_valid = 1;
      o_imm       = {
        { (XLEN-11) { instr[31] } },
        instr[30:25],
        instr[11:7]
      };
      o_funct7    = instr[31:25];
      o_rs2       = instr[24:20];
      o_rs1       = instr[19:15];
      o_funct3    = instr[14:12];
      o_rd        = 0;
    end

    // Upper Format
    OpUImm, OpUPc: begin
      o_dec_valid = 1;
      o_imm       = {
        { (XLEN-11) { instr[31] } },
        instr[30:12],
        11'b0
      };
      o_funct7    = 0;
      o_rs2       = 0;
      o_rs1       = 0;
      o_funct3    = 0;
      o_rd        = instr[11:7];
    end

    OpUJump: begin
      o_dec_valid = 1;
      o_imm       = {
        { (XLEN-11) { instr[31] } },
        instr[19:12],
        instr[20],
        instr[30:21],
        1'b0
      };
      o_funct7    = instr[31:25];
      o_rs2       = instr[24:20];
      o_rs1       = instr[19:15];
      o_funct3    = instr[14:12];
      o_rd        = 0;
    end

    default: begin
      o_dec_valid = 0;
      o_imm       = 0;
      o_funct7    = 0;
      o_rs2       = 0;
      o_rs1       = 0;
      o_funct3    = 0;
      o_rd        = 0;
      $error("Unsupported Opcode Type");
    end
  endcase
end

endmodule
