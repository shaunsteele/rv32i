// ControlUnit.sv

`default_nettype none

`include "riscv.svh"

module ControlUnit(
  // Operational Instruction Input
  input var         [6:0] i_du_id_opcode,
  input var         [6:0] i_du_id_funct7,
  input var         [2:0] i_du_id_funct3,

  // Instruction Control Output
  input var               i_eu_alu_res_zero,
  output var logic  [2:0] o_fu_pc_op_data,
  output var logic        o_eu_alu_imm_sel,
  output var logic  [3:0] o_eu_alu_op_data,
  output var logic        o_eu_wb_dm_sel
);

always_comb begin
  unique case ({i_du_id_funct7, i_du_id_funct3, i_du_id_opcode})
    // Integer Register-Immediate Instructions
    InstADDI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSLTI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluSlt;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSLTIU: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluSltu;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstXORI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluXor;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end
    
    InstORI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluOr;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end
    
    InstANDI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAnd;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSLLI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluSll;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSRAI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluSra;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    // TODO: LUI Support

    // TODO: AUIPC Support

    // Integer Register-Register Instructions
    InstADD: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluAdd;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSLT: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSlt;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSLTU: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSlt;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstXOR: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluXor;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end
    
    InstOR: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluOr;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end
    
    InstAND: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluAnd;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSLL: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSll;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSRL: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSrl;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSUB: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSub;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstSRA: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSra;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end


    // Unconditional Jump Instructions
    InstJAL: begin
      o_fu_pc_op_data   = PcJAL;
      o_eu_alu_imm_sel  = o_eu_alu_imm_sel;
      o_eu_alu_op_data  = AluAdd;
      o_eu_wb_pc_sel    = 1;
      o_eu_wb_dm_sel    = 1;
    end

    InstJAL: begin
      o_fu_pc_op_data   = PcJAL;
      o_eu_alu_imm_sel  = o_eu_alu_imm_sel;
      o_eu_alu_op_data  = AluAdd;
      o_eu_wb_pc_sel    = 1;
      o_eu_wb_dm_sel    = 1;
    end


    // Conditional Branch Instructions
    InstBEQ: begin
      o_fu_pc_op_data   = (i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluXor;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstBNE: begin
      o_fu_pc_op_data   = (~i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluXor;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstBLT: begin
      o_fu_pc_op_data   = (~i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSlt;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstBLTU: begin
      o_fu_pc_op_data   = (~i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSltu;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstBGE: begin
      o_fu_pc_op_data   = (i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSlt;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    InstBGEU: begin
      o_fu_pc_op_data   = (i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSltu;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end

    // Load Instructions
    InstLW: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 1;
    end

    // TODO: LH

    // TODO: LHU

    // TODO: LB

    // TODO: LBU

    // Store Instructions
    InstSW: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_wb_dm_sel    = 0;
    end
    
    // TODO: SH

    // TODO: SB

    default: begin  // NOP
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluAdd;
      o_eu_wb_pc_sel    = 0;
      o_eu_wb_dm_sel    = 0;
    end
  endcase
end

endmodule
