.section .text.init
.global _start

_start:
    la sp, _stack_top   # Set up the stack pointer using the address from the linker script
    jal ra, main        # Jump to the Embench main function
