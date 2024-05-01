

package riscv_pkg;

localparam int PcOps = 5;
localparam bit [PcOps-1:0]  PcStop    = 5'b00001;
localparam bit [PcOps-1:0]  PcIncr    = 5'b00010;
localparam bit [PcOps-1:0]  PcJAL     = 5'b00100;
localparam bit [PcOps-1:0]  PcJALR    = 5'b01000;
localparam bit [PcOps-1:0]  PcBranch  = 5'b10000;

endpackage
