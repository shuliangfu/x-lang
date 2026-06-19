/**
 * std/sort/sort.c — 排序（对标 Zig std.sort、Rust Vec::sort）
 *
 * 【文件职责】
 * sort_i32_c / sort_u8_c：原地不稳定 qsort；
 * sort_stable_*：稳定归并排序；
 * sort_i32_cmp_c：稳定排序 + usize 比较器；
 * sort_stable_key_tag_c：KeyTag 按 key 稳定排序。
 *
 * 【所属模块/组件】
 * 标准库 std.sort；与 std/sort/mod.sx 同属一模块。无外部依赖。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/** i32 升序比较器（qsort 语义）。 */
static int cmp_i32(const void *a, const void *b) {
  int32_t x = *(const int32_t *)a;
  int32_t y = *(const int32_t *)b;
  if (x < y) return -1;
  if (x > y) return 1;
  return 0;
}

/** u8 升序比较器（qsort 语义）。 */
static int cmp_u8(const void *a, const void *b) {
  uint8_t x = *(const uint8_t *)a;
  uint8_t y = *(const uint8_t *)b;
  if (x < y) return -1;
  if (x > y) return 1;
  return 0;
}

/** 自定义比较器类型（与 qsort 一致，经 usize 传入）。 */
typedef int32_t (*sort_cmp_fn_t)(const void *a, const void *b);

/**
 * 稳定归并排序核心：对 base[left..right) 排序，使用 temp 作辅助缓冲。
 * elem_size 为元素字节数；cmp 为比较器，NULL 时使用 memcmp 式默认（按 elem_size 字节序）。
 */
static void merge_sort_range(uint8_t *base, uint8_t *temp, int32_t left, int32_t right,
                             size_t elem_size, sort_cmp_fn_t cmp) {
  int32_t n = right - left;
  if (n <= 1) return;
  int32_t mid = left + n / 2;
  merge_sort_range(base, temp, left, mid, elem_size, cmp);
  merge_sort_range(base, temp, mid, right, elem_size, cmp);

  uint8_t *la = base + (size_t)left * elem_size;
  uint8_t *ra = base + (size_t)mid * elem_size;
  int32_t li = 0, ri = 0;
  int32_t lcnt = mid - left;
  int32_t rcnt = right - mid;
  uint8_t *out = temp;

  while (li < lcnt && ri < rcnt) {
    int32_t c;
    if (cmp) {
      c = cmp(la + (size_t)li * elem_size, ra + (size_t)ri * elem_size);
    } else {
      c = memcmp(la + (size_t)li * elem_size, ra + (size_t)ri * elem_size, elem_size);
    }
    if (c <= 0) {
      memcpy(out, la + (size_t)li * elem_size, elem_size);
      li++;
    } else {
      memcpy(out, ra + (size_t)ri * elem_size, elem_size);
      ri++;
    }
    out += elem_size;
  }
  while (li < lcnt) {
    memcpy(out, la + (size_t)li * elem_size, elem_size);
    li++;
    out += elem_size;
  }
  while (ri < rcnt) {
    memcpy(out, ra + (size_t)ri * elem_size, elem_size);
    ri++;
    out += elem_size;
  }
  memcpy(base + (size_t)left * elem_size, temp, (size_t)n * elem_size);
}

/** 对 ptr[0..len) 做稳定归并排序。 */
static void sort_stable_generic(void *ptr, int32_t len, size_t elem_size, sort_cmp_fn_t cmp) {
  if (!ptr || len <= 1) return;
  uint8_t *base = (uint8_t *)ptr;
  uint8_t *temp = (uint8_t *)malloc((size_t)len * elem_size);
  if (!temp) return;
  merge_sort_range(base, temp, 0, len, elem_size, cmp);
  free(temp);
}

/** 内建 i32 升序比较器（供 sort_stable_i32 使用）。 */
static int32_t cmp_i32_asc_fn(const void *a, const void *b) {
  return (int32_t)cmp_i32(a, b);
}

/** 内建 i32 降序比较器。 */
static int32_t cmp_i32_desc_fn(const void *a, const void *b) {
  return (int32_t)cmp_i32(b, a);
}

/** 内建 u8 升序比较器。 */
static int32_t cmp_u8_asc_fn(const void *a, const void *b) {
  return (int32_t)cmp_u8(a, b);
}

/** KeyTag 结构（与 mod.sx 布局一致：key + tag，各 i32）。 */
typedef struct {
  int32_t key;
  int32_t tag;
} sort_key_tag_t;

