/* seeds/runtime_path_fast.from_x.c — G-02f-21 product TU
 * G-02f-123 true .x pure helpers.
 * G-02f-98 pure path helper gates.
 * G-02f-rest：rest→.x 迁移完成；seed 中 16 个函数均由 .x 提供。
 *   PREFER_X_O 路径下 seed 整体跳过，进入 DIRECT 模式（无 ld -r）。
 *   冷启动路径下（xlang-c 不可用）seed 完整编译，保持语义同源。
 */
#include <stdint.h>
/* thin+rest 切割：全部 16 个函数由 .x 提供，
 * rest 模式下跳过编译避免重复定义。
 * 宏边界：XLANG_RUNTIME_PATH_FAST_FROM_X
 * 语义差异：.x path_sep_c 总是返回 '/'（47，posix 验收路径）；seed Win 分支返回 '\'（92）保留但 rest 模式下不生效。
 * PLATFORM: MACOS|DARWIN arm64 — product body is
 * src/asm/runtime_path_fast.x, pure-asm by the current compiler
 * into std/path/path.o. This C file is the Linux/Windows body and
 * the Darwin backup when pure-asm faults and the staged object is
 * missing. Do not delete these bodies. Do not gcc -E this seed
 * as the repair.
 */
#ifndef XLANG_RUNTIME_PATH_FAST_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RUNTIME_PATH_FAST_FROM_X removed */
#if defined(_WIN32) || defined(_WIN64)
#else
    return (uint8_t)47;
#endif
#endif /* XLANG_RUNTIME_PATH_FAST_FROM_X */
