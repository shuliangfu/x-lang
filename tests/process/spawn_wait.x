// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
const process = import("std.process");

/** Internal function `run_true`.
 * Implements `run_true`.
 * @param path *u8
 * @return i32
 */
function run_true(path: *u8): i32 {
  let pid: i32 = process.spawn_simple(path);
  if (pid <= 0) { return -1; }
  // See implementation.
  let rc: i32 = process.waitpid(pid);
  return rc;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let usr_true: u8[20] = [47, 117, 115, 114, 47, 98, 105, 110, 47, 116, 114, 117, 101, 0, 0, 0, 0,
  0, 0, 0];
  let bin_true: u8[16] = [47, 98, 105, 110, 47, 116, 114, 117, 101, 0, 0, 0, 0, 0, 0, 0];
  let status: i32 = 0;
  // See implementation.
  let ostype_key: u8[8] = [79, 83, 84, 89, 80, 69, 0, 0];
  let ostype_val: *u8 = process.getenv(&ostype_key[0]);
  let on_darwin: bool = false;
  if (ostype_val != 0) {
    if (ostype_val[0] == 100 && ostype_val[1] == 97 && ostype_val[2] == 114 && ostype_val[3] == 119
        && ostype_val[4] == 105 && ostype_val[5] == 110) {
      on_darwin = true;
    }
  }
  if (on_darwin) {
    status = run_true(&usr_true[0]);
    if (status == 127) { status = run_true(&bin_true[0]); }
  } else {
    status = run_true(&bin_true[0]);
    if (status == 127) { status = run_true(&usr_true[0]); }
  }
  if (status == 0) { return 0; }
  return 2;
}
