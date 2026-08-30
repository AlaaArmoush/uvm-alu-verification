# UVM ALU Verification

A self-checking UVM testbench for a 32-bit ALU using Cadence Xcelium.

## Run

```bash
make check
make test TEST=alu_regression_test SEQ=alu_add_sequence SEED=1
make regress RANDOM_SEED=1
```

A failing test is expected while the supplied RTL bugs remain unfixed. Each run saves its full log under `build/`.

## Waveforms

Generate and open a waveform database:

```bash
make waves TEST=alu_regression_test SEQ=alu_overflow_sequence SEED=1
make view TEST=alu_regression_test SEQ=alu_overflow_sequence SEED=1
```

`make view` requires a graphical SimVision session.

## Confirmed RTL bugs

- `Error` remains asserted after a later legal operation.
- Signed addition overflow does not assert `Error`.
- Signed subtraction underflow does not assert `Error`.

## Main files

- `ALU.sv` — ALU RTL under verification
- `tb/` — UVM environment, tests, sequences, and top-level testbench
- `files.f` — compilation order
- `Makefile` — compile, test, regression, coverage, and waveform commands
