/**
 * std/path/path.c — 平台主路径分隔符（STD-021）
 *
 * 与 std/path/mod.sx 同目录；链接用户程序时由 runtime 链入 path.o。
 * path_sep_c：POSIX 返回 '/'(47)，Windows 返回 '\\'(92)。
 */
#include <stdint.h>

/** 返回当前平台主路径分隔符（ASCII）。 */
uint8_t path_sep_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 92;
#else
    return 47;
#endif
}
