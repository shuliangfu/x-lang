/**
 * Stage9 Cap residual 9.1.1 probe: process setenv/getenv/unsetenv without libc.
 * Product pure-asm: std_process_* → process_*_c → environ walk/mutate
 * (link_abi_getenv_impl + xlang_environ_setenv/unsetenv; no U getenv/setenv/unsetenv).
 * PLATFORM: LINUX|x86_64 gold (POSIX Cap residual).
 */
const process = import("std.process");

/**
 * Probe entry: set X=v, getenv sees 'v', unset, getenv null.
 * @return i32 — 0 ok; 1 set fail; 2 getenv miss; 3 bad value; 4 unset fail; 5 still set
 */
export function main(): i32 {
  /* name "X" / value "v" as NUL-terminated u8 buffers */
  let name: u8[4] = [88, 0, 0, 0];
  let value: u8[4] = [118, 0, 0, 0];
  let set_r: i32 = process.setenv(&name[0], &value[0], 1);
  if (set_r != 0) {
    return 1;
  }
  let v: *u8 = process.getenv(&name[0]);
  if (v == 0) {
    return 2;
  }
  if (v[0] != 118) {
    return 3;
  }
  let unset_r: i32 = process.unsetenv(&name[0]);
  if (unset_r != 0) {
    return 4;
  }
  let v2: *u8 = process.getenv(&name[0]);
  if (v2 != 0) {
    return 5;
  }
  return 0;
}
