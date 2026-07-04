// GDT + Syscall kernel — GDT setup + naked syscall handler (int 0x80).
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

// Naked syscall handler: reads eax (syscall number) and dispatches.
// No EOI needed (software interrupt, not hardware IRQ).
#[used]
#[naked]
function syscall_handler(): void {
  unsafe {
    asm!("cmp $1, %eax; je sys_print; cmp $3, %eax; je sys_add; jmp sys_done;
          sys_print: movb %bl, %al; mov $0x3F8, %dx; outb %al, %dx; jmp sys_done;
          sys_add: add %ecx, %ebx; movl %ebx, syscall_result; jmp sys_done;
          sys_done: iret");
  }
}

let tick_count: u32 = 0;
#[interrupt]
function timer_handler(): void {
  tick_count = tick_count + 1;
  unsafe { asm!("movb $0x20, %al; outb %al, $0x20"); }
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

function gdt_init(): void {
  let gdt: *volatile u32 = 0x60000 as *volatile u32;
  unsafe { *gdt = 0; *(gdt + 1) = 0; }
  unsafe { *((0x60000 + 8) as *volatile u32) = 0x0000FFFF; }
  unsafe { *((0x60000 + 12) as *volatile u32) = 0x00CF9A00; }
  unsafe { *((0x60000 + 16) as *volatile u32) = 0x0000FFFF; }
  unsafe { *((0x60000 + 20) as *volatile u32) = 0x00CF9200; }
  let gdtr: *volatile u16 = 0x5F000 as *volatile u16;
  unsafe { *gdtr = 39; }
  let gdtr_base: *volatile u32 = 0x5F002 as *volatile u32;
  unsafe { *gdtr_base = 0x60000; }
  unsafe { asm!("lgdt 0x5F000"); }
  unsafe {
    asm!("mov $0x10, %ax; mov %ax, %ds; mov %ax, %es; mov %ax, %ss; mov %ax, %fs");
    asm!("ljmp $0x08, $1f; 1:");
  }
}

function kmain(): i32 {
  gdt_init();
  serial_putc(71);  // G
  serial_putc(58);  // :
  let timer_addr: u32 = 0;
  let syscall_addr: u32 = 0;
  unsafe {
    asm!("mov $timer_handler, %0" : "=a"(timer_addr));
    asm!("mov $syscall_handler, %0" : "=a"(syscall_addr));
  }
  idt_set_entry(32, timer_addr);
  idt_set_entry(128, syscall_addr);
  let idt_limit: *volatile u16 = 0x8F000 as *volatile u16;
  unsafe { *idt_limit = 2047; }
  let idt_base: *volatile u32 = 0x8F002 as *volatile u32;
  unsafe { *idt_base = 0x90000; }
  unsafe { asm!("lidt 0x8F000"); }
  unsafe {
    asm!("outb %%al, $0x20" : : "a"(17));
    asm!("outb %%al, $0xA0" : : "a"(17));
    asm!("outb %%al, $0x21" : : "a"(32));
    asm!("outb %%al, $0xA1" : : "a"(40));
    asm!("outb %%al, $0x21" : : "a"(4));
    asm!("outb %%al, $0xA1" : : "a"(2));
    asm!("outb %%al, $0x21" : : "a"(1));
    asm!("outb %%al, $0xA1" : : "a"(1));
    asm!("outb %%al, $0x21" : : "a"(252));
    asm!("outb %%al, $0xA1" : : "a"(255));
  }
  unsafe { asm!("sti"); }
  // Syscall 1: print 'H' (72)
  unsafe { asm!("movl $1, %%eax; movl $72, %%ebx; int $0x80" : : : "eax", "ebx", "ecx", "memory"); }
  // Syscall 3: add 10 + 20
  unsafe { asm!("movl $3, %%eax; movl $10, %%ebx; movl $20, %%ecx; int $0x80" : : : "eax", "ebx", "ecx", "memory"); }
  serial_putint(syscall_result as i32);
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x90000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
