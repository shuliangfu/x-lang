/**
 * Stage10 10.2.2 slice2 probe: lateout AAPCS x7 (newly opened mk==8).
 * Gold: `./xlang_asm -target aarch64-linux-gnu -c -o` then scan LE for
 *   mov x7,x0 (`e7 03 00 aa`) · nop · mov x0,x7 (`e0 03 07 aa`).
 * No qemu. PLATFORM: SHARED source · aarch64 emit · LINUX gold host.
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("x7") 7, lateout("x7") x);
  }
  if (x == 7) {
    return 42;
  }
  return 1;
}
