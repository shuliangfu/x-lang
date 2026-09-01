/**
 * Stage10 10.2.1 slice14 probe: options(nomem) with no memory outs.
 * Expect: nop; return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  unsafe {
    asm!("nop", options(nomem));
  }
  return 42;
}
