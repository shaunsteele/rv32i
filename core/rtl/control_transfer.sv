// control_transfer.sv

`default_nettype none

module control_transfer # (
  parameter int XLEN = 32 
)(
  input var                     clk,
  input var                     rstn,

  // Decoded Data Signals
  input var         [2:0]       i_funct3,
  input var         [XLEN-1:0]  i_rf_rs1_rdata,
  input var         [XLEN-1:0]  i_rf_rs2_rdata,
  input var         [XLEN-1:0]  i_id_immediate,

  // Decoded Control Signals
  input var                     i_stall,
  input var                     i_br_en,
  input var                     i_jump_en,
  input var                     i_jump_reg_sel,

  // Jump Write Back Signals
  output var logic  [XLEN-1:0]  o_jump_ret,

  // AUIPC Signal
  output var logic  [XLEN-1:0]  o_up_pc,
  
  // Instruction Memory Bus Read Address Signals
  output var logic              o_im_arvalid,
  input var                     i_im_arready,
  output var logic  [XLEN-1:0]  o_im_araddr,
  output var logic  [2:0]       o_im_arprot
);

import riscv_pkg::*;

// Branch Take Logic
logic br_take;
always_comb begin
  if (i_br_en) begin
    unique case (i_funct3)
      BrBEQ: begin
        br_take = i_rf_rs1_rdata == i_rf_rs2_rdata;
      end

      BrBNE: begin
        br_take = i_rf_rs1_rdata != i_rf_rs2_rdata;
      end

      BrBLT: begin
        br_take = $signed(i_rf_rs1_rdata) < $signed(i_rf_rs2_rdata);
      end

      BrBGE: begin
        br_take = $signed(i_rf_rs1_rdata) >= $signed(i_rf_rs2_rdata);
      end

      BrBLTU: begin
        br_take = $unsigned(i_rf_rs1_rdata) < $unsigned(i_rf_rs2_rdata);
      end

      BrBGEU: begin
        br_take = $unsigned(i_rf_rs1_rdata) >= $unsigned(i_rf_rs2_rdata);
      end

      default: begin
        br_take = 0;
      end
    endcase
  end else begin
    br_take = 0;
  end
end

// Program Counter
logic [XLEN-1:0]  pc;
logic [XLEN-1:0]  next_pc;

always_comb begin
  if (i_stall || !i_im_arready) begin
    next_pc = pc;
  end else begin
    if (i_jal_en || (i_br_en && br_take)) begin
      next_pc = pc + i_id_immediate;
    end else if (i_jalr_en) begin
      next_pc = i_rs1_rdata + i_id_immediate;
    end else begin
      next_pc = pc + 4;
    end
  end
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    pc <= INITIAL_ADDRESS;
  end else begin
    pc <= next_pc;
  end
end

// probably a bug if im bus gets hung up
always_ff @(posedge clk) begin
  o_up_pc <= pc;
end

// Jump Return
always_ff @(posedge clk) begin
  o_jump_ret <= pc + 4;
end

// IM Bus
logic im_arvalid;
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_im_arvalid <= 0;
  end else begin
    o_im_arvalid <= 1;
  end
end

assign o_im_ardata = pc;
assign o_im_arprot = 3'b100; // unprivileged secure instruction access

endmodule
