/* G-02f-343/344/345 / R2 thin full：PREFER hybrid thin 由 src/runtime_driver_abi_thin.x；
 * rest SHUX_L2_RDABI_THIN_FROM_X（无 pure-dup _impl；slice_marker + Cap residual 体）。
 * pure 深迁：scan/has/argv_collect/target_os/fail/smoke/peek/entry_len_i32/large_stack orch
 *   + getenv 门闩（force_c / asm skip / emit_heavy / module_only / metric / no_large_stack /
 *   sanitize_address env）在 thin.x；FROM_X 剔 pure-dup _impl。
 */
/* Generated from src/runtime_driver_abi.x (G-02f-29/41/45..57/83 true .x + C tail).
 * G-02f-116 true .x pure helpers.
 * G-02f-104 helper gates.
 * G-02f-243: P1-6 open — entry_source_len_i32 saturate + scan_top_level_import pure.
 * G-02f-244: phase index + stack want + path import orchestrate pure.
 * G-02f-245: argv_collect_defines main loop pure; uname host defines locked.
 * G-02f-246: large_stack early-exit/current-stack orch pure; P1-6 soft near-close.
 * Regen: ./shux-c -E -L .. src/runtime_driver_abi.x > /tmp/dabi.c
 *         merge flags/env/phase/peek/smoke/stack/defines; C uname + pthread create bulk.
 * .x covers: + argv_collect pure + large_stack orch + entry_len/scan/stack want/path.
 */
#include "win32_compat.h"
#include "runtime_driver_abi.h"
#include "runtime_io_abi.h"
#include "runtime_pipeline_abi.h"
#include "runtime_abi.h"
#include "diag.h"
#include "runtime_diag_codes.h"

#ifdef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_check_quiet_ok_get(void);
int32_t driver_check_diag_emitted_get(void);
int32_t driver_is_large_stack_thread(void);
void driver_large_stack_thread_mark(int on);
void driver_run_fn_on_current_large_stack(void *(*fn)(void *), void *arg);
int32_t driver_compile_phase_index_ok(int32_t phase);
char driver_ascii_toupper(char c);
int32_t driver_typeck_skip_large_entry(void);
int32_t driver_sanitize_address_get(void);
int32_t driver_typeck_force_c_enabled(void);
int32_t driver_asm_build_skip_typeck(void);
int32_t driver_asm_entry_emit_heavy(void);
int32_t driver_pipeline_no_large_stack_env(void);
int32_t driver_asm_entry_module_only_from_env(void);
int32_t driver_asm_parse_metric_only_from_env(void);
int32_t driver_pipeline_entry_source_len_i32(void);
void driver_defines_set_at(const char **defines, int i, const char *s);
int64_t driver_stack_limit_want_bytes(void);
int64_t driver_path_last_preprocess_len(void);
void driver_current_dep_path_store(const char *path);
const char *driver_current_dep_path_load(void);
void driver_pipeline_entry_source_len_store(size_t len);
int32_t driver_target_arg_os_kind(const char *target);
void driver_bump_stack_limit(void);
void driver_set_pipeline_entry_source_len(size_t len);
int compile_phase_timing_enabled(void);
const char *driver_os_define_lit(int kind);
void driver_run_thread_on_large_stack(void *(*fn)(void *), void *arg);
int driver_argv_collect_defines(int argc, char **argv, const char **defines, int max_defines);
int driver_source_has_top_level_import(const char *src, size_t src_len);
#define compile_phase_now_sec compile_phase_now_sec_impl
#define driver_compile_phase_timing_enabled driver_compile_phase_timing_enabled_impl
#define driver_check_only_flag_slot driver_check_only_flag_slot_impl
#define driver_check_diag_emitted_flag_slot driver_check_diag_emitted_flag_slot_impl
#define driver_freestanding_flag_slot driver_freestanding_flag_slot_impl
#define driver_sanitize_address_flag_slot driver_sanitize_address_flag_slot_impl
#define driver_fmt_check_only_flag_slot driver_fmt_check_only_flag_slot_impl
#define driver_x_pipeline_skip_typeck_flag_slot driver_x_pipeline_skip_typeck_flag_slot_impl
#define driver_x_pipeline_skip_codegen_flag_slot driver_x_pipeline_skip_codegen_flag_slot_impl
#define driver_skip_codegen_dep_0_flag_slot driver_skip_codegen_dep_0_flag_slot_impl
#define driver_large_stack_thread_flag_slot driver_large_stack_thread_flag_slot_impl
#define driver_path_read_preprocess_malloc driver_path_read_preprocess_malloc_impl
#endif

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
/* G-02f-119：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
char driver_ascii_toupper(char c) {
    if (c >= 'a' && c <= 'z')
        return (char)(c + ('A' - 'a'));
    return c;
}
#endif





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
void driver_current_dep_path_store(const char *path);
const char *driver_current_dep_path_load(void);
void driver_print_check_ok_impl(const char *input_path);
void driver_bump_stack_limit(void);
void driver_bump_stack_limit_to_impl(int64_t want_bytes);
int64_t driver_stack_limit_want_bytes(void);
void driver_defines_set_at(const char **defines, int i, const char *s);
const char *driver_os_define_lit(int kind);
int driver_argv_collect_append_uname_impl(const char **defines, int ndefines, int max_defines);
int32_t driver_target_arg_os_kind(const char *target);
void driver_run_thread_on_large_stack(void *(*fn)(void *), void *arg);
void driver_run_thread_on_large_stack_pthread_impl(void *(*fn)(void *), void *arg);
void driver_call_fn_void_arg_impl(void *(*fn)(void *), void *arg);
int32_t driver_pipeline_no_large_stack_env(void);
void driver_pipeline_fail_code_rc_impl(int32_t rc);
void driver_pipeline_fail_code_path_impl(const uint8_t *path);
void driver_print_x_smoke_parse_ok_impl(int32_t num_funcs, int32_t main_ix, int64_t codegen_len);
void driver_print_x_smoke_parse_empty_impl(void);
void driver_print_x_smoke_typeck_ok_impl(void);
int driver_source_scan_top_level_import(const char *src, size_t src_len);
char *driver_path_read_preprocess_malloc(const char *path);
int64_t driver_path_last_preprocess_len(void);
void driver_pipeline_entry_source_len_store(size_t len);
size_t driver_pipeline_entry_source_len_load_and_maybe_debug(void);
int32_t driver_compile_phase_timing_enabled(void);
int32_t driver_compile_phase_index_ok(int32_t phase);

/** shux check：非 0 时 typeck 通过后跳过 codegen 与链接（C 与 X pipeline 共用）。 */
static int driver_check_only_flag;
static int driver_check_diag_emitted_flag;

/**
 * 设置 check-only 模式。
 * 参数：v 非 0 启用。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_check_only_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_check_only_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}
#endif

/**
 * 查询 check-only 模式。
 * 返回值：1 表示启用，0 表示否。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
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
#endif

#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_check_diag_emitted_reset(void) {
  (void)(({   {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    (void)(((p)[0] = 0));
  }
 }));
}
#endif

#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_check_diag_emitted_note(void) {
  (void)(({   {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    (void)(((p)[0] = 1));
  }
 }));
}
#endif

#ifndef SHUX_L2_RDABI_THIN_FROM_X
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
#endif

/** `-freestanding` / SHUX_FREESTANDING：用户程序 nostdlib 静态链（S4）。 */
static int driver_freestanding_flag;

/** 设置 freestanding 链接模式。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_freestanding_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_freestanding_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}
#endif

/** 查询 freestanding 链接模式。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
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
#endif

/** M-6：`-fsanitize=address` 时强制数组/切片 INDEX 边界检查。 */
static int driver_sanitize_address_flag;

/** 设置 sanitize=address 标志。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_sanitize_address_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_sanitize_address_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}
#endif

/**
 * 查询 sanitize=address；显式标志或 SHUX_SANITIZE_ADDRESS 环境变量。
 * pure 权威：thin.x driver_sanitize_address_get（flag + env 门闩）；
 * 冷启动保留全 C 体；FROM_X 无 pure-dup env_enabled_impl（H↓）。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
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
#endif

static int driver_fmt_check_only_flag;

/** shux fmt --check：仅校验格式，不写回。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_fmt_check_only_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_fmt_check_only_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}
#endif

/** 查询 fmt --check 模式。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
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
#endif

/* 【Why 根源】MinGW PE 格式不真正支持 __attribute__((weak))：weak 函数被当作普通强符号，
 * 与 fmt_check_cmd.c 的强符号并存；--allow-multiple-definition 选第一个遇到的定义，
 * 链接器不保证按 OBJS_CORE 顺序选 fmt_check_cmd.o 的版本。当 weak 版本被选中且返回 0，
 * check 成功后会逐文件打印 "check OK"，与 deno check 静默成功语义矛盾。
 * 【Invariant】deno check 语义：成功时静默。weak 默认值必须返回 1（静默），保证无论
 * Windows 链接器选中哪个版本，driver_print_check_ok 都不输出逐文件 check OK。
 * 【Asm/Perf】macOS/Linux 上 weak 正常工作，强符号覆盖 weak 默认值，此改动无影响。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
SHUX_WEAK int32_t driver_check_quiet_ok_get(void) {
  return 1;
}
#endif

/**
 * 统一 shux check 成功行；deno 风格批量 check 成功时由 fmt_check_cmd 保持静默。
 * 参数：input_path 被检查文件路径（可为 NULL）。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_print_check_ok(const char *input_path) {
  (void)(({   {
    if ((driver_check_quiet_ok_get() !=0)) {
      return;
    }
    (void)(driver_print_check_ok_impl(input_path));
  }
 }));
}
#endif

/** 非 0 时 pipeline_impl_typecheck 跳过 .x typeck。 */
static int driver_x_pipeline_skip_typeck_flag;

/** 供 pipeline.x 读取：是否跳过 X typeck。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
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
#endif

/** 设置 X typeck 跳过标志（C 预检后由 runtime 置位/清位）。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_x_pipeline_skip_typeck_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_x_pipeline_skip_typeck_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}
#endif

/** 非 0 时 pipeline_impl_run_all 跳过 .x C codegen。 */
static int driver_x_pipeline_skip_codegen_flag;

/** 供 pipeline.x 读取：是否跳过 X C codegen。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
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
#endif

/** 设置 X C codegen 跳过标志。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_x_pipeline_skip_codegen_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_x_pipeline_skip_codegen_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}
#endif

/**
 * 非 0 时入口模块 typeck 走 C 的 typeck_module（大模块 asm 构建时避免 .x typeck 栈过深）。
 * pure 权威：thin.x driver_typeck_force_c_enabled；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_typeck_force_c_enabled_impl(void) {
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

int32_t driver_typeck_force_c_enabled(void) {
  return driver_typeck_force_c_enabled_impl();
}
#endif

/** 当前线程是否已在 driver_run_thread_on_large_stack 创建的大栈 pthread 内。
 * 【Why 逻辑根源】nostdlib 静态链下 pthread 是 stub（bootstrap_nostdlib_pthread_is_stub()=1），
 *                driver_run_thread_on_large_stack 在当前栈运行不创建新线程，全程单线程无需 TLS。
 *                之前用 _Thread_local 时 gcc 对 _impl 生成 `mov %fs:0x0,%rax; add $-16,%rax` 间接访问，
 *                bootstrap_init_static_tls 只把 %fs 设为 &bootstrap_tls（48 字节 block），
 *                %fs:0x0 读到 BSS 默认值 0，0-16=0xfffffffffffffff0 无效地址 → SIGSEGV。
 *                stage1 工作纯属巧合：编译器把 driver_is_large_stack_thread 内联为 `mov %fs:-16,%eax`。
 * 【Invariant 状态不变量】nostdlib 路径下进程内只有 1 个执行流，单变量即正确反映"在大栈线程上下文"标志。
 * 【Asm/Perf 性能预期】普通 static int 在 BSS 中，访问为 RIP-relative 一次 load，比 TLS 间接访问快且无 %fs 依赖。 */
static int g_driver_on_large_stack_thread;

/* G-02f-45 */
int32_t *driver_large_stack_thread_flag_slot(void) {
    return (int32_t *)&g_driver_on_large_stack_thread;
}


/**
 * 供 ast_pool / pipeline glue 查询：LSP 主循环已在大栈线程上时，typeck 勿再 spawn 嵌套 pthread。
 * 返回值：非 0 表示当前在大栈线程上下文。
 */

#ifndef SHUX_L2_RDABI_THIN_FROM_X
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
#endif

/**
 * 标记当前线程大栈上下文（runtime pthread trampoline 进入/退出时调用）。
 * 参数：on 非 0 进入，0 退出。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_large_stack_thread_mark(int on) {
  (void)(({   {
    int32_t * p = driver_large_stack_thread_flag_slot();
    (void)(((p)[0] = on));
  }
 }));
}
#endif

/** 当前 pipeline 入口源码长度；供 .x 按体积跳过大库 merge/typeck。 */
static size_t g_pipeline_entry_source_len;

/* G-02f-45 */
/* G-02f-243：逻辑源 .x（真迁 saturate）；seed 保留同语义 C 供产品 cc */
/* G-02f-388：实现体始终 seed（读 static g_pipeline_entry_source_len）；public PREFER 时 thin forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_pipeline_entry_source_len_i32_impl(void) {
    if (g_pipeline_entry_source_len > (size_t)0x7fffffff)
        return 0x7fffffff;
    return (int32_t)g_pipeline_entry_source_len;
}
#endif

#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_pipeline_entry_source_len_i32(void) {
    return driver_pipeline_entry_source_len_i32_impl();
}
#endif





/* G-02f-401：实现体始终 seed；public PREFER 时 thin forward */
void driver_pipeline_entry_source_len_store_impl(size_t len) {
    g_pipeline_entry_source_len = len;
}

