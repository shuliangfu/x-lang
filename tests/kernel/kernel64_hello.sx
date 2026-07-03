// x86_64 QEMU boot — 64-bit kernel that outputs via serial after long mode switch.
// boot64.s handles 32-bit PVH entry -> long mode -> _start64 -> call kmain.

#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }
#[link_section(".boot")]
const mb1: MB1Header = { magic: 0x1BADB002, flags: 0, checksum: 0xE4524FFE, };

function serial_putc(c: u8): void {
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
}
function serial_putint(n: i32): void {
  if (n < 0) { serial_putc(45); n = 0 - n; }
  if (n >= 10) { serial_putint(n / 10); }
  serial_putc((n % 10 + 48) as u8);
}

// kmain must be externally visible (called from boot64.s _start64)
#[used]
function kmain(): i32 {
  serial_putc(81);
  serial_putc(58);
  let sp: u64 = 0;
  unsafe { asm!("mov %%rsp, %0" : "=r"(sp)); }
  serial_putint((sp & 0xFFFF) as i32);
  serial_putc(10);
  return 0;
}

function main(): i32 { return kmain() + mb1.magic as i32; }
