/* r06_sort.c — Quicksort benchmark (matches r06_sort.x / .zig)
 * Tests: recursive function calls, array random access, branch prediction.
 * All three languages use the same Lomuto-partition quicksort (last-element pivot).
 * Init: arr[i] = (i * 1103515245 + 12345) & 0xFFFF (LCG-based pseudo-random).
 * Anti-fold: returns arr[0]+arr[N-1]; __asm__ on result. */
#include <stdint.h>

static void swap_i32(int32_t *a, int32_t *b) {
  int32_t t = *a;
  *a = *b;
  *b = t;
}

static int32_t partition(int32_t *arr, int32_t lo, int32_t hi) {
  int32_t pivot = arr[hi];
  int32_t i = lo - 1;
  int32_t j = lo;
  while (j < hi) {
    if (arr[j] <= pivot) {
      i = i + 1;
      swap_i32(&arr[i], &arr[j]);
    }
    j = j + 1;
  }
  swap_i32(&arr[i + 1], &arr[hi]);
  return i + 1;
}

static void quicksort(int32_t *arr, int32_t lo, int32_t hi) {
  if (lo < hi) {
    int32_t p = partition(arr, lo, hi);
    quicksort(arr, lo, p - 1);
    quicksort(arr, p + 1, hi);
  }
}

int main(void) {
  int32_t n = 10000;
  int32_t arr[10000];
  int32_t i = 0;
  while (i < n) {
    arr[i] = (i * 1103515245 + 12345) & 0xFFFF;
    i = i + 1;
  }
  quicksort(arr, 0, n - 1);
  int32_t result = arr[0] + arr[n - 1];
  /* B-CMP: prevent DCE of the sort by making the result opaque. */
  __asm__ volatile("" : "+r"(result) : : "memory");
  return (int)result;
}
