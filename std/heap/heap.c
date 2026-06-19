/**
 * std/heap/heap.c — 堆分配：malloc / free / realloc / calloc 薄封装
 *
 * 【文件职责】
 * 为 std.heap 提供与 libc 一致的堆分配接口，供 std.vec、std.map 等使用。
 * 所有函数对 .sx 通过 extern 暴露；指针与大小由调用方保证合法。
 *
 * 【约定】
 * - 分配失败返回 NULL；free(NULL) 不操作；realloc(ptr, 0) 等价于 free(ptr) 并返回 NULL。
 * - alloc_zeroed 等价于 calloc(1, size)，即分配并清零。
 */

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/** SHUX_HEAP_TRACE=1 时统计 alloc/free 次数与字节（STD-017）。 */
static int32_t shu_heap_trace_on = -1;
static uint64_t shu_heap_trace_alloc_count;
static uint64_t shu_heap_trace_free_count;
static uint64_t shu_heap_trace_realloc_count;
static uint64_t shu_heap_trace_bytes;

/** 懒加载环境变量 SHUX_HEAP_TRACE。 */
static int32_t heap_trace_is_on(void) {
  const char *env;
  if (shu_heap_trace_on >= 0)
    return shu_heap_trace_on;
  env = getenv("SHUX_HEAP_TRACE");
  shu_heap_trace_on = (env && env[0] == '1') ? 1 : 0;
  return shu_heap_trace_on;
}

/** 分配成功时更新 trace 计数。 */
static void heap_trace_note_alloc(size_t size) {
  if (!heap_trace_is_on())
    return;
  shu_heap_trace_alloc_count++;
  shu_heap_trace_bytes += (uint64_t)size;
}

/** free 时更新 trace 计数。 */
static void heap_trace_note_free(void) {
  if (!heap_trace_is_on())
    return;
  shu_heap_trace_free_count++;
}

/** 分配 size 字节，未初始化；失败返回 NULL。对应 Zig allocator.alloc、Rust alloc、Go 底层。 */
void *heap_alloc_c(size_t size) {
  void *p;
  if (size == 0) return NULL;
  p = malloc(size);
  if (p)
    heap_trace_note_alloc(size);
  return p;
}

/** 释放 ptr；ptr 可为 NULL（无操作）。 */
void heap_free_c(void *ptr) {
  if (ptr) {
    heap_trace_note_free();
    free(ptr);
  }
}

/** 分配 count 个 int32_t，未初始化；失败返回 NULL。供 std.vec Vec_i32 等使用。 */
int32_t *heap_alloc_i32_c(int32_t count) {
  if (count <= 0) return NULL;
  return (int32_t *)malloc((size_t)count * sizeof(int32_t));
}

/** 将 ptr 调整为 new_count 个 int32_t；失败返回 NULL 且原 ptr 未释放。 */
int32_t *heap_realloc_i32_c(int32_t *ptr, int32_t new_count) {
  if (new_count <= 0) {
    if (ptr) free(ptr);
    return NULL;
  }
  return (int32_t *)realloc(ptr, (size_t)new_count * sizeof(int32_t));
}

/** 释放由 heap_alloc_i32_c / heap_realloc_i32_c 分配的 ptr；ptr 可为 NULL。 */
void heap_free_i32_c(int32_t *ptr) {
  if (ptr) free(ptr);
}

/** 分配 count 个 uint8_t，未初始化；失败返回 NULL。供 std.vec Vec_u8 等使用。 */
uint8_t *heap_alloc_u8_c(int32_t count) {
  if (count <= 0) return NULL;
  return (uint8_t *)malloc((size_t)count * sizeof(uint8_t));
}

/** 将 ptr 调整为 new_count 个 uint8_t；失败返回 NULL 且原 ptr 未释放。 */
uint8_t *heap_realloc_u8_c(uint8_t *ptr, int32_t new_count) {
  if (new_count <= 0) {
    if (ptr) free(ptr);
    return NULL;
  }
  return (uint8_t *)realloc(ptr, (size_t)new_count * sizeof(uint8_t));
}

/** 释放由 heap_alloc_u8_c / heap_realloc_u8_c 分配的 ptr；ptr 可为 NULL。 */
void heap_free_u8_c(uint8_t *ptr) {
  if (ptr) free(ptr);
}

/** 将 ptr 调整为 new_size 字节，可能移动块；失败返回 NULL 且原 ptr 未释放。new_size==0 等价于 free 并返回 NULL。 */
void *heap_realloc_c(void *ptr, size_t new_size) {
  if (new_size == 0) {
    if (ptr) free(ptr);
    return NULL;
  }
  return realloc(ptr, new_size);
}

