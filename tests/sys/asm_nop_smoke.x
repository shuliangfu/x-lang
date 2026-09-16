/**
 * Stage10 10.2.1 slice0 probe: product `asm!("nop")` via xlang_asm.
 * Expect: parse EXPR_ASM → emit x86 nop (0x90) → return 42.
 * PLATFORM: SHARED source · LINUX|x86_64 gold runtime.
 */
export function main(): i32 {
  unsafe {
    asm!("nop");
  }
  return 42;
}
