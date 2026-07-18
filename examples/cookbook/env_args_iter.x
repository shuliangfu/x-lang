/**
 * See implementation.
 */
const env = import("std.env");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let ai: ArgsIter = env.args_iter();
  let a0: *u8 = env.args_iter_next(&ai);
  if (a0 == 0) { return 1; }
  if (env.args_iter_count() < 1) { return 2; }
  let ei: EnvIter = env.iter();
  if (env.iter_count() < 0) { return 3; }
  let _unused: EnvIter = ei;
  return 0;
}
