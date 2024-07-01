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

Execute Unit
    - receives a specific enable signal
    - register enable signals
    - check for valid data from specific enable signal
        - if alu, register write back valid
        - if load valid, raise mem busy flag
        - 
    - choose which unit to write back data from

    - data memory writes immediately, reads in 1 clock

    - ALU Enable -> ALU Result Valid -> write back rd valid
    - Store Enable -> Data Memory Writes Valid
    - Load Enable -> DM raddr Valid -> DM rdata valid -> write back rd valid

write back shift register for pipeline
l
s


    TODO:
        -write back data selection timing
        - branch/jump write back logic


Fetch   Decode  Execute Memory  Writeback
store
pc+4

branch  store
pc+4

add     branch
pc+imm  take

branch
pc+


        |*| |
        | | |
        | | |
        | | |
        |*| |
        
steps
- reset program counter to specific address
- fetch
    - sends read address to instruction memory bus
    - forwards read address to decode
    - increments program counter
        - inputs combos
            - current count + 4
            - current count + signed immediate offset (take branch) priority!
            - current count + signed immediate offset (jump)
            priority!
        - adder
- decode
    - receives instruction from im bus
    - instruction type determined from opcode
    - instruction type determines intermediate encoding
    - register file outputs determined from rs1 and rs2 encodings
        - register bank
        - hazard check register tag
            - rd waddr from encoding sets
            - rd waddr from write back resets
        - immediate, alu result, dm read data
    - opcode determines which execute unit to enable
    - function, rs1 rdata, rs2 rdata, rd waddr, immediate, opcode registered
    - rs1 and rs2 compared for branch
- write back
    - rd waddr from forward register
    - rd wvalid disable take branch 2 cycle pulse
    - rd wdata inputs selected from forwarded opcode type
        - load result
        - alu result forward
        - immediate forward
- 


- Control Transfer
    - IM Read Addr Channel
        - addr register
        - valid reset from decode hazard detection
    - Branch
        - Compare rs1 and rs2 data
        - addr register is PC + immediate if branch take
        - funct3 determines comparison type
    - Jumps
        - JAL
            - addr reg is PC + immediate
        - JALR
            - addr reg is rs1 data + immediate
            - funct3 == 0
        - PC + 4 to rd forward registers
    - interrupt (future)
        - addr reg is interrupt address
        - interrupt return register is PC + 4
    - I/O
        - im_ar(valid, ready, addr, prot==3'b100 (unprivileged secure instruction access))

- Write Back
    - Load - 0 forwarding registers
        - 1 forwarding enable register
    - Integer - 1 forwarding register with pause
        - Reg-Reg
        - Reg-Imm
        - AUIPC
        - LUI
    - Jumps - 1 forwarding register with pause
