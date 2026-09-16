/**
 * Stage10 10.2.2 slice1 probe: `in("x1")` AAPCS arg home (encode-only).
 * Gold: `./xlang_asm -target aarch64-linux-gnu -c -o` then scan LE for
 *   mov x1,x0 (`e1 03 00 aa`) · nop (`1f 20 03 d5`).
 * No qemu. PLATFORM: SHARED source · aarch64 emit · LINUX gold host.
 */
export function main(): i32 {
  unsafe {
    asm!("nop", in("x1") 7);
  }
  return 42;
}
