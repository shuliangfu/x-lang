// K5e: clear .bss + global stack — _start zeroes .bss (__bss_start→__bss_end)
// then sets esp to __stack_top (linker-defined 16KB stack in .bss area).

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
  if (n < 0) {
    serial_putc(45);
    n = 0 - n;
  }
  if (n >= 10) {
    serial_putint(n / 10);
  }
  serial_putc((n % 10 + 48) as u8);
}

// Zero-initialized global — C compiler puts in .bss; _start must clear it.
let bss_test_var: u32 = 0;

function kmain(): i32 {
  serial_putc(66);
  serial_putc(58);
  serial_putint(bss_test_var as i32);
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe {
    asm!("cld; mov $__bss_start, %edi; mov $__bss_end, %ecx; sub %edi, %ecx; xor %eax, %eax; rep stosb; mov $__stack_top, %esp; call kmain; cli; hlt");
  }
}

function main(): i32 { return kmain() + mb1.magic as i32; }
