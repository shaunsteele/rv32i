// execute_unit.sv

`default_nettype none

module execute_unit # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Decode Integer Unit Interface
  input var                     i_alu_en,
  input var         [9:0]       i_alu_op,
  input var         [XLEN-1:0]  i_alu_src1,
  input var         [XLEN-1:0]  i_alu_src1,
  input var         [4:0]       i_alu_waddr,

  // Decode Write Back Interface
  output var logic              o_wb_rd_wvalid,
  output var logic  [4:0]       o_wb_rd_waddr,
  output var logic  [XLEN-1:0]  o_wb_rd_wdata
);

//
logic alu_valid;
logic [4:0] alu_wb_waddr;
logic [XLEN-1:0]  alu_res;
integer_unit # (.XLEN(XLEN)) u_IU (
  .clk        (clk),
  .rstn       (rstn),
  .i_en       (i_alu_en),
  .i_op       (i_alu_op),
  .i_src1     (i_alu_src1),
  .i_src2     (i_alu_src2),
  .i_waddr    (i_alu_waddr),
  .o_valid    (alu_valid),
  .o_wb_waddr (alu_wb_waddr),
  .o_res      (alu_res)
);

/*
  Execute Control Flow
  - ILS (integer/load/store) receives command
  - ILS executes command
  - opcode register forwarded (skid buffer?)
  - write back input mux
  - write back data at correct address
*/

logic [2:0] ils[3];
always_ff @(posedge clk) begin
  if (!rstn) begin
    ils[0] <= 0;
    ils[1] <= 0;
    ils[2] <= 0;
  end else begin
    ils[0] <= {i_alu_enable, i_load_enable, i_store_enable};
    ils[1] <= ils[0];
    ils[2] <= ils[1];
  end
end


// Write Back Registers
always_ff @(posedge clk) begin
  
end

logic load_latch;
always_ff @(posedge clk) begin
  if (!rstn) begin
    load_latch <= 0;
  end else begin
    if (load_latch) begin
      load_latch <= ~i_dm_bus_rvalid;
    end else begin
      load_latch <= i_load_en;
    end
  end
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_wb_rd_wvalid <= 0;
  end else begin
    if (i_load_en) begin
      
    end
    if (alu_en)
    o_wb_rd_wvalid <= alu_valid;
  end
end
// alu enable
// alu valid (next)
// load (read) en
// load (read) valid (next2)
// store (write) en
// store (write) valid (next)
// 3 bit fifo
logic [2:0] ils_reg;
always_ff @(posedge clk) begin
  ils_reg <= {i_alu_en, i_load_en, i_store_en};
end
always_comb begin
  if (alu_valid) begin
    o_wb_rd_waddr <= alu_wb_waddr;
    o_wb_rd_wdata <= alu_res;
  end else if ()
end

endmodule
