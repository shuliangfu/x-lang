/**
 * See implementation.
 *
 * See implementation.
 * See implementation.
 */
const context = import("std.context");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let root: Context = context.background();
  if (context.is_cancelled(root) != 0) { return 1; }

  // See implementation.
  let child: Context = context.with_cancel(root);
  if (child.handle == 0) { return 2; }
  context.cancel(child);
  if (context.is_cancelled(child) == 0) {
    context.free(child);
    return 3;
  }
  context.free(child);

  // See implementation.
  let timed: Context = context.with_timeout(root, 200000000 as i64);
  if (timed.handle == 0) { return 4; }
  let rem: i64 = context.remaining_ns(timed);
  if (rem <= 0 || rem > 200000000) {
    context.free(timed);
    return 5;
  }

  // See implementation.
  let key: u8[6] = [116, 114, 97, 99, 101, 0];
  let out: i64 = 0;
  if (context.set_value(timed, &key[0], 42) != 0) {
    context.free(timed);
    return 6;
  }
  if (context.get_value(timed, &key[0], &out) == 0 || out != 42) {
    context.free(timed);
    return 7;
  }
  context.free(timed);
  return 0;
}
