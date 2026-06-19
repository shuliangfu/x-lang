/**
 * std/trace/trace.c — 分布式链路追踪基础（STD-088）
 *
 * 【文件职责】
 * Span 创建/结束/嵌套；trace_id/span_id 生成；text 导出；
 * 供 mod.sx 与 std.context 集成及 gate 烟测调用。
 *
 * 【所属模块】标准库 std.trace；与 std/trace/mod.sx 同属一模块。
 * 【依赖】std/time/time.c、std/random/random.c。
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
    TRACE_OK = 0,
    TRACE_ERR_NULL = -1,
    TRACE_ERR_NOT_FOUND = -2,
    TRACE_ERR_FULL = -3,
    TRACE_ERR_INVALID = -4,
};

#define TRACE_MAX_SPANS 32
#define TRACE_MAX_NAME 64
#define TRACE_STACK_MAX 16

extern int64_t time_now_monotonic_ns_c(void);
extern int32_t random_fill_bytes_c(uint8_t *buf, int32_t len);

typedef struct span_node {
    uint64_t span_id;
    uint64_t parent_id;
    char name[TRACE_MAX_NAME];
    int64_t start_ns;
    int64_t end_ns;
    int32_t active;
    int32_t used;
} span_node_t;

typedef struct trace_state {
    uint8_t trace_id[16];
    span_node_t spans[TRACE_MAX_SPANS];
    int32_t span_count;
    uint64_t next_span_id;
    int32_t stack[TRACE_STACK_MAX];
    int32_t stack_depth;
} trace_state_t;

static trace_state_t *trace_from_handle(int64_t h) {
    if (h == 0) return NULL;
    return (trace_state_t *)(uintptr_t)h;
}

/** 生成 128-bit trace_id。 */
static void trace_gen_trace_id(uint8_t *out16) {
    if (random_fill_bytes_c(out16, 16) != 16) {
        int64_t t = time_now_monotonic_ns_c();
        memcpy(out16, &t, 8);
        memcpy(out16 + 8, &t, 8);
    }
}

/** 查找 span 索引；不存在 -1。 */
static int32_t trace_find_span(trace_state_t *t, uint64_t span_id) {
    int32_t i;
    if (!t || span_id == 0) return -1;
    for (i = 0; i < TRACE_MAX_SPANS; i++) {
        if (t->spans[i].used && t->spans[i].span_id == span_id) return i;
    }
    return -1;
}

/** 创建追踪会话。 */
int64_t trace_create_c(void) {
    trace_state_t *t = (trace_state_t *)calloc(1, sizeof(trace_state_t));
    if (!t) return 0;
    trace_gen_trace_id(t->trace_id);
    t->next_span_id = 1;
    return (int64_t)(uintptr_t)t;
}

/** 释放追踪会话。 */
void trace_free_c(int64_t handle) {
    trace_state_t *t = trace_from_handle(handle);
    if (t) free(t);
}

/** 读取 trace_id 16 字节。 */
void trace_trace_id_c(int64_t handle, uint8_t *out16) {
    trace_state_t *t = trace_from_handle(handle);
    if (!t || !out16) return;
    memcpy(out16, t->trace_id, 16);
}

/** 当前栈顶 span_id；无则 0。 */
uint64_t trace_current_span_c(int64_t handle) {
    trace_state_t *t = trace_from_handle(handle);
    if (!t || t->stack_depth <= 0) return 0;
    return (uint64_t)t->stack[t->stack_depth - 1];
}

/** 开始 span；parent_id=0 表示根。返回 span_id，失败 0。 */
uint64_t trace_start_span_c(int64_t handle, uint64_t parent_id, const uint8_t *name, int32_t name_len) {
    trace_state_t *t = trace_from_handle(handle);
    int32_t i;
    uint64_t sid;
    if (!t || !name || name_len <= 0) return 0;
    if (parent_id != 0 && trace_find_span(t, parent_id) < 0) return 0;
    if (t->stack_depth >= TRACE_STACK_MAX) return 0;
    for (i = 0; i < TRACE_MAX_SPANS; i++) {
        if (!t->spans[i].used) break;
    }
    if (i >= TRACE_MAX_SPANS) return 0;
    sid = t->next_span_id++;
    t->spans[i].span_id = sid;
    t->spans[i].parent_id = parent_id;
    if (name_len >= TRACE_MAX_NAME) name_len = TRACE_MAX_NAME - 1;
    memcpy(t->spans[i].name, name, (size_t)name_len);
    t->spans[i].name[name_len] = '\0';
    t->spans[i].start_ns = time_now_monotonic_ns_c();
    t->spans[i].end_ns = 0;
    t->spans[i].active = 1;
    t->spans[i].used = 1;
    t->stack[t->stack_depth++] = (int32_t)sid;
    t->span_count++;
    return sid;
}

/** 结束 span；须为栈顶。0 成功。 */
int32_t trace_end_span_c(int64_t handle, uint64_t span_id) {
    trace_state_t *t = trace_from_handle(handle);
    int32_t idx;
    if (!t || span_id == 0) return TRACE_ERR_NULL;
    if (t->stack_depth <= 0 || (uint64_t)t->stack[t->stack_depth - 1] != span_id) return TRACE_ERR_INVALID;
    idx = trace_find_span(t, span_id);
    if (idx < 0) return TRACE_ERR_NOT_FOUND;
    t->spans[idx].end_ns = time_now_monotonic_ns_c();
    t->spans[idx].active = 0;
    t->stack_depth--;
    return TRACE_OK;
}

