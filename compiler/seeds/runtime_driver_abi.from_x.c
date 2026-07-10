/* Generated from src/runtime_driver_abi.x (G-02f-29/41/45 true .x + C tail).
 * Regen: ./shux-c -E -L .. src/runtime_driver_abi.x > /tmp/dabi.c
 *         merge flags/env/skip_large/large_stack; C slots + pthread timing.
 * .x covers: quiet_ok, env probes, flag get/set, typeck_skip_large_entry, large_stack mark.
 */
#include "win32_compat.h"
#include "runtime_driver_abi.h"
#include "runtime_io_abi.h"
#include "runtime_pipeline_abi.h"
#include "runtime_abi.h"
#include "diag.h"
#include "runtime_diag_codes.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* SHUX_WEAK: POSIX 用 weak attribute；Windows/MinGW 不支持 weak 函数符号，改为正常定义，
 * 配合 Makefile 的 -Wl,--allow-multiple-definition 解决重复定义冲突。 */
#ifndef SHUX_WEAK
#if defined(_WIN32) || defined(_WIN64)
#define SHUX_WEAK
#else
#define SHUX_WEAK __attribute__((weak))
#endif
#endif
#ifndef _WIN32
#include <sys/time.h>
#include <sys/utsname.h>
#ifndef _WIN32
#include <sys/resource.h>
#endif
#endif
#include <pthread.h>

/** nostdlib 下勿用 glibc ctype 宏（会引用 __ctype_toupper_loc）；本地 ASCII 大写。 */
static char driver_ascii_toupper(char c) {
    if (c >= 'a' && c <= 'z')
        return (char)(c + ('A' - 'a'));
    return c;
}


/* G-02f-41: flag slot protos (defs after static storage) */
int32_t *driver_check_only_flag_slot(void);
int32_t *driver_check_diag_emitted_flag_slot(void);
int32_t *driver_freestanding_flag_slot(void);
int32_t *driver_sanitize_address_flag_slot(void);
int32_t *driver_fmt_check_only_flag_slot(void);
int32_t *driver_x_pipeline_skip_typeck_flag_slot(void);
int32_t *driver_x_pipeline_skip_codegen_flag_slot(void);
int32_t *driver_skip_codegen_dep_0_flag_slot(void);
int32_t driver_pipeline_entry_source_len_i32(void);
int32_t *driver_large_stack_thread_flag_slot(void);

/** shux check：非 0 时 typeck 通过后跳过 codegen 与链接（C 与 X pipeline 共用）。 */
static int driver_check_only_flag;
static int driver_check_diag_emitted_flag;

/**
 * 设置 check-only 模式。
 * 参数：v 非 0 启用。
 */
void driver_check_only_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_check_only_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}

/**
 * 查询 check-only 模式。
 * 返回值：1 表示启用，0 表示否。
 */
