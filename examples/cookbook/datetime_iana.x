/**
 * See implementation.
 * See implementation.
 */
const datetime = import("std.datetime");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let utc_name: u8[4] = [85, 84, 67, 0];
  let tz: TimeZone = TimeZone { offset_min: 0, iana_id: -1 };
  if (datetime.timezone_iana(&utc_name[0], 3, &tz) != 0) {
    return 1;
  }
  if (tz.iana_id < 0) {
    return 2;
  }
  return 0;
}
