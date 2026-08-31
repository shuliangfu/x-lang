/**
 * Stage10 10.2.2 slice0 probe: product `asm!("nop")` for aarch64 encode.
 * Gold: `./xlang_asm -target aarch64-linux-gnu -c -o` then scan LE bytes
 * `1f 20 03 d5` (HINT nop / d503201f). No qemu required (same as 10.4.1 arm64).
 * PLATFORM: SHARED source · aarch64 emit · LINUX gold host.
 */
export function main(): i32 {
  unsafe {
    asm!("nop");
  }
  return 42;
}
