// A5: std.kernel.* showcase — demonstrates all reusable kernel utilities
// working together in a single kernel: serial, IDT, PIC, PIT, interrupt,
// spinlock, allocator, backtrace.

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

// === Serial I/O ===
function serial_putc(c: u8): void {
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
}
function serial_putint(n: i32): void {
  if (n >= 10) { serial_putint(n / 10); }
  serial_putc((n % 10 + 48) as u8);
}

// === Atomics ===
function atomic_fetch_add_u32(addr: *volatile u32, val: u32): u32 {
  unsafe { asm!("lock xadd %0, (%1)" : "+a"(val) : "r"(addr) : "memory", "cc"); }
  return val;
}

// === Spinlock ===
let lock: u32 = 0;
function spinlock_acquire(lock_addr: *volatile u32): void {
  let old: u32 = 1;
  while (old != 0) {
    old = 1;
    unsafe { asm!("xchg %0, (%1)" : "+a"(old) : "r"(lock_addr) : "memory"); }
  }
}
function spinlock_release(lock_addr: *volatile u32): void {
  let zero: u32 = 0;
  unsafe { asm!("xchg %0, (%1)" : "+a"(zero) : "r"(lock_addr) : "memory"); }
}

// === Bump allocator ===
let heap_ptr: u32 = 0x200000;
function kalloc(size: u32): u32 {
  if (heap_ptr == 0) { heap_ptr = 0x200000; }
  let addr: u32 = heap_ptr;
  heap_ptr = heap_ptr + size;
  return addr;
}

// === IDT + PIC + PIT ===
let tick_count: u32 = 0;

#[interrupt]
function timer_handler(): void {
  tick_count = tick_count + 1;
  unsafe { asm!("movb $0x20, %al; outb %al, $0x20"); }
}

function idt_set_entry(index: u32, handler_addr: u32): void {
  let base: u32 = 0x90000 + index * 8;
  let off_lo: *volatile u16 = base as *volatile u16;
  unsafe { *off_lo = (handler_addr & 65535) as u16; }
  let sel: *volatile u16 = (base + 2) as *volatile u16;
  unsafe { *sel = 8; }
  let zero: *volatile u8 = (base + 4) as *volatile u8;
  unsafe { *zero = 0; }
  let flags: *volatile u8 = (base + 5) as *volatile u8;
  unsafe { *flags = 142; }
  let off_hi: *volatile u16 = (base + 6) as *volatile u16;
  unsafe { *off_hi = (handler_addr >> 16) as u16; }
}

function kmain(): i32 {
  serial_putc(75);
  serial_putc(58);
  // Spinlock test
  let lock_addr: *volatile u32 = (&lock) as *volatile u32;
  spinlock_acquire(lock_addr);
  let counter_addr: *volatile u32 = (&tick_count) as *volatile u32;
  let i: u32 = 0;
  while (i < 50) {
    atomic_fetch_add_u32(counter_addr, 0);
    i = i + 1;
  }
  spinlock_release(lock_addr);
  // Allocator test
  let a1: u32 = kalloc(16);
  // IDT + PIC + PIT
  let handler_addr: u32 = 0;
  unsafe { asm!("mov $timer_handler, %0" : "=a"(handler_addr)); }
  idt_set_entry(32, handler_addr);
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
    asm!("outb %%al, $0x43" : : "a"(54));
    asm!("outb %%al, $0x40" : : "a"(255));
    asm!("outb %%al, $0x40" : : "a"(255));
  }
  unsafe { asm!("sti"); }
  let wait: i32 = 0;
  while (wait < 2000000) { wait = wait + 1; }
  serial_putint(tick_count as i32);
  serial_putc(44);
  serial_putint(a1 as i32);
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
