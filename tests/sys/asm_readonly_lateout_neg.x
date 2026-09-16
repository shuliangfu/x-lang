/**
 * Stage10 10.2.1 slice15 negative: readonly + lateout local = memory write.
 * Expect: build fail.
 * PLATFORM: SHARED (Ubuntu gold).
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("rax") 7, lateout("rax") x, options(readonly));
  }
  return x;
}
