/**
 * std/context/context.c — 取消、超时与 deadline 传播（STD-071）
 *
 * 【文件职责】
 * Context 树：background / with_cancel / with_deadline / with_timeout；
 * cancel / is_cancelled；deadline_ns / remaining_ns；轻量键值 bag。
 * 取消标志使用 C11 原子操作，可重复查询、线程安全。
 *
 * 【所属模块】标准库 std.context；与 std/context/mod.su 同属一模块。
 * 【依赖】单调时钟（time_now_monotonic_ns_c，链入 std/time/time.o）。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
#include <stdatomic.h>
#else
#error "std.context requires C11 atomics"
#endif

/** 与 mod.su 错误码一致。 */
enum {
  CTX_OK = 0,
  CTX_ERR_NULL = -1,
  CTX_CANCELLED = -2,
  CTX_DEADLINE = -3,
};

#define CTX_VALUE_SLOTS 8

/** 单调时钟；由 std/time/time.c 提供。 */
extern int64_t time_now_monotonic_ns_c(void);

typedef struct ctx_value_slot {
  uint32_t key_hash;
  int64_t value;
  int32_t used;
} ctx_value_slot_t;

typedef struct ctx_node {
  struct ctx_node *parent;
  atomic_int cancelled;
  int64_t deadline_ns; /* 0 = 继承父链 */
  ctx_value_slot_t values[CTX_VALUE_SLOTS];
} ctx_node_t;

/** 进程级 background 根节点（永不取消、无 deadline）。 */
static ctx_node_t g_ctx_background;

static int g_ctx_background_init;

/** 确保 background 单例已初始化。 */
static void ctx_ensure_background(void) {
  if (g_ctx_background_init) return;
  memset(&g_ctx_background, 0, sizeof(g_ctx_background));
  atomic_init(&g_ctx_background.cancelled, 0);
  g_ctx_background.deadline_ns = 0;
  g_ctx_background.parent = NULL;
  g_ctx_background_init = 1;
}

static ctx_node_t *ctx_from_handle(int64_t handle) {
  if (handle == 0) return NULL;
  return (ctx_node_t *)(uintptr_t)handle;
}

/** FNV-1a 32-bit：对 NUL 结尾 C 串求哈希。 */
static uint32_t ctx_key_hash(const uint8_t *key) {
  uint32_t h = 2166136261u;
  if (!key) return 0;
  while (*key) {
    h ^= (uint32_t)(*key++);
    h *= 16777619u;
  }
  return h;
}

/** 沿父链解析有效 deadline（取最近非零）。 */
static int64_t ctx_effective_deadline(ctx_node_t *node) {
  while (node) {
    if (node->deadline_ns > 0) return node->deadline_ns;
    node = node->parent;
  }
  return 0;
}

/** 节点或祖先是否已取消。 */
static int32_t ctx_chain_cancelled(ctx_node_t *node) {
  while (node) {
    if (atomic_load_explicit(&node->cancelled, memory_order_acquire)) return 1;
    node = node->parent;
  }
  return 0;
}

/** 返回 background 句柄。 */
int64_t ctx_background_c(void) {
  ctx_ensure_background();
  return (int64_t)(uintptr_t)&g_ctx_background;
}

/** 派生可取消子上下文；失败返回 0。 */
int64_t ctx_with_cancel_c(int64_t parent_handle) {
  ctx_node_t *parent = ctx_from_handle(parent_handle);
  ctx_node_t *child;
  if (!parent) return 0;
  child = (ctx_node_t *)calloc(1, sizeof(ctx_node_t));
  if (!child) return 0;
  child->parent = parent;
  atomic_init(&child->cancelled, 0);
  child->deadline_ns = 0;
  return (int64_t)(uintptr_t)child;
}

/** 派生带绝对 deadline（单调 ns）的子上下文；0 表示无 deadline。 */
int64_t ctx_with_deadline_c(int64_t parent_handle, int64_t deadline_ns) {
  ctx_node_t *parent = ctx_from_handle(parent_handle);
  ctx_node_t *child;
  if (!parent) return 0;
  child = (ctx_node_t *)calloc(1, sizeof(ctx_node_t));
  if (!child) return 0;
  child->parent = parent;
  atomic_init(&child->cancelled, 0);
  child->deadline_ns = deadline_ns > 0 ? deadline_ns : 0;
  return (int64_t)(uintptr_t)child;
}

/** 派生相对超时子上下文（now + timeout_ns）。 */
int64_t ctx_with_timeout_c(int64_t parent_handle, int64_t timeout_ns) {
  int64_t now;
  int64_t dl;
  if (timeout_ns <= 0) return ctx_with_deadline_c(parent_handle, 0);
  now = time_now_monotonic_ns_c();
  if (now <= 0) return 0;
  dl = now + timeout_ns;
  if (dl < now) return 0;
  return ctx_with_deadline_c(parent_handle, dl);
}

