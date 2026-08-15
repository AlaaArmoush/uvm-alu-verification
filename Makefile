XRUN       ?= xrun
XRUN_FLAGS ?= -64bit -uvm -c

PROJECT_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TB_DIR      := $(PROJECT_ROOT)tb
BUILD_DIR   := $(PROJECT_ROOT)build/check

SOURCES := $(TB_DIR)/alu_interface.sv \
           $(TB_DIR)/alu_sequence_item.sv \
           $(TB_DIR)/alu_sequencer.sv

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
