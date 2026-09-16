/**
 * Stage10 10.2.1 slice7 probe: lateout from Linux syscall arg4 home (r10).
 * Expect: mov $7 → rax; mov rax→r10; nop; mov r10→rax; store → x; return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("r10") 7, lateout("r10") x);
  }
  if (x == 7) {
    return 42;
  }
  return 1;
}
