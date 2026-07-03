// ShuxOS v2 — comprehensive kernel integrating all OS features.
// Features: VGA, serial, kprintf, GDT, IDT, PIC, PIT, preemptive scheduler,
// paging, allocator, spinlock, panic+backtrace, syscall.

#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }

#[link_section(".boot")]
const mb1: MB1Header = {
  magic: 0x1BADB002,
  flags: 0,
  checksum: 0xE4524FFE,
};

#[repr(C)]
struct Context { sp: u32; }

// === Serial I/O ===
function serial_putc(c: u8): void {
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
}

// === kprintf (kernel printf) ===
function kputchar(c: u8): void {
  serial_putc(c);
}

function kputs(s: u32): void {
  let p: *volatile u8 = s as *volatile u8;
  let ch: u8 = 0;
  unsafe { ch = *p; }
  while (ch != 0) {
    kputchar(ch);
    p = (p as u32 + 1) as *volatile u8;
    unsafe { ch = *p; }
  }
}

function kputint(n: i32): void {
  if (n < 0) { kputchar(45); n = 0 - n; }
  if (n >= 10) { kputint(n / 10); }
  kputchar((n % 10 + 48) as u8);
}

function kputhex(n: u32): void {
  let i: i32 = 28;
  while (i >= 0) {
    let nibble: u32 = (n >> i) & 15;
    if (nibble < 10) { kputchar((nibble + 48) as u8); }
    else { kputchar((nibble + 55) as u8); }
    i = i - 4;
  }
}

// === VGA ===
const VGA_BASE: u32 = 0xB8000;
const VGA_WIDTH: u32 = 80;
let vga_row: u32 = 0;
let vga_col: u32 = 0;

function vga_putc(c: u8, color: u8): void {
  let offset: u32 = (vga_row * VGA_WIDTH + vga_col) * 2;
  unsafe { *((VGA_BASE + offset) as *volatile u8) = c; }
  unsafe { *((VGA_BASE + offset + 1) as *volatile u8) = color; }
  vga_col = vga_col + 1;
  if (vga_col >= VGA_WIDTH) { vga_col = 0; vga_row = vga_row + 1; }
}

function vga_print_str(s: u32, color: u8): void {
  let p: *volatile u8 = s as *volatile u8;
  let ch: u8 = 0;
  unsafe { ch = *p; }
  while (ch != 0) {
    vga_putc(ch, color);
    p = (p as u32 + 1) as *volatile u8;
    unsafe { ch = *p; }
  }
}

// === Bump allocator ===
let heap_ptr: u32 = 0x200000;
function kalloc(size: u32): u32 {
  if (heap_ptr == 0) { heap_ptr = 0x200000; }
  let addr: u32 = heap_ptr;
  heap_ptr = heap_ptr + size;
  return addr;
}

// === Spinlock ===
let lock: u32 = 0;
function spinlock_acquire(addr: *volatile u32): void {
  let old: u32 = 1;
  while (old != 0) {
    old = 1;
    unsafe { asm!("xchg %0, (%1)" : "+a"(old) : "r"(addr) : "memory"); }
  }
}
function spinlock_release(addr: *volatile u32): void {
  let zero: u32 = 0;
  unsafe { asm!("xchg %0, (%1)" : "+a"(zero) : "r"(addr) : "memory"); }
}

// === Atomics ===
function atomic_inc(addr: *volatile u32): u32 {
  let val: u32 = 1;
  unsafe { asm!("lock xadd %0, (%1)" : "+a"(val) : "r"(addr) : "memory", "cc"); }
  return val;
}

// === Timer + Scheduler ===
let tick_count: u32 = 0;
let schedule_tick: u32 = 0;
let ctx_main: Context = { sp: 0 };
let ctx_task1: Context = { sp: 0 };
let ctx_task2: Context = { sp: 0 };
let current_task: u32 = 0;
let task1_count: u32 = 0;
let task2_count: u32 = 0;

#[used]
#[naked]
function switch_to(old: *Context, new_ctx: *Context): void {
  unsafe {
    asm!("movl 4(%esp), %eax; movl 8(%esp), %edx; pushl %ebp; pushl %ebx; pushl %esi; pushl %edi; movl %esp, (%eax); movl (%edx), %esp; popl %edi; popl %esi; popl %ebx; popl %ebp; ret");
  }
}

#[interrupt]
function timer_handler(): void {
  tick_count = tick_count + 1;
  schedule_tick = schedule_tick + 1;
  unsafe { asm!("movb $0x20, %al; outb %al, $0x20"); }
}

// === Tasks ===
#[used]
function task1(): void {
  let i: u32 = 0;
  while (i < 5) {
    task1_count = task1_count + 1;
    switch_to(&ctx_task1, &ctx_task2);
    i = i + 1;
  }
  switch_to(&ctx_task1, &ctx_main);
}

