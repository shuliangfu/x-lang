// See implementation.
// struct PageFlags uses C bitfields for page table entry bits.

#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }
#[link_section(".boot")]
const mb1: MB1Header = { magic: 0x1BADB002, flags: 0, checksum: 0xE4524FFE, };

/** Internal function `serial_putc`.
 * Implements `serial_putc`.
 * @param c u8): void { unsafe { asm!("outb %%al
 * @param %%dx" : "a"(c)
 * @param "d"(0x3F8)
 * @return void
 */
function serial_putc(c: u8): void { unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); } }
/** Internal function `serial_putint`.
 * Implements `serial_putint`.
 * @param n i32): void { if (n >= 10) { serial_putint(n / 10); } serial_putc((n % 10 + 48) as u8
 * @return void
 */
function serial_putint(n: i32): void { if (n >= 10) { serial_putint(n / 10); } serial_putc((n % 10 + 48) as u8); }

#[repr(C)]
struct PageFlags {
  present: u32 : 1;
  writable: u32 : 1;
  user: u32 : 1;
  write_through: u32 : 1;
  cache_disable: u32 : 1;
  accessed: u32 : 1;
  dirty: u32 : 1;
  pat: u32 : 1;
  global: u32 : 1;
  avail: u32 : 3;
  addr: u32 : 20;
}

// Force struct emission by using it in a function signature
/** Internal function `read_pte`.
 * Read path helper `read_pte`.
 * @param pte PageFlags
 * @return i32
 */
function read_pte(pte: PageFlags): i32 {
  return pte.present as i32 + pte.writable as i32;
}

/** Internal function `kmain`.
 * Implements `kmain`.
 * @return i32
 */
function kmain(): i32 {
  let pte: PageFlags = { present: 1, writable: 1, user: 0, write_through: 0, cache_disable: 0, accessed: 0, dirty: 0, pat: 0, global: 0, avail: 0, addr: 0x1000 };
  serial_putc(70);
  serial_putc(58);
  serial_putint(read_pte(pte));
  serial_putc(44);
  serial_putint((pte.addr & 0xFFFF) as i32);
  serial_putc(10);
  return 0;
}

/** Internal function `start`.
 * Implements `start`.
 * @return void
 */
#[entry]
function start(): void {
  unsafe { asm!("cld; mov $__bss_start, %edi; mov $__bss_end, %ecx; sub %edi, %ecx; xor %eax, %eax; rep stosb; mov $__stack_top, %esp; call kmain; cli; hlt"); }
}
/** Internal function `main`.
 * Program/test entry point.
 * @param ) i32 { return kmain(
 * @return void
 */
function main(): i32 { return kmain() + mb1.magic as i32; }
