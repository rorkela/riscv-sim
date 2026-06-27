# RV32IZca RISC-V Core (SystemVerilog + Verilator)
Pipelined implementation of RV32IZca in SystemVerilog and verified using Verilator.

## Features
- 5-stage pipelined RV32I core with forwarding, hazard detection, stalls, and flushes
- Zca compressed instruction support via instruction decompression in the IF stage
- Verilator-based simulation environment
- riscv-tests integration
- Embench-IoT benchmark support

## Instructions
1. Configure the `Makefile` to update `RISCV_TESTS` and `EMBENCH` variables to path to their cloned repository. Also use appropriate `RISCV_PREFIX`
2. Make sure `riscv-tests` are compiled beforehand with `XLEN=32`
3. Use `make verilate` to compile the core. (Pass `TARGET_DESIGN` as required)
Running Programs:
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
## Some benchmark results
| Benchmark | CPI | Cycles | Code Size (B) | Code Size + Zca (B) |
|-----------|----:|-------:|--------------:|--------------------:|
| crc32 | 1.18 | 10.5M |  912| 572|
| edn | 1.49 | 122M |  5908| 4360|
| huffbench | 1.34 | 10.5M | 5336 | 4096|
| qrduino | 1.41 | 18.8M |  21104| 16060|
## Personal Comments
This was one of the things which i delayed for quite a while. However just wanted to add that Verilator and its linting helped a lot in the project. It was really powerful at making sure i was not messing anything up. Most of the times just clearing up the linter issues would save me a hour of debugging.

Integration of the test-suites and benchmarks was little challenging but was manageable due to the fact that it was just compiled programs. I just needed to make sure the memory locations and other things are appropriate. 

I tested some basic synthesizability with yosys and it worked.

For this project, I assumed a ideal memory model without delays. I did not want to complicate the thing further by modelling the memory. I wanted to solely focus on the architecture more.

CPI calculation is little weird I realised later. But it averages out for large benchmarks, few line fix. will implement later.
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
