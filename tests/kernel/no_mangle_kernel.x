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

function serial_putint(n: i32): void {
  if (n >= 10) {
    serial_putint(n / 10);
  }
  serial_putc((n % 10 + 48) as u8);
}

#[no_mangle]
function compute_value(a: i32, b: i32): i32 {
  return a * 100 + b;
}

#[link_name("asm_multiply")]
extern function asm_mul(a: i32, b: i32): i32;

function kmain(): i32 {
  serial_putc(78);
  serial_putc(58);
  let r1: i32 = compute_value(3, 7);
  let r2: i32 = asm_mul(6, 8);
  serial_putint(r1);
  serial_putc(44);
  serial_putint(r2);
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
