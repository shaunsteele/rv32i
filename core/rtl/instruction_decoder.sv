// instruction_decoder.sv

`default_nettype none

module instruction_decoder # (
  parameter int XLEN = 32
)(
  input var         [31:0]      i_instruction,

  output var logic  [6:0]       o_opcode,

  output var logic              o_br_en,
  output var logic              o_jump_en,
  output var logic              o_jump_reg_sel,
  output var logic              o_int_en,
  output var logic              o_up_en,
  output var logic              o_up_pc_sel,
  output var logic              o_load_en,
  output var logic              o_store_en,

  output var logic  [6:0]       o_funct7,
  output var logic  [2:0]       o_funct3,

  output var logic              o_rs1_rvalid,
  output var logic  [4:0]       o_rs1_raddr,

  output var logic              o_rs2_rvalid,
  output var logic  [4:0]       o_rs2_raddr,

  output var logic              o_rd_wvalid,
  output var logic  [4:0]       o_rd_waddr,

  output var logic  [XLEN-1:0]  o_immediate
);

import riscv_pkg::*;

assign o_opcode = i_instruction[6:0];

assign o_funct7 = i_instruction[31:25];
assign o_funct3 = i_instruction[14:12];

assign o_rs1_raddr = i_instruction[19:15];
assign o_rs2_raddr = i_instruction[24:20];
assign o_rd_waddr = i_instruction[11:7];

always_comb begin
  o_br_en = o_opcode == OpSBranch;
end

always_comb begin
  o_jump_en = (o_opcode == OpIJump) | (o_opcode == OpUJump);
  o_jump_reg_sel = o_opcode == OpIJump;
end

always_comb begin
  o_int_en = (o_opcode == OpRInt) | (o_opcode == OpIInt);
end

always_comb begin
  o_up_en = (o_opcode == OpUPc) | (o_opcode == OpUImm);
  o_up_pc_sel = o_opcode == OpUPc;
end

always_comb begin
  o_load_en = o_opcode == OpILoad;
  o_store_en = o_opcode == OpSStore;
end

always_comb begin
  unique case (o_opcode)
    OpRInt: begin
      o_rd_wvalid = 1;
      o_rs1_rvalid = 1;
      o_rs2_rvalid = 1;
      immediate = 0;
    end

    OpIInt, OpIJump, OpILoad: begin
      o_rd_wvalid = 1;
      o_rs1_rvalid = 1;
      o_rs2_rvalid = 0;
      immediate = {
        {(XLEN-12){i_instruction[31]}},
        instruction[31:20]
      };
    end

    OpSBranch: begin
      o_rd_wvalid = 0;
      o_rs1_rvalid = 1;
      o_rs2_rvalid = 1;
      immediate = {
        {(XLEN-12){instruction[31]}},
        instruction[7],
        instruction[30:25],
        instruction[11:8],
        1'b0
      };
    end

    OpSStore: begin
      o_rd_wvalid = 0;
      o_rs1_rvalid = 1;
      o_rs2_rvalid = 1;
      immediate = {
        {(XLEN-11){instruction[31]}},
        instruction[30:25],
        instruction[11:7]
      };
    end

    OpUImm, OpUPc: begin
      o_rd_wvalid = 1;
      o_rs1_rvalid = 0;
      o_rs2_rvalid = 0;
      immediate = {
        instruction[31:12],
        12'b0
      };
    end

    OpUJump: begin
      o_rd_wvalid = 1;
      o_rs1_rvalid = 0;
      o_rs2_rvalid = 0;
      immediate = {
        {(XLEN-20){instruction[31]}},
        instruction[19:12],
        instruction[20],
        instruction[30:21],
        1'b0
      };
    end

    default: begin
      o_rd_wvalid = 0;
      o_rs1_rvalid = 0;
      o_rs2_rvalid = 0;
      immediate = 0;
    end
  endcase
end

endmodule
