# ============================================================================
# Makefile for UVM ALU Verification
# ============================================================================

XRUN       ?= xrun
XRUN_FLAGS ?= -64bit -uvm -quiet
SIMVISION  ?= simvision

PROJECT_ROOT  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BUILD_ROOT    := $(PROJECT_ROOT)build
COMPILE_DIR   := $(BUILD_ROOT)/compile
COMPILE_STAMP := $(COMPILE_DIR)/.compile_done

TOP      := tb_top
SNAPSHOT := alu_snapshot

TEST        ?= alu_regression_test
SEQ         ?= all
SEED        ?= 1
RANDOM_SEED ?= 1
VERBOSITY   ?= UVM_LOW
SHOW_OUTPUT ?= 1

RUN_DIR      := $(BUILD_ROOT)/$(TEST)_$(SEQ)_seed_$(SEED)
COVERAGE_DIR := $(BUILD_ROOT)/coverage_$(TEST)_$(SEQ)_seed_$(SEED)
WAVE_DIR     := $(BUILD_ROOT)/waves_$(TEST)_$(SEQ)_seed_$(SEED)

SIM_ARGS = \
	-svseed $(SEED) \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=$(VERBOSITY) \
	+SEQ_NAME=$(SEQ)

DIRECTED_SEQUENCES := \
	alu_add_sequence \
	alu_sub_sequence \
	alu_and_sequence \
	alu_or_sequence \
	alu_xor_sequence \
	alu_undefined_opcode_sequence \
	alu_overflow_sequence \
	alu_underflow_sequence

SOURCES := \
	$(PROJECT_ROOT)Makefile \
	$(PROJECT_ROOT)files.f \
	$(PROJECT_ROOT)ALU.sv \
	$(wildcard $(PROJECT_ROOT)tb/*.sv) \
	$(wildcard $(PROJECT_ROOT)tb/sequences/*.sv)

GREEN := \033[0;32m
RED   := \033[0;31m
NC    := \033[0m

.PHONY: help compile check test regress coverage waves view clean
.DELETE_ON_ERROR:

help:
	@echo "make check"
	@echo "make test TEST=<test> SEQ=<sequence> SEED=<seed>"
	@echo "make regress RANDOM_SEED=<seed>"
	@echo "make coverage TEST=<test> SEQ=<sequence> SEED=<seed>"
	@echo "make waves TEST=<test> SEQ=<sequence> SEED=<seed>"
	@echo "make view TEST=<test> SEQ=<sequence> SEED=<seed>"
	@echo "make clean"

# Compile and elaborate one reusable snapshot.
compile: $(COMPILE_STAMP)

$(COMPILE_STAMP): $(SOURCES) | $(COMPILE_DIR)
	@echo "Compiling design snapshot $(SNAPSHOT) ..."
	@cd "$(COMPILE_DIR)" && \
		$(XRUN) $(XRUN_FLAGS) \
		-f ../../files.f \
		-top $(TOP) \
		-elaborate \
		-snapshot $(SNAPSHOT)
	@touch "$@"

check: compile
	@printf "$(GREEN)Compile/elaboration check passed.$(NC)\n"

# A direct test displays all UVM and scoreboard output.
# Regression invokes this target with SHOW_OUTPUT=0.
test: compile | $(RUN_DIR)
	@echo "Running $(TEST)/$(SEQ) with seed $(SEED)"
	@if [ "$(SHOW_OUTPUT)" = "1" ]; then \
		cd "$(COMPILE_DIR)" && \
		$(XRUN) $(XRUN_FLAGS) \
			-r $(SNAPSHOT) \
			$(SIM_ARGS) \
			-l "$(RUN_DIR)/xrun.log" || true; \
	else \
		cd "$(COMPILE_DIR)" && \
		$(XRUN) $(XRUN_FLAGS) \
			-r $(SNAPSHOT) \
			$(SIM_ARGS) \
			-l "$(RUN_DIR)/xrun.log" \
			> /dev/null 2>&1 || true; \
	fi
	@if grep -q "TEST PASS" "$(RUN_DIR)/xrun.log" 2>/dev/null && \
	    ! grep -q "TEST FAIL" "$(RUN_DIR)/xrun.log" 2>/dev/null; then \
		printf "$(GREEN)Result: PASS$(NC)\n"; \
	else \
		printf "$(RED)Result: FAIL$(NC)\n"; \
		echo "Log: $(RUN_DIR)/xrun.log"; \
		exit 1; \
	fi

# Run all existing directed sequences, followed by one random test.
regress: compile
	@status=0; \
	results=""; \
	for sequence_name in $(DIRECTED_SEQUENCES); do \
		if $(MAKE) --no-print-directory test \
			TEST=alu_regression_test \
			SEQ=$$sequence_name \
			SEED=1 \
			VERBOSITY=$(VERBOSITY) \
			SHOW_OUTPUT=0; then \
			results="$$results\n  $$sequence_name: PASS"; \
		else \
			results="$$results\n  $$sequence_name: FAIL"; \
			status=1; \
		fi; \
	done; \
	if $(MAKE) --no-print-directory test \
		TEST=alu_random_test \
		SEQ=all \
		SEED=$(RANDOM_SEED) \
		VERBOSITY=$(VERBOSITY) \
		SHOW_OUTPUT=0; then \
		results="$$results\n  alu_random_test seed $(RANDOM_SEED): PASS"; \
	else \
		results="$$results\n  alu_random_test seed $(RANDOM_SEED): FAIL"; \
		status=1; \
	fi; \
	printf "\nRegression summary\n"; \
	printf "%b\n" "$$results"; \
	exit $$status

# Coverage requires its own instrumented compilation.
coverage: | $(COVERAGE_DIR)
	@cd "$(COVERAGE_DIR)" && \
		$(XRUN) $(XRUN_FLAGS) \
		-f ../../files.f \
		-top $(TOP) \
		$(SIM_ARGS) \
		-coverage all || true
	@grep "ALU_COVERAGE" "$(COVERAGE_DIR)/xrun.log" || true
	@grep -q "TEST PASS" "$(COVERAGE_DIR)/xrun.log"
	@! grep -q "TEST FAIL" "$(COVERAGE_DIR)/xrun.log"

# Wave recording requires signal access during compilation.
waves: | $(WAVE_DIR)
	@cd "$(WAVE_DIR)" && \
		$(XRUN) $(XRUN_FLAGS) \
		-f ../../files.f \
		-top $(TOP) \
		$(SIM_ARGS) \
		-access +rwc \
		-input ../../waves.tcl || true
	@test -d "$(WAVE_DIR)/xcelium.shm" || { \
		echo "Waveform generation failed."; \
		echo "Log: $(WAVE_DIR)/xrun.log"; \
		exit 1; \
	}
	@echo "Waveform database: $(WAVE_DIR)/xcelium.shm"

view:
	@test -d "$(WAVE_DIR)/xcelium.shm" || { \
		echo "Waveform database not found."; \
		echo "Run: make waves TEST=$(TEST) SEQ=$(SEQ) SEED=$(SEED)"; \
		exit 1; \
	}
	@test -n "$$DISPLAY" || { \
		echo "No graphical display is available."; \
		echo "Reconnect from Fedora using: ssh -Y orion"; \
		exit 1; \
	}
	@cd "$(WAVE_DIR)" && \
		$(SIMVISION) xcelium.shm > simvision.log 2>&1 &

$(COMPILE_DIR) $(RUN_DIR) $(COVERAGE_DIR) $(WAVE_DIR):
	@mkdir -p "$@"

clean:
	@rm -rf -- "$(BUILD_ROOT)"
