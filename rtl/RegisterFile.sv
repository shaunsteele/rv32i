// RegisterFile.sv

`default_nettype none

module RegisterFile # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Register Source 2 Read Address
  input var                     i_rs2_arvalid,
  output var logic              o_rs2_arready,
  input var         [4:0]       i_rs2_araddr,

  // Register Source 2 Read Data
  output var logic              o_rs2_rvalid,
  input var                     i_rs2_rready,
  output var logic  [XLEN-1:0]  o_rs2_rdata,

  // Register Source 1 Read Address
  input var                     i_rs1_arvalid,
  output var logic              o_rs1_arready,
  input var         [4:0]       i_rs1_araddr,

  // Register Source 2 Read Data
  output var logic              o_rs1_rvalid,
  input var logic               i_rs1_rvalid,
  output var logic  [XLEN-1:0]  o_rs1_rdata,

  // Destination Register Write Address and Data
  input var                     i_rd_wvalid,
  output var logic              o_rd_wready,
  input var         [4:0]       i_rd_waddr,     // destination register address
  input var         [XLEN-1:0]  i_rd_wdata
);

// Write Handshake
logic rd_wen;
always_comb begin
  rd_wen = i_rd_wvalid & o_rd_wready;
end

// Register Array
logic [XLEN-1:0] register_file[32];

// Register Write Logic
always_ff @(posedge clk) begin
  if (!rstn) begin
    for (int i=0; i < 32; i++) begin
      register_file[i] <= 0;
    end
  end else begin
    if (rd_wen) begin
      if (i_rd_waddr == 5'b0) begin
        register_file[i_rd_waddr] <= 0;
      end else begin
        register_file[i_rd_waddr] <= i_rd_wdata;
      end
    end else begin
      register_file[i_rd_waddr] <= register_file[i_rd_waddr];
    end
  end
end

// Read Logic
logic rs2a_ren;
logic rs1a_ren;
always_comb begin
  rs2a_ren = i_rs2_arvalid & o_rs2_arready;
  rs1a_ren = i_rs1_arvalid & o_rs1_arvalid;
end

assign o_rs2_rvalid = rs2a_ren;
assign o_rs1_rvalid = rs1a_ren;

always_comb begin
  if (rs2a_en) begin
    o_rs2_rdata = register_file[i_rs2_araddr];
  end else begin
    o_rs2_rdata = 0;
  end
end

always_comb begin
  if (rs1a_en) begin
    o_rs1_rdata = register_file[i_rs1_araddr];
  end else begin
    o_rs1_rdata = 0;
  end
end

endmodule
