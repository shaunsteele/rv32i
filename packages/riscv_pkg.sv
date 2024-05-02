

package riscv_pkg;

/* Program Counter Opcodes */
localparam int PcOps = 5;
localparam bit [PcOps-1:0]  PcStop    = 5'b00001;
localparam bit [PcOps-1:0]  PcIncr    = 5'b00010;
localparam bit [PcOps-1:0]  PcJAL     = 5'b00100;
localparam bit [PcOps-1:0]  PcJALR    = 5'b01000;
localparam bit [PcOps-1:0]  PcBranch  = 5'b10000;

/* Instruction Opcode TYpes */
localparam bit [6:0] OpIInt     = 7'b0010011; // x13
localparam bit [6:0] OpUImm     = 7'b0110111; // x37
localparam bit [6:0] OpUPc      = 7'b0010111; // x17
localparam bit [6:0] OpRInt     = 7'b0110011; // x33
localparam bit [6:0] OpUJump    = 7'b1101111; // x6F
localparam bit [6:0] OpIJump    = 7'b1100111; // x67
localparam bit [6:0] OpSBranch  = 7'b1100011; // x63
localparam bit [6:0] OpILoad    = 7'b0000011; // x03
localparam bit [6:0] OpSStore   = 7'b0100011; // x23
localparam bit [6:0] OpMMem     = 7'b0001111; // x0F
localparam bit [6:0] OpSystem   = 7'b0;

endpackage
