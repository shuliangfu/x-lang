/**
 * Stage10 10.2.2 slice2 probe: lateout AAPCS x2 (mid GP; slice1 opened enc path).
 * Gold: `./xlang_asm -target aarch64-linux-gnu -c -o` then scan LE for
 *   mov x2,x0 (`e2 03 00 aa`) · nop · mov x0,x2 (`e0 03 02 aa`).
 * No qemu. PLATFORM: SHARED source · aarch64 emit · LINUX gold host.
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("x2") 7, lateout("x2") x);
  }
  if (x == 7) {
    return 42;
  }
  return 1;
}
