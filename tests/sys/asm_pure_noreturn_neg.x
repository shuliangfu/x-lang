/**
 * Stage10 10.2.1 slice16 negative: pure + noreturn conflict.
 * Expect: build fail.
 * PLATFORM: SHARED (Ubuntu gold).
 */
export function main(): i32 {
  unsafe {
    asm!("syscall", in("rdi") 42, in("rax") 60, options(pure, noreturn));
  }
  return 1;
}
