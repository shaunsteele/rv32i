// write_back.sv

`default_nettype none

module write_back # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Decoded Control Signals
  input var                     i_load_en,
  input var                     i_int_en,
  input var                     i_jump_en,
  input var         [4:0]       i_waddr,
  output var logic              o_load_stall,

  // Load Unit
  input var                     i_load_valid,
  input var         [XLEN-1:0]  i_load_data,

  // Integer Unit
  input var         [XLEN-1:0]  i_int_res,

  // Upper Unit
  input var                     i_up_en,
  input var         [XLEN-1:0]  i_up_data,

  // Jump Unit
  input var         [XLEN-1:0]  i_jump_ret,

  // Register File Signals
  output var logic              o_rd_wvalid,
  output var logic  [4:0]       o_rd_waddr,
  output var logic  [XLEN-1:0]  o_rd_wdata
);


// load enable pipeline registers
logic load_ex_en;
logic load_mem_en;

always_comb begin
  o_load_stall = load_mem_en & ~i_load_valid;
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    load_ex_en <= 0;
    load_mem_en <= 0;
  end else begin
    if (load_stall) begin
      load_ex_en <= load_ex_en;
      load_mem_en <= load_mem_en;
    end else begin
      load_ex_en <= i_load_en;
      load_mem_en <= load_ex_en;
    end
  end
end


// integer pipeline registers
logic int_ex_en;
logic int_mem_en;

always_ff @(posedge clk) begin
  if (!rstn) begin
    int_ex_en <= 0;
    int_mem_en <= 0;
  end else begin
    if (o_load_stall) begin
      int_ex_en <= int_ex_en;
      int_mem_en <= int_mem_en;
    end else begin
      int_ex_en <= i_int_en;
      int_mem_en <= int_ex_en;
    end
  end
end

logic [XLEN-1:0]  int_mem_res;
always_ff @(posedge clk) begin
  int_mem_res <= i_int_res;
end


// upper pipeline registers
logic up_ex_en;
logic up_mem_en;
always_ff @(posedge clk) begin
  if (!rstn) begin
    up_ex_en <= 0;
    up_mem_en <= 0;
  end else begin
    if (o_load_stall) begin
      up_ex_en <= up_ex_en;
      up_mem_en <= up_mem_en;
    end else begin
      up_ex_en <= i_up_en;
      up_mem_en <= up_ex_en;
    end
  end
end

logic [XLEN-1:0]  up_mem_data;
always_ff @(posedge clk) begin
  up_mem_data <= i_up_data;
end


// jump pipeline registers
logic jump_ex_en;
logic jump_mem_en;
always_ff @(posedge clk) begin
  if (!rstn) begin
    jump_ex_en <= 0;
    jump_mem_en <= 0;
  end else begin
    if (o_load_stall) begin
      jump_ex_en <= jump_ex_en;
      jump_mem_en <= jump_mem_en;
    end else begin
      jump_ex_en <= i_jump_en;
      jump_mem_en <= jump_ex_en;
    end
  end
end

logic [XLEN-1:0]  jump_mem_ret;
always_ff @(posedge clk) begin
  jump_mem_ret <= i_jump_ret;
end

// rd waddr pipeline registers
logic [4:0] waddr_ex;
logic [4:0] waddr_mem;
always_ff @(posedge clk) begin
  if (o_load_stall) begin
    waddr_ex <= waddr_ex;
    waddr_mem <= waddr_mem;
  end else begin
    waddr_ex <= i_waddr;
    waddr_mem <= waddr_ex;
  end
end

// register file write
logic [XLEN-1:0]  next_rd_wdata;

always_comb begin
  unique case ({load_mem_en, int_mem_en, up_mem_en, jump_mem_en})
    4'b1000: begin // Load Data
      next_rd_wvalid = load_mem_en & i_load_valid;
      next_rd_wdata = i_load_data;
    end

    4'b0100: begin // Integer Data
      next_rd_wvalid = 1;
      next_rd_wdata = i_int_mem_res;
    end

    4'b0010: begin // Upper Data
      next_rd_wvalid = 1;
      next_rd_wdata = i_up_mem_data;
    end

    4'b0001: begin // Jump Data
      next_rd_wvalid = 1;
      next_rd_wdata = i_jump_mem_ret;
    end

    default: begin
      next_rd_wvalid = 0;
      next_rd_wdata = o_rd_wdata;
    end
  endcase
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_rd_wvalid <= 0;
  end else begin
    o_rd_wvalid <= next_rd_wvalid;
  end
end

always_ff @(posedge clk) begin
  o_rd_waddr <= waddr_mem;
  o_rd_wdata <= next_rd_wdata;
end

endmodule
