# tb_core.py

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
import riscv_instructions
from riscv_instructions import Instruction
from core_dbg_mon import CoreDbgMon

@cocotb.test()
async def tb_core(dut):
  dbg = CoreDbgMon(dut, dut.clk)

  # TODO: Opcode/Function Scoreboard - unpack function in riscv_instructions
  # TODO: Register File Scoreboard - register file model array
  # TODO: Program Counter Scoreboard - program counter model int
  # TODO: Memory Bus Scoreboard - memory model array



  dut.clk.value = 0
  dut.rstn.value = 0
  nop = Instruction()
  nop.nop()
  dut.i_im_rdata.value = int(nop)
  dut.i_dm_rdata.value = 0xDEAD_BEEF

  cocotb.start_soon(Clock(dut.clk, 10, "ns").start())

  await ClockCycles(dut.clk, 10)
  dut.rstn.value = 1
  dbg_run = cocotb.start_soon(dbg.run())

  rand_instr = Instruction()
  mon_instr = Instruction()

  for i in range(10000):
    rand_instr.randomize()
    cocotb.log.info(f"drv\t0x{(i << 2):08x}: {rand_instr}")
    # print(hex(int(rand_instr)))

    await FallingEdge(dut.clk)
    dut.i_im_rdata.value = int(rand_instr)

    await RisingEdge(dut.clk)
    cocotb.log.info(str(dbg))
    mon_instr.unpack(dbg.instr)
    cocotb.log.info(f"mon\t0x{(i << 2):08x}: {mon_instr}")
    cocotb.log.info("")
    assert rand_instr == mon_instr
    # dbg.instr_check(int(rand_instr))
    # dbg.op_funct_check(rand_instr)

  dbg_run.kill()
