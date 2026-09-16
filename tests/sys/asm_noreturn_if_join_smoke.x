/**
 * Stage10 10.2.1 slice11 probe: if-only noreturn must not poison join.
 * Cond false → skip then → return 42. Unsafe wraps the asm arm only
 * (if/else inside one unsafe region drops else / confuses join).
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  let c: i32 = 0;
  if (c != 0) {
    unsafe {
      asm!("syscall", in("rdi") 99, in("rax") 60, options(noreturn));
    }
  }
  return 42;
}
