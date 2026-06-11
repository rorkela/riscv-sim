SECTIONS
{
    .text 0x00000000 : {
        *(.text*)
    }

    .rodata : {
        *(.rodata*)
    }

    .data 0x00001000 : {
        *(.data*)
    }

    .bss : {
        *(.bss*)
    }
}
