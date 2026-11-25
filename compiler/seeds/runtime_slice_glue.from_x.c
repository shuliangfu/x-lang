/* seeds/runtime_slice_glue.from_x.c — G-02f-22 product TU
 * w1100: Darwin arm64 product body is src/asm/runtime_slice_glue.x
 * (pure asm). Linux, Windows, and the pure-asm-fault backup stay this seed.
 * PLATFORM: SHARED seed; MACOS|DARWIN arm64 prefers the .x.
 */
/* compiler/src/asm/runtime_slice_glue.c — slice 构造薄封装（语言限制 C 桩）
 *
 * 【Why 根源】XLANG parser/codegen 暂不支持 slice 复合字面量（[]i32 { data, length }），
 * 也不支持范围切片（arr[0..n]）。core/slice/mod.x 的 subslice_i32 / chunk_i32 / split_at_i32
 * 等零拷贝视图须经本 TU 构造切片。布局与 codegen 生成的
 * struct xlang_slice_<T>_t { T *data; size_t length; } 一致（16 字节，经 out 写入）。
 *
 * 【Invariant】data 指向至少 total_len 个 T 元素的可读缓冲；start/len 不越界（subslice 内部钳制）。
 * out 非空，写入与 codegen 的 struct xlang_slice_<T>_t 相同的 16 字节布局。
 * 按值返回在已装编译器上写不出来，所以 .x 与本种子都改成 out 指针。链接名不变。
 * 【Asm/Perf】6 个函数均为指针加法 + 一次 16 字节存储。
 *
 * 从 core/slice/slice.c 迁入（G-01：core/ 零 C）。待 codegen 补齐 slice 字面量后迁移回 .x。
 */
#include <stdint.h>
#include <stddef.h>

#ifndef XLANG_RUNTIME_SLICE_GLUE_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RUNTIME_SLICE_GLUE_FROM_X removed */
#endif /* XLANG_RUNTIME_SLICE_GLUE_FROM_X */
