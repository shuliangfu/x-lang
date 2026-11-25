/* seeds/rt_content.from_x.c — G-02f-261/306 P2 R2 content_has_* + path wrappers
 * Logic source: src/runtime/rt_content.x
 * Hybrid: XLANG_RT_CONTENT_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * f-261: content_has_generic / compound_assign（纯串）
 * f-306: driver_source_has_*（path → peek → content_has）
 * R2 full（2026-07-14）：path wrappers 亦由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

extern int driver_peek_source_file(const char *path, char *content, size_t cap);

/** 检测内存中的源码 content[0..n-1] 是否含泛型或 trait 语法（.x 流水线不支持，需走 C 路径）。 */
/* G-02f-126：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RT_CONTENT_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_CONTENT_FROM_X removed */
#else
int content_has_generic_syntax(const char *content, size_t n);
#endif




/** 检测 path 指向的源码文件是否含泛型语法（如 <T> 或 <i32>），有则返回 1 否则 0；供 .x driver 在 run_compiler_x_path 中决定是否走 C 流水线。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

/** 检测内存源码是否含复合赋值（+= 等）；.x 解析器未覆盖时须走 C 流水线（run-compound-assign 等）。
 * 跳过 //、块注释与双引号字符串，避免注释/字面量中的 token 误触发 asm→C 降级。 */
/* G-02f-126：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RT_CONTENT_FROM_X
#else
int content_has_compound_assign_syntax(const char *content, size_t n);
#endif

#ifndef XLANG_RT_CONTENT_FROM_X
#else
int driver_source_has_generic_syntax(const uint8_t *path, int path_len);
int driver_source_has_compound_assign_syntax(const uint8_t *path, int path_len);
#endif

int labi_rt_content_slice_marker(void) {
    return 1;
}
