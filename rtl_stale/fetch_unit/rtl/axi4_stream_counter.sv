// axi4_stream_counter.sv

`default_nettype none

module axi4_stream_counter # (
  parameter int LEN = 32,
  parameter int INITIAL = 32'h0,
  parameter int USER = 4'b0000
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_load_en
  input var         [LEN-1:0]   i_load_data,

  output var logic              o_tvalid,
  input var                     i_tready,
  output var logic  [LEN-1:0]   o_tdata,
  output var logic  [2:0]       o_tuser
);

assign o_tuser = USER_DATA;

// counter register
logic [XLEN-1:0]  count;
logic [XLEN-1:0]  next_count;
always_ff @(posedge clk) begin
  if (!rstn) begin
    count <= INITIAL_ADDRESS;
  end else begin
    count <= next_count;
  end
end

assign o_tdata = count;

// next count logic
always_comb begin
  if (i_im_bus_rready) begin
    if (i_load_en) begin
      next_count = count + i_load_data;
    end else begin
      next_count = count + 4;
    end
  end else begin
    next_count = count;
  end
end

always_ff @(posedge clk) begin
  o_tvalid <= rstn;
end

endmodule
