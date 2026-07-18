// See implementation.
//
// See implementation.
// See implementation.
const json = import("std.json");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let plain: u8[8] = [34, 104, 101, 108, 108, 111, 34, 0];
  let out_len: i32 = 0;
  let consumed: i32 = 0;
  let vp: *u8 = json.parse_string_view(&plain[0], 7, &out_len, &consumed);
  if (vp == 0 as *u8) {
    return 1;
  }
  if (out_len != 5) {
    return 2;
  }
  if (consumed != 7) {
    return 3;
  }
  if (vp[0] != 104 || vp[1] != 101 || vp[2] != 108 || vp[3] != 108 || vp[4] != 111) {
    return 4;
  }
  if (vp != &plain[1]) {
    return 5;
  }
  // See implementation.
  let esc: u8[10] = [34, 97, 92, 117, 48, 48, 54, 50, 34, 0];
  let ol2: i32 = 0;
  let c2: i32 = 0;
  let vp2: *u8 = json.parse_string_view(&esc[0], 9, &ol2, &c2);
  if (vp2 != 0 as *u8) {
    return 10;
  }
  if (ol2 != json.needs_copy()) {
    return 11;
  }
  let out_buf: u8[8] = [];
  let n: i32 = json.parse_string(&esc[0], 9, &out_buf[0], 8, &c2);
  if (n != 2) {
    return 12;
  }
  if (out_buf[0] != 97 || out_buf[1] != 98) {
    return 13;
  }
  return 0;
}
