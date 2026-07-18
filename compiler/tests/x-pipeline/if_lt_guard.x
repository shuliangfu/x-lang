/** Probe: if (i < lim) style guard; returns -1 only when i >= lim-1. */

/**
 * With i=1 and lim=64, the guard fails so main returns 0 (not -1).
 */
function main(): i32 {
  let i: i32 = 1;
  let lim: i32 = 64;
  if (i >= lim - 1) {
    return -1;
  }
  return 0;
}
