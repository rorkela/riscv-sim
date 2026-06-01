compile_prog: prog/p1.c
	riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -T prog/linker.ld prog/p1.c -o temp_outputs/prog.elf

inspect_elf: 
	riscv-none-elf-objdump -d temp_outputs/prog.elf

elf_to_hex:
	riscv-none-elf-objcopy -O verilog --change-addresses -0x80000000 ../riscv-tests/isa/rv32ui-p-lw temp_outputs/program.hex
verilate:
	verilator --build --cc src/top.sv --exe src/verilator_tb.cpp -I./src --trace

run:
	./obj_dir/Vtop
TEST_DIR := ../riscv-tests/isa

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
