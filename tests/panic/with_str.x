// main: panic with string message (host-C intptr cast into int ABI).
/**
 * Program/test entry: panic("boom") must link and abort (non-zero).
 * @return i32 — never returns on success path
 */
function main(): i32 {
  panic("boom")
}
