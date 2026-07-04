/**
 * string_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const string = import("std.string")` 生成 std_string_* 符号；
 * string.o 由 runtime_string_fast.c 提供 shux_string_* 快路径，本 TU 提供
 * std_string_* 实现（语义对齐 mod.x）。
 *
 * asm `-o` ABI（x86_64）：
 * - String 栈槽为 8 字节 ShuxString*；只读调用 rdi=ShuxString*，可变调用 rdi=ShuxString**。
 * - StrView 栈槽为 8 字节 ShuxStrView*；只读调用 rdi=ShuxStrView*。
 * - string_new / string_from_slice / string_view 返回值 rax 为堆分配指针。
 */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/** 与 mod.x String 布局一致。 */
typedef struct ShuxString {
  uint8_t data[256];
  int32_t len;
} ShuxString;

/** 与 mod.x StrView 布局一致。 */
typedef struct ShuxStrView {
  uint8_t *ptr;
  int32_t len;
} ShuxStrView;

/** string.o 内 shux_string_* 快路径。 */
extern int32_t shux_string_memcmp_c(uint8_t *a, uint8_t *b, int32_t n);
extern int32_t shux_string_memmem_c(uint8_t *hay, int32_t hay_len, uint8_t *needle, int32_t needle_len);
extern void shux_string_copy_c(uint8_t *dst, uint8_t *src, int32_t n);
extern int32_t shux_string_memchr_c(uint8_t *ptr, uint8_t c, int32_t n);
extern int32_t shux_string_memrchr_c(uint8_t *ptr, uint8_t c, int32_t n);
extern int32_t shux_string_memcmp_at_c(uint8_t *a, int32_t off, uint8_t *b, int32_t n);

static const int32_t k_string_cap = 256;
static const int32_t k_long_threshold = 32;

/** 分配空 String；供 string_new / string_from_slice 使用。 */
static ShuxString *string_alloc_empty(void) {
  ShuxString *s = (ShuxString *)calloc(1, sizeof(ShuxString));
  return s;
}

/** 分配 StrView 描述符；不拷贝底层 bytes。 */
static ShuxStrView *view_alloc(uint8_t *ptr, int32_t len) {
  ShuxStrView *v = (ShuxStrView *)malloc(sizeof(ShuxStrView));
  if (!v)
    return 0;
  v->ptr = ptr;
  v->len = len;
  return v;
}

/** 从可变槽取 String*。 */
static ShuxString *string_from_slot(ShuxString **slot) {
  if (!slot)
    return 0;
  return *slot;
}

/** 空串长度常量 0。 */
int32_t std_string_string_empty(void) { return 0; }

/** 固定缓冲容量 256。 */
int32_t std_string_string_capacity(void) { return k_string_cap; }

/** 新建空字符串；返回堆 ShuxString*。 */
ShuxString *std_string_string_new(void) { return string_alloc_empty(); }

/** 当前字节数；rdi=ShuxString*。 */
int32_t std_string_string_len(ShuxString *s) {
  if (!s)
    return 0;
  return s->len;
}

/** 指针版 len；rdi=ShuxString**。 */
int32_t std_string_string_len_ptr(ShuxString **slot) {
  ShuxString *s = string_from_slot(slot);
  if (!s)
    return 0;
  return s->len;
}

/** 是否为空；rdi=ShuxString*。 */
int32_t std_string_string_is_empty(ShuxString *s) {
  if (!s || s->len <= 0)
    return 1;
  return 0;
}

/** 从 (ptr,len) 构造；rdi=src, rsi=len；返回 ShuxString*。 */
ShuxString *std_string_string_from_slice(uint8_t *ptr, int32_t len) {
  ShuxString *s = string_alloc_empty();
  int32_t n = len;
  if (!s)
    return 0;
  if (n > k_string_cap)
    n = k_string_cap;
  if (n > 0 && ptr)
    shux_string_copy_c(&s->data[0], ptr, n);
  s->len = n;
  return s;
}

/** 取第 i 字节；rdi=ShuxString*, rsi=index。 */
uint8_t std_string_string_get(ShuxString *s, int32_t i) { return s->data[i]; }

