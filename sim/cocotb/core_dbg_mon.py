# core_dbg_mon.py

from cocotb.triggers import RisingEdge


class CoreDbgMon:
  def __init__(self, dut, clk):
    self.dut = dut
    self.clk = clk
    self.pc_op    = 0
    self.pc       = 0
    self.instr    = 0
    self.opcode   = 0
    self.funct7   = 0
    self.funct3   = 0
    self.imm      = 0
    self.rs1_addr = 0
    self.rs1_data = 0
    self.rs2_addr = 0
    self.rs2_data = 0
    self.rd_addr  = 0
    self.alu_op   = 0
    self.alu_res  = 0
    self.alu_zero = 0
    self.alu_zero = 0
    self.wb_op    = 0
    self.rd_valid = 0
    self.rd_data  = 0

  def __str__(self):
    s  = f"dbg\t0x{int(self.pc):08x}:"#0x{int(self.instr):08x}"
    s += f"\t\tfunct7: 0b{int(self.funct7):07b}"
    s += f"\tfunct3: 0b{int(self.funct3):03b}"
    s += f"\topcode: 0b{int(self.opcode):07b}"
    s += f"\timm: 0x{int(self.imm):08x}"
    s += f"\trs2: 0x{int(self.rs2_addr):02x}"
    s += f"\trs1: 0x{int(self.rs1_addr):02x}"
    s += f"\trd: 0x{int(self.rd_addr):02x}"
    # s += f"\tPC_OP: {self.pc_op}"
    return s

  async def run(self):
    while True:
      await RisingEdge(self.clk)
      self.pc_op    = self.dut.dbg_pc_op_data.value
      self.pc       = self.dut.dbg_fu_pc_data.value
      self.instr    = self.dut.dbg_fu_instruction.value
      self.opcode   = self.dut.dbg_du_id_opcode.value
      self.funct7   = self.dut.dbg_du_id_funct7.value
      self.funct3   = self.dut.dbg_du_id_funct3.value
      self.imm      = self.dut.dbg_du_id_imm.value
      # print(f"rx 0x{int(self.dut.dbg_du_id_imm.value):08x}")
      self.rs1_addr = self.dut.dbg_du_rf_rs1_raddr.value
      self.rs1_data = self.dut.dbg_du_rf_rs1_rdata.value
      self.rs2_addr = self.dut.dbg_du_rf_rs2_raddr.value
      self.rs2_data = self.dut.dbg_du_rf_rs2_rdata.value
      self.rd_addr  = self.dut.dbg_du_rf_rd_waddr.value
      self.alu_op   = self.dut.dbg_alu_op_data.value
      self.alu_res  = self.dut.dbg_eu_alu_res_data.value
      self.alu_zero = self.dut.dbg_eu_alu_res_zero.value
      self.alu_zero = self.dut.dbg_dm_op_data.value
      self.wb_op    = self.dut.dbg_wb_op_data
      self.rd_valid = self.dut.dbg_rf_rd_wvalid
      self.rd_data  = self.dut.dbg_eu_wb_rf_rd_wdata

  def instr_check(self, instr):
    assert self.instr == instr, f"Failed Instruction: tb={instr}\tdbg={hex(self.instr)}"
  
  def op_funct_check(self, instr):
    assert self.opcode == instr.opcode, f"Failed Opcode: tb={hex(instr.opcode)}\tdbg={hex(self.opcode)}"
    assert self.funct7 == instr.funct7, f"Failed Funct7: tb={hex(instr.funct7)}\tdbg={hex(self.funct7)}"
    assert self.funct3 == instr.funct3, f"Failed Funct3: tb={hex(instr.funct3)}\tdbg={hex(self.funct3)}"
