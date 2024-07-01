// fetch_unit.sv

`default_nettype none

module fetch_unit # (
  parameter XLEN = 32,
  parameter FU_INITIAL_ADDRESS = 32'h0,
  parameter FU_USER_DATA = 3'b0
)(
  input var                   clk,
  input var                   rstn,

  output var logic              o_im_bus_arvalid,
  input var                     i_im_bus_arready,
  output var logic  [XLEN-1:0]  o_im_bus_araddr,
  output var logic  [2:0]       o_im_bus_arprot,

  output var logic  
);

// register file
logic [XLEN-1:0]  rf_rs1_rdata;
logic [XLEN-1:0]  rf_rs2_rdata;

// control transfer
logic             ct_br_take;

// instruction decode
logic [6:0]       id_opcode;
logic [6:0]       id_funct7;
logic [2:0]       id_funct3;
logic [4:0]       id_rs1_raddr;
logic [4:0]       id_rs2_raddr;
logic [4:0]       id_rd_waddr;
logic [XLEN-1:0]  id_immediate;


control_transfer # (.XLEN(XLEN)) u_BC (
  .i_funct      (i_id_funct3),
  .i_src1       (i_rf_rs1_rdata),
  .i_src2       (i_rf_rs2_rdata),
  .o_take       (ct_br_take),
  .o_immediate  (id_immediate)
);

logic ct_enable = 0;
always_comb begin : 
  ct_enable = ct_br_take || id_opcode == OpJAL || id_opcode == OpJALR;
end

axi4_stream_counter # (
  .LEN      (XLEN),
  .INITIAL  (FU_INITIAL_ADDRESS),
  .USER     ({1'b0, FU_PROT}),
  .INCR     (4)
) u_PC (
  .clk          (clk),
  .rstn         (rstn),
  .i_load_en    (ct_enable),
  .i_load_data  (ct_immediate),
  .o_tvalid     (o_im_bus_arvalid),
  .i_tready     (i_im_bus_arready),
  .o_tdata      (o_im_bus_araddr),
  .o_tuser      (o_im_bus_arprot)
);

instruction_decoder # (.XLEN(XLEN)) u_ID (
  .i_instruction  (i_im_bus_rdata),
  .o_opcode       (id_opcode),
  .o_funct7       (id_funct7),
  .o_funct3       (id_funct3),
  .o_rs1_raddr    (id_rs1_raddr),
  .o_rs2_raddr    (id_rs2_raddr),
  .o_rd_waddr     (id_rd_waddr;),
  .o_immediate    (id_immediate)
);

register_file # (.XLEN(XLEN)) u_RF (
  .clk          (clk),
  .rstn         (rstn),
  .i_rs1_raddr  (id_rs1_raddr),
  .o_rs1_rdata  (),
  .o_rs1_hazard (),
  .i_rs2_raddr  (id_rs2_raddr),
  .o_rs2_rdata  (),
  .o_rs2_hazard (),
  .i_rd_hdvalid (),
  .i_rd_hdaddr  (),
  .i_rd_wvalid  (),
  .i_rd_waddr   (),
  .i_rd_wdata   ()
);



endmodule
