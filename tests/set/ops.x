// See implementation.
const set = import("std.set");

/** Internal function `set_has_keys`.
 * Implements `set_has_keys`.
 * @param dst Set_i32
 * @param expect *i32
 * @param n i32
 * @return i32
 */
function set_has_keys(dst: Set_i32, expect: *i32, n: i32): i32 {
  if (set.len(dst) != n) { return 0; }
  let i: i32 = 0;
  while (i < n) {
    if (set.contains_key(dst, expect[i]) == 0) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: Set_i32 = set.new(0);
  let b: Set_i32 = set.new(0);
  let dst: Set_i32 = set.new(0);
  if (set.with_capacity(&a, 8) != 0) { return 1; }
  if (set.with_capacity(&b, 8) != 0) { return 2; }
  if (set.with_capacity(&dst, 16) != 0) { return 3; }
  if (set.insert(&a, 1) != 0) { return 4; }
  if (set.insert(&a, 2) != 0) { return 5; }
  if (set.insert(&a, 3) != 0) { return 6; }
  if (set.insert(&b, 2) != 0) { return 7; }
  if (set.insert(&b, 3) != 0) { return 8; }
  if (set.insert(&b, 4) != 0) { return 9; }
  if (set.union_into(&dst, a, b) != 0) { return 10; }
  let u: i32[4] = [1, 2, 3, 4];
  if (set_has_keys(dst, &u[0], 4) == 0) { return 11; }
  if (set.intersect_into(&dst, a, b) != 0) { return 12; }
  let ic: i32[2] = [2, 3];
  if (set_has_keys(dst, &ic[0], 2) == 0) { return 13; }
  if (set.difference_into(&dst, a, b) != 0) { return 14; }
  let d: i32[1] = [1];
  if (set_has_keys(dst, &d[0], 1) == 0) { return 15; }
  if (set.difference_into(&dst, b, a) != 0) { return 16; }
  let d2: i32[1] = [4];
  if (set_has_keys(dst, &d2[0], 1) == 0) { return 17; }
  set.deinit(&a);
  set.deinit(&b);
  set.deinit(&dst);
  return 0;
}
