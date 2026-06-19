OUTPUT_ARCH( "riscv" )

SECTIONS
{
  . = 0x00000000;

  .text : {
    *(.text.init)
    *(.text)
    *(.text.*)
  }

  .rodata : {
    *(.rodata)
    *(.rodata.*)
  }

  .data : {
    *(.data)
    *(.data.*)
  }

  .bss : {
    *(.bss)
    *(.bss.*)
    *(COMMON)
  }

  /* Define a crude stack pointer marker at the end of the binary */
  _stack_top = ALIGN(16) + 0x4000;
}
