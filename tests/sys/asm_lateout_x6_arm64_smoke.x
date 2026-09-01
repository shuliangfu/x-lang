/**
 * Stage10 10.2.2 slice2 probe: lateout AAPCS x6 (newly opened mk==7).
 * Gold: `./xlang_asm -target aarch64-linux-gnu -c -o` then scan LE for
 *   mov x6,x0 (`e6 03 00 aa`) · nop · mov x0,x6 (`e0 03 06 aa`).
 * No qemu. PLATFORM: SHARED source · aarch64 emit · LINUX gold host.
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("x6") 7, lateout("x6") x);
  }
  if (x == 7) {
    return 42;
  }
  return 1;
}
