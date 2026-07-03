ENTRY(_start)
PHDRS {
    boot PT_LOAD;
    text PT_LOAD;
    note PT_NOTE;
}
SECTIONS {
    . = 0x100000;
    .boot : { *(.boot) } :boot
    .text : { *(.text*) } :text
    .rodata : { *(.rodata*) } :text
    .data : { *(.data*) } :text
    .note.pvh : { *(.note.pvh) *(.note*) } :note
    .bss : {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;
        . = ALIGN(16);
        . += 16384;
        __stack_top = .;
    } :text
}
