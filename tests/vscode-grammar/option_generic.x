// See implementation.
const option = import("core.option");
const result = import("core.result");

/** Internal function `demo`.
 * Implements `demo`.
 * @return i32
 */
function demo(): i32 {
  let o: Option<i32> = Option<i32>.none();
  let r: Result<i32, i32> = Result<i32, i32>.ok(1);
  return o.is_some() ? 1 : r.unwrap_or(0);
}
