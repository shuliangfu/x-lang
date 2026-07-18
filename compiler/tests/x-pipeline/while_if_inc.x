/** Probe: while with if that does not return, plus j++. */

/**
 * When j==0 add 10 to acc; always increment j. Returns acc (expect 10).
 */
function main(): i32 {
  let j: i32 = 0;
  let len: i32 = 2;
  let acc: i32 = 0;
  while (j < len) {
    if (j == 0) {
      acc = acc + 10;
    }
    j = j + 1;
  }
  return acc;
}
