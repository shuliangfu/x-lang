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

let heap_ptr: u32 = 0x200000;

/** Internal function `kalloc`.
 * Memory management helper `kalloc`.
 * @param size u32
 * @return u32
 */
function kalloc(size: u32): u32 {
  let addr: u32 = heap_ptr;
  heap_ptr = heap_ptr + size;
  return addr;
}

/** Internal function `kmain`.
 * Implements `kmain`.
 * @return i32
 */
function kmain(): i32 {
  serial_putc(75);
  serial_putc(58);
  let a: u32 = kalloc(16);
  let b: u32 = kalloc(32);
  serial_putint(a as i32);
  serial_putc(44);
  serial_putint(b as i32);
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
