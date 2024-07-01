// core.sv

`default_nettype none

module core # (
  parameter int XLEN = 32
)(
  input var       clk,
  input var       rstn,

  axi5_lite_if.M  im_bus,
  axi5_lite_if.M  dm_bus
);

// Control Transfer
logic [2:0]       id_funct3;
logic [XLEN-1:0]  id_immediate;
logic [XLEN-1:0]  rf_rs1_rdata;
logic [XLEN-1:0]  rf_rs2_rdata;
logic             ct_stall;
logic             ct_br_en;
logic             ct_jump_en;
logic             ct_jump_reg_sel;
logic [XLEN-1:0]  ct_jump_ret;
logic [XLEN-1:0]  ct_up_pc;

logic             wb_load_stall;
logic             ls_store_stall;
always_comb begin
  ct_stall = wb_load_stall | ls_store_stall;
end

control_transfer # (.XLEN(XLEN)) u_CT (
  .clk            (clk),
  .rstn           (rstn),
  .i_id_funct3    (id_funct3),
  .i_id_immediate (id_immediate),
  .i_rf_rs1_rdata (rf_rs1_rdata),
  .i_rf_rs2_rdata (rf_rs2_rdata),
  .i_stall        (ct_stall),
  .i_br_en        (ct_br_en),
  .i_jump_en      (ct_jump_en),
  .i_jump_reg_sel (ct_jump_reg_sel),
  .o_jump_ret     (ct_jump_ret),
  .o_up_pc        (ct_up_pc),
  .o_im_arvalid   (im_bus.arvalid),
  .i_im_arready   (im_bus.arready),
  .o_im_araddr    (im_bus.araddr),
  .o_im_arprot    (im_bus.arprot)
);

// Decode Registers
logic             dr_int_en;
logic [9:0]       dr_int_funct;
logic [XLEN-1:0]  dr_int_src1;
logic [XLEN-1:0]  dr_int_src2;
logic             dr_up_en;
logic [XLEN-1:0]  dr_up_imm;
logic             dr_up_pc_sel;
logic [XLEN-1:0]  dr_up_pc;
logic [XLEN-1:0]  dr_lsu_base;
logic [XLEN-1:0]  dr_lsu_offset;
logic [2:0]       dr_lsu_width;
logic             dr_load_en;
logic             dr_store_en;
logic [XLEN-1:0]  dr_store_src;
logic             dr_wb_jump_en;
logic [4:0]       dr_rf_rd_waddr;
logic             wb_rf_rd_wvalid;
logic [4:0]       wb_rf_rd_waddr;
logic [XLEN-1:0]  wb_rf_rd_wdata;

decode_registers #  (.XLEN(XLEN)) u_DR (
  .clk            (clk),
  .rstn           (rstn),
  .i_im_rvalid    (im_bus.rvalid),
  .o_im_rready    (im_bus.rready),
  .i_im_rdata     (im_bus.rdata),
  .i_im_rresp     (im_bus.rresp),
  .o_ct_funct3    (id_funct3),
  .o_ct_rs1_rdata (rf_rs1_rdata),
  .o_ct_rs2_rdata (rf_rs2_rdata),
  .o_ct_immediate (id_immediate),
  .o_int_en       (dr_int_en),
  .o_int_funct    (dr_int_funct),
  .o_int_src1     (dr_int_src1),
  .o_int_src2     (dr_int_src2),
  .o_up_en        (dr_up_en),
  .o_up_imm       (dr_up_imm),
  .o_up_pc_sel    (dr_up_pc_sel),
  .o_up_pc        (dr_up_pc),
  .o_lsu_base     (dr_lsu_base),
  .o_lsu_offset   (dr_lsu_offset),
  .o_lsu_width    (dr_lsu_width),
  .i_load_stall   (wb_load_stall),
  .o_load_en      (dr_load_en),
  .o_store_en     (dr_store_en),
  .o_store_src    (dr_store_src),
  .i_store_stall  (ls_store_stall),
  .o_wb_jump_en   (dr_wb_jump_en),
  .o_wb_waddr     (dr_rf_rd_waddr),
  .i_rf_rd_wvalid (wb_rf_rd_wvalid),
  .i_rf_rd_waddr  (wb_rf_rd_waddr),
  .i_rf_rd_wdata  (wb_rf_rd_wdata)
);

// Integer ALU
logic [XLEN-1:0]  int_res;

integer_alu # (.XLEN(XLEN)) u_ALU (
  .clk        (clk),
  .rstn       (rstn),
  .i_en       (dr_int_en),
  .i_funct    (dr_int_funct),
  .i_src1     (dr_int_src1),
  .i_src2     (dr_int_src2),
  .i_stall    (ct_stall),
  .o_res      (int_res)
);

// Upper
logic [XLEN-1:0]  up_reg;
upper # (.XLEN(XLEN)) u_UP (
  .clk          (clk),
  .rstn         (rstn),
  .i_en         (dr_up_en),
  .i_stall      (ct_stall),
  .i_immediate  (dr_up_imm),
  .i_pc_sel     (dr_up_pc_sel),
  .i_pc         (dr_up_pc),
  .o_up_reg     (up_reg)
);

// Load Store
logic             ls_load_valid;
logic [XLEN-1:0]  ls_load_data;

load_store # (.XLEN(XLEN)) u_LS (
  .clk            (clk),
  .rstn           (rstn),
  .i_stall        (wb_load_stall),
  .i_base         (dr_lsu_base),
  .i_offset       (dr_lsu_offset),
  .i_width        (dr_lsu_width),
  .i_load_en      (dr_load_en),
  .o_load_stall   (ls_load_stall),
  .o_dm_arvalid   (dm_bus.arvalid),
  .i_dm_arready   (dm_bus.arready),
  .o_dm_araddr    (dm_bus.araddr),
  .o_dm_arprot    (dm_bus.arprot),
  .i_dm_rvalid    (dm_bus.rvalid),
  .o_dm_rready    (dm_bus.rready),
  .i_dm_rresp     (dm_bus.rresp),
  .o_load_valid   (ls_load_valid),
  .o_load_data    (ls_load_data),
  .i_store_en     (dr_store_en),
  .i_store_src    (dr_store_src),
  .o_store_stall  (ls_store_stall),
  .o_dm_awvalid   (db_bus.awvalid),
  .i_dm_awready   (db_bus.awready),
  .o_dm_awaddr    (db_bus.awaddr),
  .o_dm_awprot    (db_bus.awprot),
  .o_dm_wvalid    (db_bus.wvalid),
  .i_dm_wready    (db_bus.wready),
  .o_dm_wdata     (db_bus.wdata),
  .o_dm_wstrb     (db_bus.wstrb)
);

// Write Back
write_back # (.XLEN(XLEN)) u_WB (
  .clk          (clk),
  .rstn         (rstn),
  .i_load_en    (dr_load_en),
  .i_int_en     (dr_int_en),
  .i_jump_en    (dr_wb_jump_en),
  .i_waddr      (dr_rf_rd_waddr),
  .o_load_stall (wb_load_stall),
  .i_load_valid (ls_load_valid),
  .i_load_data  (ls_load_data),
  .i_int_res    (int_res),
  .i_up_en      (dr_up_en),
  .i_up_data    (dr_up_reg),
  .i_jump_ret   (ct_jump_ret),
  .o_rd_wvalid  (wb_rf_rd_wvalid),
  .o_rd_waddr   (wb_rf_rd_wvalid),
  .o_rd_wdata   (wb_rf_rd_wvalid)
);

endmodule
