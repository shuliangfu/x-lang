/**
 * Stage10 10.2.1 slice14: nomem allows `_` clobber discard (no store).
 * Expect: return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  unsafe {
    asm!("nop", in("rax") 7, lateout("rax") _, options(nomem));
  }
  return 42;
}
