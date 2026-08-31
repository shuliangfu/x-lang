/**
 * Stage10 10.2.1 slice11 probe: if/else both noreturn → join unreachable.
 * Cond false → else exit(42). Expect RUN=42 and no fallthrough `return 1`.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu); exit = syscall 60.
 */
export function main(): i32 {
  let c: i32 = 0;
  unsafe {
    if (c != 0) {
      asm!("syscall", in("rdi") 1, in("rax") 60, options(noreturn));
    } else {
      asm!("syscall", in("rdi") 42, in("rax") 60, options(noreturn));
    }
  }
  return 1;
}
