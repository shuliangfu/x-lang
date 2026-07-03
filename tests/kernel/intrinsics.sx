// High-level intrinsic functions — wrapping common asm! patterns.
// Tests: cpuid, rdmsr/wrmsr, invlpg, pause, hlt, cli/sti, lgdt/lidt, cr3/cr0.

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

// === Intrinsic wrapper functions ===

#[used]
function intrinsic_hlt(): void { unsafe { asm!("hlt"); } }

#[used]
function intrinsic_cli(): void { unsafe { asm!("cli"); } }

#[used]
function intrinsic_sti(): void { unsafe { asm!("sti"); } }

#[used]
function intrinsic_pause(): void { unsafe { asm!("pause"); } }

#[used]
function intrinsic_mfence(): void { unsafe { asm!("mfence"); } }

#[used]
function intrinsic_lfence(): void { unsafe { asm!("lfence"); } }

#[used]
function intrinsic_sfence(): void { unsafe { asm!("sfence"); } }

#[used]
function intrinsic_invlpg(addr: u32): void {
  unsafe { asm!("invlpg (%0)" : : "a"(addr) : "memory"); }
}

#[used]
function intrinsic_read_cr0(): u32 {
  let val: u32 = 0;
  unsafe { asm!("mov %%cr0, %0" : "=a"(val)); }
  return val;
}

#[used]
function intrinsic_read_cr3(): u32 {
  let val: u32 = 0;
  unsafe { asm!("mov %%cr3, %0" : "=a"(val)); }
  return val;
}

#[used]
function intrinsic_write_cr3(addr: u32): void {
  unsafe { asm!("mov %0, %%cr3" : : "a"(addr)); }
}

#[used]
function intrinsic_cpuid(leaf: u32): u32 {
  let a: u32 = leaf;
  let b: u32 = 0;
  let c: u32 = 0;
  let d: u32 = 0;
  unsafe { asm!("cpuid" : "+a"(a), "=b"(b), "=c"(c), "=d"(d) : : ); }
  return a;
}

#[used]
function intrinsic_rdmsr(msr: u32): u64 {
  let lo: u32 = 0;
  let hi: u32 = 0;
  unsafe { asm!("rdmsr" : "=a"(lo), "=d"(hi) : "c"(msr)); }
  return (lo as u64) | ((hi as u64) << 32);
}

#[used]
function intrinsic_wrmsr(msr: u32, val: u64): void {
  let lo: u32 = (val & 0xFFFFFFFF) as u32;
  let hi: u32 = (val >> 32) as u32;
  unsafe { asm!("wrmsr" : : "a"(lo), "d"(hi), "c"(msr)); }
}

// === AtomicU32 wrapper ===
#[repr(C)]
struct AtomicU32 {
  value: u32;
}

#[used]
function atomic_u32_load(a: *AtomicU32): u32 {
  let p: *volatile u32 = (a as u32 + 0) as *volatile u32;
  let v: u32 = 0;
  unsafe { v = *p; }
  return v;
}

#[used]
function atomic_u32_store(a: *AtomicU32, val: u32): void {
  let p: *volatile u32 = (a as u32 + 0) as *volatile u32;
  unsafe { *p = val; }
}

#[used]
function atomic_u32_fetch_add(a: *AtomicU32, val: u32): u32 {
  let p: *volatile u32 = (a as u32 + 0) as *volatile u32;
  unsafe { asm!("lock xadd %0, (%1)" : "+a"(val) : "r"(p) : "memory", "cc"); }
  return val;
}

#[used]
function atomic_u32_cas(a: *AtomicU32, expected: u32, newval: u32): u32 {
  let p: *volatile u32 = (a as u32 + 0) as *volatile u32;
  let prev: u32 = expected;
  unsafe { asm!("lock cmpxchg %2, (%1)" : "+a"(prev) : "r"(p), "r"(newval) : "memory", "cc"); }
  return prev;
}

function kmain(): i32 {
  kputc(73); kputc(58);  // I:

  // Test intrinsics
  intrinsic_cli();
  intrinsic_sti();
  intrinsic_mfence();
  intrinsic_lfence();
  intrinsic_sfence();
  intrinsic_pause();

  // Test cr0 read
  let cr0: u32 = intrinsic_read_cr0();
  kputhex(cr0); kputc(44);

  // Test cpuid (leaf 0 = max CPUID leaf)
  let max_leaf: u32 = intrinsic_cpuid(0);
  kputhex(max_leaf); kputc(44);

  // Test AtomicU32
  let counter: AtomicU32 = { value: 0 };
  let old: u32 = atomic_u32_fetch_add((&counter) as *AtomicU32, 10);
  let val: u32 = atomic_u32_load((&counter) as *AtomicU32);
  let cas_old: u32 = atomic_u32_cas((&counter) as *AtomicU32, 10, 20);
  let val2: u32 = atomic_u32_load((&counter) as *AtomicU32);
  kputint(old as i32); kputc(44);
  kputint(val as i32); kputc(44);
  kputint(cas_old as i32); kputc(44);
  kputint(val2 as i32); kputc(10);
  return 0;
}

#[entry]
function start(): void { unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); } }
function main(): i32 { return kmain() + mb1.magic as i32; }
