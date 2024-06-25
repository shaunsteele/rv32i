// decode_unit.sv

`default_nettype none

module decode_unit import riscv_pkg::*;
# (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // AXI4-Lite Instruction Bus Master Read Channel
  input var                     i_im_rvalid,
  output var logic              o_im_rready,
  input var         [XLEN-1:0]  i_im_rdata,

  // Fetch Unit

  // Execute Unit
  input var                     i_ex_ready,

  output var logic              o_rd_valid,
  
  output var logic              o_funct3_valid,
  output var logic  [2:0]       o_funct3,

  output var logic              o_rs1_valid,
  output var logic  [XLEN-1:0]  o_rs1_rdata,
  
  output var logic              o_rs2_valid,
  output var logic  [XLEN-1:0]  o_rs2_rdata,

  output var logic              o_funct7_valid,
  output var logic  [6:0]       o_funct7,

  output var logic              o_immediate_valid,
  output var logic  [XLEN-1:0]  o_immediate
);

logic funct3_ready;
logic rs1_ready;
logic rs2_ready;
logic funct3_ready;
logic immediate_ready;

logic ex_ready;
always_comb begin
  ex_ready = funct3_ready | rs1_ready | rs2_ready | funct3_ready | immediate_ready;
end

logic im_rhs;
always_comb begin
  im_rhs = i_im_rvalid & ex_ready;
end

assign o_im_rready = ex_ready;

logic [XLEN-1:0]  instruction;
always_ff @(posedge clk) begin
  if (!rstn) begin
    instruction <= 0;
  end else begin
    if (im_rhs) begin
      instruction <= i_im_rdata;
    end else begin
      instruction <= instruction;
    end
  end
end

logic [6:0] opcode;
assign opcode = instruction[6:0];

logic [4:0] rd_waddr;
assign rd = instruction[11:7];

logic [2:0] funct3;
assign funct3 = instruction[14:12];

logic [4:0] rs1_raddr;
assign rs1 = instruction[19:15];

logic [4:0] rs2_raddr;
assign rs2 = instruction[24:20];

logic [6:0] funct7;
assign funct7 = instruction[31:25];

logic rd_valid;
logic funct3_valid;
logic rs1_valid;
logic rs2_valid;
logic funct7_valid;
logic immediate_valid;
logic [XLEN-1:0]  immediate;

always_comb begin
  if (!rstn) begin
    rd_valid = 0;
    funct3_valid = 0;
    rs1_valid = 0;
    rs2_valid = 0;
    funct7_valid = 0;
    immediate_valid = 0;
    immediate = 0;
  end else begin
    unique case (opcode)
      OpRInt: begin
        rd_valid = 1;
        funct3_valid = 1;
        rs1_valid = 1;
        rs2_valid = 1;
        funct7_valid = 1;
        immediate_valid = 0;
        immediate = 0;
      end

      OpIInt, OpIJump, OpILoad: begin
        rd_valid = 1;
        funct3_valid = 1;
        rs1_valid = 1;
        rs2_valid = 0;
        funct7_valid = 0;
        immediate_valid = 1;
        immediate = {
          {(XLEN-12){instruction[31]}},
          instruction[31:20]
        };
      end

      OpSBranch: begin
        rd_valid = 0;
        funct3_valid = 1;
        rs1_valid = 1;
        rs2_valid = 1;
        funct7_valid = 1;
        immediate_valid = 1;
        immediate = {
          {(XLEN-12){instruction[31]}},
          instruction[7],
          instruction[30:25],
          instruction[11:8],
          1'b0
        };
      end

      OpSStore: begin
        rd_valid = 0;
        funct3_valid = 1;
        rs1_valid = 1;
        rs2_valid = 1;
        funct7_valid = 1;
        immediate_valid = 1;
        immediate = {
          {(XLEN-11){instruction[31]}},
          instruction[30:25],
          instruction[11:7]
        };
      end

      OpUImm, OpUPc: begin
        rd_valid = 1;
        funct3_valid = 0;
        rs1_valid = 0;
        rs2_valid = 0;
        funct7_valid = 0;
        immediate_valid = 1;
        immediate = {
          instruction[31:12],
          12'b0
        };
      end

      OpUJump: begin
        rd_valid = 1;
        funct3_valid = 0;
        rs1_valid = 0;
        rs2_valid = 0;
        funct7_valid = 0;
        immediate_valid = 1;
        immediate = {
          {(XLEN-20){instruction[31]}},
          instruction[19:12],
          instruction[20],
          instruction[30:21],
          1'b0
        };
      end

      default: begin
        rd_valid = 0;
        funct3_valid = 0;
        rs1_valid = 0;
        rs2_valid = 0;
        funct7_valid = 0;
        immediate_valid = 0;
        immediate = 0;
      end
    endcase
  end
end

// TODO: figure out rd_waddr and data logic
// register file
logic [XLEN-1:0]  rs1_rdata;
logic [XLEN-1:0]  rs2_rdata;
register_file # (.XLEN(XLEN)) u_RF (
  .clk          (clk),
  .rstn         (rstn),
  .i_rs1_raddr  (rs1_raddr),
  .o_rs1_rdata  (rs1_rdata),
  .i_rs2_raddr  (rs2_raddr),
  .o_rs2_rdata  (rs2_rdata),
  .i_rd_waddr   (),
  .i_rd_wvalid  (),
  .i_rd_wdata   ()
);

// Output buffering
skid_buffer #(.DLEN(3)) u_F3BUF (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (funct3_valid),
  .o_ready  (funct3_ready),
  .i_data   (funct3),
  .o_valid  (o_funct3_valid),
  .i_ready  (i_ex_ready),
  .o_data   (o_funct3)
);

skid_buffer #(.DLEN(XLEN)) u_RS1BUF (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (rs1_valid),
  .o_ready  (rs1_ready),
  .i_data   (rs1_rdata),
  .o_valid  (o_rs1_valid),
  .i_ready  (i_ex_ready),
  .o_data   (o_rs1_rdata)
);

skid_buffer #(.DLEN(XLEN)) u_RS2BUF (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (rs2_valid),
  .o_ready  (rs2_ready),
  .i_data   (rs2_rdata),
  .o_valid  (o_rs2_valid),
  .i_ready  (i_ex_ready),
  .o_data   (o_rs2_rdata)
);

skid_buffer #(.DLEN(7)) u_F7BUF (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (funct7_valid),
  .o_ready  (funct7_ready),
  .i_data   (funct7),
  .o_valid  (o_funct7_valid),
  .i_ready  (i_ex_ready),
  .o_data   (o_funct7)
);

skid_buffer #(.DLEN(XLEN)) u_IMMBUF (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (immediate_valid),
  .o_ready  (immediate_ready),
  .i_data   (immediate),
  .o_valid  (o_immediate_valid),
  .i_ready  (i_ex_ready),
  .o_data   (o_immediate)
);

endmodule
