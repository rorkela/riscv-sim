TARGET_DESIGN?=pipelined
TOP?=top.sv
TB?=verilator_tb.cpp
DESIGN_PATH=./designs/$(TARGET_DESIGN)/src
TOP_PATH=$(DESIGN_PATH)/$(TOP)
TB_PATH=$(DESIGN_PATH)/$(TB)
BOARDSUPPORT=./boardsupport/
RISCV_TESTS?=../riscv-tests
EMBENCH?=../embench-iot
RISCV_PREFIX?=riscv-none-elf-

compile_prog: prog/p1.c
	$(RISCV_PREFIX)gcc -march=rv32i -mabi=ilp32 -nostdlib -T prog/linker.ld prog/p1.c -o temp_outputs/prog.elf

compile_ass: prog/p1.s
	$(RISCV_PREFIX)gcc -march=rv32i -mabi=ilp32 -nostdlib -T prog/linker.ld prog/p1.s -o temp_outputs/prog.elf

inspect_elf: 
	$(RISCV_PREFIX)objdump -d temp_outputs/prog.elf

elf_to_hex:
	$(RISCV_PREFIX)objcopy -O verilog temp_outputs/prog.elf temp_outputs/program.hex

verilate:
	verilator --build --cc $(TOP_PATH) --exe $(TB_PATH) -I$(DESIGN_PATH) --trace -j$(nproc)

gtkwave:
	gtkwave waveform.vcd

run:
	./obj_dir/Vtop
TEST_DIR := $(RISCV_TESTS)/isa

run_tests:
	@for test in $(filter-out %.dump,$(wildcard $(TEST_DIR)/rv32ui-p-*)); do \
		echo "Running $$(basename $$test)"; \
		riscv-none-elf-objcopy \
			-O verilog \
			--change-addresses -0x80000000 \
			$$test \
			temp_outputs/program.hex || exit 1; \
		$(MAKE) run || exit 1; \
	done
	@for test in $(filter-out %.dump,$(wildcard $(TEST_DIR)/rv32uc-p-*)); do \
		echo "Running $$(basename $$test)"; \
		riscv-none-elf-objcopy \
			-O verilog \
			--change-addresses -0x80000000 \
			$$test \
			temp_outputs/program.hex || exit 1; \
		$(MAKE) run || exit 1; \
	done
crun: verilate compile_prog elf_to_hex run gtkwave
assrun: verilate compile_ass elf_to_hex run gtkwave

BENCHMARK?=crc32
compile_benchmark:
	cd $(EMBENCH) && \
	scons --config-dir=$(abspath $(BOARDSUPPORT)) cc=$(RISCV_PREFIX)gcc cflags='-fdata-sections -ffunction-sections -mabi=ilp32 -march=rv32i_zca' ldflags='-Wl,-gc-sections -Wl,--undefined=_start -mabi=ilp32 -march=rv32i_zca -nostartfiles -T$${CONFIG_DIR}/link.ld' user_libs=-lm bd/src/$(BENCHMARK)/$(BENCHMARK)
	$(RISCV_PREFIX)objcopy -O verilog $(EMBENCH)/bd/src/$(BENCHMARK)/$(BENCHMARK) temp_outputs/program.hex 
