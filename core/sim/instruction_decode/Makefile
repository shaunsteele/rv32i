
REPO_DIR := /home/shaun/repos/rv32i

PKG_DIR := $(REPO_DIR)/packages
RTL_DIR := $(REPO_DIR)/core/rtl

SIM ?= verilator

EXTRA_ARGS += --trace --trace-structs

TOPLEVELLANG ?= verilog

VERILOG_SOURCES += $(PKG_DIR)/riscv_pkg.sv
VERILOG_SOURCES += $(RTL_DIR)/instruction_decoder.sv

TOPLEVEL = instruction_decoder

MODULE = tb_instruction_decoder

include $(shell cocotb-config --makefiles)/Makefile.sim

WAVEFILE = dump.vcd

.PHONY: waves
waves:
	gtkwave $(WAVEFILE)
