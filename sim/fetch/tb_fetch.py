# tb_fetch.py

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb.binary import BinaryValue
from cocotb.log import logging
import numpy as np
import array as arr

from instruction_memory_driver import instruction_memory_driver
 

@cocotb.test()
async def tb_fetch(dut):
  dut.log.setLevel(logging.DEBUG)

  mem = arr.array('I', [0x0000_0000,
                        0x1111_1111,
                        0x2222_2222,
                        0x3333_3333,
                        0x4444_4444,
                        0x5555_5555,
                        0x6666_6666,
                        0x7777_7777,
                        0x8888_8888,
                        0x9999_9999,
                        0xAAAA_AAAA,
                        0xBBBB_BBBB,
                        0xCCCC_CCCC,
                        0xDDDD_DDDD,
                        0xEEEE_EEEE,
                        0xFFFF_FFFF]
                        )
  # print("Original Array")
  # print([print(hex(x)) for x in mem])
  # print("\nArray.tobytes()")
  # print([print(hex(x)) for x in mem.tobytes()])
  drv = instruction_memory_driver(dut, mem)

  dut.rstn.value = 0
  dut.i_dbg_state_ready.value = 1
  dut.i_dbg_imm_data.value = 0xFF
  dut.i_dbg_pc_incr_op.value = 0b00

  cocotb.start_soon(Clock(dut.clk, 10, "ns").start())

  await ClockCycles(dut.clk, 10)
  dut.rstn.value = 1

  await ClockCycles(dut.clk, 10)

