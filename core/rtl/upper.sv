// upper.sv

`default_nettype none

module upper # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_en,
  input var                     i_stall,

  input var         [XLEN-1:0]  i_immediate,

  input var                     i_pc_sel,
  input var         [XLEN-1:0]  i_pc,

  output var logic  [XLEN-1:0]  o_up_reg
);

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_up_reg <= 0;
  end else begin
    if (i_en && !i_stall) begin
      if (i_pc_sel) begin
        o_up_reg <= i_pc + i_immediate;
      end else begin
        o_up_reg <= i_immediate;
      end
    end else begin
      o_up_reg <= o_up_reg;
    end
  end
end

endmodule
