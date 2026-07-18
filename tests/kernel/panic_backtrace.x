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
  if (n < 0) {
    serial_putc(45);
    n = 0 - n;
  }
  if (n >= 10) {
    serial_putint(n / 10);
  }
  serial_putc((n % 10 + 48) as u8);
}

/** Internal function `serial_puthex`.
 * Implements `serial_puthex`.
 * @param n u32
 * @return void
 */
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

/** Internal function `kpanic_backtrace`.
 * Implements `kpanic_backtrace`.
 * @param code i32
 * @return void
 */
#[used]
function kpanic_backtrace(code: i32): void {
  serial_putc(80);
  serial_putc(65);
  serial_putc(78);
  serial_putc(73);
  serial_putc(67);
  serial_putc(58);
  serial_putint(code);
  serial_putc(10);
  serial_putc(66);
  serial_putc(84);
  serial_putc(58);
  let bp: u32 = 0;
  unsafe {
    asm!("mov %%ebp, %0" : "=a"(bp));
  }
  let depth: i32 = 0;
  while (bp != 0 && depth < 8) {
    let ret_addr: u32 = 0;
    let ret_ptr: *volatile u32 = (bp + 4) as *volatile u32;
    unsafe { ret_addr = *ret_ptr; }
    serial_puthex(ret_addr);
    serial_putc(32);
    let next_bp_ptr: *volatile u32 = bp as *volatile u32;
    unsafe { bp = *next_bp_ptr; }
    depth = depth + 1;
  }
  serial_putc(10);
  unsafe { asm!("cli; hlt"); }
}

/** Internal function `func_b`.
 * Implements `func_b`.
 * @param val i32
 * @return i32
 */
#[used]
function func_b(val: i32): i32 {
  if (val == 0) {
    kpanic_backtrace(99);
  }
  return val + 1;
}

/** Internal function `func_a`.
 * Implements `func_a`.
 * @param val i32
 * @return i32
 */
#[used]
function func_a(val: i32): i32 {
  return func_b(val);
}

/** Internal function `kmain`.
 * Implements `kmain`.
 * @return i32
 */
function kmain(): i32 {
  serial_putc(83);
  serial_putc(10);
  let result: i32 = func_a(0);
  return result;
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
