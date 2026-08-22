/**
 * Cookbook CSTR-01: core.str bytes_view_index_of / starts_with (STD-131).
 * Payload is "hello" (len 5). starts_with must test the prefix "he",
 * not the mid-string "ll" used by index_of (that assertion always failed).
 */
const str = import("core.str");

/**
 * Program/test entry point.
 * @return i32 — 0 on success; 1/2/3 name the failing check
 */
function main(): i32 {
  let buf: u8[6] = [104, 101, 108, 108, 111, 0];
  let v: BytesView = str.bytes_view(&buf[0], 5);
  if (str.bytes_view_index_of_byte(v, 111) != 4) { return 1; }
  let ll: u8[2] = [108, 108];
  if (str.bytes_view_index_of(v, &ll[0], 2) != 2) { return 2; }
  let he: u8[2] = [104, 101];
  if (str.bytes_view_starts_with(v, &he[0], 2) == 0) { return 3; }
  return 0;
}
