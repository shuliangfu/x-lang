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

/** Internal function `serial_putc`.
 * Implements `serial_putc`.
 * @param c u8
 * @return void
 */
function serial_putc(c: u8): void {
  unsafe {
    asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8));
  }
}

/** Internal function `serial_putint`.
 * Implements `serial_putint`.
 * @param n i32
 * @return void
 */
function serial_putint(n: i32): void {
  if (n >= 10) {
    serial_putint(n / 10);
  }
  serial_putc((n % 10 + 48) as u8);
}

/** Internal function `atomic_fetch_add_u32`.
 * Implements `atomic_fetch_add_u32`.
 * @param addr *volatile u32
 * @param val u32
 * @return u32
 */
function atomic_fetch_add_u32(addr: *volatile u32, val: u32): u32 {
  unsafe {
    asm!("lock xadd %0, (%1)" : "+a"(val) : "r"(addr) : "memory", "cc");
  }
  return val;
}

/** Internal function `atomic_cas_u32`.
 * Implements `atomic_cas_u32`.
 * @param addr *volatile u32
 * @param expected u32
 * @param newval u32
 * @return u32
 */
function atomic_cas_u32(addr: *volatile u32, expected: u32, newval: u32): u32 {
  let prev: u32 = expected;
  unsafe {
    asm!("lock cmpxchg %2, (%1)" : "+a"(prev) : "r"(addr), "r"(newval) : "memory", "cc");
  }
  return prev;
}

/** Internal function `kmain`.
 * Implements `kmain`.
 * @return i32
 */
function kmain(): i32 {
  let counter: u32 = 0;
  let counter_addr: *volatile u32 = (&counter) as *volatile u32;
  let r1: u32 = atomic_fetch_add_u32(counter_addr, 5);
  serial_putc(65);
  serial_putc(58);
  serial_putint(r1 as i32);
  serial_putc(44);
  serial_putint(counter as i32);
  serial_putc(10);
  let r2: u32 = atomic_cas_u32(counter_addr, 5, 10);
  serial_putc(67);
  serial_putc(58);
  serial_putint(r2 as i32);
  serial_putc(44);
  serial_putint(counter as i32);
  serial_putc(10);
  return 0;
}

/** Internal function `start`.
 * Implements `start`.
 * @return void
 */
#[entry]
function start(): void {
  unsafe {
    asm!("mov $0x80000, %esp; call kmain; cli; hlt");
  }
}

/** Internal function `main`.
 * Program/test entry point.
 * @param ) i32 { return kmain(
 * @return void
 */
function main(): i32 { return kmain() + mb1.magic as i32; }
