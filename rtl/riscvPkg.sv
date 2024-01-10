// riscvPkg.sv

`default_nettype none

package riscvPkg;

/* Opcode Types */
localparam bit [6:0] OpIInt     = 7'b0010011;
localparam bit [6:0] OpUImm     = 7'b0110111;
localparam bit [6:0] OpUPc      = 7'b0010111;
localparam bit [6:0] OpRInt     = 7'b0110011;
localparam bit [6:0] OpUJump    = 7'b1101111;
localparam bit [6:0] OpIJump    = 7'b1100111;
localparam bit [6:0] OpSBranch  = 7'b1100011;
localparam bit [6:0] OpILoad    = 7'b0000011;
localparam bit [6:0] OpSStore   = 7'b0100011;
localparam bit [6:0] OpMMem     = 7'b0001111;
localparam bit [6:0] OpSystem   = 7'b0;



/* ALU Opcodes */
localparam bit [3:0] AluAdd   = 4'b0000;
localparam bit [3:0] AluSub   = 4'b1000;
localparam bit [3:0] AluSll   = 4'b0001;
localparam bit [3:0] AluSlt   = 4'b0010;
localparam bit [3:0] AluSltu  = 4'b0011;
localparam bit [3:0] AluXor   = 4'b0100;
localparam bit [3:0] AluSrl   = 4'b0101;
localparam bit [3:0] AluSra   = 4'b1101;
localparam bit [3:0] AluOr    = 4'b0110;
localparam bit [3:0] AluAnd   = 4'b0111;


/* Instruction Decode */
// Format: { funct7, funct3, opcode }
localparam logic [16:0] InstADDI  = { 7'bxxxxxxx, 3'b000, OpIInt    };
localparam logic [16:0] InstSLTI  = { 7'bxxxxxxx, 3'b010, OpIInt    };
localparam logic [16:0] InstSLTIU = { 7'bxxxxxxx, 3'b011, OpIInt    };
localparam logic [16:0] InstXORI  = { 7'bxxxxxxx, 3'b100, OpIInt    };
localparam logic [16:0] InstORI   = { 7'bxxxxxxx, 3'b110, OpIInt    };
localparam logic [16:0] InstANDI  = { 7'bxxxxxxx, 3'b111, OpIInt    };
localparam logic [16:0] InstSLLI  = { 7'b0000000, 3'b001, OpIInt    };
localparam logic [16:0] InstSRLI  = { 7'b0000000, 3'b101, OpIInt    };
localparam logic [16:0] InstSRAI  = { 7'b0100000, 3'b101, OpIInt    };
localparam logic [16:0] InstLUI   = { 7'bxxxxxxx, 3'bxxx, OpUImm    };
localparam logic [16:0] InstAUIPC = { 7'bxxxxxxx, 3'bxxx, OpUPc     };
localparam logic [16:0] InstADD   = { 7'b0000000, 3'b000, OpRInt    };
localparam logic [16:0] InstSLT   = { 7'b0000000, 3'b010, OpRInt    };
localparam logic [16:0] InstSLTU  = { 7'b0000000, 3'b011, OpRInt    };
localparam logic [16:0] InstAND   = { 7'b0000000, 3'b111, OpRInt    };
localparam logic [16:0] InstOR    = { 7'b0000000, 3'b110, OpRInt    };
localparam logic [16:0] InstXOR   = { 7'b0000000, 3'b100, OpRInt    };
localparam logic [16:0] InstSLL   = { 7'b0000000, 3'b001, OpRInt    };
localparam logic [16:0] InstSRL   = { 7'b0000000, 3'b101, OpRInt    };
localparam logic [16:0] InstSUB   = { 7'b0100000, 3'b000, OpRInt    };
localparam logic [16:0] InstSRA   = { 7'b0100000, 3'b101, OpRInt    };
localparam logic [16:0] InstJAL   = { 7'bxxxxxxx, 3'bxxx, OpUJump   };
localparam logic [16:0] InstJALR  = { 7'bxxxxxxx, 3'b000, OpIJump   };
localparam logic [16:0] InstBEQ   = { 7'bxxxxxxx, 3'b000, OpSBranch };
localparam logic [16:0] InstBNE   = { 7'bxxxxxxx, 3'b001, OpSBranch };
localparam logic [16:0] InstBLT   = { 7'bxxxxxxx, 3'b100, OpSBranch };
localparam logic [16:0] InstBLTU  = { 7'bxxxxxxx, 3'b110, OpSBranch };
localparam logic [16:0] InstBGE   = { 7'bxxxxxxx, 3'b101, OpSBranch };
localparam logic [16:0] InstBGEU  = { 7'bxxxxxxx, 3'b111, OpSBranch };

localparam logic [16:0] InstLB    = { 7'bxxxxxxx, 3'b000, OpILoad };
localparam logic [16:0] InstLH    = { 7'bxxxxxxx, 3'b001, OpILoad };
localparam logic [16:0] InstLW    = { 7'bxxxxxxx, 3'b010, OpILoad };
localparam logic [16:0] InstLBU   = { 7'bxxxxxxx, 3'b100, OpILoad };
localparam logic [16:0] InstLHU   = { 7'bxxxxxxx, 3'b101, OpILoad };
localparam logic [16:0] InstSB    = { 7'bxxxxxxx, 3'b000, OpSStore  };
localparam logic [16:0] InstSH    = { 7'bxxxxxxx, 3'b001, OpSStore   };
localparam logic [16:0] InstSW    = { 7'bxxxxxxx, 3'b010, OpStore   };


/* Program Counter Opcodes */
localparam bit [1:0]  PcIncr    = 2'b00;
localparam bit [1:0]  PcJump    = 2'b01;
localparam bit [1:0]  PcBranch  = 2'b10;
localparam bit [1:0]  PcRsvd    = 2'b11;


endpackage
