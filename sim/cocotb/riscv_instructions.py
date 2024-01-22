# riscv_instructions.py

import cocotb
import random


I_INT     = 0b0010011
U_IMM     = 0b0110111
U_PC      = 0b0010111
R_INT     = 0b0110011
U_JUMP    = 0b1101111
I_JUMP    = 0b1100111
S_BRANCH  = 0b1100011
I_LOAD    = 0b0000011
S_STORE   = 0b0100011


instr_dict = {
      "ADDI":   {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0010011, 'imm_len': 12},
      "SLTI":   {'funct7': 0b0000000, 'funct3': 0b010, 'opcode': 0b0010011, 'imm_len': 12},
      "SLTIU":  {'funct7': 0b0000000, 'funct3': 0b011, 'opcode': 0b0010011, 'imm_len': 12},
      "XORI":   {'funct7': 0b0000000, 'funct3': 0b100, 'opcode': 0b0010011, 'imm_len': 12},
      "ORI":    {'funct7': 0b0000000, 'funct3': 0b110, 'opcode': 0b0010011, 'imm_len': 12},
      "ANDI":   {'funct7': 0b0000000, 'funct3': 0b111, 'opcode': 0b0010011, 'imm_len': 12},
      "SLLI":   {'funct7': 0b0000000, 'funct3': 0b001, 'opcode': 0b0010011, 'imm_len': 5},
      "SRLI":   {'funct7': 0b0000000, 'funct3': 0b101, 'opcode': 0b0010011, 'imm_len': 5},
      "SRAI":   {'funct7': 0b0100000, 'funct3': 0b101, 'opcode': 0b0010011, 'imm_len': 5},
      "LUI":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0110111, 'imm_len': 20},
      "AUIPC":  {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0010111, 'imm_len': 20},
      "ADD":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0110011, 'imm_len': 0},
      "SLT":    {'funct7': 0b0000000, 'funct3': 0b010, 'opcode': 0b0110011, 'imm_len': 0},
      "SLTU":   {'funct7': 0b0000000, 'funct3': 0b011, 'opcode': 0b0110011, 'imm_len': 0},
      "AND":    {'funct7': 0b0000000, 'funct3': 0b100, 'opcode': 0b0110011, 'imm_len': 0},
      "OR":     {'funct7': 0b0000000, 'funct3': 0b110, 'opcode': 0b0110011, 'imm_len': 0},
      "XOR":    {'funct7': 0b0000000, 'funct3': 0b100, 'opcode': 0b0110011, 'imm_len': 0},
      "SLL":    {'funct7': 0b0000000, 'funct3': 0b001, 'opcode': 0b0110011, 'imm_len': 0},
      "SRL":    {'funct7': 0b0000000, 'funct3': 0b101, 'opcode': 0b0110011, 'imm_len': 0},
      "SUB":    {'funct7': 0b0100000, 'funct3': 0b000, 'opcode': 0b0110011, 'imm_len': 0},
      "SRA":    {'funct7': 0b0100000, 'funct3': 0b101, 'opcode': 0b0110011, 'imm_len': 0},
      "JAL":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1101111, 'imm_len': 19},
      "JALR":   {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1100111, 'imm_len': 12},
      "BEQ":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1100011, 'imm_len': 12},
      "BNE":    {'funct7': 0b0000000, 'funct3': 0b001, 'opcode': 0b1100011, 'imm_len': 12},
      "BLT":    {'funct7': 0b0000000, 'funct3': 0b100, 'opcode': 0b1100011, 'imm_len': 12},
      "BLTU":   {'funct7': 0b0000000, 'funct3': 0b110, 'opcode': 0b1100011, 'imm_len': 12},
      "BGE":    {'funct7': 0b0000000, 'funct3': 0b101, 'opcode': 0b1100011, 'imm_len': 12},
      "BGEU":   {'funct7': 0b0000000, 'funct3': 0b111, 'opcode': 0b1100011, 'imm_len': 12},
      "LW":     {'funct7': 0b0000000, 'funct3': 0b010, 'opcode': 0b0000011, 'imm_len': 12},
      "LH":     {'funct7': 0b0000000, 'funct3': 0b001, 'opcode': 0b0000011, 'imm_len': 12},
      "LHU":    {'funct7': 0b0000000, 'funct3': 0b101, 'opcode': 0b0000011, 'imm_len': 12},
      "LB":     {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0000011, 'imm_len': 12},
      "LBU":    {'funct7': 0b0000000, 'funct3': 0b100, 'opcode': 0b0000011, 'imm_len': 12},
      "SW":     {'funct7': 0b0000000, 'funct3': 0b010, 'opcode': 0b0100011, 'imm_len': 12},
      "SH":     {'funct7': 0b0000000, 'funct3': 0b001, 'opcode': 0b0100011, 'imm_len': 12},
      "SB":     {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0100011, 'imm_len': 12}
}

def bitmask(ct):
  if ct == 0:
    return 0

  out = 0 
  for i in range(ct):
    out |= 2**i
  
  return out


