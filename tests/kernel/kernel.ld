ENTRY(_start)
SECTIONS {
    . = 0x100000;
    .boot : { *(.boot) }
    .text : { *(.text) }
    .rodata : { *(.rodata*) }
    .data : { *(.data) }
    .bss : {
        __bss_start = .;
        *(.bss)
        *(COMMON)
        __bss_end = .;
        . = ALIGN(16);
        . += 16384;
        __stack_top = .;
    }
}
