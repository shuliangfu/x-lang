// Probe: nested block comments must not truncate the outer docblock.
// Historical failure mode: prose containing /**/ closed the outer /* early,
// so the remaining lines became stray tokens / parse errors.

/**
 * Nested open-close sequence inside doc prose: /**/
 * Also a true nested block: /* inner note */
 * Outer continues after both; function below must still parse.
 */
function main(): i32 {
  // Deep nest: outer / mid / inner all close correctly.
  /*
   * level1
   /* level2
      /* level3 */
   */
   */
  return 42;
}
