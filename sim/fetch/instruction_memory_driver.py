# instruction_memory_driver.py

from cocotb import coroutine
from cocotb_bus.drivers.amba import AXI4Slave


def get_parameters(dut):
  addr_len = dut.IMADDRLEN.value
  data_len = dut.IMDATALEN.value
  return addr_len, data_len

class instruction_memory_driver:
  def __init__(self, dut, memory):
    s_axi = AXI4Slave(dut, 'im', dut.clk, memory)
    # print("\nRDATA LEN")
    # print(len(s_axi.bus.RDATA))
  