#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_pipeline_entry_source_len_store(size_t len) {
    driver_pipeline_entry_source_len_store_impl(len);
}
#endif

/* G-02f-416：getenv/reportf 体始终 seed；public PREFER 时 thin pure forward */
size_t driver_pipeline_entry_source_len_load_and_maybe_debug_impl(void) {
    if (getenv("SHUX_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: entry_source_len_global=%zu", g_pipeline_entry_source_len);
    return g_pipeline_entry_source_len;
}
#ifndef SHUX_L2_RDABI_THIN_FROM_X
size_t driver_pipeline_entry_source_len_load_and_maybe_debug(void) {
    return driver_pipeline_entry_source_len_load_and_maybe_debug_impl();
}
#endif

/**
 * 记录 pipeline 入口源码字节数（大栈 pthread 进入 pipeline 前调用）。
 * 参数：len 预处理后的入口源码长度。
 */
/* G-02f-402：public PREFER 时 thin → store_impl */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_set_pipeline_entry_source_len(size_t len) {
  {
    driver_pipeline_entry_source_len_store_impl(len);
  }
}
#endif

/**
 * 查询当前记录的入口源码长度；SHUX_DEBUG_PIPE=1 时打印。
 * 返回值：最近一次 driver_set_pipeline_entry_source_len 写入的长度。
 */
/* G-02f-416：public PREFER 时 thin pure forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
size_t driver_pipeline_entry_source_len_impl(void) {
    return driver_pipeline_entry_source_len_load_and_maybe_debug_impl();
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
size_t driver_pipeline_entry_source_len(void) {
    return driver_pipeline_entry_source_len_impl();
}
#endif

/**
 * 非 0 表示入口源码过大，应跳过 merge/library 全量 typeck（.x 路径上易 segfault）。
 * 返回值：len > 150000 时为 1，否则 0。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_typeck_skip_large_entry(void) {
  (void)(({   {
    int32_t len = driver_pipeline_entry_source_len_i32_impl();
    if ((len > 150000)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}
#endif

/**
 * build_shux_asm 单模块 -o：SHUX_ASM_BUILD_SKIP_TYPECK=1 时跳过 .x typeck。
 * pure 权威：thin.x；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_asm_build_skip_typeck_impl(void) {
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

int32_t driver_asm_build_skip_typeck(void) {
  return driver_asm_build_skip_typeck_impl();
}
#endif

/**
 * typeck 第二遍 EMIT_HEAVY：SHUX_ASM_ENTRY_EMIT_HEAVY=1 时 pipeline 跳过文本 asm codegen。
 * pure 权威：thin.x；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_asm_entry_emit_heavy_impl(void) {
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

int32_t driver_asm_entry_emit_heavy(void) {
  return driver_asm_entry_emit_heavy_impl();
}
#endif

/**
 * build_shux_asm 单模块 -o：SHUX_ASM_ENTRY_MODULE_ONLY=1 时仅编入口模块。
 * pure 权威：thin.x；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_asm_entry_module_only_from_env_impl(void) {
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

int32_t driver_asm_entry_module_only_from_env(void) {
  return driver_asm_entry_module_only_from_env_impl();
}
#endif

/**
 * A-11 typeck-parse-count-gate：仅采集 parse 指标，不跑 pipeline/asm_codegen_elf_o。
 * pure 权威：thin.x；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_asm_parse_metric_only_from_env_impl(void) {
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

int32_t driver_asm_parse_metric_only_from_env(void) {
  return driver_asm_parse_metric_only_from_env_impl();
}
#endif

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
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_skip_codegen_dep_0_set(int32_t v) {
  (void)(({   {
    int32_t * p = driver_skip_codegen_dep_0_flag_slot();
    (void)(((p)[0] = v));
  }
 }));
}
#endif

/** 查询 skip_codegen_dep_0；pipeline.x dep_j==0 时读取。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
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
#endif

/** 当前 codegen 的 dep 逻辑路径（如 std.io.driver），供 .x codegen 前缀 C 符号。 */
static const char *driver_current_dep_path_for_codegen;

/* G-02f-46: dep path store/load + print_check_ok diag impl */
/* G-02f-401：实现体始终 seed；public PREFER 时 thin forward */
void driver_current_dep_path_store_impl(const char *path) {
    driver_current_dep_path_for_codegen = path;
}

#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_current_dep_path_store(const char *path) {
    driver_current_dep_path_store_impl(path);
}
#endif

const char *driver_current_dep_path_load_impl(void) {
    return driver_current_dep_path_for_codegen;
}

#ifndef SHUX_L2_RDABI_THIN_FROM_X
const char *driver_current_dep_path_load(void) {
    return driver_current_dep_path_load_impl();
}
#endif

void driver_print_check_ok_impl(const char *input_path) {
    diag_reportf(NULL, 0, 0, "info", NULL,
                 "check OK: %s", input_path ? input_path : "?");
}

void driver_pipeline_fail_code_rc_impl(int32_t rc) {
    diag_reportf_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP003, NULL,
                           "pipeline failed rc=%d", (int)rc);
}

void driver_pipeline_fail_code_path_impl(const uint8_t *path) {
    diag_reportf_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP004, NULL,
                           "resolve path tried: %s", path ? (const char *)path : "?");
}

void driver_print_x_smoke_parse_ok_impl(int32_t num_funcs, int32_t main_ix, int64_t codegen_len) {
    diag_reportf(NULL, 0, 0, "info", NULL,
                 "parse OK: num_funcs=%d main_idx=%d codegen_bytes=%zu",
                 (int)num_funcs, (int)main_ix, (size_t)codegen_len);
}

void driver_print_x_smoke_parse_empty_impl(void) {
    diag_report_with_code(NULL, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001,
                "parse produced no functions in module", NULL);
}

void driver_print_x_smoke_typeck_ok_impl(void) {
    diag_report(NULL, 0, 0, "info", "typeck OK", NULL);
}



/**
 * 设置当前 dep 路径；pipeline codegen 循环每 dep 调用。
 * 参数：path import 逻辑路径或 NULL 清槽。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_set_current_dep_path_for_codegen(const char *path) {
  (void)(({   {
    (void)(driver_current_dep_path_store_impl(path));
  }
 }));
}
#endif
/* G-02f-413：实现体始终 seed；public PREFER 时 thin pure forward */
const char *driver_get_current_dep_path_for_codegen_impl(void) {
    return driver_current_dep_path_load_impl();
}
#ifndef SHUX_L2_RDABI_THIN_FROM_X
const char *driver_get_current_dep_path_for_codegen(void) {
    return driver_get_current_dep_path_for_codegen_impl();
}
#endif



/** OBS-001：编译阶段耗时；phase 0=parse 1=typeck 2=codegen。 */
#define SHUX_COMPILE_PHASE_MAX 3

static double g_compile_phase_acc_ms[SHUX_COMPILE_PHASE_MAX];
static double g_compile_phase_start_sec[SHUX_COMPILE_PHASE_MAX];
static int g_compile_phase_active[SHUX_COMPILE_PHASE_MAX];

/** 是否启用 SHUX_COMPILE_PHASE_TIMING 阶段计时。 */
/* G-02f-116：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-402：getenv 体始终 seed；public PREFER 时 thin forward */
int compile_phase_timing_enabled_impl(void) {
  return getenv("SHUX_COMPILE_PHASE_TIMING") != NULL;
}

#ifndef SHUX_L2_RDABI_THIN_FROM_X
int compile_phase_timing_enabled(void) {
  return compile_phase_timing_enabled_impl();
}
#endif



/** 单调 wall-clock 秒（gettimeofday）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
double compile_phase_now_sec(void)
#else
double compile_phase_now_sec_impl(void)
#endif
{
    struct timeval tv;
    #ifndef _WIN32
    gettimeofday(&tv, NULL);
#else
    time_t t = time(NULL); tv.tv_sec = (long)t; tv.tv_usec = 0;
#endif
    return (double)tv.tv_sec + (double)tv.tv_usec * 1e-6;
}




/* G-02f-244：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_compile_phase_index_ok(int32_t phase) {
    if (phase < 0)
        return 0;
    if (phase >= SHUX_COMPILE_PHASE_MAX)
        return 0;
    return 1;
}
#endif

/**
 * 标记编译阶段开始；由 pipeline.x run_x_pipeline_impl 调用。
 * 参数：phase 0..2。
 */
void driver_compile_phase_timing_begin_impl(int32_t phase) {
    if (!driver_compile_phase_index_ok(phase))
        return;
    g_compile_phase_start_sec[phase] = compile_phase_now_sec();
    g_compile_phase_active[phase] = 1;
}

/**
 * 累加阶段耗时（毫秒）；同 phase 可多次 begin/end 叠加。
 * 参数：phase 0..2。
 */
void driver_compile_phase_timing_end_impl(int32_t phase) {
    if (!driver_compile_phase_index_ok(phase) || !g_compile_phase_active[phase])
        return;
    g_compile_phase_acc_ms[phase] += (compile_phase_now_sec() - g_compile_phase_start_sec[phase]) * 1000.0;
    g_compile_phase_active[phase] = 0;
}

/** 打印 parse/typeck/codegen/total 毫秒汇总行并清零；SHUX_COMPILE_PHASE_TIMING 启用时生效。 */
void driver_compile_phase_timing_flush_impl(void) {
    double total = g_compile_phase_acc_ms[0] + g_compile_phase_acc_ms[1] + g_compile_phase_acc_ms[2];
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "compile phase timing: parse_ms=%.3f typeck_ms=%.3f codegen_ms=%.3f total_ms=%.3f",
                 g_compile_phase_acc_ms[0], g_compile_phase_acc_ms[1], g_compile_phase_acc_ms[2], total);
    memset(g_compile_phase_acc_ms, 0, sizeof(g_compile_phase_acc_ms));
    memset(g_compile_phase_active, 0, sizeof(g_compile_phase_active));
}

#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_compile_phase_timing_flush(void) {
  (void)(({   {
    if ((driver_compile_phase_timing_enabled() ==0)) {
      return;
    }
    (void)(driver_compile_phase_timing_flush_impl());
  }
 }));
}
#endif

/* G-02f-244：逻辑源 .x（门闩 → index_ok pure）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_compile_phase_timing_end(int32_t phase) {
  (void)(({   {
    if ((driver_compile_phase_timing_enabled() ==0)) {
      return;
    }
    if ((driver_compile_phase_index_ok(phase) ==0)) {
      return;
    }
    (void)(driver_compile_phase_timing_end_impl(phase));
  }
 }));
}
#endif

#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_compile_phase_timing_enabled(void)
#else
int32_t driver_compile_phase_timing_enabled_impl(void)
#endif
{
  (void)(({   {
    char *e = getenv("SHUX_COMPILE_PHASE_TIMING");
    if ((e ==((char *)(0)))) {
      return 0;
    }
    return 1;
  }
 }));
  return 0;
}

/* G-02f-244：逻辑源 .x（门闩 → index_ok pure）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_compile_phase_timing_begin(int32_t phase) {
  (void)(({   {
    if ((driver_compile_phase_timing_enabled() ==0)) {
      return;
    }
    if ((driver_compile_phase_index_ok(phase) ==0)) {
      return;
    }
    (void)(driver_compile_phase_timing_begin_impl(phase));
  }
 }));
}
#endif


/**
 * 从 argv 收集 -D / -DFOO 与 -target 推导 OS_*、uname 的 SHUX_OS_/SHUX_ARCH_（run_compiler_c / asm 后端共用）。
 * 参数：defines 至少 max_defines 个槽；返回 ndefines。
 * G-02f-245：主循环逻辑源 .x pure；uname 🔒。
 */
/* G-02f-400：实现体始终 seed；public PREFER 时 thin forward */
void driver_defines_set_at_impl(const char **defines, int i, const char *s) {
    if (!defines || i < 0)
        return;
    defines[i] = s;
}

#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_defines_set_at(const char **defines, int i, const char *s) {
    driver_defines_set_at_impl(defines, i, s);
}
#endif

/* G-02f-402：字符串字面量体始终 seed；public PREFER 时 thin forward */
const char *driver_os_define_lit_impl(int kind) {
    if (kind == 1)
        return "OS_LINUX";
    if (kind == 2)
        return "OS_MACOS";
    if (kind == 3)
        return "OS_FREEBSD";
    if (kind == 4)
        return "OS_WINDOWS";
    return NULL;
}

#ifndef SHUX_L2_RDABI_THIN_FROM_X
const char *driver_os_define_lit(int kind) {
    return driver_os_define_lit_impl(kind);
}
#endif

