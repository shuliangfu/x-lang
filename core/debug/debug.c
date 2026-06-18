/**
 * core/debug/debug.c — CORE-019 诊断钩子（volatile 快照，供 gdb/后处理读取）
 */
#include <stdint.h>

volatile int32_t g_shulang_debug_last_a = 0;
volatile int32_t g_shulang_debug_last_b = 0;
volatile int32_t g_shulang_debug_last_tag = 0;

/** 记录断言失败前的 a/b/tag 三元组（不分配、不写 stderr）。 */
void shulang_debug_diag_store_c(int32_t a, int32_t b, int32_t tag) {
    g_shulang_debug_last_a = a;
    g_shulang_debug_last_b = b;
    g_shulang_debug_last_tag = tag;
}
