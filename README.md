# RV32IZca (SystemVerilog+Verilator)
Pipelined implementation of RV32IZca in SystemVerilog and verified using Verilator.

## Features
- 5-stage pipelined RV32I processor
- Zca compressed instruction support via IF-stage decompression
- Verilator simulation environment
- riscv-tests integration
- Embench-IoT benchmark support

## Instructions
1. Configure the `Makefile` to update `RISCV_TESTS` and `EMBENCH` variables to path to their cloned repository. Also use appropriate `RISCV_PREFIX`
2. Make sure `riscv-tests` are compiled beforehand with `XLEN=32`
3. Use `make verilate` to compile the core. (Pass `TARGET_DESIGN` as required)
General Programs:
```bash
make compile_prog #Not tested as of current build
make elf_to_hex
make run 
```
Test:
Consider pass if `gp=1` else fail
```bash
make run_tests
```
Benchmark:
Consider pass if `a0=0 gp=2` else fail
```bash
make compile_benchmark BENCHMARK=crc32
make run
```

## Checklist
- [x] RV32I Single Cycle
- [x] Rv32I Single Cycle Complete ISA test (riscv-tests)
- [x] RV32I Pipelined
- [x] RV32I Pipelined Complete ISA test (riscv-tests)
- [x] RV32I Pipelined embench setup + test runs
- [x] RV32I Embench setup more formalized
- [x] RV32IZca tests + Benchmark
- [x] Mult unit (Booth Multiplier)
- [ ] RV32IZcaZmmul tests + Benchmarks
- [ ] Div unit
- [ ] RV32IM Pipelined (+ tests)
- [ ] RV32I Pipelined generic Branch Prediction (+ tests + benchmark)

Currently on pause due to personal commitments