/* G-02f-245：逻辑源 .x（真迁 target→OS kind）；seed 保留同语义 C 供产品 cc */
/* G-02f-401：strstr 字面量体始终 seed；public PREFER 时 thin forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_target_arg_os_kind_impl(const char *target) {
    if (!target)
        return 0;
    if (strstr(target, "linux") != NULL)
        return 1;
    if (strstr(target, "darwin") != NULL || strstr(target, "apple") != NULL)
        return 2;
    if (strstr(target, "freebsd") != NULL)
        return 3;
    if (strstr(target, "windows") != NULL)
        return 4;
    return 0;
}
#endif

#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_target_arg_os_kind(const char *target) {
    return driver_target_arg_os_kind_impl(target);
}
#endif

/* G-02f-245：uname + SHUX_OS_/SHUX_ARCH_ 🔒 */
int driver_argv_collect_append_uname_impl(const char **defines, int ndefines, int max_defines) {
    struct utsname u;
    static char shu_os_def[80], shu_arch_def[80];
    if (!defines)
        return ndefines;
    if (ndefines + 2 > max_defines)
        return ndefines;
    if (uname(&u) != 0)
        return ndefines;
    snprintf(shu_os_def, sizeof shu_os_def, "SHUX_OS_%s", u.sysname);
    snprintf(shu_arch_def, sizeof shu_arch_def, "SHUX_ARCH_%s", u.machine);
    for (char *p = shu_os_def + 7; *p; p++)
        *p = driver_ascii_toupper(*p);
    for (char *p = shu_arch_def + 9; *p; p++)
        *p = driver_ascii_toupper(*p);
    defines[ndefines++] = shu_os_def;
    defines[ndefines++] = shu_arch_def;
    return ndefines;
}

/* G-02f-245：逻辑源 .x；G-02f-413：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_argv_collect_defines_impl(int argc, char **argv, const char **defines, int max_defines) {
    int ndefines = 0;
    const char *target_arg = NULL;
    int i;
    if (argv == NULL)
        return 0;
    if (defines == NULL)
        return 0;
    if (max_defines <= 0)
        return 0;
    if (argc <= 0)
        return 0;
    for (i = 1; i < argc; i++) {
        const char *arg = argv[i];
        if (!arg)
            continue;
        if (strcmp(arg, "-D") == 0) {
            if (i + 1 >= argc)
                continue;
            if (ndefines < max_defines)
                defines[ndefines++] = argv[i + 1];
            i++;
        } else if (strncmp(arg, "-D", 2) == 0 && arg[2] != '\0') {
            if (ndefines < max_defines)
                defines[ndefines++] = arg + 2;
        } else if (strcmp(arg, "-target") == 0 && i + 1 < argc) {
            target_arg = argv[i + 1];
            i++;
        } else if (strcmp(arg, "-o") == 0 || strcmp(arg, "-L") == 0 || strcmp(arg, "-O") == 0 ||
                   strcmp(arg, "-backend") == 0) {
            if (i + 1 < argc)
                i++;
        }
    }
    if (target_arg && ndefines < max_defines) {
        int k = (int)driver_target_arg_os_kind_impl(target_arg);
        if (k != 0) {
            const char *lit = driver_os_define_lit_impl(k);
            if (lit)
                defines[ndefines++] = lit;
        }
    }
    if (ndefines + 2 <= max_defines)
        ndefines = driver_argv_collect_append_uname_impl(defines, ndefines, max_defines);
    return ndefines;
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_argv_collect_defines(int argc, char **argv, const char **defines, int max_defines) {
    return driver_argv_collect_defines_impl(argc, argv, defines, max_defines);
}
#endif

/** pipeline_gen.c / main.x：module num_funcs 与 main 下标。 */
extern int driver_get_module_num_funcs(void *m);
extern int driver_get_module_main_func_index(void *m);

/** pipeline 失败 rc 诊断；rc==-7 时打印 resolve 尝试路径。 */
/* G-02f-413：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_pipeline_fail_code_impl(int rc, const uint8_t *path) {
    driver_pipeline_fail_code_rc_impl((int32_t)rc);
    if (rc != -7) {
        return;
    }
    if (path == NULL) {
        return;
    }
    driver_pipeline_fail_code_path_impl(path);
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_pipeline_fail_code(int rc, const uint8_t *path) {
    driver_pipeline_fail_code_impl(rc, path);
}
#endif

/**
 * .x pipeline 烟测 stderr 摘要；保留 parse OK / typeck OK 前缀供 run-import gate grep。
 * 参数：module ASTModule*；codegen_len 产出字节数（可为 0）。
 */
/* G-02f-244/413：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_print_x_smoke_summary_impl(void *module, size_t codegen_len) {
    int32_t num_funcs;
    int32_t main_ix;
    if (module == NULL) {
        return;
    }
    if (driver_check_diag_emitted_get() != 0) {
        return;
    }
    num_funcs = (int32_t)driver_get_module_num_funcs(module);
    main_ix = (int32_t)driver_get_module_main_func_index(module);
    driver_print_x_smoke_parse_ok_impl(num_funcs, main_ix, (int64_t)codegen_len);
    if (num_funcs <= 0) {
        driver_print_x_smoke_parse_empty_impl();
        return;
    }
    driver_print_x_smoke_typeck_ok_impl();
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_print_x_smoke_summary(void *module, size_t codegen_len) {
    driver_print_x_smoke_summary_impl(module, codegen_len);
}
#endif

/**
 * B-20：读源文件前缀到 content（最多 cap-1 字节）；成功返回读入字节数，失败 -1。
 * 参数：path 源路径；content/cap 输出缓冲；实现委托 runtime_io_abi。
 */
/* G-02f-413：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_peek_source_file_impl(const char *path, char *content, size_t cap) {
    int32_t n;
    if (path == NULL) {
        return -1;
    }
    if (content == NULL) {
        return -1;
    }
    if (cap <= 1) {
        return -1;
    }
    n = shux_read_file_into_path(path, content, (size_t)(cap - 1));
    return (int)n;
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_peek_source_file(const char *path, char *content, size_t cap) {
    return driver_peek_source_file_impl(path, content, cap);
}
#endif

/**
 * 大模块 pipeline 栈帧深；macOS 默认 RLIMIT_STACK 约 512KiB～8MiB，进入 pipeline 前抬高软上限。
 * NL-07 nostdlib：pthread 大栈桩无效，须把主线程软上限抬到 256MiB 以免 -o 编译栈溢出 SIGSEGV。
 * G-02f-244：want pure 在 .x；setrlimit / nostdlib 覆盖 🔒 在 to_impl。
 */
/* G-02f-244：逻辑源 .x（真迁 parse）；seed 保留同语义 C 供产品 cc */
static int64_t driver_parse_u32_cstr(const char *s) {
    int64_t n = 0;
    int i = 0;
    if (!s || !s[0])
        return -1;
    for (i = 0; i < 20 && s[i]; i++) {
        unsigned char c = (unsigned char)s[i];
        if (c < '0' || c > '9')
            return -1;
        n = n * 10 + (int64_t)(c - '0');
    }
    if (i == 0)
        return -1;
    return n;
}

/* G-02f-400：getenv 体始终 seed；public PREFER 时 thin forward */
int64_t driver_stack_limit_want_bytes_impl(void) {
    int64_t def = (int64_t)512 * 1024 * 1024;
    const char *e = getenv("SHUX_STACK_LIMIT_MB");
    int64_t mb;
    if (!e || !e[0])
        return def;
    mb = driver_parse_u32_cstr(e);
    if (mb < 64 || mb > 8192)
        return def;
    return mb * (int64_t)(1024 * 1024);
}

#ifndef SHUX_L2_RDABI_THIN_FROM_X
int64_t driver_stack_limit_want_bytes(void) {
    return driver_stack_limit_want_bytes_impl();
}
#endif

void driver_bump_stack_limit_to_impl(int64_t want_bytes) {
    #ifndef _WIN32
    struct rlimit rl;
    rlim_t want = (rlim_t)want_bytes;
    if (want_bytes <= 0)
        want = (rlim_t)(512 * 1024 * 1024);
    if (bootstrap_nostdlib_pthread_is_stub())
        want = (rlim_t)(512 * 1024 * 1024);
    if (getrlimit(RLIMIT_STACK, &rl) == 0 && rl.rlim_cur < want) {
        rl.rlim_cur = want;
        if (rl.rlim_max > (rlim_t)0 && rl.rlim_cur > rl.rlim_max)
            rl.rlim_cur = rl.rlim_max;
        (void)setrlimit(RLIMIT_STACK, &rl);
    }
    #else
    (void)want_bytes;
    #endif
}

/* G-02f-244：逻辑源 .x（want pure → to_impl）；seed 保留同语义 C 供产品 cc */
/* G-02f-402：public PREFER 时 thin → want_impl + to_impl */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_bump_stack_limit(void) {
    driver_bump_stack_limit_to_impl(driver_stack_limit_want_bytes_impl());
}
#endif



/** pthread 大栈调用参数（trampoline 解包 fn/arg）。 */
typedef struct {
    void *(*fn)(void *);
    void *arg;
} DriverLargeStackCall;

/** pthread 入口：标记大栈线程并抬高 soft limit 后执行用户 fn。 */
/* G-02f-243：.x 门闩 null 边界；主体 🔒 pthread 解包 */
void * driver_large_stack_thread_trampoline(void *v) {
    DriverLargeStackCall *c;
    if (v == NULL)
        return NULL;
    c = (DriverLargeStackCall *)v;
    driver_large_stack_thread_mark(1);
    driver_bump_stack_limit();
    void *r = c->fn(c->arg);
    driver_large_stack_thread_mark(0);
    return r;
}

/** fn 指针调用 🔒（.x 无法安全间接调用） */
void driver_call_fn_void_arg_impl(void *(*fn)(void *), void *arg) {
    if (fn)
        (void)fn(arg);
}

/* pure 权威：thin.x driver_pipeline_no_large_stack_env；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int32_t driver_pipeline_no_large_stack_env_impl(void) {
    const char *e = getenv("SHUX_PIPELINE_NO_LARGE_STACK");
    if (!e || !e[0] || e[0] == '0')
        return 0;
    return 1;
}

int32_t driver_pipeline_no_large_stack_env(void) {
  return driver_pipeline_no_large_stack_env_impl();
}
#endif

/** 在当前线程直接执行 fn(arg)，并临时标记大栈上下文。 */
/* G-02f-246 pure 深迁：PREFER thin 真体；冷启动 full C；FROM_X 无 pure-dup */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_run_fn_on_current_large_stack(void *(*fn)(void *), void *arg)
{
    if (fn == NULL)
        return;
    driver_large_stack_thread_mark(1);
    driver_bump_stack_limit();
    driver_call_fn_void_arg_impl(fn, arg);
    driver_large_stack_thread_mark(0);
}
#endif

/**
 * pthread 创建/join 体 🔒；调用方已做 null / 早退 pure。
 * 默认 256MiB，可用 SHUX_STACK_LIMIT_MB 覆盖。
 */
