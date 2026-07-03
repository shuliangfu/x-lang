// Page frame allocator — bitmap-based physical memory management.
// Tracks 4KB pages from 0x100000 to 0x400000 (3MB = 768 pages).

#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }
#[link_section(".boot")]
const mb1: MB1Header = { magic: 0x1BADB002, flags: 0, checksum: 0xE4524FFE, };

#[used]
function kputc(c: u8): void { unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); } }
#[used]
function kputint(n: i32): void {
  if (n >= 10) { kputint(n / 10); }
  kputc((n % 10 + 48) as u8);
}

// Bitmap at 0x50000, 96 bytes = 768 bits = 768 pages
const PMM_BITMAP: u32 = 0x50000;
const PMM_PAGE_SIZE: u32 = 4096;
const PMM_START: u32 = 0x100000;
const PMM_PAGES: u32 = 768;

function pmm_init(): void {
  let i: u32 = 0;
  while (i < 96) {
    unsafe { *((PMM_BITMAP + i) as *volatile u8) = 0; }
    i = i + 1;
  }
}

function pmm_test_bit(page: u32) : u32 {
  let byte_idx: u32 = page / 8;
  let bit_idx: u32 = page % 8;
  let byte: *volatile u8 = (PMM_BITMAP + byte_idx) as *volatile u8;
  let val: u8 = 0;
  unsafe { val = *byte; }
  return (val >> bit_idx) & 1;
}

function pmm_set_bit(page: u32, val: u32): void {
  let byte_idx: u32 = page / 8;
  let bit_idx: u32 = page % 8;
  let p: *volatile u8 = (PMM_BITMAP + byte_idx) as *volatile u8;
  let old: u8 = 0;
  unsafe { old = *p; }
  if (val != 0) {
    let mask: u8 = (1 as u8) << (bit_idx as u8);
    unsafe { *p = old | mask; }
  } else {
    let mask: u8 = (1 as u8) << (bit_idx as u8);
    unsafe { *p = old & (((255 as u8) - mask)); }
  }
}

function pmm_alloc(): u32 {
  let i: u32 = 0;
  while (i < PMM_PAGES) {
    if (pmm_test_bit(i) == 0) {
      pmm_set_bit(i, 1);
      return PMM_START + i * PMM_PAGE_SIZE;
    }
    i = i + 1;
  }
  return 0;
}

function pmm_free(addr: u32): void {
  let page: u32 = (addr - PMM_START) / PMM_PAGE_SIZE;
  pmm_set_bit(page, 0);
}

function pmm_count_free(): u32 {
  let count: u32 = 0;
  let i: u32 = 0;
  while (i < PMM_PAGES) {
    if (pmm_test_bit(i) == 0) { count = count + 1; }
    i = i + 1;
  }
  return count;
}

function kmain(): i32 {
  kputc(77); kputc(58);  // M:
  pmm_init();
  let free0: u32 = pmm_count_free();
  
  let a1: u32 = pmm_alloc();
  let a2: u32 = pmm_alloc();
  let a3: u32 = pmm_alloc();
  let free1: u32 = pmm_count_free();
  
  pmm_free(a2);
  let free2: u32 = pmm_count_free();
  
  let a4: u32 = pmm_alloc();
  let free3: u32 = pmm_count_free();
  
  kputint(free0 as i32); kputc(44);
  kputint(a1 as i32); kputc(44);
  kputint(a2 as i32); kputc(44);
  kputint(free1 as i32); kputc(44);
  kputint(free2 as i32); kputc(44);
  kputint(a4 as i32); kputc(10);
  return 0;
}

#[entry]
function start(): void { unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); } }
function main(): i32 { return kmain() + mb1.magic as i32; }
