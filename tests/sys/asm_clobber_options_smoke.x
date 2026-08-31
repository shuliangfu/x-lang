/**
 * Stage10 10.2.1 slice6 probe: clobber discard `_` + trailing options(...).
 * Expect: lateout rax → x; lateout rdi `_` is clobber-only; options accept-only.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("rax") 7, lateout("rax") x, lateout("rdi") _, options(nostack, preserves_flags));
  }
  if (x == 7) {
    return 42;
  }
  return 1;
}
