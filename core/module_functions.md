RV32I Core Modules and their functions

core.sv
- hierarchical top module for rv32i core
- axi instruction memory bus and data memory bus interfaces
- connects all submodules together

control_transfer.sv
- decoded funct3 rs1_rdata rs2_rdata and id_immedate from decode_registers module. Combinatorial signals from instruction memory bus read
- program counter stall from data memory bus stall
- decoded control signals for branch and jump for controlling program counter
- outputs registered pc + 4 for jump instructions
- outputs registered pc for auipc instruction
- instruction memory read address bus channel

decode_registers.sv
- hierarchical module containing instruction_decode and register_file
- instruction memory read data bus channel
- outputs combinatorial funct3 rs1_rdata, rs2_rdata, immediate data and branch and jump control signals from instruction_decode to control transfer
- outputs registered integer alu enable, funct7, funct3 from instruction_decode and rs1_rdata and rs2_rdata from register_file
- inputs current program counter for auipc instruction
- registered immediate, current pc and control for upper instruction handling
- registered base(rs1_rdata), offset(immediate), width(funct3) to load store unit
- load and store stall inputs for data memory bus stalls
- load and store control outputs
- registered store source(rs2_rdata)
- write back jump control to pipelining registers
- write back write address to pipelineing registers
- write back address and data input

instruction_decoder.sv
- instruction execute control signals
- instruction format values

register_file.sv
- read register interfaces
- read before write hazard detection
- write interface

integer_alu.sv
- enable and function control input
- 2 data source input signals
- register stall
- alu result register

load_store.sv
- data memory bus read and write stall input
- load instruction data register to write back unit
- store control and source data input
- data write address and data channels

upper.sv
- lui and auipc control inoput
- immediate for lui instruction
- pc data and control for auipc instruction
- data output register to write back

write_back.sv
- decode_register control signal registers
- write back address pipeline register input
- data memory bus read stall
- execution unit data registers - integer(1 reg), load(2+ reg), upper(1 reg), jump(0 reg)
- register file write data interface