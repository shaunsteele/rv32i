// ControlUnit.sv

`default_nettype none

`include "core.svh"

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
  output var logic        o_eu_dm_wvalid,
  output var logic  [2:0] o_eu_dm_op_data,
  output var logic        o_du_rf_rd_wvalid,
  output var logic  [2:0] o_eu_wb_op_data
);

always_comb begin
  unique casez ({i_du_id_funct7, i_du_id_funct3, i_du_id_opcode})
    // Integer Register-Immediate Instructions
    InstADDI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSLTI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluSlt;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSLTIU: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluSltu;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstXORI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluXor;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end
    
    InstORI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluOr;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end
    
    InstANDI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAnd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSLLI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluSll;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSRAI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluSra;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstLUI: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbImm;
    end

    InstAUIPC: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbPcImm;
    end


    // Integer Register-Register Instructions
    InstADD: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSLT: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSlt;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSLTU: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSlt;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstXOR: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluXor;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end
    
    InstOR: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluOr;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end
    
    InstAND: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluAnd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSLL: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSll;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSRL: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSrl;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSUB: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSub;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSRA: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSra;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end


    // Unconditional Jump Instructions
    InstJAL: begin
      o_fu_pc_op_data   = PcJAL;
      o_eu_alu_imm_sel  = o_eu_alu_imm_sel;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbPcRet;
    end

    InstJALR: begin
      o_fu_pc_op_data   = PcJALR;
      o_eu_alu_imm_sel  = o_eu_alu_imm_sel;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbAlu;
    end


    // Conditional Branch Instructions
    InstBEQ: begin
      o_fu_pc_op_data   = (i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluXor;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end

    InstBNE: begin
      o_fu_pc_op_data   = (~i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluXor;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end

    InstBLT: begin
      o_fu_pc_op_data   = (~i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSlt;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end

    InstBLTU: begin
      o_fu_pc_op_data   = (~i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSltu;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end

    InstBGE: begin
      o_fu_pc_op_data   = (i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSlt;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end

    InstBGEU: begin
      o_fu_pc_op_data   = (i_eu_alu_res_zero) ? PcBranch : PcIncr;
      o_eu_alu_imm_sel  = 0;
      o_eu_alu_op_data  = AluSltu;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end


    // Load Instructions
    InstLW: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbDm;
    end

    InstLH: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemH;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbDm;
    end

    InstLHU: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemHU;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbDm;
    end

    InstLB: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemB;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbDm;
    end

    InstLBU: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemHU;
      o_du_rf_rd_wvalid = 1;
      o_eu_wb_op_data   = WbDm;
    end


    // Store Instructions
    InstSW: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 1;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSH: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 1;
      o_eu_dm_op_data   = MemH;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end

    InstSB: begin
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 1;
      o_eu_dm_op_data   = MemB;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end


    default: begin  // NOP
      o_fu_pc_op_data   = PcIncr;
      o_eu_alu_imm_sel  = 1;
      o_eu_alu_op_data  = AluAdd;
      o_eu_dm_wvalid    = 0;
      o_eu_dm_op_data   = MemW;
      o_du_rf_rd_wvalid = 0;
      o_eu_wb_op_data   = WbAlu;
    end
  endcase
end

endmodule
