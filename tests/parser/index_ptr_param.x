// probe_index: see function docblock below.

/** Internal function `probe_index`.
 * Implements `probe_index`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
function probe_index(body: *u8, len: i32): i32 {
  let x: u8 = body[0];
  return x as i32;
}

/** Internal function `probe_while_if`.
 * Implements `probe_while_if`.
 * @param body *u8
 * @param len i32
 * @return i32
 */
function probe_while_if(body: *u8, len: i32): i32 {
  let i: i32 = 0;
  let b0: u8 = 0;
  while (i < len) {
    b0 = body[0];
    if (b0 == 105) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}
