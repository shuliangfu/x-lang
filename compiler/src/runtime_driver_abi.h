/**
 * runtime_driver_abi.h — 编译器 C 侧 driver 状态 ABI 声明（Phase E-04 v22～v29）
 *
 * 文件职责：声明 driver CLI / pipeline 跳过标志、asm 环境、阶段计时与 check 输出辅助。
 * 所属模块：compiler 运行时 ABI；实现于 runtime_driver_abi.c。
 * 与其它文件的关系：runtime.c 仍承载 pipeline/run_compiler_c 主体；本头不依赖 C 前端头。
 */

#ifndef SHUX_RUNTIME_DRIVER_ABI_H
#define SHUX_RUNTIME_DRIVER_ABI_H

#include <stdint.h>
#include <stddef.h>

/** shux check：非 0 时 typeck 通过后跳过 codegen 与链接。 */
void driver_check_only_set(int32_t v);
int32_t driver_check_only_get(void);

/** `-freestanding`：用户程序 nostdlib 静态链。 */
void driver_freestanding_set(int32_t v);
int32_t driver_freestanding_get(void);

/** `-fsanitize=address` / SHUX_SANITIZE_ADDRESS=1 时强制边界检查。 */
void driver_sanitize_address_set(int32_t v);
int32_t driver_sanitize_address_get(void);

/** shux fmt --check：仅校验格式，不写回。 */
void driver_fmt_check_only_set(int32_t v);
int32_t driver_fmt_check_only_get(void);

/** 非 SX 链或未链 fmt_check_cmd 时弱符号默认 0（批量 check 成功时静默）。 */
int driver_check_quiet_ok_get(void);

/** 统一 shux check 成功行；deno 风格批量 check 时由 fmt_check_cmd 保持静默。 */
void driver_print_check_ok(const char *input_path);

/** 非 0 时 pipeline 跳过 .sx typeck（C 预检已通过）。 */
void driver_sx_pipeline_skip_typeck_set(int32_t v);
int32_t driver_sx_pipeline_skip_typeck_get(void);

/** 非 0 时 pipeline 跳过 .sx C codegen（用户 asm -o 单路径 emit）。 */
void driver_sx_pipeline_skip_codegen_set(int32_t v);
int32_t driver_sx_pipeline_skip_codegen_get(void);

/** SHUX_TYPECK_FORCE_C=1 时入口模块 typeck 走 C typeck_module。 */
int32_t driver_typeck_force_c_enabled(void);

/** 当前线程是否已在 driver 大栈 pthread 内（避免 LSP 嵌套再分配大栈）。 */
int driver_is_large_stack_thread(void);

/**
 * 标记当前线程是否处于大栈执行上下文（runtime 内 pthread  trampoline 调用）。
 * 参数：on 非 0 进入大栈上下文，0 退出。
 */
void driver_large_stack_thread_mark(int on);

/** 提升 RLIMIT_STACK 软上限（run_compiler / pipeline 入口前调用）。 */
void driver_bump_stack_limit(void);

/**
 * 在 256MiB 栈 pthread 上执行 fn(arg)；LSP / pipeline / typeck 深栈场景使用。
 * SHUX_PIPELINE_NO_LARGE_STACK=1 时于当前线程直接执行。
 */
void driver_run_thread_on_large_stack(void *(*fn)(void *), void *arg);

/** 对外别名：与 driver_run_thread_on_large_stack 相同（LSP 主循环等）。 */
void driver_run_on_large_stack_pthread(void *(*fn)(void *), void *arg);

/** pipeline 入口源码长度（大模块 typeck 跳过判定）。 */
void driver_set_pipeline_entry_source_len(size_t len);
size_t driver_pipeline_entry_source_len(void);
int32_t driver_typeck_skip_large_entry(void);

/** SHUX_ASM_BUILD_SKIP_TYPECK / SHUX_ASM_ENTRY_EMIT_HEAVY / SHUX_ASM_ENTRY_MODULE_ONLY。 */
int32_t driver_asm_build_skip_typeck(void);
int32_t driver_asm_entry_emit_heavy(void);
int32_t driver_asm_entry_module_only_from_env(void);

/** A-11：SHUX_ASM_PARSE_METRIC_ONLY=1 时 entry parse 后输出 num_defined，跳过 pipeline/asm emit（防 typeck.sx OOM）。 */
int32_t driver_asm_parse_metric_only_from_env(void);

/** -o exe 时跳过 dep 0 codegen；当前 dep 路径供 codegen 前缀。 */
void driver_skip_codegen_dep_0_set(int32_t v);
int32_t driver_skip_codegen_dep_0_get(void);
void driver_set_current_dep_path_for_codegen(const char *path);
const char *driver_get_current_dep_path_for_codegen(void);

/** OBS-001：SHUX_COMPILE_PHASE_TIMING 阶段计时（pipeline.sx 调用）。 */
void driver_compile_phase_timing_begin(int32_t phase);
void driver_compile_phase_timing_end(int32_t phase);
void driver_compile_phase_timing_flush(void);

/**
 * 从 argv 收集 -D / -DFOO 与 -target 推导 OS_*、uname 的 SHUX_OS_/SHUX_ARCH_。
 * 参数：defines 至少 max_defines 个槽；返回注入宏数量。
 */
int driver_argv_collect_defines(int argc, char **argv, const char **defines, int max_defines);

/** pipeline 失败 rc 诊断；rc==-7 时打印 resolve 尝试路径。 */
void driver_pipeline_fail_code(int rc, const uint8_t *path);

/** .sx pipeline 烟测 stderr 摘要（parse OK / typeck OK 前缀供 gate grep）。 */
void driver_print_sx_smoke_summary(void *module, size_t codegen_len);

/**
 * B-20：读源文件前缀到 content（最多 cap-1 字节）；成功返回读入字节数，失败 -1。
 */
int driver_peek_source_file(const char *path, char *content, size_t cap);

/** 预处理后源码是否含顶层 import（seed asm 对这类入口 SX parse 易 0 func）。 */
int driver_source_has_top_level_import(const char *src, size_t src_len);

/** 读 path 并检测顶层 import（compile.sx extern）。 */
int driver_source_has_top_level_import_path(const char *path);

#endif /* SHUX_RUNTIME_DRIVER_ABI_H */
