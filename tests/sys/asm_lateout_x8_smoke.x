/**
 * Stage10 10.2.1 slice10 probe: lateout from Linux aarch64 syscall-nr home (x8).
 * Gold: `./xlang_asm -target aarch64-linux-gnu -c -o` then scan LE bytes for
 *   mov x8,x0 (`e8 03 00 aa`) · nop (`1f 20 03 d5`) · mov x0,x8 (`e0 03 08 aa`).
 * No qemu required (same as 10.2.2 / 10.4.1 arm64 encode probes).
 * PLATFORM: SHARED source · aarch64 emit · LINUX gold host.
 */
export function main(): i32 {
  let x: i32 = 0;
  unsafe {
    asm!("nop", in("x8") 7, lateout("x8") x);
  }
  if (x == 7) {
    return 42;
  }
  return 1;
}
