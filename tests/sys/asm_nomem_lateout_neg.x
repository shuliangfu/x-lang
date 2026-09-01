/**
 * Stage10 10.2.1 slice14 negative: nomem + lateout to local = memory write.
 * Expect: build fail (CG002 / try_emit -1).
 * PLATFORM: SHARED (Ubuntu gold).
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("rax") 7, lateout("rax") x, options(nomem));
  }
  return x;
}
