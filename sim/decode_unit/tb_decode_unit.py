# tb_decode_unit.py

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from enum import Enum
import random


class Opcode(Enum):
  I_INT = 0x13
  U_IMM = 0x37
  U_PC = 0x17
  R_INT = 0x33
  U_JMP = 0x6F
  I_JMP = 0x67
  S_BRN = 0x63
  I_LD = 0x03
  S_ST = 0x23


r_funct7 = [0, 0x20]
r_s_brn = [0b000, 0b001, 0b100, 0b101, 0b110, 0b111]


class Instruction:
  def __init__(self, op=None, rd=None, rs1=None, rs2=None,
               funct7=None, funct3=None, imm=None, instr=None):
    self.op = op
    self.rd = rd
    self.rs1 = rs1
    self.rs2 = rs2
    self.funct7 = funct7
    self.funct3 = funct3
    self.instr = instr

  def rand(self):
    self.op = random.choice(list(Opcode))
    self.rd = None
    self.rs1 = None
    self.rs2 = None
    self.funct7 = None
    self.imm = None

    instr = self.op.value

    if (self.op.name == "R_INT"):
      self.rd = random.randint(0, 0x1F)
      instr |= self.rd << 7

      self.funct3 = random.randint(0, 0b111)
      instr |= self.funct3 << 12

      self.rs1 = random.randint(0, 0x1F)
      instr |= self.rs1 << 15

      self.rs2 = random.randint(0, 0x1F)
      instr |= self.rs2 << 20

      self.funct7 = random.choice(r_funct7)
      instr |= self.funct7 << 25
      cocotb.log.info(f"{self.op.name}\t0x{self.op.value:01x}\tf7: 0x{self.funct7:02x}\tf3: 0b{self.funct3:03b}\
        \t\t\tr2: 0x{self.rs2:02x}\tr1: 0x{self.rs1:02x}\trd: 0x{self.rd:02x}")

    elif (self.op.name == "I_INT" or self.op.name == "I_JMP" or self.op.name == "I_LD"):
      self.rd = random.randint(0, 0x1F)
      instr |= self.rd << 7

      if (self.op.name == "I_LD"):
        self.funct3 = random.randint(0, 0b101)
      elif (self.op.name == "I_INT"):
        self.funct3 = random.randint(0, 0b111)
      else:
        self.funct3 = 0
      instr |= self.funct3 << 12

      self.rs1 = random.randint(0, 0x1F)
      instr |= self.rs1 << 15

      self.imm = random.randint(0, 0xFFF)
      instr |= self.imm << 20
      cocotb.log.info(f"{self.op.name}\t0x{self.op.value:02x}\t\t\tf3: 0b{self.funct3:03b}\
        \timm: 0x  {self.imm:03x}\t\t\tr1: 0x{self.rs1:02x}")

    elif (self.op.name == "S_ST"):
      self.imm = random.randint(0, 0xFFF)
      instr |= (self.imm & 0x1F) << 7

      self.funct3 = random.randint(0, 0b10)
      instr |= self.funct3 << 12

      self.rs1 = random.randint(0, 0x1F)
      instr |= self.rs1 << 15

      self.rs2 = random.randint(0, 0x1F)
      instr |= self.rs2 << 20

      instr |= ((self.imm & 0xFE0) >> 5) << 25
      cocotb.log.info(f"{self.op.name}\t\
      0x{self.op.value:01x}\t\t\tf3: 0b{self.funct3:03b}\
        \timm: 0x  {self.imm:03x}\tr2: {self.rs2:02x}\tr1: 0x{self.rs1:02x}")

    elif (self.op.name == "S_BRN"):
      self.imm = random.randint(0b10, 0x1FF)
      instr |= ((self.imm & 0x0800) >> 11) << 7
      instr |= ((self.imm & 0x001E) >> 1) << 8

      self.funct3 = random.choice(r_s_brn)
      instr |= self.funct3 << 12

      self.rs1 = random.randint(0, 0x1F)
      instr |= self.rs1 << 15

      self.rs2 = random.randint(0, 0x1F)
      instr |= self.rs2 << 20

      instr |= ((self.imm & 0x07C0) >> 5) << 25
      instr |= ((self.imm & 0x1000) >> 12) << 31
      cocotb.log.info(f"{self.op.name}\t\0x{self.op.value:01x}\t\t\tf3: 0b{self.funct3:03b}\
        \timm: 0x {self.imm:04x}\t\t\tr1: 0x{self.rs1:02x}")

    elif (self.op.name == "U_IMM" or self.op.name == "U_PC"):
      self.rd = random.randint(0, 0x1F)
      instr |= self.rd << 7

      self.imm = random.randint(0, 0xF_FFF)
      instr |= self.imm << 12
      cocotb.log.info(f"{self.op.name}\t0x{self.op.value:01x}\t\t\t\t\
        \timm: 0x{self.imm:05x}\t\t\t\t\trd: 0x{self.rd:02x}")

    elif (self.op.name == "U_JMP"):
      self.rd = random.randint(0, 0x1F)
      instr |= self.rd << 7

      self.imm = random.randint(0b10, 0x1F_FFF)
      instr |= ((self.imm & 0x0FF000) >> 12) << 12
      instr |= ((self.imm & 0x000800) >> 11) << 20
      instr |= ((self.imm & 0x0003FE) >> 1) << 21
      instr |= ((self.imm & 0x100000) >> 20) << 31
      cocotb.log.info(f"{self.op.name}\t0x{self.op.value:01x}\t\t\t\t\
        \timm: 0x{self.imm:05x}\t\t\t\t\trd: 0x{self.rd:02x}")

    return instr


@cocotb.test()
async def tb_decode_unit(dut):
  cocotb.log.info(f"Starting {tb_decode_unit.__name__}")
  cocotb.log.info("Parameters:")
  cocotb.log.info(f"\tXLEN:\t{dut.XLEN.value}")

  # Start Clock
  cocotb.start_soon(Clock(dut.clk, 10, "ns").start())

  # Initialize Values
  dut.rstn.value = 0
  dut.i_im_rvalid.value = 0
  dut.i_im_rdata.value = 0
  dut.i_ex_ready.value = 0
  dut.i_rf_rd_wvalid.value = 0
  dut.i_rf_rd_wdata.value = 0

  await ClockCycles(dut.clk, 10)
  dut.rstn.value = 1

  await RisingEdge(dut.clk)
  dut.i_ex_ready.value = 1

  for _ in range(30):
    await RisingEdge(dut.clk)
    dut.i_im_rvalid.value = 1
    a = Instruction()
    dut.i_im_rdata.value = a.rand()

  dut.i_ex_ready.value = 0

  await RisingEdge(dut.clk)
  dut.i_ex_ready.value = 1

  await ClockCycles(dut.clk, 5)