/** 两 String 相等；rdi/rsi=ShuxString*。 */
int32_t std_string_string_eq(ShuxString *a, ShuxString *b) {
  int32_t i;
  if (!a || !b)
    return 0;
  if (a->len != b->len)
    return 0;
  if (a->len == 1)
    return a->data[0] == b->data[0] ? 1 : 0;
  if (a->len == 2)
    return (a->data[0] == b->data[0] && a->data[1] == b->data[1]) ? 1 : 0;
  if (a->len == 3)
    return (a->data[0] == b->data[0] && a->data[1] == b->data[1] && a->data[2] == b->data[2]) ? 1 : 0;
  if (a->len == 4)
    return (a->data[0] == b->data[0] && a->data[1] == b->data[1] && a->data[2] == b->data[2] &&
            a->data[3] == b->data[3])
               ? 1
               : 0;
  if (a->len >= k_long_threshold)
    return shux_string_memcmp_c(&a->data[0], &b->data[0], a->len) == 0 ? 1 : 0;
  i = 0;
  while (i + 3 < a->len) {
    if (a->data[i] != b->data[i] || a->data[i + 1] != b->data[i + 1] || a->data[i + 2] != b->data[i + 2] ||
        a->data[i + 3] != b->data[i + 3])
      return 0;
    i += 4;
  }
  while (i < a->len) {
    if (a->data[i] != b->data[i])
      return 0;
    i++;
  }
  return 1;
}

/** 字典序比较；rdi/rsi=ShuxString*。 */
int32_t std_string_string_compare(ShuxString *a, ShuxString *b) {
  int32_t n;
  int32_t r;
  if (!a || !b)
    return 0;
  n = a->len;
  if (b->len < n)
    n = b->len;
  if (n >= 1) {
    r = shux_string_memcmp_c(&a->data[0], &b->data[0], n);
    if (r < 0)
      return -1;
    if (r > 0)
      return 1;
  }
  if (a->len < b->len)
    return -1;
  if (a->len > b->len)
    return 1;
  return 0;
}

/** 追加单字符；rdi=ShuxString**, rsi=byte。 */
int32_t std_string_string_append_char(ShuxString **slot, uint8_t c) {
  ShuxString *s = string_from_slot(slot);
  if (!s || s->len >= k_string_cap)
    return -1;
  s->data[s->len] = c;
  s->len++;
  return 0;
}

/** 追加 slice；rdi=ShuxString**, rsi=ptr, rdx=len。 */
int32_t std_string_string_append_slice(ShuxString **slot, uint8_t *ptr, int32_t len) {
  ShuxString *s = string_from_slot(slot);
  int32_t remain;
  int32_t base;
  if (!s)
    return -1;
  remain = k_string_cap - s->len;
  if (remain <= 0 || len > remain)
    return -1;
  base = s->len;
  if (len > 0 && ptr)
    shux_string_copy_c(&s->data[base], ptr, len);
  s->len = base + len;
  return 0;
}

/** 零拷贝 data 指针；rdi=ShuxString**。 */
uint8_t *std_string_string_data_ptr(ShuxString **slot) {
  ShuxString *s = string_from_slot(slot);
  if (!s)
    return 0;
  return &s->data[0];
}

/** 拷贝到 out；rdi=ShuxString*, rsi=out, rdx=out_max。 */
int32_t std_string_string_copy_to(ShuxString *s, uint8_t *out, int32_t out_max) {
  if (!s || !out)
    return -1;
  if (s->len > out_max)
    return -1;
  if (s->len >= 4)
    shux_string_copy_c(out, &s->data[0], s->len);
  else {
    if (s->len > 0)
      out[0] = s->data[0];
    if (s->len > 1)
      out[1] = s->data[1];
    if (s->len > 2)
      out[2] = s->data[2];
  }
  return s->len;
}

/** 找字节 c；rdi=ShuxString*, rsi=c。 */
int32_t std_string_string_find_char(ShuxString *s, uint8_t c) {
  if (!s)
    return -1;
  return shux_string_memchr_c(&s->data[0], c, s->len);
}

/** 前缀判断；rdi=ShuxString*, rsi=prefix, rdx=prefix_len。 */
int32_t std_string_string_starts_with(ShuxString *s, uint8_t *prefix, int32_t prefix_len) {
  if (prefix_len <= 0)
    return 1;
  if (!s || s->len < prefix_len)
    return 0;
  return shux_string_memcmp_c(&s->data[0], prefix, prefix_len) == 0 ? 1 : 0;
}

