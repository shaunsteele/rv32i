//  ExecuteUnit.sv
//    Program Counter and ALU

`default_nettype none

module ExecuteUnit # (
  parameter int XLEN      = 32,
  parameter int DMADDRLEN = XLEN,
  parameter int DMDATALEN = XLEN,
  parameter int DMSTRBLEN = DMDATALEN / 8
)(
  input var                         clk,
  input var                         rstn,

  // Execute Enable
  input var logic                   i_execute_valid,  // Start Execute
  output var logic                  o_execute_ready,  // Execute Done

  // Immediate Value
  input var         [XLEN-1:0]      i_imm_data,

  // Register File
  // input var                         i_rs2_rvalid,
  // output var logic                  o_rs2_rready,
  // input var         [XLEN-1:0]      i_rs2_rdata,
  // input var                         i_rs1_rvalid,
  // output var logic                  o_rs1_rready,
  // input var         [XLEN-1:9]      i_rs1_rdata,

  // Program Counter
  input var         [1:0]           i_pc_incr_op,
  // input var                         i_pc_incr_alu_sel,
  output var logic                  o_pc_valid,
  output var logic  [XLEN-1:0]      o_pc_data//,

  // Arithmetic Logic Unit
  // input var                         i_alu_op_valid,
  // output var logic                  o_alu_op_ready,
  // input var         [3:0]           i_alu_op_data,
  // input var                         i_alu_a_pc_sel,
  // input var                         i_alu_b_imm_sel,
  // output var logic                  o_alu_f_valid,
  // input var logic                   o_alu_f_ready,
  // output var logic  [XLEN-1:0]      o_alu_f_data,
  // output var logic                  o_alu_z_valid,

  // Memory Unit
  // input var                         i_mem_wvalid,
  // output var logic                  o_mem_wready,
  // input var         [DMSTRBLEN-1:0] i_mem_wstrb,
  // output var logic                  o_mem_rvalid,
  // input var logic                   i_mem_rready,
  // input var logic   [DMSTRBLEN-1:0] i_mem_rstrb,
  // input var logic                   i_mem_rsign,
  // if_axi_lite.M                     m_axi
);


/* Program Counter */
logic [XLEN-1:0] pc_incr_data;
always_comb begin
  // if (i_pc_incr_alu_sel) begin
  //   pc_incr_data = o_alu_f_data;
  // end else begin
    pc_incr_data = i_imm_data;
  // end
end

ProgramCounter # (
  .XLEN (XLEN)
) u_PC (
  .clk          (clk),
  .rstn         (rstn),
  .i_incr_valid (i_execute_valid),
  .i_incr_op    (i_pc_incr_op),
  .i_incr_data  (pc_incr_data),
  .o_pc_valid   (o_pc_valid),
  .o_pc_data    (o_pc_data)
);

assign o_execute_ready = o_pc_valid;


/* Arithmetic Logic Unit */
// assign o_rs2_rready = o_alu_op_ready;

// logic alu_b_valid;
// logic [XLEN-1:0] alu_a_data;
// always_comb begin
//   if (i_alu_b_imm_sel) begin
//     alu_b_valid = i_dec_imm_valid;
//     alu_b_data = i_dec_imm_data;
//   end else begin
//     alu_b_valid = i_rs2_rvalid;
//     alu_b_data = i_rs2_rdata;
//   end
// end

// assign o_rs1_rready = o_alu_op_ready;

// logic alu_a_valid;
// logic [XLEN-1:0] alu_a_data;
// always_comb begin
//   if (i_alu_a_pc_sel) begin
//     alu_a_valid = o_pc_valid;
//     alu_a_data = o_pc + 4;
//   end else begin
//     alu_a_valid = i_rs1_rvalid;
//     alu_a_data = i_rs1_rdata;
//   end
// end

// ArithmeticLogicUnit # (
//   .XLEN (XLEN)
// ) u_ALU (
//   .clk        (clk),
//   .rstn       (rstn),
//   .i_op_valid (i_alu_op_valid),
//   .o_op_ready (o_alu_op_ready),
//   .i_op_data  (i_alu_op_data),
//   .i_a_valid  (alu_a_valid),
//   .i_a_data   (alu_a_data),
//   .i_b_valid  (alu_b_valid),
//   .i_b_data   (alu_b_data),
//   .o_f_valid  (o_alu_f_valid),
//   .o_f_data   (o_alu_f_data),
//   .o_z_valid  (o_alu_z_valid)
// );


/* Memory Unit */
// logic mem_axvalid;
// assign mem_axvalid = alu_f_valid;

// logic [DMDATALEN-1:0] mem_rdata_d;
// MemoryUnit # (
//   .XLEN       (XLEN),
//   .DMADDRLEN  (DMADDRLEN),
//   .DMDATALEN  (DMDATALEN),
//   .DMSTRBLEN  (DMSTRBLEN)
// ) u_MU (
//   .clk        (clk),
//   .rstn       (rstn),
//   .i_axaddr   (o_alu_f_data),
//   .i_awvalid  (mem_axvalid),
//   .o_awready  (),
//   .i_arvalid  (mem_axvalid),
//   .o_arready  (),
//   .i_wvalid   (i_mem_wvalid),
//   .o_wready   (o_mem_wready),
//   .i_wdata    (i_rs2_rdata),
//   .i_wstrb    (i_mem_wstrb),
//   .o_rvalid   (o_mem_rvalid),
//   .i_rready   (i_mem_rvalid),
//   .o_rdata    (mem_rdata_d),
//   .m_axi      (m_axi)
// );

// logic [DMDATALEN-1:0] mem_rdata;
// always_comb begin
//   case (i_mem_rstrb)
//     4'b0001: begin
//       if (i_mem_rsign) begin
//         mem_rdata = { {(XLEN-24){mem_rdata[7]}}, mem_rdata_d[7:0] };
//       end else begin
//         mem_rdata = { {(XLEN-24){1'b0}}, mem_rdata_d[7:0] };
//       end
//     end

//     4'b0011: begin
//       if (i_mem_rsign) begin
//         mem_rdata = { {(XLEN-16){mem_rdata_d[15]}}, mem_rdata_d[15:0]};
//       end else begin
//         mem_rdata = { {(XLEN-16){0}}, mem_rdata_d[15:0]};
//       end
//     end

//     4'b1111: begin
//       mem_rdata = mem_rdata_d;
//     end

//     default: begin
//       $warning("Illegal rstrb: 0b%04b", i_mem_rstrb);
//     end
//   endcase
// end



endmodule
