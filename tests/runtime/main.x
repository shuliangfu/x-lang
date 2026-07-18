// See implementation.
const runtime = import("std.runtime");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let ok: i32 = runtime.ready();
  return ok;
}
