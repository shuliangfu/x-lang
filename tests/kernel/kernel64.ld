ENTRY(_start)
SECTIONS {
    . = 0xFFFFFFFF80000000;
    .boot : { *(.boot) }
    .text : { *(.text*) }
    .rodata : { *(.rodata*) }
    .data : { *(.data*) }
    .bss : { *(.bss*) *(COMMON) }
}
