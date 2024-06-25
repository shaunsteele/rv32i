// program_counter

`default_nettype none

module program_counter import riscv_pkg::*;
#(
  parameter int XLEN = 32
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_en,
  input var         [PcOps-1:0] i_op,           // opcode
  input var         [XLEN-1:0]  i_id_immediate, // decoded immediate
  input var         [XLEN-1:0]  i_alu_res,      // alu result
  output var logic  [XLEN-1:0]  o_addr,         // pc address
  output var logic  [XLEN-1:0]  o_branch_addr,  // pc branch address
  output var logic  [XLEN-1:0]  o_ret_addr      // pc return address
);


/* PC Register */
logic [XLEN-1:0]  pc;
logic [XLEN-1:0]  pc_d;
always_ff @(posedge clk) begin
  if (!rstn) begin
    pc <= 0;
  end else begin
    pc <= pc_d;
  end
end

assign o_addr = pc;

/* PC Logic */
// Adders
logic [XLEN-1:0]  pc_incr;
always_comb begin
  pc_incr = pc + 4;
end

assign o_ret_addr = pc_incr;

logic [XLEN-1:0]  pc_branch;
always_comb begin
  pc_branch = pc + i_id_immediate;
end

assign o_branch_addr = pc_branch;

// Mux
always_comb begin
  if (!i_en) begin
    pc_d = pc;
  end else begin
    unique case (i_op)
      PcStop: begin
        pc_d = pc;
      end

      PcIncr: begin
        pc_d = pc_incr;
      end

      PcJAL: begin
        pc_d = i_id_immediate;
      end

      PcJALR: begin
        pc_d = pc + i_alu_res;
      end

      PcBranch: begin
        pc_d = pc_branch;
      end

      default: begin
        pc_d = 0;
        // $error("Illegal or Unsupported PC Opcode: %s 0b%02b", i_op.name(), i_op);
      end
    endcase
  end
end

endmodule
