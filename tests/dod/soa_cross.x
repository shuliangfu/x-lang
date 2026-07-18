/**
 * See implementation.
 * See implementation.
 */
const soa_cross_lib = import("soa_cross_lib");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: Particle[4] = [];
  arr[0].x = 1;
  arr[1].x = 2;
  arr[2].x = 3;
  arr[3].x = 4;
  return sum_x_column(arr, 4);
}
