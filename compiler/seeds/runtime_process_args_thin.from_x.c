/* seeds/runtime_process_args_thin.from_x.c — process_args_count_c / process_arg_c
 *
 * 【Why 根源】product `-x -E` 对库模块（无 main）当前会在巨型 rt_preamble 写入后
 * 提前结束函数体 emit（观测：stdout 在 16KiB/20KiB 页对齐处截断，codegen_bytes
 * 远小于文件长，中途符号如 process_gete…）。std/process/process.x 仅两行薄封装，
 * 在 -E 修好前用本 seed 提供权威 process_args_*_c，与 process.x 语义 1:1。
 *
 * process.o = 本 TU + runtime_process_argv.o + runtime_process_os_glue.o。
 * 用户 import("std.process") 的 std_process_* API 由 co-emit mod.x 提供，不进 process.o。
 *
 * 【Invariant】符号名 process_args_count_c / process_arg_c；实现只转发 argv 胶层。
 * 待 -x -E 库模块全量 emit 恢复后，可改回 shux_compile_std_module process.x 并删本文件。
 */
#include <stdint.h>

extern int32_t process_shux_argc_get(void);
extern uint8_t *process_shux_argv_get(int32_t i);

int32_t process_args_count_c(void) {
    return process_shux_argc_get();
}

uint8_t *process_arg_c(int32_t i) {
    return process_shux_argv_get(i);
}
