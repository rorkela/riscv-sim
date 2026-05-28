compile_prog: prog/p1.c
	riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -T prog/linker.ld prog/p1.c -o temp_outputs/prog.elf;

inspect_elf: 
	riscv-none-elf-objdump -d temp_outputs/prog.elf

elf_to_hex:
	riscv-none-elf-objcopy -O verilog temp_outputs/prog.elf temp_outputs/program.hex
verilate:
	verilator  --build --cc src/top.sv --exe src/verilator_tb.cpp -I./src 
run:
	./obj_dir/Vtop
