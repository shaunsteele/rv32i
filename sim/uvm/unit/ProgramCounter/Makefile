# Sanity Check
ifneq ($(words $(CURDIR)), 1)
	$(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

# Setup Variables
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe

# Optimize
VERILATOR_FLAGS += -x-assign fast

# Warn about lint issues
VERILATOR_FLAGS += -Wall

# Make Waveforms
VERILATOR_FLAGS += --trace

# Check SystemVerilog assertions
VERILATOR_FLAGS += --assert

# Generate Coverage Analysis
VERILATOR_FLAGS += --coverage

# Input files for Verilator
SRC_DIR = ~/repos

INC_FILES += $(SRC_DIR)/rv32i/rtl/core/core.svh

RTL_FILES += $(SRC_DIR)/rv32i/rtl/core/ProgramCounter.sv

SIM_FILES += $(SRC_DIR)/rv32i/sim/uvm/unit/ProgramCounter/TbPcTop.sv

VERILATOR_INPUT = -f $(INC_FILES) $(RLT_FILES) $(SIM_FILES)

default: run

run:
	@echo
	@echo "### VERILATING ###"
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)

	@echo
	@echo "### BUILDING ###"
	$(MAKE) -j -C obj_dir -f Vtop.mk

	@echo
	@echo "### RUNNING ###"
	@rm -rf logs
	mkdir -p logs
	obj_dir/Vtop +trace

	@echo
	@echo "### COVERAGE ###"
	@rm -rf logs/annotated
	$(VERILATOR_COVERAGE) --annotate logs/annotated logs/coverage.dat

	@echo
	@echo "### DONE ###"
	@echo "to see waveforms, open vlt_dump.vcd in a waveform viewer"
	@echo

show-config:
	$(VERILATOR) -V

maintainer-copy::
clean mostlyclean distclean maintainer-clean::
	-rm -rf obj_dir *.log *.dmp *.vpd coverage.dat core
