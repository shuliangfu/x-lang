// User mode (ring 3) kernel — simplified for debugging.
#[repr(C)]
struct MB1Header {
  magic: u32;
  flags: u32;
  checksum: u32;
}

#[link_section(".boot")]
const mb1: MB1Header = {
  magic: 0x1BADB002,
  flags: 0,
  checksum: 0xE4524FFE,
};

function serial_putc(c: u8): void {
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
}
function serial_putint(n: i32): void {
  if (n >= 10) { serial_putint(n / 10); }
  serial_putc((n % 10 + 48) as u8);
}

let syscall_result: u32 = 0;

#[used]
#[naked]
function syscall_handler(): void {
  unsafe {
    asm!("cmp $1, %eax; je sys_print; cmp $2, %eax; je sys_add; cmp $99, %eax; je sys_done; jmp sys_done;
          sys_print: pusha; movb 16(%esp), %al; mov $0x3F8, %dx; outb %al, %dx; popa; jmp sys_done;
          sys_add: add %ecx, %ebx; movl %ebx, syscall_result; jmp sys_done;
          sys_done: iret");
  }
}

function idt_set_entry(index: u32, handler_addr: u32): void {
  let base: u32 = 0x90000 + index * 8;
  unsafe {
    *(base as *volatile u16) = (handler_addr & 65535) as u16;
    *((base + 2) as *volatile u16) = 8;
    *((base + 4) as *volatile u8) = 0;
    *((base + 5) as *volatile u8) = 142;
    *((base + 6) as *volatile u16) = (handler_addr >> 16) as u16;
  }
}

function kmain(): i32 {
  serial_putc(75);  // K
  serial_putc(58);  // :

  // GDT
  unsafe { *((0x60000) as *volatile u32) = 0; *((0x60004) as *volatile u32) = 0; }
  unsafe { *((0x60008) as *volatile u32) = 0x0000FFFF; *((0x6000C) as *volatile u32) = 0x00CF9A00; }
  unsafe { *((0x60010) as *volatile u32) = 0x0000FFFF; *((0x60014) as *volatile u32) = 0x00CF9200; }
  unsafe { *((0x60018) as *volatile u32) = 0x0000FFFF; *((0x6001C) as *volatile u32) = 0x00CFFA00; }
  unsafe { *((0x60020) as *volatile u32) = 0x0000FFFF; *((0x60024) as *volatile u32) = 0x00CFF200; }
  // TSS
  unsafe { *((0x60028) as *volatile u32) = 0x00000068; *((0x6002C) as *volatile u32) = 0x00408905; }
  let tss_esp0: *volatile u32 = (0x50000 + 4) as *volatile u32;
  unsafe { *tss_esp0 = 0x90000; }
  let tss_ss0: *volatile u32 = (0x50000 + 8) as *volatile u32;
  unsafe { *tss_ss0 = 0x10; }
  let gdtr: *volatile u16 = 0x5F000 as *volatile u16;
  unsafe { *gdtr = 47; }
  let gdtr_base: *volatile u32 = 0x5F002 as *volatile u32;
  unsafe { *gdtr_base = 0x60000; }
  unsafe { asm!("lgdt 0x5F000"); }
  unsafe { asm!("mov $0x28, %%ax; ltr %%ax" : : : "eax"); }
  unsafe {
    asm!("mov $0x10, %%ax; mov %%ax, %%ds; mov %%ax, %%es; mov %%ax, %%ss; mov %%ax, %%fs" : : : "eax");
    asm!("ljmp $0x08, $1f; 1:");
  }
  serial_putc(71);  // G (GDT done)

  // IDT
  let sc_addr: u32 = 0;
  unsafe { asm!("mov $syscall_handler, %0" : "=a"(sc_addr)); }
  idt_set_entry(128, sc_addr); unsafe { *((0x90000 + 128 * 8 + 5) as *volatile u8) = 238; }
  let idt_limit: *volatile u16 = 0x8F000 as *volatile u16;
  unsafe { *idt_limit = 2047; }
  let idt_base: *volatile u32 = 0x8F002 as *volatile u32;
  unsafe { *idt_base = 0x90000; }
  unsafe { asm!("lidt 0x8F000"); }
  serial_putc(73);  // I (IDT done)

  // PIC (mask all)
  unsafe {
    asm!("outb %%al, $0x20" : : "a"(17));
    asm!("outb %%al, $0xA0" : : "a"(17));
    asm!("outb %%al, $0x21" : : "a"(32));
    asm!("outb %%al, $0xA1" : : "a"(40));
    asm!("outb %%al, $0x21" : : "a"(4));
    asm!("outb %%al, $0xA1" : : "a"(2));
    asm!("outb %%al, $0x21" : : "a"(1));
    asm!("outb %%al, $0xA1" : : "a"(1));
    asm!("outb %%al, $0x21" : : "a"(255));
    asm!("outb %%al, $0xA1" : : "a"(255));
  }
  unsafe { asm!("sti"); }
  serial_putc(83);  // S (sti done)

  // Enter ring 3 via IRET
  // Build IRET frame: SS, ESP, EFLAGS, CS, EIP
  let user_addr: u32 = 0;
  unsafe { asm!("mov $user_task, %0" : "=a"(user_addr)); }
  serial_putc(85);  // U (before iret)
  unsafe {
    asm!("push $0x23; push $0x78000; pushf; push $0x1B; push %0; iret" : : "a"(user_addr) : "memory");
  }
  // Returns here after user_task exits (via syscall 99 → kmain continues)
  serial_putc(33);  // !
  serial_putc(10);
  return 0;
}

#[used]
function user_task(): void {
  // Running in ring 3!
  unsafe { asm!("movl $1, %%eax; movl $85, %%ebx; int $0x80" : : : "eax", "ebx", "ecx", "memory"); }
  unsafe { asm!("movl $2, %%eax; movl $15, %%ebx; movl $27, %%ecx; int $0x80" : : : "eax", "ebx", "ecx", "memory"); }
  unsafe { asm!("movl $1, %%eax; movl $52, %%ebx; int $0x80" : : : "eax", "ebx", "ecx", "memory"); }
  unsafe { asm!("movl $1, %%eax; movl $50, %%ebx; int $0x80" : : : "eax", "ebx", "ecx", "memory"); }
  // Exit: return to kernel via int 0x80 with eax=99
  unsafe { asm!("movl $99, %%eax; int $0x80" : : : "eax", "ebx", "ecx", "memory"); }
  unsafe { asm!("1: jmp 1b"); }
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x90000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
