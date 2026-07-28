// Probe: string literal of 64 semantic bytes must hard-fail with L011.
// wave283 Cap residual pure — prior soft residual silently truncated to 63.
// Authority: parser decode + lexer sticky L011 + parse_into gate.
// PLATFORM: SHARED.

function main(): i32 {
  // 64 A's — exceeds Expr.var_name content cap 63
  let s: *u8 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  return 42;
}
