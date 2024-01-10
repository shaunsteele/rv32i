// Fdre.sv

`default_nettype none

module Fdre # (
  parameter int W = 1
)(
  input var         clk,
  input var         rstn,
  input var         d,
  output var logic  q
);

always_ff @(posedge clk) begin
  if (!rstn) begin
    q <= 0;
  end else begin
    q <= d;
  end
end

endmodule
