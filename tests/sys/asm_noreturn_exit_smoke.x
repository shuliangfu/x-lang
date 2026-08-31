/**
 * Stage10 10.2.1 slice8 probe: options(noreturn) after exit syscall.
 * Emit order: load rdi first, then rax last (later `in` would clobber rax).
 * Expect: mov $42→rdi; mov $60→rax; syscall; ud2 — exit status 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu); exit = syscall 60.
 */
export function main(): i32 {
  unsafe {
    asm!("syscall", in("rdi") 42, in("rax") 60, options(noreturn));
  }
  return 1;
}
