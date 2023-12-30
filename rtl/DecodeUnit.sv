// DecodeUnit.sv

`default_nettype none

`include "riscvPkg.sv"

module DecodeUnit # (
  parameter int XLEN = 32,
  parameter int ILEN = 32
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_decode_en,    // Decode Enable Flag
  input var         [ILEN-1:0]  i_instruction,  // Instruction

  output var logic  [6:0]       o_opcode,       // Opcode Register
  output var logic  [6:0]       o_funct7,       // Funct7 Register
  output var logic  [2:0]       o_funct3,       // Funct3 Register
  output var logic  [XLEN-1:0]  o_immediate,    // Immediate Register

  input var                     i_rf_wen,       // Reg File Write Enable
  input var         [XLEN-1:0]  i_rf_wdata,     // Reg File Write Data
  output var logic  [XLEN-1:0]  o_rf_src1,      // Reg File Source1 Register
  output var logic  [XLEN-1:0]  o_rf_src2       // Reg File Source2 Register
);


import riscvPkg::*;


/* Opcode Decode */
logic [6:0] next_opcode;
always_comb begin
  if (i_decode_en) begin
    next_opcode = i_instruction[6:0];
  end else begin
    next_opcode = o_opcode;
  end
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_opcode <= 0;
  end else begin
    o_opcode <= next_opcode;
  end
end


/* Instruction Fields Decode */
logic [XLEN-1:0]  next_immediate;
logic [6:0]       next_funct7;
logic [4:0]       rs2;
logic [4:0]       rs1;
logic [2:0]       next_funct3;
logic [4:0]       rd;

always_comb begin
  case (next_opcode)

    OpStore: begin
      next_immediate  = {
        {(XLEN-11){i_instruction[31]}},
        i_instruction[30:25],
        i_instruction[11:7]
      };
      next_funct7     = i_instruction[31:25];
      rs2             = i_instruction[24:20];
      rs1             = i_instruction[19:15];
      next_funct3     = i_instruction[14:12];
      rd              = 5'b0;
    end

    OpImmLoad, OpRegImm, OpJumpImm: begin
      next_immediate  = {
        {(XLEN-11){i_instruction[31]}},
        i_instruction[30:20]
      };
      next_funct7     = 7'b0;
      rs2             = 5'b0;
      rs1             = i_instruction[19:15];
      next_funct3     = i_instruction[14:12];
      rd              = i_instruction[11:7];
    end

    OpBranch: begin
      next_immediate  = {
        {(XLEN-12){i_instruction[31]}},
        i_instruction[7],
        i_instruction[30:25],
        i_instruction[11:8],
        1'b0
      };
      next_funct7     = i_instruction[31:25];
      rs2             = i_instruction[24:20];
      rs1             = i_instruction[19:15];
      next_funct3     = i_instruction[14:12];
      rd              = 5'b0;
    end

    OpJump: begin
      next_immediate  = {
        {(XLEN-11){i_instruction[20]}},
        i_instruction[10:1],
        i_instruction[11],
        i_instruction[19:12],
        1'b0
      };
      next_funct7     = 0;
      rs2             = 0;
      rs1             = 0;
      next_funct3     = 0;
      rd              = i_instruction[11:7];
    end

    default: begin
      next_immediate  = 0;
      next_funct7     = 0;
      next_funct3     = 0;
      rs2             = 0;
      rs1             = 0;
      rd              = 0;
      if (rstn) begin
        $error("Unsupported opcode: 0b%07b", next_opcode);
      end
    end

  endcase
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_immediate <= 0;
    o_funct7 <= 0;
    o_funct3 <= 0;
  end else begin
    if (i_decode_en) begin
      o_immediate <= next_immediate;
      o_funct7 <= next_funct7;
      o_funct3 <= next_funct3;
    end else begin
      o_immediate <= o_immediate;
      o_funct7 <= o_funct7;
      o_funct3 <= o_funct3;
    end
  end
end


/* Register File */
logic [XLEN-1:0] next_rf_src1;
logic [XLEN-1:0] next_rf_src2;

RegisterFile # (
  .XLEN (XLEN)
) u_RegisterFile (
  .clk      (clk),
  .rstn     (rstn),
  .i_rs2    (rs2),
  .i_rs1    (rs1),
  .i_rd     (rd),
  .i_wen    (i_rf_wen),
  .i_wdata  (i_rf_wdata),
  .o_src1   (next_rf_src1),
  .o_src2   (next_rf_src2)
);

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_rf_src1 <= 0;
    o_rf_src2 <= 0;
  end else begin
    if (i_decode_en) begin
      o_rf_src1 <= next_rf_src1;
      o_rf_src2 <= next_rf_src2;
    end else begin
      o_rf_src1 <= o_rf_src1;
      o_rf_src2 <= o_rf_src2;
    end
  end
end

endmodule
