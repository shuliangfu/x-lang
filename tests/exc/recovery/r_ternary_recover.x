// See implementation.
// PLATFORM: SHARED — prefer short Result API (is_ok / unwrap_or), not *_i32 aliases.
// Asm ternary + Result-by-value call arms mis-eval; use if/else (no .value field).
const result = import("core.result");

/**
 * Program/test entry point.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let r: Result_i32 = result.err(3);
  let v: i32 = 77;
  if (result.is_ok(r)) {
    v = result.unwrap_or(r, 0);
  }
  if (v != 77) { return 1; }
  let g: Result_i32 = result.ok(11);
  let w: i32 = 0;
  if (result.is_ok(g)) {
    w = result.unwrap_or(g, 0);
  }
  if (w != 11) { return 2; }
  return 0;
}
