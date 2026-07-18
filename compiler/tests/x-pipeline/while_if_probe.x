/** Probe: single-level if inside while. */

/**
 * Increment j under two ifs until j >= len; returns final j (expect 2).
 */
function main(): i32 {
  let j: i32 = 0;
  let len: i32 = 2;
  while (j < len) {
    if (j == 0) {
      j = j + 1;
    }
    if (j != 0) {
      j = j + 1;
    }
  }
  return j;
}
