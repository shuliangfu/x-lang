/**
 * runtime_link_abi.h — 编译器 C 侧链接/cc 辅助 ABI（Phase E-04 v5/v6+）
 *
 * 文件职责：声明 invoke_cc / asm_ld 链接 argv 构建辅助；自 runtime.c 逐步拆出。
 * 所属模块：compiler 运行时链接 ABI；实现于 runtime_link_abi.c。
 * 与其它文件的关系：依赖 runtime_proc_abi.h（asm_link_obj_skip_missing）；E-04 v17 invoke_cc 已迁入本模块。
 */

#ifndef SHUX_RUNTIME_LINK_ABI_H
#define SHUX_RUNTIME_LINK_ABI_H

#include <stddef.h>

#ifndef SHUX_ASM_LD_PATH_BANK_SLOTS
/** ASM ld argv 路径 bank 槽位数（须 ≥ append_std_objs 链入的 std+glue 总量）。 */
#define SHUX_ASM_LD_PATH_BANK_SLOTS 96
#endif
#ifndef SHUX_LINK_ABI_PATH_MAX
#define SHUX_LINK_ABI_PATH_MAX 4096
#endif
#ifndef SHUX_INVOKE_CC_MAX_C_FILES
#define SHUX_INVOKE_CC_MAX_C_FILES 64
#endif
#ifndef SHUX_LD_ARGV_CAP
/** ASM ld/gcc 子进程 argv 槽位上限（须 ≥ std 模块 + -l 参数）。 */
#define SHUX_LD_ARGV_CAP 96
#endif

/** ASM 链接子进程内向 argv[] 填入的冗长路径存这里（execvp 前须保持有效）。 */
typedef struct ShuAsmLdPathBank {
    char slots[SHUX_ASM_LD_PATH_BANK_SLOTS][SHUX_LINK_ABI_PATH_MAX];
    int n;
} ShuAsmLdPathBank;

/** asm_ld_append_std_objs：记录已链入 std 模块，供 macOS/Linux 追加 -pthread/-lm/-lz/-ldl。 */
typedef struct ShuAsmLdStdLinkFlags {
    int have_io;
    int have_net;
    int have_thread;
    int have_sync;
    int have_channel;
    int have_math;
    int have_compress;
    int have_dynlib;
    int have_sqlite;
    int have_elf;
    int have_libc_heap;
    int have_fs;
} ShuAsmLdStdLinkFlags;

/**
 * 解析 shux 可执行文件所在 compiler/ 目录（/proc/self/exe 或 argv0 realpath）。
 * 参数：argv0 可选；out_dir/out_dir_sz 输出缓冲。
 * 返回值：0 成功，-1 失败。
 */
int shu_resolve_compiler_dir(const char *argv0, char *out_dir, size_t out_dir_sz);

/**
 * link_argv0 为空时合成 «compiler-dir/shux» 供 std/*.o 路径解析。
 * 参数：link_argv0；syn_buf/syn_sz 合成缓冲。
 * 返回值：有效 argv0 或 NULL。
 */
const char *shux_asm_ld_effective_link_argv0(const char *link_argv0, char *syn_buf, size_t syn_sz);

/**
 * std/io/io.o 路径；与 shux 所在目录的 ../std/io/ 对齐。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_std_io_o_path(const char *argv0);

/**
 * std/compress/compress.o 路径；F-04 v7 + F-06 v1 已退役，恒返回空串。
 * 参数：argv0 可选 shux 路径。
 * 返回值：空串。
 */
const char *shux_std_compress_o_path(const char *argv0);

/**
 * 由 argv0 推导仓库根目录（io.o 路径向上三级），供 invoke_cc -I 使用。
 * 参数：argv0 可选 shux 路径。
 * 返回值：仓库根路径或空串。
 */
const char *shux_repo_root_from_argv0(const char *argv0);

/**
 * 将 path 复制到 ASM ld path bank 下一槽；成功返回持久指针，满则 NULL。
 * 参数：b bank；path 常为栈上 snprintf 结果。
 */
const char *shux_asm_ld_bank_push(ShuAsmLdPathBank *b, const char *path);

/**
 * 在每个 lib root 下尝试 rel（如 std/io/io.o）；命中则拷入 bank 并返回指针。
 * 参数：rel 相对路径；lib_roots/n_lib_roots -L 根；bank 路径持久化。
 */
const char *shux_asm_ld_try_under_lib_roots(const char *rel, const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank);

