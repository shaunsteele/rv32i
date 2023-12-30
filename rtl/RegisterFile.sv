// RegisterFile.sv

`default_nettype none

module RegisterFile # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  input var         [4:0]       i_rs2,    // source 2 register address
  input var         [4:0]       i_rs1,    // source 1 register address

  input var         [4:0]       i_rd,     // destination register address
  input var                     i_wen,
  input var         [XLEN-1:0]  i_wdata,

  output var logic  [XLEN-1:0]  o_src1,
  output var logic  [XLEN-1:0]  o_src2
);

logic [XLEN-1:0] mem[32];

// Write Interface
always_ff @(posedge clk) begin
  if (!rstn) begin
    for (int i=0; i < 32; i++) begin
      mem[i] <= 0;
    end
  end else begin
    if (i_wen) begin
      if (i_rd == 5'h0) begin
        mem[i_rd] <= 0;
      end else begin
        mem[i_rd] <= i_wdata;
      end
    end else begin
      mem[i_rd] <= mem[i_rd];
    end
  end
end

// Read Interface
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_src1 <= 0;
    o_src2 <= 0;
  end else begin
    o_src1 <= mem[i_rs1];
    o_src2 <= mem[i_rs2];
  end
end

endmodule
