/**
 * std/regex/regex.c — 最小正则（STD-051 纯 C 引擎）
 *
 * 【文件职责】compile / match / free / capture group API；全平台链入 regex_min.inc.c，
 * 无 POSIX regex.h 依赖，Windows 与 Unix 行为一致。
 * 【所属模块】std.regex；与 std/regex/mod.sx 同属一模块。
 */

#include "regex_min.inc.c"
