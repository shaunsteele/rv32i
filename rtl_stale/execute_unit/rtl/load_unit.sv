// load_unit.sv

`default_nettype none

module load_unit # (
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  // Decode Interface
  input var                     i_en,
  input var         [4:0]       i_dest,
  input var         [2:0]       i_width,
  input var         [XLEN-1:0]  i_base,
  input var         [XLEN-1:0]  i_offset,

  // Data Memory Bus Read Address Channel
  output var logic              o_dm_bus_arvalid,
  input var                     i_dm_bus_arready,
  output var logic  [XLEN-1:0]  o_dm_bus_araddr,

  // Data Memory Bus Read Data Channel
  input var                     i_dm_bus_rvalid,
  output var logic              o_dm_bus_rready,
  input var         [XLEN-1:0]  i_dm_bus_rdata
);

typedef enum logic [1:0] {
  LD_IDLE,
  LD_READ,
  LD_WAIT
} state_e;

state_e curr_state;
state_e next_state;

always_comb begin
  unique case (curr_state)
    LD_IDLE: begin
      if (i_en) begin
        
        next_state = 
      end
    end
    LD_WAIT:
    LD_READ: begin
    end
    default: 
  endcase
end

logic [XLEN-1:0]  arvalid;
always_ff @(posedge clk) begin
  if (!rstn) begin
    arvalid <= 0;
  end else begin
    arvalid <= i_en;
  end
end

logic [XLEN-1:0]  araddr;
always_ff @(posedge clk) begin
  araddr <= i_base + i_offset;
end

logic [2:0] width;
always_ff @(posedge clk) begin
  width <= i_width;
end

skid_buffer # (.XLEN(XLEN)) (
  .clk      (clk),
  .rstn     (rstn),
  .i_valid  (arvalid),
  .o_ready  (),
  .i_data   (ardata),
  .o_valid  (o_dm_bus_arvalid),
  .i_ready  (i_dm_bus_arready),
  .o_data   (o_dm_bus_araddr)
);

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_dm_bus_rready <= 0;
  end else begin
    if (o_dm_bus_rready) begin
      o_dm_bus_rready <= i_en | ~i_dm_bus_valid;
    end else begin
      o_dm_bus_rready <= i_en;
    end
  end
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_valid <= 0;
  end else begin
    o_valid <= i_dm_bus_rvalid;
  end
end

always_ff @(posedge clk) begin
  unique case (width)
    LdByte: begin
      o_rdata <= {{(XLEN-8){i_dm_bus_rdata[7]}}, i_dm_bus_rdata[7:0]};
    end

    LdHalf: begin
      o_rdata <= {{(XLEN-16){i_dm_bus_rdata[15]}}, i_dm_bus_rdata[15:0]};
    end
    
    LdWord: begin
      o_rdata <= i_dm_bus_rdata[7:0];
    end
    
    LdByteUnsigned: begin
      o_rdata <= {{(XLEN-8){1'b0}}, i_dm_bus_rdata[7:0]};
    end
    
    LdHalfUnsigned: begin
      o_rdata <= {{(XLEN-16){1'b0}}, i_dm_bus_rdata[15:0]};
    end

    default: begin
      o_rdata <= 0;
    end
  endcase
end


endmodule
