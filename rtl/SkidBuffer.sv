// SkidBuffer.sv

`default_nettype none

module SkidBuffer # (
  parameter int DLEN    = 8 // Data Width
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_valid,
  output var logic              o_ready,
  input var         [DLEN-1:0]  i_data,

  output var logic              o_valid,
  input var                     i_ready,
  output var logic  [DLEN-1:0]  o_data
);


// Valid Buffer Logic
logic valid_buf;
always_ff @(posedge clk) begin
  if (!rstn) begin
    valid_buf <= 0;
  end else begin
    if (ihs && !i_ready) begin
      valid_buf <= 1;
    end else if (i_ready) begin
      valid_buf <= 0;
    end else begin
      valid_buf <= valid_buf;
    end
  end
end

// Ready Logic
always_comb begin
  o_ready = ~valid_buf;
end

// Handshakes
logic ihs;
logic ohs;
always_comb begin
  ihs = i_valid & o_ready;
  ohs = o_valid & i_ready;
end

// Data Buffer Logic
logic [DLEN-1:0] data_buf;
always_ff @(posedge clk) begin
  if (!rstn) begin
    data_buf <= 0;
  end else begin
    if (i_valid && !i_ready) begin
      data_buf <= i_data;
    end else if (ohs) begin
      data_buf <= 0;
    end else begin
      data_buf <= data_buf;
    end
  end
end

// Output Valid Logic
always_comb begin
  o_valid = i_valid | valid_buf;
end

// Output Data Logic
always_comb begin
  if (valid_buf) begin
    o_data = data_buf;
  end else if (i_valid) begin
    o_data = i_data;
  end else begin
    o_data = 0;
  end
end

endmodule
