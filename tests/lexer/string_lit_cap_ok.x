// Probe: string literal of exactly 63 semantic bytes must still accept (cap edge).
// wave283 Cap residual pure — product path stores Expr.var_name[0..62] + NUL.
// PLATFORM: SHARED.

function main(): i32 {
  // 63 A's
  let s: *u8 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  return 42;
}
