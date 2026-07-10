/* seeds/runtime_compress_zlib_glue.from_x.c — G-02f-21 product TU
 * Logic still C until full .x port.
 */
/**
 * runtime_compress_zlib_glue.c — zlib 宏包装桩
 *
 * 【Why 逻辑根源】zlib.h 中 deflateInit2/inflateInit2 是宏，展开为
 * deflateInit2_/inflateInit2_（带 ZLIB_VERSION 和 sizeof(z_stream) 参数）。
 * SHUX 生成 C 不包含 zlib.h，直接调用 deflateInit2 链接器找不到符号。
 * 此桩包含 zlib.h 后 #undef 宏，提供与 SHUX extern 声明同名的真实函数符号，
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

/**
 * 包装 deflateInit2 宏：调用真实 deflateInit2_ 并传入版本和结构体大小。
 * 参数与 libz.x extern function deflateInit2 完全一致。
 */
int deflateInit2(void *strm, int level, int method, int windowBits, int memLevel, int strategy) {
    return deflateInit2_((z_streamp)strm, level, method, windowBits, memLevel, strategy,
                         ZLIB_VERSION, (int)sizeof(z_stream));
}

/**
 * 包装 inflateInit2 宏：调用真实 inflateInit2_ 并传入版本和结构体大小。
 * 参数与 libz.x extern function inflateInit2 完全一致。
 */
int inflateInit2(void *strm, int windowBits) {
    return inflateInit2_((z_streamp)strm, windowBits,
                         ZLIB_VERSION, (int)sizeof(z_stream));
}
