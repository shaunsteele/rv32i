# tb_instruction_decoder.py
# test cases:

import cocotb
from cocotb.triggers import Timer


opcodes = {
  IntReg: 0b0110011,
  IntImm: 0b0010011,
  LUI:    0b0110111,
  AUIPC:  0b0010111,
  JAL:    0b1101111,
  JALR:   0b1100111,
  Branch: 0b1100011,
  Load:   0b0000011,
  Store:  0b0100011
}

alu_op = {
  ADD:  0x000,
  SUB:  0x100,
  SLL:  0x001,
  SLT:  0x002,
  SLTU: 0x003,
  XOR:  0x004,
  SRL:  0x005,
  SRA:  0x105,
  OR:   0x006,
  AND:  0x007
}

async def integer_test(dut):
  
  

@cocotb.test()
async def tb_control_transfer(dut):
  # initialize inputs
  dut.i_instruction.value = 0

  # start clock
  await Timer(10, "ns")

  # test cases

  await Timer(10, "ns")
  cocotb.log.info("Testing Completed")
