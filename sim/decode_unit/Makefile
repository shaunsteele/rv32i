# CocoTB Makefile

REPO_DIR := /home/shaun/repos/rv32i

# IF_DIR	:= $(REPO_DIR)/interfaces
PKG_DIR := $(REPO_DIR)/packages
RTL_DIR := $(REPO_DIR)/rtl
SIM_DIR := $(REPO_DIR)/sim/decode_unit

SIM ?= verilator

EXTRA_ARGS += --trace --trace-structs

TOPLEVELLANG ?= verilog

VERILOG_SOURCES += $(PKG_DIR)/riscv_pkg.sv
VERILOG_SOURCES += $(RTL_DIR)/instruction_decode.sv
VERILOG_SOURCES += $(RTL_DIR)/register_file.sv
VERILOG_SOURCES += $(RTL_DIR)/decode_unit.sv

TOPLEVEL = decode_unit

MODULE = tb_decode_unit

include $(shell cocotb-config --makefiles)/Makefile.sim

WAVES = dump.vcd

.PHONY: waves
waves:
	gtkwave $(WAVES)
