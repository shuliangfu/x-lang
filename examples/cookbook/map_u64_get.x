// cookbook：Map_u64_i32 get/remove
const map = import("std.map");

function main(): i32 {
  let mu: Map_u64_i32 = map.new(0 as u64);
  if (map.with_capacity(&mu, 4) != 0) { return 1; }
  if (map.insert(&mu, 1000 as u64, 10) != 0) { return 2; }
  if (map.get(mu, 1000 as u64, 0) != 10) { return 3; }
  if (map.remove(&mu, 1000 as u64) != 1) { return 4; }
  map.deinit(&mu);
  return 0;
}
