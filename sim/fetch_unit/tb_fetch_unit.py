# tb_fetch_unit.py

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
from enum import Enum


class pc_op(Enum):
  STOP = 0x01
  INCR = 0x02
  JAL = 0x04
  JALR = 0x08
  BRANCH = 0x10


@cocotb.test()
async def tb_fetch_unit(dut):
  cocotb.log.info(f"Starting {tb_fetch_unit.__name__}")
  cocotb.log.info("Parameters:")
  cocotb.log.info(f"\tXLEN:\t{dut.XLEN.value}")

  # Start Clock
  cocotb.start_soon(Clock(dut.clk, 10, "ns").start())

  # Initialize Values
  dut.rstn.value = 0
  dut.i_pc_op.value = pc_op['STOP'].value
  dut.i_id_immediate.value = 0
  dut.i_alu_res.value = 0
  dut.i_im_arready.value = 0

  await ClockCycles(dut.clk, 10)
  dut.rstn.value = 1

  # Increment Test
  await RisingEdge(dut.clk)
  dut.i_im_arready.value = 1
  dut.i_pc_op.value = pc_op['INCR'].value

  await RisingEdge(dut.clk)
  dut.i_im_arready.value = 0

  # JAL Test
  await RisingEdge(dut.clk)
  dut.i_pc_op.value = pc_op['JAL'].value
  dut.i_id_immediate.value = 0xAAAA
  dut.i_im_arready.value = 1

  await RisingEdge(dut.clk)
  dut.i_im_arready.value = 0

  # JALR Test
  await RisingEdge(dut.clk)
  dut.i_pc_op.value = pc_op['JALR'].value
  dut.i_id_immediate.value = 0
  dut.i_alu_res.value = 0x5555
  dut.i_im_arready.value = 1

  await RisingEdge(dut.clk)
  dut.i_im_arready.value = 0

  # Branch Test
  await RisingEdge(dut.clk)
  dut.i_pc_op.value = pc_op['BRANCH'].value
  dut.i_id_immediate.value = 0xFFFF
  dut.i_im_arready.value = 1

  await RisingEdge(dut.clk)
  dut.i_im_arready.value = 0

  await ClockCycles(dut.clk, 5)
