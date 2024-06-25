// instruction_decode.sv

`default_nettype none

module instruction_decode import riscv_pkg::*;
# (
  parameter int XLEN = 32
)(
  input var                     rstn,

  // Instruction Memory Bus
  input var         [XLEN-1:0]  i_instruction,

  // Output Decoded Instruction
  output var logic  [6:0]       o_opcode,
  output var logic  [6:0]       o_funct7,
  output var logic  [2:0]       o_funct3,
  output var logic  [XLEN-1:0]  o_immediate,
  output var logic  [4:0]       o_rs1_raddr,
  output var logic  [4:0]       o_rs2_raddr,
  output var logic  [4:0]       o_rd_waddr
);

assign o_opcode = i_instruction[6:0];
assign o_rs2_raddr = i_instruction[24:20];
assign o_rs1_raddr = i_instruction[19:15];
assign o_rd_waddr = i_instruction[11:7];
assign o_funct7 = i_instruction[31:25];
assign o_funct3 = i_instruction[14:12];

// Immediate Decoder
always_comb begin
  case (o_opcode)
    OpRInt: begin
      o_immediate = 0;
    end

    OpIInt, OpIJump, OpILoad: begin
      o_immediate = {
                      {(XLEN-12){i_instruction[31]}},
                      i_instruction[31:20]
                    };
    end

    OpSBranch: begin
      o_immediate = {
                      {(XLEN-12){i_instruction[31]}},
                      i_instruction[7],
                      i_instruction[30:25],
                      i_instruction[11:8],
                      1'b0
                    };
    end

    OpSStore: begin
      o_immediate = {
                      {(XLEN-11){i_instruction[31]}},
                      i_instruction[30:25],
                      i_instruction[11:7]
                    };
    end

    OpUImm, OpUPc: begin
      o_immediate = {
                      i_instruction[31:12],
                      12'b0
                    };
    end

    OpUJump: begin
      o_immediate = {
                      {(XLEN-20){i_instruction[31]}},
                      i_instruction[19:12],
                      i_instruction[20],
                      i_instruction[30:21],
                      1'b0
                    };
    end

    default: begin
      o_immediate = 0;
    end
  endcase
end

endmodule