/** 后缀判断；rdi=ShuxString*, rsi=suffix, rdx=suffix_len。 */
int32_t std_string_string_ends_with(ShuxString *s, uint8_t *suffix, int32_t suffix_len) {
  int32_t off;
  if (suffix_len <= 0)
    return 1;
  if (!s || s->len < suffix_len)
    return 0;
  off = s->len - suffix_len;
  return shux_string_memcmp_at_c(&s->data[0], off, suffix, suffix_len) == 0 ? 1 : 0;
}

/** find_slice 线性扫描（memcmp_at 四轮步进）。 */
static int32_t string_find_slice_scan(ShuxString *s, uint8_t *sub, int32_t sub_len, int32_t start, int32_t end) {
  while (start <= end) {
    if (shux_string_memcmp_at_c(&s->data[0], start, sub, sub_len) == 0)
      return start;
    if (start + 1 <= end && shux_string_memcmp_at_c(&s->data[0], start + 1, sub, sub_len) == 0)
      return start + 1;
    if (start + 2 <= end && shux_string_memcmp_at_c(&s->data[0], start + 2, sub, sub_len) == 0)
      return start + 2;
    if (start + 3 <= end && shux_string_memcmp_at_c(&s->data[0], start + 3, sub, sub_len) == 0)
      return start + 3;
    start += 4;
  }
  return -1;
}

/** 子串首次下标；rdi=ShuxString*, rsi=sub, rdx=sub_len。 */
int32_t std_string_string_find_slice(ShuxString *s, uint8_t *sub, int32_t sub_len) {
  int32_t end;
  if (sub_len <= 0)
    return 0;
  if (!s || s->len < sub_len)
    return -1;
  if (sub_len == 1)
    return shux_string_memchr_c(&s->data[0], sub[0], s->len);
  if (s->len >= k_long_threshold || sub_len >= 8)
    return shux_string_memmem_c(&s->data[0], s->len, sub, sub_len);
  end = s->len - sub_len;
  return string_find_slice_scan(s, sub, sub_len, 0, end);
}

/** 是否包含子串。 */
int32_t std_string_string_contains(ShuxString *s, uint8_t *sub, int32_t sub_len) {
  return std_string_string_find_slice(s, sub, sub_len) >= 0 ? 1 : 0;
}

/** 反向找字节；rdi=ShuxString*, rsi=c。C 直实现（shux-c 编译 memrchr_c 的 while 不落码）。 */
int32_t std_string_string_rfind_char(ShuxString *s, uint8_t c) {
  int32_t pos;
  if (!s || s->len <= 0)
    return -1;
  pos = s->len - 1;
  while (pos >= 0) {
    if (s->data[pos] == c)
      return pos;
    pos--;
  }
  return -1;
}

/** trim 跳过首部空白。 */
static int32_t trim_skip_start(ShuxString *s, int32_t i) {
  while (i < s->len) {
    if (s->data[i] != 32 && s->data[i] != 9)
      return i;
    i++;
  }
  return i;
}

/** trim 跳过尾部空白。 */
static int32_t trim_skip_end(ShuxString *s, int32_t start, int32_t i) {
  while (i >= start) {
    if (s->data[i] != 32 && s->data[i] != 9)
      return i;
    i--;
  }
  return start - 1;
}

/** 去首尾空白写入 out；rdi=ShuxString*, rsi=out, rdx=out_max。 */
int32_t std_string_string_trim_space(ShuxString *s, uint8_t *out, int32_t out_max) {
  int32_t start;
  int32_t end;
  int32_t n;
  if (!s || s->len <= 0 || out_max <= 0)
    return 0;
  start = trim_skip_start(s, 0);
  end = trim_skip_end(s, start, s->len - 1);
  n = end - start + 1;
  if (n <= 0)
    return 0;
  if (n > out_max)
    return -1;
  shux_string_copy_c(out, &s->data[start], n);
  return n;
}

/** 原地替换 from→to；rdi=ShuxString**, rsi=from, rdx=to。 */
int32_t std_string_string_replace_char(ShuxString **slot, uint8_t from, uint8_t to) {
  ShuxString *s = string_from_slot(slot);
  int32_t i;
  int32_t count = 0;
  if (!s)
    return 0;
  for (i = 0; i < s->len; i++) {
    if (s->data[i] == from) {
      s->data[i] = to;
      count++;
    }
  }
  return count;
}

/** 构造 StrView；rdi=ptr, rsi=len；返回 ShuxStrView*。 */
ShuxStrView *std_string_string_view(uint8_t *ptr, int32_t len) { return view_alloc(ptr, len); }

