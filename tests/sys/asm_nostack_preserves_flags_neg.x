/**
 * Stage10 10.2.1 slice13: nostack wins over preserves_flags wrap.
 * Expect: nop only (no pushfq/popfq) even with preserves_flags; return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  unsafe {
    asm!("nop", options(nostack, preserves_flags));
  }
  return 42;
}
