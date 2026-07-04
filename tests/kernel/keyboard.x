// Keyboard scancode decoder — Set 1 (PS/2) scan code → ASCII translation.
#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }

#[link_section(".boot")]
const mb1: MB1Header = {
  magic: 0x1BADB002,
  flags: 0,
  checksum: 0xE4524FFE,
};

function serial_putc(c: u8): void {
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
}

// Keyboard table at fixed memory 0x50000 (128 bytes, zero-initialized by .bss clear)
const KBD_TABLE: u32 = 0x50000;

function kbd_set(scan: u8, ascii: u8): void {
  let p: *volatile u8 = (KBD_TABLE + scan as u32) as *volatile u8;
  unsafe { *p = ascii; }
}

function kbd_translate(scan: u8): u8 {
  if (scan >= 128) { return 0; }
  let p: *volatile u8 = (KBD_TABLE + scan as u32) as *volatile u8;
  let ch: u8 = 0;
  unsafe { ch = *p; }
  return ch;
}

function kbd_init(): void {
  kbd_set(0x1E, 97);  kbd_set(0x30, 98);  kbd_set(0x2E, 99);  kbd_set(0x20, 100);
  kbd_set(0x12, 101); kbd_set(0x23, 102); kbd_set(0x21, 103); kbd_set(0x24, 104);
  kbd_set(0x25, 105); kbd_set(0x26, 106); kbd_set(0x27, 107); kbd_set(0x28, 108);
  kbd_set(0x2C, 109); kbd_set(0x2D, 110); kbd_set(0x31, 111); kbd_set(0x18, 112);
  kbd_set(0x19, 113); kbd_set(0x10, 114); kbd_set(0x13, 115); kbd_set(0x1F, 116);
  kbd_set(0x22, 117); kbd_set(0x35, 118); kbd_set(0x1A, 119); kbd_set(0x11, 120);
  kbd_set(0x2A, 121); kbd_set(0x2B, 122);
  kbd_set(0x02, 49); kbd_set(0x03, 50); kbd_set(0x04, 51); kbd_set(0x05, 52);
  kbd_set(0x06, 53); kbd_set(0x07, 54); kbd_set(0x08, 55); kbd_set(0x09, 56);
  kbd_set(0x0A, 57); kbd_set(0x0B, 48);
  kbd_set(0x39, 32); kbd_set(0x1C, 10);
}

function kmain(): i32 {
  serial_putc(75); serial_putc(58);
  kbd_init();
  // "hello" = h(0x24) e(0x12) l(0x28) l(0x28) o(0x31)
  serial_putc(kbd_translate(0x24));
  serial_putc(kbd_translate(0x12));
  serial_putc(kbd_translate(0x28));
  serial_putc(kbd_translate(0x28));
  serial_putc(kbd_translate(0x31));
  serial_putc(10);
  // "shux" = s(0x13) h(0x24) u(0x22) x(0x11)
  serial_putc(kbd_translate(0x13));
  serial_putc(kbd_translate(0x24));
  serial_putc(kbd_translate(0x22));
  serial_putc(kbd_translate(0x11));
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
