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
  unsafe {
    asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8));
  }
}

function serial_putint(n: i32): void {
  if (n >= 10) {
    serial_putint(n / 10);
  }
  serial_putc((n % 10 + 48) as u8);
}

let tick_count: u32 = 0;

#[interrupt]
function timer_handler(): void {
  tick_count = tick_count + 1;
  unsafe {
    asm!("movb $0x20, %al; outb %al, $0x20");
  }
}

function kmain(): i32 {
  serial_putc(73);
  serial_putc(58);
  let handler_addr: u32 = 0;
  unsafe {
    asm!("mov $timer_handler, %0" : "=a"(handler_addr));
  }
  let idt_off_lo: *volatile u16 = (0x90000 + 32 * 8) as *volatile u16;
  unsafe { *idt_off_lo = (handler_addr & 65535) as u16; }
  let idt_sel: *volatile u16 = (0x90000 + 32 * 8 + 2) as *volatile u16;
  unsafe { *idt_sel = 8; }
  let idt_zero: *volatile u8 = (0x90000 + 32 * 8 + 4) as *volatile u8;
  unsafe { *idt_zero = 0; }
  let idt_flags: *volatile u8 = (0x90000 + 32 * 8 + 5) as *volatile u8;
  unsafe { *idt_flags = 142; }
  let idt_off_hi: *volatile u16 = (0x90000 + 32 * 8 + 6) as *volatile u16;
  unsafe { *idt_off_hi = (handler_addr >> 16) as u16; }
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
    asm!("outb %%al, $0x21" : : "a"(254));
    asm!("outb %%al, $0xA1" : : "a"(255));
  }
  unsafe {
    asm!("outb %%al, $0x43" : : "a"(54));
    asm!("outb %%al, $0x40" : : "a"(255));
    asm!("outb %%al, $0x40" : : "a"(255));
  }
  unsafe { asm!("sti"); }
  let wait: i32 = 0;
  while (wait < 2000000) {
    wait = wait + 1;
  }
  let ticks: u32 = 0;
  unsafe { asm!("movl tick_count, %0" : "=a"(ticks)); }
  serial_putint(ticks as i32);
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe {
    asm!("mov $0x80000, %esp; call kmain; cli; hlt");
  }
}

function main(): i32 { return kmain() + mb1.magic as i32; }
