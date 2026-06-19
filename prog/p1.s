.section .text
.global _start
_start:
	addi x10,x0,67
	sw x10, 1000(x0)
	lw x11, 1000(x0)
	add x12, x11, x10

