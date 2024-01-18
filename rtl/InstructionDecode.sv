// InstructionDecode.sv

`default_nettype none

`include "riscv.svh"

module InstructionDecode # (
  parameter int XLEN = 32
)(
  // Instruction Memory Bus
  input var         [XLEN-1:0]  i_im_rdata,

  // Output Decoded Instruction
  output var logic  [6:0]       o_opcode,
  output var logic  [6:0]       o_funct7,
  output var logic  [2:0]       o_funct3,
  output var logic  [XLEN-1:0]  o_imm,
  output var logic  [4:0]       o_rs2_raddr,
  output var logic  [4:0]       o_rs2_raddr,
  output var logic  [4:0]       o_rd_waddr
);

assign o_opcode = i_im_rdata[6:0];

logic [XLEN-1:0]  instr;
assign instr = i_im_rdata;

always_comb begin
  case (o_opcode)
    // Register Format
    OpRInt: begin
      o_imm     = 0;
      o_funct7  = instr[31:25];
      o_rs2     = instr[24:20];
      o_rs1     = instr[19:15];
      o_funct3  = instr[14:12];
      o_rd      = instr[11:7];
    end

    // Immediate Format
    OpIInt, OpIJump, OpILoad: begin
      o_imm     = {
                    {(XLEN-12){instr[31]}},
                    instr[30:20],
                    1'b0
                  };
      o_funct7  = instr[31:25];
      o_rs2     = 0;
      o_rs1     = instr[19:15];
      o_funct3  = instr[14:12];
      o_rd      = instr[11:7];
    end

    OpSBranch: begin
      o_imm     = {
                     {(XLEN-12){instr[31]}},
                     instr[7],
                     instr[30:25],
                     instr[11:8],
                     1'b0
                  };
      o_funct7  = instr[31:25];
      o_rs2     = instr[24:20];
      o_rs1     = instr[19:15];
      o_funct3  = instr[14:12];
      o_rd      = 0;
    end

    OpSStore: begin
      o_imm     = {
                    {(XLEN-11){instr[31]}},
                    instr[30:25],
                    instr[11:7]
                  };
      o_funct7  = instr[31:25];
      o_rs2     = instr[24:20];
      o_rs1     = instr[19:15];
      o_funct3  = instr[14:12];
      o_rd      = 0;
    end

    // Upper Format
    OpUImm, OpUPc: begin
      o_imm     = {
                    instr[31:12],
                    12'b0
                  };
      o_funct7  = 0;
      o_rs2     = 0;
      o_rs1     = 0;
      o_funct3  = 0;
      o_rd      = instr[11:7];
    end

    OpUJump: begin
      o_imm     = {
                    {(XLEN-20){instr[31]}},
                    instr[19:12],
                    instr[20],
                    instr[30:21],
                    1'b0
                  };
      o_funct7  = instr[31:25];
      o_rs2     = instr[24:20];
      o_rs1     = instr[19:15];
      o_funct3  = instr[14:12];
      o_rd      = 0;
    end

    default: begin
      o_dec_valid   = 0;
      o_dec_imm     = 0;
      o_dec_funct7  = 0;
      o_dec_rs2     = 0;
      o_dec_rs1     = 0;
      o_dec_funct3  = 0;
      o_dec_rd      = 0;
      $error("Unsupported Opcode Type");
    end
  endcase
end

endmodule