void driver_run_thread_on_large_stack_pthread_impl(void *(*fn)(void *), void *arg) {
    pthread_attr_t attr;
    pthread_t tid;
    void *stk = NULL;
    size_t stack_sz = (size_t)256 * 1024 * 1024;
    const char *mb_env = getenv("SHUX_STACK_LIMIT_MB");
    DriverLargeStackCall call = { fn, arg };
    if (fn == NULL)
        return;
    if (mb_env && mb_env[0]) {
        unsigned long mb = strtoul(mb_env, NULL, 10);
        if (mb >= 64 && mb <= 8192)
            stack_sz = (size_t)mb * (size_t)(1024 * 1024);
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

/**
 * 在大栈 pthread 上执行 fn(arg)；早退 pure 后进 pthread 体。
 * macOS 主线程 RLIMIT_STACK 硬顶约 8MiB，深递归 pipeline/typeck 须与大 pipeline 同路径。
 * G-02f-246/414：实现体始终 seed；public PREFER 时 thin pure forward；pthread 创建 🔒。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_run_thread_on_large_stack_impl(void *(*fn)(void *), void *arg) {
    if (fn == NULL)
        return;
    if (driver_is_large_stack_thread()) {
        driver_call_fn_void_arg_impl(fn, arg);
        return;
    }
    driver_bump_stack_limit();
    /*
     * NL-07 nostdlib：bootstrap pthread 桩同步跑在当前栈上，256MiB posix_memalign 栈不会生效；
     * 依赖 driver_bump_stack_limit 在当前线程跑 pipeline，避免栈溢出 SIGSEGV。
     */
    if (bootstrap_nostdlib_pthread_is_stub()) {
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    if (driver_pipeline_no_large_stack_env()) {
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    driver_run_thread_on_large_stack_pthread_impl(fn, arg);
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_run_thread_on_large_stack(void *(*fn)(void *), void *arg) {
    driver_run_thread_on_large_stack_impl(fn, arg);
}
#endif



/** 对外别名：LSP 主循环等在 256MiB 栈 pthread 上执行 fn(arg)。 */
/* G-02f-414：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_run_on_large_stack_pthread_impl(void *(*fn)(void *), void *arg) {
    driver_run_thread_on_large_stack_impl(fn, arg);
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
void driver_run_on_large_stack_pthread(void *(*fn)(void *), void *arg) {
    driver_run_on_large_stack_pthread_impl(fn, arg);
}
#endif

/**
 * Cap-fn-ptr residual：.x 无法形成函数指针常量。
 * 绑定 driver_stack_esc_gate_thread_fn 后走大栈路径（与 pthread 体同层平台原语）。
 * 始终提供（不随 RDABI thin 宏剥离），供 rt_stack R2 full .x 调用。
 */
extern void *driver_stack_esc_gate_thread_fn(void *arg);
void driver_run_stack_esc_gate_on_large_stack(void *arg) {
    if (arg == NULL)
        return;
    driver_run_thread_on_large_stack(driver_stack_esc_gate_thread_fn, arg);
}

/**
 * Cap residual：opaque FILE* 供 rt_entry R2 full .x 的 diag_print_*。
 * 始终提供（不随 RDABI thin 宏剥离）。
 */
void *driver_stdio_stdout(void) {
    return (void *)stdout;
}

void *driver_stdio_stderr(void) {
    return (void *)stderr;
}

/**
 * Cap residual：rt_entry R2 缓冲槽 + fmt argv。
 * .x 禁局部 u8[N]（-E 抬 init_globals / 丢函数）。
 */
static char driver_entry_ab[256];
static char driver_entry_code_buf[256];
static char driver_entry_suggest[16];
static char driver_entry_msg[256];
static char driver_entry_tmp[16];
static char driver_entry_tmp2[16];
static char *driver_entry_fmt_argv[2] = {"shux", "fmt"};

uint8_t *driver_entry_ab_slot(void) {
    return (uint8_t *)driver_entry_ab;
}

uint8_t *driver_entry_code_slot(void) {
    return (uint8_t *)driver_entry_code_buf;
}

uint8_t *driver_entry_suggest_slot(void) {
    return (uint8_t *)driver_entry_suggest;
}

uint8_t *driver_entry_msg_slot(void) {
    return (uint8_t *)driver_entry_msg;
}

uint8_t *driver_entry_tmp_slot(void) {
    return (uint8_t *)driver_entry_tmp;
}

uint8_t *driver_entry_tmp2_slot(void) {
    return (uint8_t *)driver_entry_tmp2;
}

char **driver_entry_fmt_argv_slot(void) {
    return driver_entry_fmt_argv;
}

/**
 * Cap residual：rt_run_exec R2 full .x 的 usage 写 fd1。
 * 巨型多行字面量留平台层（.x -E 对 \\n 长串易丢体/误编码）。
 * 始终提供（不随 RDABI thin 宏剥离）。
 */
void driver_print_usage_write(void) {
    static const char usage[] =
        "Shux (shux) compiler\n"
        "\n"
        "Usage:\n"
        "  shux [options] file.x          compile and run\n"
        "  shux build [file.x] [-o exe]   compile (default a.out)\n"
        "  shux run file.x                compile and run\n"
        "  shux check [paths...]           parse + typeck only\n"
        "  shux fmt [--check] [paths...]   format .x sources\n"
        "  shux explain <CODE>             explain a diagnostic code\n"
        "  shux test [script.sh]           run test script\n"
        "\n"
        "Common options:\n"
        "  -backend asm|c    backend (default asm)\n"
        "  -O <0|1|2|3|s>    optimization (default 2)\n"
        "  -o <path>         output binary or .o\n"
        "  -L <dir>          library search path\n"
        "  -target <triple>  target (e.g. aarch64-linux-gnu)\n"
        "  -target-cpu <cpu> native|generic|avx2|...\n"
        "  --print-target-cpu  print host CPU features and exit\n"
        "  --explain <CODE>   print diagnostic code explanation and exit\n"
        "  -freestanding     nostdlib static link (Linux x86_64 ELF)\n"
        "  -legacy-f32-abi   legacy SysV f32 CALL (f64 widen; default xmm ABI)\n"
        "  -E                emit C (debug)\n"
        "  -flto              link-time optimization (C backend)\n"
        "  -h, --help         show this help\n"
        "\n"
        "Environment:\n"
        "  SHUX_ABI_F32_XMM=0  same as -legacy-f32-abi (x86_64 SysV)\n"
        "  SHUX_OPT          default -O level if omitted\n"
        "\n"
        "Release default: shux_asm -backend asm -O2 (f32 xmm ABI on unless legacy).\n"
        "See compiler/docs/F32_XMM_ABI.md for f32 ABI and deprecation timeline.\n";
    /* fwrite+fflush：避免本 TU 内先手写 extern write 再 #include <unistd.h> 触发 Darwin asm 冲突。 */
    (void)fwrite(usage, 1, sizeof(usage) - 1u, stdout);
    (void)fflush(stdout);
}

/**
 * Cap residual：rt_run_exec R2 driver_exec_compiled 体。
 * .x 禁 *u8→**u8 cast / let **u8（-E 整函数丢体）；scan+non_exe+spawn 在此。
 * 始终提供（不随 RDABI thin 宏剥离）。
 */
#if !defined(_WIN32) && !defined(_WIN64)
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#endif
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern const char *driver_exec_scan_out_path(int argc, char **argv);
extern int driver_exec_path_is_non_exe(const char *exe);
#if !defined(_WIN32) && !defined(_WIN64)
extern int shu_waitpid_retry(pid_t pid, int *status_out);
#endif

int driver_exec_compiled_body(int argc, uint8_t *argv_opaque) {
    char **argv = (char **)argv_opaque;
    const char *exe;
    if (!argv || argc < 1)
        return 1;
    exe = driver_exec_scan_out_path(argc, argv);
    if (driver_exec_path_is_non_exe(exe))
        return 0;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    {
        char *av[2];
        intptr_t rc;
        av[0] = (char *)exe;
        av[1] = NULL;
        rc = _spawnvp(_P_WAIT, exe, (const char *const *)av);
        if (rc == -1) {
            runtime_diag_errno_path(NULL, "process error", "spawnvp (driver_exec_compiled)", exe);
            return 1;
        }
        return (int)rc;
    }
#else
    {
        pid_t pid = fork();
        if (pid < 0) {
            runtime_diag_errno_path(NULL, "process error", "fork (driver_exec_compiled)", exe);
            return 1;
        }
        if (pid == 0) {
            char *av[2];
            av[0] = (char *)exe;
            av[1] = NULL;
            execv(exe, av);
            runtime_diag_errno_path(NULL, "process error", "execv (driver_exec_compiled)", exe);
            _exit(127);
        }
        {
            int st = 0;
            if (shu_waitpid_retry(pid, &st) != 0)
                return 1;
            if (WIFEXITED(st))
                return WEXITSTATUS(st);
            return 1;
        }
    }
#endif
}

/**
 * Cap-global-bss residual：rt_emit_state R2 full .x 写共享 emit 槽。
 * 数据定义在 seeds/rt_emit_state.from_x.c（跨 TU 非 static）；本层暴露槽/绑定。
 * 始终提供（不随 RDABI thin 宏剥离）。避免 .x 侧 **u8 赋值（-E 会丢函数）。
 */
#define X_EMIT_MAX_LIB_ROOTS_ABI 16
extern const char *driver_x_emit_c_path;
extern const char *driver_x_emit_lib_roots[X_EMIT_MAX_LIB_ROOTS_ABI];
extern int driver_x_emit_n_lib_roots;
extern char driver_x_emit_path_buf[512];
extern char driver_x_emit_lib_bufs[X_EMIT_MAX_LIB_ROOTS_ABI][256];
extern int driver_x_emit_c_want_extern;
/* argv 扫描临时缓冲（.x 勿用局部 u8[512]，易被抬成坏 init_globals） */
extern char driver_x_emit_scan_ab[512];
extern char driver_x_emit_scan_nx[512];

uint8_t *driver_x_emit_path_buf_slot(void) {
    return (uint8_t *)driver_x_emit_path_buf;
}

uint8_t *driver_x_emit_lib_buf_slot(int i) {
    if (i < 0 || i >= X_EMIT_MAX_LIB_ROOTS_ABI)
        return NULL;
    return (uint8_t *)driver_x_emit_lib_bufs[i];
}

uint8_t *driver_x_emit_scan_ab_slot(void) {
    return (uint8_t *)driver_x_emit_scan_ab;
}

uint8_t *driver_x_emit_scan_nx_slot(void) {
    return (uint8_t *)driver_x_emit_scan_nx;
}

void driver_x_emit_clear_c_path(void) {
    driver_x_emit_c_path = NULL;
}

void driver_x_emit_bind_c_path_to_buf(void) {
    driver_x_emit_c_path = driver_x_emit_path_buf;
}

void driver_x_emit_bind_lib_root(int i) {
    if (i < 0 || i >= X_EMIT_MAX_LIB_ROOTS_ABI)
        return;
    driver_x_emit_lib_roots[i] = driver_x_emit_lib_bufs[i];
}

int32_t *driver_x_emit_n_lib_roots_slot(void) {
    return (int32_t *)&driver_x_emit_n_lib_roots;
}

int32_t *driver_x_emit_want_extern_slot(void) {
    return (int32_t *)&driver_x_emit_c_want_extern;
}

/**
 * Cap-global-bss residual：rt_arena_buf R2 full .x 访问 128MiB/2MiB 静态缓冲。
 * 数据定义在 seeds/rt_arena_buf.from_x.c（跨 TU 非 static）；本层暴露槽/尺寸。
 * 始终提供（不随 RDABI thin 宏剥离）。
 */
#define DRIVER_ARENA_STATIC_SIZE_ABI (128 * 1024 * 1024)
#define DRIVER_MODULE_STATIC_SIZE_ABI (2 * 1024 * 1024)
extern uint8_t driver_arena_static[DRIVER_ARENA_STATIC_SIZE_ABI];
extern uint8_t driver_module_static[DRIVER_MODULE_STATIC_SIZE_ABI];

uint8_t *driver_arena_static_slot(void) {
    return driver_arena_static;
}

uint8_t *driver_module_static_slot(void) {
    return driver_module_static;
}

size_t driver_arena_static_size(void) {
    return (size_t)DRIVER_ARENA_STATIC_SIZE_ABI;
}

size_t driver_module_static_size(void) {
    return (size_t)DRIVER_MODULE_STATIC_SIZE_ABI;
}

/**
 * Cap-giant-string residual：rt_preamble R2 full .x 访问巨型 C 字串表。
 * 数据定义在 seeds/rt_preamble.from_x.c（跨 TU 非 static）；本层暴露 line_at/count。
 * 始终提供（不随 RDABI thin 宏剥离）。
 */
extern const char *const driver_preamble_io_net_lines[];
extern const int32_t driver_preamble_io_net_lines_n;
extern const char *const driver_preamble_fs_path_lines[];
extern const int32_t driver_preamble_fs_path_lines_n;

uint8_t *driver_preamble_io_net_line_at(int32_t i) {
    if (i < 0 || i >= driver_preamble_io_net_lines_n)
        return NULL;
    return (uint8_t *)(uintptr_t)driver_preamble_io_net_lines[i];
}

int32_t driver_preamble_io_net_line_count(void) {
    return driver_preamble_io_net_lines_n;
}

uint8_t *driver_preamble_fs_path_line_at(int32_t i) {
    if (i < 0 || i >= driver_preamble_fs_path_lines_n)
        return NULL;
    return (uint8_t *)(uintptr_t)driver_preamble_fs_path_lines[i];
}

int32_t driver_preamble_fs_path_line_count(void) {
    return driver_preamble_fs_path_lines_n;
}

/** Cap residual：opaque *u8 stream → FILE* fputs（EOF 时返回负值）。 */
int32_t driver_preamble_fputs(uint8_t *s, uint8_t *stream) {
    if (s == NULL || stream == NULL)
        return -1;
    return (int32_t)fputs((const char *)(void *)s, (FILE *)(void *)stream);
}

/* ---------- Cap residual：rt_run_x_emit R2（平台/巨型布局） ---------- */
#ifndef X_CODEGEN_OUTBUF_CAP_ABI
#define X_CODEGEN_OUTBUF_CAP_ABI (9 * 1024 * 1024)
#endif
struct driver_codegen_outbuf_abi {
    unsigned char data[X_CODEGEN_OUTBUF_CAP_ABI];
    int32_t len;
};

extern const char *driver_x_emit_c_path;
extern const char *driver_x_emit_lib_roots[];
extern int driver_x_emit_n_lib_roots;
extern int driver_x_emit_c_want_extern;
extern int typeck_ndep;
extern void *typeck_dep_module_ptrs[];
extern void *typeck_dep_arena_ptrs[];

struct parser_ParseIntoResult {
    int32_t ok;
    int32_t main_idx;
};
extern struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data,
                                                          int32_t len);

uint8_t *driver_x_emit_take_c_path(void) {
    const char *p = driver_x_emit_c_path;
    driver_x_emit_c_path = NULL;
    return (uint8_t *)(void *)p;
}

int32_t driver_x_emit_take_want_extern(void) {
    int32_t w = (int32_t)driver_x_emit_c_want_extern;
    driver_x_emit_c_want_extern = 0;
    return w;
}

int32_t driver_x_emit_n_lib_roots_get(void) {
    return (int32_t)driver_x_emit_n_lib_roots;
}

uint8_t *driver_x_emit_lib_root_at(int32_t i) {
    if (i < 0 || i >= driver_x_emit_n_lib_roots)
        return NULL;
    return (uint8_t *)(void *)driver_x_emit_lib_roots[i];
}

void driver_x_emit_stdout_set_unbuffered(void) {
    (void)setvbuf(stdout, NULL, _IONBF, 0);
}

int32_t driver_x_emit_fwrite_stdout(uint8_t *data, int32_t len) {
    size_t n;
    if (data == NULL || len <= 0)
        return 0;
    n = fwrite(data, 1, (size_t)len, stdout);
    (void)fflush(stdout);
    return (int32_t)n;
}

void *driver_codegen_outbuf_calloc(void) {
    return calloc(1, sizeof(struct driver_codegen_outbuf_abi));
}

void driver_codegen_outbuf_free(void *p) {
    free(p);
}

int32_t driver_codegen_outbuf_len(void *p) {
    if (p == NULL)
        return 0;
    return ((struct driver_codegen_outbuf_abi *)p)->len;
}

uint8_t *driver_codegen_outbuf_data(void *p) {
    if (p == NULL)
        return NULL;
    return ((struct driver_codegen_outbuf_abi *)p)->data;
}

void *driver_pipeline_dep_ctx_calloc(void) {
    return calloc(1, sizeof(struct ast_PipelineDepCtx));
}

void *driver_ptr_table_calloc(int32_t n) {
    if (n <= 0)
        return NULL;
    return calloc((size_t)n, sizeof(void *));
}

void driver_ptr_table_free(void *t) {
    free(t);
}

void *driver_ptr_table_get(void *t, int32_t i) {
    if (t == NULL || i < 0)
        return NULL;
    return ((void **)t)[i];
}

void driver_ptr_table_set(void *t, int32_t i, void *p) {
    if (t == NULL || i < 0)
        return;
    ((void **)t)[i] = p;
}

void *driver_size_table_calloc(int32_t n) {
    if (n <= 0)
        return NULL;
    return calloc((size_t)n, sizeof(size_t));
}

void driver_size_table_free(void *t) {
    free(t);
}

size_t driver_size_table_get(void *t, int32_t i) {
    if (t == NULL || i < 0)
        return 0;
    return ((size_t *)t)[i];
}

void driver_size_table_set(void *t, int32_t i, size_t v) {
    if (t == NULL || i < 0)
        return;
    ((size_t *)t)[i] = v;
}

int32_t driver_parse_into_buf_rc(void *arena, void *module, uint8_t *data, int32_t len,
                                 int32_t *out_main_idx) {
    struct parser_ParseIntoResult pr;
    if (out_main_idx)
        *out_main_idx = -1;
    if (!arena || !module || !data)
        return -1;
    pr = parser_parse_into_buf(arena, module, data, len);
    if (out_main_idx)
        *out_main_idx = pr.main_idx;
    return pr.ok;
}

void *driver_diag_snapshot_alloc(void) {
    return calloc(1, sizeof(DiagContextSnapshot));
}

void driver_diag_snapshot_free(void *s) {
    free(s);
}

void driver_diag_push_file(void *snap, uint8_t *path, uint8_t *src, size_t len) {
    if (snap == NULL)
        return;
    diag_push_file((DiagContextSnapshot *)snap, (const char *)(void *)path,
                   (const char *)(void *)src, len);
}

void driver_diag_restore(void *snap) {
    if (snap == NULL)
        return;
    diag_restore((const DiagContextSnapshot *)snap);
}

void driver_typeck_ndep_set(int32_t n) {
    typeck_ndep = (int)n;
}

void driver_typeck_dep_ptrs_set(int32_t j, void *mod, void *arena) {
    if (j < 0 || j >= 32)
        return;
    typeck_dep_module_ptrs[j] = mod;
    typeck_dep_arena_ptrs[j] = arena;
}

static char g_driver_path_max_slot[4096];
static char g_driver_entry_dir_slot[512];

uint8_t *driver_path_max_slot(void) {
    return (uint8_t *)g_driver_path_max_slot;
}

uint8_t *driver_entry_dir_slot(void) {
    return (uint8_t *)g_driver_entry_dir_slot;
}

static const char *g_driver_x_emit_dot = ".";
static const char *g_driver_x_emit_one_root[1];

uint8_t *driver_x_emit_effective_lib_roots(int32_t *n_out) {
    if (driver_x_emit_n_lib_roots <= 0) {
        g_driver_x_emit_one_root[0] = g_driver_x_emit_dot;
        if (n_out)
            *n_out = 1;
        return (uint8_t *)(void *)g_driver_x_emit_one_root;
    }
    if (n_out)
        *n_out = (int32_t)driver_x_emit_n_lib_roots;
    return (uint8_t *)(void *)driver_x_emit_lib_roots;
}

extern int32_t parser_diag_fail_at_token_kind(struct shux_slice_uint8_t *source);

int32_t driver_parser_diag_fail_tok_kind(uint8_t *src, size_t len) {
    struct shux_slice_uint8_t s;
    if (src == NULL)
        return 0;
    s.data = src;
    s.length = len;
    return parser_diag_fail_at_token_kind(&s);
}

void driver_pipeline_dep_ctx_set_use_asm(void *ctx, int32_t v) {
    if (ctx == NULL)
        return;
    ((struct ast_PipelineDepCtx *)ctx)->use_asm_backend = v;
}

/*
 * Cap residual：rt_run_x_emit 工作槽。
 * 指针槽 i: 0 path 1 src 2 raw 3 arena 4 module 5 entry_dir 6 dep_sources
 *   7 dep_paths 8 dep_lens 9 dep_arenas 10 dep_modules 11 out_buf 12 pctx
 *   13 one_ctx 14 dep_out 15 dep_src 16 resolved 17 snap 18 dep_diag_file
 *   19 kind 20 code 21 msg 22 cpaths 23 out_data 24 lib_roots_as_u8 25 tmp_p
 * i32 槽 i: 0 want_extern 1 n_lib 2 n_deps 3 asm_direct 4 n_imports 5 main_idx
 *   6 pr_ok 7 ec 8 ec_dep 9 emit_ret 10 out_len 11 j 12 i 13 fail_tok
 *   14 n_closure 15 rc 16 free_src_flag
 * size_t 槽 i: 0 src_len 1 raw_len 2 arena_sz 3 module_sz 4 dep_len
 */
#define DRIVER_X_EMIT_WORK_NP 26
#define DRIVER_X_EMIT_WORK_NI 17
#define DRIVER_X_EMIT_WORK_NZ 5
static uint8_t *g_xe_work_p[DRIVER_X_EMIT_WORK_NP];
static int32_t g_xe_work_i[DRIVER_X_EMIT_WORK_NI];
static size_t g_xe_work_z[DRIVER_X_EMIT_WORK_NZ];

void driver_x_emit_work_reset(void) {
    memset(g_xe_work_p, 0, sizeof g_xe_work_p);
    memset(g_xe_work_i, 0, sizeof g_xe_work_i);
    memset(g_xe_work_z, 0, sizeof g_xe_work_z);
}

uint8_t *driver_x_emit_work_p_get(int32_t i) {
    if (i < 0 || i >= DRIVER_X_EMIT_WORK_NP)
        return NULL;
    return g_xe_work_p[i];
}

void driver_x_emit_work_p_set(int32_t i, uint8_t *v) {
    if (i < 0 || i >= DRIVER_X_EMIT_WORK_NP)
        return;
    g_xe_work_p[i] = v;
}

int32_t driver_x_emit_work_i_get(int32_t i) {
    if (i < 0 || i >= DRIVER_X_EMIT_WORK_NI)
        return 0;
    return g_xe_work_i[i];
}

void driver_x_emit_work_i_set(int32_t i, int32_t v) {
    if (i < 0 || i >= DRIVER_X_EMIT_WORK_NI)
        return;
    g_xe_work_i[i] = v;
}

size_t driver_x_emit_work_z_get(int32_t i) {
    if (i < 0 || i >= DRIVER_X_EMIT_WORK_NZ)
        return 0;
    return g_xe_work_z[i];
}

void driver_x_emit_work_z_set(int32_t i, size_t v) {
    if (i < 0 || i >= DRIVER_X_EMIT_WORK_NZ)
        return;
    g_xe_work_z[i] = v;
}

extern void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);

int32_t driver_x_emit_try_extern_via_cparser(uint8_t *input_path) {
    /*
     * 产品 runtime_driver_no_c 为 SHUX_NO_C_FRONTEND；driver_abi 本层不带该宏编译，
     * 故固定走 no-C 诊断（与产品 NO_C 语义一致）。
     * 冷启动全 C 体（seeds/rt_run_x_emit.from_x.c 无 FROM_X）仍可走 cparser 分支。
     */
    (void)input_path;
    diag_report_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001,
                          "-x -E -E-extern requires C parser/codegen (rebuild without -DSHUX_NO_C_FRONTEND)",
                          NULL);
    return 1;
}

void driver_x_emit_work_cleanup(void) {
    int32_t n = g_xe_work_i[2]; /* ndeps */
    int32_t i;
    void *p;
    void *ds = g_xe_work_p[6];
    void *dp = g_xe_work_p[7];
    void *dl = g_xe_work_p[8];
    void *da = g_xe_work_p[9];
    void *dm = g_xe_work_p[10];
    for (i = 0; i < n; i++) {
        if (da) {
            p = ((void **)da)[i];
            free(p);
        }
        if (dm) {
            p = ((void **)dm)[i];
            free(p);
        }
        if (ds) {
            p = ((void **)ds)[i];
            free(p);
        }
        if (dp) {
            p = ((void **)dp)[i];
            free(p);
        }
    }
    free(ds);
    free(dp);
    free(dl);
    free(da);
    free(dm);
    free(g_xe_work_p[11]); /* out_buf */
    if (g_xe_work_p[12])
        pipeline_dep_ctx_heap_destroy((struct ast_PipelineDepCtx *)(void *)g_xe_work_p[12]);
    free(g_xe_work_p[3]);  /* arena */
    free(g_xe_work_p[4]);  /* module */
    free(g_xe_work_p[1]);  /* src */
    free(g_xe_work_p[19]); /* kind */
    free(g_xe_work_p[20]); /* code */
    free(g_xe_work_p[21]); /* msg */
    driver_x_emit_work_reset();
}

/**
 * 扫描预处理后源码是否含顶层 import（`import("` 或 `= import(`）。
 * 参数：src 预处理后缓冲；src_len 有效字节数。
 * 返回值：1 含顶层 import；0 否。
 * G-02f-243/414：实现体始终 seed（memcmp 字面量）；public PREFER 时 thin pure forward。
 */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_source_scan_top_level_import_impl(const char *src, size_t src_len) {
    const char *p;
    const char *end;
    if (src == NULL)
        return 0;
    if (src_len < 8)
        return 0;
    p = src;
    end = src + src_len;
    while (p + 8 <= end) {
        if (memcmp(p, "import(\"", 8) == 0)
            return 1;
        if (p + 9 <= end && memcmp(p, "= import(", 9) == 0)
            return 1;
        p++;
    }
    return 0;
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_source_scan_top_level_import(const char *src, size_t src_len) {
    return driver_source_scan_top_level_import_impl(src, src_len);
}
#endif

/* G-02f-243/414：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_source_has_top_level_import_impl(const char *src, size_t src_len) {
    if (src == NULL) {
        return 0;
    }
    if (src_len < 9) {
        return 0;
    }
    return driver_source_scan_top_level_import_impl(src, src_len);
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_source_has_top_level_import(const char *src, size_t src_len) {
    return driver_source_has_top_level_import_impl(src, src_len);
}
#endif

/**
 * 读入口 .x 并预处理；返回 malloc 缓冲，长度经 driver_path_last_preprocess_len。
 * G-02f-244：IO 🔒；编排在 .x（scan pure + free）。
 */
static size_t g_driver_path_last_preprocess_len;

char *driver_path_read_preprocess_malloc(const char *path) {
    ShuxRuntimeFileView raw_view;
    size_t src_len = 0;
    char *src;

    g_driver_path_last_preprocess_len = 0;
    if (!path)
        return NULL;
    if (runtime_read_file_view(path, &raw_view) != 0)
        return NULL;
    src = shux_preprocess(raw_view.data, raw_view.length, NULL, 0, &src_len);
    runtime_release_file_view(&raw_view);
    if (!src)
        return NULL;
    g_driver_path_last_preprocess_len = src_len;
    return src;
}

/* G-02f-400：实现体始终 seed（读 static）；public PREFER 时 thin forward */
int64_t driver_path_last_preprocess_len_impl(void) {
    return (int64_t)g_driver_path_last_preprocess_len;
}

#ifndef SHUX_L2_RDABI_THIN_FROM_X
int64_t driver_path_last_preprocess_len(void) {
    return driver_path_last_preprocess_len_impl();
}
#endif

/* G-02f-244/414：实现体始终 seed（IO/preprocess）；public PREFER 时 thin pure forward */
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_source_has_top_level_import_path_impl(const char *path) {
    char *src;
    int has;
    int64_t len;

    if (path == NULL)
        return 0;
    src = driver_path_read_preprocess_malloc(path);
    if (!src)
        return 0;
    len = driver_path_last_preprocess_len_impl();
    has = driver_source_has_top_level_import_impl(src, (size_t)len);
    free(src);
    return has;
}
#endif
#ifndef SHUX_L2_RDABI_THIN_FROM_X
int driver_source_has_top_level_import_path(const char *path) {
    return driver_source_has_top_level_import_path_impl(path);
}
#endif

/* --------------------------------------------------------------------------
 * Cap residual：rt_run_asm_backend R2（FILE* / pctx 字段 / host #ifdef / **u8 / work 槽）
 * -------------------------------------------------------------------------- */

void driver_pipeline_dep_ctx_set_target_arch(void *ctx, int32_t v) {
    if (ctx == NULL)
        return;
    ((struct ast_PipelineDepCtx *)ctx)->target_arch = v;
}

void driver_pipeline_dep_ctx_set_target_cpu_features(void *ctx, int32_t v) {
    if (ctx == NULL)
        return;
    ((struct ast_PipelineDepCtx *)ctx)->target_cpu_features = v;
}

void driver_pipeline_dep_ctx_set_use_macho_o(void *ctx, int32_t v) {
    if (ctx == NULL)
        return;
    ((struct ast_PipelineDepCtx *)ctx)->use_macho_o = v;
}

void driver_pipeline_dep_ctx_set_use_coff_o(void *ctx, int32_t v) {
    if (ctx == NULL)
        return;
    ((struct ast_PipelineDepCtx *)ctx)->use_coff_o = v;
}

void driver_pipeline_dep_ctx_set_entry_already_parsed(void *ctx, int32_t v) {
    if (ctx == NULL)
        return;
    ((struct ast_PipelineDepCtx *)ctx)->entry_already_parsed = v;
}

void driver_pipeline_dep_ctx_set_asm_entry_module_only(void *ctx, int32_t v) {
    if (ctx == NULL)
        return;
    ((struct ast_PipelineDepCtx *)ctx)->asm_entry_module_only = v;
}

int32_t driver_pipeline_dep_ctx_get_asm_entry_module_only(void *ctx) {
    if (ctx == NULL)
        return 0;
    return ((struct ast_PipelineDepCtx *)ctx)->asm_entry_module_only;
}

int32_t driver_pipeline_dep_ctx_get_use_macho_o(void *ctx) {
    if (ctx == NULL)
        return 0;
    return ((struct ast_PipelineDepCtx *)ctx)->use_macho_o;
}

int32_t driver_pipeline_dep_ctx_get_use_coff_o(void *ctx) {
    if (ctx == NULL)
        return 0;
    return ((struct ast_PipelineDepCtx *)ctx)->use_coff_o;
}

extern uint32_t driver_get_pending_target_cpu_features(void);

void driver_asm_pctx_apply_host_defaults(void *ctx, uint8_t *target, int32_t emit_elf_o) {
    struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)ctx;
    const char *t = (const char *)(void *)target;
    if (pctx == NULL)
        return;
    pctx->target_arch = 0;
    if (t && (strstr(t, "aarch64") != NULL || strstr(t, "arm64") != NULL))
        pctx->target_arch = 1;
    if (t && strstr(t, "riscv64") != NULL)
        pctx->target_arch = 2;
    pctx->target_cpu_features = (int32_t)driver_get_pending_target_cpu_features();
#if defined(__APPLE__) && defined(__aarch64__)
    if (!t)
        pctx->target_arch = 1;
#endif
    pctx->use_macho_o = 0;
    pctx->use_coff_o = 0;
#if defined(__APPLE__)
    if (emit_elf_o)
        pctx->use_macho_o = 1;
#endif
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    if (emit_elf_o)
        pctx->use_coff_o = 1;
#endif
    if (emit_elf_o && t && strstr(t, "windows") != NULL)
        pctx->use_coff_o = 1;
}

uint8_t *driver_asm_fopen_wb(uint8_t *path) {
    if (path == NULL)
        return NULL;
    return (uint8_t *)(void *)fopen((const char *)(void *)path, "wb");
}

#ifndef SHUX_TMP_PREFIX
#if !defined(_WIN32) && !defined(_WIN64)
#define SHUX_TMP_PREFIX "/tmp/shux_"
#else
#define SHUX_TMP_PREFIX "shux_"
#endif
#endif

uint8_t *driver_asm_mkstemp_fdopen(uint8_t *path_out64) {
#if defined(_WIN32) || defined(_WIN64)
    (void)path_out64;
    return NULL;
#else
    int fd;
    FILE *fp;
    if (path_out64 == NULL)
        return NULL;
    snprintf((char *)(void *)path_out64, 64, "%sshux_asm_XXXXXX", SHUX_TMP_PREFIX);
    fd = mkstemp((char *)(void *)path_out64);
    if (fd < 0)
        return NULL;
    fp = fdopen(fd, "wb");
    if (!fp) {
        close(fd);
        unlink((char *)(void *)path_out64);
        path_out64[0] = 0;
        return NULL;
    }
    return (uint8_t *)(void *)fp;
#endif
}

void driver_asm_fclose(uint8_t *fp) {
    driver_asm_fclose_asm_out((FILE *)(void *)fp);
}

int32_t driver_asm_fwrite(uint8_t *fp, uint8_t *data, int32_t len) {
    FILE *out;
    size_t n;
    if (data == NULL || len <= 0)
        return 0;
    out = fp ? (FILE *)(void *)fp : stdout;
    n = fwrite(data, 1, (size_t)len, out);
    return (n == (size_t)len) ? 0 : 1;
}

void driver_asm_fflush_stdout(void) {
    (void)fflush(stdout);
}

int32_t driver_asm_write_metric_o(uint8_t *path) {
    FILE *metric_o;
    if (path == NULL)
        return 1;
    metric_o = fopen((const char *)(void *)path, "wb");
    if (!metric_o)
        return 1;
    (void)fputc('\0', metric_o);
    if (fclose(metric_o) != 0)
        return 1;
    return 0;
}

extern size_t pipeline_sizeof_elf_ctx(void);

uint8_t *driver_asm_elf_ctx_calloc(void) {
    size_t sz = pipeline_sizeof_elf_ctx();
    void *p;
    if (sz == 0)
        return NULL;
    p = malloc(sz);
    if (p)
        memset(p, 0, sz);
    return (uint8_t *)p;
}

void driver_asm_elf_ctx_free(uint8_t *p) {
    free(p);
}

static char g_driver_asm_tmp_path_slot[64];

uint8_t *driver_asm_tmp_path_slot(void) {
    return (uint8_t *)g_driver_asm_tmp_path_slot;
}

#ifndef MAX_DEFINES
#define MAX_DEFINES 64
#endif
static const char *g_driver_asm_defines[MAX_DEFINES];
static int32_t g_driver_asm_ndefines;

int32_t driver_asm_collect_defines(int32_t argc, uint8_t *argv) {
    g_driver_asm_ndefines = 0;
    memset(g_driver_asm_defines, 0, sizeof g_driver_asm_defines);
    if (argv == NULL || argc <= 0)
        return 0;
    g_driver_asm_ndefines = (int32_t)driver_argv_collect_defines(
        (int)argc, (char **)(void *)argv, g_driver_asm_defines, MAX_DEFINES);
    return g_driver_asm_ndefines;
}

uint8_t *driver_asm_defines_as_u8(void) {
    if (g_driver_asm_ndefines <= 0)
        return NULL;
    return (uint8_t *)(void *)g_driver_asm_defines;
}

int32_t driver_asm_ndefines_get(void) {
    return g_driver_asm_ndefines;
}

static const char *g_driver_asm_dot = ".";
static const char *g_driver_asm_one_root[1];
static const char **g_driver_asm_lib_roots_bound;
static int32_t g_driver_asm_n_lib_bound;

uint8_t *driver_asm_bind_lib_roots(uint8_t *lib_roots, int32_t n, int32_t *n_out) {
    g_driver_asm_lib_roots_bound = (const char **)(void *)lib_roots;
    g_driver_asm_n_lib_bound = n;
    if (n <= 0 || lib_roots == NULL) {
        g_driver_asm_one_root[0] = g_driver_asm_dot;
        if (n_out)
            *n_out = 1;
        return (uint8_t *)(void *)g_driver_asm_one_root;
    }
    if (n_out)
        *n_out = n;
    return lib_roots;
}

uint8_t *driver_asm_argv0(uint8_t *argv) {
    char **a = (char **)(void *)argv;
    if (a == NULL || a[0] == NULL)
        return NULL;
    return (uint8_t *)(void *)a[0];
}

int32_t driver_asm_try_c_frontend_early(uint8_t *input_path, uint8_t *src, uint8_t *lib_roots,
                                        int32_t n_lib, uint8_t *out_path) {
    /*
     * 产品 runtime_driver_no_c 为 SHUX_NO_C_FRONTEND；本层固定走 no-C 继续 pipeline。
     * 冷启动全 C 体（seeds/rt_run_asm_backend.from_x.c 无 FROM_X）仍含 #if 分支。
     */
    (void)input_path;
    (void)src;
    (void)lib_roots;
    (void)n_lib;
    (void)out_path;
    return -2;
}

int32_t driver_asm_try_c_typeck_precheck(uint8_t *input_path, uint8_t *src, uint8_t *lib_roots,
                                        int32_t n_lib) {
    (void)input_path;
    (void)src;
    (void)lib_roots;
    (void)n_lib;
    /* 产品 NO_C：跳过 C typeck 预检。 */
    return -1;
}

int32_t driver_asm_use_compiler_impl_c(void) {
#if defined(SHUX_ASM_USE_COMPILER_IMPL_C)
    return 1;
#else
    return 0;
#endif
}

/*
 * asm work 槽：
 * p: 0 path 1 src 2 out_path 3 arena 4 module 5 entry 6 dsrc 7 dpath 8 dlens
 *    9 dar 10 dmod 11 out_buf 12 pctx 13 kind 14 code 15 msg 16 lib 17 target
 *    18 argv 19 asm_out 20 elf 21 defines 22 tmp_path 23 one_ctx 24 dep_out
 * i: 0 nlib 1 ndeps 2 nimp 3 main 4 emit_elf 5 want_exe 6 smoke 7 ndef 8 argc
 *    9 ec 10 j 11 entry_only 12 skip_dep_load 13 rc 14 n_closure 15 num_funcs
 * z: 0 src_len 1 asz 2 msz 3 dep_len
 */
#define DRIVER_ASM_WORK_NP 25
#define DRIVER_ASM_WORK_NI 16
#define DRIVER_ASM_WORK_NZ 4
static uint8_t *g_asm_work_p[DRIVER_ASM_WORK_NP];
static int32_t g_asm_work_i[DRIVER_ASM_WORK_NI];
static size_t g_asm_work_z[DRIVER_ASM_WORK_NZ];

void driver_asm_work_reset(void) {
    memset(g_asm_work_p, 0, sizeof g_asm_work_p);
    memset(g_asm_work_i, 0, sizeof g_asm_work_i);
    memset(g_asm_work_z, 0, sizeof g_asm_work_z);
    g_driver_asm_tmp_path_slot[0] = 0;
}

uint8_t *driver_asm_work_p_get(int32_t i) {
    if (i < 0 || i >= DRIVER_ASM_WORK_NP)
        return NULL;
    return g_asm_work_p[i];
}

void driver_asm_work_p_set(int32_t i, uint8_t *v) {
    if (i < 0 || i >= DRIVER_ASM_WORK_NP)
        return;
    g_asm_work_p[i] = v;
}

int32_t driver_asm_work_i_get(int32_t i) {
    if (i < 0 || i >= DRIVER_ASM_WORK_NI)
        return 0;
    return g_asm_work_i[i];
}

void driver_asm_work_i_set(int32_t i, int32_t v) {
    if (i < 0 || i >= DRIVER_ASM_WORK_NI)
        return;
    g_asm_work_i[i] = v;
}

size_t driver_asm_work_z_get(int32_t i) {
    if (i < 0 || i >= DRIVER_ASM_WORK_NZ)
        return 0;
    return g_asm_work_z[i];
}

void driver_asm_work_z_set(int32_t i, size_t v) {
    if (i < 0 || i >= DRIVER_ASM_WORK_NZ)
        return;
    g_asm_work_z[i] = v;
}

void driver_asm_work_cleanup(void) {
    int32_t n = g_asm_work_i[1]; /* ndeps */
    int32_t i;
    void *p;
    void *ds = g_asm_work_p[6];
    void *dp = g_asm_work_p[7];
    void *dl = g_asm_work_p[8];
    void *da = g_asm_work_p[9];
    void *dm = g_asm_work_p[10];
    for (i = 0; i < n; i++) {
        if (da) {
            p = ((void **)da)[i];
            free(p);
        }
        if (dm) {
            p = ((void **)dm)[i];
            free(p);
        }
        if (ds) {
            p = ((void **)ds)[i];
            free(p);
        }
        if (dp) {
            p = ((void **)dp)[i];
            free(p);
        }
    }
    free(ds);
    free(dp);
    free(dl);
    free(da);
    free(dm);
    free(g_asm_work_p[11]); /* out_buf */
    if (g_asm_work_p[12])
        pipeline_dep_ctx_heap_destroy((struct ast_PipelineDepCtx *)(void *)g_asm_work_p[12]);
    if (g_asm_work_p[19])
        driver_asm_fclose_asm_out((FILE *)(void *)g_asm_work_p[19]);
    free(g_asm_work_p[20]); /* elf */
    free(g_asm_work_p[3]);  /* arena */
    free(g_asm_work_p[4]);  /* module */
    free(g_asm_work_p[1]);  /* src */
    free(g_asm_work_p[13]); /* kind */
    free(g_asm_work_p[14]); /* code */
    free(g_asm_work_p[15]); /* msg */
    driver_asm_work_reset();
}

/* ========== Cap residual: rt_run_compiler_parsed R2 full ========== */

#ifndef X_FULL_MAX_LIB_ROOTS
#define X_FULL_MAX_LIB_ROOTS 16
#endif
#ifndef SHUX_TMP_PREFIX
#if !defined(_WIN32) && !defined(_WIN64)
#define SHUX_TMP_PREFIX "/tmp/shux_"
#else
#define SHUX_TMP_PREFIX "shux_"
#endif
#endif

typedef struct DriverCompileParsedAbi {
    const char *input_path;
    const char *out_path;
    const char *lib_roots_arr[X_FULL_MAX_LIB_ROOTS];
    int n_lib_roots;
    int want_asm_backend;
    const char *target;
    const char *opt_level;
    int use_lto;
} DriverCompileParsedAbi;

extern int write_io_net_abi_inline(FILE *cf);
extern int write_fs_path_map_error_abi_inline(FILE *cf);
extern int shux_write_path_bytes(const char *path, const void *data, size_t len);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail,
                         const char *fmt, ...);
extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern void runtime_diag_errno_path_pair(const char *file, const char *kind, const char *op,
                                         const char *from_path, const char *to_path);
extern void driver_unlink_failed_output(const char *out_path);
extern const char *shux_std_io_o_path(const char *argv0);
extern const char *shux_rel_o_path_from_argv0(const char *argv0, const char *rel);
extern const char *shux_runtime_panic_o_path(const char *argv0);
extern const char *shux_repo_root_from_argv0(const char *argv0);
extern int shux_invoke_cc(const char **c_paths, int n, const char *out_path, const char *target,
                          const char *opt_level, int use_lto, const char *io_o, const char *fs_o,
                          const char *process_o, const char *string_o, const char *heap_o, const char *path_o,
                          const char *runtime_o, const char *runtime_panic_o, const char *net_o,
                          const char *thread_o, const char *time_o, const char *random_o, const char *env_o,
                          const char *sync_o, const char *encoding_o, const char *base64_o, const char *crypto_o,
                          const char *log_o, const char *atomic_o, const char *channel_o, const char *backtrace_o,
                          const char *hash_o, const char *math_o, const char *sort_o, const char *ffi_o,
                          const char *db_o, const char *elf_o, const char *json_o, const char *csv_o,
                          const char *regex_o, const char *compress_o, const char *unicode_o, const char *dynlib_o,
                          const char *http_o, const char *tar_o, const char *simd_o, const char *context_o,
                          const char *datetime_o, const char *uuid_o, const char *url_o, const char *cli_o,
                          const char *security_o, const char *config_o, const char *cache_o, const char *trace_o,
                          const char *task_o, const char *schema_o, const char *test_o, const char *include_root,
                          const char *async_scheduler_o);
