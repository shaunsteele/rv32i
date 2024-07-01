// branch_checker.sv

`default_nettype none

module branch_checker # (
  parameter int XLEN = 32 
)(
  input var             i_valid,
  input var [2:0]       i_funct3,

  input var [XLEN-1:0]  i_rs1_rdata_d,
  input var [XLEN-1:0]  i_rs2_rdata_d,

  output var logic      o_take
);

import riscv_pkg::*;

always_comb begin
  if (i_valid) begin
    unique case (i_funct3)
      BrBEQ: begin
        o_take = i_rs1_rdata_d == i_rs2_rdata_d;
      end

      BrBNE: begin
        o_take = i_rs1_rdata_d != i_rs2_rdata_d;
      end

      BrBLT: begin
        o_take = $signed(i_rs1_rdata_d) < $signed(i_rs2_rdata_d);
      end

      BrBGE: begin
        o_take = $signed(i_rs1_rdata_d) >= $signed(i_rs2_rdata_d);
      end

      BrBLTU: begin
        o_take = $unsigned(i_rs1_rdata_d) < $unsigned(i_rs2_rdata_d);
      end

      BrBGEU: begin
        o_take = $unsigned(i_rs1_rdata_d) >= $unsigned(i_rs2_rdata_d);
      end

      default: begin
        o_take = 0;
      end
    endcase
  end   
end

endmodule