int32_t driver_check_only_get(void) {
  (void)(({   {
    int32_t * p = driver_check_only_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

void driver_check_diag_emitted_reset(void) {
  (void)(({   {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    (void)(((p)[0] = 0));
  }
 }));
}

void driver_check_diag_emitted_note(void) {
  (void)(({   {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    (void)(((p)[0] = 1));
  }
 }));
}

int32_t driver_check_diag_emitted_get(void) {
  (void)(({   {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/** `-freestanding` / SHUX_FREESTANDING：用户程序 nostdlib 静态链（S4）。 */
static int driver_freestanding_flag;

/** 设置 freestanding 链接模式。 */
void driver_freestanding_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_freestanding_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}

/** 查询 freestanding 链接模式。 */
int32_t driver_freestanding_get(void) {
  (void)(({   {
    int32_t * p = driver_freestanding_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/** M-6：`-fsanitize=address` 时强制数组/切片 INDEX 边界检查。 */
static int driver_sanitize_address_flag;

/** 设置 sanitize=address 标志。 */
void driver_sanitize_address_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_sanitize_address_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}

/**
 * 查询 sanitize=address；显式标志或 SHUX_SANITIZE_ADDRESS 环境变量。
 * 返回值：1 表示启用边界检查插桩。
 */
int32_t driver_sanitize_address_get(void) {
  (void)(({   {
    int32_t * p = driver_sanitize_address_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    char *e = getenv("SHUX_SANITIZE_ADDRESS");
    if ((e ==((char *)(0)))) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
 }));
  return 0;
}

static int driver_fmt_check_only_flag;

/** shux fmt --check：仅校验格式，不写回。 */
void driver_fmt_check_only_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_fmt_check_only_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}

/** 查询 fmt --check 模式。 */
int32_t driver_fmt_check_only_get(void) {
  (void)(({   {
    int32_t * p = driver_fmt_check_only_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/* 【Why 根源】MinGW PE 格式不真正支持 __attribute__((weak))：weak 函数被当作普通强符号，
 * 与 fmt_check_cmd.c 的强符号并存；--allow-multiple-definition 选第一个遇到的定义，
 * 链接器不保证按 OBJS_CORE 顺序选 fmt_check_cmd.o 的版本。当 weak 版本被选中且返回 0，
 * check 成功后会逐文件打印 "check OK"，与 deno check 静默成功语义矛盾。
 * 【Invariant】deno check 语义：成功时静默。weak 默认值必须返回 1（静默），保证无论
 * Windows 链接器选中哪个版本，driver_print_check_ok 都不输出逐文件 check OK。
 * 【Asm/Perf】macOS/Linux 上 weak 正常工作，强符号覆盖 weak 默认值，此改动无影响。 */
SHUX_WEAK int32_t driver_check_quiet_ok_get(void) {
  return 1;
}

/**
 * 统一 shux check 成功行；deno 风格批量 check 成功时由 fmt_check_cmd 保持静默。
 * 参数：input_path 被检查文件路径（可为 NULL）。
 */
void driver_print_check_ok(const char *input_path) {
    if (driver_check_quiet_ok_get())
        return;
    diag_reportf(NULL, 0, 0, "info", NULL,
                 "check OK: %s", input_path ? input_path : "?");
}

/** 非 0 时 pipeline_impl_typecheck 跳过 .x typeck。 */
static int driver_x_pipeline_skip_typeck_flag;

/** 供 pipeline.x 读取：是否跳过 X typeck。 */
int32_t driver_x_pipeline_skip_typeck_get(void) {
  (void)(({   {
    int32_t * p = driver_x_pipeline_skip_typeck_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/** 设置 X typeck 跳过标志（C 预检后由 runtime 置位/清位）。 */
void driver_x_pipeline_skip_typeck_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_x_pipeline_skip_typeck_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}

/** 非 0 时 pipeline_impl_run_all 跳过 .x C codegen。 */
static int driver_x_pipeline_skip_codegen_flag;

/** 供 pipeline.x 读取：是否跳过 X C codegen。 */
int32_t driver_x_pipeline_skip_codegen_get(void) {
  (void)(({   {
    int32_t * p = driver_x_pipeline_skip_codegen_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/** 设置 X C codegen 跳过标志。 */
void driver_x_pipeline_skip_codegen_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_x_pipeline_skip_codegen_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}

/**
 * 非 0 时入口模块 typeck 走 C 的 typeck_module（大模块 asm 构建时避免 .x typeck 栈过深）。
 * 返回值：1 表示 SHUX_TYPECK_FORCE_C 已启用。
 */
int32_t driver_typeck_force_c_enabled(void) {
  (void)(({   {
    char *e = getenv("SHUX_TYPECK_FORCE_C");
    if ((e ==((char *)(0)))) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
 }));
  return 0;
}

/** 当前线程是否已在 driver_run_thread_on_large_stack 创建的大栈 pthread 内。 */
static _Thread_local int g_driver_on_large_stack_thread;

/* G-02f-45 */
int32_t *driver_large_stack_thread_flag_slot(void) {
    return (int32_t *)&g_driver_on_large_stack_thread;
}


/**
 * 供 ast_pool / pipeline glue 查询：LSP 主循环已在大栈线程上时，typeck 勿再 spawn 嵌套 pthread。
 * 返回值：非 0 表示当前在大栈线程上下文。
 */

int32_t driver_is_large_stack_thread(void) {
  (void)(({   {
    int32_t * p = driver_large_stack_thread_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/**
 * 标记当前线程大栈上下文（runtime pthread trampoline 进入/退出时调用）。
 * 参数：on 非 0 进入，0 退出。
 */
void driver_large_stack_thread_mark(int on) {
  (void)(({   {
    int32_t * p = driver_large_stack_thread_flag_slot();
    (void)(((p)[0] = on));
  }
 }));
}

/** 当前 pipeline 入口源码长度；供 .x 按体积跳过大库 merge/typeck。 */
static size_t g_pipeline_entry_source_len;

/* G-02f-45 */
int32_t driver_pipeline_entry_source_len_i32(void) {
    if (g_pipeline_entry_source_len > (size_t)0x7fffffff)
        return 0x7fffffff;
    return (int32_t)g_pipeline_entry_source_len;
}


/**
 * 记录 pipeline 入口源码字节数（大栈 pthread 进入 pipeline 前调用）。
 * 参数：len 预处理后的入口源码长度。
 */
void driver_set_pipeline_entry_source_len(size_t len) {
    g_pipeline_entry_source_len = len;
}

/**
 * 查询当前记录的入口源码长度；SHUX_DEBUG_PIPE=1 时打印。
 * 返回值：最近一次 driver_set_pipeline_entry_source_len 写入的长度。
 */
size_t driver_pipeline_entry_source_len(void) {
    if (getenv("SHUX_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: entry_source_len_global=%zu", g_pipeline_entry_source_len);
    return g_pipeline_entry_source_len;
}

/**
 * 非 0 表示入口源码过大，应跳过 merge/library 全量 typeck（.x 路径上易 segfault）。
 * 返回值：len > 150000 时为 1，否则 0。
 */
int32_t driver_typeck_skip_large_entry(void) {
  (void)(({   {
    int32_t len = driver_pipeline_entry_source_len_i32();
    if ((len > 150000)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/**
 * build_shux_asm 单模块 -o：SHUX_ASM_BUILD_SKIP_TYPECK=1 时跳过 .x typeck。
 * 返回值：环境变量非空且非 '0' 时为 1。
 */
int32_t driver_asm_build_skip_typeck(void) {
  (void)(({   {
    char *e = getenv("SHUX_ASM_BUILD_SKIP_TYPECK");
    if ((e ==((char *)(0)))) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
 }));
  return 0;
}

/**
 * typeck 第二遍 EMIT_HEAVY：SHUX_ASM_ENTRY_EMIT_HEAVY=1 时 pipeline 跳过文本 asm codegen。
 * 返回值：环境变量非空且非 '0' 时为 1。
 */
int32_t driver_asm_entry_emit_heavy(void) {
  (void)(({   {
    char *e = getenv("SHUX_ASM_ENTRY_EMIT_HEAVY");
    if ((e ==((char *)(0)))) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
 }));
  return 0;
}

/**
 * build_shux_asm 单模块 -o：SHUX_ASM_ENTRY_MODULE_ONLY=1 时仅编入口模块。
 * 返回值：环境变量非空且非 '0' 时为 1。
 */
int32_t driver_asm_entry_module_only_from_env(void) {
  (void)(({   {
    char *e = getenv("SHUX_ASM_ENTRY_MODULE_ONLY");
    if ((e ==((char *)(0)))) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
 }));
  return 0;
}

/**
 * A-11 typeck-parse-count-gate：仅采集 parse 指标，不跑 pipeline/asm_codegen_elf_o。
 * 返回值：SHUX_ASM_PARSE_METRIC_ONLY 非空且非 '0' 时为 1。
 */
int32_t driver_asm_parse_metric_only_from_env(void) {
  (void)(({   {
    char *e = getenv("SHUX_ASM_PARSE_METRIC_ONLY");
    if ((e ==((char *)(0)))) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
 }));
  return 0;
}

/** -o 可执行文件路径：非 0 时 pipeline 跳过 dep 0 的 codegen。 */
static int driver_skip_codegen_dep_0_flag;

/* G-02f-41: flag slot implementations */
int32_t *driver_check_only_flag_slot(void) { return (int32_t *)&driver_check_only_flag; }
int32_t *driver_check_diag_emitted_flag_slot(void) { return (int32_t *)&driver_check_diag_emitted_flag; }
int32_t *driver_freestanding_flag_slot(void) { return (int32_t *)&driver_freestanding_flag; }
int32_t *driver_sanitize_address_flag_slot(void) { return (int32_t *)&driver_sanitize_address_flag; }
int32_t *driver_fmt_check_only_flag_slot(void) { return (int32_t *)&driver_fmt_check_only_flag; }
int32_t *driver_x_pipeline_skip_typeck_flag_slot(void) { return (int32_t *)&driver_x_pipeline_skip_typeck_flag; }
int32_t *driver_x_pipeline_skip_codegen_flag_slot(void) { return (int32_t *)&driver_x_pipeline_skip_codegen_flag; }
int32_t *driver_skip_codegen_dep_0_flag_slot(void) { return (int32_t *)&driver_skip_codegen_dep_0_flag; }


/** 设置 skip_codegen_dep_0 标志（driver -o exe 路径）。 */
void driver_skip_codegen_dep_0_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_skip_codegen_dep_0_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}

/** 查询 skip_codegen_dep_0；pipeline.x dep_j==0 时读取。 */
int32_t driver_skip_codegen_dep_0_get(void) {
  (void)(({   {
    int32_t * p = driver_skip_codegen_dep_0_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/** 当前 codegen 的 dep 逻辑路径（如 std.io.driver），供 .x codegen 前缀 C 符号。 */
static const char *driver_current_dep_path_for_codegen;

/**
 * 设置当前 dep 路径；pipeline codegen 循环每 dep 调用。
 * 参数：path import 逻辑路径或 NULL 清槽。
 */
void driver_set_current_dep_path_for_codegen(const char *path) {
    driver_current_dep_path_for_codegen = path;
}

/** 查询当前 dep 路径；ast_pool / codegen 生成 C 符号前缀时读取。 */
const char *driver_get_current_dep_path_for_codegen(void) {
    return driver_current_dep_path_for_codegen;
}

/** OBS-001：编译阶段耗时；phase 0=parse 1=typeck 2=codegen。 */
#define SHUX_COMPILE_PHASE_MAX 3

static double g_compile_phase_acc_ms[SHUX_COMPILE_PHASE_MAX];
static double g_compile_phase_start_sec[SHUX_COMPILE_PHASE_MAX];
static int g_compile_phase_active[SHUX_COMPILE_PHASE_MAX];

/** 是否启用 SHUX_COMPILE_PHASE_TIMING 阶段计时。 */
static int compile_phase_timing_enabled(void) {
    return getenv("SHUX_COMPILE_PHASE_TIMING") != NULL;
}

/** 单调 wall-clock 秒（gettimeofday）。 */
static double compile_phase_now_sec(void) {
    struct timeval tv;
    #ifndef _WIN32
    gettimeofday(&tv, NULL);
#else
    time_t t = time(NULL); tv.tv_sec = (long)t; tv.tv_usec = 0;
#endif
    return (double)tv.tv_sec + (double)tv.tv_usec * 1e-6;
}

/**
 * 标记编译阶段开始；由 pipeline.x run_x_pipeline_impl 调用。
 * 参数：phase 0..2。
 */
void driver_compile_phase_timing_begin(int32_t phase) {
    if (!compile_phase_timing_enabled() || phase < 0 || phase >= SHUX_COMPILE_PHASE_MAX)
        return;
    g_compile_phase_start_sec[phase] = compile_phase_now_sec();
    g_compile_phase_active[phase] = 1;
}

/**
 * 累加阶段耗时（毫秒）；同 phase 可多次 begin/end 叠加。
 * 参数：phase 0..2。
 */
void driver_compile_phase_timing_end(int32_t phase) {
    if (!compile_phase_timing_enabled() || phase < 0 || phase >= SHUX_COMPILE_PHASE_MAX || !g_compile_phase_active[phase])
        return;
    g_compile_phase_acc_ms[phase] += (compile_phase_now_sec() - g_compile_phase_start_sec[phase]) * 1000.0;
    g_compile_phase_active[phase] = 0;
}

/** 打印 parse/typeck/codegen/total 毫秒汇总行并清零；SHUX_COMPILE_PHASE_TIMING 启用时生效。 */
void driver_compile_phase_timing_flush(void) {
    if (!compile_phase_timing_enabled())
        return;
    double total = g_compile_phase_acc_ms[0] + g_compile_phase_acc_ms[1] + g_compile_phase_acc_ms[2];
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "compile phase timing: parse_ms=%.3f typeck_ms=%.3f codegen_ms=%.3f total_ms=%.3f",
                 g_compile_phase_acc_ms[0], g_compile_phase_acc_ms[1], g_compile_phase_acc_ms[2], total);
    memset(g_compile_phase_acc_ms, 0, sizeof(g_compile_phase_acc_ms));
    memset(g_compile_phase_active, 0, sizeof(g_compile_phase_active));
}

/**
 * 从 argv 收集 -D / -DFOO 与 -target 推导 OS_*、uname 的 SHUX_OS_/SHUX_ARCH_（run_compiler_c / asm 后端共用）。
 * 参数：defines 至少 max_defines 个槽；返回 ndefines。
 */
int driver_argv_collect_defines(int argc, char **argv, const char **defines, int max_defines) {
    int ndefines = 0;
    const char *target_arg = NULL;
    for (int i = 1; i < argc; i++) {
        if (!argv[i])
            continue;
        if (strcmp(argv[i], "-D") == 0) {
            if (i + 1 >= argc)
                continue;
            if (ndefines < max_defines)
                defines[ndefines++] = argv[i + 1];
            i++;
        } else if (strncmp(argv[i], "-D", 2) == 0 && argv[i][2] != '\0') {
            if (ndefines < max_defines)
                defines[ndefines++] = argv[i] + 2;
        } else if (strcmp(argv[i], "-target") == 0 && i + 1 < argc) {
            target_arg = argv[i + 1];
            i++;
        } else if (strcmp(argv[i], "-o") == 0 || strcmp(argv[i], "-L") == 0 || strcmp(argv[i], "-O") == 0 ||
                   strcmp(argv[i], "-backend") == 0) {
            if (i + 1 < argc)
                i++;
        }
    }
    if (target_arg && ndefines < max_defines) {
        if (strstr(target_arg, "linux") != NULL)
            defines[ndefines++] = "OS_LINUX";
        else if (strstr(target_arg, "darwin") != NULL || strstr(target_arg, "apple") != NULL)
            defines[ndefines++] = "OS_MACOS";
        else if (strstr(target_arg, "freebsd") != NULL)
            defines[ndefines++] = "OS_FREEBSD";
        else if (strstr(target_arg, "windows") != NULL)
            defines[ndefines++] = "OS_WINDOWS";
    }
    if (ndefines + 2 <= max_defines) {
        struct utsname u;
        static char shu_os_def[80], shu_arch_def[80];
        if (uname(&u) == 0) {
            snprintf(shu_os_def, sizeof shu_os_def, "SHUX_OS_%s", u.sysname);
            snprintf(shu_arch_def, sizeof shu_arch_def, "SHUX_ARCH_%s", u.machine);
            for (char *p = shu_os_def + 7; *p; p++)
                *p = driver_ascii_toupper(*p);
            for (char *p = shu_arch_def + 9; *p; p++)
                *p = driver_ascii_toupper(*p);
            defines[ndefines++] = shu_os_def;
            defines[ndefines++] = shu_arch_def;
        }
    }
    return ndefines;
}

/** pipeline_gen.c / main.x：module num_funcs 与 main 下标。 */
extern int driver_get_module_num_funcs(void *m);
extern int driver_get_module_main_func_index(void *m);

/** pipeline 失败 rc 诊断；rc==-7 时打印 resolve 尝试路径。 */
void driver_pipeline_fail_code(int rc, const uint8_t *path) {
    diag_reportf_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP003, NULL,
                           "pipeline failed rc=%d", rc);
    if (rc == -7 && path != NULL) {
        diag_reportf_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP004, NULL,
                               "resolve path tried: %s", (const char *)path);
    }
}

/**
 * .x pipeline 烟测 stderr 摘要；保留 parse OK / typeck OK 前缀供 run-import gate grep。
 * 参数：module ASTModule*；codegen_len 产出字节数（可为 0）。
 */
void driver_print_x_smoke_summary(void *module, size_t codegen_len) {
    if (driver_check_diag_emitted_get())
        return;
    int num_funcs = driver_get_module_num_funcs(module);
    int main_ix = driver_get_module_main_func_index(module);
    diag_reportf(NULL, 0, 0, "info", NULL,
                 "parse OK: num_funcs=%d main_idx=%d codegen_bytes=%zu",
                 num_funcs, main_ix, codegen_len);
    if (num_funcs <= 0) {
        diag_report_with_code(NULL, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001,
                    "parse produced no functions in module", NULL);
        return;
    }
    diag_report(NULL, 0, 0, "info", "typeck OK", NULL);
}

/**
 * B-20：读源文件前缀到 content（最多 cap-1 字节）；成功返回读入字节数，失败 -1。
 * 参数：path 源路径；content/cap 输出缓冲；实现委托 runtime_io_abi。
 */
int driver_peek_source_file(const char *path, char *content, size_t cap) {
    if (!path || !content || cap <= 1)
        return -1;
    return shux_read_file_into_path(path, content, cap - 1);
}

/**
 * 大模块 pipeline 栈帧深；macOS 默认 RLIMIT_STACK 约 512KiB～8MiB，进入 pipeline 前抬高软上限。
 * NL-07 nostdlib：pthread 大栈桩无效，须把主线程软上限抬到 256MiB 以免 -o 编译栈溢出 SIGSEGV。
 */
void driver_bump_stack_limit(void) {
    #ifndef _WIN32
    struct rlimit rl;
    rlim_t want = (rlim_t)(512 * 1024 * 1024);
    const char *mb_env = getenv("SHUX_STACK_LIMIT_MB");
    if (mb_env && mb_env[0]) {
        unsigned long mb = strtoul(mb_env, NULL, 10);
        if (mb >= 64 && mb <= 8192)
            want = (rlim_t)mb * (rlim_t)(1024 * 1024);
    }
    if (bootstrap_nostdlib_pthread_is_stub())
        want = (rlim_t)(512 * 1024 * 1024);
    if (getrlimit(RLIMIT_STACK, &rl) == 0 && rl.rlim_cur < want) {
        rl.rlim_cur = want;
        if (rl.rlim_max > (rlim_t)0 && rl.rlim_cur > rl.rlim_max)
            rl.rlim_cur = rl.rlim_max;
        (void)setrlimit(RLIMIT_STACK, &rl);
    }
    #endif
}

/** pthread 大栈调用参数（trampoline 解包 fn/arg）。 */
typedef struct {
    void *(*fn)(void *);
    void *arg;
} DriverLargeStackCall;

/** pthread 入口：标记大栈线程并抬高 soft limit 后执行用户 fn。 */
static void *driver_large_stack_thread_trampoline(void *v) {
    DriverLargeStackCall *c = (DriverLargeStackCall *)v;
    driver_large_stack_thread_mark(1);
    driver_bump_stack_limit();
    void *r = c->fn(c->arg);
    driver_large_stack_thread_mark(0);
    return r;
}

/** 在当前线程直接执行 fn(arg)，并临时标记大栈上下文。 */
static void driver_run_fn_on_current_large_stack(void *(*fn)(void *), void *arg) {
    driver_large_stack_thread_mark(1);
    driver_bump_stack_limit();
    fn(arg);
    driver_large_stack_thread_mark(0);
}

/**
 * 在大栈 pthread 上执行 fn(arg)；默认 256MiB，可用 SHUX_STACK_LIMIT_MB 覆盖。
 * macOS 主线程 RLIMIT_STACK 硬顶约 8MiB，深递归 pipeline/typeck 须与大 pipeline 同路径。
 */
void driver_run_thread_on_large_stack(void *(*fn)(void *), void *arg) {
    pthread_attr_t attr;
    pthread_t tid;
    void *stk = NULL;
    size_t stack_sz = (size_t)256 * 1024 * 1024;
    const char *mb_env = getenv("SHUX_STACK_LIMIT_MB");
    if (mb_env && mb_env[0]) {
        unsigned long mb = strtoul(mb_env, NULL, 10);
        if (mb >= 64 && mb <= 8192)
            stack_sz = (size_t)mb * (size_t)(1024 * 1024);
    }
    const char *no_large = getenv("SHUX_PIPELINE_NO_LARGE_STACK");
    DriverLargeStackCall call = { fn, arg };
    if (driver_is_large_stack_thread()) {
        fn(arg);
        return;
    }
    driver_bump_stack_limit();
    /*
     * NL-07 nostdlib：bootstrap pthread 桩同步跑在当前栈上，256MiB posix_memalign 栈不会生效；
     * 依赖 driver_bump_stack_limit(256MiB) 在当前线程跑 pipeline，避免栈溢出 SIGSEGV。
     */
    if (bootstrap_nostdlib_pthread_is_stub()) {
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    if (no_large != NULL && no_large[0] != '\0' && no_large[0] != '0') {
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    if (pthread_attr_init(&attr) != 0) {
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    (void)pthread_attr_setguardsize(&attr, 0);
    if (posix_memalign(&stk, (size_t)65536, stack_sz) != 0)
        stk = NULL;
    if (stk != NULL && pthread_attr_setstack(&attr, stk, stack_sz) == 0) {
        if (pthread_create(&tid, &attr, driver_large_stack_thread_trampoline, &call) == 0) {
            pthread_join(tid, NULL);
            pthread_attr_destroy(&attr);
            free(stk);
            return;
        }
    }
    pthread_attr_destroy(&attr);
    free(stk);
    if (pthread_attr_init(&attr) != 0) {
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    if (pthread_attr_setstacksize(&attr, stack_sz) != 0) {
        pthread_attr_destroy(&attr);
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    if (pthread_create(&tid, &attr, driver_large_stack_thread_trampoline, &call) != 0) {
        pthread_attr_destroy(&attr);
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    pthread_join(tid, NULL);
    pthread_attr_destroy(&attr);
}

/** 对外别名：LSP 主循环等在 256MiB 栈 pthread 上执行 fn(arg)。 */
void driver_run_on_large_stack_pthread(void *(*fn)(void *), void *arg) {
    driver_run_thread_on_large_stack(fn, arg);
}

/**
 * 扫描预处理后源码是否含顶层 import（`import("` 或 `= import(`）。
 * 参数：src 预处理后缓冲；src_len 有效字节数。
 * 返回值：1 含顶层 import；0 否。
 */
int driver_source_has_top_level_import(const char *src, size_t src_len) {
    const char *p;
    const char *end;

    if (!src || src_len < 9)
        return 0;
    p = src;
    end = src + src_len;
    while (p + 9 <= end) {
        if (memcmp(p, "import(\"", 8) == 0)
            return 1;
        if (memcmp(p, "= import(", 9) == 0)
            return 1;
        p++;
    }
    return 0;
}

/**
 * 读入口 .x 并检测预处理后是否含顶层 import（compile.x asm 分派降级 C 后端用）。
 * 参数：path 源文件路径。
 * 返回值：1 含顶层 import；0 否或读/预处理失败。
 */
int driver_source_has_top_level_import_path(const char *path) {
    ShuxRuntimeFileView raw_view;
    size_t src_len = 0;
    char *src;
    int has;

    if (runtime_read_file_view(path, &raw_view) != 0)
        return 0;
    src = shux_preprocess(raw_view.data, raw_view.length, NULL, 0, &src_len);
    runtime_release_file_view(&raw_view);
    if (!src)
        return 0;
    has = driver_source_has_top_level_import(src, src_len);
    free(src);
    return has;
}

