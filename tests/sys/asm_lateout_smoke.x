/**
 * Stage10 10.2.1 slice4 probe: lateout captures asm result into a local.
 * Expect: mov $7 → rax; nop; store rax → x; return 42 iff x==7.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("rax") 7, lateout("rax") x);
  }
  if (x == 7) {
    return 42;
  }
  return 1;
}
