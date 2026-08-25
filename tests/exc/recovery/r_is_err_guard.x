// See implementation.
// PLATFORM: SHARED — prefer short Result API (is_err), not is_err_i32 alias.
const result = import("core.result");

/**
 * Program/test entry point.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let r: Result_i32 = result.err(7);
  if (!result.is_err(r)) { return 1; }
  let v: i32 = 66;
  if (v != 66) { return 1; }
  return 0;
}
