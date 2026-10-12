/* seeds/runtime_string_fast.from_x.c — G-02f-21 product TU
 * G-02f-99 portable memmem gate.
 * G-02f-rest：rest→.x 迁移完成；seed 中 8 个函数均由 .x 提供。
 *   PREFER_X_O 路径下 seed 整体跳过，进入 DIRECT 模式（无 ld -r）。
 *   冷启动路径下（xlang-c 不可用）seed 完整编译，保持语义同源。
 *
 * PLATFORM: MACOS|DARWIN arm64 — product body is
 * src/asm/runtime_string_fast.x, pure-asm by the current compiler.
 * This C file is the Linux/Windows body and the Darwin backup when
 * pure-asm faults and the staged object is missing. Do not delete
 * these bodies. Do not gcc -E this seed as the repair.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

/* G-02f-rest：rest→.x 迁移 — 8 个函数全部包入 #ifndef，由 .x 提供权威实现 */
#ifndef XLANG_RUNTIME_STRING_FAST_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RUNTIME_STRING_FAST_FROM_X removed */
#endif /* XLANG_RUNTIME_STRING_FAST_FROM_X */
