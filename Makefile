XRUN       ?= xrun
XRUN_FLAGS ?= -64bit -uvm -c

PROJECT_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TB_DIR       := $(PROJECT_ROOT)tb
SEQ_DIR      := $(TB_DIR)/sequences
BUILD_DIR    := $(PROJECT_ROOT)build/check

SOURCES := $(TB_DIR)/alu_interface.sv \
           $(TB_DIR)/alu_sequence_item.sv \
           $(TB_DIR)/alu_sequencer.sv \
           $(SEQ_DIR)/alu_random_sequence.sv \
           $(SEQ_DIR)/alu_add_sequence.sv \
           $(SEQ_DIR)/alu_sub_sequence.sv \
           $(SEQ_DIR)/alu_and_sequence.sv \
           $(SEQ_DIR)/alu_or_sequence.sv \
           $(SEQ_DIR)/alu_xor_sequence.sv \
           $(SEQ_DIR)/alu_undefined_opcode_sequence.sv \
           $(SEQ_DIR)/alu_overflow_sequence.sv \
           $(SEQ_DIR)/alu_underflow_sequence.sv \
           $(TB_DIR)/alu_driver.sv \
           $(TB_DIR)/alu_monitor.sv \
           $(TB_DIR)/alu_agent.sv \
					 $(TB_DIR)/alu_scoreboard.sv \
					 $(TB_DIR)/alu_coverage.sv \
					 $(TB_DIR)/alu_environment.sv \
           $(TB_DIR)/alu_base_test.sv \
           $(TB_DIR)/alu_random_test.sv \
           $(TB_DIR)/alu_regression_test.sv

.PHONY: help check clean
.DELETE_ON_ERROR:

help:
	@echo "Available targets:"
	@echo "  make check    Compile all testbench sources"
	@echo "  make clean    Remove compile-check output"

check: | $(BUILD_DIR)
	cd "$(BUILD_DIR)" && $(XRUN) $(XRUN_FLAGS) $(SOURCES)
	@echo "COMPILE PASS: all testbench sources compiled successfully."

$(BUILD_DIR):
	mkdir -p "$@"

clean:
	rm -rf -- "$(BUILD_DIR)"
