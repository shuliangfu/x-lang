// See implementation.
//
// See implementation.
// See implementation.
const map = import("std.map");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let mu: Map_u64_i32 = map.new(0 as u64);
  if (map.with_capacity(&mu, 4) != 0) { return 1; }
  // See implementation.
  if (map.insert(&mu, 1000 as u64, 10) != 0) { return 2; }
  if (map.insert(&mu, 2000 as u64, 20) != 0) { return 3; }
  // See implementation.
  if (map.get(mu, 1000 as u64, 0) != 10) { return 4; }
  if (map.get(mu, 3000 as u64, 99) != 99) { return 5; }
  // See implementation.
  if (map.insert(&mu, 1000 as u64, 11) != 0) { return 6; }
  if (map.get(mu, 1000 as u64, 0) != 11) { return 7; }
  // case 5：remove + contains_key
  if (map.remove(&mu, 2000 as u64) != 1) { return 8; }
  if (map.contains_key(mu, 2000 as u64) != 0) { return 9; }
  if (map.contains_key(mu, 1000 as u64) != 1) { return 10; }
  map.deinit(&mu);

  // See implementation.
  let ms: Map_str_i32 = map.str_new();
  if (map.str_with_capacity(&ms, 4) != 0) { return 11; }
  let k1: u8[3] = [97, 98, 99];
  let k2: u8[3] = [120, 121, 122];
  if (map.str_insert(&ms, k1, 3, 42) != 0) { return 12; }
  if (map.str_insert(&ms, k2, 3, 99) != 0) { return 13; }
  // See implementation.
  if (map.str_get(ms, k1, 3, 0) != 42) { return 14; }
  if (map.str_get(ms, k1, 2, 0) != 0) { return 15; }
  // case 8：str remove
  if (map.str_remove(&ms, k2, 3) != 1) { return 16; }
  if (map.str_contains(ms, k2, 3) != 0) { return 17; }
  map.str_deinit(&ms);
  return 0;
}