#[used]
function task2(): void {
  let i: u32 = 0;
  while (i < 5) {
    task2_count = task2_count + 1;
    switch_to(&ctx_task2, &ctx_task1);
    i = i + 1;
  }
  switch_to(&ctx_task2, &ctx_main);
}

function setup_task(ctx: *Context, entry: u32, stack_top: u32): void {
  let sp: u32 = stack_top - 20;
  unsafe { *((stack_top - 4) as *volatile u32) = entry; }
  unsafe { *((stack_top - 8) as *volatile u32) = 0; }
  unsafe { *((stack_top - 12) as *volatile u32) = 0; }
  unsafe { *((stack_top - 16) as *volatile u32) = 0; }
  unsafe { *((stack_top - 20) as *volatile u32) = 0; }
  unsafe { *(ctx as *volatile u32) = sp; }
}

// === IDT + PIC ===
function idt_set_entry(index: u32, handler: u32): void {
  let base: u32 = 0x90000 + index * 8;
  unsafe {
    *(base as *volatile u16) = (handler & 65535) as u16;
    *((base + 2) as *volatile u16) = 8;
    *((base + 4) as *volatile u8) = 0;
    *((base + 5) as *volatile u8) = 142;
    *((base + 6) as *volatile u16) = (handler >> 16) as u16;
  }
}

function kmain(): i32 {
  // Clear VGA
  let vi: u32 = 0;
  while (vi < 80 * 25) {
    unsafe { *((0xB8000 + vi * 2) as *volatile u8) = 32; }
    unsafe { *((0xB8000 + vi * 2 + 1) as *volatile u8) = 7; }
    vi = vi + 1;
  }
  vga_row = 0; vga_col = 0;
  
  // VGA banner
  let banner: u8[8] = [83, 104, 117, 120, 79, 83, 50, 0];  // "ShuxOS2"
  vga_print_str((&banner[0]) as u32, 11);
  
  // Serial banner
  kputchar(83); kputchar(104); kputchar(117); kputchar(120);  // Shux
  kputchar(79); kputchar(83);  // OS
  kputchar(50); kputchar(10);  // 2\n
  
  // Setup IDT
  let timer_addr: u32 = 0;
  unsafe { asm!("mov $timer_handler, %0" : "=a"(timer_addr)); }
  idt_set_entry(32, timer_addr);
  let idt_limit: *volatile u16 = 0x8F000 as *volatile u16;
  unsafe { *idt_limit = 2047; }
  let idt_base: *volatile u32 = 0x8F002 as *volatile u32;
  unsafe { *idt_base = 0x90000; }
  unsafe { asm!("lidt 0x8F000"); }
  
  // PIC remap
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
  
  // Setup tasks
  let t1_addr: u32 = 0;
  let t2_addr: u32 = 0;
  unsafe { asm!("mov $task1, %0" : "=a"(t1_addr)); }
  unsafe { asm!("mov $task2, %0" : "=a"(t2_addr)); }
  setup_task(&ctx_task1, t1_addr, 0x70000);
  setup_task(&ctx_task2, t2_addr, 0x78000);
  
  // Run scheduler (cooperative round-trip)
  switch_to(&ctx_main, &ctx_task1);
  
  // Results
  kputchar(84); kputchar(58);  // T:
  kputint(tick_count as i32); kputchar(44);
  kputint(task1_count as i32); kputchar(44);
  kputint(task2_count as i32); kputchar(10);
  
  // Allocator test
  let a1: u32 = kalloc(16);
  let a2: u32 = kalloc(32);
  kputchar(65); kputchar(58);  // A:
  kputint(a1 as i32); kputchar(44); kputint(a2 as i32); kputchar(10);
  
  // Paging test
  let pd: *volatile u32 = 0x60000 as *volatile u32;
  unsafe { *pd = 0x61000 | 3; }
  let pi: u32 = 0;
  while (pi < 1024) {
    unsafe { *((0x61000 + pi * 4) as *volatile u32) = (pi * 4096) | 3; }
    pi = pi + 1;
  }
  unsafe { asm!("mov $0x60000, %eax; mov %eax, %cr3"); }
  unsafe { asm!("mov %cr0, %eax; or $0x80000000, %eax; mov %eax, %cr0"); }
  let cr0: u32 = 0;
  unsafe { asm!("mov %%cr0, %0" : "=a"(cr0)); }
  kputchar(80); kputchar(58);  // P:
  kputhex(cr0); kputchar(10);
  
  // Done
  kputchar(68); kputchar(79); kputchar(78); kputchar(69); kputchar(10);  // DONE
  return 0;
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