/** 以当前栈顶为 parent 开始子 span。 */
uint64_t trace_start_child_c(int64_t handle, const uint8_t *name, int32_t name_len) {
    trace_state_t *t = trace_from_handle(handle);
    uint64_t parent;
    if (!t) return 0;
    parent = trace_current_span_c(handle);
    if (parent == 0) return trace_start_span_c(handle, 0, name, name_len);
    return trace_start_span_c(handle, parent, name, name_len);
}

/** 已完成 span 数量。 */
int32_t trace_span_count_c(int64_t handle) {
    trace_state_t *t = trace_from_handle(handle);
    if (!t) return TRACE_ERR_NULL;
    return t->span_count;
}

/** 导出 text 格式（OTLP 风格简化行）；返回写入长度，失败 -1。 */
int32_t trace_export_text_c(int64_t handle, uint8_t *out, int32_t out_cap) {
    trace_state_t *t = trace_from_handle(handle);
    int32_t pos = 0;
    int32_t i;
    int n;
    if (!t || !out || out_cap <= 0) return TRACE_ERR_NULL;
    n = snprintf((char *)out + pos, (size_t)out_cap - (size_t)pos,
                 "trace_id=");
    if (n < 0) return TRACE_ERR_INVALID;
    pos += n;
    for (i = 0; i < 16 && pos + 2 < out_cap; i++) {
        n = snprintf((char *)out + pos, (size_t)out_cap - (size_t)pos, "%02x", t->trace_id[i]);
        if (n < 0) return TRACE_ERR_INVALID;
        pos += n;
    }
    if (pos + 1 >= out_cap) return TRACE_ERR_FULL;
    out[pos++] = '\n';
    for (i = 0; i < TRACE_MAX_SPANS; i++) {
        if (!t->spans[i].used) continue;
        n = snprintf((char *)out + pos, (size_t)out_cap - (size_t)pos,
                     "span id=%llu parent=%llu name=%s start=%lld end=%lld\n",
                     (unsigned long long)t->spans[i].span_id,
                     (unsigned long long)t->spans[i].parent_id,
                     t->spans[i].name,
                     (long long)t->spans[i].start_ns,
                     (long long)t->spans[i].end_ns);
        if (n < 0) return TRACE_ERR_INVALID;
        if (pos + n >= out_cap) return TRACE_ERR_FULL;
        pos += n;
    }
    return pos;
}

/** C 烟测：嵌套 span + text 导出。 */
int32_t trace_smoke_c(void) {
    int64_t tr = trace_create_c();
    uint64_t root;
    uint64_t child;
    uint8_t buf[512];
    int32_t n;
    static const uint8_t n_root[] = "root";
    static const uint8_t n_child[] = "child";
    if (tr == 0) return 1;
    root = trace_start_span_c(tr, 0, n_root, 4);
    if (root == 0) return 2;
    child = trace_start_child_c(tr, n_child, 5);
    if (child == 0 || child == root) return 3;
    if (trace_end_span_c(tr, child) != TRACE_OK) return 4;
    if (trace_end_span_c(tr, root) != TRACE_OK) return 5;
    if (trace_span_count_c(tr) != 2) return 6;
    n = trace_export_text_c(tr, buf, 512);
    if (n <= 0) return 7;
    buf[n] = '\0';
    if (!strstr((char *)buf, "trace_id=")) return 8;
    if (!strstr((char *)buf, "name=root")) return 9;
    if (!strstr((char *)buf, "name=child")) return 10;
    trace_free_c(tr);
    return 0;
}

/* --- STD-118：关键路径 hook span 烟测 --- */

/** 模拟 io/net/async 挂钩 span 命名与计数；0 通过。 */
int32_t trace_hooks_smoke_c(void) {
    int64_t tr = trace_create_c();
    uint64_t root = 0;
    uint64_t sp_io = 0;
    uint64_t sp_net = 0;
    uint64_t sp_async = 0;
    static const uint8_t n_root[] = "root";
    static const uint8_t n_io[] = "io.read";
    static const uint8_t n_net[] = "net.connect";
    static const uint8_t n_async[] = "async.drain";
    if (tr == 0) return 1;
    root = trace_start_span_c(tr, 0, n_root, 4);
    if (root == 0) return 2;
    sp_io = trace_start_child_c(tr, n_io, 7);
    if (sp_io == 0) return 3;
    if (trace_end_span_c(tr, sp_io) != TRACE_OK) return 4;
    sp_net = trace_start_child_c(tr, n_net, 11);
    if (sp_net == 0) return 5;
    if (trace_end_span_c(tr, sp_net) != TRACE_OK) return 6;
    sp_async = trace_start_child_c(tr, n_async, 11);
    if (sp_async == 0) return 7;
    if (trace_end_span_c(tr, sp_async) != TRACE_OK) return 8;
    if (trace_end_span_c(tr, root) != TRACE_OK) return 9;
    if (trace_span_count_c(tr) != 4) return 10;
    trace_free_c(tr);
    return 0;
}
