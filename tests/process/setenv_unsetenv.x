// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
const process = import("std.process");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // name "X" = [88, 0, ...], value "v" = [118, 0, ...]
  let name: u8[4] = [88, 0, 0, 0];
  let value: u8[4] = [118, 0, 0, 0];
  // See implementation.
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