/** 分配 size 字节并清零（calloc 语义）；失败返回 NULL。 */
void *heap_alloc_zeroed_c(size_t size) {
  if (size == 0) return NULL;
  return calloc(1, size);
}

/** 块拷贝：dst[dst_offset..dst_offset+count-1] = src[0..count-1]（按 i32 元素）；count<=0 不写。供 std.vec append_slice/from_slice 快路径。 */
void heap_copy_i32_at_c(int32_t *dst, int32_t dst_offset, const int32_t *src, int32_t count) {
  if (count <= 0) return;
  memcpy(dst + dst_offset, src, (size_t)count * sizeof(int32_t));
}

/** 块拷贝：dst[dst_offset..dst_offset+count-1] = src[0..count-1]（按 u8 元素）；count<=0 不写。 */
void heap_copy_u8_at_c(uint8_t *dst, int32_t dst_offset, const uint8_t *src, int32_t count) {
  if (count <= 0) return;
  memcpy(dst + dst_offset, src, (size_t)count);
}

/** 分配 count 个 float，未初始化；失败返回 NULL。DOD-S2：std.vec SoA 列存储。 */
float *heap_alloc_f32_c(int32_t count) {
  if (count <= 0) return NULL;
  return (float *)malloc((size_t)count * sizeof(float));
}

/** 将 ptr 调整为 new_count 个 float；失败返回 NULL 且原 ptr 未释放。 */
float *heap_realloc_f32_c(float *ptr, int32_t new_count) {
  if (new_count <= 0) {
    if (ptr) free(ptr);
    return NULL;
  }
  return (float *)realloc(ptr, (size_t)new_count * sizeof(float));
}

/** 释放由 heap_alloc_f32_c / heap_realloc_f32_c 分配的 ptr；ptr 可为 NULL。 */
void heap_free_f32_c(float *ptr) {
  if (ptr) free(ptr);
}

/** 块拷贝 f32：dst[dst_offset..] = src[0..count-1]；count<=0 不写。 */
void heap_copy_f32_at_c(float *dst, int32_t dst_offset, const float *src, int32_t count) {
  if (count <= 0) return;
  memcpy(dst + dst_offset, src, (size_t)count * sizeof(float));
}

/**
 * std.heap/mod.sx 薄包装符号（asm 路径跳过 std.heap dep emit 时由 heap.o 解析）。
 * 与 pipeline_asm_redirect_std_c_wrapper_sym 中 alloc_f32→heap_alloc_f32_c 双轨，保证 ld 可链。
 */
float *alloc_f32(int32_t count) {
  return heap_alloc_f32_c(count);
}

/** 见 alloc_f32。 */
float *realloc_f32(float *ptr, int32_t new_count) {
  return heap_realloc_f32_c(ptr, new_count);
}

/** 见 alloc_f32。 */
void free_f32(float *ptr) {
  heap_free_f32_c(ptr);
}

/** std.map 查找快路径：在 keys/occupied 中线性探测找 key；存在返回下标，否则 -1。与 .sx map_i32_i32_slot 一致。 */
static inline int32_t map_slot(int32_t key, int32_t cap) {
  int32_t h = key % cap;
  return h < 0 ? h + cap : h;
}

int32_t map_i32_i32_find_c(const int32_t *keys, const uint8_t *occupied, int32_t cap, int32_t key) {
  if (cap <= 0) return -1;
  int32_t start = map_slot(key, cap);
  int32_t i = start;
  for (;;) {
    if (occupied[i] == 0) return -1;
    if (keys[i] == key) return i;
    i++;
    if (i >= cap) i = 0;
    if (i == start) return -1;
  }
}

/** 供 codegen 生成的 C 调用（模块前缀 std_heap_）；转发到 map_i32_i32_find_c。 */
int32_t std_heap_map_i32_i32_find_c(const int32_t *keys, const uint8_t *occupied, int32_t cap, int32_t key) {
  return map_i32_i32_find_c(keys, occupied, cap, key);
}

/** std.mem 用：将 ptr[0..n-1] 置为 byte；n<=0 不写。对标 Zig std.mem.set、Rust ptr::write_bytes。 */
void heap_mem_set_c(uint8_t *ptr, uint8_t byte, int32_t n) {
  if (n <= 0) return;
  (void)memset(ptr, (unsigned char)byte, (size_t)n);
}

