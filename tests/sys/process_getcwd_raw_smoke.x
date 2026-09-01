/**
 * Stage10 Cap residual 9.1.3 probe: getcwd/chdir without libc.
 * Product: process_* → Linux raw getcwd(79)/chdir(80) on x86_64.
 * PLATFORM: LINUX|x86_64 gold.
 */
const process = import("std.process");

/**
 * Probe: getcwd fills buf; chdir("."); getcwd again ok.
 * @return i32 — 0 ok; 1–3 fail stages
 */
export function main(): i32 {
  let buf1: u8[256] = [];
  let n1: i32 = process.getcwd(&buf1[0], 256);
  if (n1 <= 0 || buf1[0] == (0 as u8)) {
    return 1;
  }
  let dot: u8[2] = [46 as u8, 0 as u8];
  if (process.chdir(&dot[0]) != 0) {
    return 2;
  }
  let buf2: u8[256] = [];
  let n2: i32 = process.getcwd(&buf2[0], 256);
  if (n2 <= 0 || buf2[0] == (0 as u8)) {
    return 3;
  }
  return 0;
}
