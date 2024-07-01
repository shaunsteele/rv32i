// load_store.sv

`default_nettype none

module load_store # (
  parameter int XLEN = 32,
  parameter int STRB = XLEN / 4
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_stall,

  // General Signals
  input var         [XLEN-1:0]  i_base,
  input var         [XLEN-1:0]  i_offset,
  input var         [2:0]       i_width,

  // Load Signals
  input var                     i_load_en,
  output var logic              o_load_stall,
  
  // Data Memory Read Address Channel
  output var logic              o_dm_arvalid,
  input var                     i_dm_arready,
  output var logic  [XLEN-1:0]  o_dm_araddr,
  output var logic  [2:0]       o_dm_arprot,

  // Data Memory Read Data Channel
  input var                     i_dm_rvalid,
  output var logic              o_dm_rready,
  input var         [XLEN-1:0]  i_dm_rdata,
  input var         [1:0]       i_dm_rresp,

  // Load Write Back
  output var logic              o_load_valid,
  output var logic  [XLEN-1:0]  o_load_data,
  
  // Store Signals
  input var                     i_store_en,
  input var          [XLEN-1:0] i_store_src,
  output var logic              o_store_stall,

  // Data Memory Write Address Channel
  output var logic              o_dm_awvalid,
  input var                     i_dm_awready,
  output var logic  [XLEN-1:0]  o_dm_awaddr,
  output var logic  [2:0]       o_dm_awprot,

  // Data Memory Write Data Channel
  output var logic              o_dm_wvalid,
  input var                     i_dm_wready,
  output var logic  [XLEN-1:0]  o_dm_wdata,
  output var logic  [STRB-1:0]  o_dm_wstrb
);

// Load Address
logic dm_arvalid;
always_ff @(posedge clk) begin
  if (!rstn) begin
    dm_arvalid <= 0;
  end else begin
    dm_arvalid <= i_load_en;
  end
end

logic dm_arready;
always_comb begin
  o_load_stall = dm_arvalid & ~dm_arready;
end

logic [XLEN-1:0]  addr;
always_comb begin
  addr = i_base + i_offset;
end

logic [XLEN-1:0]  dm_araddr;
always_ff @(posedge clk) begin
  dm_araddr <= addr;
end

assign dm_arprot = 3'b000; // unprivileged secure data access

skid_buffer # (.DLEN(XLEN + 3)) u_ARSB (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (dm_arvalid),
  .o_ready  (dm_arready),
  .i_data   ({dm_arprot, dm_araddr}),
  .o_valid  (o_dm_arvalid),
  .i_ready  (i_dm_arready),
  .o_data   ({o_dm_arprot, o_dm_araddr})
);

// Load Data
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_dm_rready <= 0;
  end else begin
    o_dm_rready <= ~i_stall;
  end
end

assign o_load_valid = i_dm_rvalid;
always_comb begin
  unique case(i_width)
    LsByte: begin
      o_load_data = {{(XLEN-8){i_dm_rdata[7]}}, i_dm_rdata[7:0]};
    end

    LsHalf: begin
      o_load_data = {{(XLEN-16){i_dm_rdata[15]}}, i_dm_rdata[15:0]};
    end

    LsWord: begin
      o_load_data = i_dm_rdata;
    end

    LsByteU: begin
      o_load_data = {{(XLEN-8){i_dm_rdata[7]}}, i_dm_rdata[7:0]};
    end

    LsHalfU: begin
      o_load_data = {{(XLEN-16)}{i_dm_rdata[15]}, i_dm_rdata[15:0]};
    end
  endcase
end

// Store Address
logic dm_awaddr;

always_ff @(posedge clk) begin
  dm_awaddr <= addr;
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    dm_awvalid <= 0;
  end else begin
    dm_awvalid <= i_store_en;
  end
end

logic dm_awready;
skid_buffer # (.DLEN(XLEN)) u_AWSB (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (dm_awvalid),
  .o_ready  (dm_awready),
  .i_data   (dm_awaddr),
  .o_valid  (o_dm_awvalid),
  .i_ready  (i_dm_awready),
  .o_data   (o_dm_awaddr)
);

// store_data
logic dm_wvalid;
always_ff @(posedge clk) begin
  if (!rstn) begin
    dm_wvalid <= 0;
  end else begin
    dm_wvalid <= i_store_en;
  end
end

logic dm_wready;
always_comb begin
  o_store_stall = (dm_awvalid & ~dm_awready) || (dm_wvalid & ~dm_wready);
end

logic [XLEN-1:0]  dm_wdata;
always_ff @(posedge clk) begin
  dm_wdata <= i_src;
end

logic [STRB-1:0]  dm_wstrb;

skid_buffer # (.DLEN(XLEN+STRB)) u_WSB (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (dm_wvalid),
  .o_ready  (dm_wready),
  .i_data   ({dm_wstrb, dm_wdata}),
  .o_valid  (o_dm_wvalid),
  .i_ready  (i_dm_wready),
  .o_data   ({o_dm_wstrb, o_dm_wdata})
);


endmodule
