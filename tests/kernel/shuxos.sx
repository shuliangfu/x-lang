// ShuxOS mini — interactive kernel with VGA + keyboard + timer.
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

const VGA_BASE: u32 = 0xB8000;
const VGA_WIDTH: u32 = 80;
const VGA_HEIGHT: u32 = 25;
let vga_row: u32 = 0;
let vga_col: u32 = 0;

function vga_putc(c: u8, color: u8): void {
  let offset: u32 = (vga_row * VGA_WIDTH + vga_col) * 2;
  let p: *volatile u8 = (VGA_BASE + offset) as *volatile u8;
  unsafe { *p = c; }
  let pc: *volatile u8 = (VGA_BASE + offset + 1) as *volatile u8;
  unsafe { *pc = color; }
  vga_col = vga_col + 1;
  if (vga_col >= VGA_WIDTH) { vga_col = 0; vga_row = vga_row + 1; if (vga_row >= VGA_HEIGHT) { vga_row = 0; } }
}

function vga_clear(): void {
  let i: u32 = 0;
  while (i < VGA_WIDTH * VGA_HEIGHT) {
    unsafe { *((VGA_BASE + i * 2) as *volatile u8) = 32; *((VGA_BASE + i * 2 + 1) as *volatile u8) = 7; }
    i = i + 1;
  }
  vga_row = 0;
  vga_col = 0;
}

function serial_putc(c: u8): void {
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
}
function serial_putint(n: i32): void {
  if (n >= 10) { serial_putint(n / 10); }
  serial_putc((n % 10 + 48) as u8);
}

let tick_count: u32 = 0;
let key_scan: u8 = 0;
let key_count: u32 = 0;

#[interrupt]
function timer_handler(): void {
  tick_count = tick_count + 1;
  unsafe { asm!("movb $0x20, %al; outb %al, $0x20"); }
}

#[interrupt]
function keyboard_handler(): void {
  let sc: u8 = 0;
  unsafe {
    asm!("inb $0x60, %%al" : "=a"(sc));
    key_scan = sc;
    key_count = key_count + 1;
    asm!("movb $0x20, %al; outb %al, $0x20");
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
  vga_clear();
  vga_putc(83, 11); vga_putc(104, 11); vga_putc(117, 11); vga_putc(120, 11);
  vga_putc(79, 11); vga_putc(83, 11); vga_putc(32, 7); vga_putc(118, 10);
  vga_putc(49, 10); vga_putc(46, 10); vga_putc(48, 10);
  vga_row = 2; vga_col = 0;
  serial_putc(83); serial_putc(104); serial_putc(117); serial_putc(120);
  serial_putc(79); serial_putc(83); serial_putc(10);
  let timer_addr: u32 = 0;
  let kb_addr: u32 = 0;
  unsafe {
    asm!("mov $timer_handler, %0" : "=a"(timer_addr));
    asm!("mov $keyboard_handler, %0" : "=a"(kb_addr));
  }
  idt_set_entry(32, timer_addr);
  idt_set_entry(33, kb_addr);
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
    asm!("outb %%al, $0x43" : : "a"(54));
    asm!("outb %%al, $0x40" : : "a"(255));
    asm!("outb %%al, $0x40" : : "a"(255));
  }
  unsafe { asm!("sti"); }
  let wait: i32 = 0;
  while (tick_count < 1) { wait = wait + 1; }
  serial_putc(84); serial_putc(58); serial_putint(tick_count as i32); serial_putc(10);
  serial_putc(68); serial_putc(79); serial_putc(78); serial_putc(69); serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
