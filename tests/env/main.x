// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
const env = import("std.env");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let key_path: u8[8] = [80, 65, 84, 72, 0, 0, 0, 0];
  let buf: u8[256] = [];
  let n: i32 = env.getenv(&key_path[0], 4, &buf[0], 256);
  if (n < 0 && env.getenv_exists(&key_path[0], 4) == 0) {
    // See implementation.
  }
  // See implementation.
  
  // See implementation.
  let tmp: u8[64] = [];
  let td: i32 = env.temp_dir(&tmp[0], 64);
  if (td < 0) {
    return 1;
  }
  if (td >= 64) {
    return 11;
  }
  
  // See implementation.
  let name: u8[4] = [88, 95, 69, 0];
  let val: u8[4] = [118, 0, 0, 0];
  if (env.setenv(&name[0], &val[0], 1) != 0) {
    return 2;
  }
  if (env.getenv_exists(&name[0], 3) != 1) {
    return 3;
  }
  let out_val: u8[8] = [];
  let got: i32 = env.getenv(&name[0], 3, &out_val[0], 8);
  if (got != 1) {
    return 6;
  }
  if (out_val[0] != 118) {
    return 7;
  }
  // See implementation.
  let len: i32 = 0;
  let p: *u8 = env.getenv_z(&name[0], &len);
  if (p == 0) {
    return 9;
  }
  if (len != 1) {
    return 12;
  }
  if (p[0] != 118) {
    return 13;
  }
  
  // See implementation.
  if (env.unsetenv(&name[0]) != 0) {
    return 4;
  }
  if (env.getenv_exists(&name[0], 3) != 0) {
    return 5;
  }
  let got2: i32 = env.getenv(&name[0], 3, &out_val[0], 8);
  if (got2 != -1) {
    return 8;
  }
  // See implementation.
  let q: *u8 = env.getenv_z(&name[0], &len);
  if (q != 0) {
    return 14;
  }
  
  return 0;
}
