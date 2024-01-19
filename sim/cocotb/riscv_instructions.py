# riscv_instructions.py

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
      "JAL":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1101111, 'imm_len': 20},
      "JALR":   {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1100111, 'imm_len': 12},
      "BEQ":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1100011, 'imm_len': 12},
      "BNE":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1100011, 'imm_len': 12},
      "BLT":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1100011, 'imm_len': 12},
      "BLTU":   {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1100011, 'imm_len': 12},
      "BGE":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1100011, 'imm_len': 12},
      "BGEU":   {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b1100011, 'imm_len': 12},
      "LW":     {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0000011, 'imm_len': 12},
      "LH":     {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0000011, 'imm_len': 12},
      "LHU":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0000011, 'imm_len': 12},
      "LB":     {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0000011, 'imm_len': 12},
      "LBU":    {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0000011, 'imm_len': 12},
      "SW":     {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0100011, 'imm_len': 12},
      "SH":     {'funct7': 0b0000000, 'funct3': 0b000, 'opcode': 0b0100011, 'imm_len': 12},
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
    if self.opcode & R_INT:
      ret |= self.rd << 5
      ret |= self.funct3 << 12
      ret |= self.rs1 << 15
      ret |= self.rs2 << 20
      ret |= self.funct7 << 25
      return ret

    elif self.opcode & I_INT or self.opcode & I_JUMP or self.opcodee & I_LOAD:
      ret |= self.rd << 5
      ret |= self.funct3 << 12
      ret |= self.rs1 << 15
      ret |= self.imm << 20
      if self.instruction == instr_dict['SLLI'] or \
        self.instruction == instr_dict['SRLI'] or \
        self.instruction == instr_dict['SRAI']:
        ret |= self.funct7 << 25
      return ret

    elif self.opcode & S_BRANCH or self.opcode & S_STORE:
      ret |= self.rd << 5
      ret |= (self.imm & 0x1F) << 12
      ret |= self.rs1 << 15
      ret |= self.rs2 << 20
      ret |= (self.funct7 & 0xFE0) << 20 # 25-5
      return ret
    
    elif self.opcode & U_IMM or self.opcode & U_PC or self.opcode & U_JUMP:
      ret |= self.rd << 7
      ret |= self.imm << 12
      return ret

  def __str__(self):
    return str(self.instruction)

  def nop(self):
    self.instruction = instr_dict['ADD']
    self.opcode = instr_dict['ADD']['opcode']
    self.funct7 = instr_dict['ADD']['funct7']
    self.funct3 = instr_dict['ADD']['funct3']
    self.imm = 0
    self.rs2 = 0
    self.rs1 = 0
    self.rd = 0

  def randomize(self):
    self.instruction = random.choice(list(instr_dict.values()))
    self.opcode = self.instruction["opcode"]
    self.funct7 = self.instruction["funct7"]
    self.funct3 = self.instruction["funct3"]
    self.imm = random.randint(0, 2**20) & bitmask(self.instruction["imm_len"])
    self.rs2 = random.randint(0, 2**5)
    self.rs1 = random.randint(0, 2**5)
    self.rd = random.randint(0, 2**5)