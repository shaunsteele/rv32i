# CocoTB Makefile

REPO_DIR := /home/shaun/repos/rv32i

# IF_DIR	:= $(REPO_DIR)/interfaces
PKG_DIR := $(REPO_DIR)/packages
RTL_DIR := $(REPO_DIR)/rtl
SIM_DIR := $(REPO_DIR)/sim/program_counter

SIM ?= verilator

EXTRA_ARGS += --trace --trace-structs

TOPLEVELLANG ?= verilog

VERILOG_SOURCES += $(PKG_DIR)/riscv_pkg.sv
VERILOG_SOURCES += $(RTL_DIR)/program_counter.sv

TOPLEVEL = program_counter

MODULE = tb_program_counter

include $(shell cocotb-config --makefiles)/Makefile.sim

WAVES = dump.vcd

.PHONY: waves
waves:
	gtkwave $(WAVES)
