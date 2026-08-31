/**
 * Stage10 10.2.1 slice8 probe: options(noreturn) after exit syscall.
 * Expect: mov $60; mov $42; syscall; ud2 — process exits 42 before ud2.
 * Dead `return 1` proves control does not fall through the asm.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu); exit = syscall 60.
 */
export function main(): i32 {
  unsafe {
    asm!("syscall", in("rax") 60, in("rdi") 42, options(noreturn));
  }
  return 1;
}
