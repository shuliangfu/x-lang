// See implementation.
const hash = import("std.hash");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[3] = [97, 98, 99];
  let hs: *u8 = hash.start_algo(0);
  let ha: *u8 = hash.start_algo(1);
  if (hs == 0 || ha == 0) {
    return 1;
  }
  hash.write_bytes_algo(hs, &buf[0], 3);
  hash.write_bytes_algo(ha, &buf[0], 3);
  let rs: u64 = hash.finish_algo(hs);
  let ra: u64 = hash.finish_algo(ha);
  hash.free_algo(hs);
  hash.free_algo(ha);
  if (rs == 0 || ra == 0) {
    return 2;
  }
  if (rs == ra) {
    return 3;
  }
  if (hash.default_hasher() != 0) {
    return 4;
  }
  return 0;
}