/**
 * runtime_panic.o 路径；优先 cwd（compiler/runtime_panic.o），再 argv0 目录。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_panic_o_path(const char *argv0);

/**
 * std.async 协作调度内核（std/async/scheduler.o）；task 按需链入时使用。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_std_async_scheduler_o_path(const char *argv0);

/**
 * crt0_user.o 路径；与 runtime_panic.o 同目录（compiler/），SHUX_FREESTANDING 链入。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_crt0_user_o_path(const char *argv0);

/**
 * freestanding_io.o 路径；compiler/ 下，SHUX_FREESTANDING syscall write 链入。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_freestanding_io_o_path(const char *argv0);

/**
 * runtime_asm_io_stubs.o 路径；seed asm 用户程序 std.io 桩，与 shux 同目录。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_asm_io_stubs_o_path(const char *argv0);

/**
 * runtime_process_argv.o 路径；codegen argc/argv 全局，与 process.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_process_argv_o_path(const char *argv0);

/**
 * runtime_process_os_glue.o 路径；getenv/spawn/getcwd 等 OS 胶层，与 process.o 同链。
 */
const char *shux_runtime_process_os_glue_o_path(const char *argv0);

/**
 * runtime_test_fn_invoke.o 路径；std.test fn-ptr，与 test.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_test_fn_invoke_o_path(const char *argv0);

/**
 * runtime_random_fill.o 路径；CSPRNG OS fill，与 random.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_random_fill_o_path(const char *argv0);

/**
 * runtime_heap_user.o 路径；co-emit std.heap redirect 的 heap_*_c 符号。
 */
const char *shux_runtime_heap_user_o_path(const char *argv0);

/**
 * runtime_time_os.o 路径；time OS syscall，与 time.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_time_os_o_path(const char *argv0);

/**
 * runtime_queue_contention.o 路径；queue 竞争烟测 pthread，与 queue.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_queue_contention_o_path(const char *argv0);

/**
 * runtime_dynlib_os.o 路径；dlopen/LoadLibrary，与 dynlib.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_dynlib_os_o_path(const char *argv0);

/**
 * runtime_env_os.o 路径；env OS getenv/setenv/iter，与 env.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_env_os_o_path(const char *argv0);

/**
 * runtime_backtrace_platform.o 路径；capture/symbolicate/crash evidence，与 backtrace.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_backtrace_platform_o_path(const char *argv0);

/**
 * runtime_log_os.o 路径；log sink/轮转/异步，与 log.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_log_os_o_path(const char *argv0);

/**
 * runtime_math_libm.o 路径；libm/fenv 转发，与 math.o 同链（须 -lm）。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_math_libm_o_path(const char *argv0);

/**
 * runtime_atomic_glue.o 路径；原子 load/store/CAS/fence，与 atomic.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_atomic_glue_o_path(const char *argv0);

/**
 * runtime_channel_glue.o 路径；channel 有界/无界/select，与 channel.o 同链（Unix 须 -lpthread）。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_channel_glue_o_path(const char *argv0);

/**
 * runtime_net_udp_batch.o 路径；Linux recvmmsg/sendmmsg，与 net.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_net_udp_batch_o_path(const char *argv0);

/**
 * runtime_net_workers.o 路径；accept worker 线程入口，与 net.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_net_workers_o_path(const char *argv0);

/**
 * runtime_sync_os.o 路径；Mutex/RwLock/Condvar，与 sync.o 同链（Unix 须 -lpthread）。
 */
const char *shux_runtime_sync_os_o_path(const char *argv0);

/**
 * runtime_sync_lock_diag_tls.o 路径；锁诊断 TLS 栈，与 sync.o 同链。
 */
const char *shux_runtime_sync_lock_diag_tls_o_path(const char *argv0);

const char *shux_runtime_thread_glue_o_path(const char *argv0);

/**
 * runtime_scheduler_glue.o 路径；协作调度 + async_net_fs，与 scheduler.o 同链（按需 -pthread）。
 */
const char *shux_runtime_scheduler_glue_o_path(const char *argv0);

/**
 * runtime_http_glue.o 路径；HTTP/HTTP2 胶层，与 http.o 同链。
 */
const char *shux_runtime_http_glue_o_path(const char *argv0);

/**
 * runtime_tls_mbedtls_bio.o 路径；mbedTLS BIO，net-o-mbedtls 时 ld -r 并入 tls_mbedtls.o。
 */
