/**
 * See implementation.
 * See implementation.
 */
struct Particle soa {
  x: i32
  y: i32
}

/**
 * See implementation.
 */
function sum_x_column(arr: Particle[4], n: i32): i32 {
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    s = s + arr[i].x;
    i = i + 1;
  }
  return s;
}
