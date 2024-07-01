# tb_control_transfer.py
# test cases:
# - reset outputs test
# - increment test
# - branch tests
# - jump tests
# - up register checking

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
import random


async def reset_check(dut):
  await FallingEdge(dut.clk)
  assert dut.o_im_arvalid.value == 0
  assert dut.o_jump_ret.value == 4
  assert dut.o_up_pc.value == 0


async def increment_test(dut):
  dut.i_stall.value = 0
  dut.i_im_arready.value = 1
  dut.i_jump_en.value = 0
  dut.i_br_en.value = 0
  dut.i_jump_en.value = 0

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  assert dut.o_im_arvalid.value
  assert dut.o_im_araddr.value == 0

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  assert dut.o_im_arvalid.value == 1
  assert dut.o_im_araddr.value == 4


async def branch(dut, funct, src1, src2, imm):
  dut.i_funct3.value = funct
  dut.i_rf_rs1_rdata.value = src1
  dut.i_rf_rs2_rdata.value = src2
  dut.i_id_immediate.value = imm
  dut.i_br_en.value = 1
  assert (dut.o_im_arvalid.value == 1)
  pc = dut.o_im_araddr.value

  if (funct == 0):    # BrBEQ
    expected_take = src1 == src2

  elif (funct == 1):  # BrBNE
    expected_take = src1 != src2

  elif (funct == 4):  # BrBLT
    expected_take = src1 < src2

  elif (funct == 5):  # BrBGE
    expected_take = src1 >= src2

  elif (funct & 0x6):
    # convert sources to unsigned if negative
    if (src1 < 0):
      src1u = src1 + 2**32
    else:
      src1u = src1

    if (src2 < 0):
      src2u = src2 + 2**32
    else:
      src2u = src2

    if (funct == 6):    # BrBLTU
      expected_take = src1u < src2u
    elif (funct == 7):  # BrBGEU
      expected_take = src1u >= src2u

  if (expected_take):
    pc += imm
  else:
    pc += 4

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  assert dut.o_im_arvalid.value
  assert dut.o_im_araddr.value == pc


async def branch_test(dut):
  # BrBEQ
  await branch(dut, 0, 0xFFFFFFFF, 0xFFFFFFFF, 100)
  await branch(dut, 0, 0xFFFFFFFF, 0, 100)
  
  # BrBNE
  await branch(dut, 1, 0xAAAAAAAA, 0x55555555, 100)
  await branch(dut, 1, 0xAAAAAAAA, 0xAAAAAAAA, 100)
  
  # BrBLT
  await branch(dut, 4, random.randint(-(2**32), -1), random.randint(0, 2), 100)
  await branch(dut, 4, random.randint(0, 2), random.randint(-(2**32), -1), 100)

  # BrBGE
  await branch(dut, 5, random.randint(0, 2), random.randint(-(2**32), -1), 100)
  await branch(dut, 5, random.randint(-(2**32), -1), random.randint(0, 2), 100)

  # BrBLTU
  await branch(dut, 6, random.randint(0, 2**31), 0x80000000, 100)
  await branch(dut, 6, 0x80000000, random.randint(0, 2**31), 100)

  # BrBGEU
  await branch(dut, 6, 0x80000000, random.randint(0, 2**31), 100)
  await branch(dut, 6, random.randint(0, 2**31), 0x80000000, 100)


@cocotb.test()
async def tb_control_transfer(dut):
  # initialize inputs
  dut.rstn.value = 0
  dut.i_funct3.value = 0
  dut.i_rf_rs1_rdata.value = 0
  dut.i_rf_rs2_rdata.value = 0
  dut.i_id_immediate.value = 0
  dut.i_stall.value = 0
  dut.i_br_en.value = 0
  dut.i_jump_en.value = 0
  dut.i_jump_reg_sel.value = 0
  dut.i_im_arready.value = 0

  # start clock
  cocotb.start_soon(Clock(dut.clk, 10, "ns").start())

  # reset raise
  await ClockCycles(dut.clk, 10)
  dut.rstn.value = 1

  # test cases
  await reset_check(dut)
  await increment_test(dut)
  await branch_test(dut)

  await ClockCycles(dut.clk, 10)
  cocotb.log.info("Testing Completed")
