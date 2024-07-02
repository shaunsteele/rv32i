# tb_control_transfer.py
# test cases:
# - reset outputs test
# - increment test
# - branch tests
# - jump tests
# - up register checking
# - stall test

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge


async def reset_check(dut):
  await FallingEdge(dut.clk)
  assert dut.o_im_arvalid.value == 0
  assert dut.o_jump_ret.value == 4
  assert dut.o_up_pc.value == 0
  cocotb.log.info("Reset Test Passed")


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
  cocotb.log.info("Incrememnt Test Pass")


async def branch(dut, funct, src1, src2, imm):
  dut.i_funct3.value = funct
  dut.i_rf_rs1_rdata.value = src1
  dut.i_rf_rs2_rdata.value = src2
  dut.i_id_immediate.value = imm
  dut.i_br_en.value = 1

  # cocotb.log.info(
  #   f"function: {funct:#05b}\tsrc1: {src1:#010x} \
  #   \tsrc2: {src2:#010x}\timm: {imm:#010x}")

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

  # cocotb.log.info(f"last pc:\t{int(pc):#010x}")
  if (expected_take):
    pc = pc + imm
  else:
    pc = pc + 4

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  # cocotb.log.info(f"current pc:\t{int(pc):#010x}")
  assert dut.o_im_arvalid.value
  assert dut.o_im_araddr.value == pc, \
    f"{int(dut.o_im_araddr.value):#010x}\t{int(pc):#010x}"


async def branch_test(dut):
  # BrBEQ
  await branch(dut, 0, 0xFFFFFFFF, 0xFFFFFFFF, 0x100)
  await branch(dut, 0, 0xFFFFFFFF, 0, 0x100)

  # BrBNE
  await branch(dut, 1, 0xAAAAAAAA, 0x55555555, 0x100)
  await branch(dut, 1, 0xAAAAAAAA, 0xAAAAAAAA, 0x100)

  # BrBLT
  await branch(dut, 4, -1, 0, 0x100)
  await branch(dut, 4, 0, 0, 0x100)

  # BrBGE
  await branch(dut, 5, 0, -1, 0x100)
  await branch(dut, 5, -1, -2, 0x100)

  # BrBLTU
  await branch(dut, 6, -1, 0, 0x100)
  await branch(dut, 6, -1, -1, 0x100)

  # BrBGEU
  await branch(dut, 6, 0, -2, 0x100)
  await branch(dut, 6, -2, 0, 0x100)
  cocotb.log.info("Branch Test Pass")


async def jump_test(dut):
  assert (dut.o_im_arvalid.value)
  pc = dut.o_im_araddr.value
  imm = 0x00080000
  rs1 = 0x88888888

  # JAL
  dut.i_jump_en.value = 1
  dut.i_jump_reg_sel.value = 0
  dut.i_id_immediate.value = imm
  dut.i_rf_rs1_rdata.value = 0

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  expected_jump_ret = int(pc) + 4
  assert (dut.o_jump_ret.value == expected_jump_ret)
  pc = int(pc) + imm
  assert (dut.o_im_araddr == pc)

  dut.i_rf_rs1_rdata.value = rs1

  # JALR
  dut.i_jump_reg_sel.value = 1
  dut.i_rf_rs1_rdata.value = rs1

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  expected_jump_ret = int(pc) + 4
  assert (dut.o_jump_ret.value == expected_jump_ret)
  pc = rs1 + imm
  assert (dut.o_im_araddr == pc)

  dut.i_jump_en.value = 0
  dut.i_jump_reg_sel.value = 0

  cocotb.log.info("Jump Test Pass")


async def up_test(dut):
  assert (dut.o_im_arvalid.value)
  pc = dut.o_im_araddr.value

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  assert (dut.o_up_pc == pc)
  assert (dut.o_im_araddr.value == (int(pc) + 4))

  cocotb.log.info("Up Test Pass")


async def stall_test(dut):
  await RisingEdge(dut.clk)
  # bus stall
  dut.i_stall.value = 0
  dut.i_im_arready.value = 0
  assert (dut.o_im_arvalid)
  pc = dut.o_im_araddr.value

  for _ in range(5):
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert (dut.o_im_arvalid)
    assert (dut.o_im_araddr.value == pc)

  # control stall
  dut.i_stall.value = 1
  dut.i_im_arready.value = 0
  assert (dut.o_im_arvalid)

  for _ in range(5):
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert (dut.o_im_arvalid)
    assert (dut.o_im_araddr.value == pc), \
      f"{hex(int(dut.o_im_araddr.value))}\t{hex(int(pc))}"

  cocotb.log.info("Stall Test Pass")


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
  await jump_test(dut)
  await up_test(dut)
  await stall_test(dut)

  await ClockCycles(dut.clk, 10)
  cocotb.log.info("Testing Completed")