extern void codegen_reset_preamble_skip_mask(void);
extern void codegen_or_preamble_skip_mask(unsigned mask);
#ifndef CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS
#define CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS 1u
#define CODEGEN_PREAMBLE_SKIP_STD_IO_UNDEF_REDEFINE 4u
#endif

uint8_t *driver_parsed_input_path(void *p) {
    if (!p) return NULL;
    return (uint8_t *)(void *)((DriverCompileParsedAbi *)p)->input_path;
}
uint8_t *driver_parsed_out_path(void *p) {
    if (!p) return NULL;
    return (uint8_t *)(void *)((DriverCompileParsedAbi *)p)->out_path;
}
uint8_t *driver_parsed_lib_roots(void *p) {
    if (!p) return NULL;
    return (uint8_t *)(void *)((DriverCompileParsedAbi *)p)->lib_roots_arr;
}
int32_t driver_parsed_n_lib_roots(void *p) {
    if (!p) return 0;
    return (int32_t)((DriverCompileParsedAbi *)p)->n_lib_roots;
}
int32_t driver_parsed_want_asm(void *p) {
    if (!p) return 0;
    return (int32_t)((DriverCompileParsedAbi *)p)->want_asm_backend;
}
uint8_t *driver_parsed_target(void *p) {
    if (!p) return NULL;
    return (uint8_t *)(void *)((DriverCompileParsedAbi *)p)->target;
}
static const char g_driver_parsed_opt_default[] = "2";
uint8_t *driver_parsed_opt_level(void *p) {
    const char *o;
    if (!p) return (uint8_t *)(void *)g_driver_parsed_opt_default;
    o = ((DriverCompileParsedAbi *)p)->opt_level;
    if (!o) return (uint8_t *)(void *)g_driver_parsed_opt_default;
    return (uint8_t *)(void *)o;
}
int32_t driver_parsed_use_lto(void *p) {
    if (!p) return 0;
    return (int32_t)((DriverCompileParsedAbi *)p)->use_lto;
}