/** 取消上下文（仅标记本节点；子节点查询时沿链可见）。 */
void ctx_cancel_c(int64_t handle) {
  ctx_node_t *node = ctx_from_handle(handle);
  if (!node) return;
  atomic_store_explicit(&node->cancelled, 1, memory_order_release);
}

/** 是否已取消：1 是，0 否；无效句柄视为已取消。 */
int32_t ctx_is_cancelled_c(int64_t handle) {
  ctx_node_t *node = ctx_from_handle(handle);
  if (!node) return 1;
  return ctx_chain_cancelled(node);
}

/** 有效 deadline（单调 ns）；0 表示无 deadline。 */
int64_t ctx_deadline_ns_c(int64_t handle) {
  ctx_node_t *node = ctx_from_handle(handle);
  if (!node) return 0;
  return ctx_effective_deadline(node);
}

/** 剩余时间（纳秒）；已取消或已过期返回 0。 */
int64_t ctx_remaining_ns_c(int64_t handle) {
  ctx_node_t *node = ctx_from_handle(handle);
  int64_t dl;
  int64_t now;
  int64_t rem;
  if (!node) return 0;
  if (ctx_chain_cancelled(node)) return 0;
  dl = ctx_effective_deadline(node);
  if (dl <= 0) return 0;
  now = time_now_monotonic_ns_c();
  if (now <= 0) return 0;
  rem = dl - now;
  return rem > 0 ? rem : 0;
}

/** 设置键值（覆盖同 key）；成功 0，满 -1，空参 -1。 */
int32_t ctx_set_value_c(int64_t handle, const uint8_t *key, int64_t value) {
  ctx_node_t *node = ctx_from_handle(handle);
  uint32_t h;
  int i;
  int free_slot = -1;
  if (!node || !key) return CTX_ERR_NULL;
  h = ctx_key_hash(key);
  for (i = 0; i < CTX_VALUE_SLOTS; i++) {
    if (node->values[i].used && node->values[i].key_hash == h) {
      node->values[i].value = value;
      return CTX_OK;
    }
    if (!node->values[i].used && free_slot < 0) free_slot = i;
  }
  if (free_slot < 0) return -1;
  node->values[free_slot].key_hash = h;
  node->values[free_slot].value = value;
  node->values[free_slot].used = 1;
  return CTX_OK;
}

/** 读取键值；找到返回 1 并写 *out，否则返回 0。 */
int32_t ctx_get_value_c(int64_t handle, const uint8_t *key, int64_t *out) {
  ctx_node_t *node = ctx_from_handle(handle);
  uint32_t h;
  int i;
  if (!node || !key || !out) return 0;
  h = ctx_key_hash(key);
  for (i = 0; i < CTX_VALUE_SLOTS; i++) {
    if (node->values[i].used && node->values[i].key_hash == h) {
      *out = node->values[i].value;
      return 1;
    }
  }
  return 0;
}

/** 释放派生上下文（不可释放 background）。 */
void ctx_free_c(int64_t handle) {
  ctx_node_t *node = ctx_from_handle(handle);
  if (!node || node == &g_ctx_background) return;
  free(node);
}

/** C 烟测：cancel 传播 + deadline 过期 + value bag。 */
int32_t ctx_smoke_c(void) {
  int64_t bg;
  int64_t child;
  int64_t dl_child;
  int64_t rem;
  int64_t got;
  bg = ctx_background_c();
  if (!bg) return 1;
  if (ctx_is_cancelled_c(bg)) return 2;
  child = ctx_with_cancel_c(bg);
  if (!child) return 3;
  if (ctx_is_cancelled_c(child)) return 4;
  ctx_cancel_c(child);
  if (!ctx_is_cancelled_c(child)) return 5;
  ctx_free_c(child);
  child = ctx_with_timeout_c(bg, 2000000000LL);
  if (!child) return 6;
  if (ctx_deadline_ns_c(child) <= 0) return 7;
  rem = ctx_remaining_ns_c(child);
  if (rem <= 0 || rem > 2000000000LL) return 8;
  if (ctx_set_value_c(child, (const uint8_t *)"trace", 42) != CTX_OK) return 9;
  if (!ctx_get_value_c(child, (const uint8_t *)"trace", &got) || got != 42) return 10;
  ctx_free_c(child);
  dl_child = ctx_with_deadline_c(bg, 1);
  if (!dl_child) return 11;
  if (ctx_remaining_ns_c(dl_child) != 0) return 12;
  ctx_free_c(dl_child);
  return 0;
}
