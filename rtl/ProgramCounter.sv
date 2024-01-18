// Program Counter

`default_nettype none

`include "riscv.svh"

module ProgramCounter # (
  parameter int XLEN = 32
)(
  input var         clk,
  input var         rstn,

  input var         [XLEN-1:0]  i_op,
  input var         [XLEN-1:0]  i_id_imm_data,
  input var         [XLEN-1:0]  i_alu_res_data,
  output var logic  [XLEN-1:0]  o_data,
  output var logic  [XLEN-1:0]  o_ret_data
);

/* PC Logic */
logic [XLEN-1:0]  pc;
logic [XLEN-1:0]  pc_d;
always_comb begin
  unique case (i_op)
    PcStop: begin
      pc_d = pc;
    end

    PcIncr: begin
      pc_d = pc + 4;
    end

    PcJAL: begin
      pc_d = i_incr_data;
    end

    PcJALR: begin
      pc_d = pc + i_alu_res_data;
    end

    PcBranch: begin
      pc_d = pc + i_imm_data;
    end

    PcRsvd: begin
      pc_d = pc;
      $warning("Unsupported PC Opcode: 0b%02b", i_op);
    end

    default: begin
      pc_d = 0;
      $error("Illegal PC Opcode: 0b%02b", i_op);
    end
  endcase
end


/* PC Register */
always_ff @(posedge clk) begin
  if (!rstn) begin
    pc <= 0;
  end else begin
    pc <= pc_d;
  end
end

assign o_data = pc;

// Return PC Value
always_comb begin
  o_ret_data = pc + 4;
end

endmodule