class Instruction:
  def __init__(self):
    self.instruction = 0
    self.opcode = 0
    self.funct7 = 0
    self.funct3 = 0
    self.imm = 0
    self.rs2 = 0
    self.rs1 = 0
    self.rd = 0
  
  def __int__(self):
    ret = self.opcode
    if self.opcode == R_INT:
      # cocotb.log.info(f"Packing R_INT")
      ret |= self.rd << 7
      ret |= self.funct3 << 12
      ret |= self.rs1 << 15
      ret |= self.rs2 << 20
      ret |= self.funct7 << 25
      return ret

    elif self.opcode == I_INT or self.opcode == I_JUMP or self.opcode == I_LOAD:
      # cocotb.log.info("Packing I_TYPE")
      ret |= self.rd << 7
      ret |= self.funct3 << 12
      ret |= self.rs1 << 15
      ret |= (self.imm & 0xFFF) << 20
      if self.instruction == instr_dict['SLLI'] or \
        self.instruction == instr_dict['SRLI'] or \
        self.instruction == instr_dict['SRAI']:
        ret |= self.funct7 << 25
      return ret

    elif self.opcode == S_STORE:
      # cocotb.log.info("Packing S_TYPE")
      ret |= (self.imm & 0x1F) << 7
      ret |= self.funct3 << 12
      ret |= self.rs1 << 15
      ret |= self.rs2 << 20
      ret |= (self.imm & 0xFE0) << 20 # 25-5
      return ret
    
    elif self.opcode == S_BRANCH:
      ret |= ((self.imm & 0x800) >> 11) << 7
      ret |= ((self.imm & 0x1E) >> 1) << 8
      ret |= self.funct3 << 12
      ret |= self.rs1 << 15
      ret |= self.rs2 << 20
      ret |= ((self.imm & 0x7E0) >> 5) << 25
      ret |= ((self.imm & 0x1000) >> 12) << 31
      return ret

    elif self.opcode == U_JUMP:
      ret |= self.rd << 7
      ret |= ((self.imm & 0xF_F000) >> 12) << 12
      ret |= ((self.imm & 0x800) >> 11) << 20
      ret |= ((self.imm & 0x7FE) >> 1) << 21
      ret |= ((self.imm & 0x10_0000) >> 20) << 31
      return ret
     
    elif self.opcode == U_IMM or self.opcode == U_PC:
      # cocotb.log.info("Packing U_TYPE")
      ret |= self.rd << 7
      ret |= self.imm
      return ret
 
  def __str__(self):
    s = list(instr_dict.keys())[list(instr_dict.values()).index(self.instruction)]
    s += f"  \tfunct7: 0b{self.instruction['funct7']:07b}"
    s += f"\tfunct3: 0b{self.instruction['funct3']:03b}"
    s += f"\topcode: 0b{self.instruction['opcode']:07b}"
    # s += f"\t{str(self.instruction)}"
    s += f"\timm: 0x{self.imm:08x}"
    s += f"\trs2: 0x{self.rs2:02x}"
    s += f"\trs1: 0x{self.rs1:02x}"
    s += f"\trd: 0x{self.rd:02x}"
    return s

  def __eq__(self, rhs):
    assert self.opcode == rhs.opcode

    if (self.opcode == R_INT):
      assert self.rd      == rhs.rd
      assert self.funct3  == rhs.funct3
      assert self.rs1     == rhs.rs1
      assert self.rs2     == rhs.rs2
      assert self.funct7  == rhs.funct7
    
    elif (self.opcode == I_INT or self.opcode == I_JUMP or self.opcode == I_LOAD):
      assert self.rd      == rhs.rd
      assert self.funct3  == rhs.funct3
      assert self.rs1     == rhs.rs1
      assert self.imm     == rhs.imm
      if (self.opcode == I_INT and (self.funct3 == 0b001 or self.funct3 == 0b101)):
        assert self.funct7  == rhs.funct7
  
    elif (self.opcode == S_BRANCH or self.opcode == S_STORE):
      assert self.funct3  == rhs.funct3
      assert self.rs1     == rhs.rs1
      assert self.rs2     == rhs.rs2
      assert self.imm     == rhs.imm
    
    elif (self.opcode == U_IMM or self.opcode == U_JUMP or self.opcode == U_PC):
      assert self.rd      == rhs.rd, f"{hex(self.rd)} {hex(rhs.rd)}"
      assert self.imm     == rhs.imm, f"{hex(self.imm)} {hex(rhs.rd)}"
    
    return True

  def unpack(self, instr):
    self.nop()
    self.opcode = instr & 0x7F
    if (self.opcode == R_INT):
      self.rd     = (instr >> 7) & 0x1F
      self.funct3 = (instr >> 12) & 0x7
      self.rs1    = (instr >> 15) & 0x1F
      self.rs2    = (instr >> 20) & 0x1F
      self.funct7 = (instr >> 25) & 0x7F
      self.instruction = {'funct7': self.funct7, 'funct3': self.funct3, 'opcode': self.opcode, 'imm_len': 0}
    
    elif (self.opcode == I_INT or self.opcode == I_JUMP or self.opcode == I_LOAD):
      self.rd     = (instr >> 7) & 0x1F
      self.funct3 = (instr >> 12) & 0x7
      self.rs1    = (instr >> 15) & 0x1F
      if (self.opcode == I_INT and (self.funct3 == 0b001 or self.funct3 == 0b101)):
        self.imm    = (instr >> 20) & 0x1F
        self.funct7 = (instr >> 25) & 0x7F
        self.instruction = {'funct7': self.funct7, 'funct3': self.funct3, 'opcode': self.opcode, 'imm_len': 5}
      else:
        self.imm    = (instr >> 20) & 0xFFF
        if (self.imm & 0x800):
          self.imm |= 0xFFFF_F000
        self.instruction = {'funct7': self.funct7, 'funct3': self.funct3, 'opcode': self.opcode, 'imm_len': 12}
     
    elif (self.opcode == S_BRANCH):
      self.funct3 = (instr >> 12) & 0x7
      self.rs1    = (instr >> 15) & 0x1F
      self.rs2    = (instr >> 20) & 0x1F
      self.imm    |= ((instr >> 7) & 0x1) << 11
      self.imm    |= ((instr >> 8) & 0xF) << 1
      self.imm    |= ((instr >> 25) & 0x3F) << 5
      self.imm    |= ((instr >> 31) & 0x1) << 12
      if (self.imm & 0x1000):
        self.imm |= 0xFFFF_E000
      self.instruction = {'funct7': self.funct7, 'funct3': self.funct3, 'opcode': self.opcode, 'imm_len': 12}

    elif (self.opcode == S_STORE):
      self.funct3 = (instr >> 12) & 0x7
      self.rs1    = (instr >> 15) & 0x1F
      self.rs2    = (instr >> 20) & 0x1F
      self.imm    |= (instr >> 7) & 0x1F
      self.imm    |= ((instr >> 25) & 0x7F) << 5
      if self.imm & 0x800:
        self.imm |= 0xFFFF_F000
      self.instruction = {'funct7': self.funct7, 'funct3': self.funct3, 'opcode': self.opcode, 'imm_len': 12}
    
    elif (self.opcode == U_IMM or self.opcode == U_PC):
      self.rd   = (instr >> 7) & 0x1F
      self.imm  = instr & 0xFFFF_F000
      self.instruction = {'funct7': self.funct7, 'funct3': self.funct3, 'opcode': self.opcode, 'imm_len': 20}
    
    elif (self.opcode == U_JUMP):
      self.rd   = (instr >> 7) & 0x1F
      self.imm  |= instr & 0xFF000
      self.imm  |= ((instr >> 20) & 0x1) << 11
      self.imm  |= ((instr >> 21) & 0x3FF) << 1
      self.imm  |= ((instr >> 31) & 0x1) << 20
      # if (self.imm & 0x)
      self.instruction = {'funct7': self.funct7, 'funct3': self.funct3, 'opcode': self.opcode, 'imm_len': 19}
    cocotb.log.info(f"Unpacked\t\t\tfunct7: 0b{int(self.funct7):07b}\tfunct3: 0b{int(self.funct3):03b}\topcode: 0b{int(self.opcode):07b}\timm: 0x{int(self.imm):08x}\trs2: 0x{int(self.rs2):02x}\trs1: 0x{int(self.rs1):02x}\trd: 0x{int(self.rd):02x}")
     
  def nop(self):
    self.instruction = instr_dict['ADDI']
    self.opcode = instr_dict['ADDI']['opcode']
    self.funct7 = instr_dict['ADDI']['funct7']
    self.funct3 = instr_dict['ADDI']['funct3']
    self.imm = 0
    self.rs2 = 0
    self.rs1 = 0
    self.rd = 0

  def randomize(self):
    self.instruction = random.choice(list(instr_dict.values()))
    self.opcode = self.instruction["opcode"]
    self.funct7 = self.instruction["funct7"]
    self.funct3 = self.instruction["funct3"]
    self.imm = random.randint(0, 2**20 - 1) & bitmask(self.instruction["imm_len"])
    # print(f"rand_imm = 0x{self.imm:08x}")
    if ((self.opcode == I_INT or self.opcode == I_JUMP or self.opcode == I_LOAD) and self.imm & 0x800):
      self.imm |= 0xFFFF_F000
    elif (self.opcode == S_STORE and self.imm & 0x800):
      self.imm |= 0xFFFF_F000
    elif (self.opcode == S_BRANCH):
      if (self.imm & 0x800):
        self.imm |= 0xFFFF_F000
      self.imm <<= 1
    elif (self.opcode == U_JUMP):
      self.imm <<= 1
      if (self.imm & 0x10_0000):
        self.imm |= 0xFFE0_0000
    elif (self.opcode == U_IMM or self.opcode == U_PC or self.opcode == U_JUMP):
      self.imm <<= 12
    self.imm &= bitmask(32)
    self.rs2 = random.randint(0, 2**5 - 1)
    self.rs1 = random.randint(0, 2**5 - 1)
    self.rd = random.randint(0, 2**5 - 1)
    # print(f"random imm: 0x{self.imm:08x}\trs2: 0x{self.rs2:02x}\trs1: 0x{self.rs1:02x}\trd: 0x{self.rd:02x}")
