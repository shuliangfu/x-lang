/**
 * Stage10 10.2.1 slice15 probe: options(readonly) with no memory outs.
 * Expect: return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  unsafe {
    asm!("nop", options(readonly));
  }
  return 42;
}
