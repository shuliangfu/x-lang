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

let lock: u32 = 0;
let shared_counter: u32 = 0;

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

function kmain(): i32 {
  serial_putc(76);
  serial_putc(58);
  let lock_addr: *volatile u32 = (&lock) as *volatile u32;
  spinlock_acquire(lock_addr);
  let counter_addr: *volatile u32 = (&shared_counter) as *volatile u32;
  let i: u32 = 0;
  while (i < 100) {
    shared_counter = shared_counter + 1;
    i = i + 1;
  }
  spinlock_release(lock_addr);
  serial_putint(shared_counter as i32);
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
