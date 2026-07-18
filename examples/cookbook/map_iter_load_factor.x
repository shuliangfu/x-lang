// See implementation.
const map = import("std.map");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let m: Map_i32_i32 = map.new(0);
  if (map.insert(&m, 1, 10) != 0) { return 1; }
  if (map.load_factor_pct(m) <= 0) { return 2; }
  let it: MapIter_i32_i32 = map.iter_init(m);
  let item: MapIterItem_i32 = map.iter_next(&it);
  if (item.ok != 1) { return 3; }
  map.deinit(&m);
  return 0;
}