/** 视图长度；rdi=ShuxStrView*。 */
int32_t std_string_string_view_len(ShuxStrView *v) {
  if (!v)
    return 0;
  return v->len;
}

/** 视图是否为空。 */
int32_t std_string_string_view_is_empty(ShuxStrView *v) {
  if (!v || v->len <= 0)
    return 1;
  return 0;
}

/** 取视图字节；rdi=ShuxStrView*, rsi=index。 */
uint8_t std_string_string_view_get(ShuxStrView *v, int32_t i) { return v->ptr[i]; }

/** 两视图相等。 */
int32_t std_string_string_view_eq(ShuxStrView *a, ShuxStrView *b) {
  int32_t i;
  if (!a || !b)
    return 0;
  if (a->len != b->len)
    return 0;
  if (a->len == 1)
    return a->ptr[0] == b->ptr[0] ? 1 : 0;
  if (a->len == 2)
    return (a->ptr[0] == b->ptr[0] && a->ptr[1] == b->ptr[1]) ? 1 : 0;
  if (a->len == 3)
    return (a->ptr[0] == b->ptr[0] && a->ptr[1] == b->ptr[1] && a->ptr[2] == b->ptr[2]) ? 1 : 0;
  if (a->len == 4)
    return (a->ptr[0] == b->ptr[0] && a->ptr[1] == b->ptr[1] && a->ptr[2] == b->ptr[2] && a->ptr[3] == b->ptr[3]) ? 1
                                                                                                                     : 0;
  if (a->len >= k_long_threshold)
    return shux_string_memcmp_c(a->ptr, b->ptr, a->len) == 0 ? 1 : 0;
  i = 0;
  while (i + 3 < a->len) {
    if (a->ptr[i] != b->ptr[i] || a->ptr[i + 1] != b->ptr[i + 1] || a->ptr[i + 2] != b->ptr[i + 2] ||
        a->ptr[i + 3] != b->ptr[i + 3])
      return 0;
    i += 4;
  }
  while (i < a->len) {
    if (a->ptr[i] != b->ptr[i])
      return 0;
    i++;
  }
  return 1;
}

/** 视图字典序比较。 */
int32_t std_string_string_view_compare(ShuxStrView *a, ShuxStrView *b) {
  int32_t n;
  int32_t i;
  int32_t r;
  if (!a || !b)
    return 0;
  n = a->len;
  if (b->len < n)
    n = b->len;
  if (n >= k_long_threshold) {
    r = shux_string_memcmp_c(a->ptr, b->ptr, n);
    if (r != 0)
      return r;
  } else {
    i = 0;
    while (i + 3 < n) {
      if (a->ptr[i] != b->ptr[i])
        return a->ptr[i] < b->ptr[i] ? -1 : 1;
      if (a->ptr[i + 1] != b->ptr[i + 1])
        return a->ptr[i + 1] < b->ptr[i + 1] ? -1 : 1;
      if (a->ptr[i + 2] != b->ptr[i + 2])
        return a->ptr[i + 2] < b->ptr[i + 2] ? -1 : 1;
      if (a->ptr[i + 3] != b->ptr[i + 3])
        return a->ptr[i + 3] < b->ptr[i + 3] ? -1 : 1;
      i += 4;
    }
    while (i < n) {
      if (a->ptr[i] != b->ptr[i])
        return a->ptr[i] < b->ptr[i] ? -1 : 1;
      i++;
    }
  }
  if (a->len < b->len)
    return -1;
  if (a->len > b->len)
    return 1;
  return 0;
}

/** 视图中找字节 c。 */
int32_t std_string_string_view_find_char(ShuxStrView *v, uint8_t c) {
  if (!v)
    return -1;
  return shux_string_memchr_c(v->ptr, c, v->len);
}

/** 视图前缀判断。 */
int32_t std_string_string_view_starts_with(ShuxStrView *v, uint8_t *prefix, int32_t prefix_len) {
  int32_t i;
  if (prefix_len <= 0)
    return 1;
  if (!v || v->len < prefix_len)
    return 0;
  if (prefix_len >= 8)
    return shux_string_memcmp_c(v->ptr, prefix, prefix_len) == 0 ? 1 : 0;
  for (i = 0; i < prefix_len; i++) {
    if (v->ptr[i] != prefix[i])
      return 0;
  }
  return 1;
}

