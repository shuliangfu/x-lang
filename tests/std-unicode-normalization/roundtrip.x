// See implementation.
const unicode = import("std.unicode");

/** Internal function `bytes_eq4`.
 * Implements `bytes_eq4`.
 * @param buf *u8
 * @param n i32
 * @param e0 u8
 * @param e1 u8
 * @param e2 u8
 * @param e3 u8
 * @param expect_len i32
 * @return i32
 */
function bytes_eq4(buf: *u8, n: i32, e0: u8, e1: u8, e2: u8, e3: u8, expect_len: i32): i32 {
  if (n != expect_len) { return 0; }
  if (expect_len > 0 && buf[0] != e0) { return 0; }
  if (expect_len > 1 && buf[1] != e1) { return 0; }
  if (expect_len > 2 && buf[2] != e2) { return 0; }
  if (expect_len > 3 && buf[3] != e3) { return 0; }
  return 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let decomposed: u8[3] = [101, 204, 129];
  let composed: u8[2] = [195, 169];
  let out: u8[8] = [];
  let n: i32 = 0;

  /* std.unicode exports nfc_buf only; NFC of e+acute is c3 a9. */
  n = unicode.nfc_buf(&decomposed[0], 3, &out[0], 8);
  if (bytes_eq4(&out[0], n, 195 as u8, 169 as u8, 0 as u8, 0 as u8, 2) == 0) { return 3; }

  /* NFC of an already composed buffer stays the same two bytes. */
  n = unicode.nfc_buf(&composed[0], 2, &out[0], 8);
  if (bytes_eq4(&out[0], n, 195 as u8, 169 as u8, 0 as u8, 0 as u8, 2) == 0) { return 4; }

  return 0;
}
