// Probe: illegal/unknown source byte must hard-fail with L003.
// wave272 Cap residual pure — product path must print "illegal character"
// (or L003) and refuse silent soft P001 "no functions" / BLD001-only.
//
// Authority: lexer.x punct fallthrough + parse_into_apply_unclosed_gate sticky.
// Dollar is not a token introducer on the product lexical surface.
// PLATFORM: SHARED.

function main(): i32 {
  return $ 0;
}
