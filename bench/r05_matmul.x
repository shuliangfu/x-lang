// r05_matmul.x — 64x64 integer matrix multiply (matches r05_matmul.c / .zig)
// Uses 1D arrays to simulate 2D: index = i*64 + j.
// Tests: triple-nested loop, memory access patterns, integer MAC throughput.

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32[4096] = [];
  let b: i32[4096] = [];
  let c: i32[4096] = [];
  let i: i32 = 0;
  while (i < 64) {
    let j: i32 = 0;
    while (j < 64) {
      a[i * 64 + j] = i + j;
      b[i * 64 + j] = i * j;
      c[i * 64 + j] = 0;
      j = j + 1;
    }
    i = i + 1;
  }
  i = 0;
  while (i < 64) {
    let j: i32 = 0;
    while (j < 64) {
      let s: i32 = 0;
      let k: i32 = 0;
      while (k < 64) {
        s = s + a[i * 64 + k] * b[k * 64 + j];
        k = k + 1;
      }
      c[i * 64 + j] = s;
      j = j + 1;
    }
    i = i + 1;
  }
  return c[0] + c[63 * 64 + 63];
}
