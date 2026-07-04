// L5: per-CPU segment relative addressing (gs:[off]) test.
// Sets up a GDT with a per-CPU data segment, loads gs, reads/writes via gs:offset.
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

function kmain(): i32 {
  // Set up GDT at 0x80000 with a per-CPU data segment
  // GDT entry 0: null
  // GDT entry 1: 32-bit code (base=0, limit=0xFFFFF, type=0x9A, flags=0xCF)
  // GDT entry 2: 32-bit data (base=0, limit=0xFFFFF, type=0x92, flags=0xCF)
  // GDT entry 3: per-CPU data (base=0x60000, limit=0x1000, type=0x92, flags=0x40)
  let gdt: *volatile u32 = 0x80000 as *volatile u32;
  // Entry 0: null
  unsafe { *gdt = 0; *(gdt + 1) = 0; }  // gdt[0], gdt[1]
  // Entry 1: code segment (base=0, limit=0xFFFFF)
  let gdt1: *volatile u32 = (0x80000 + 8) as *volatile u32;
  unsafe { *gdt1 = 0x0000FFFF; *(gdt1 + 1) = 0x00CF9A00; }
  // Entry 2: data segment (base=0, limit=0xFFFFF)
  let gdt2: *volatile u32 = (0x80000 + 16) as *volatile u32;
  unsafe { *gdt2 = 0x0000FFFF; *(gdt2 + 1) = 0x00CF9200; }
  // Entry 3: per-CPU data segment (base=0x60000, limit=0x1000, 32-bit granularity)
  let gdt3: *volatile u32 = (0x80000 + 24) as *volatile u32;
  unsafe { *gdt3 = 0x00001000; *(gdt3 + 1) = 0x00409200; }  // base=0x60000? no, base in entry
  // Fix: GDT entry format: limit_low(16) | base_low(16) | base_mid(8) | type(8) | flags(4)+limit_high(4) | base_high(8)
  // For base=0x60000, limit=0x1000, type=0x92 (data, writable), flags=0x4 (32-bit, byte granularity)
  // limit_low = 0x1000, base_low = 0x0000, base_mid = 0x06, type = 0x92, flags|limit_high = 0x40, base_high = 0x00
  // Actually base=0x60000: base_low=0x0000, base_mid=0x06, base_high=0x00. Wait 0x60000 = 393216. 
  // base_low = 0x0000, base_mid = 0x60, base_high = 0x00. Wait no: 0x60000 = 0x00060000.
  // base_low = 0x0000 (bits 0-15), base_mid = 0x06 (bits 16-23), base_high = 0x00 (bits 24-31). 
  // Wait: 0x60000 = 0x06 << 16 = 0x00060000. base_low=0x0000, base_mid=0x06.
  // Hmm, 0x60000 = 6 * 65536 = 393216. In hex: 0x00060000. 
  // base_low(0-15) = 0x0000, base_mid(16-23) = 0x06, base_high(24-31) = 0x00.
  // Wait: 0x06 << 16 = 0x60000. Yes. But base_mid is byte 16-23, so it's 0x06.
  // Hmm, 0x60000 in binary: 0000 0000 0000 0110 0000 0000 0000 0000
  // base_low (bits 0-15) = 0x0000
  // base_mid (bits 16-23) = 0x06
  // base_high (bits 24-31) = 0x00
  // But that gives base = 0x00060000 = 393216 = 0x60000. Correct!
  // Wait, I used 0x60000 but 0x06 << 16 = 0x60000. But 0x60000 is 393216.
  // Actually let me just use 0x60000 directly.
  // GDT entry 3: limit=0x1000, base=0x60000
  // Word 0: limit_low(0x1000) | base_low(0x0000) = 0x00001000 (little-endian: low 16 bits of limit in bits 0-15, low 16 bits of base in bits 16-31)
  // Wait, GDT entry layout (8 bytes):
  // Byte 0-1: limit 0-15
  // Byte 2-3: base 0-15
  // Byte 4: base 16-23
  // Byte 5: type/flags (access byte)
  // Byte 6: flags(4 bits) | limit 16-19 (4 bits)
  // Byte 7: base 24-31
  // As two 32-bit words (little-endian):
  // Word 0 (bytes 0-3): limit_low(16) | base_low(16) = 0x0000_1000
  // Word 1 (bytes 4-7): base_mid(8) | type(8) | flags_limit_high(8) | base_high(8)
  //   = 0x06 | 0x92 | 0x40 | 0x00 = 0x00_40_92_06
  // But as a 32-bit value in little-endian: 0x00409206
  // So word0 = 0x00001000, word1 = 0x00409206
  unsafe { *gdt3 = 0x00001000; *(gdt3 + 1) = 0x00409206; }

  // Load GDT
  // GDT descriptor: limit (16 bits) = 31 (4 entries * 8 - 1), base (32 bits) = 0x80000
  let gdtr: *volatile u16 = 0x7F000 as *volatile u16;
  unsafe { *gdtr = 31; }
  let gdtr_base: *volatile u32 = 0x7F002 as *volatile u32;
  unsafe { *gdtr_base = 0x80000; }
  unsafe { asm!("lgdt 0x7F000"); }

  // Load segment selectors
  unsafe {
    asm!("mov $0x10, %ax; mov %ax, %ds; mov %ax, %es; mov %ax, %ss");
    // Load gs with per-CPU segment selector (entry 3 = 0x18)
    asm!("mov $0x18, %ax; mov %ax, %gs");
    // Far jump to reload CS
    asm!("ljmp $0x08, $1f; 1:");
  }

  // Write per-CPU data at gs:0 (base=0x60000, so writes to 0x60000)
  // Use gs:offset addressing
  unsafe {
    asm!("movl %%eax, %%gs:0" : : "a"(12345));
  }
  // Read back via gs:0
  let val: u32 = 0;
  unsafe {
    asm!("movl %%gs:0, %%eax" : "=a"(val));
  }

  serial_putc(80);
  serial_putc(58);
  serial_putint(val as i32);
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x90000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
