// InstructionDecode.sv

`default_nettype none

`include "core.svh"

module InstructionDecode # (
  parameter int XLEN = 32
)(
  input var                     rstn,

  // Instruction Memory Bus
  input var         [XLEN-1:0]  i_im_rdata,

  // Output Decoded Instruction
  output var logic  [6:0]       o_opcode,
  output var logic  [6:0]       o_funct7,
  output var logic  [2:0]       o_funct3,
  output var logic  [XLEN-1:0]  o_imm,
  output var logic  [4:0]       o_rs1_raddr,
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
      o_imm       = 0;
      o_funct7    = instr[31:25];
      o_rs2_raddr = instr[24:20];
      o_rs1_raddr = instr[19:15];
      o_funct3    = instr[14:12];
      o_rd_waddr  = instr[11:7];
    end

    // Immediate Format
    OpIInt, OpIJump, OpILoad: begin
      o_imm       = {
                      {(XLEN-12){instr[31]}},
                      instr[31:20]
                    };
      o_funct7    = instr[31:25];
      o_rs2_raddr = 0;
      o_rs1_raddr = instr[19:15];
      o_funct3    = instr[14:12];
      o_rd_waddr  = instr[11:7];
    end

    OpSBranch: begin
      o_imm       = {
                       {(XLEN-12){instr[31]}},
                       instr[7],
                       instr[30:25],
                       instr[11:8],
                       1'b0
                    };
      o_funct7    = 0;
      o_rs2_raddr = instr[24:20];
      o_rs1_raddr = instr[19:15];
      o_funct3    = instr[14:12];
      o_rd_waddr  = 0;
    end

    OpSStore: begin
      o_imm       = {
                      {(XLEN-11){instr[31]}},
                      instr[30:25],
                      instr[11:7]
                    };
      o_funct7    = 0;
      o_rs2_raddr = instr[24:20];
      o_rs1_raddr = instr[19:15];
      o_funct3    = instr[14:12];
      o_rd_waddr  = 0;
    end

    // Upper Format
    OpUImm, OpUPc: begin
      o_imm       = {
                      instr[31:12],
                      12'b0
                    };
      o_funct7    = 0;
      o_rs2_raddr = 0;
      o_rs1_raddr = 0;
      o_funct3    = 0;
      o_rd_waddr  = instr[11:7];
    end

    OpUJump: begin
      o_imm       = {
                      {(XLEN-20){instr[31]}},
                      instr[19:12],
                      instr[20],
                      instr[30:21],
                      1'b0
                    };
      o_funct7    = 0;
      o_rs2_raddr = 0;
      o_rs1_raddr = 0;
      o_funct3    = 0;
      o_rd_waddr  = instr[11:7];
    end

    default: begin
      o_imm       = 0;
      o_funct7    = 0;
      o_rs2_raddr = 0;
      o_rs1_raddr = 0;
      o_funct3    = 0;
      o_rd_waddr  = 0;
      if (rstn) begin
        $warning("Unsupported Opcode Type: 0b%07b", o_opcode);
      end
    end
  endcase
end

endmodule