int32_t driver_parsed_try_c_after_pp(uint8_t *input_path, uint8_t *src, size_t src_len,
                                     uint8_t *lib_roots, int32_t n_lib, uint8_t *out_path,
                                     int32_t argc, uint8_t *argv, uint8_t *opt_level,
                                     int32_t use_lto, int32_t ndefines, uint8_t *defines) {
    /*
     * 产品 runtime_driver_no_c 为 SHUX_NO_C_FRONTEND：固定继续 .x pipeline。
     * 冷启动全 C 体（seeds/rt_run_compiler_parsed.from_x.c 无 FROM_X）仍含完整 C 分支。
     */
    (void)input_path;
    (void)src;
    (void)src_len;
    (void)lib_roots;
    (void)n_lib;
    (void)out_path;
    (void)argc;
    (void)argv;
    (void)opt_level;
    (void)use_lto;
    (void)ndefines;
    (void)defines;
    return -2;
}

void driver_pipeline_dep_ctx_set_skip_codegen_dep_0(void *ctx, int32_t v) {
    if (!ctx) return;
    ((struct ast_PipelineDepCtx *)ctx)->skip_codegen_dep_0 = (int)v;
}

static char g_driver_parsed_tmp_c[64];

uint8_t *driver_parsed_open_out_file(uint8_t *out_path, uint8_t *tmp_c_out64, int32_t *emit_stdout) {
    char tmp[128];
    int fd;
    FILE *cf;
    if (emit_stdout)
        *emit_stdout = 0;
    g_driver_parsed_tmp_c[0] = 0;
    if (tmp_c_out64)
        tmp_c_out64[0] = 0;
    if (!out_path) {
        if (emit_stdout)
            *emit_stdout = 1;
        return (uint8_t *)(void *)stdout;
    }
    snprintf(tmp, sizeof(tmp), "%sshux_x.XXXXXX", SHUX_TMP_PREFIX);
    fd = mkstemp(tmp);
    if (fd < 0) {
        runtime_diag_errno_path((const char *)(void *)out_path, "build error", "mkstemp", tmp);
        return NULL;
    }
    cf = fdopen(fd, "w");
    if (!cf) {
        runtime_diag_errno_path((const char *)(void *)out_path, "build error", "fdopen", tmp);
        close(fd);
        unlink(tmp);
        return NULL;
    }
    snprintf(g_driver_parsed_tmp_c, sizeof(g_driver_parsed_tmp_c), "%s.c", tmp);
    if (rename(tmp, g_driver_parsed_tmp_c) != 0) {
        runtime_diag_errno_path_pair((const char *)(void *)out_path, "build error", "rename", tmp,
                                     g_driver_parsed_tmp_c);
        unlink(tmp);
        fclose(cf);
        return NULL;
    }
    if (tmp_c_out64) {
        size_t n = strlen(g_driver_parsed_tmp_c);
        if (n > 63)
            n = 63;
        memcpy(tmp_c_out64, g_driver_parsed_tmp_c, n);
        tmp_c_out64[n] = 0;
    }
    return (uint8_t *)(void *)cf;
}

void driver_parsed_fclose(uint8_t *fp) {
    if (!fp || fp == (uint8_t *)(void *)stdout)
        return;
    fclose((FILE *)(void *)fp);
}

int32_t driver_parsed_fclose_rc(uint8_t *fp) {
    if (!fp || fp == (uint8_t *)(void *)stdout)
        return 0;
    return fclose((FILE *)(void *)fp) == 0 ? 0 : 1;
}

int32_t driver_parsed_write_out(uint8_t *fp, uint8_t *data, int32_t len) {
    FILE *cf = (FILE *)(void *)fp;
    size_t first_line = 0;
    int need_preamble;
    static const char min_preamble[] =
        "/* generated */\n#include <stdint.h>\n#include <stddef.h>\n#include <stdlib.h>\n#include "
        "<stdio.h>\n#include <string.h>\n";
    if (!cf || !data || len < 0)
        return 1;
    while (first_line < (size_t)len && data[first_line] != '\n')
        first_line++;
    if (first_line < (size_t)len)
        first_line++;
    need_preamble =
        (len > 0 && data[0] != '#' && (len < 2 || data[0] != '/' || data[1] != '*'));
    if (need_preamble) {
        if (fwrite(min_preamble, 1, sizeof(min_preamble) - 1, cf) != (size_t)(sizeof(min_preamble) - 1))
            return 1;
    }
    if (fwrite(data, 1, first_line, cf) != first_line)
        return 1;
    if (write_io_net_abi_inline(cf) != 0)
        return 1;
    if (write_fs_path_map_error_abi_inline(cf) != 0)
        return 1;
    if (fwrite(data + first_line, 1, (size_t)len - first_line, cf) != (size_t)len - first_line)
        return 1;
    return 0;
}

int32_t driver_parsed_invoke_cc(uint8_t *tmp_c, uint8_t *out_path, uint8_t *opt_level, int32_t use_lto,
                                uint8_t *argv0) {
    const char *c_paths[1];
    const char *a0 = (const char *)(void *)argv0;
    const char *opt = opt_level ? (const char *)(void *)opt_level : "2";
    const char *io_o = shux_std_io_o_path(a0);
    const char *fs_o = NULL;
    const char *process_o = shux_rel_o_path_from_argv0(a0, "std/process/process.o");
    const char *string_o = shux_rel_o_path_from_argv0(a0, "std/string/string.o");
    const char *heap_o = NULL;
    const char *path_o = shux_rel_o_path_from_argv0(a0, "std/path/path.o");
    const char *runtime_o = shux_rel_o_path_from_argv0(a0, "std/runtime/runtime.o");
    const char *runtime_panic_o = shux_runtime_panic_o_path(a0);
    const char *net_o = shux_rel_o_path_from_argv0(a0, "std/net/net.o");
    const char *thread_o = shux_rel_o_path_from_argv0(a0, "std/thread/thread.o");
    const char *time_o = shux_rel_o_path_from_argv0(a0, "std/time/time.o");
    const char *random_o = shux_rel_o_path_from_argv0(a0, "std/random/random.o");
    const char *env_o = shux_rel_o_path_from_argv0(a0, "std/env/env.o");
    const char *sync_o = shux_rel_o_path_from_argv0(a0, "std/sync/sync.o");
    const char *encoding_o = shux_rel_o_path_from_argv0(a0, "std/encoding/encoding.o");
    const char *base64_o = shux_rel_o_path_from_argv0(a0, "std/base64/base64.o");
    const char *crypto_o = shux_rel_o_path_from_argv0(a0, "std/crypto/crypto.o");
    const char *log_o = shux_rel_o_path_from_argv0(a0, "std/log/log.o");
    const char *atomic_o = shux_rel_o_path_from_argv0(a0, "std/atomic/atomic.o");
    const char *channel_o = shux_rel_o_path_from_argv0(a0, "std/channel/channel.o");
    const char *backtrace_o = shux_rel_o_path_from_argv0(a0, "std/backtrace/backtrace.o");
    const char *hash_o = shux_rel_o_path_from_argv0(a0, "std/hash/hash.o");
    const char *math_o = shux_rel_o_path_from_argv0(a0, "std/math/math.o");
    const char *sort_o = shux_rel_o_path_from_argv0(a0, "std/sort/sort.o");
    const char *ffi_o = shux_rel_o_path_from_argv0(a0, "std/ffi/ffi.o");
    const char *db_o = shux_rel_o_path_from_argv0(a0, "std/db/sqlite/sqlite.o");
    const char *elf_o = shux_rel_o_path_from_argv0(a0, "std/elf/elf.o");
    const char *json_o = shux_rel_o_path_from_argv0(a0, "std/json/json.o");
    const char *csv_o = shux_rel_o_path_from_argv0(a0, "std/csv/csv.o");
    const char *regex_o = shux_rel_o_path_from_argv0(a0, "std/regex/regex.o");
    const char *compress_o = NULL;
    const char *unicode_o = shux_rel_o_path_from_argv0(a0, "std/unicode/unicode.o");
    const char *dynlib_o = shux_rel_o_path_from_argv0(a0, "std/dynlib/dynlib.o");
    const char *http_o = shux_rel_o_path_from_argv0(a0, "std/http/http.o");
    const char *tar_o = shux_rel_o_path_from_argv0(a0, "std/tar/tar.o");
    const char *simd_o = shux_rel_o_path_from_argv0(a0, "std/simd/simd.o");
    const char *context_o = shux_rel_o_path_from_argv0(a0, "std/context/context.o");
    const char *datetime_o = shux_rel_o_path_from_argv0(a0, "std/datetime/datetime.o");
    const char *uuid_o = shux_rel_o_path_from_argv0(a0, "std/uuid/uuid.o");
    const char *url_o = shux_rel_o_path_from_argv0(a0, "std/url/url.o");
    const char *cli_o = shux_rel_o_path_from_argv0(a0, "std/cli/cli.o");
    const char *security_o = shux_rel_o_path_from_argv0(a0, "std/security/security.o");
    const char *config_o = shux_rel_o_path_from_argv0(a0, "std/config/config.o");
    const char *cache_o = shux_rel_o_path_from_argv0(a0, "std/cache/cache.o");
    const char *trace_o = shux_rel_o_path_from_argv0(a0, "std/trace/trace.o");
    const char *task_o = shux_rel_o_path_from_argv0(a0, "std/task/task.o");
    const char *schema_o = shux_rel_o_path_from_argv0(a0, "std/schema/schema.o");
    const char *test_o = shux_rel_o_path_from_argv0(a0, "std/test/test.o");
    int cc_ret;
    if (!tmp_c || !out_path)
        return 1;
    c_paths[0] = (const char *)(void *)tmp_c;
    cc_ret = shux_invoke_cc(c_paths, 1, (const char *)(void *)out_path, NULL, opt, (int)use_lto, io_o,
                            fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o,
                            thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o,
                            atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o,
                            csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o,
                            datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o,
                            schema_o, test_o, shux_repo_root_from_argv0(a0), NULL);
    if (cc_ret != 0) {
        driver_unlink_failed_output((const char *)(void *)out_path);
        diag_reportf_with_code(NULL, 0, 0, "build error", "BLD001", NULL,
                               "cc failed, keeping generated C: %s", (const char *)(void *)tmp_c);
        return 1;
    }
    if (!getenv("SHUX_KEEP_C"))
        unlink((const char *)(void *)tmp_c);
    else
        diag_reportf(NULL, 0, 0, "note", NULL, "kept generated C: %s", (const char *)(void *)tmp_c);
    return 0;
}

