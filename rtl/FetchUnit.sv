//  FetchUnit.sv
//    Interfaces with the Read Address and Data Channels
//    of the Instruction Memory to fetch instructions

`default_nettype none

module FetchUnit # (
  parameter int XLEN      = 32,
  parameter int IMDATALEN = 32
)(
  input var                           clk,
  input var                           rstn,

  input var                           i_fetch_valid,
  output var logic                    o_fetch_ready,
  input var         [XLEN-1:0]        i_fetch_addr,

  output var logic                    o_instr_valid,
  input var                           i_instr_ready,
  output var logic  [IMDATALEN-1:0]   o_instr_data,

  if_axi4_lite.M                      m_axi
);


assign m_axi.arvalid = i_fetch_valid;
assign o_fetch_ready = m_axi.arready;
assign m_axi.araddr = i_fetch_addr >> 2;

logic ar_en;
always_comb begin
  ar_en = m_axi.arvalid & m_axi.arready;
end

assign o_instr_valid = m_axi.rvalid;
assign m_axi.rready = i_instr_ready;
assign o_instr_data = m_axi.rdata;

endmodule
