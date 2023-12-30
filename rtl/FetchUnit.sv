//  FetchUnit.sv
//    Interfaces with the Read Address and Data Channels
//    of the Instruction Memory to fetch instructions

`default_nettype none

module FetchUnit # (
  parameter int XLEN = 32,
  parameter int ILEN = 32,
  parameter int AXILADDRLEN = 32,
  parameter int AXILDATALEN = XLEN,
  parameter int PC_INCR = 4,
  parameter bit [AXILADDRLEN-1:0] PC_INIT = 0
)(
  input var                           clk,
  input var                           rstn,

  input var                           i_fetch_instr,  // Fetch Enable

  input var         [AXILADDRLEN-1:0] i_pc,           // Program Counter

  output var logic                    o_instr_valid,  // Instruction Valid
  output var logic  [ILEN-1:0]        o_instr_data,   // Instruction Register

  if_axi_lite.M                       axi // Instruction Memory Interface
);


/* AXI-Lite Instruction RAM Logic */
// Read Address Channel
assign axi.araddr = i_pc;

always_ff @(posedge clk) begin
  if (!rstn) begin
    axi.arvalid <= 0;
  end else begin
    axi.arvalid <= i_fetch_instr;
  end
end

// Read Data Channel
always_ff @(posedge clk) begin
  if (!rstn) begin
    axi.rready <= 0;
  end else begin
    axi.rready <= 1;
  end
end

always_comb begin
  o_instr_valid = axi.rready & axi.rvalid;
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_instr_data <= 0;
  end else begin
    if (o_instr_valid) begin
      o_instr_data <= axi.rdata[ILEN-1:0];
    end else begin
      o_instr_data <= o_instr_data;
    end
  end
end


/* Unused AXI-Lite Signals */
assign axi.awprot = 0;
assign axi.arprot = 0;


endmodule
