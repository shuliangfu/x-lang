// s05_release_safe_vs_fast.x — mixed workload benchmark
// Matches bench/s05_release_safe_vs_fast.c / .zig algorithm.
// Mixed: array access + integer arithmetic + byte string scan.
// Data: int arr[10000] init arr[i]=i; u8 str[10000] init str[i]=(i*31+17)&0xFF.
// Loop: N=100000000 iterations: sum += arr[i%10000] * i; if (str[i%10000] > 127) str_count++.

/** Internal function `main`.
 * Program/test entry point. Mixed workload benchmark combining array
 * access, integer arithmetic, and byte-level string scanning. Returns
 * sum + str_count to prevent DCE.
 * @return i32 sum + str_count
 */
function main(): i32 {
  let n: i32 = 100000000;
  let m: i32 = 10000;
  let arr: i32[10000] = [];
  let str_data: u8[10000] = [];
  let i: i32 = 0;
  while (i < m) {
    arr[i] = i;
    str_data[i] = ((i * 31 + 17) & 255) as u8;
    i = i + 1;
  }
  let sum: i32 = 0;
  let str_count: i32 = 0;
  i = 0;
  while (i < n) {
    let j: i32 = i % m;
    sum = sum + arr[j] * i;
    if (str_data[j] > 127) {
      str_count = str_count + 1;
    }
    i = i + 1;
  }
  return sum + str_count;
}
