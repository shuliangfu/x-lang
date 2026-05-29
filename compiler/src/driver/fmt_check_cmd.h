/**
 * fmt_check_cmd.h — shu fmt / shu check 子命令（对标 deno fmt、deno check 的 CLI 行为）
 *
 * fmt：无参数时递归格式化当前目录下 .su；--check 仅校验；--fail-fast；--ignore=前缀列表。
 * check：支持多文件/目录；收集诊断并以 path:line:col - error: 输出。
 */

#ifndef SHU_FMT_CHECK_CMD_H
#define SHU_FMT_CHECK_CMD_H

#include <stdint.h>

/** 运行 shu fmt；解析 argv（含子命令后的参数）；0 成功，1 失败。 */
int driver_run_fmt(int argc, char **argv);

/** 运行 shu check；0 成功，1 失败。 */
int driver_run_compiler_check(int argc, char **argv);

/** 设置当前 check 源文件路径（诊断行前缀）。 */
void driver_check_set_current_file(const char *path);

/** 将已收集的 LSP 诊断打印到 stderr（deno 风格）；返回诊断条数。 */
int driver_check_print_collected_diagnostics(const char *path);

/** 非 0 时 driver_print_check_ok 不输出（deno check 全通过时静默）。 */
int driver_check_quiet_ok_get(void);

#endif /* SHU_FMT_CHECK_CMD_H */
