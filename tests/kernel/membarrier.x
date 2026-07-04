// A2: Memory ordering model — mfence/lfence/sfence barriers via asm!
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
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
}
function serial_putint(n: i32): void {
  if (n >= 10) { serial_putint(n / 10); }
  serial_putc((n % 10 + 48) as u8);
}

let data_a: u32 = 0;
let data_b: u32 = 0;

function kmain(): i32 {
  serial_putc(77);
  serial_putc(58);
  data_a = 10;
  unsafe { asm!("sfence"); }
  data_b = 20;
  unsafe { asm!("mfence"); }
  let a: u32 = data_a;
  unsafe { asm!("lfence"); }
  let b: u32 = data_b;
  serial_putint(a as i32);
  serial_putc(44);
  serial_putint(b as i32);
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
