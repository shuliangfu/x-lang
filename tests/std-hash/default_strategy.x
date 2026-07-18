// See implementation.
const hash = import("std.hash");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  if (hash.default_hasher() != 0) { return 1; }
  if (hash.recommend_hasher_map() != 0) { return 2; }
  if (hash.recommend_hasher_fast() != 2) { return 3; }

  // See implementation.
  let buf: u8[3] = [97, 98, 99];
  let hs: *u8 = hash.start_algo(0);
  let ha: *u8 = hash.start_algo(1);
  let hx: *u8 = hash.start_algo(2);
  if (hs == 0 || ha == 0 || hx == 0) { return 4; }
  hash.write_bytes_algo(hs, &buf[0], 3);
  hash.write_bytes_algo(ha, &buf[0], 3);
  hash.write_bytes_algo(hx, &buf[0], 3);
  let rs: u64 = hash.finish_algo(hs);
  let ra: u64 = hash.finish_algo(ha);
  let rx: u64 = hash.finish_algo(hx);
  hash.free_algo(hs);
  hash.free_algo(ha);
  hash.free_algo(hx);
  if (rs == 0 || ra == 0 || rx == 0) { return 5; }
  if (rs == ra || rs == rx || ra == rx) { return 6; }

  // See implementation.
  let one: u64 = hash.xxhash64(&buf[0], 3);
  if (one == 0) { return 7; }

  return 0;
}
