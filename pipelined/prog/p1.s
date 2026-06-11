.section .text
.global _start
_start:
	addi x10,x0,1
	add x0,x0,x0
	add x0,x0,x0
	add x0,x0,x0
	add x0,x0,x0
	add x0,x0,x0
	beq x10,x0,8
	addi x11,x0,2
	addi x12,x0,3
	add x0,x0,x0
	add x0,x0,x0
	add x0,x0,x0
	add x0,x0,x0
	add x0,x0,x0