const char *shux_runtime_tls_mbedtls_bio_o_path(const char *argv0);

const char *shux_runtime_kv_mmap_glue_o_path(const char *argv0);

const char *shux_runtime_arrow_simd_glue_o_path(const char *argv0);

const char *shux_runtime_sqlite_glue_o_path(const char *argv0);

const char *shux_runtime_crypto_inc_glue_o_path(const char *argv0);

const char *shux_runtime_ed25519_ref10_glue_o_path(const char *argv0);

/**
 * 若 runtime_panic.o 尚不存在则用 cc -c 从 src/asm 源码生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_panic_o(const char *argv0);

/**
 * SHUX_FREESTANDING=1 或 driver -freestanding：Linux 上 nostdlib 静态链是否启用。
 * 参数：driver_freestanding 非 0 表示 driver 已设 -freestanding。
 * 返回值：非 0 表示 freestanding 链启用。
 */
int shux_link_freestanding_enabled(int driver_freestanding);

/**
 * 若 runtime_asm_io_stubs.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_asm_io_stubs_o(const char *argv0);

/**
 * 若 runtime_process_argv.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_process_argv_o(const char *argv0);

int shux_ensure_runtime_process_os_glue_o(const char *argv0);

/**
 * 若 runtime_test_fn_invoke.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_test_fn_invoke_o(const char *argv0);

/**
 * 若 runtime_random_fill.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_random_fill_o(const char *argv0);

/**
 * 若 runtime_heap_user.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 */
int shux_ensure_runtime_heap_user_o(const char *argv0);

/**
 * 若 runtime_time_os.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_time_os_o(const char *argv0);

/**
 * 若 runtime_queue_contention.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_queue_contention_o(const char *argv0);

/**
 * 若 runtime_dynlib_os.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_dynlib_os_o(const char *argv0);

/**
 * 若 runtime_env_os.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_env_os_o(const char *argv0);

/**
 * 若 runtime_backtrace_platform.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_backtrace_platform_o(const char *argv0);

/**
 * 若 runtime_log_os.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_log_os_o(const char *argv0);

/**
 * 若 runtime_math_libm.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_runtime_math_libm_o(const char *argv0);

/**
 * 若 runtime_atomic_glue.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_atomic_glue_o(const char *argv0);

/**
 * 若 runtime_channel_glue.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_channel_glue_o(const char *argv0);

/**
 * 若 runtime_net_udp_batch.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_net_udp_batch_o(const char *argv0);

/**
 * 若 runtime_net_workers.o 尚不存在则用 cc -c 生成到 compiler/ 目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_net_workers_o(const char *argv0);

int shux_ensure_runtime_sync_os_o(const char *argv0);

int shux_ensure_runtime_sync_lock_diag_tls_o(const char *argv0);

int shux_ensure_runtime_thread_glue_o(const char *argv0);

int shux_ensure_runtime_scheduler_glue_o(const char *argv0);

int shux_ensure_runtime_http_glue_o(const char *argv0);

int shux_ensure_runtime_tls_mbedtls_bio_o(const char *argv0);

int shux_ensure_runtime_kv_mmap_glue_o(const char *argv0);

int shux_ensure_runtime_arrow_simd_glue_o(const char *argv0);

int shux_ensure_runtime_sqlite_glue_o(const char *argv0);

int shux_ensure_runtime_crypto_inc_glue_o(const char *argv0);

int shux_ensure_runtime_ed25519_ref10_glue_o(const char *argv0);

/**
 * 若 crt0_user.o 尚不存在则从 crt0_user_x86_64.s 编译；未启用 freestanding 时 no-op。
 * 参数：argv0；driver_freestanding 同 shux_link_freestanding_enabled。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_crt0_user_o(const char *argv0, int driver_freestanding);

/**
 * 若 freestanding_io.o 尚不存在则从 freestanding_io_x86_64.s 编译；未启用 freestanding 时 no-op。
 * 参数：argv0；driver_freestanding 同 shux_link_freestanding_enabled。
 * 返回值：0 成功，-1 失败。
 */
int shux_ensure_freestanding_io_o(const char *argv0, int driver_freestanding);

/**
 * 相对仓库根的 .o 路径解析（realpath/cwd/argv0/../rel）。
 * invoke_cc / invoke_ld 统一用此替代 runtime.c 内原 get_std_*_o_path 重复实现（E-04 v16）。
 * 参数：argv0 可选；rel 如 std/fs/fs.o。
 */
