/**
 * Stage10 10.2.1 slice1 probe: `asm!("nop", in("rax") expr)`.
 * Expect: parse operand → emit value into rax → nop → return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  unsafe {
    asm!("nop", in("rax") 7);
  }
  return 42;
}
