// Probe: unclosed nested block comment at EOF must hard-fail with L001.
// wave269 Cap residual pure — product path must print "unclosed block comment"
// (or L001) and refuse to link a silent empty module.
//
// Authority: lexer.x skip_whitespace_and_comments + driver_parse_into_buf_rc
// sticky pending hard-fail. PLATFORM: SHARED.

/* deliberately unclosed — no matching closer
function main(): i32 {
  return 42;
}
