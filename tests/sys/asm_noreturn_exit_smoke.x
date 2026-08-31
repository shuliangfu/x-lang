/**
 * Stage10 10.2.1 slice9 probe: options(noreturn) truncates unreachable emit.
 * Emit order: load rdi first, then rax last (later `in` would clobber rax).
 * Expect: mov $42→rdi; mov $60→rax; syscall; ud2 — and NO trailing `return 1`
 * (no `mov $0x1,%eax` after ud2). Exit status 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu); exit = syscall 60.
 */
export function main(): i32 {
  unsafe {
    asm!("syscall", in("rdi") 42, in("rax") 60, options(noreturn));
  }
  return 1;
}
