// See implementation.
//
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
  let p_cwd: *u8 = process.getcwd_ptr();
  if (p_cwd == 0) {
    return 1;
  }
  if (process.getcwd_cached_len() <= 0) {
    return 2;
  }
  let p_exe: *u8 = process.self_exe_path_ptr();
  if (p_exe == 0) {
    return 3;
  }
  if (process.self_exe_path_cached_len() <= 0) {
    return 4;
  }
  return 0;
}
