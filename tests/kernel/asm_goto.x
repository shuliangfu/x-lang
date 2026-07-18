// label (asm goto) — test asm goto! with label jump in QEMU.
// asm goto!("jmp %l[skip]" : : : "memory" : skip) jumps over x=99 to the
// codegen-emitted C label "skip:", then continues with x=42.

#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }
#[link_section(".boot")]
const mb1: MB1Header = { magic: 0x1BADB002, flags: 0, checksum: 0xE4524FFE, };

/** Internal function `serial_putc`.
 * Implements `serial_putc`.
 * @param c u8
 * @return void
 */
function serial_putc(c: u8): void {
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
}
/** Internal function `serial_putint`.
 * Implements `serial_putint`.
 * @param n i32
 * @return void
 */
function serial_putint(n: i32): void {
  if (n >= 10) { serial_putint(n / 10); }
  serial_putc((n % 10 + 48) as u8);
}

/** Internal function `kmain`.
 * Implements `kmain`.
 * @return i32
 */
function kmain(): i32 {
  let x: i32 = 1;
  unsafe {
    asm goto!("jmp %l[skip]" : : : "memory" : skip);
  }
  x = 99;
  serial_putc(71);
  serial_putc(58);
  serial_putint(x);
  serial_putc(10);
  return 0;
}

#[entry]
/** Internal function `start`.
 * Implements `start`.
 * @return void
 */
function start(): void {
  unsafe { asm!("cld; mov $__bss_start, %edi; mov $__bss_end, %ecx; sub %edi, %ecx; xor %eax, %eax; rep stosb; mov $__stack_top, %esp; call kmain; cli; hlt"); }
}
/** Internal function `main`.
 * Program/test entry point.
 * @param ) i32 { return kmain(
 * @return void
 */
function main(): i32 { return kmain() + mb1.magic as i32; }
