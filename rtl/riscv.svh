// riscv.svh
`ifndef __RISCV
`define __RISCV


/* PC Opcodes */
localparam bit [2:0] PcStop   = 3'b000;
localparam bit [2:0] PcIncr   = 3'b001;
localparam bit [2:0] PcJAL    = 3'b010;
localparam bit [2:0] pcJALR   = 3'b011;
localparam bit [2:0] PcBranch = 3'b100;
localparam bit [2:0] PcRSvd   = 3'b101;


/* Instruction Opcode Types */
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


/* Instruction Decode */
// Format: { funct7, funct3, opcode }
localparam logic [16:0] InstADDI  = { 7'b???????, 3'b000, OpIInt    };
localparam logic [16:0] InstSLTI  = { 7'b???????, 3'b010, OpIInt    };
localparam logic [16:0] InstSLTIU = { 7'b???????, 3'b011, OpIInt    };
localparam logic [16:0] InstXORI  = { 7'b???????, 3'b100, OpIInt    };
localparam logic [16:0] InstORI   = { 7'b???????, 3'b110, OpIInt    };
localparam logic [16:0] InstANDI  = { 7'b???????, 3'b111, OpIInt    };
localparam logic [16:0] InstSLLI  = { 7'b0000000, 3'b001, OpIInt    };
localparam logic [16:0] InstSRLI  = { 7'b0000000, 3'b101, OpIInt    };
localparam logic [16:0] InstSRAI  = { 7'b0100000, 3'b101, OpIInt    };
localparam logic [16:0] InstLUI   = { 7'b???????, 3'b???, OpUImm    };
localparam logic [16:0] InstAUIPC = { 7'b???????, 3'b???, OpUPc     };
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
localparam logic [16:0] InstJAL   = { 7'b???????, 3'b???, OpUJump   };
localparam logic [16:0] InstJALR  = { 7'b???????, 3'b000, OpIJump   };
localparam logic [16:0] InstBEQ   = { 7'b???????, 3'b000, OpSBranch };
localparam logic [16:0] InstBNE   = { 7'b???????, 3'b001, OpSBranch };
localparam logic [16:0] InstBLT   = { 7'b???????, 3'b100, OpSBranch };
localparam logic [16:0] InstBLTU  = { 7'b???????, 3'b110, OpSBranch };
localparam logic [16:0] InstBGE   = { 7'b???????, 3'b101, OpSBranch };
localparam logic [16:0] InstBGEU  = { 7'b???????, 3'b111, OpSBranch };
localparam logic [16:0] InstLB    = { 7'b???????, 3'b000, OpILoad   };
localparam logic [16:0] InstLH    = { 7'b???????, 3'b001, OpILoad   };
localparam logic [16:0] InstLW    = { 7'b???????, 3'b010, OpILoad   };
localparam logic [16:0] InstLBU   = { 7'b???????, 3'b100, OpILoad   };
localparam logic [16:0] InstLHU   = { 7'b???????, 3'b101, OpILoad   };
localparam logic [16:0] InstSB    = { 7'b???????, 3'b000, OpSStore  };
localparam logic [16:0] InstSH    = { 7'b???????, 3'b001, OpSStore  };
localparam logic [16:0] InstSW    = { 7'b???????, 3'b010, OpSStore  };


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


/* Memory Opcodes */
localparam bit [2:0]  MemW  = 3'b000;
localparam bit [2:0]  MemH  = 3'b001;
localparam bit [2:0]  MemHU = 3'b010;
localparam bit [2:0]  MemB  = 3'b011;
localparam bit [2:0]  MemBU = 3'b100;


/* Write-back Opcodes */
localparam bit [2:0]  WbAlu   = 3'b000;
localparam bit [2:0]  WbImm   = 3'b001;
localparam bit [2:0]  WbPcImm = 3'b010;
localparam bit [2:0]  WbPcRet = 3'b011;
localparam bit [2:0]  WbDm    = 3'b100;


`endif
