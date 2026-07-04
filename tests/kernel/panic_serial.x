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

function serial_puts_count(count: i32): void {
  serial_putc(80);
  serial_putc(65);
  serial_putc(78);
  serial_putc(73);
  serial_putc(67);
  serial_putc(58);
  serial_putc(32);
  if (count >= 10) {
    serial_putc((count / 10 + 48) as u8);
  }
  serial_putc((count % 10 + 48) as u8);
  serial_putc(10);
}

#[used]
function kpanic(code: i32): void {
  serial_puts_count(code);
  unsafe { asm!("cli; hlt"); }
}

function kmain(): i32 {
  serial_putc(83);
  serial_putc(10);
  let divisor: i32 = 0;
  let result: i32 = 0;
  if (divisor == 0) {
    kpanic(42);
  }
  result = 100 / divisor;
  serial_putc(79);
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
