// K6e: multiboot2 header with end tag — header_length=24, end tag type=0/flags=0/size=8.
// Tag format: type(u16)+flags(u16)+size(u32). End tag = type=0,flags=0,size=8 = 8 bytes.
// Represented as two u32: end_tag_tf=0 (type+flags packed), end_tag_size=8.

#[repr(C)]
struct MB2Header {
  magic: u32;
  arch: u32;
  header_length: u32;
  checksum: u32;
  end_tag_tf: u32;
  end_tag_size: u32;
}

#[link_section(".boot")]
const mb2: MB2Header = {
  magic: 0xE85250D6,
  arch: 0,
  header_length: 24,
  checksum: 0x17ADAF12,
  end_tag_tf: 0,
  end_tag_size: 8,
};

function serial_putc(c: u8): void {
  unsafe {
    asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8));
  }
}

function kmain(): i32 {
  serial_putc(77);
  serial_putc(50);
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe {
    asm!("cld; mov $__bss_start, %edi; mov $__bss_end, %ecx; sub %edi, %ecx; xor %eax, %eax; rep stosb; mov $__stack_top, %esp; call kmain; cli; hlt");
  }
}

function main(): i32 { return kmain() + mb2.magic as i32; }
