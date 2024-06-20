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
        - Full adder and register (FDCE)
        - Adder source multiplexers (A: immediate, previous address; B: 0, 4, alu result, immediate)
            - Source determined by opcode and branch taken input
    - Instruction Memory Address Interface
        - External facing handshake logic
        - Output Program Counter enable signal

Decode Unit
    - Instruction Memory Data Interface
        - External facing handshake logic
        - ready output from execute ready or data hazard hit
    - Immediate register Decoder
        - Decodes Immediate format from opcode type
    - Immediate wired output to fetch unit for branching
    - funct7, funct3, rs1 data, rs2 data, rd addr register
    - valid output registers
        - funct7, funct3, rs1 data, rs2 data, rd addr valid for R-Type
        - immediate, rs1 data, funct3, rd addr valid for I-Type
        - immediate, rs2 data, rs1 data, funct3 valid for S-Type and B-Type
        - immediate, rd addr valid data for U-Type and J-Type
    - register file
        - asynchronous ram-like design
        - dual port read
        - single port write
        - addr 0 writes blocked
        - register read before write data hazard bit
        - if rsx has data hazard bit set, raise data hazard hit bit until rd write enable for specific register
    - branch control (to minimize flushing)
        - rs1 and rs2 valid AND gate enabling rs1 and rs2 data arithmetic check (less than, greater than, equals)
        - check bit to fetch unit branch taken
    -

Store Unit
    - Receives opcode from decode unit to enable unit
    - 