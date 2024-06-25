// register_file.sv

`default_nettype none

module register_file # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Read Interface
  input var         [4:0]       i_rs1_raddr,
  output var logic  [XLEN-1:0]  o_rs1_rdata,
  output var logic              o_rs1_hazard,

  input var         [4:0]       i_rs2_raddr,
  output var logic  [XLEN-1:0]  o_rs2_rdata,
  output var logic              o_rs2_hazard,

  // Hazard Detection Map Interface
  input var                     i_rd_hdvalid,
  input var         [4:0]       i_rd_hdaddr,

  // Write Interface
  input var                     i_rd_wvalid,
  input var         [4:0]       i_rd_waddr,
  input var         [XLEN-1:0]  i_rd_wdata
);

/* Register Array */
logic [XLEN-1:0]  regs[32];


/* Hazard Detection */
// Active Register Bank
logic [31:0]      hd_regs; // active hazard detection registers

// Set Reset Register
always_ff @(posedge clk) begin
  if (rstn) begin
    hd_regs <= 0;
  end else begin
    if (hd_regs[i_rdwaddr]) begin
      hd_regs[i_rd_waddr] <= ~i_rd_wvalid; // Reset
    end else begin
      hd_regs[i_rd_hdaddr] <= i_rd_hdvalid; // Set
    end
  end
end


/* Read Logic */
always_comb begin
  o_rs1_rdata = regs[i_rs1_raddr];
  o_rs1_hazard = hd_regs[i_rs1_raddr];

  o_rs2_rdata = regs[i_rs2_raddr];
  o_rs2_hazard = hd_regs[i_rs2_raddr];
end


/* Write Logic */
always_ff @(posedge clk) begin
  if (!rstn) begin
    foreach(regs[i]) begin
      regs[i] <= 0;
    end
  end else begin
    if (i_rd_wvalid) begin
      regs[i_rd_waddr] <= i_rd_wdata;
    end else begin
      regs[i_rd_waddr] <= regs[i_rd_waddr];
    end
  end
end


endmodule