const char *shux_rel_o_path_from_argv0(const char *argv0, const char *rel);

/**
 * 扫描 .o 未定义符号 sym；nm 失败时保守返回 1。
 */
int shux_link_obj_needs_undef_sym(const char *o_path, const char *sym);

/** 用户 .o 是否引用 shux_sys_*（按需链 freestanding_io.o）。 */
int shux_freestanding_user_o_needs_io(const char *user_o);

/** 用户 .o 是否引用 shux_panic_（按需链 runtime_panic.o）。 */
int shux_freestanding_user_o_needs_panic(const char *user_o);

/**
 * ASM 链接：按 invoke_cc 顺序追加 std/*.o 到 ld argv。
 */
void shux_asm_ld_append_std_objs(const char *link_argv0, const char **lib_roots, int n_lib_roots,
    ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags);

/**
 * ASM 链接：按用户 .o 未定义符号按需追加伴生 .o。
 */
void shux_asm_ld_append_on_demand_user_objs(const char *link_argv0, const char *user_o,
    const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank,
    const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags);

/**
 * invoke_ld / driver_asm_invoke_ld：ensure panic/io_stubs/crt0/freestanding_io 并校验 freestanding 目标格式。
 * 参数：link_eff 有效 link argv0；user_o 用户 .o；driver_freestanding 同 shux_link_freestanding_enabled。
 * 返回值：0 成功，-1 失败。
 */
int shux_asm_ld_prepare_for_exe_link(const char *link_eff, const char *user_o, int driver_freestanding,
    int use_macho_o, int use_coff_o);

#if defined(__linux__) || defined(__APPLE__)
/**
 * 用户 .o 是否无任何未定义符号（nm -u 为空）；用于 Linux 最小 gcc 链 user.o+-lc。
 * 参数：o_path 用户对象路径。
 * 返回值：1 有未定义符号或 nm 失败（保守），0 完全自包含。
 */
int shux_asm_user_o_has_undef_syms(const char *o_path);
#endif

/**
 * macOS asm ld/clang：按 std 链入标记追加 -lm、压缩库、-lsqlite3、-pthread、-lSystem。
 * 参数：compress_o std/compress/compress.o 路径；append_lsystem 非 0 时在 ld 路径追加 -lSystem。
 */
void shux_asm_ld_append_mach_tail_libs(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    const char **argv, int *la, int max_la, int append_lsystem);

/**
 * Linux/Unix gcc 或裸 ld 路径：按 std 链入标记追加 -luring、-pthread、-lm、压缩库、-ldl、-lc。
 * 参数：compress_o std/compress/compress.o 路径；user_o 用户主 .o；need_pt 已由 thread/sync/channel 推导。
 */
void shux_asm_ld_append_unix_gcc_tail_libs(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    int need_pt, const char **argv, int *la, int max_la);

/**
 * ASM -o exe：fork 子进程执行 clang/ld 或 lld-link/ld；调用方须先 shux_asm_ld_prepare_for_exe_link。
 * 参数：driver_freestanding 同 shux_link_freestanding_enabled；link_argv0 用于 std/.o 路径解析。
 * 返回值：0 成功，-1 失败。
 */
int shux_asm_invoke_ld_platform(const char *o_path, const char *exe_path, const char *target,
    int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots,
    int driver_freestanding);

/**
 * 判断 -o 路径是否写出对象文件（.o / .obj 则写 ELF/Mach-O/COFF 而非 .s）。
 * 参数：path 为 -o 参数；NULL 则返回 0。
 * 返回值：非 0 表示对象文件后缀。
 */
int shux_output_is_elf_o(const char *path);

/**
 * 判断 -o 路径是否表示可执行文件名（非 .o/.obj/.s 后缀）。
 * 参数：path 为 -o 参数；空串或 NULL 则返回 0。
 * 返回值：非 0 表示 -backend asm 应自动调 ld 出 exe。
 */
int shux_output_want_exe(const char *path);

/**
 * ASM -o exe 薄包装：prepare + shux_asm_invoke_ld_platform；freestanding 取自 driver_freestanding_get。
 * 参数：o_path 临时或最终 .o；exe_path 目标可执行；link_argv0 可为 NULL（镜像路径推导）。
 * 返回值：0 成功，-1 失败。
 */
