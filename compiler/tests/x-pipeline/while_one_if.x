/** Probe: while with single if + j++. */

/**
 * Walk two bytes and return 99 if any byte is not quote (34); else 0.
 */
function main(): i32 {
  let line: u8[4] = [97, 98, 0, 0];
  let j: i32 = 0;
  let len: i32 = 2;
  while (j < len) {
    if (line[j] != 34) {
      return 99;
    }
    j = j + 1;
  }
  return 0;
}
