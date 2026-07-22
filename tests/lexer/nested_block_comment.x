// Probe: nested block comments must not truncate the outer docblock.
// Historical failure mode: prose containing /**/ closed the outer /* early,
// so the remaining lines became stray tokens / parse errors.
//
// wave138 root fix: path globs like }/*.o or /*.x must NOT nest-open, or a
// single closing */ only pops the accidental inner depth and swallows the
// rest of the file (silent num_funcs truncation).

/**
 * Nested open-close sequence inside doc prose: /**/
 * Also a true nested block: /* inner note */
 * Outer continues after both; function below must still parse.
 * Path globs in prose must stay body text: std/db/{kv,arrow}/*.o and src/*.x
 */
function main(): i32 {
  // Deep nest: outer / mid / inner all close correctly.
  /*
   * level1
   /* level2
      /* level3 */
   */
   */
  // Path-safe: accidental /*.o after brace must not leave outer unclosed.
  /*
   * still on-demand link std/db/{kv,arrow}/*.o for product notes.
   */
  return 42;
}
