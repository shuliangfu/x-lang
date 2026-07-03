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

let data_var: u32 = 42;

function kmain(): i32 {
  serial_putc(75);
  serial_putc(58);
  let val: u32 = data_var;
  if (val >= 10) {
    serial_putc((val / 10 + 48) as u8);
  }
  serial_putc((val % 10 + 48) as u8);
  serial_putc(10);
  return 0;
}

function main(): i32 { return kmain() + mb1.magic as i32; }