int shux_invoke_ld_for_exe(const char *o_path, const char *exe_path, const char *target,
    int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots);

/**
 * CI/Docker/musl 上是否跳过 -march=native/-flto 等 native 调优。
 * 参数：无。
 * 返回值：非 0 表示跳过 native 调优。
 */
int invoke_cc_skip_native_tuning(void);

/**
 * 扫描生成 C 是否引用 std.async scheduler 符号（invoke_cc 按需链 scheduler.o）。
 */
int shux_generated_c_needs_async_scheduler(const char *c_path);

/**
 * 调用系统 cc 将多个 C 文件编译链接为可执行文件（fork/exec + strip）。
 * 参数：c_paths/n 源文件；各 *_o 可选 std/core .o；include_root 用于 -I 与按需 .o 解析。
 * 返回值：0 成功，-1 失败。
 */
int shux_invoke_cc(const char **c_paths, int n, const char *out_path, const char *target, const char *opt_level, int use_lto, const char *io_o, const char *fs_o, const char *process_o, const char *string_o, const char *heap_o, const char *path_o, const char *runtime_o, const char *runtime_panic_o, const char *net_o, const char *thread_o, const char *time_o, const char *random_o, const char *env_o, const char *sync_o, const char *encoding_o, const char *base64_o, const char *crypto_o, const char *log_o, const char *atomic_o, const char *channel_o, const char *backtrace_o, const char *hash_o, const char *math_o, const char *sort_o, const char *ffi_o, const char *db_o, const char *elf_o, const char *json_o, const char *csv_o, const char *regex_o, const char *compress_o, const char *unicode_o, const char *dynlib_o, const char *http_o, const char *tar_o, const char *simd_o, const char *context_o, const char *datetime_o, const char *uuid_o, const char *url_o, const char *cli_o, const char *security_o, const char *config_o, const char *cache_o, const char *trace_o, const char *task_o, const char *schema_o, const char *test_o, const char *include_root, const char *async_scheduler_o);

/**
 * invoke_cc 子进程：仅当 path 指向已存在的 .o 时追加到 argv（可选 realpath）。
 * 参数：argv/ia/max_ia 为 cc 链接 argv 构建状态；path 候选 .o。
 * 返回值：1 已追加，0 跳过。
 */
int invoke_cc_argv_push_existing(char *argv[], int *ia, int max_ia, const char *path);

/**
 * task.o 链入时推导 scheduler.o 路径；explicit_scheduler 非空时优先使用。
 * 参数：task_o task 模块 .o 路径；explicit_scheduler 显式 scheduler .o 或 NULL。
 * 返回值：可链入的 scheduler .o 路径，失败 NULL。
 */
const char *scheduler_o_for_task_link(const char *task_o, const char *explicit_scheduler);

/**
 * ASM 链接：按 compress.o / 用户 .o 依赖追加 -lz / -lzstd / -lbrotli*。
 * 参数：compress_o；user_o 用户主 .o（F-04 v4）；argv/la/max_la 为 ld argv 状态。
 */
void asm_ld_append_compress_libs(const char *compress_o, const char *user_o, const char **argv, int *la, int max_la);

/**
 * invoke_cc 链接：按 compress.o / 用户 .o 依赖追加压缩库 -l 参数。
 * 参数：argv/i/argv_cap；compress_o 候选 .o；user_o 用户 .o（可 NULL）。
 */
void invoke_cc_append_compress_ld(char *argv[], int *i, int argv_cap, const char *compress_o, const char *user_o);

/**
 * SHUX_NET_TLS 非 stub 时尝试 make net-o-openssl / net-o-mbedtls。
 * 参数：repo_root 仓库根绝对路径。
 */
void ensure_std_net_o_auto_tls(const char *repo_root);

/**
 * net.o 为 OpenSSL/mbedTLS 后端时追加 -L/-l；返回 1 表示已追加。
 * 参数：argv/i/argv_cap；net_o std/net .o。
 */
int invoke_cc_append_net_tls_ld(char *argv[], int *i, int argv_cap, const char *net_o, const char *repo_root);

#if defined(__linux__)
/**
 * Linux release 链接硬化：PIE + NX（GNU_STACK 无 E）+ partial RELRO。
 * 参数：argv/la/cap 为 gcc/ld 链接 argv 构建状态。
 */
void shux_append_linux_link_harden(char *argv[], int *la, int cap);
#endif

#endif /* SHUX_RUNTIME_LINK_ABI_H */
