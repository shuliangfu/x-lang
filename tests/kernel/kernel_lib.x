// A5: std.kernel.* framework library — reusable kernel utilities.
// Include this file at the top of your kernel .x (before kmain).
// All functions use #[used] or are called directly (not DCE'd).

// === Serial I/O (COM1 @ 0x3F8) ===

function serial_putc(c: u8): void {
  unsafe {
    asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8));
  }
}

function serial_putint(n: i32): void {
  if (n < 0) {
    serial_putc(45);
    n = 0 - n;
  }
  if (n >= 10) {
    serial_putint(n / 10);
  }
  serial_putc((n % 10 + 48) as u8);
}

function serial_puthex(n: u32): void {
  let i: i32 = 28;
  while (i >= 0) {
    let nibble: u32 = (n >> i) & 15;
    if (nibble < 10) {
      serial_putc((nibble + 48) as u8);
    } else {
      serial_putc((nibble + 55) as u8);
    }
    i = i - 4;
  }
}

function serial_puts_count(count: i32): void {
  serial_putc(80);
  serial_putc(65);
  serial_putc(78);
  serial_putc(73);
  serial_putc(67);
  serial_putc(58);
  serial_putc(32);
  if (count >= 10) {
    serial_putc((count / 10 + 48) as u8);
  }
  serial_putc((count % 10 + 48) as u8);
  serial_putc(10);
}

// === Atomics ===

function atomic_fetch_add_u32(addr: *volatile u32, val: u32): u32 {
  unsafe {
    asm!("lock xadd %0, (%1)" : "+a"(val) : "r"(addr) : "memory", "cc");
  }
  return val;
}

function atomic_cas_u32(addr: *volatile u32, expected: u32, newval: u32): u32 {
  let prev: u32 = expected;
  unsafe {
    asm!("lock cmpxchg %2, (%1)" : "+a"(prev) : "r"(addr), "r"(newval) : "memory", "cc");
  }
  return prev;
}

// === Spinlock ===

function spinlock_acquire(lock_addr: *volatile u32): void {
  let old: u32 = 1;
  while (old != 0) {
    old = 1;
    unsafe {
      asm!("xchg %0, (%1)" : "+a"(old) : "r"(lock_addr) : "memory");
    }
  }
}

function spinlock_release(lock_addr: *volatile u32): void {
  let zero: u32 = 0;
  unsafe {
    asm!("xchg %0, (%1)" : "+a"(zero) : "r"(lock_addr) : "memory");
  }
}

// === Bump allocator ===

let heap_ptr: u32 = 0x200000;

function kalloc(size: u32): u32 {
  if (heap_ptr == 0) {
    heap_ptr = 0x200000;
  }
  let addr: u32 = heap_ptr;
  heap_ptr = heap_ptr + size;
  return addr;
}

// === IDT setup ===

function idt_set_entry(index: u32, handler_addr: u32, selector: u16, flags: u8): void {
  let base: u32 = 0x90000 + index * 8;
  let off_lo: *volatile u16 = base as *volatile u16;
  unsafe { *off_lo = (handler_addr & 65535) as u16; }
  let sel: *volatile u16 = (base + 2) as *volatile u16;
  unsafe { *sel = selector; }
  let zero: *volatile u8 = (base + 4) as *volatile u8;
  unsafe { *zero = 0; }
  let fl: *volatile u8 = (base + 5) as *volatile u8;
  unsafe { *fl = flags; }
  let off_hi: *volatile u16 = (base + 6) as *volatile u16;
  unsafe { *off_hi = (handler_addr >> 16) as u16; }
}

function idt_load(): void {
  let idt_limit: *volatile u16 = 0x8F000 as *volatile u16;
  unsafe { *idt_limit = 2047; }
  let idt_base: *volatile u32 = 0x8F002 as *volatile u32;
  unsafe { *idt_base = 0x90000; }
  unsafe { asm!("lidt 0x8F000"); }
}

// === PIC remap ===

function pic_remap(): void {
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
}

function pic_eoi(): void {
  unsafe {
    asm!("movb $0x20, %al; outb %al, $0x20");
  }
}

// === PIT programming ===

function pit_init(): void {
  unsafe {
    asm!("outb %%al, $0x43" : : "a"(54));
    asm!("outb %%al, $0x40" : : "a"(255));
    asm!("outb %%al, $0x40" : : "a"(255));
  }
}

// === Multiboot1 header ===

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
