/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
const soa_cross_lib = import("soa_cross_lib");

/* See implementation. */
struct Particle {
  x: i32
  y: i32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: Particle[2] = [];
  arr[0].x = 3;
  arr[1].x = 7;
  let s: i32 = arr[0].x + arr[1].x;
  return s;
}
