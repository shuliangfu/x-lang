// G1: Host unit test — kernel logic testable on host without QEMU.
// This module computes IDT entry values and multiboot checksums.
// Compile for host (not freestanding) to run as a normal test.

/** Internal function `idt_entry_lo`.
 * Implements `idt_entry_lo`.
 * @param handler u32
 * @return u16
 */
function idt_entry_lo(handler: u32): u16 {
  return (handler & 65535) as u16;
}

/** Internal function `idt_entry_hi`.
 * Implements `idt_entry_hi`.
 * @param handler u32
 * @return u16
 */
function idt_entry_hi(handler: u32): u16 {
  return (handler >> 16) as u16;
}

/** Internal function `mb1_checksum`.
 * Implements `mb1_checksum`.
 * @param magic u32
 * @param flags u32
 * @return u32
 */
function mb1_checksum(magic: u32, flags: u32) : u32 {
  return 0 - (magic + flags);
}

/** Internal function `sum_range`.
 * Implements `sum_range`.
 * @param lo i32
 * @param hi i32
 * @return i32
 */
function sum_range(lo: i32, hi: i32): i32 {
  let total: i32 = 0;
  let i: i32 = lo;
  while (i <= hi) {
    total = total + i;
    i = i + 1;
  }
  return total;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let errors: i32 = 0;
  let cs: u32 = mb1_checksum(0x1BADB002, 0);
  if (cs != 0xE4524FFE) {
    errors = errors + 1;
  }
  let lo: u16 = idt_entry_lo(0x12345678);
  if (lo != 0x5678) {
    errors = errors + 1;
  }
  let hi: u16 = idt_entry_hi(0x12345678);
  if (hi != 0x1234) {
    errors = errors + 1;
  }
  let s: i32 = sum_range(1, 100);
  if (s != 5050) {
    errors = errors + 1;
  }
  return errors;
}
