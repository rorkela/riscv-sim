#include <support.h>

// Force the symbol to be globally visible to the linker
void _start(void) __attribute__((section(".text.init"), naked, public));

void _start(void) {
    __asm__ volatile (
        "la sp, _stack_top \n"
        "jal ra, main      \n"
        :
        :
        : "memory"
    );
}

void initialise_board() {}
void start_trigger() { __asm__ volatile ("nop"); }
void stop_trigger() { __asm__ volatile ("ecall"); }
