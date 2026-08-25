// STD-129 smoke: Set_i32 union_into / intersect_into / difference_into.
// PLATFORM: SHARED — product path via std.set overload names (not set_i32_*_into).
// Note: avoid helper that takes Set_i32 by-value plus stack-array &i32[N]
// (that pattern currently SIGSEGV on Darwin/Linux product link; separate residual).
const set = import("std.set");

/**
 * Program entry for STD-129 set ops smoke.
 * Builds two Set_i32 values, exercises union/intersect/difference into a
 * destination set, and asserts membership via contains_key / length.
 * @return i32 0 on success; nonzero step code on first failure
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

  // dst = a ∪ b → {1,2,3,4}
  if (set.union_into(&dst, a, b) != 0) { return 10; }
  if (set.length(dst) != 4) { return 11; }
  if (set.contains_key(dst, 1) == 0) { return 12; }
  if (set.contains_key(dst, 2) == 0) { return 13; }
  if (set.contains_key(dst, 3) == 0) { return 14; }
  if (set.contains_key(dst, 4) == 0) { return 15; }

  // dst = a ∩ b → {2,3}
  if (set.intersect_into(&dst, a, b) != 0) { return 16; }
  if (set.length(dst) != 2) { return 17; }
  if (set.contains_key(dst, 2) == 0) { return 18; }
  if (set.contains_key(dst, 3) == 0) { return 19; }

  // dst = a \ b → {1}
  if (set.difference_into(&dst, a, b) != 0) { return 20; }
  if (set.length(dst) != 1) { return 21; }
  if (set.contains_key(dst, 1) == 0) { return 22; }

  // dst = b \ a → {4}
  if (set.difference_into(&dst, b, a) != 0) { return 23; }
  if (set.length(dst) != 1) { return 24; }
  if (set.contains_key(dst, 4) == 0) { return 25; }

  set.deinit(&a);
  set.deinit(&b);
  set.deinit(&dst);
  return 0;
}
