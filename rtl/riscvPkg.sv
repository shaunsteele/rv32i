// riscvPkg.sv

`default_nettype none

package riscvPkg;

/* Opcode Types */
localparam bit [6:0] OpImmLoad  = 7'b0000011;
localparam bit [6:0] OpStore    = 7'b0100011;
localparam bit [6:0] OpBranch   = 7'b1100011;
localparam bit [6:0] OpRegReg   = 7'b0110011;
localparam bit [6:0] OpRegImm   = 7'b0010011;
localparam bit [6:0] OpJump     = 7'b1101111;
localparam bit [6:0] OpJumpImm  = 7'b1100111;


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


/* Funct3 Load Data Decode */
localparam bit [2:0] DataByte   = 3'b000;
localparam bit [2:0] DataHalf   = 3'b001;
localparam bit [2:0] DataWord   = 3'b010;
localparam bit [2:0] DataByteU  = 3'b100;
localparam bit [2:0] DataHalfU  = 3'b101;


/* Instruction Decode */
// Format: { funct7, funct3, opcode }
localparam logic [16:0] InstLB    = { 7'bxxxxxxx, DataByte,   OpImmLoad };
localparam logic [16:0] InstLH    = { 7'bxxxxxxx, DataHalf,   OpImmLoad };
localparam logic [16:0] InstLW    = { 7'bxxxxxxx, DataWord,   OpImmLoad };
localparam logic [16:0] InstLBU   = { 7'bxxxxxxx, DataByteU,  OpImmLoad };
localparam logic [16:0] InstLHU   = { 7'bxxxxxxx, DataHalfU,  OpImmLoad };
localparam logic [16:0] InstSB    = { 7'bxxxxxxx, DataByte,   OpStore   };
localparam logic [16:0] InstSH    = { 7'bxxxxxxx, DataHalf,   OpStore   };
localparam logic [16:0] InstSW    = { 7'bxxxxxxx, DataWord,   OpStore   };
localparam logic [16:0] InstADD   = { 7'b0000000, 3'b000,     OpRegReg  };
localparam logic [16:0] InstSUB   = { 7'b0100000, 3'b000,     OpRegReg  };
localparam logic [16:0] InstSLL   = { 7'b0000000, 3'b001,     OpRegReg  };
localparam logic [16:0] InstSLT   = { 7'b0000000, 3'b010,     OpRegReg  };
localparam logic [16:0] InstSLTU  = { 7'b0000000, 3'b011,     OpRegReg  };
localparam logic [16:0] InstXOR   = { 7'b0000000, 3'b100,     OpRegReg  };
localparam logic [16:0] InstSRL   = { 7'b0000000, 3'b101,     OpRegReg  };
localparam logic [16:0] InstSRA   = { 7'b0100000, 3'b101,     OpRegReg  };
localparam logic [16:0] InstOR    = { 7'b0000000, 3'b110,     OpRegReg  };
localparam logic [16:0] InstAND   = { 7'b0000000, 3'b111,     OpRegReg  };
localparam logic [16:0] InstADDI  = { 7'bxxxxxxx, 3'b000,     OpRegImm  };
localparam logic [16:0] InstSLTI  = { 7'bxxxxxxx, 3'b010,     OpRegImm  };
localparam logic [16:0] InstSLTIU = { 7'bxxxxxxx, 3'b011,     OpRegImm  };
localparam logic [16:0] InstXORI  = { 7'bxxxxxxx, 3'b100,     OpRegImm  };
localparam logic [16:0] InstORI   = { 7'bxxxxxxx, 3'b110,     OpRegImm  };
localparam logic [16:0] InstANDI  = { 7'bxxxxxxx, 3'b111,     OpRegImm  };
localparam logic [16:0] InstBEQ   = { 7'bxxxxxxx, 3'b000,     OpBranch  };
localparam logic [16:0] InstBNE   = { 7'bxxxxxxx, 3'b001,     OpBranch  };
localparam logic [16:0] InstBLT   = { 7'bxxxxxxx, 3'b100,     OpBranch  };
localparam logic [16:0] InstBGE   = { 7'bxxxxxxx, 3'b101,     OpBranch  };
localparam logic [16:0] InstBLTU  = { 7'bxxxxxxx, 3'b110,     OpBranch  };
localparam logic [16:0] InstBGEU  = { 7'bxxxxxxx, 3'b111,     OpBranch  };
localparam logic [16:0] InstJAL   = { 7'bxxxxxxx, 3'bxxx,     OpJump    };
localparam logic [16:0] InstJALR  = { 7'bxxxxxxx, 3'b000,     OpJumpImm };


endpackage
