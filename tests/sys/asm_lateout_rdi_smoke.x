/**
 * Stage10 10.2.1 slice5 probe: lateout from non-rax SysV GP (rdi).
 * Expect: mov $7 → rax; mov rax→rdi; nop; mov rdi→rax; store → x; return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("rdi") 7, lateout("rdi") x);
  }
  if (x == 7) {
    return 42;
  }
  return 1;
}
