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
/* G-02f-rest：rest→.x 迁移：3 个 slice struct + 6 个函数真迁 .x，PREFER_X_O 路径下整体跳过 */
struct xlang_slice_int32_t { int32_t *data; size_t length; };
struct xlang_slice_uint8_t  { uint8_t  *data; size_t length; };
struct xlang_slice_uint64_t { uint64_t *data; size_t length; };

/* from_ptr：直接包装 (ptr,len) 为切片，不做边界检查。结果写入 out。 */
void core_slice_i32_from_ptr_c(struct xlang_slice_int32_t *out, int32_t *data, size_t length) {
    out->data = data; out->length = length;
}
void core_slice_u8_from_ptr_c(struct xlang_slice_uint8_t *out, uint8_t *data, size_t length) {
    out->data = data; out->length = length;
}
void core_slice_u64_from_ptr_c(struct xlang_slice_uint64_t *out, uint64_t *data, size_t length) {
    out->data = data; out->length = length;
}

/* subslice：从 start 起取 len 个元素；越界钳制（start>=total → 空，尾部不足截断）。结果写入 out。 */
void core_subslice_i32_c(struct xlang_slice_int32_t *out, int32_t *data, size_t total_len, size_t start, size_t len) {
    if (start >= total_len) { out->data = data; out->length = 0; return; }
    size_t avail = total_len - start;
    if (len > avail) len = avail;
    out->data = data + start; out->length = len;
}
void core_subslice_u8_c(struct xlang_slice_uint8_t *out, uint8_t *data, size_t total_len, size_t start, size_t len) {
    if (start >= total_len) { out->data = data; out->length = 0; return; }
    size_t avail = total_len - start;
    if (len > avail) len = avail;
    out->data = data + start; out->length = len;
}
void core_subslice_u64_c(struct xlang_slice_uint64_t *out, uint64_t *data, size_t total_len, size_t start, size_t len) {
    if (start >= total_len) { out->data = data; out->length = 0; return; }
    size_t avail = total_len - start;
    if (len > avail) len = avail;
    out->data = data + start; out->length = len;
}
#endif /* XLANG_RUNTIME_SLICE_GLUE_FROM_X */
