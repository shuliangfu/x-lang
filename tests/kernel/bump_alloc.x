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

let heap_ptr: u32 = 0x200000;

function kalloc(size: u32): u32 {
  let addr: u32 = heap_ptr;
  heap_ptr = heap_ptr + size;
  return addr;
}

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

#[entry]
function start(): void {
  unsafe {
    asm!("mov $0x80000, %esp; call kmain; cli; hlt");
  }
}

function main(): i32 { return kmain() + mb1.magic as i32; }
