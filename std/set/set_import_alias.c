/**
 * set_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const set = import("std.set")` 生成 std_set_* 符号；
 * mod.sx 在自举 slice 下暂不能稳定 emit 为 .o（reserve_one 等 typeck/codegen 缺陷）。
 * 本 TU 提供 std_set_set_i32_* 实现（线性探测哈希，语义对齐 mod.sx）。
 */
#include <stdint.h>
#include <string.h>

extern int32_t *std_heap_alloc_i32(int32_t count);
extern uint8_t *std_heap_alloc_u8(int32_t count);
extern void std_heap_free_i32(int32_t *ptr);
extern void std_heap_free_u8(uint8_t *ptr);

/** 与 mod.sx Set_i32 布局一致。 */
typedef struct ShuxSetI32 {
  int32_t *keys;
  uint8_t *occupied;
  int32_t cap;
  int32_t len;
} ShuxSetI32;

/** 取 key 的槽位下标（0..cap-1）。 */
static int32_t set_i32_slot(const ShuxSetI32 *s, int32_t key) {
  int32_t h;
  if (!s || s->cap <= 0) {
    return 0;
  }
  h = key % s->cap;
  if (h < 0) {
    return h + s->cap;
  }
  return h;
}

/** 前向声明：grow 路径 rehash 须调用 insert。 */
static int32_t set_i32_insert(ShuxSetI32 *s, int32_t key);

/** 线性探测查找 key；存在返回槽位，否则 -1。 */
static int32_t set_i32_find(const ShuxSetI32 *s, int32_t key) {
  int32_t start;
  int32_t i;
  if (!s || s->cap <= 0) {
    return -1;
  }
  start = set_i32_slot(s, key);
  i = start;
  for (;;) {
    if (s->occupied[i] == 0) {
      return -1;
    }
    if (s->keys[i] == key) {
      return i;
    }
    i = i + 1;
    if (i >= s->cap) {
      i = 0;
    }
    if (i == start) {
      return -1;
    }
  }
}

/** 预分配 capacity 槽位；失败 -1，成功 0。 */
static int32_t set_i32_with_capacity(ShuxSetI32 *s, int32_t capacity) {
  int32_t *k;
  uint8_t *o;
  int32_t i;
  if (!s) {
    return -1;
  }
  if (capacity <= 0) {
    s->keys = (int32_t *)0;
    s->occupied = (uint8_t *)0;
    s->cap = 0;
    s->len = 0;
    return 0;
  }
  k = std_heap_alloc_i32(capacity);
  o = std_heap_alloc_u8(capacity);
  if (!k || !o) {
    if (k) {
      std_heap_free_i32(k);
    }
    if (o) {
      std_heap_free_u8(o);
    }
    return -1;
  }
  i = 0;
  while (i < capacity) {
    o[i] = 0;
    i = i + 1;
  }
  s->keys = k;
  s->occupied = o;
  s->cap = capacity;
  s->len = 0;
  return 0;
}

/** 扩容为 new_cap 并 rehash；失败 -1。 */
static int32_t set_i32_grow(ShuxSetI32 *s, int32_t new_cap) {
  int32_t *old_keys;
  uint8_t *old_occupied;
  int32_t old_cap;
  int32_t i;
  if (!s || new_cap <= s->cap) {
    return 0;
  }
  old_keys = s->keys;
  old_occupied = s->occupied;
  old_cap = s->cap;
  if (set_i32_with_capacity(s, new_cap) != 0) {
    return -1;
  }
  i = 0;
  while (i < old_cap) {
    if (old_occupied[i] != 0) {
      (void)set_i32_insert(s, old_keys[i]);
    }
    i = i + 1;
  }
  std_heap_free_i32(old_keys);
  std_heap_free_u8(old_occupied);
  return 0;
}

/** 负载 >0.75 时扩容；失败 -1。 */
static int32_t set_i32_reserve_one(ShuxSetI32 *s) {
  int32_t max_load;
  if (!s) {
    return -1;
  }
  if (s->cap <= 0) {
    return set_i32_with_capacity(s, 8);
  }
  max_load = s->cap * 3 / 4;
  if (s->len + 1 <= max_load) {
    return 0;
  }
  return set_i32_grow(s, s->cap * 2);
}

/** 插入 key；成功 0，失败 -1。 */
static int32_t set_i32_insert(ShuxSetI32 *s, int32_t key) {
  int32_t start;
  int32_t i;
  if (!s) {
    return -1;
  }
  if (set_i32_reserve_one(s) != 0) {
    return -1;
  }
  start = set_i32_slot(s, key);
  i = start;
  for (;;) {
    if (s->occupied[i] == 0) {
      s->keys[i] = key;
      s->occupied[i] = 1;
      s->len = s->len + 1;
      return 0;
    }
    if (s->keys[i] == key) {
      return 0;
    }
    i = i + 1;
    if (i >= s->cap) {
      i = 0;
    }
    if (i == start) {
      if (set_i32_grow(s, s->cap * 2) != 0) {
        return -1;
      }
      return set_i32_insert(s, key);
    }
  }
}

/** 是否包含 key；1 是，0 否。 */
int32_t std_set_set_i32_contains(ShuxSetI32 *s, int32_t key) {
  if (set_i32_find(s, key) >= 0) {
    return 1;
  }
  return 0;
}

/** 插入 key；成功 0，失败 -1。 */
int32_t std_set_set_i32_insert(ShuxSetI32 *s, int32_t key) {
  return set_i32_insert(s, key);
}

/** 移除 key；存在 1，否则 0。 */
int32_t std_set_set_i32_remove(ShuxSetI32 *s, int32_t key) {
  int32_t idx;
  if (!s) {
    return 0;
  }
  idx = set_i32_find(s, key);
  if (idx < 0) {
    return 0;
  }
  s->occupied[idx] = 0;
  s->len = s->len - 1;
  return 1;
}

/** 元素个数。 */
int32_t std_set_set_i32_len(ShuxSetI32 *s) {
  if (!s) {
    return 0;
  }
  return s->len;
}

/** 释放堆内存。 */
void std_set_set_i32_deinit(ShuxSetI32 *s) {
  if (!s) {
    return;
  }
  if (s->keys) {
    std_heap_free_i32(s->keys);
    s->keys = (int32_t *)0;
  }
  if (s->occupied) {
    std_heap_free_u8(s->occupied);
    s->occupied = (uint8_t *)0;
  }
  s->cap = 0;
  s->len = 0;
}
