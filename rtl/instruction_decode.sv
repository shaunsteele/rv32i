// instruction_decode.sv

`default_nettype none

module instruction_decode import riscv_pkg::*;
# (
  parameter int XLEN = 32
)(
  input var                     rstn,

  // Instruction Memory Bus
  input var         [XLEN-1:0]  i_im_rdata,

  // Output Decoded Instruction
  output var logic  [6:0]       o_opcode,
  output var logic  [6:0]       o_funct7,
  output var logic  [2:0]       o_funct3,
  output var logic  [XLEN-1:0]  o_immediate,
  output var logic  [4:0]       o_rs1_raddr,
  output var logic  [4:0]       o_rs2_raddr,
  output var logic  [4:0]       o_rd_waddr
);

assign o_opcode = i_im_rdata[6:0];

always_comb begin
  case (o_opcode)
    // Register Format
    OpRInt: begin
      o_immediate = 0;
      o_funct7    = i_im_rdata[31:25];
      o_rs2_raddr = i_im_rdata[24:20];
      o_rs1_raddr = i_im_rdata[19:15];
      o_funct3    = i_im_rdata[14:12];
      o_rd_waddr  = i_im_rdata[11:7];
    end

    // Immediate Format
    OpIInt, OpIJump, OpILoad: begin
      o_immediate = {
                      {(XLEN-12){i_im_rdata[31]}},
                      i_im_rdata[31:20]
                    };
      o_funct7    = i_im_rdata[31:25];
      o_rs2_raddr = 0;
      o_rs1_raddr = i_im_rdata[19:15];
      o_funct3    = i_im_rdata[14:12];
      o_rd_waddr  = i_im_rdata[11:7];
    end

    OpSBranch: begin
      o_immediate = {
                      {(XLEN-12){i_im_rdata[31]}},
                      i_im_rdata[7],
                      i_im_rdata[30:25],
                      i_im_rdata[11:8],
                      1'b0
                    };
      o_funct7    = 0;
      o_rs2_raddr = i_im_rdata[24:20];
      o_rs1_raddr = i_im_rdata[19:15];
      o_funct3    = i_im_rdata[14:12];
      o_rd_waddr  = 0;
    end

    OpSStore: begin
      o_immediate = {
                      {(XLEN-11){i_im_rdata[31]}},
                      i_im_rdata[30:25],
                      i_im_rdata[11:7]
                    };
      o_funct7    = 0;
      o_rs2_raddr = i_im_rdata[24:20];
      o_rs1_raddr = i_im_rdata[19:15];
      o_funct3    = i_im_rdata[14:12];
      o_rd_waddr  = 0;
    end

    // Upper Format
    OpUImm, OpUPc: begin
      o_immediate = {
                      i_im_rdata[31:12],
                      12'b0
                    };
      o_funct7    = 0;
      o_rs2_raddr = 0;
      o_rs1_raddr = 0;
      o_funct3    = 0;
      o_rd_waddr  = i_im_rdata[11:7];
    end

    OpUJump: begin
      o_immediate = {
                      {(XLEN-20){i_im_rdata[31]}},
                      i_im_rdata[19:12],
                      i_im_rdata[20],
                      i_im_rdata[30:21],
                      1'b0
                    };
      o_funct7    = 0;
      o_rs2_raddr = 0;
      o_rs1_raddr = 0;
      o_funct3    = 0;
      o_rd_waddr  = i_im_rdata[11:7];
    end

    default: begin
      o_immediate = 0;
      o_funct7    = 0;
      o_rs2_raddr = 0;
      o_rs1_raddr = 0;
      o_funct3    = 0;
      o_rd_waddr  = 0;
    end
  endcase
end

endmodule