/** 视图后缀判断。 */
int32_t std_string_string_view_ends_with(ShuxStrView *v, uint8_t *suffix, int32_t suffix_len) {
  int32_t off;
  if (suffix_len <= 0)
    return 1;
  if (!v || v->len < suffix_len)
    return 0;
  off = v->len - suffix_len;
  return shux_string_memcmp_at_c(v->ptr, off, suffix, suffix_len) == 0 ? 1 : 0;
}

/** 视图 find_slice 扫描。 */
static int32_t view_find_slice_scan(ShuxStrView *v, uint8_t *sub, int32_t sub_len, int32_t start, int32_t end) {
  while (start <= end) {
    if (shux_string_memcmp_at_c(v->ptr, start, sub, sub_len) == 0)
      return start;
    if (start + 1 <= end && shux_string_memcmp_at_c(v->ptr, start + 1, sub, sub_len) == 0)
      return start + 1;
    if (start + 2 <= end && shux_string_memcmp_at_c(v->ptr, start + 2, sub, sub_len) == 0)
      return start + 2;
    if (start + 3 <= end && shux_string_memcmp_at_c(v->ptr, start + 3, sub, sub_len) == 0)
      return start + 3;
    start += 4;
  }
  return -1;
}

/** 视图中找子串。 */
int32_t std_string_string_view_find_slice(ShuxStrView *v, uint8_t *sub, int32_t sub_len) {
  int32_t end;
  if (sub_len <= 0)
    return 0;
  if (!v || v->len < sub_len)
    return -1;
  if (sub_len == 1)
    return shux_string_memchr_c(v->ptr, sub[0], v->len);
  if (v->len >= k_long_threshold || sub_len >= 8)
    return shux_string_memmem_c(v->ptr, v->len, sub, sub_len);
  end = v->len - sub_len;
  return view_find_slice_scan(v, sub, sub_len, 0, end);
}

/** 视图 contains。 */
int32_t std_string_string_view_contains(ShuxStrView *v, uint8_t *sub, int32_t sub_len) {
  return std_string_string_view_find_slice(v, sub, sub_len) >= 0 ? 1 : 0;
}

/** String 与 StrView 相等；rdi=ShuxString*, rsi=ShuxStrView*。 */
int32_t std_string_string_eq_view(ShuxString *s, ShuxStrView *v) {
  int32_t i;
  if (!s || !v)
    return 0;
  if (s->len != v->len)
    return 0;
  if (s->len >= k_long_threshold)
    return shux_string_memcmp_c(&s->data[0], v->ptr, s->len) == 0 ? 1 : 0;
  i = 0;
  while (i + 3 < s->len) {
    if (s->data[i] != v->ptr[i] || s->data[i + 1] != v->ptr[i + 1] || s->data[i + 2] != v->ptr[i + 2] ||
        s->data[i + 3] != v->ptr[i + 3])
      return 0;
    i += 4;
  }
  while (i < s->len) {
    if (s->data[i] != v->ptr[i])
      return 0;
    i++;
  }
  return 1;
}

/** String 与 StrView 字典序比较。 */
int32_t std_string_string_compare_view(ShuxString *s, ShuxStrView *v) {
  int32_t n;
  int32_t i;
  int32_t r;
  if (!s || !v)
    return 0;
  n = s->len;
  if (v->len < n)
    n = v->len;
  if (n >= k_long_threshold) {
    r = shux_string_memcmp_c(&s->data[0], v->ptr, n);
    if (r != 0)
      return r;
  } else {
    i = 0;
    while (i + 3 < n) {
      if (s->data[i] != v->ptr[i])
        return s->data[i] < v->ptr[i] ? -1 : 1;
      if (s->data[i + 1] != v->ptr[i + 1])
        return s->data[i + 1] < v->ptr[i + 1] ? -1 : 1;
      if (s->data[i + 2] != v->ptr[i + 2])
        return s->data[i + 2] < v->ptr[i + 2] ? -1 : 1;
      if (s->data[i + 3] != v->ptr[i + 3])
        return s->data[i + 3] < v->ptr[i + 3] ? -1 : 1;
      i += 4;
    }
    while (i < n) {
      if (s->data[i] != v->ptr[i])
        return s->data[i] < v->ptr[i] ? -1 : 1;
      i++;
    }
  }
  if (s->len < v->len)
    return -1;
  if (s->len > v->len)
    return 1;
  return 0;
}
