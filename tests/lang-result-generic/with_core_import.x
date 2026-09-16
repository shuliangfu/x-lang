/**
 * LANG-010 smoke: generic Result&lt;i32,i32&gt; annotation unifies with core.result
 * Result_i32 API (CORE-016 E=i32 compress / named-inst equality).
 */
const result = import("core.result");

/**
 * Program/test entry point.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let g: Result_i32 = result.ok_i32(42);
  let f: Result_i32 = result.ok_i32(7);
  if (g.err != 0 || g.value != 42) { return 1; }
  if (!result.is_ok(f) || result.unwrap_or(f, 0) != 7) { return 2; }
  return 0;
}