/** std.mem 用：比较 a[0..n-1] 与 b[0..n-1]；返回 <0 / 0 / >0。对标 Zig std.mem.compare、Rust/Golang bytes.Compare。 */
int32_t heap_mem_compare_c(const uint8_t *a, const uint8_t *b, int32_t n) {
  if (n <= 0) return 0;
  int r = memcmp(a, b, (size_t)n);
  if (r < 0) return -1;
  if (r > 0) return 1;
  return 0;
}

/** DOD-CL-S2 默认 arena chunk 字节数（须为 64 倍数）。 */
#define HEAP_ARENA64_DEFAULT_CAP 4096u

/**
 * DOD-CL-S2：posix_memalign 分配；align 须为 2 的幂且 ≥ sizeof(void*)。
 * 失败返回 NULL。
 */
void *heap_alloc_aligned_c(size_t align, size_t size) {
  void *p = NULL;
  if (size == 0)
    return NULL;
  if (align < sizeof(void *))
    align = sizeof(void *);
  if (posix_memalign(&p, align, size) != 0)
    return NULL;
  return p;
}

/** 返回 (uintptr_t)ptr % mod；供 smoke 验证指针对齐。mod<=0 时返回 0。 */
uintptr_t heap_ptr_mod_c(void *ptr, uintptr_t mod) {
  if (!ptr || mod == 0)
    return 0;
  return (uintptr_t)ptr % mod;
}

/** DOD-CL-S2 bump arena 状态（chunk 由 heap_alloc_aligned_c(64, cap) 分配）。 */
typedef struct {
  uint8_t *chunk;
  size_t cap;
  size_t off;
} heap_arena64_t;

/** 初始化 arena：cap==0 时用 HEAP_ARENA64_DEFAULT_CAP；失败返回 -1。 */
int32_t heap_arena64_init_c(heap_arena64_t *a, size_t cap) {
  if (!a)
    return -1;
  a->chunk = NULL;
  a->cap = 0;
  a->off = 0;
  if (cap == 0)
    cap = HEAP_ARENA64_DEFAULT_CAP;
  a->chunk = (uint8_t *)heap_alloc_aligned_c(64, cap);
  if (!a->chunk)
    return -1;
  a->cap = cap;
  return 0;
}

/**
 * 从 arena bump 分配 size 字节；align 为对象对齐（0 视为 8）。
 * 空间不足返回 NULL。
 */
void *heap_arena64_alloc_c(heap_arena64_t *a, size_t size, size_t align) {
  size_t cur;
  size_t rem;
  size_t gap;
  size_t next;
  void *p;
  if (!a || !a->chunk || size == 0)
    return NULL;
  if (align == 0)
    align = 8;
  cur = a->off;
  rem = cur % align;
  gap = rem ? (align - rem) : 0;
  next = cur + gap + size;
  if (next > a->cap)
    return NULL;
  p = a->chunk + cur + gap;
  a->off = next;
  return p;
}

/** 释放 arena chunk 并重置状态。 */
void heap_arena64_deinit_c(heap_arena64_t *a) {
  if (!a)
    return;
  heap_free_c(a->chunk);
  a->chunk = NULL;
  a->cap = 0;
  a->off = 0;
}

/** 分配 count 个 uint64_t；失败 NULL（STD-013 Map_u64）。 */
uint64_t *heap_alloc_u64_c(int32_t count) {
  if (count <= 0)
    return NULL;
  return (uint64_t *)malloc((size_t)count * sizeof(uint64_t));
}

/** 释放 heap_alloc_u64_c 分配的 ptr。 */
void heap_free_u64_c(uint64_t *ptr) {
  if (ptr)
    free(ptr);
}

/** STD-017：trace 是否启用（1/0）。 */
int32_t heap_trace_enabled_c(void) {
  return heap_trace_is_on();
}

/** STD-017：重置 trace 计数器。 */
void heap_trace_reset_c(void) {
  shu_heap_trace_alloc_count = 0;
  shu_heap_trace_free_count = 0;
  shu_heap_trace_realloc_count = 0;
  shu_heap_trace_bytes = 0;
}

/** STD-017：读取 trace 统计到 C 结构体（与 HeapTraceStats ABI 一致）。 */
void heap_trace_stats_c(uint64_t *alloc_count, uint64_t *free_count, uint64_t *realloc_count,
                        uint64_t *bytes_allocated) {
  if (alloc_count)
    *alloc_count = shu_heap_trace_alloc_count;
  if (free_count)
    *free_count = shu_heap_trace_free_count;
  if (realloc_count)
    *realloc_count = shu_heap_trace_realloc_count;
  if (bytes_allocated)
    *bytes_allocated = shu_heap_trace_bytes;
}
