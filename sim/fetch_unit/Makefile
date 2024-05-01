# CocoTB Makefile

REPO_DIR := /home/shaun/repos/rv32i

# IF_DIR	:= $(REPO_DIR)/interfaces
PKG_DIR := $(REPO_DIR)/packages
RTL_DIR := $(REPO_DIR)/rtl
SIM_DIR := $(REPO_DIR)/sim/fetch_unit

SIM ?= verilator

EXTRA_ARGS += --trace --trace-structs

TOPLEVELLANG ?= verilog

VERILOG_SOURCES += $(PKG_DIR)/riscv_pkg.sv
VERILOG_SOURCES += $(RTL_DIR)/program_counter.sv
VERILOG_SOURCES += $(RTL_DIR)/fetch_ctrl.sv
VERILOG_SOURCES += $(RTL_DIR)/fetch_unit.sv

TOPLEVEL = fetch_unit

MODULE = tb_fetch_unit

include $(shell cocotb-config --makefiles)/Makefile.sim

WAVES = dump.vcd

.PHONY: waves
waves:
	gtkwave $(WAVES)
