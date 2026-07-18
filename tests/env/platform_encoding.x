// See implementation.
//
// See implementation.
const env = import("std.env");

/** Internal function `val_is_a_eq_b`.
 * Implements `val_is_a_eq_b`.
 * @param val *u8
 * @return i32
 */
function val_is_a_eq_b(val: *u8): i32 {
  if (val[0] != 97) { return 0; }
  if (val[1] != 61) { return 0; }
  if (val[2] != 98) { return 0; }
  if (val[3] != 0) { return 0; }
  return 1;
}

/** Internal function `test_setenv_boundaries`.
 * Implements `test_setenv_boundaries`.
 * @return i32
 */
function test_setenv_boundaries(): i32 {
  let name_empty: u8[8] = [88, 95, 80, 69, 95, 69, 0, 0];
  let val_empty: u8[1] = [0];
  if (env.setenv(&name_empty[0], &val_empty[0], 1) != 0) { return 1; }
  let out: u8[8] = [];
  let got: i32 = env.getenv(&name_empty[0], 6, &out[0], 8);
  if (got != 0) { return 2; }
  if (out[0] != 0) { return 3; }

  let name_eq: u8[8] = [88, 95, 80, 69, 95, 69, 81, 0];
  let val_eq: u8[4] = [97, 61, 98, 0];
  if (env.setenv(&name_eq[0], &val_eq[0], 1) != 0) { return 4; }
  got = env.getenv(&name_eq[0], 7, &out[0], 8);
  if (got != 3) { return 5; }
  if (val_is_a_eq_b(&out[0]) != 1) { return 6; }
  let len: i32 = 0;
  let p: *u8 = env.getenv_ptr(&name_eq[0], 7, &len);
  if (p == 0) { return 7; }
  if (len != 3) { return 8; }
  if (val_is_a_eq_b(p) != 1) { return 9; }
  return 0;
}

/** Internal function `test_key_len_boundary`.
 * Implements `test_key_len_boundary`.
 * @return i32
 */
function test_key_len_boundary(): i32 {
  let key4: u8[4] = [88, 95, 80, 69];
  let out: u8[8] = [];
  if (env.getenv(&key4[0], 4, &out[0], 8) != -1) { return 1; }
  if (env.getenv(&key4[0], 0, &out[0], 8) != -1) { return 2; }
  let long_key: u8[260] = [];
  let i: i32 = 0;
  while (i < 256) {
    long_key[i] = 65;
    i = i + 1;
  }
  if (env.getenv(&long_key[0], 256, &out[0], 8) != -1) { return 3; }
  if (env.getenv_exists(&long_key[0], 256) != 0) { return 4; }
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r: i32 = test_setenv_boundaries();
  if (r != 0) { return r; }
  r = test_key_len_boundary();
  if (r != 0) { return 20 + r; }

  let name_empty: u8[8] = [88, 95, 80, 69, 95, 69, 0, 0];
  let name_eq: u8[8] = [88, 95, 80, 69, 95, 69, 81, 0];
  if (env.unsetenv(&name_empty[0]) != 0) { return 30; }
  if (env.unsetenv(&name_eq[0]) != 0) { return 31; }
  return 0;
}
