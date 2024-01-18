RV32I Core Development

Iterative Design and Testbench Steps:
  1.  Fetch - FetchUnit, ExecuteUnit(PC), ControlUnit passing Criteria
      1.  FetchUnit successfully accepts address and returns instruction in FETCH state
      2.  ExecuteUnit successfully increment and loads PC in EXECUTE state
      3.  ControlUnit successfully flows through states
  2.  Execute
      1. InstructionDecoder correctly decodes incoming instruction
      2. ControlUnit/InstructionExecute decodes correct control signals from opcode/funct