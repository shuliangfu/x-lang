/** Function `callee`.
 * Purpose: implements `callee`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
function callee(): i32 {
  return 7;
}

/** Function `callee_spaced`.
 * Purpose: implements `callee_spaced`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
function callee_spaced (): i32 {
  return callee();
}

/** Function `main`.
 * Purpose: implements `main`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
function main (): i32 {
  if (1 != 0) {
    return callee_spaced();
  }
  return callee();
}
