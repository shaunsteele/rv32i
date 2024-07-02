# tb_instruction_decoder.py
# test cases:

import cocotb
from cocotb.triggers import Timer


opcodes = {
  IntReg = 0b1101
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
