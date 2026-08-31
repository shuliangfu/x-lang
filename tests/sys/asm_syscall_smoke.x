/**
 * Stage10 10.2.1 slice3 probe: `asm!("syscall", in("rax") nr)`.
 * Linux x86_64 getpid (nr=39) → opcode 0F 05; return 42 from main.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  unsafe {
    asm!("syscall", in("rax") 39);
  }
  return 42;
}
