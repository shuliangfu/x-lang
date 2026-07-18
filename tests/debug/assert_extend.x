/**
 * See implementation.
 */
const debug = import("core.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let max_u: u64 = 18446744073709551615 as u64;
  debug.assert_eq_u64(0 as u64, 0 as u64);
  debug.assert_eq_u64(max_u, max_u);
  debug.assert_ne_u64(1 as u64, 2 as u64);

  // See implementation.
  debug.assert_eq_bool(true, true);
  debug.assert_ne_bool(true, false);
  debug.assert_ne_bool(false, true);

  // See implementation.
  let buf: u8[4] = [1, 2, 3, 4];
  let p: *u8 = &buf[0];
  debug.assert_eq_ptr(p, &buf[0]);
  let null_p: *u8 = 0 as *u8;
  debug.assert_eq_ptr(null_p, 0 as *u8);
  let q: *u8 = &buf[2];
  debug.assert_ne_ptr(p, q);

  return 0;
}
