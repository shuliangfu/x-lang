/**
 * Stage10 10.2.2 slice1 probe: lateout from AAPCS64 arg home x1.
 * Gold: `./xlang_asm -target aarch64-linux-gnu -c -o` then scan LE bytes for
 *   mov x1,x0 (`e1 03 00 aa`) · nop (`1f 20 03 d5`) · mov x0,x1 (`e0 03 01 aa`).
 * No qemu required (encode-only; same as 10.2.2 slice0 / lateout x8).
 * PLATFORM: SHARED source · aarch64 emit · LINUX gold host.
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("x1") 7, lateout("x1") x);
  }
  if (x == 7) {
    return 42;
  }
  return 1;
}
