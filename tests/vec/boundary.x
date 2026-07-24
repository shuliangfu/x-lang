// See implementation.
//
// See implementation.
// See implementation.
const vec = import("std.vec");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: Vec_i32 = vec.new();
  // See implementation.
  if (vec.is_empty(v) != 1) { return 1; }
  // See implementation.
  if (vec.capacity(v) != 0) { return 2; }
  // See implementation.
  if (vec.push(&v, 10) != 0) { return 3; }
  if (vec.push(&v, 20) != 0) { return 4; }
  if (vec.push(&v, 30) != 0) { return 5; }
  // See implementation.
  if (vec.length(v) != 3) { return 6; }
  // case 5：get/set
  if (vec.get(v, 1) != 20) { return 7; }
  vec.set(&v, 1, 21);
  if (vec.get(v, 1) != 21) { return 8; }
  // case 6：pop
  let popped: i32 = vec.pop(&v);
  if (popped != 30) { return 9; }
  if (vec.length(v) != 2) { return 10; }
  // case 7：append_slice (now called extend)
  let tail: i32[2] = [40, 50];
  if (vec.extend(&v, &tail[0], 2) != 0) { return 11; }
  if (vec.length(v) != 4) { return 12; }
  // See implementation.
  vec.clear(&v);
  if (vec.is_empty(v) != 1) { return 13; }
  // case 9：truncate + deinit
  if (vec.push(&v, 1) != 0) { return 14; }
  vec.truncate(&v, 0);
  if (vec.length(v) != 0) { return 15; }
  vec.deinit(&v);
  return 0;
}
