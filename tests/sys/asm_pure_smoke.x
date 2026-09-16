/**
 * Stage10 10.2.1 slice16 probe: options(pure) alone.
 * Expect: return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  unsafe {
    asm!("nop", options(pure));
  }
  return 42;
}
