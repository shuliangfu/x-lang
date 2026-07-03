// Paging kernel — sets up identity-mapped page tables and enables paging.
// Maps first 4MB (1024 PTEs × 4KB = 4MB) with identity mapping.

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
function serial_puthex(n: u32): void {
  let i: i32 = 28;
  while (i >= 0) {
    let nibble: u32 = (n >> i) & 15;
    if (nibble < 10) { serial_putc((nibble + 48) as u8); }
    else { serial_putc((nibble + 55) as u8); }
    i = i - 4;
  }
}

function kmain(): i32 {
  serial_putc(80);  // P
  serial_putc(58);  // :

  // Page table layout:
  // PML4  at 0x70000 (1 entry -> PDPT)
  // PDPT  at 0x71000 (1 entry -> PD)
  // PD    at 0x72000 (1 entry -> 2MB page, identity mapped)
  // Or for 32-bit paging:
  // PD    at 0x70000 (1024 entries, each maps 4MB)
  // PT    at 0x71000 (1024 entries, each maps 4KB)

  // 32-bit paging: PD at 0x70000, PT at 0x71000
  // PD[0] -> PT (Present + Write + 0x71000)
  // PT[i] -> identity map (Present + Write + i*4KB)

  // Set up PD[0] to point to PT
  let pd: *volatile u32 = 0x70000 as *volatile u32;
  unsafe { *pd = 0x71000 | 3; }  // Present + Write

  // Set up PT: identity map first 4MB (1024 entries × 4KB)
  let pt: *volatile u32 = 0x71000 as *volatile u32;
  let i: u32 = 0;
  while (i < 1024) {
    let pte: *volatile u32 = (0x71000 + i * 4) as *volatile u32; unsafe { *pte = (i * 4096) | 3; }  // Present + Write, identity
    i = i + 1;
  }

  // Load CR3 with page directory address
  unsafe {
    asm!("mov $0x70000, %eax; mov %eax, %cr3");
  }

  // Enable paging (set CR0.PG = bit 31)
  unsafe {
    asm!("mov %cr0, %eax; or $0x80000000, %eax; mov %eax, %cr0");
  }

  // Paging is now enabled! Verify memory access works.
  // Read a known address (VGA buffer at 0xB8000)
  let vga: *volatile u8 = 0xB8000 as *volatile u8;
  unsafe { *vga = 80; }  // 'P'
  let vga_attr: *volatile u8 = 0xB8001 as *volatile u8;
  unsafe { *vga_attr = 11; }  // Cyan
  let readback: u8 = 0;
  unsafe { readback = *vga; }

  // Read CR0 to confirm paging is on
  let cr0: u32 = 0;
  unsafe { asm!("mov %%cr0, %0" : "=a"(cr0)); }

  serial_puthex(cr0);
  serial_putc(44);
  serial_putint(readback as i32);
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x90000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
