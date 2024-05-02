RV32I Core Development

Iterative Design and Testbench Steps:
  1.  Fetch - FetchUnit, ExecuteUnit(PC), ControlUnit passing Criteria
      1.  FetchUnit successfully accepts address and returns instruction in FETCH state
      2.  ExecuteUnit successfully increment and loads PC in EXECUTE state
      3.  ControlUnit successfully flows through states
  2.  Execute
      1. InstructionDecoder correctly decodes incoming instruction
      2. ControlUnit/InstructionExecute decodes correct control signals from opcode/funct


Control Unit
    - Fetch Stage
        - Instruction Bus Read
        - Program Counter with 1 cycle latency
    - Decode Stage
        - Instruction Decoder Register Bank
        - Reads data from Register File
    - Execute Stage
        - Integer Unit and Register
        - Load Store Unit
            - Data Bus Read and Write
    - Write Back Stage
        - Mux data into Register File

Fetch Unit
    - Program Counter
        - Calculates next instruction address in 1 clock cycle
    - Fetch Controller
        - Executes a read from instruction memory in 1 clock cycle

Decode Unit
    - Receives data from im read data channel
    - decodes and stores data in register
    - takes backpressure from execute unit
    - Instruction Bus Read Data Channel
        - Reads if Unit is ready and data is valid
    - Instruction Decode
        - Combinational decoder
    - Decoded Register Bank
        - Stores decoded data from Instruction Bus control
    - Register File
        - Decoded rs addrs

Store Unit
    - Receives opcode from decode unit to enable unit
    - 