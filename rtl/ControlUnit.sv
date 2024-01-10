// ControlUnit.sv

`default_nettype none

module ControlUnit # (
  parameter int XLEN = 32,
  parameter int STRB = XLEN / 8
)(
  input var                     clk,
  input var                     rstn,

  // State Machine Flow Control
  output var logic              o_state_valid,
  input var                     i_state_ready,
  output var logic              o_state_data,

  // Fetch Unit
  output var logic              o_fu_fetch_valid,
  input var                     i_fu_fetch_ready,
  input var logic               i_fu_instr_valid,
  output var logic              o_fu_instr_ready,
  input var         [31:0]      i_fu_instr_data,

  // Instruction Decoder
  input var                     i_id_dec_valid,
  output var logic              o_id_dec_ready,
  input var         [6:0]       i_id_dec_opcode,
  input var         [6:0]       i_id_dec_funct7,
  input var         [2:0]       i_id_dec_funct3,

  // Execute Unit
  //// Program Counter
  output var logic              o_eu_pc_incr_valid,
  input var                     i_eu_pc_incr_ready,
  output var logic [1:0]        o_eu_pc_incr_op,
  output var logic              o_eu_pc_incr_alu_sel,
  input var                     i_eu_pc_valid,

  //// Arithmetic Logic Unit
  output var logic              o_eu_alu_op_valid,
  input var logic               i_eu_alu_op_ready,
  output var logic  [3:0]       o_eu_alu_op_data,
  output var logic              o_eu_alu_a_pc_sel,
  output var logic              o_eu_alu_b_imm_sel,
  input var                     i_eu_alu_f_valid,
  output var logic              o_eu_alu_f_ready,
  input var                     i_eu_alu_z_valid,

  //// Memory Unit
  output var logic              o_eu_mem_wvalid,
  input var                     i_eu_mem_wready,
  output var logic  [STRB-1:0]  o_eu_mem_wstrb,
  output var logic              o_eu_mem_arvalid,
  input var logic               i_eu_mem_arready,
  input var                     i_eu_mem_rvalid,
  output var logic              o_eu_mem_rready,
  output var logic  [STRB-1:0]  o_eu_mem_rstrb,
  output var logic              o_eu_mem_rsign,

  // Register File
  output var logic              o_rf_rd_wvalid,
  input var logic               i_rf_rd_wready
);


import riscvPkg::*;

/* State Machine */
// State Machine Enable Flag
logic state_en;
always_comb begin
  state_en = o_state_valid & i_state_ready;
end

// State Definitions
localparam int StateAmt = 3;
typedef enum logic [StateAmt-1:0] {
  CU_IDLE,
  CU_FETCH,
  CU_EXECUTE
} state_e;

state_e next_state;
state_e curr_state;
state_e prev_state;

assign o_state_data = curr_state;

// Previous State Logic
always_ff @(posedge clk) begin
  if (!rstn) begin
    prev_state <= CU_FETCH;
  end else begin
    if (state_en) begin
      prev_state <= curr_state;
    end else begin
      prev_state <= prev_state;
    end
  end
end

// Current State Logic
always_ff @(posedge clk) begin
  if (!rstn) begin
    curr_state <= CU_IDLE;
  end else begin
    curr_state <= next_state;
  end
end

// Next State Logic
logic fu_fetch_en;
always_comb begin
  fu_fetch_en = o_fu_fetch_valid & i_fu_fetch_ready;
end

logic eu_alu_f_en;
always_comb begin
  eu_alu_f_en = i_eu_alu_f_valid & o_eu_alu_f_ready;
end

logic mem_w_en;
always_comb begin
  mem_w_en = o_mem_wvalid & i_mem_wready;
end

logic mem_r_en;
always_comb begin
  mem_r_en = i_mem_rvalid & o_mem_rready;
end

logic rf_rd_en;
always_comb begin
  rf_rd_en = o_rf_rd_wvalid & i_rf_rd_wready;
end

logic eu_en;
always_comb begin
  eu_en = i_eu_pc_valid & (eu_alu_f_en | mem_w_en | mem_r_en | rf_rd_en);
end

always_comb begin
  case (curr_state)
    CU_IDLE: begin
      o_fu_fetch_valid = 1;
      o_fu_instr_ready = 0;

      if (state_en) begin
        next_state = prev_state;
      end else if (fu_fetch_en) begin
        next_state = CU_FETCH;
      end else begin
        next_state = CU_IDLE;
      end
    end

    CU_FETCH: begin
      o_fu_instr_ready = 1;

      if (!state_en) begin
        o_fu_fetch_valid = 0;
        next_state = CU_IDLE;
      end else begin
        if (fu_instr_en) begin
          next_state = CU_EXECUTE;
        end else begin
          next_state = CU_FETCH;
        end
      end
    end

    CU_EXECUTE: begin
      o_fu_fetch_valid = 1;
      o_fu_instr_ready = 0;

      if (execute_en) begin
        next_state = (state_en) ? CU_FETCH : CU_IDLE;
      end else begin
        next_state = CU_EXECUTE;
      end
    end

    default: begin
      $error("Illegal Control Unit State: 0x%0h", curr_state);
    end
  endcase
end


/* Instruction Decode  */
assign o_id_dec_ready = 1;

logic id_dec_en;
always_comb begin
  id_dec_en = i_id_dec_valid & o_id_dec_ready;
end

logic [6:0] opcode;
logic [6:0] funct7;
logic [2:0] funct3;

always_comb begin
  if (id_dec_en) begin
    opcode = i_id_dec_opcode;
    funct7 = i_id_dec_funct7;
    funct3 = i_id_dec_funct3;
  end else begin
    opcode = 0;
    funct7 = 0;
    funct3 = 0;
  end
end


/* Execute Unit Control */
// Handshakes
logic pc_load_en;
logic pc_incr_en;
always_comb begin
  pc_load_en = o_eu_pc_load_valid & i_eu_pc_load_ready;
  pc_incr_en = o_eu_pc_incr_valid & i_eu_pc_incr_ready;
end

always_comb begin
  if (curr_state == CU_EXECUTE) begin
    case ({funct7, funct3, opcode})
      InstADDI: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSLTI: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSlt;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_arsign       = 0;
        o_eu_mem_rready       = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSLTIU: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSltu;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstXORI: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluXor;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstORI: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluOr;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstANDI: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAnd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSLLI: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSll;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSRLI: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSrl;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSRAI: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSra;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstLUI: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 0;
        o_eu_alu_op_data      = 4'b0;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstAUIPC: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 1;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstADD: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSLT: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSlt;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSLTU: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSltu;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstAND: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAnd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstOR: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluOr;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstXOR: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluXor;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSLL: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSll;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSRL: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSrl;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSUB: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluOr;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstSRA: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSra;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b0;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_arsign       = 0;
        o_eu_mem_arstrb       = 4'b0;
        o_eu_mem_arsign       = 0;
        o_eu_mem_rready       = 0;

        // Register Write
        o_rf_rd_wvalid        = 1;
        o_rf_rd_mem_sel       = 0;
      end

      InstJAL: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcJump;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 0;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_wvalid        = 1;
        o_rf_rd_mem_sel       = 0;
      end

      InstJALR: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcJump;
        o_eu_pc_incr_alu_sel  = 1;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstBEQ: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = (i_eu_alu_z_valid) ? PcBranch : PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluXor;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstBNE: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = (!i_eu_alu_z_valid) ? PcBranch : PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluXor;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstBLT: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = (!i_eu_alu_z_valid) ? PcBranch : PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSlt;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstBLTU: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = (!i_eu_alu_z_valid) ? PcBranch : PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSltu;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstBGE: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = (i_eu_alu_z_valid) ? PcBranch : PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSlt;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstBGEU: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = (i_eu_alu_z_valid) ? PcBranch : PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluSltu;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 0;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 1;
      end

      InstLW: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 1;
        o_eu_mem_rready       = 1;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 1;

        // Register Write
        o_rf_rd_mem_sel       = 1;
        o_rf_rd_wvalid        = 1;
      end

      InstLH: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 1;
        o_eu_mem_rready       = 1;
        o_eu_mem_rstrb        = 4'b0011;
        o_eu_mem_rsign        = 1;

        // Register Write
        o_rf_rd_mem_sel       = 1;
        o_rf_rd_wvalid        = 1;
      end

      InstLHU: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 1;
        o_eu_mem_rready       = 1;
        o_eu_mem_rstrb        = 4'b0011;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 1;
        o_rf_rd_wvalid        = 1;
      end

      InstLB: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 1;
        o_eu_mem_rready       = 1;
        o_eu_mem_rstrb        = 4'b0001;
        o_eu_mem_rsign        = 1;

        // Register Write
        o_rf_rd_mem_sel       = 1;
        o_rf_rd_wvalid        = 1;
      end

      InstLBU: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 1;
        o_eu_mem_rready       = 1;
        o_eu_mem_rstrb        = 4'b0001;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 1;
        o_rf_rd_wvalid        = 1;
      end

      InstSW: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 1;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 0;
      end

      InstSH: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 1;
        o_eu_mem_wstrb        = 4'b0011;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 0;
      end

      InstSB: begin
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 1;
        o_eu_mem_wstrb        = 4'b0001;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 0;
      end

      default: begin // NOP Instruction
        // Program Counter
        o_eu_pc_incr_valid    = 1;
        o_eu_pc_incr_op       = PcIncr;
        o_eu_pc_incr_alu_sel  = 0;

        // ALU
        o_eu_alu_op_valid     = 1;
        o_eu_alu_op_data      = AluAdd;
        o_eu_alu_a_pc_sel     = 0;
        o_eu_alu_b_imm_sel    = 1;

        // Data Memory
        o_eu_mem_wvalid       = 0;
        o_eu_mem_wstrb        = 4'b1111;
        o_eu_mem_arvalid      = 0;
        o_eu_mem_rready       = 0;
        o_eu_mem_rstrb        = 4'b1111;
        o_eu_mem_rsign        = 0;

        // Register Write
        o_rf_rd_mem_sel       = 0;
        o_rf_rd_wvalid        = 0;

        $error(
          "Unsupported instruction: funct7=0b%07b funct3=0b%03b opcode=0b%07b",
          i_funct7, i_funct3, i_opcode
        );
      end
    endcase
  end else begin
    // Program Counter
    o_eu_pc_incr_valid    = 1;
    o_eu_pc_incr_op       = PcIncr;
    o_eu_pc_incr_alu_sel  = 0;

    // ALU
    o_eu_alu_op_valid     = 1;
    o_eu_alu_op_data      = AluAdd;
    o_eu_alu_a_pc_sel     = 0;
    o_eu_alu_b_imm_sel    = 1;

    // Data Memory
    o_eu_mem_wvalid       = 0;
    o_eu_mem_wstrb        = 4'b1111;
    o_eu_mem_arvalid      = 0;
    o_eu_mem_rready       = 0;
    o_eu_mem_rstrb        = 4'b1111;
    o_eu_mem_rsign        = 0;

    // Register Write
    o_rf_rd_wvalid        = 0;
  end
end


endmodule
