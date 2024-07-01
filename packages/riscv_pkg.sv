

package riscv_pkg;

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


/* Branch Functions */
localparam bit [2:0]  BrBEQ   = 3'b000;
localparam bit [2:0]  BrBNE   = 3'b001;
localparam bit [2:0]  BrBLT   = 3'b100;
localparam bit [2:0]  BrBGE   = 3'b101;
localparam bit [2:0]  BrBLTU  = 3'b110;
localparam bit [2:0]  BrBGEU  = 3'b111;


/* Integer ALU Functions*/
localparam bit [9:0]  AluADD  = 10'b0000000_000;
localparam bit [9:0]  AluSUB  = 10'b0100000_000;
localparam bit [9:0]  AluSLL  = 10'b0000000_001;
localparam bit [9:0]  AluSLT  = 10'b0000000_010;
localparam bit [9:0]  AluSLTU = 10'b0000000_011;
localparam bit [9:0]  AluXOR  = 10'b0000000_100;
localparam bit [9:0]  AluSRL  = 10'b0000000_101;
localparam bit [9:0]  AluSRA  = 10'b0100000_101;
localparam bit [9:0]  AluOR   = 10'b0000000_110;
localparam bit [9:0]  AluAND  = 10'b0000000_111;


endpackage
