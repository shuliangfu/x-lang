/**
 * Stage10 10.2.1 slice12 probe: options(preserves_flags) wraps template.
 * Expect: pushfq (0x9c); nop (0x90); popfq (0x9d); return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu). aarch64: option accepted, no wrap.
 */
export function main(): i32 {
  unsafe {
    asm!("nop", options(preserves_flags));
  }
  return 42;
}
