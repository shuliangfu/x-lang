/**
 * runtime_process_argv.c — codegen 入口 argc/argv 全局（F-ZC：自 std/process/process_arg_glue.c 迁入）
 *
 * 由 codegen 生成的 main(int argc, char **argv) 在入口处赋值；
 * std/process/process.sx 经 process_shux_argc_get / process_shux_argv_get 读取。
 */
#include <stddef.h>
#include <stdint.h>

/** 由 codegen 写入；供 process.sx 经 getter 读取。 */
int shux_process_argc = 0;
char **shux_process_argv = NULL;

/**
 * 供 process.sx 读取 argc（避免 .sx 直接绑全局符号）。
 * 返回值：当前进程 argc（int32）。
 */
int32_t process_shux_argc_get(void) {
    return (int32_t)shux_process_argc;
}

/**
 * 供 process.sx 读取 argv[i]；越界返回 NULL。
 * 参数：i 参数索引。
 * 返回值：argv[i] 指针或 NULL。
 */
uint8_t *process_shux_argv_get(int32_t i) {
    if (shux_process_argv == NULL || i < 0 || (int)i >= shux_process_argc)
        return NULL;
    return (uint8_t *)shux_process_argv[i];
}
