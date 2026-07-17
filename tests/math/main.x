// tests/math/main.x — std.math 回归：常量、floor/ceil、sqrt、abs/signum。
// Non-lit METHOD_CALL args (var / post-clobber) must use SysV xmm0 — not GP rdi residual.
const math = import("std.math");

function main(): i32 {
  if (math.pi() <= 3.0 || math.pi() >= 4.0) { return 1; }
  if (math.e() <= 2.0 || math.e() >= 3.0) { return 2; }
  if (math.floor(2.3) != 2.0) { return 3; }
  if (math.ceil(2.3) != 3.0) { return 4; }
  if (math.sqrt(4.0) != 2.0) { return 5; }
  if (math.abs(0.0 - 1.5) != 1.5) { return 6; }
  if (math.signum(0.0 - 3.0) != (0.0 - 1.0)) { return 7; }
  // Non-lit VAR: proves param-type SSE place (FLOAT_LIT alone is not enough).
  let xf: f64 = 2.3;
  if (math.floor(xf) != 2.0) { return 8; }
  if (math.ceil(xf) != 3.0) { return 9; }
  // After sqrt, xmm0 holds 3.0; abs/signum must reload args into xmm0 (no residual fake green).
  if (math.sqrt(9.0) != 3.0) { return 10; }
  if (math.abs(0.0 - 1.5) != 1.5) { return 11; }
  if (math.signum(0.0 - 3.0) != (0.0 - 1.0)) { return 12; }
  return 0;
}
