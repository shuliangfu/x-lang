/* seeds/runtime_process_argv.from_x.c — G-02f-20 product TU
 * G-02f-106 helper gates.
 * Product: runtime_process_argv.o; logic still C until full .x port.
 */
/**
 * runtime_process_argv.c — codegen 入口 argc/argv 全局（F-ZC：自 std/process/process_arg_glue.c 迁入）
 *
 * C codegen 路径：main(int argc, char **argv) 在入口处赋值。
 * asm 用户程序 main() 无参时：constructor 从 CRT 读取 argc/argv（macOS _NSGetArgc、Linux /proc/self/cmdline）。
 * std/process/process.x 经 process_shux_argc_get / process_shux_argv_get 读取。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined(__APPLE__)
#include <crt_externs.h>
#endif

/* SHUX_WEAK：macOS/Linux 下生成 weak 符号；Windows/MinGW PE 不支持函数 weak，宏为空
 *（PE 侧靠 --allow-multiple-definition 兜底）。 */
#if defined(__GNUC__) || defined(__clang__)
#define SHUX_WEAK __attribute__((weak))
#else
#define SHUX_WEAK
#endif

/** 由 codegen 或 shux_process_argv_bind_from_crt 写入；供 process.x 经 getter 读取。 */
int shux_process_argc = 0;
char **shux_process_argv = NULL;

/* thin+rest：thin 函数在 rest 模式下由 .x 提供，前向声明供 rest 函数调用 */
void shux_process_argv_bind_from_crt(void);

/**
 * 从 CRT 绑定 argc/argv（asm 用户 main 无参、gcc -pie 链入时）。
 * 若已由 codegen 写入则 no-op。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void shux_process_argv_bind_from_crt_impl(void) {
  if (shux_process_argc > 0 && shux_process_argv != NULL)
    return;
#if defined(__APPLE__)
  shux_process_argc = *_NSGetArgc();
  shux_process_argv = *_NSGetArgv();
#elif defined(__linux__)
  {
    /* /proc/self/cmdline 常不支持 SEEK_END/ftell（得 0）→ 旧逻辑 silent no-op → argc 永 0
     * （bstrict31 run-process args）。分块读入，不依赖 seek。 */
    FILE *f;
    char *cmdline = NULL;
    size_t cap = 0;
    size_t n = 0;
    int argc;
    char **argv;
    char *p;
    char chunk[4096];
    size_t nr;
    f = fopen("/proc/self/cmdline", "rb");
    if (!f)
      return;
    while ((nr = fread(chunk, 1, sizeof chunk, f)) > 0) {
      char *grown;
      if (n + nr + 1 > 1024 * 1024) {
        free(cmdline);
        fclose(f);
        return;
      }
      grown = (char *)realloc(cmdline, n + nr + 1);
      if (!grown) {
        free(cmdline);
        fclose(f);
        return;
      }
      cmdline = grown;
      memcpy(cmdline + n, chunk, nr);
      n += nr;
    }
    fclose(f);
    if (!cmdline || n == 0) {
      free(cmdline);
      return;
    }
    cmdline[n] = '\0';
    argc = 0;
    for (p = cmdline; p < cmdline + n; p++) {
      if (*p != '\0')
        continue;
      argc++;
      if (p + 1 >= cmdline + n)
        break;
    }
    if (argc <= 0) {
      free(cmdline);
      return;
    }
    argv = (char **)calloc((size_t)argc + 1, sizeof(char *));
    if (!argv) {
      free(cmdline);
      return;
    }
    {
      int i = 0;
      p = cmdline;
      while (p < cmdline + n && i < argc) {
        argv[i++] = p;
        while (p < cmdline + n && *p != '\0')
          p++;
        p++;
      }
      shux_process_argc = argc;
      shux_process_argv = argv;
      /* cmdline 缓冲由 argv[] 指向，勿 free */
      (void)cap;
    }
  }
#endif
}

#ifndef SHUX_RUNTIME_PROCESS_ARGV_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin（src/asm/runtime_process_argv.x）提供 wrapper 调用 _impl */
void shux_process_argv_bind_from_crt(void) { shux_process_argv_bind_from_crt_impl(); }
#endif /* SHUX_RUNTIME_PROCESS_ARGV_FROM_X */




/** asm 用户程序：main 前绑定 argc/argv（优先级低于 codegen 显式赋值）。 */
__attribute__((constructor(65535))) static void shux_process_argv_ctor_bind(void) {
  shux_process_argv_bind_from_crt();
}

/**
 * 供 process.x 读取 argc（避免 .x 直接绑全局符号）。
 * 返回值：当前进程 argc（int32）。
 */
int32_t process_shux_argc_get(void) {
    return (int32_t)shux_process_argc;
}

/**
 * 供 process.x 读取 argv[i]；越界返回 NULL。
 * 参数：i 参数索引。
 * 返回值：argv[i] 指针或 NULL。
 */
uint8_t *process_shux_argv_get(int32_t i) {
    if (shux_process_argv == NULL || i < 0 || (int)i >= shux_process_argc)
        return NULL;
    return (uint8_t *)shux_process_argv[i];
}

/**
 * std/process/process.x 同名热路径；weak fallback 供 minimal 链（C -o 路径不经 process.x 编译时）。
 * 【Why 根源】process.x 编译出强符号 process_args_count_c；本 TU 经 ld -r 合并进 process.o
 * 时若也是强符号 → duplicate symbol。weak 让链接器优先选 process.x 强符号，本定义仅在
 * 未链 process.o 的 minimal 场景下被解析。
 * 【Invariant】weak 定义与 process.x 强符号实现等价（都转调 process_shux_argc_get），
 * 覆盖与否不影响行为。
 * 返回值：命令行参数个数（含 argv[0]）。
 */
SHUX_WEAK int32_t process_args_count_c(void) {
    return process_shux_argc_get();
}

/**
 * std/process/process.x 同名热路径；weak fallback（见上 process_args_count_c 说明）。
 * 【Why】同上 — 让 process.x 强符号覆盖，避免 ld -r 合并 duplicate symbol。
 * 参数：i — 参数索引。
 * 返回值：argv[i] C 字符串指针；越界返回 NULL。
 */
SHUX_WEAK uint8_t *process_arg_c(int32_t i) {
    return process_shux_argv_get(i);
}
