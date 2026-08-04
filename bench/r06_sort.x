// r06_sort.x — Quicksort benchmark (matches r06_sort.c / .zig)
// Tests: recursive function calls, array random access, branch prediction.
// Uses the same Lomuto-partition quicksort (last-element pivot) as C/Zig.
// Pointer-indexed array access follows the pattern from io_mmap_throughput.x
// (ptr[i] on *u8) and net_echo_throughput.x (s[i] on *u8).

/** Internal function `partition`.
 * Lomuto partition: pick last element as pivot, partition [lo..hi] in place.
 * @param arr pointer to the array base
 * @param lo lower bound index (inclusive)
 * @param hi upper bound index (inclusive, pivot position)
 * @return i32 final pivot index
 */
function partition(arr: *i32, lo: i32, hi: i32): i32 {
  let pivot: i32 = arr[hi];
  let i: i32 = lo - 1;
  let j: i32 = lo;
  while (j < hi) {
    if (arr[j] <= pivot) {
      i = i + 1;
      let tmp: i32 = arr[i];
      arr[i] = arr[j];
      arr[j] = tmp;
    }
    j = j + 1;
  }
  let tmp: i32 = arr[i + 1];
  arr[i + 1] = arr[hi];
  arr[hi] = tmp;
  return i + 1;
}

/** Internal function `quicksort`.
 * Recursive quicksort using Lomuto partition.
 * @param arr pointer to the array base
 * @param lo lower bound index (inclusive)
 * @param hi upper bound index (inclusive)
 */
function quicksort(arr: *i32, lo: i32, hi: i32): void {
  if (lo < hi) {
    let p: i32 = partition(arr, lo, hi);
    quicksort(arr, lo, p - 1);
    quicksort(arr, p + 1, hi);
  }
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 10000;
  let arr: i32[10000] = [];
  let i: i32 = 0;
  while (i < n) {
    arr[i] = (i * 1103515245 + 12345) & 0xFFFF;
    i = i + 1;
  }
  quicksort(&arr[0], 0, n - 1);
  return arr[0] + arr[n - 1];
}
