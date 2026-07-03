/* 32-bit boot code: multiboot1/PVH entry -> set up long mode -> jump to 64-bit _start64
 * Compiled as 64-bit ELF (with .code32 for boot, .code64 for kernel entry).
 * QEMU loads via PVH note, starts in 32-bit mode, boot code switches to long mode.
 */

.section .boot, "ax"
.code32
.globl _start
_start:
    /* Set up stack for 32-bit boot */
    movl $0x90000, %esp

    /* Set up page tables for identity mapping (first 2MB) */
    /* PML4 at 0x70000, PDPT at 0x71000, PD at 0x72000 */
    movl $0x70000, %eax
    movl $0x71000, (%eax)      /* PML4[0] -> PDPT */
    movl $0x71, 4(%eax)         /* Present + Write */

    movl $0x71000, %eax
    movl $0x72000, (%eax)      /* PDPT[0] -> PD */
    movl $0x71, 4(%eax)         /* Present + Write */

    movl $0x72000, %eax
    movl $0x00000083, (%eax)   /* PD[0] = 2MB page, Present + Write + PS (huge page) */

    /* Load CR3 with PML4 */
    movl $0x70000, %eax
    movl %eax, %cr3

    /* Enable PAE (CR4.PAE = 1) */
    movl %cr4, %eax
    orl $0x20, %eax
    movl %eax, %cr4

    /* Enable long mode (EFER.LME = 1) */
    movl $0xC0000080, %ecx      /* EFER MSR */
    rdmsr
    orl $0x100, %eax            /* LME = 1 */
    wrmsr

    /* Enable paging (CR0.PG = 1) */
    movl %cr0, %eax
    orl $0x80000000, %eax
    movl %eax, %cr0

    /* Set up a minimal GDT for long mode */
    movl $0x73000, %eax
    /* GDT entry 0: null */
    movl $0, (%eax)
    movl $0, 4(%eax)
    /* GDT entry 1: 64-bit code (base=0, limit=0xFFFFF, type=0x9A, flags=0xAF) */
    movl $0x73008, %eax
    movl $0x0000FFFF, (%eax)
    movl $0x00AF9A00, 4(%eax)

    /* Load GDT */
    movl $0x73000-6, %eax
    movw $15, (%eax)
    movl $0x73000, 2(%eax)
    lgdt (%eax)

    /* Far jump to 64-bit code segment */
    ljmp $0x08, $_start64

.section .text
.code64
.globl _start64
_start64:
    /* Now in 64-bit mode! Set up stack and call kmain */
    movq $0x90000, %rsp
    callq kmain
    cli
    hlt
    jmp .

/* PVH ELF Note: tells QEMU to boot this 64-bit ELF via 32-bit PVH entry */
.section .note.pvh, "a"
.align 4
.long 0x00000004          /* namesz: "Xen\0" = 4 bytes */
.long 0x00000004          /* descsz: 4 bytes (32-bit entry address) */
.long 0x80000001          /* type: XEN_ELFNOTE_PHYS32_ENTRY */
.asciz "Xen"              /* name */
.long _start              /* desc: 32-bit entry point */
