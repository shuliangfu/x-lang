// Probe: identifier length 64 must hard-fail L012 (not silent XP003 / clamp).
// wave284 Cap residual pure — AST name[64] content cap 63.
// Authority: lexer try_keyword TOKEN_IDENT path sticky L012 + parse gate.
// PLATFORM: SHARED.

function main(): i32 {
  let aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: i32 = 42;
  return aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
}
