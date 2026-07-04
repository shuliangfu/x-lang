/**
 * Cookbook CSTR-01：core.str bytes_view_index_of / starts_with（STD-131）。
 */
const str = import("core.str");

function main(): i32 {
  let buf: u8[6] = [104, 101, 108, 108, 111, 0];
  let v: BytesView = str.bytes_view(&buf[0], 5);
  if (str.bytes_view_index_of_byte(v, 111) != 4) { return 1; }
  let ll: u8[2] = [108, 108];
  if (str.bytes_view_index_of(v, &ll[0], 2) != 2) { return 2; }
  if (str.bytes_view_starts_with(v, &ll[0], 2) == 0) { return 3; }
  return 0;
}