/** KeyTag 仅按 key 字段比较（稳定排序保留 tag 顺序）。 */
static int32_t cmp_key_tag_fn(const void *a, const void *b) {
  const sort_key_tag_t *x = (const sort_key_tag_t *)a;
  const sort_key_tag_t *y = (const sort_key_tag_t *)b;
  if (x->key < y->key) return -1;
  if (x->key > y->key) return 1;
  return 0;
}

/** 原地排序 ptr[0..len]（i32 升序）；不稳定。 */
void sort_i32_c(int32_t *ptr, int32_t len) {
  if (!ptr || len <= 1) return;
  qsort(ptr, (size_t)len, sizeof(int32_t), cmp_i32);
}

/** 原地排序 ptr[0..len]（u8 升序）；不稳定。 */
void sort_u8_c(uint8_t *ptr, int32_t len) {
  if (!ptr || len <= 1) return;
  qsort(ptr, (size_t)len, sizeof(uint8_t), cmp_u8);
}

/** 原地稳定升序排序 ptr[0..len]（i32）。 */
void sort_stable_i32_c(int32_t *ptr, int32_t len) {
  sort_stable_generic(ptr, len, sizeof(int32_t), cmp_i32_asc_fn);
}

/** 原地稳定升序排序 ptr[0..len]（u8）。 */
void sort_stable_u8_c(uint8_t *ptr, int32_t len) {
  sort_stable_generic(ptr, len, sizeof(uint8_t), cmp_u8_asc_fn);
}

/** 原地稳定排序 ptr[0..len]（i32）；cmp_fn 为 usize 承载的比较器。 */
void sort_i32_cmp_c(int32_t *ptr, int32_t len, void *cmp_fn) {
  if (!ptr || len <= 1) return;
  sort_cmp_fn_t cmp = cmp_fn ? (sort_cmp_fn_t)cmp_fn : cmp_i32_asc_fn;
  sort_stable_generic(ptr, len, sizeof(int32_t), cmp);
}

/** KeyTag 数组按 key 稳定升序排序。 */
void sort_stable_key_tag_c(sort_key_tag_t *ptr, int32_t len) {
  sort_stable_generic(ptr, len, sizeof(sort_key_tag_t), cmp_key_tag_fn);
}

/** 返回降序 i32 比较器函数地址（usize）。 */
uintptr_t sort_cmp_i32_desc_fn_c(void) {
  return (uintptr_t)(void *)cmp_i32_desc_fn;
}

/** 返回升序 i32 比较器函数地址（usize）。 */
uintptr_t sort_cmp_i32_asc_fn_c(void) {
  return (uintptr_t)(void *)cmp_i32_asc_fn;
}

/** 返回 KeyTag key 比较器函数地址（usize）。 */
uintptr_t sort_cmp_key_i32_fn_c(void) {
  return (uintptr_t)(void *)cmp_key_tag_fn;
}

/** STD-060 C 烟测：稳定升序 + 降序比较器 + 相等 key 稳定性。 */
int32_t sort_stable_smoke_c(void) {
  int32_t a[] = {3, 1, 4, 2};
  sort_stable_i32_c(a, 4);
  if (a[0] != 1 || a[1] != 2 || a[2] != 3 || a[3] != 4) return 1;

  int32_t b[] = {3, 1, 4, 2};
  sort_i32_cmp_c(b, 4, (void *)cmp_i32_desc_fn);
  if (b[0] != 4 || b[1] != 3 || b[2] != 2 || b[3] != 1) return 2;

  /* 相等 key 稳定性：seq 0 应在 seq 2 前 */
  sort_key_tag_t items[] = {{3, 0}, {1, 1}, {3, 2}, {2, 3}};
  sort_stable_key_tag_c(items, 4);
  if (items[0].key != 1 || items[1].key != 2) return 3;
  if (items[2].key != 3 || items[3].key != 3) return 4;
  if (items[2].tag != 0 || items[3].tag != 2) return 5;
  return 0;
}

/** STD-150 C 烟测：KeyTag 稳定 key 排序。 */
int32_t sort_key_cmp_smoke_c(void) {
  sort_key_tag_t items[] = {{3, 0}, {1, 1}, {3, 2}, {2, 3}};
  sort_stable_key_tag_c(items, 4);
  if (items[0].key != 1) return 1;
  if (items[1].key != 2) return 2;
  if (items[2].key != 3 || items[3].key != 3) return 3;
  if (items[2].tag != 0 || items[3].tag != 2) return 4;
  if (sort_cmp_key_i32_fn_c() == 0) return 5;
  return 0;
}
