# tb_core.py

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from riscv_instructions import Instruction

@cocotb.test()
async def tb_core(dut):
  dut.rstn.value = 0
  nop = Instruction()
  nop.nop()
  dut.i_im_rdata.value = int(nop)
  dut.i_dm_rdata.value = 0

  cocotb.start_soon(Clock(dut.clk, 10, "ns").start())

  await ClockCycles(dut.clk, 10)

  rand_instr = Instruction()

  rand_instr.randomize()
  cocotb.log.info(f"Random Instruction: {rand_instr}")
  dut.i_im_rdata.value = int(rand_instr)

  await ClockCycles(dut.clk, 2)
