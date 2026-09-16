/**
 * Stage10 10.2.1 slice13 probe: options(nostack) alone is accept-only.
 * Expect: nop only (no pushfq); return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  unsafe {
    asm!("nop", options(nostack));
  }
  return 42;
}
