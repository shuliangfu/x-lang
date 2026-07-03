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

#[repr(C)]
struct VTable {
  putc_fn: u32;
}

function serial_putc(c: u8): void {
  unsafe {
    asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8));
  }
}

#[used]
function driver_a_putc(c: u8): void {
  unsafe {
    asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8));
  }
}

#[used]
function driver_b_putc(c: u8): void {
  unsafe {
    asm!("outb %%al, %%dx" : : "a"(c), "d"(0x2F8));
  }
}

function vtable_call(vt: VTable, c: u8): void {
  let fn_addr: u32 = vt.putc_fn;
  unsafe {
    let c32: u32 = c as u32; asm!("pushl %1; call *%0; addl $4, %%esp" : : "a"(fn_addr), "b"(c32) : "memory", "cc");
  }
}

function kmain(): i32 {
  let driver_a_addr: u32 = 0;
  unsafe {
    asm!("mov $driver_a_putc, %0" : "=a"(driver_a_addr));
  }
  let vt_a: VTable = { putc_fn: driver_a_addr };
  vtable_call(vt_a, 86);
  vtable_call(vt_a, 84);
  vtable_call(vt_a, 10);
  return 0;
}

#[entry]
function start(): void {
  unsafe {
    asm!("mov $0x80000, %esp; call kmain; cli; hlt");
  }
}

function main(): i32 { return kmain() + mb1.magic as i32; }
