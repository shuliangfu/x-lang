// Virtual memory manager — map/unmap pages using page tables + PMM.
#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }
#[link_section(".boot")]
const mb1: MB1Header = { magic: 0x1BADB002, flags: 0, checksum: 0xE4524FFE, };

#[used]
function kputc(c: u8): void { unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); } }
#[used]
function kputint(n: i32): void { if (n >= 10) { kputint(n / 10); } kputc((n % 10 + 48) as u8); }
#[used]
function kputhex(n: u32): void {
  let i: i32 = 28;
  while (i >= 0) { let nib: u32 = (n >> i) & 15; if (nib < 10) { kputc((nib + 48) as u8); } else { kputc((nib + 55) as u8); } i = i - 4; }
}

const PMM_BITMAP: u32 = 0x50000;
const PMM_PAGE_SIZE: u32 = 4096;
const PMM_START: u32 = 0x100000;
const PMM_PAGES: u32 = 768;

#[used]
function pmm_init(): void { let i: u32 = 0; while (i < 96) { unsafe { *((PMM_BITMAP + i) as *volatile u8) = 0; } i = i + 1; } }
#[used]
function pmm_test_bit(page: u32): u32 { let b: *volatile u8 = (PMM_BITMAP + page / 8) as *volatile u8; let v: u8 = 0; unsafe { v = *b; } return (v >> (page % 8)) & 1; }
#[used]
function pmm_set_bit(page: u32, val: u32): void {
  let p: *volatile u8 = (PMM_BITMAP + page / 8) as *volatile u8; let old: u8 = 0; unsafe { old = *p; }
  let mask: u8 = (1 as u8) << ((page % 8) as u8);
  if (val != 0) { unsafe { *p = old | mask; } } else { unsafe { *p = old & ((255 as u8) - mask); } }
}
#[used]
function pmm_alloc(): u32 { let i: u32 = 0; while (i < PMM_PAGES) { if (pmm_test_bit(i) == 0) { pmm_set_bit(i, 1); return PMM_START + i * PMM_PAGE_SIZE; } i = i + 1; } return 0; }

const PD_BASE: u32 = 0x60000;
const PT_BASE: u32 = 0x61000;

#[used]
function paging_init(): void {
  unsafe { *(PD_BASE as *volatile u32) = PT_BASE | 3; }
  let i: u32 = 0;
  while (i < 1024) { unsafe { *((PT_BASE + i * 4) as *volatile u32) = (i * 4096) | 3; } i = i + 1; }
  unsafe { asm!("mov $0x60000, %eax; mov %eax, %cr3"); }
  unsafe { asm!("mov %cr0, %eax; or $0x80000000, %eax; mov %eax, %cr0"); }
}

#[used]
function vmm_map(virt: u32, phys: u32): i32 {
  let pd_idx: u32 = virt >> 22;
  let pt_idx: u32 = (virt >> 12) & 1023;
  let pde: *volatile u32 = (PD_BASE + pd_idx * 4) as *volatile u32;
  let pde_val: u32 = 0;
  unsafe { pde_val = *pde; }
  if ((pde_val & 1) == 0) {
    let pt_phys: u32 = pmm_alloc();
    if (pt_phys == 0) { return -1; }
    let j: u32 = 0;
    while (j < 1024) { unsafe { *((pt_phys + j * 4) as *volatile u32) = 0; } j = j + 1; }
    unsafe { *pde = pt_phys | 3; }
    pde_val = pt_phys | 3;
  }
  let pt_addr: u32 = pde_val & 0xFFFFF000;
  let pte: *volatile u32 = (pt_addr + pt_idx * 4) as *volatile u32;
  unsafe { *pte = phys | 3; }
  return 0;
}

#[used]
function vmm_unmap(virt: u32): void {
  let pd_idx: u32 = virt >> 22;
  let pt_idx: u32 = (virt >> 12) & 1023;
  let pde: *volatile u32 = (PD_BASE + pd_idx * 4) as *volatile u32;
  let pde_val: u32 = 0;
  unsafe { pde_val = *pde; }
  if ((pde_val & 1) == 0) { return; }
  let pt_addr: u32 = pde_val & 0xFFFFF000;
  let pte: *volatile u32 = (pt_addr + pt_idx * 4) as *volatile u32;
  unsafe { *pte = 0; }
}

function kmain(): i32 {
  kputc(86); kputc(58);
  pmm_init();
  paging_init();
  let phys: u32 = pmm_alloc();
  let r: i32 = vmm_map(0xC00000, phys);
  let p: *volatile u32 = 0xC00000 as *volatile u32;
  unsafe { *p = 12345; }
  let val: u32 = 0;
  unsafe { val = *p; }
  vmm_unmap(0xC00000);
  kputhex(phys); kputc(44); kputint(r); kputc(44); kputint(val as i32); kputc(10);
  return 0;
}

#[entry]
function start(): void { unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); } }
function main(): i32 { return kmain() + mb1.magic as i32; }
