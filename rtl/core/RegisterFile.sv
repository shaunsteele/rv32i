// RegisterFile.sv

`default_nettype none

module RegisterFile # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Read Interface
  input var         [4:0]       i_rs1_raddr,
  output var logic  [XLEN-1:0]  o_rs1_rdata,

  input var         [4:0]       i_rs2_raddr,
  output var logic  [XLEN-1:0]  o_rs2_rdata,

  // Write Interface
  input var                     i_rd_wvalid,
  input var         [4:0]       i_rd_waddr,
  input var         [XLEN-1:0]  i_rd_wdata
);


/* Register Array */
logic [XLEN-1:0] register_file[32];


/* Read Logic */
always_comb begin
  o_rs2_rdata = register_file[i_rs2_raddr];
  o_rs1_rdata = register_file[i_rs1_raddr];
end


/* Write Logic */
always_ff @(posedge clk) begin
  if (!rstn) begin
    foreach(register_file[i]) begin
      register_file[i] <= 0;
    end
  end else begin
    if (i_rd_wvalid) begin
      if (i_rd_waddr == 0) begin
        register_file[0] <= 0;
      end else begin
        register_file[i_rd_waddr] <= i_rd_wdata;
      end
    end else begin
      register_file[i_rd_waddr] <= register_file[i_rd_waddr];
    end
  end
end


endmodule
