/**
 * Stage10 10.2.1 slice11 probe: if-only noreturn must not poison join.
 * Cond false → skip then → return 42. (Slice9 left diverged=1 after emitting
 * then, which incorrectly skipped the reachable return.)
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  let c: i32 = 0;
  unsafe {
    if (c != 0) {
      asm!("syscall", in("rdi") 99, in("rax") 60, options(noreturn));
    }
  }
  return 42;
}
