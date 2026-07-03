/* 32-bit multiboot1 boot code -> switch to long mode -> 64-bit serial output.
 * Compiled as 32-bit ELF. .code64 section emits 64-bit instructions in 32-bit ELF.
 */
.section .boot, "ax"
.code32
.globl _start
_start:
    movl $0x90000, %esp
    /* Page tables: PML4@0x70000, PDPT@0x71000, PD@0x72000 */
    /* PML4[0] -> PDPT @ 0x71000, P+RW = 0x3 */
    movl $0x70000, %eax
    movl $0x71003, (%eax)
    movl $0, 4(%eax)
    /* PDPT[0] -> PD @ 0x72000, P+RW = 0x3 */
    movl $0x71000, %eax
    movl $0x72003, (%eax)
    movl $0, 4(%eax)
    /* PD[0] = 2MB huge page, P+RW+PS = 0x83 */
    movl $0x72000, %eax
    movl $0x00000083, (%eax)
    movl $0, 4(%eax)
    /* Load CR3 */
    movl $0x70000, %eax
    movl %eax, %cr3
    /* Enable PAE (CR4.PAE = bit 5) */
    movl %cr4, %eax
    orl $0x20, %eax
    movl %eax, %cr4
    /* Enable long mode (EFER.LME = bit 8) */
    movl $0xC0000080, %ecx
    rdmsr
    orl $0x100, %eax
    wrmsr
    /* Enable paging (CR0.PG = bit 31) */
    movl %cr0, %eax
    orl $0x80000000, %eax
    movl %eax, %cr0
    /* GDT for long mode */
    movl $0x73000, %eax
    movl $0, (%eax)
    movl $0, 4(%eax)
    movl $0x73008, %eax
    movl $0x0000FFFF, (%eax)
    movl $0x00AF9A00, 4(%eax)
    /* Load GDT */
    movl $0x73000-6, %eax
    movw $15, (%eax)
    movl $0x73000, 2(%eax)
    lgdt (%eax)
    /* Far jump to 64-bit code segment (selector 0x08) */
    ljmp $0x08, $_start64

.section .text, "ax"
.code64
_start64:
    /* 64-bit mode! Output 'Q:64\n' via COM1 serial */
    movb $0x51, %al           /* 'Q' */
    movw $0x3F8, %dx
    outb %al, %dx
    movb $0x3A, %al           /* ':' */
    outb %al, %dx
    movb $0x36, %al           /* '6' */
    outb %al, %dx
    movb $0x34, %al           /* '4' */
    outb %al, %dx
    movb $0x0A, %al           /* '\n' */
    outb %al, %dx
    cli
    hlt
    jmp .
