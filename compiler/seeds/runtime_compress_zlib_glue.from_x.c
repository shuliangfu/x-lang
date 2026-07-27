/* seeds/runtime_compress_zlib_glue.from_x.c — G-02f-21 product TU
 *
 * R2 migration architecture:
 *   - thin (.x): public deflateInit2 / inflateInit2 wrappers (#[no_mangle],
 *     no _c suffix to match libz.x extern declarations)
 *     (XLANG_RUNTIME_COMPRESS_ZLIB_GLUE_FROM_X)
 *   - rest (this file, always compiled): deflateInit2_impl_c /
 *     inflateInit2_impl_c bridges that #include <zlib.h>, #undef the macros,
 *     and call the real deflateInit2_ / inflateInit2_ with ZLIB_VERSION and
 *     sizeof(z_stream).
 *
 * Cold path (no guard): this file provides both the public wrappers + _impl.
 * R2 path: this file provides only the _impl bridges; the wrappers come
 * from .x.
 */
/**
 * runtime_compress_zlib_glue.c — zlib 宏包装桩
 *
 * 【Why 逻辑根源】zlib.h 中 deflateInit2/inflateInit2 是宏，展开为
 * deflateInit2_/inflateInit2_（带 ZLIB_VERSION 和 sizeof(z_stream) 参数）。
 * XLANG 生成 C 不包含 zlib.h，直接调用 deflateInit2 链接器找不到符号。
 * 此桩包含 zlib.h 后 #undef 宏，提供与 XLANG extern 声明同名的真实函数符号，
 * 内部调用 deflateInit2_/inflateInit2_ 完成宏展开等价行为。
 *
 * 【Invariant】包装函数签名与 libz.x 中 extern 声明完全一致；
 * ZStream 用 allow(padding) 对齐 C z_stream，内存布局兼容；
 * 用 void * 接收指针以避免跨 TU 类型不匹配告警，链接期仅匹配符号名。
 *
 * 【Asm/Perf】仅转发调用，cc -O2 内联展开为 jmp deflateInit2_，零开销。
 */
#include <zlib.h>

/* 撤销 zlib.h 中的宏定义，使下方函数名不被展开 */
#undef deflateInit2
#undef inflateInit2

/* === R2 _impl bridges (always compiled, both cold and R2 paths use them) ===
 * #include <zlib.h> and call the real deflateInit2_ / inflateInit2_ with
 * ZLIB_VERSION and sizeof(z_stream).
 *
 * 【Why 根因】.x 无法 #include <zlib.h>，无法获取 ZLIB_VERSION /
 * sizeof(z_stream) / deflateInit2_ 符号声明。此 _impl_c 桥被 thin (.x) 的
 * deflateInit2 / inflateInit2 wrappers 调用。
 *
 * 【Invariant】strm 指向有效 z_stream（ZStream in libz.x）；调用方约定
 * 内存布局兼容。
 *
 * 【Asm/Perf】仅转发调用，cc -O2 内联展开为 jmp deflateInit2_，零开销。 */
int deflateInit2_impl_c(void *strm, int level, int method, int windowBits, int memLevel, int strategy) {
    return deflateInit2_((z_streamp)strm, level, method, windowBits, memLevel, strategy,
                         ZLIB_VERSION, (int)sizeof(z_stream));
}

int inflateInit2_impl_c(void *strm, int windowBits) {
    return inflateInit2_((z_streamp)strm, windowBits,
                         ZLIB_VERSION, (int)sizeof(z_stream));
}

#ifndef XLANG_RUNTIME_COMPRESS_ZLIB_GLUE_FROM_X
/* Cold path public wrappers: when XLANG_RUNTIME_COMPRESS_ZLIB_GLUE_FROM_X is
 * NOT defined, these wrappers provide the full implementation (call _impl_c).
 * When the guard IS defined, the thin (.x) provides the wrappers and calls
 * _impl_c above.
 *
 * 包装 deflateInit2 宏：调用真实 deflateInit2_ 并传入版本和结构体大小。
 * 参数与 libz.x extern function deflateInit2 完全一致。 */
int deflateInit2(void *strm, int level, int method, int windowBits, int memLevel, int strategy) {
    return deflateInit2_impl_c(strm, level, method, windowBits, memLevel, strategy);
}

/**
 * 包装 inflateInit2 宏：调用真实 inflateInit2_ 并传入版本和结构体大小。
 * 参数与 libz.x extern function inflateInit2 完全一致。
 */
int inflateInit2(void *strm, int windowBits) {
    return inflateInit2_impl_c(strm, windowBits);
}
#endif /* !XLANG_RUNTIME_COMPRESS_ZLIB_GLUE_FROM_X */