void driver_parsed_maybe_dump_prep(uint8_t *input_path, uint8_t *src, size_t src_len) {
    if (!getenv("SHUX_DUMP_PREP") || !src)
        return;
    if (shux_write_path_bytes("/tmp/shux_prep_entry.bin", src, src_len) == 0) {
        diag_reportf((const char *)(void *)input_path, 0, 0, "note", NULL,
                     "dumped prep entry (%zu bytes) to /tmp/shux_prep_entry.bin", src_len);
    }
}

int32_t driver_parsed_deps_has_std_io_core(uint8_t *dep_paths, int32_t n_deps) {
    int32_t j;
    char **dp = (char **)(void *)dep_paths;
    if (!dp || n_deps <= 0)
        return 0;
    for (j = 0; j < n_deps; j++) {
        if (dp[j] && strcmp(dp[j], "std.io.core") == 0)
            return 1;
    }
    return 0;
}

void driver_parsed_apply_preamble_skip(uint8_t *dep_paths, int32_t n_deps) {
    codegen_reset_preamble_skip_mask();
    if (!driver_parsed_deps_has_std_io_core(dep_paths, n_deps)) {
        codegen_or_preamble_skip_mask(CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS |
                                      CODEGEN_PREAMBLE_SKIP_STD_IO_UNDEF_REDEFINE);
    }
}

/*
 * parsed work 槽：
 * p: 0 path 1 src 2 out_path 3 arena 4 module 5 entry 6 dsrc 7 dpath 8 dlens
 *    9 dar 10 dmod 11 out_buf 12 pctx 13 kind 14 code 15 msg 16 lib 17 opt
 *    18 argv 19 cf 20 tmp_c 21 target 22 defs
 * i: 0 nlib 1 ndeps 2 nimp 3 main 4 want_asm 5 emit_stdout 6 ndef 7 use_lto
 *    8 argc 9 ec 10 j 11 check 12 n_funcs
 * z: 0 src_len 1 asz 2 msz
 */
#define DRIVER_PARSED_WORK_NP 24
#define DRIVER_PARSED_WORK_NI 14
#define DRIVER_PARSED_WORK_NZ 4
static uint8_t *g_parsed_work_p[DRIVER_PARSED_WORK_NP];
static int32_t g_parsed_work_i[DRIVER_PARSED_WORK_NI];
static size_t g_parsed_work_z[DRIVER_PARSED_WORK_NZ];
static char g_parsed_tmp_c_slot[64];

void driver_parsed_work_reset(void) {
    memset(g_parsed_work_p, 0, sizeof g_parsed_work_p);
    memset(g_parsed_work_i, 0, sizeof g_parsed_work_i);
    memset(g_parsed_work_z, 0, sizeof g_parsed_work_z);
    g_parsed_tmp_c_slot[0] = 0;
    g_driver_parsed_tmp_c[0] = 0;
}

uint8_t *driver_parsed_work_p_get(int32_t i) {
    if (i < 0 || i >= DRIVER_PARSED_WORK_NP)
        return NULL;
    return g_parsed_work_p[i];
}
void driver_parsed_work_p_set(int32_t i, uint8_t *v) {
    if (i < 0 || i >= DRIVER_PARSED_WORK_NP)
        return;
    g_parsed_work_p[i] = v;
}
int32_t driver_parsed_work_i_get(int32_t i) {
    if (i < 0 || i >= DRIVER_PARSED_WORK_NI)
        return 0;
    return g_parsed_work_i[i];
}
void driver_parsed_work_i_set(int32_t i, int32_t v) {
    if (i < 0 || i >= DRIVER_PARSED_WORK_NI)
        return;
    g_parsed_work_i[i] = v;
}
size_t driver_parsed_work_z_get(int32_t i) {
    if (i < 0 || i >= DRIVER_PARSED_WORK_NZ)
        return 0;
    return g_parsed_work_z[i];
}
void driver_parsed_work_z_set(int32_t i, size_t v) {
    if (i < 0 || i >= DRIVER_PARSED_WORK_NZ)
        return;
    g_parsed_work_z[i] = v;
}

void driver_parsed_work_cleanup(void) {
    int32_t n = g_parsed_work_i[1]; /* ndeps */
    int32_t emit_stdout = g_parsed_work_i[5];
    int32_t i;
    void *p;
    void *ds = g_parsed_work_p[6];
    void *dp = g_parsed_work_p[7];
    void *dl = g_parsed_work_p[8];
    void *da = g_parsed_work_p[9];
    void *dm = g_parsed_work_p[10];
    for (i = 0; i < n; i++) {
        if (da) {
            p = ((void **)da)[i];
            free(p);
        }
        if (dm) {
            p = ((void **)dm)[i];
            free(p);
        }
        if (ds) {
            p = ((void **)ds)[i];
            free(p);
        }
        if (dp) {
            p = ((void **)dp)[i];
            free(p);
        }
    }
    free(ds);
    free(dp);
    free(dl);
    free(da);
    free(dm);
    free(g_parsed_work_p[11]); /* out_buf */
    if (g_parsed_work_p[12])
        pipeline_dep_ctx_heap_destroy((struct ast_PipelineDepCtx *)(void *)g_parsed_work_p[12]);
    if (g_parsed_work_p[19] && !emit_stdout) {
        driver_parsed_fclose(g_parsed_work_p[19]);
        if (g_parsed_work_p[20] && g_parsed_work_p[20][0])
            unlink((const char *)(void *)g_parsed_work_p[20]);
        else if (g_driver_parsed_tmp_c[0])
            unlink(g_driver_parsed_tmp_c);
    }
    free(g_parsed_work_p[3]);  /* arena */
    free(g_parsed_work_p[4]);  /* module */
    free(g_parsed_work_p[1]);  /* src */
    free(g_parsed_work_p[13]); /* kind */
    free(g_parsed_work_p[14]); /* code */
    free(g_parsed_work_p[15]); /* msg */
    free(g_parsed_work_p[20]); /* tmp_c heap copy if any */
    driver_parsed_work_reset();
}

/* ========== Cap residual: rt_dispatch_impl R2 full ========== */

extern int driver_lib_roots_from_key(uint8_t *lib_key, const char **out_arr,
                                     char bufs[X_FULL_MAX_LIB_ROOTS][512]);
extern int driver_run_compiler_parsed(void *p, int argc, char **argv);

static char g_dispatch_lib_bufs[X_FULL_MAX_LIB_ROOTS][512];
static const char *g_dispatch_lib_roots[X_FULL_MAX_LIB_ROOTS];
static const char g_dispatch_opt_default[] = "2";

uint8_t *driver_dispatch_lib_roots_from_key(uint8_t *lib_key, int32_t *n_out) {
    int n = driver_lib_roots_from_key(lib_key, g_dispatch_lib_roots, g_dispatch_lib_bufs);
    if (n_out)
        *n_out = (int32_t)n;
    return (uint8_t *)(void *)g_dispatch_lib_roots;
}

uint8_t *driver_dispatch_lib_root_at(uint8_t *roots, int32_t i) {
    const char **arr;
    if (!roots || i < 0 || i >= X_FULL_MAX_LIB_ROOTS)
        return NULL;
    arr = (const char **)(void *)roots;
    return (uint8_t *)(void *)arr[i];
}

uint8_t *driver_dispatch_opt_default(void) {
    return (uint8_t *)(void *)g_dispatch_opt_default;
}

int32_t driver_dispatch_run_compiler_parsed(uint8_t *input_path, uint8_t *out_path,
                                            uint8_t *lib_roots, int32_t n_lib,
                                            uint8_t *target, uint8_t *opt_level,
                                            int32_t use_lto, int32_t argc, uint8_t *argv) {
    DriverCompileParsedAbi p;
    int n = n_lib;
    memset(&p, 0, sizeof p);
    p.input_path = (const char *)(void *)input_path;
    p.out_path = out_path ? (const char *)(void *)out_path : NULL;
    if (n > X_FULL_MAX_LIB_ROOTS)
        n = X_FULL_MAX_LIB_ROOTS;
    if (n > 0 && lib_roots)
        memcpy(p.lib_roots_arr, lib_roots, (size_t)n * sizeof(const char *));
    p.n_lib_roots = n;
    p.want_asm_backend = 0;
    p.target = (target && target[0]) ? (const char *)(void *)target : NULL;
    p.opt_level = (opt_level && opt_level[0]) ? (const char *)(void *)opt_level : g_dispatch_opt_default;
    p.use_lto = use_lto != 0;
    return (int32_t)driver_run_compiler_parsed((void *)&p, (int)argc, (char **)(void *)argv);
}

/* ---------- Cap residual：rt_asm_stub R2（GAS 行表 + OutBuf append） ---------- */
static const char *const g_asm_stub_gas_lines[] = {
    ".text",         ".globl main", "main:",       "pushq %rbp", "movq %rsp, %rbp",
    "subq $0, %rsp", "movl $42, %eax", "movq %rsp, %rbp", "popq %rbp", "ret",
};
static const int32_t g_asm_stub_gas_lines_n =
    (int32_t)(sizeof g_asm_stub_gas_lines / sizeof g_asm_stub_gas_lines[0]);

uint8_t *driver_asm_stub_gas_line_at(int32_t i) {
    if (i < 0 || i >= g_asm_stub_gas_lines_n)
        return NULL;
    return (uint8_t *)(uintptr_t)g_asm_stub_gas_lines[i];
}

int32_t driver_asm_stub_gas_line_count(void) {
    return g_asm_stub_gas_lines_n;
}

int32_t driver_asm_stub_out_append_cstr(void *out, uint8_t *s) {
    struct driver_codegen_outbuf_abi *ob;
    size_t n;
    size_t len;
    size_t cur;
    if (!out || !s)
        return -1;
    ob = (struct driver_codegen_outbuf_abi *)out;
    len = strlen((const char *)(void *)s);
    cur = (size_t)ob->len;
    if (cur > (size_t)X_CODEGEN_OUTBUF_CAP_ABI)
        return -1;
    if (cur + len + 1 > (size_t)X_CODEGEN_OUTBUF_CAP_ABI)
        return -1;
    memcpy(ob->data + cur, s, len);
    ob->data[cur + len] = (unsigned char)'\n';
    n = cur + len + 1;
    ob->len = (int32_t)n;
    return 0;
}

/* ---------- Cap residual：rt_dispatch_thin R2（sibling path/access/fork） ---------- */
extern int driver_argv0_basename_is(const char *argv0, const char *base);

/**
 * 与冷启动 seeds/rt_dispatch_thin.from_x.c driver_try_compile_via_shu_c_sibling 同语义。
 * argv 为 char**（*u8）；成功返回子进程 exit；-1 未委托。
 */
int32_t driver_dispatch_sibling_try_spawn(int32_t argc, uint8_t *argv) {
    char shu_c[512];
    char **av = (char **)(void *)argv;
    const char *self;
    const char *slash;
    if (argc < 2 || !av || !av[0])
        return -1;
    if (driver_argv0_basename_is(av[0], "shux-c"))
        return -1;
    self = av[0];
    slash = strrchr(self, '/');
#if defined(_WIN32)
    {
        const char *bs = strrchr(self, '\\');
        if (bs && (!slash || bs > slash))
            slash = bs;
    }
#endif
    if (slash) {
        size_t dir_len = (size_t)(slash - self);
        if (dir_len >= sizeof(shu_c) - 8)
            return -1;
        memcpy(shu_c, self, dir_len);
        shu_c[dir_len] = '\0';
        strcat(shu_c, "/shux-c");
    } else {
        strcpy(shu_c, "shux-c");
    }
    if (access(shu_c, X_OK) != 0)
        return -1;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    {
        intptr_t rc;
        av[0] = shu_c;
        rc = _spawnvp(_P_WAIT, shu_c, (const char *const *)av);
        if (rc == -1)
            return -1;
        return (int32_t)rc;
    }
#else
    {
        pid_t pid = fork();
        if (pid < 0)
            return -1;
        if (pid == 0) {
            av[0] = shu_c;
            execvp(shu_c, av);
            _exit(127);
        }
        {
            int st = 0;
            if (waitpid(pid, &st, 0) < 0)
                return -1;
            if (WIFEXITED(st))
                return (int32_t)WEXITSTATUS(st);
            return 1;
        }
    }
#endif
}

int runtime_driver_abi_slice_marker(void) {
    return 1;
}
