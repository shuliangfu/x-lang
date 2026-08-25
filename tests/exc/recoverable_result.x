// See implementation.
// PLATFORM: SHARED — prefer short Result API (err/ok/unwrap_or/is_err/is_ok), not *_i32 aliases.
const result = import("core.result");
const err = import("std.error");

/**
 * Program/test entry point.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let bad: Result_i32 = result.err(err.code_invalid());
  let v: i32 = result.unwrap_or(bad, 99);
  if (v != 99) { return 1; }
  let good: Result_i32 = result.ok(7);
  if (result.unwrap_or(good, 0) != 7) { return 2; }
  if (!result.is_err(bad) || result.is_ok(bad)) { return 3; }
  return 0;
}
