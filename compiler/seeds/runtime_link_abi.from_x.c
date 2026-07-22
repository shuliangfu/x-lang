/* Generated from src/runtime_link_abi.x (G-02f-34..56/64..70/89/91/92/94 true .x + C tail).
 * G-02f-115 true .x pure helpers.
 * G-02f-112 helper gates.
 * Regen: ./shux-c -E -L .. src/runtime_link_abi.x > /tmp/labi.c
 *         merge invoke_cc + linux_harden + remaining link gates.
 * .x covers: + shux_invoke_cc, append_linux_link_harden; link_abi exported set nearly gated.
 * G-02f-89/91/92/94: path/diag/needs + cc_ex/nm/nostdlib helpers gated over _impl.
 */
#include <shux_weak.h>
#include "win32_compat.h"
#include "runtime_link_abi.h"
#include "runtime_proc_abi.h"
#include "runtime_io_abi.h"
#include "runtime_driver_abi.h"
#include "runtime_abi.h"
#include "diag.h"
#include "runtime_diag_codes.h"

/* G-02f-53/65/66: empty C string + path/ld helpers */
const char *shux_asm_ld_bank_push_impl(ShuAsmLdPathBank *b, const char *path);
const char *shux_runtime_asm_io_stubs_o_path(const char *argv0);
const char *shux_runtime_process_argv_o_path(const char *argv0);
const char *shux_asm_ld_effective_link_argv0(const char *link_argv0, char *syn_buf, size_t syn_sz);
int shux_path_is_nonempty_regular_file_impl(const char *path);
int link_abi_ld_argv_entry_is_obj(const char *s);
int shux_invoke_ld_for_exe_impl(const char *o_path, const char *exe_path, const char *target,
    int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots);
void shux_asm_ld_append_mach_tail_libs_impl(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    const char **argv, int *la, int max_la, int append_lsystem);
void shux_asm_ld_append_unix_gcc_tail_libs_impl(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    int need_pt, const char **argv, int *la, int max_la);
/* G-02f-70 invoke_cc + harden */
int shux_invoke_cc_impl(const char **c_paths, int n, const char *out_path, const char *target, const char *opt_level, int use_lto, const char *io_o, const char *fs_o, const char *process_o, const char *string_o, const char *heap_o, const char *path_o, const char *runtime_o, const char *runtime_panic_o, const char *net_o, const char *thread_o, const char *time_o, const char *random_o, const char *env_o, const char *sync_o, const char *encoding_o, const char *base64_o, const char *crypto_o, const char *log_o, const char *atomic_o, const char *channel_o, const char *backtrace_o, const char *hash_o, const char *math_o, const char *sort_o, const char *ffi_o, const char *db_o, const char *elf_o, const char *json_o, const char *csv_o, const char *regex_o, const char *compress_o, const char *unicode_o, const char *dynlib_o, const char *http_o, const char *tar_o, const char *simd_o, const char *context_o, const char *datetime_o, const char *uuid_o, const char *url_o, const char *cli_o, const char *security_o, const char *config_o, const char *cache_o, const char *trace_o, const char *task_o, const char *schema_o, const char *test_o, const char *include_root, const char *async_scheduler_o);
void shux_append_linux_link_harden_impl(char *argv[], int *la, int cap);
/* G-02f-69 mega link helpers */
int shu_resolve_compiler_dir(const char *argv0, char *out_dir, size_t out_dir_sz);
int shux_asm_invoke_ld_platform(const char *o_path, const char *exe_path, const char *target, int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots, int driver_freestanding);
void shux_asm_ld_append_std_objs(const char *link_argv0, const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags);
void shux_asm_ld_append_std_objs_for_user(const char *link_argv0, const char *user_o, const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags);
void shux_asm_ld_append_on_demand_user_objs(const char *link_argv0, const char *user_o, const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags);
int invoke_cc_append_net_tls_ld(char *argv[], int *i, int argv_cap, const char *net_o, const char *repo_root);
void ensure_std_net_o_auto_tls(const char *repo_root);
/* PLATFORM: SHARED — formal std .o after L4 wipe (def near ensure_std_net_o_auto_tls). */
static int shux_ensure_formal_std_make_o(const char *repo_root, const char *rel_from_repo, const char *make_target);
/* G-02f-68 link helpers */
int shu_waitpid_retry(pid_t pid, int *status_out);
int shux_asm_user_o_has_undef_syms(const char *o_path);
void asm_ld_append_compress_libs(const char *compress_o, const char *user_o, const char **argv, int *la, int max_la);
void invoke_cc_append_compress_ld(char *argv[], int *i, int argv_cap, const char *compress_o, const char *user_o);
int invoke_cc_argv_push_existing(char *argv[], int *ia, int max_ia, const char *path);
int shux_asm_ld_prepare_for_exe_link(const char *link_eff, const char *user_o, int driver_freestanding, int use_macho_o, int use_coff_o);
/* G-02f-67 ensure impls */
int shux_ensure_freestanding_io_o(const char *argv0, int driver_freestanding);
int shux_ensure_crt0_user_o(const char *argv0, int driver_freestanding);
int shux_ensure_runtime_arrow_simd_glue_o(const char *argv0);
int shux_ensure_runtime_asm_io_stubs_o(const char *argv0);
const char *labi_od_rel_page_mmap(void);
int shux_ensure_runtime_atomic_glue_o(const char *argv0);
int shux_ensure_runtime_backtrace_platform_o(const char *argv0);
int shux_ensure_runtime_channel_glue_o(const char *argv0);
int shux_ensure_runtime_compress_zlib_glue_o(const char *argv0);
int shux_ensure_runtime_crypto_inc_glue_o(const char *argv0);
int shux_ensure_runtime_dynlib_os_o(const char *argv0);
int shux_ensure_runtime_ed25519_ref10_glue_o(const char *argv0);
int shux_ensure_runtime_env_os_o(const char *argv0);
int shux_ensure_runtime_heap_user_o(const char *argv0);
int shux_link_obj_has_defined_sym(const char *o_path, const char *sym);
int shux_ensure_runtime_http_glue_o(const char *argv0);
int shux_ensure_runtime_kv_mmap_glue_o(const char *argv0);
int shux_ensure_runtime_log_os_o(const char *argv0);
int shux_ensure_runtime_math_libm_o(const char *argv0);
int shux_ensure_runtime_net_udp_batch_o(const char *argv0);
int shux_ensure_runtime_net_workers_o(const char *argv0);
int shux_ensure_runtime_panic_o(const char *argv0);
int shux_ensure_runtime_process_argv_o(const char *argv0);
int shux_ensure_runtime_process_os_glue_o(const char *argv0);
int shux_ensure_runtime_queue_contention_o(const char *argv0);
int shux_ensure_runtime_random_fill_o(const char *argv0);
int shux_ensure_runtime_scheduler_glue_o(const char *argv0);
int shux_ensure_runtime_sqlite_glue_o(const char *argv0);
int shux_ensure_runtime_sync_lock_diag_tls_o(const char *argv0);
int shux_ensure_runtime_sync_os_o(const char *argv0);
int shux_ensure_runtime_test_fn_invoke_o(const char *argv0);
int shux_ensure_runtime_thread_glue_o(const char *argv0);
int shux_ensure_runtime_time_os_o(const char *argv0);
int shux_ensure_runtime_tls_mbedtls_bio_o(const char *argv0);
const char *shux_empty_cstr(void) {
    static char buf[1];
    buf[0] = '\0';
    return buf;
}


#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            macOS/Linux delegate to system <unistd.h> via #include_next.
 *            Historical #ifndef _WIN32 guard removed — shim is a no-op
 *            on POSIX and provides needed declarations on Windows. */
#include <unistd.h>
#ifndef _WIN32
#include <sys/wait.h>
#endif
#include <sys/stat.h>
#if defined(__linux__)
#include <elf.h>
#include <fcntl.h>
#include <sys/mman.h>
#endif

#if defined(__APPLE__)
#include <mach-o/dyld.h>
#endif
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

/** invoke_cc 子进程 realpath 缓冲池：不可共用单块 static，否则多次 push 后 argv 中旧槽指向最后被覆盖的路径。 */
#define INVOKE_CC_ABS_POOL_SZ 80

/**
 * 在字符串 s 中查找最后一个路径分隔符（POSIX '/' 或 Windows '\\')。
 * Windows 上 argv0 / realpath 结果可能含反斜杠，需双分隔符查找；
 * POSIX 上 strchr(s, '\\') 通常为 NULL（文件名极少含反斜杠），行为不变。
 * 返回值：指向最后分隔符的指针，找不到返回 NULL。
 */
/* G-02f-118：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-267 L0 path pure */
#ifndef SHUX_LABI_PATH_PURE_FROM_X
char * shux_path_last_sep(const char *s) {
    char *p = s ? strrchr(s, '/') : NULL;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    if (s) {
        char *bs = strrchr(s, '\\');
        if (bs && (!p || bs > p))
            p = bs;
    }
#endif
    return p;
}
#else
char *shux_path_last_sep(const char *s);
#endif





/** 字符串是否包含任意路径分隔符（POSIX '/' 或 Windows '\\')。 */
/* G-02f-118：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-267 L0 path pure */
#ifndef SHUX_LABI_PATH_PURE_FROM_X
int shux_path_has_sep(const char *s) {
    if (!s)
        return 0;
    if (strchr(s, '/'))
        return 1;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    if (strchr(s, '\\'))
        return 1;
#endif
    return 0;
}
#else
int shux_path_has_sep(const char *s);
#endif





/**
 * 同步执行 cc 编译 .c/.s → .o；POSIX 上 fork+execvp+waitpid，Windows 上 _spawnvp(_P_WAIT,...)。
 * 参数：src 源文件；out_o 输出 .o 路径；inc0/inc1/inc2 三个 -I 包含路径；
 *       from_asm_s != 0 表示源是 .s 汇编，仅传 -c -o out src，不传 -Wall/-Wextra/-I。
 *       extra_flags 可选额外标志数组（NULL 或 NULL-terminated），插在 -I 之后、-c 之前。
 * 返回值：0 成功，非 0 失败（exit code 或 -1）。
 * 设计目的：消除 30+ 处 ensure_runtime_*_o 函数中重复的 fork+execlp+waitpid 三段式，
 *           并让 Windows 宿主走 _spawnvp 同步路径（无 fork）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_cc_compile_sync_ex(const char *src, const char *out_o,
                                    const char *inc0, const char *inc1, const char *inc2,
                                    int from_asm_s,
                                    const char *const *extra_flags) {
    const char *argv[32];
    int ai = 0;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    argv[ai++] = "gcc";
#else
    argv[ai++] = "cc";
#endif
    if (!from_asm_s) {
        argv[ai++] = "-Wall";
        argv[ai++] = "-Wextra";
        argv[ai++] = "-I";
        argv[ai++] = inc0;
        argv[ai++] = "-I";
        argv[ai++] = inc1;
        argv[ai++] = "-I";
        argv[ai++] = inc2;
    }
    if (extra_flags) {
        int i;
        for (i = 0; extra_flags[i] != NULL && ai < 28; i++)
            argv[ai++] = extra_flags[i];
    }
    argv[ai++] = "-c";
    argv[ai++] = "-o";
    argv[ai++] = out_o;
    argv[ai++] = src;
    argv[ai] = NULL;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    {
        intptr_t rc = _spawnvp(_P_WAIT, "gcc", (const char *const *)argv);
        if (rc == -1)
            return -1;
        return (int)rc;
    }
#else
    {
        pid_t pid = fork();
        if (pid < 0)
            return -1;
        if (pid == 0) {
            execvp("cc", (char *const *)argv);
            _exit(127);
        }
        {
            int st;
            if (shu_waitpid_retry(pid, &st) != 0)
                return -1;
            if (!WIFEXITED(st) || WEXITSTATUS(st) != 0)
                return -1;
        }
    }
    return 0;
#endif
}




/**
 * shux_cc_compile_sync 的简化包装：无额外标志。
 * G-02e-17：若 src 以 .inc 结尾，写临时 wrap.c（#include 绝对路径）再 cc，结束后删除 wrap。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_cc_compile_sync(const char *src, const char *out_o,
                                const char *inc0, const char *inc1, const char *inc2,
                                int from_asm_s) {
    size_t n;
    char wrap_c[PATH_MAX];
    FILE *wf;
    int rc;
    if (!src)
        return -1;
    n = strlen(src);
    if (n > 4 && strcmp(src + (n - 4), ".inc") == 0) {
        if ((size_t)snprintf(wrap_c, sizeof wrap_c, "%s.wrap.c", out_o) >= sizeof wrap_c)
            return -1;
        wf = fopen(wrap_c, "w");
        if (!wf)
            return -1;
        fprintf(wf, "/* generated by shux_cc_compile_sync (.inc wrap, G-02e) */\n#include \"%s\"\n", src);
        fclose(wf);
        rc = shux_cc_compile_sync_ex(wrap_c, out_o, inc0, inc1, inc2, from_asm_s, NULL);
        (void)remove(wrap_c);
        return rc;
    }
    return shux_cc_compile_sync_ex(src, out_o, inc0, inc1, inc2, from_asm_s, NULL);
}




/**
 * 同步执行子进程：POSIX 上 fork+execvp+waitpid，Windows 上 _spawnvp(_P_WAIT,...)。
 * 参数：prog 程序名（PATH 查找）；argv 参数数组，须以 NULL 结尾。
 * 返回值：0 成功（exit 0），非 0 失败（exit code 或 -1）。
 * 设计目的：shux_asm_invoke_ld_platform 中 6 处 fork+execvp+waitpid 统一封装。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_spawn_sync(const char *prog, const char *const *argv) {
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    {
        intptr_t rc = _spawnvp(_P_WAIT, prog, (const char *const *)argv);
        if (rc == -1)
            return -1;
        return (int)rc;
    }
#else
    {
        pid_t pid = fork();
        if (pid < 0)
            return -1;
        if (pid == 0) {
            execvp(prog, (char *const *)argv);
            _exit(127);
        }
        {
            int st;
            if (shu_waitpid_retry(pid, &st) != 0)
                return -1;
            if (!WIFEXITED(st) || WEXITSTATUS(st) != 0)
                return -1;
        }
    }
    return 0;
#endif
}


/* G-02f-124：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-268 L1 diag pure：code_for_kind 真迁在 L1 leaf；rest 非 hybrid 自带 */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
const char * link_diag_code_for_kind(const char *kind) {
    if (!kind)
        return SHUX_DIAG_CODE_PROCESS_PRC001;
    if (strcmp(kind, "build error") == 0)
        return SHUX_DIAG_CODE_BUILD_BLD001;
    if (strcmp(kind, "process error") == 0)
        return SHUX_DIAG_CODE_PROCESS_PRC001;
    return NULL;
}
#else
const char * link_diag_code_for_kind(const char *kind);
#endif

/* Cap residual (always): POSIX wait status decode for pure tool/obj status orch.
 * PLATFORM: POSIX (macOS + Linux). Windows hybrid uses win32_compat wait macros. */
int link_diag_wait_is_signaled(int status) {
    return WIFSIGNALED(status) ? 1 : 0;
}
int link_diag_wait_code(int status) {
    if (WIFSIGNALED(status))
        return (int)WTERMSIG(status);
    if (WIFEXITED(status))
        return (int)WEXITSTATUS(status);
    return -1;
}

/* G-02f-165 / wave112：tool_status pure orch in labi_diag_pure.x (hybrid L1);
 * mega cold twin under #ifndef SHUX_LABI_DIAG_PURE_FROM_X. Cap residual wait decode
 * stays always-linked. PLATFORM: SHARED. */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_tool_status(const char *tool, int status) {
    if (!tool)
        tool = "tool";
    if (WIFSIGNALED(status)) {
        diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                               "%s failed (signal %d)", tool, WTERMSIG(status));
    } else {
        diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                               "%s failed (exit %d)", tool, WIFEXITED(status) ? WEXITSTATUS(status) : -1);
    }
}
#else
void link_diag_tool_status(const char *tool, int status);
#endif


/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* R2 labi_diag_pure：hybrid FROM_X 下公共+消息体由 L1 .x 提供；冷启动仍保留 _impl */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_runtime_obj_resolve_fail_impl(const char *obj_name, const char *hint) {
    if (!obj_name)
        obj_name = "runtime object";
    if (hint && hint[0] != '\0') {
        diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                               "cannot resolve compiler directory to build %s (%s)",
                               obj_name, hint);
    } else {
        diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                               "cannot resolve compiler directory to build %s",
                               obj_name);
    }
}
void link_diag_runtime_obj_resolve_fail(const char *obj_name, const char *hint) {
    link_diag_runtime_obj_resolve_fail_impl(obj_name, hint);
}
#else
void link_diag_runtime_obj_resolve_fail(const char *obj_name, const char *hint);
#endif

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_runtime_source_missing_impl(const char *obj_name, const char *source_path) {
    if (!obj_name)
        obj_name = "runtime object";
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "%s source not found at %s",
                           obj_name, source_path ? source_path : "?");
}
void link_diag_runtime_source_missing(const char *obj_name, const char *source_path) {
    link_diag_runtime_source_missing_impl(obj_name, source_path);
}
#else
void link_diag_runtime_source_missing(const char *obj_name, const char *source_path);
#endif



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_runtime_source_missing_under_impl(const char *obj_name, const char *base_dir,
                                                   const char *suffix) {
    if (!obj_name)
        obj_name = "runtime object";
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "%s source not found under %s%s",
                           obj_name, base_dir ? base_dir : "?", suffix ? suffix : "");
}
void link_diag_runtime_source_missing_under(const char *obj_name, const char *base_dir,
                                                   const char *suffix) {
    link_diag_runtime_source_missing_under_impl(obj_name, base_dir, suffix);
}
#else
void link_diag_runtime_source_missing_under(const char *obj_name, const char *base_dir, const char *suffix);
#endif

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_runtime_obj_missing_impl(const char *obj_name, const char *out_o) {
    if (!obj_name)
        obj_name = "runtime object";
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "%s missing after cc -c (expected near %s)",
                           obj_name, out_o ? out_o : "?");
}
void link_diag_runtime_obj_missing(const char *obj_name, const char *out_o) {
    link_diag_runtime_obj_missing_impl(obj_name, out_o);
}
#else
void link_diag_runtime_obj_missing(const char *obj_name, const char *out_o);
#endif



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


/* wave112：obj_build_status pure orch in labi_diag_pure.x (hybrid L1);
 * mega cold twin under #ifndef. Cap residual wait decode always-linked. PLATFORM: SHARED. */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_runtime_obj_build_status(const char *obj_name, int status) {
    if (!obj_name)
        obj_name = "runtime object";
    if (WIFSIGNALED(status)) {
        diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                               "failed to build %s (signal %d)",
                               obj_name, WTERMSIG(status));
    } else {
        diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                               "failed to build %s (exit %d)",
                               obj_name, WIFEXITED(status) ? WEXITSTATUS(status) : -1);
    }
}
#else
void link_diag_runtime_obj_build_status(const char *obj_name, int status);
#endif
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/* Cap residual always: errno capture + strerror. Message orch is pure L1 (wave113).
 * PLATFORM: SHARED — libc errno/strerror. */
const char *link_diag_strerror_current(void) {
    int saved_errno = errno;
    const char *err = strerror(saved_errno);
    return err ? err : "unknown error";
}

/* G-02f-165 / wave113：link_diag_errno / _path pure orch in labi_diag_pure.x (hybrid L1);
 * mega cold twin under #ifndef SHUX_LABI_DIAG_PURE_FROM_X. Cap residual strerror stays
 * always-linked. PLATFORM: SHARED. */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_errno(const char *kind, const char *op) {
    const char *err = link_diag_strerror_current();
    const char *resolved_kind = kind ? kind : "process error";
    const char *resolved_op = (op && op[0]) ? op : "system call";
    const char *code = link_diag_code_for_kind(resolved_kind);
    if (code) {
        diag_reportf_with_code(NULL, 0, 0, resolved_kind, code, NULL,
                               "%s failed: %s",
                               resolved_op,
                               err ? err : "unknown error");
    } else {
        diag_reportf(NULL, 0, 0, resolved_kind, NULL,
                     "%s failed: %s",
                     resolved_op,
                     err ? err : "unknown error");
    }
}

void link_diag_errno_path(const char *kind, const char *op, const char *path) {
    const char *err;
    const char *resolved_kind;
    const char *resolved_op;
    const char *code;
    if (!path || path[0] == '\0') {
        link_diag_errno(kind, op);
        return;
    }
    err = link_diag_strerror_current();
    resolved_kind = kind ? kind : "process error";
    resolved_op = (op && op[0]) ? op : "system call";
    code = link_diag_code_for_kind(resolved_kind);
    if (code) {
        diag_reportf_with_code(NULL, 0, 0, resolved_kind, code, NULL,
                               "%s failed for '%s': %s",
                               resolved_op,
                               path,
                               err ? err : "unknown error");
    } else {
        diag_reportf(NULL, 0, 0, resolved_kind, NULL,
                     "%s failed for '%s': %s",
                     resolved_op,
                     path,
                     err ? err : "unknown error");
    }
}
#else
void link_diag_errno(const char *kind, const char *op);
void link_diag_errno_path(const char *kind, const char *op, const char *path);
#endif







#if defined(__GNUC__) || defined(__clang__)
__attribute__((unused))
#endif
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* R2：freestanding_missing 消息体 hybrid 由 L1 .x；冷启动 _impl */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_freestanding_missing_impl(const char *obj_name, const char *symbol_name) {
    if (symbol_name && symbol_name[0]) {
        diag_reportf_with_code(NULL, 0, 0, "link error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                     "freestanding link missing %s (user references %s)",
                     obj_name ? obj_name : "runtime object",
                     symbol_name);
        return;
    }
    diag_reportf_with_code(NULL, 0, 0, "link error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                 "freestanding link missing %s",
                 obj_name ? obj_name : "runtime object");
}
void link_diag_freestanding_missing(const char *obj_name, const char *symbol_name) {
    link_diag_freestanding_missing_impl(obj_name, symbol_name);
}
#else
void link_diag_freestanding_missing(const char *obj_name, const char *symbol_name);
#endif



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* R2：freestanding_unsupported 消息体 hybrid 由 L1 .x（拆段 ≤64） */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_freestanding_unsupported_impl(void) {
    diag_report_with_code(NULL, 0, 0, "link error", SHUX_DIAG_CODE_BUILD_BLD001,
                "-freestanding / SHUX_FREESTANDING is only supported for Linux ELF x86_64 (-o prog, not .o/.obj on macOS/COFF)",
                NULL);
}
void link_diag_freestanding_unsupported(void) {
    link_diag_freestanding_unsupported_impl();
}
#else
void link_diag_freestanding_unsupported(void);
#endif

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* R2：ld_debug_push 消息体 hybrid 由 L1 .x */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_ld_debug_push_impl(const char *rel, const char *stage, const char *path) {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "ld debug: push %s %s=%s",
                 rel ? rel : "(null)",
                 stage ? stage : "path",
                 path ? path : "(null)");
}
void link_diag_ld_debug_push(const char *rel, const char *stage, const char *path) {
    link_diag_ld_debug_push_impl(rel, stage, path);
}
#else
void link_diag_ld_debug_push(const char *rel, const char *stage, const char *path);
#endif



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* Cap residual：ld_debug_argv char** 遍历 🔒 常驻 _impl（L1 .x thin 转发） */
void link_diag_ld_debug_argv_impl(const char *label, const char *const *argv) {
    int di;
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "ld debug: %s",
                 label ? label : "argv");
    if (!argv)
        return;
    for (di = 0; argv[di] != NULL; di++) {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "ld debug argv[%d]=%s",
                     di,
                     argv[di]);
    }
}
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void link_diag_ld_debug_argv(const char *label, const char *const *argv) {
    link_diag_ld_debug_argv_impl(label, argv);
}
#else
void link_diag_ld_debug_argv(const char *label, const char *const *argv);
#endif

/* G-02f-165 / wave111：shux_link_perror pure orch in labi_diag_pure.x (hybrid L1);
 * mega cold twin under #ifndef SHUX_LABI_DIAG_PURE_FROM_X.
 * wave113: pure errno/_path orch; Cap residual is link_diag_strerror_current only.
 * PLATFORM: SHARED. */
#ifndef SHUX_LABI_DIAG_PURE_FROM_X
void shux_link_perror(const char *msg) {
    char op_buf[128];
    char path_buf[160];
    const char *text = msg;
    const char *lparen;
    const char *rparen;
    size_t op_len;
    size_t path_len;
    if (!text || !text[0]) {
        link_diag_errno("process error", "system call");
        return;
    }
    if (strncmp(text, "shux: ", 6) == 0)
        text += 6;
    lparen = strrchr(text, '(');
    rparen = strrchr(text, ')');
    if (lparen && rparen && lparen < rparen && rparen[1] == '\0') {
        const char *op_end = lparen;
        while (op_end > text && op_end[-1] == ' ')
            op_end--;
        op_len = (size_t)(op_end - text);
        path_len = (size_t)(rparen - lparen - 1);
        if (op_len >= sizeof op_buf)
            op_len = sizeof op_buf - 1;
        if (path_len >= sizeof path_buf)
            path_len = sizeof path_buf - 1;
        memcpy(op_buf, text, op_len);
        op_buf[op_len] = '\0';
        memcpy(path_buf, lparen + 1, path_len);
        path_buf[path_len] = '\0';
        link_diag_errno_path("process error", op_buf, path_buf);
        return;
    }
    link_diag_errno("process error", text);
}
#else
void shux_link_perror(const char *msg);
#endif

#define perror(msg) shux_link_perror((msg))

/**
 * 判断 lib root 指针可安全解引用（避开 NULL/low tag/getenv 脏值）。
 * 参数：p 候选 lib root 字符串指针。
 * 返回值：非 0 表示可用。
 */
/* G-02f-115 / wave114：pure orch in labi_path_pure.x (hybrid L0);
 * mega cold twin under #ifndef SHUX_LABI_PATH_PURE_FROM_X.
 * Semantics: null / (uintptr_t)p < 4096 / empty → 0. PLATFORM: SHARED. */
#ifndef SHUX_LABI_PATH_PURE_FROM_X
int shux_asm_ld_lib_root_ptr_usable(const char *p) {
  return p && (uintptr_t)p >= 4096u && p[0] != '\0';
}
#else
int shux_asm_ld_lib_root_ptr_usable(const char *p);
#endif



/**
 * 写入默认 lib root 到 root_buf（SHUX_LIB 或 "."）。
 * 参数：root_buf 至少 512 字节。
 */
/* G-02f-165 / wave115：pure orch in labi_path_pure.x (hybrid L0);
 * mega cold twin under #ifndef SHUX_LABI_PATH_PURE_FROM_X.
 * Semantics: "." then getenv("SHUX_LIB") if pure usable. PLATFORM: SHARED. */
#ifndef SHUX_LABI_PATH_PURE_FROM_X
void shux_asm_ld_lib_root_default(char root_buf[512]) {
    const char *def = getenv("SHUX_LIB");
    root_buf[0] = '.';
    root_buf[1] = '\0';
    if (!shux_asm_ld_lib_root_ptr_usable(def))
        return;
    strncpy(root_buf, def, 511);
    root_buf[511] = '\0';
}
#else
void shux_asm_ld_lib_root_default(char root_buf[512]);
#endif




#if defined(__linux__)
/** nostdlib 链 environ 可能无 PATH：链接子进程优先用绝对路径 gcc（含 gcc 官方镜像 /usr/local/bin）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
const char * shux_linux_host_gcc_path(void) {
    if (access("/usr/bin/gcc", X_OK) == 0)
        return "/usr/bin/gcc";
    if (access("/usr/local/bin/gcc", X_OK) == 0)
        return "/usr/local/bin/gcc";
    return "gcc";
}




/** Linux 链接子进程 PATH：gcc 官方镜像仅提供 /usr/local/bin/gcc。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void shux_linux_ld_child_path(void) {
    (void)setenv("PATH", "/usr/local/bin:/usr/bin:/bin", 1);
}



#endif

/* #region debug-point A:hello-stage1-segv */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void shux_debug_hello_stage1_report(const char *hypothesis_id, const char *location,
    const char *msg, int v1, int v2, int v3) {
    char url[256];
    char session[64];
    const char *env_paths[] = { ".dbg/hello-stage1-segv.env", "../.dbg/hello-stage1-segv.env", NULL };
    int path_i;
    url[0] = '\0';
    session[0] = '\0';
    for (path_i = 0; env_paths[path_i]; path_i++) {
        FILE *fp = fopen(env_paths[path_i], "r");
        char line[320];
        if (!fp)
            continue;
        while (fgets(line, sizeof line, fp)) {
            if (strncmp(line, "DEBUG_SERVER_URL=", 17) == 0) {
                strncpy(url, line + 17, sizeof(url) - 1);
                url[sizeof(url) - 1] = '\0';
                url[strcspn(url, "\r\n")] = '\0';
            } else if (strncmp(line, "DEBUG_SESSION_ID=", 17) == 0) {
                strncpy(session, line + 17, sizeof(session) - 1);
                session[sizeof(session) - 1] = '\0';
                session[strcspn(session, "\r\n")] = '\0';
            }
        }
        fclose(fp);
        if (url[0] && session[0])
            break;
    }
    if (!url[0])
        strncpy(url, "http://127.0.0.1:7777/event", sizeof(url) - 1);
    if (!session[0])
        strncpy(session, "hello-stage1-segv", sizeof(session) - 1);
    if (fork() == 0) {
        char body[768];
        (void)snprintf(body, sizeof(body),
            "{\"sessionId\":\"%s\",\"runId\":\"pre-fix\",\"hypothesisId\":\"%s\",\"location\":\"%s\","
            "\"msg\":\"[DEBUG] %s\",\"data\":{\"v1\":%d,\"v2\":%d,\"v3\":%d}}",
            session, hypothesis_id ? hypothesis_id : "A", location ? location : "runtime_link_abi.c",
            msg ? msg : "hello-stage1", v1, v2, v3);
        execlp("curl", "curl", "-s", "-X", "POST", url, "-H", "Content-Type: application/json", "-d", body, (char *)NULL);
        _exit(0);
    }
}



/* #endregion */

/**
 * 解析当前 shux 可执行文件所在目录（compiler/），用于冷启动时在同一目录生成 runtime_panic.o。
 * Linux 用 /proc/self/exe，macOS 用 _NSGetExecutablePath；再回退 realpath(argv0)。
 * 参数：argv0 可选；out_dir/out_dir_sz 输出缓冲。
 * 返回值：0 成功，-1 失败。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shu_resolve_compiler_dir(const char *argv0, char *out_dir, size_t out_dir_sz) {
    char buf[PATH_MAX];
    buf[0] = '\0';
    if (!out_dir || out_dir_sz < 2)
        return -1;
#if defined(__linux__)
    {
        ssize_t n = readlink("/proc/self/exe", buf, sizeof(buf) - 1);
        if (n > 0) {
            buf[n] = '\0';
            char *slash = strrchr(buf, '/');
            if (slash) {
                *slash = '\0';
                if (strlen(buf) >= out_dir_sz)
                    return -1;
                memcpy(out_dir, buf, strlen(buf) + 1);
                return 0;
            }
        }
    }
#endif
#if defined(__APPLE__)
    {
        uint32_t bufsz = (uint32_t)sizeof(buf);
        if (_NSGetExecutablePath(buf, &bufsz) == 0) {
            char resolved[PATH_MAX];
            if (realpath(buf, resolved) != NULL) {
                char *slash = strrchr(resolved, '/');
                if (slash) {
                    *slash = '\0';
                    if (strlen(resolved) >= out_dir_sz)
                        return -1;
                    memcpy(out_dir, resolved, strlen(resolved) + 1);
                    return 0;
                }
            }
        }
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    {
        /* MinGW process.h 提供 _pgmptr 全局变量（char*），是当前进程可执行文件完整路径
         * （含 .exe 与盘符）。无需 #include <windows.h>，避免与 token.h 的 TOKEN_TYPE 冲突。 */
        extern char *_pgmptr;
        const char *exe_path = _pgmptr;
        if (exe_path && exe_path[0]) {
            size_t n = strlen(exe_path);
            if (n >= sizeof(buf))
                n = sizeof(buf) - 1;
            memcpy(buf, exe_path, n);
            buf[n] = '\0';
            char *slash = shux_path_last_sep(buf);
            if (slash) {
                *slash = '\0';
                if (strlen(buf) >= out_dir_sz)
                    return -1;
                memcpy(out_dir, buf, strlen(buf) + 1);
                return 0;
            }
        }
    }
#endif
    if (!argv0 || !argv0[0] || !shux_path_has_sep(argv0))
        return -1;
    if (realpath(argv0, buf) == NULL)
        return -1;
    {
        char *slash = shux_path_last_sep(buf);
        if (!slash)
            return -1;
        *slash = '\0';
        if (strlen(buf) >= out_dir_sz)
            return -1;
        memcpy(out_dir, buf, strlen(buf) + 1);
    }
    return 0;
}




/**
 * argv0 缺失时构造 «compiler-dir/shux» 供 get_*_path 走 ../std/…；shux 毋须真实存在。
 * 参数：link_argv0 调用方 argv[0]；syn_buf/syn_sz 合成路径缓冲。
 * 返回值：有效 link argv0 或 NULL。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
const char *shux_asm_ld_effective_link_argv0(const char *link_argv0, char *syn_buf, size_t syn_sz) {
    char comp_dir[PATH_MAX];
    int nn;
    if (link_argv0 && link_argv0[0])
        return link_argv0;
    if (!syn_buf || syn_sz == 0)
        return NULL;
    syn_buf[0] = '\0';
    if (shu_resolve_compiler_dir(NULL, comp_dir, sizeof comp_dir) != 0)
        return NULL;
    nn = snprintf(syn_buf, syn_sz, "%s/shux", comp_dir);
    if (nn < 0 || (size_t)nn >= syn_sz)
        return NULL;
    return syn_buf;
}



/**
 * F-03 v2/v3：std.io 已纯 .x，无 io.o；保留 API 供 repo root 推导，返回空串。
 * 参数：argv0 可选 shux 路径。
 * 返回值：空串（调用方应改用 shux_repo_root_from_argv0 的 process.o 路径）。
 */
const char *shux_std_io_o_path(const char *argv0) {
  (void)argv0;
  {
    return shux_empty_cstr();
  }
  return NULL;
}

/**
 * F-04 v7 + F-06 v1：std.compress 已纯 .x，无 compress.o；保留 API 兼容，返回空串。
 * 参数：argv0 可选 shux 路径。
 * 返回值：空串（压缩库由 user .o / 生成 C 扫描按需 -lz/-lzstd/-lbrotli*）。
 */
const char *shux_std_compress_o_path(const char *argv0) {
  (void)argv0;
  {
    return shux_empty_cstr();
  }
  return NULL;
}

/**
 * Derive repo root from the product host binary path.
 * Authority (G.7): shu_resolve_compiler_dir (compiler/) → parent = repo root.
 * PLATFORM: SHARED — must not depend on formal std/*.o existing.
 *
 * Why: after L4 wipe, std/process/process.o is gone. The old path walked
 * process.o up three seps; when process.o is missing, include_root became ""
 * and shux_ensure_formal_std_make_o never ran (mac true-cold residual).
 * Fallback: legacy process.o walk when compiler_dir resolve fails but process.o
 * already exists (warm tree).
 *
 * @param argv0 optional shux path (also used by shu_resolve_compiler_dir fallback)
 * @return static buffer with repo root, or empty string
 */
const char *shux_repo_root_from_argv0(const char *argv0) {
    static char buf[512];
    char comp[PATH_MAX];
    char *last;
    const char *proc_o;
    int k;
    buf[0] = '\0';
    /* Primary: compiler dir from self/exe or argv0 → parent is repo root. */
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) == 0 && comp[0]) {
        if (strlen(comp) < sizeof(buf)) {
            memcpy(buf, comp, strlen(comp) + 1);
            last = shux_path_last_sep(buf);
            if (last && last != buf) {
                *last = '\0';
                return buf;
            }
            buf[0] = '\0';
        }
    }
    /* Fallback: process.o exists (warm tree) → strip std/process/process.o (3 seps). */
    proc_o = shux_rel_o_path_from_argv0(argv0, "std/process/process.o");
    if (!proc_o || !proc_o[0])
        return buf;
    if (strlen(proc_o) >= sizeof(buf))
        return buf;
    strcpy(buf, proc_o);
    for (k = 0; k < 3; k++) {
        last = shux_path_last_sep(buf);
        if (!last || last == buf)
            break;
        *last = '\0';
    }
    return buf;
}

/**
 * 将 path 复制到 bank 下一槽（path 常为栈上 snprintf 结果）；成功返回持久指针；满则返回 NULL。
 * 参数：b bank；path 候选路径。
 */
const char *shux_asm_ld_bank_push_impl(ShuAsmLdPathBank *b, const char *path) {
    if (!b || b->n >= SHUX_ASM_LD_PATH_BANK_SLOTS)
        return NULL;
    if (snprintf(b->slots[b->n], sizeof(b->slots[0]), "%s", path) >= (int)sizeof(b->slots[0]))
        return NULL;
    return b->slots[b->n++];
}

/* G-02f-277 L9 gates */
#ifndef SHUX_LABI_GATES_FROM_X
const char *shux_asm_ld_bank_push(ShuAsmLdPathBank *b, const char *path) {
  if (b == NULL) {
    return NULL;
  }
  if (path == NULL) {
    return NULL;
  }
  {
    if (path[0] == 0) {
      return NULL;
    }
    return shux_asm_ld_bank_push_impl(b, path);
  }
  return NULL;
}
#else
const char *shux_asm_ld_bank_push(ShuAsmLdPathBank *b, const char *path);
#endif

/**
 * 在每个 -L（lib root）根下尝试 rel（如 std/process/process.o）；命中则拷入 bank 并返回指针。
 * 参数：rel 相对路径；lib_roots/n_lib_roots -L 根；bank 路径持久化。
 */
/* wave116：pure orch in labi_path_pure.x (hybrid L0);
 * mega cold twin under #ifndef SHUX_LABI_PATH_PURE_FROM_X.
 * Pure: join root/rel without snprintf; Cap residual skip_missing + bank_push.
 * PLATFORM: SHARED. */
#ifndef SHUX_LABI_PATH_PURE_FROM_X
const char *shux_asm_ld_try_under_lib_roots(const char *rel, const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank) {
    int i;
    char tmp[PATH_MAX];
    if (!rel || (uintptr_t)rel < 4096u)
        return NULL;
    if (!rel[0] || !bank || !lib_roots || (uintptr_t)lib_roots < 4096u || n_lib_roots <= 0)
        return NULL;
    for (i = 0; i < n_lib_roots && i < 24; i++) {
        size_t rn;
        const char *root = lib_roots[i];
        /* nostdlib getenv/environ 异常时 lib_roots 可能为低地址垃圾指针（如 0x1）。 */
        if (!root || (uintptr_t)root < 4096u)
            continue;
        if (!root[0])
            continue;
        rn = strlen(root);
        while (rn > 1 && root[rn - 1] == '/')
            rn--;
        if (rn + 2 + strlen(rel) >= sizeof(tmp))
            continue;
        {
            int nn = rn > 0 ? snprintf(tmp, sizeof tmp, "%.*s/%s", (int)rn, root, rel) : snprintf(tmp, sizeof tmp, "%s", rel);
            if (nn < 0 || nn >= (int)sizeof tmp)
                continue;
        }
        if (!asm_link_obj_skip_missing(tmp))
            continue;
        return shux_asm_ld_bank_push(bank, tmp);
    }
    return NULL;
}
#else
const char *shux_asm_ld_try_under_lib_roots(const char *rel, const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank);
#endif

/**
 * 对 path 做 realpath，仅当目标为已存在常规文件时返回 resolved（避免 nostdlib realpath 拼出不存在的路径）。
 * 参数：path 候选；resolved 输出缓冲（PATH_MAX）。
 * 返回值：resolved 或 NULL。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-270/L L3：realpath+skip 主体始终在 rest（thin shell 在 labi_path_io）。
 * 注意：impl 调用 asm_link_obj_skip_missing（hybrid 时由 L3 提供）。 */
const char *shux_runtime_o_realpath_if_exists_impl(const char *path, char *resolved) {
    if (!path || !path[0] || !resolved || realpath(path, resolved) == NULL)
        return NULL;
    return asm_link_obj_skip_missing(resolved);
}

/* G-02f-270 L3 path IO public thin（非 hybrid 时 rest 自带；hybrid 时由 L3 提供） */
#ifndef SHUX_LABI_PATH_IO_FROM_X
const char * shux_runtime_o_realpath_if_exists(const char *path, char *resolved) {
    if (path == NULL)
        return NULL;
    if (path[0] == 0)
        return NULL;
    if (resolved == NULL)
        return NULL;
    return shux_runtime_o_realpath_if_exists_impl(path, resolved);
}
#else
const char *shux_runtime_o_realpath_if_exists(const char *path, char *resolved);
#endif





/**
 * runtime_panic.o 路径；优先 cwd（runtime_panic.o / compiler/runtime_panic.o），再 argv0 目录。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_panic_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    const char *hit;
    buf[0] = resolved[0] = '\0';
    /* cwd 即 compiler/：与 shux_asm 同目录的 runtime_panic.o */
    hit = shux_runtime_o_realpath_if_exists("runtime_panic.o", resolved);
    if (hit)
        return hit;
    hit = shux_runtime_o_realpath_if_exists("compiler/runtime_panic.o", resolved);
    if (hit)
        return hit;
    {
        char cwd[512];
        if (getcwd(cwd, sizeof(cwd) - 24) != NULL) {
            size_t L = strlen(cwd);
            if (L + 24 <= sizeof(cwd)) {
                memcpy(cwd + L, "/compiler/runtime_panic.o", 25);
                cwd[L + 24] = '\0';
                hit = shux_runtime_o_realpath_if_exists(cwd, resolved);
                if (hit)
                    return hit;
            }
        }
    }
    if (argv0 && argv0[0]) {
        const char *last_slash = shux_path_last_sep(argv0);
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - 20)
                return buf;
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.';
            buf[1] = '\0';
            n = 1;
        }
        if (n + 18 < (int)sizeof(buf)) {
            strcat(buf, "/runtime_panic.o");
            hit = shux_runtime_o_realpath_if_exists(buf, resolved);
            if (hit)
                return hit;
            if (asm_link_obj_skip_missing(buf))
                return buf;
        }
    }
    return buf;
}

/**
 * std.async 协作调度内核（std/async/scheduler.o）；调用 coop_pingpong* 时按需链入。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_std_async_scheduler_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/async/scheduler.o", resolved) != NULL)
        return resolved;
    {
        char cwd[512];
        if (getcwd(cwd, sizeof(cwd) - 26) != NULL) {
            size_t L = strlen(cwd);
            if (L + 26 <= sizeof(cwd)) {
                memcpy(cwd + L, "/std/async/scheduler.o", 22);
                cwd[L + 22] = '\0';
                if (realpath(cwd, resolved) != NULL)
                    return resolved;
            }
        }
    }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = shux_path_last_sep(buf);
        if (last && (size_t)(last - buf) + 26 < sizeof(buf)) {
            *last = '\0';
            strcat(buf, "/../std/async/scheduler.o");
            if (realpath(buf, resolved) != NULL)
                return resolved;
        }
    }
    return buf;
}

/**
 * crt0_user.o 路径；与 runtime_panic.o 同目录（compiler/），供 SHUX_FREESTANDING 链入。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_crt0_user_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("compiler/crt0_user.o", resolved) != NULL)
        return resolved;
    {
        char cwd[512];
        if (getcwd(cwd, sizeof(cwd) - 22) != NULL) {
            size_t L = strlen(cwd);
            if (L + 22 <= sizeof(cwd)) {
                memcpy(cwd + L, "/compiler/crt0_user.o", 22);
                cwd[L + 21] = '\0';
                if (realpath(cwd, resolved) != NULL)
                    return resolved;
            }
        }
    }
    if (argv0 && argv0[0]) {
        const char *last_slash = shux_path_last_sep(argv0);
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - 16)
                return buf;
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.';
            buf[1] = '\0';
            n = 1;
        }
        if (n + 14 < (int)sizeof(buf)) {
            strcat(buf, "/crt0_user.o");
            if (realpath(buf, resolved) != NULL)
                return resolved;
            return buf;
        }
    }
    return buf;
}

/**
 * freestanding_io.o 路径；与 crt0_user.o 同目录（compiler/），供 SHUX_FREESTANDING syscall write。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_freestanding_io_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("compiler/freestanding_io.o", resolved) != NULL)
        return resolved;
    {
        char cwd[512];
        if (getcwd(cwd, sizeof(cwd) - 28) != NULL) {
            size_t L = strlen(cwd);
            if (L + 28 <= sizeof(cwd)) {
                memcpy(cwd + L, "/compiler/freestanding_io.o", 28);
                cwd[L + 27] = '\0';
                if (realpath(cwd, resolved) != NULL)
                    return resolved;
            }
        }
    }
    if (argv0 && argv0[0]) {
        const char *last_slash = shux_path_last_sep(argv0);
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - 20)
                return buf;
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.';
            buf[1] = '\0';
            n = 1;
        }
        if (n + 18 < (int)sizeof(buf)) {
            strcat(buf, "/freestanding_io.o");
            if (realpath(buf, resolved) != NULL)
                return resolved;
            return buf;
        }
    }
    return buf;
}
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

int shux_runtime_compiler_o_path_copy(const char *argv0, const char *leaf, char *out, size_t out_sz) {
    char comp_dir[PATH_MAX];
    int nn;
    if (!out || out_sz == 0 || !leaf || !leaf[0])
        return -1;
    out[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return -1;
    nn = snprintf(out, out_sz, "%s/%s", comp_dir, leaf);
    if (nn < 0 || (size_t)nn >= out_sz) {
        out[0] = '\0';
        return -1;
    }
    return 0;
}




/**
 * seed asm 用户程序：std.io 桩 .o（与 io.o 同链）；见 seeds/runtime_asm_io_stubs.from_x.c。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：.o 路径或空串。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
const char *shux_runtime_asm_io_stubs_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    if (shux_runtime_compiler_o_path_copy(argv0, "runtime_asm_io_stubs.o", resolved, sizeof resolved) != 0)
        resolved[0] = '\0';
    return resolved;
}



/**
 * F-ZC：runtime_process_argv.o 路径；codegen argc/argv 全局，与 process.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
const char *shux_runtime_process_argv_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    if (shux_runtime_compiler_o_path_copy(argv0, "runtime_process_argv.o", resolved, sizeof resolved) != 0)
        resolved[0] = '\0';
    return resolved;
}



const char *shux_runtime_process_os_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_process_os_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_test_fn_invoke.o 路径；std.test fn-ptr，与 test.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_test_fn_invoke_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_test_fn_invoke.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_random_fill.o 路径；CSPRNG OS fill，与 random.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_random_fill_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_random_fill.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * zlib 宏包装桩路径；deflateInit2/inflateInit2 是宏，此 .o 提供真实函数符号。
 */
const char *shux_runtime_compress_zlib_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_compress_zlib_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-03：runtime_heap_user.o 路径；co-emit std.heap redirect 的 heap_*_c 符号。
 */
const char *shux_runtime_heap_user_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_heap_user.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_time_os.o 路径；time OS syscall，与 time.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_time_os_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_time_os.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_queue_contention.o 路径；queue pthread 胶层，与 queue.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_queue_contention_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_queue_contention.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_dynlib_os.o 路径；dlopen/LoadLibrary，与 dynlib.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_dynlib_os_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_dynlib_os.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_env_os.o 路径；env OS getenv/setenv/iter，与 env.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_env_os_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_env_os.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_backtrace_platform.o 路径；capture/symbolicate，与 backtrace.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_backtrace_platform_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_backtrace_platform.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_log_os.o 路径；log sink/轮转/异步，与 log.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_log_os_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_log_os.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_math_libm.o 路径；libm/fenv，与 math.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_math_libm_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_math_libm.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_atomic_glue.o 路径；原子 load/store/CAS/fence，与 atomic.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_atomic_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_atomic_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_channel_glue.o 路径；channel 有界/无界/select，与 channel.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_channel_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_channel_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_net_udp_batch.o 路径；Linux recvmmsg/sendmmsg，与 net.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_net_udp_batch_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_net_udp_batch.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * F-ZC：runtime_net_workers.o 路径；accept worker 线程入口，与 net.o 同链。
 * 参数：argv0 可选 shux 路径。
 * 返回值：.o 路径或空串。
 */
const char *shux_runtime_net_workers_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_net_workers.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_sync_os_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_sync_os.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_sync_lock_diag_tls_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_sync_lock_diag_tls.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_thread_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_thread_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_scheduler_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_scheduler_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_http_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_http_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_tls_mbedtls_bio_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_tls_mbedtls_bio.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_kv_mmap_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_kv_mmap_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_arrow_simd_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_arrow_simd_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_sqlite_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_sqlite_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_crypto_inc_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_crypto_inc_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

const char *shux_runtime_ed25519_ref10_glue_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_ed25519_ref10_glue.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * 若 runtime_panic.o 尚不存在则用 cc -c 从 src/asm 下源码生成到 shux 同目录，以便 ASM -o exe 链接能提供 shux_panic_。
 * G-02f-76/83：产品冷启动源统一 seeds/*.from_x.c。Linux 优先 x86_64 .s；Apple arm64 优先 seeds/runtime_panic_arm64.from_x.c；否则 seeds/runtime_panic.from_x.c。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_ensure_runtime_panic_o(const char *argv0) {
    if (asm_link_obj_skip_missing(shux_runtime_panic_o_path(argv0)))
        return 0;
    char comp[PATH_MAX];
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_panic.o", "try: make -C compiler runtime_panic.o");
        return -1;
    }
    char out_o[PATH_MAX];
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_panic.o", comp) >= sizeof out_o)
        return -1;
#if defined(__linux__)
    char src_s[PATH_MAX];
#endif
    char src_arm[PATH_MAX];
    char src_c[PATH_MAX];
    const char *src = NULL;
    int from_asm_s = 0;
#if defined(__linux__) && (defined(__x86_64__) || defined(__amd64__))
    if ((size_t)snprintf(src_s, sizeof src_s, "%s/src/asm/runtime_panic_x86_64.s", comp) < sizeof src_s && access(src_s, R_OK) == 0) {
        src = src_s;
        from_asm_s = 1;
    }
#endif
#if (defined(__linux__) || defined(__APPLE__)) && (defined(__aarch64__) || defined(__arm64__))
    if (!src && (size_t)snprintf(src_arm, sizeof src_arm, "%s/seeds/runtime_panic_arm64.from_x.c", comp) < sizeof src_arm && access(src_arm, R_OK) == 0)
        src = src_arm;
#endif
    if (!src) {
        if ((size_t)snprintf(src_c, sizeof src_c, "%s/seeds/runtime_panic.from_x.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
            link_diag_runtime_source_missing_under("runtime_panic", comp, "/seeds/");
            return -1;
        }
        src = src_c;
    }
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src, out_o, inc0, inc1, inc2, from_asm_s);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_panic.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_panic_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_panic.o", out_o);
        return -1;
    }
    return 0;
}




/**
 * SHUX_FREESTANDING=1 或 driver -freestanding：Linux x86_64 上用户程序 -nostdlib 静态链（S4）。
 * 参数：driver_freestanding 非 0 表示 driver 已设 -freestanding。
 * 返回值：非 0 表示 freestanding 链启用。
 */
/** G-02f-36：OS 门闩槽 — .x freestanding_enabled 读此，避免 .x 内 #if。 */
/* G-02f-269 / R2 labi_host_lit：#if body Cap residual 常驻 rest（与 path_io stat 同构） */
int shux_host_is_linux_impl(void) {
#if defined(__linux__)
    return 1;
#else
    return 0;
#endif
}

/* R2：public thin 非 hybrid 时 rest 自带；FROM_X 时由 L2 full .x 提供 */
#ifndef SHUX_LABI_HOST_LIT_FROM_X
int shux_host_is_linux(void) {
    return shux_host_is_linux_impl();
}
#else
int shux_host_is_linux(void);
#endif


/** G-02f-43：Apple aarch64 门闩槽 — .x resolve_target_arch 读此。 */
/* G-02f-269 / R2 labi_host_lit：#if body Cap residual 常驻 rest */
int shux_host_is_apple_aarch64_impl(void) {
#if defined(__APPLE__) && defined(__aarch64__)
    return 1;
#else
    return 0;
#endif
}

/* R2：public thin 非 hybrid 时 rest 自带；FROM_X 时由 L2 full .x 提供 */
#ifndef SHUX_LABI_HOST_LIT_FROM_X
int shux_host_is_apple_aarch64(void) {
    return shux_host_is_apple_aarch64_impl();
}
#else
int shux_host_is_apple_aarch64(void);
#endif



/* G-02f-276 L7 freestanding list pure */
#ifndef SHUX_LABI_FREESTANDING_LIST_FROM_X
#include "seeds/labi_freestanding_list.from_x.c"
#else
const char *labi_fs_env_freestanding(void);
int labi_fs_io_sym_count(void);
const char *labi_fs_io_sym_at(int i);
const char *labi_fs_panic_sym(void);
int labi_fs_ensure_catalog_count(void);
int labi_fs_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                   const char **src_rel_out);
const char *labi_fs_ensure_out_base(int i);
const char *labi_fs_ensure_src_rel(int i);
const char *labi_fs_ensure_stem(int i);
const char *labi_fs_crt0_out_base(void);
const char *labi_fs_crt0_src_rel(void);
const char *labi_fs_io_out_base(void);
const char *labi_fs_io_src_rel(void);
/* wave117 needs pure orch (bodies in L7 pure .x / cold seed). */
int labi_fs_heap_c_needle_count(void);
const char *labi_fs_heap_c_needle_at(int i);
int labi_fs_heap_o_sym_count(void);
const char *labi_fs_heap_o_sym_at(int i);
int labi_fs_memcpy_face_sym_count(void);
const char *labi_fs_memcpy_face_sym_at(int i);
int link_abi_generated_c_needs_libc_heap(const char *c_path);
int link_abi_user_o_needs_libc_heap(const char *user_o);
int link_abi_user_o_needs_freestanding_nostdlib_face(const char *user_o);
/* wave136: C-path PRIMARY OS/fs generated_c needs pure (L7). */
int labi_fs_gen_fs_needle_count(void);
const char *labi_fs_gen_fs_needle_at(int i);
int labi_fs_gen_random_needle_count(void);
const char *labi_fs_gen_random_needle_at(int i);
int labi_fs_gen_time_needle_count(void);
const char *labi_fs_gen_time_needle_at(int i);
int labi_fs_gen_runtime_needle_count(void);
const char *labi_fs_gen_runtime_needle_at(int i);
int link_abi_generated_c_needs_fs(const char *c_path);
int link_abi_generated_c_needs_random(const char *c_path);
int link_abi_generated_c_needs_time(const char *c_path);
int link_abi_generated_c_needs_runtime(const char *c_path);
/* wave137: compress lib generated_c needs pure (L7). */
int labi_fs_gen_zlib_needle_count(void);
const char *labi_fs_gen_zlib_needle_at(int i);
int labi_fs_gen_zstd_needle_count(void);
const char *labi_fs_gen_zstd_needle_at(int i);
int labi_fs_gen_brotli_needle_count(void);
const char *labi_fs_gen_brotli_needle_at(int i);
int link_abi_generated_c_needs_zlib(const char *c_path);
int link_abi_generated_c_needs_zstd(const char *c_path);
int link_abi_generated_c_needs_brotli(const char *c_path);
/* wave138: core.slice / std.db.kv / std.db.arrow generated_c needs pure (L7). */
int labi_fs_gen_core_slice_needle_count(void);
const char *labi_fs_gen_core_slice_needle_at(int i);
int labi_fs_gen_db_kv_needle_count(void);
const char *labi_fs_gen_db_kv_needle_at(int i);
int labi_fs_gen_db_arrow_needle_count(void);
const char *labi_fs_gen_db_arrow_needle_at(int i);
int link_abi_generated_c_needs_core_slice(const char *c_path);
int link_abi_generated_c_needs_db_kv(const char *c_path);
int link_abi_generated_c_needs_db_arrow(const char *c_path);
/* wave139: co-emit provides_* pure (L7 freestanding). */
int labi_fs_gen_provides_core_mem_needle_count(void);
const char *labi_fs_gen_provides_core_mem_needle_at(int i);
int labi_fs_gen_provides_std_heap_needle_count(void);
const char *labi_fs_gen_provides_std_heap_needle_at(int i);
int link_abi_generated_c_provides_core_mem(const char *c_path);
int link_abi_generated_c_provides_std_heap(const char *c_path);
#endif

/* G-02f-276：env name from pure table */
int shux_link_freestanding_enabled(int driver_freestanding) {
  char *e;
  if (shux_host_is_linux() == 0)
    return 0;
  if (driver_freestanding != 0)
    return 1;
  e = getenv(labi_fs_env_freestanding());
  if (e == NULL)
    return 0;
  if (e[0] == 0)
    return 0;
  if (e[0] == 48) /* '0' */
    return 0;
  return 1;
}

/**
 * 若 runtime_asm_io_stubs.o 尚不存在则用 cc -c 从 seeds/runtime_asm_io_stubs.from_x.c 生成到 shux 同目录，
 * 以便 ASM -o exe 链 hello 等 import std.io 的程序时提供 std_io_print_str。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog pure
 * LABI_ENS_* 索引/flags 必须始终可见：冷启动 #include labi_ensure_list 只提供
 * catalog_* 实现（整数下标），hybrid FROM_X 由 .x 提供实现；下方 mega ensure
 * 包装器两种路径都用枚举名（不可仅放在 #else 分支，否则 clean 冷启动 undeclared）。 */
enum {
  LABI_ENS_FLAG_NONE = 0,
  LABI_ENS_FLAG_PIE = 1,
  LABI_ENS_FLAG_SQLITE = 2,
  /* runtime_http_glue.from_x.c #include "http_*.inc" — need -I seeds/http */
  LABI_ENS_FLAG_HTTP_SEEDS = 3
};
enum {
  LABI_ENS_ASM_IO_STUBS = 0,
  LABI_ENS_PROCESS_ARGV,
  LABI_ENS_PROCESS_OS_GLUE,
  LABI_ENS_RANDOM_FILL,
  LABI_ENS_COMPRESS_ZLIB_GLUE,
  LABI_ENS_TIME_OS,
  LABI_ENS_QUEUE_CONTENTION,
  LABI_ENS_DYNLIB_OS,
  LABI_ENS_ENV_OS,
  LABI_ENS_BACKTRACE_PLATFORM,
  LABI_ENS_LOG_OS,
  LABI_ENS_MATH_LIBM,
  LABI_ENS_ATOMIC_GLUE,
  LABI_ENS_CHANNEL_GLUE,
  LABI_ENS_NET_UDP_BATCH,
  LABI_ENS_NET_WORKERS,
  LABI_ENS_SYNC_OS,
  LABI_ENS_SYNC_LOCK_DIAG_TLS,
  LABI_ENS_THREAD_GLUE,
  LABI_ENS_SCHEDULER_GLUE,
  LABI_ENS_HTTP_GLUE,
  LABI_ENS_KV_MMAP_GLUE,
  LABI_ENS_ARROW_SIMD_GLUE,
  LABI_ENS_SQLITE_GLUE,
  LABI_ENS_CRYPTO_INC_GLUE,
  LABI_ENS_ED25519_REF10_GLUE,
  LABI_ENS_COUNT
};
#ifndef SHUX_LABI_ENSURE_LIST_FROM_X
#include "seeds/labi_ensure_list.from_x.c"
#else
int labi_ensure_catalog_count(void);
int labi_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                const char **seed_base_out, int *flags_out,
                                const char **hint_out);
const char *labi_ensure_catalog_stem(int i);
const char *labi_ensure_catalog_out_base(int i);
const char *labi_ensure_catalog_seed_base(int i);
int labi_ensure_catalog_flags(int i);
#endif

/**
 * G-02f-273：通用 ensure — 读纯目录表，缺 .o 则 seeds/*.from_x.c → cc -c。
 * path_fn：对应 shux_runtime_*_o_path（探活 / 最终校验）。
 * 返回值：0 成功，-1 失败并已写诊断。
 */
static int link_abi_ensure_from_catalog(const char *argv0, int catalog_idx,
    const char *(*path_fn)(const char *argv0)) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    const char *stem = NULL;
    const char *out_base = NULL;
    const char *seed_base = NULL;
    const char *hint = NULL;
    int flags = 0;
    if (!path_fn)
        return -1;
    if (!labi_ensure_catalog_step_at(catalog_idx, &stem, &out_base, &seed_base, &flags, &hint))
        return -1;
    if (!stem || !out_base || !seed_base)
        return -1;
    if (asm_link_obj_skip_missing(path_fn(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail(out_base, hint);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/%s", comp, out_base) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/seeds/%s", comp, seed_base) >= sizeof src_c
        || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing(stem, src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0
        || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc;
        if (flags == LABI_ENS_FLAG_PIE) {
            const char *extra_flags[] = { "-fPIE", NULL };
            rc = shux_cc_compile_sync_ex(src_c, out_o, inc0, inc1, inc2, 0, extra_flags);
        } else if (flags == LABI_ENS_FLAG_SQLITE) {
            const char *extra_flags[] = { "-DSHUX_DB_USE_SQLITE3", NULL };
            rc = shux_cc_compile_sync_ex(src_c, out_o, inc0, inc1, inc2, 0, extra_flags);
        } else if (flags == LABI_ENS_FLAG_HTTP_SEEDS) {
            /* 【Why 根源】http2/http_*.inc 在 seeds/http/；无 -I 则 ensure 编 glue 失败，
               C 路径 -o 链 http.o 时 U http2_*（hello 也无条件链 http.o）。 */
            char http_inc[PATH_MAX];
            const char *extra_flags[3];
            if ((size_t)snprintf(http_inc, sizeof http_inc, "%s/seeds/http", comp) >= sizeof http_inc)
                return -1;
            extra_flags[0] = "-I";
            extra_flags[1] = http_inc;
            extra_flags[2] = NULL;
            rc = shux_cc_compile_sync_ex(src_c, out_o, inc0, inc1, inc2, 0, extra_flags);
        } else {
            rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        }
        if (rc != 0) {
            link_diag_runtime_obj_build_status(out_base, rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(path_fn(argv0))) {
        link_diag_runtime_obj_missing(out_base, out_o);
        return -1;
    }
    return 0;
}

/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_asm_io_stubs_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_ASM_IO_STUBS, shux_runtime_asm_io_stubs_o_path);
}





/**
 * 若 runtime_process_argv.o 尚不存在则用 cc -c 从 seeds/runtime_process_argv.from_x.c 生成到 shux 同目录，
 * 以便链 process.o 时提供 shux_process_argc/argv 与 process_shux_argc_get。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_process_argv_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_PROCESS_ARGV, shux_runtime_process_argv_o_path);
}



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_process_os_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_PROCESS_OS_GLUE, shux_runtime_process_os_glue_o_path);
}





/**
 * 若 runtime_test_fn_invoke.o 尚不存在则生成到 shux 同目录。
 * G-02e-16：源为 seeds/runtime_test_fn_invoke.from_x.c（G-02f-76）；写临时 wrap.c 再 cc -c。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_ensure_runtime_test_fn_invoke_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char inc_path[PATH_MAX];
    char wrap_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    FILE *wf;
    if (asm_link_obj_skip_missing(shux_runtime_test_fn_invoke_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_test_fn_invoke.o", "try: make -C compiler runtime_test_fn_invoke.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_test_fn_invoke.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(inc_path, sizeof inc_path, "%s/seeds/runtime_test_fn_invoke.from_x.c", comp) >= sizeof inc_path
        || access(inc_path, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_test_fn_invoke", inc_path);
        return -1;
    }
    if ((size_t)snprintf(wrap_c, sizeof wrap_c, "%s/runtime_test_fn_invoke_wrap.c", comp) >= sizeof wrap_c)
        return -1;
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    wf = fopen(wrap_c, "w");
    if (!wf) {
        link_diag_runtime_obj_build_status("runtime_test_fn_invoke.o", -1);
        return -1;
    }
    fprintf(wf, "/* generated by shux_ensure_runtime_test_fn_invoke_o (G-02e-16) */\n#include \"%s\"\n", inc_path);
    fclose(wf);
    {
        int rc = shux_cc_compile_sync(wrap_c, out_o, inc0, inc1, inc2, 0);
        (void)remove(wrap_c);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_test_fn_invoke.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_test_fn_invoke_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_test_fn_invoke.o", out_o);
        return -1;
    }
    return 0;
}




/**
 * 若 runtime_random_fill.o 尚不存在则用 cc -c 从 seeds/runtime_random_fill.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_random_fill_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_RANDOM_FILL, shux_runtime_random_fill_o_path);
}





/**
 * 若 runtime_compress_zlib_glue.o 尚不存在则用 cc -c 从 seeds/runtime_compress_zlib_glue.from_x.c 生成。
 * 提供 deflateInit2/inflateInit2 真实函数符号（zlib.h 中为宏，无函数符号）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_compress_zlib_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_COMPRESS_ZLIB_GLUE, shux_runtime_compress_zlib_glue_o_path);
}





/**
 * 若 runtime_heap_user.o 尚不存在则生成到 shux 同目录。
 * G-02e-14：源为 seeds/runtime_heap_user.from_x.c（G-02f-76；仍可 wrap 编译）。
 * co-emit std.heap allocator_* redirect 的 heap_alloc_c / heap_arena64_alloc_c 等符号。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_ensure_runtime_heap_user_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char inc_path[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    const char *existing = shux_runtime_heap_user_o_path(argv0);
    /*
     * PLATFORM: SHARED — do not keep a stub/empty heap_user.o that lacks arena API.
     * with_arena residual: ensure returned early on 944B incomplete .o → U heap_arena_init_c.
     */
    if (asm_link_obj_skip_missing(existing)) {
        if (shux_link_obj_has_defined_sym(existing, "heap_arena_init_c")
            || shux_link_obj_has_defined_sym(existing, "heap_alloc_c"))
            return 0;
        (void)remove(existing);
    }
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_heap_user.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_heap_user.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(inc_path, sizeof inc_path, "%s/seeds/runtime_heap_user.from_x.c", comp) >= sizeof inc_path
        || access(inc_path, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_heap_user", inc_path);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    /*
     * PLATFORM: SHARED — compile seed .c directly (absolute path).
     * Prior wrap.c include path produced empty 944B .o under ensure (wrap race/empty TU)
     * → U heap_arena_init_c for with_arena. Same pattern as process_argv catalog ensure.
     */
    {
        int rc = shux_cc_compile_sync(inc_path, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_heap_user.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_heap_user_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_heap_user.o", out_o);
        return -1;
    }
    return 0;
}




/**
 * 若 runtime_time_os.o 尚不存在则用 cc -c 从 seeds/runtime_time_os.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_time_os_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_TIME_OS, shux_runtime_time_os_o_path);
}





/**
 * 若 runtime_queue_contention.o 尚不存在则用 cc -c 从 seeds/runtime_queue_contention.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_queue_contention_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_QUEUE_CONTENTION, shux_runtime_queue_contention_o_path);
}





/**
 * 若 runtime_dynlib_os.o 尚不存在则用 cc -c 从 seeds/runtime_dynlib_os.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_dynlib_os_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_DYNLIB_OS, shux_runtime_dynlib_os_o_path);
}





/**
 * 若 runtime_env_os.o 尚不存在则用 cc -c 从 seeds/runtime_env_os.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_env_os_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_ENV_OS, shux_runtime_env_os_o_path);
}





/**
 * 若 runtime_backtrace_platform.o 尚不存在则用 cc -c 从 seeds/runtime_backtrace_platform.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_backtrace_platform_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_BACKTRACE_PLATFORM, shux_runtime_backtrace_platform_o_path);
}





/**
 * 若 runtime_log_os.o 尚不存在则用 cc -c 从 seeds/runtime_log_os.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_log_os_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_LOG_OS, shux_runtime_log_os_o_path);
}





/**
 * 若 runtime_math_libm.o 尚不存在则用 cc -c 从 seeds/runtime_math_libm.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_math_libm_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_MATH_LIBM, shux_runtime_math_libm_o_path);
}





/**
 * 若 runtime_atomic_glue.o 尚不存在则用 cc -c 从 seeds/runtime_atomic_glue.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_atomic_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_ATOMIC_GLUE, shux_runtime_atomic_glue_o_path);
}





/**
 * 若 runtime_channel_glue.o 尚不存在则用 cc -c 从 seeds/runtime_channel_glue.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_channel_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_CHANNEL_GLUE, shux_runtime_channel_glue_o_path);
}





/**
 * 若 runtime_net_udp_batch.o 尚不存在则用 cc -c 从 seeds/runtime_net_udp_batch.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_net_udp_batch_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_NET_UDP_BATCH, shux_runtime_net_udp_batch_o_path);
}





/**
 * 若 runtime_net_workers.o 尚不存在则用 cc -c 从 seeds/runtime_net_workers.from_x.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_net_workers_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_NET_WORKERS, shux_runtime_net_workers_o_path);
}

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_sync_os_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_SYNC_OS, shux_runtime_sync_os_o_path);
}



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_sync_lock_diag_tls_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_SYNC_LOCK_DIAG_TLS, shux_runtime_sync_lock_diag_tls_o_path);
}

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_thread_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_THREAD_GLUE, shux_runtime_thread_glue_o_path);
}



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_scheduler_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_SCHEDULER_GLUE, shux_runtime_scheduler_glue_o_path);
}

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_http_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_HTTP_GLUE, shux_runtime_http_glue_o_path);
}



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


int shux_ensure_runtime_tls_mbedtls_bio_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_tls_mbedtls_bio_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_tls_mbedtls_bio.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_tls_mbedtls_bio.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/seeds/runtime_tls_mbedtls_bio.from_x.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_tls_mbedtls_bio", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        const char *extra_flags[] = { "-I/opt/homebrew/opt/mbedtls/include", NULL };
        int rc = shux_cc_compile_sync_ex(src_c, out_o, inc0, inc1, inc2, 0, extra_flags);
        if (rc != 0) {
            /* 无 mbedTLS 头时由 Makefile 规则兜底；此处仅 best-effort */
            link_diag_runtime_obj_build_status("runtime_tls_mbedtls_bio.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_tls_mbedtls_bio_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_tls_mbedtls_bio.o", out_o);
        return -1;
    }
    return 0;
}
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_kv_mmap_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_KV_MMAP_GLUE, shux_runtime_kv_mmap_glue_o_path);
}



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_arrow_simd_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_ARROW_SIMD_GLUE, shux_runtime_arrow_simd_glue_o_path);
}

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_sqlite_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_SQLITE_GLUE, shux_runtime_sqlite_glue_o_path);
}



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_crypto_inc_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_CRYPTO_INC_GLUE, shux_runtime_crypto_inc_glue_o_path);
}



/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


/* G-02f-273 L4 ensure catalog thin wrap */
int shux_ensure_runtime_ed25519_ref10_glue_o(const char *argv0) {
  return link_abi_ensure_from_catalog(argv0, LABI_ENS_ED25519_REF10_GLUE, shux_runtime_ed25519_ref10_glue_o_path);
}





/**
 * 若 crt0_user.o 尚不存在则从 crt0_user_x86_64.s 编译到 shux 同目录（仅 SHUX_FREESTANDING 路径需要）。
 * 参数：argv0；driver_freestanding 同 shux_link_freestanding_enabled。
 * 返回值：0 成功；未启用 freestanding 时 no-op 返回 0。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-276：crt0 ensure paths from pure table */
int shux_ensure_crt0_user_o(const char *argv0, int driver_freestanding) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_s[PATH_MAX];
    const char *out_base = labi_fs_crt0_out_base();
    const char *src_rel = labi_fs_crt0_src_rel();
    const char *stem = labi_fs_ensure_stem(0);
    if (!shux_link_freestanding_enabled(driver_freestanding))
        return 0;
    if (asm_link_obj_skip_missing(shux_crt0_user_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail(out_base ? out_base : "crt0_user.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/%s", comp, out_base ? out_base : "crt0_user.o") >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_s, sizeof src_s, "%s/%s", comp, src_rel ? src_rel : "src/asm/crt0_user_x86_64.s") >= sizeof src_s
        || access(src_s, R_OK) != 0) {
        link_diag_runtime_source_missing(stem ? stem : "crt0_user", src_s);
        return -1;
    }
    {
        int rc = shux_cc_compile_sync(src_s, out_o, NULL, NULL, NULL, 1);
        if (rc != 0) {
            link_diag_runtime_obj_build_status(out_base ? out_base : "crt0_user.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_crt0_user_o_path(argv0))) {
        link_diag_runtime_obj_missing(out_base ? out_base : "crt0_user.o", out_o);
        return -1;
    }
    return 0;
}




/**
 * 若 freestanding_io.o 尚不存在则从 freestanding_io_x86_64.s 编译（SHUX_FREESTANDING 链入 shux_sys_write）。
 * 参数：argv0；driver_freestanding 同 shux_link_freestanding_enabled。
 * 返回值：0 成功；未启用 freestanding 时 no-op 返回 0。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-276：freestanding_io ensure paths from pure table */
int shux_ensure_freestanding_io_o(const char *argv0, int driver_freestanding) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_s[PATH_MAX];
    const char *out_base = labi_fs_io_out_base();
    const char *src_rel = labi_fs_io_src_rel();
    const char *stem = labi_fs_ensure_stem(1);
    if (!shux_link_freestanding_enabled(driver_freestanding))
        return 0;
    if (asm_link_obj_skip_missing(shux_freestanding_io_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail(out_base ? out_base : "freestanding_io.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/%s", comp, out_base ? out_base : "freestanding_io.o") >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_s, sizeof src_s, "%s/%s", comp, src_rel ? src_rel : "src/asm/freestanding_io_x86_64.s") >= sizeof src_s
        || access(src_s, R_OK) != 0) {
        link_diag_runtime_source_missing(stem ? stem : "freestanding_io", src_s);
        return -1;
    }
    {
        int rc = shux_cc_compile_sync(src_s, out_o, NULL, NULL, NULL, 1);
        if (rc != 0) {
            link_diag_runtime_obj_build_status(out_base ? out_base : "freestanding_io.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_freestanding_io_o_path(argv0))) {
        link_diag_runtime_obj_missing(out_base ? out_base : "freestanding_io.o", out_o);
        return -1;
    }
    return 0;
}




/**
 * CI/Docker/musl 上 -march=native/-flto 可能导致 cc 异常退出（exit -1）。
 * 参数：无。
 * 返回值：非 0 表示跳过 native 调优。
 */
/* G-02f-274 L5 invoke_cc list pure */
#ifndef SHUX_LABI_INVOKE_CC_LIST_FROM_X
#include "seeds/labi_invoke_cc_list.from_x.c"
#else
int labi_linux_harden_flag_count(void);
const char *labi_linux_harden_flag_at(int i);
int labi_invoke_cc_skip_native_env_count(void);
const char *labi_invoke_cc_skip_native_env_at(int i);
int invoke_cc_skip_native_tuning(void);
const char *labi_icc_rel_core_builtin_o(void);
const char *labi_icc_rel_core_builtin_abi_h(void);
const char *labi_icc_rel_core_mem_o(void);
const char *labi_icc_rel_core_slice_o(void);
const char *labi_icc_rel_db_kv_o(void);
const char *labi_icc_rel_db_arrow_o(void);
const char *labi_icc_rel_csv_o(void);
const char *labi_icc_rel_error_o(void);
const char *labi_icc_rel_heap_o(void);
const char *labi_icc_rel_json_o(void);
const char *labi_icc_rel_log_o(void);
const char *labi_icc_rel_socketio_o(void);
int labi_icc_needs_rel_count(void);
const char *labi_icc_needs_rel_at(int i);
#endif


/**
 * invoke_cc 子进程：仅当 path 指向已存在的 .o 时追加到 argv（可选 realpath）。
 * 参数：见 runtime_link_abi.h。
 * 返回值：1 已追加，0 跳过。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int invoke_cc_argv_push_existing(char *argv[], int *ia, int max_ia, const char *path) {
    static char abs_pool[INVOKE_CC_ABS_POOL_SZ][PATH_MAX];
    static int abs_pool_i;
    const char *use;
    if (!path || !path[0] || !ia || *ia >= max_ia - 1)
        return 0;
    use = asm_link_obj_skip_missing(path);
    if (!use) {
        return 0;
    }
#if !defined(_WIN32) && !defined(_WIN64)
    {
        char *slot = abs_pool[abs_pool_i % INVOKE_CC_ABS_POOL_SZ];
        abs_pool_i++;
        if (realpath(use, slot) != NULL)
            use = slot;
    }
#endif
    /* needs_fs/needs_runtime 按需块与后续全量链入勿重复同一 .o（EXC-002 ld duplicate）。 */
    {
        int k;
        for (k = 0; k < *ia; k++) {
            if (argv[k] && strcmp(argv[k], use) == 0)
                return 0;
        }
    }
    argv[(*ia)++] = (char *)use;
    return 1;
}




/**
 * task.o 链入时须同时链入 scheduler.o；若调用方未显式传入则从 task_o 路径推导。
 * 参数：见 runtime_link_abi.h。
 * 返回值：scheduler .o 路径或 NULL。
 */
const char *scheduler_o_for_task_link(const char *task_o, const char *explicit_scheduler) {
    static char derived[PATH_MAX];
    static char cwd_buf[PATH_MAX];
    const char *from = "std/task/task.o";
    const char *to = "std/async/scheduler.o";
    char *pos;
    if (explicit_scheduler && explicit_scheduler[0])
        return explicit_scheduler;
    if (!task_o || !task_o[0])
        return NULL;
    if (strlen(task_o) >= sizeof(derived))
        return NULL;
    memcpy(derived, task_o, strlen(task_o) + 1);
    pos = strstr(derived, from);
    if (pos) {
        size_t tail = strlen(pos + strlen(from));
        memmove(pos + strlen(to), pos + strlen(from), tail + 1);
        memcpy(pos, to, strlen(to));
        if (access(derived, F_OK) == 0)
            return derived;
    }
    cwd_buf[0] = '\0';
    if (realpath("std/async/scheduler.o", cwd_buf) != NULL)
        return cwd_buf;
    return NULL;
}

/**
 * 检测 .o 是否导出 marker 符号（nm 输出含 marker 子串）。
 * 参数：obj_o 目标 .o；marker 符号名子串。
 * 返回值：1 命中，0 否。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int link_abi_obj_exports_marker(const char *obj_o, const char *marker) {
    char cmd[PATH_MAX + 96];
    FILE *fp;
    char line[512];
    const char *use = obj_o;
    static char resolved[PATH_MAX];
    if (!obj_o || !obj_o[0] || !marker || !marker[0])
        return 0;
#if !defined(_WIN32) && !defined(_WIN64)
    if (realpath(obj_o, resolved) != NULL)
        use = resolved;
#endif
    if ((size_t)snprintf(cmd, sizeof cmd, "nm '%s' 2>/dev/null", use) >= sizeof cmd)
        return 0;
    fp = popen(cmd, "r");
    if (!fp)
        return 0;
    while (fgets(line, sizeof line, fp)) {
        if (strstr(line, marker) != NULL) {
            pclose(fp);
            return 1;
        }
    }
    pclose(fp);
    return 0;
}




/**
 * 检测 .o 是否含未定义符号 sym（nm 行含 " U " 与 sym 子串）。
 * 参数：obj_o 目标 .o；sym 符号名子串。
 * 返回值：1 含未定义 sym，0 否。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int link_abi_obj_has_undef_sym(const char *obj_o, const char *sym) {
    char cmd[PATH_MAX + 96];
    FILE *fp;
    char line[512];
    const char *use = obj_o;
    static char resolved[PATH_MAX];
    if (!obj_o || !obj_o[0] || !sym || !sym[0])
        return 0;
#if !defined(_WIN32) && !defined(_WIN64)
    if (realpath(obj_o, resolved) != NULL)
        use = resolved;
#endif
    if ((size_t)snprintf(cmd, sizeof cmd, "nm '%s' 2>/dev/null", use) >= sizeof cmd)
        return 0;
    fp = popen(cmd, "r");
    if (!fp)
        return 0;
    while (fgets(line, sizeof line, fp)) {
        if (strstr(line, " U ") != NULL && strstr(line, sym) != NULL) {
            pclose(fp);
            return 1;
        }
    }
    pclose(fp);
    return 0;
}




/*
 * wave131: compress family pure orch lives in labi_ondemand_list
 * (zlib/zstd/brotli marker + UNDEF/prefix tables + needs_compress_libs).
 * Cap residual: link_abi_obj_exports_marker + link_abi_obj_has_undef_sym stay mega.
 * Cold twin: #include labi_ondemand_list.from_x.c (below); hybrid FROM_X → L8b pure.
 * Forward decls: call sites below need symbols before the ondemand include block.
 * PLATFORM: SHARED.
 */
int link_abi_obj_needs_zlib(const char *obj_o);
int link_abi_obj_needs_zstd(const char *obj_o);
int link_abi_obj_needs_brotli(const char *obj_o);
int link_abi_user_o_needs_compress_libs(const char *user_o);

/* G-02f-275 L6 invoke_ld list pure */
#ifndef SHUX_LABI_INVOKE_LD_LIST_FROM_X
#include "seeds/labi_invoke_ld_list.from_x.c"
#else
int labi_ld_brew_lib_path_count(void);
const char *labi_ld_brew_lib_path_at(int i);
const char *labi_ld_flag_lz(void);
const char *labi_ld_flag_lzstd(void);
const char *labi_ld_flag_lbrotlienc(void);
const char *labi_ld_flag_lbrotlidec(void);
int labi_ld_compress_flag_count(void);
const char *labi_ld_compress_flag_at(int i);
const char *labi_ld_flag_lm(void);
const char *labi_ld_flag_lsqlite3(void);
const char *labi_ld_flag_pthread(void);
const char *labi_ld_flag_lpthread(void);
const char *labi_ld_flag_ldl(void);
const char *labi_ld_flag_lc(void);
const char *labi_ld_flag_lSystem(void);
const char *labi_ld_flag_lws2_32(void);
const char *labi_ld_flag_lbcrypt(void);
const char *labi_ld_driver_clang(void);
const char *labi_ld_driver_ld(void);
const char *labi_ld_driver_gcc(void);
const char *labi_ld_driver_cc(void);
const char *labi_ld_mach_entry_main(void);
const char *labi_ld_flag_e(void);
const char *labi_ld_flag_o(void);
int labi_ld_common_tail_flag_count(void);
const char *labi_ld_common_tail_flag_at(int i);
#endif

/** macOS Homebrew /usr/local：便于 -lz / -lzstd 解析。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-275：brew -L 表驱动 */
void ld_append_brew_lib_paths(const char **argv, int *la, int max_la) {
#if defined(__APPLE__)
    int n = labi_ld_brew_lib_path_count();
    int k;
    for (k = 0; k < n; k++) {
        const char *p = labi_ld_brew_lib_path_at(k);
        if (!p || !p[0])
            continue;
        if (*la < max_la - 1)
            argv[(*la)++] = p;
    }
#else
    (void)argv;
    (void)la;
    (void)max_la;
#endif
}




/**
 * ASM 链接：按 compress.o / 用户 .o 实际依赖追加 -lz / -lzstd / -lbrotli*。
 * 参数：compress_o std/compress .o；user_o 用户主 .o（F-04 v4 libz.x）；argv/la/max_la 为 ld argv 构建状态。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-275：compress -l* from pure table */
void asm_ld_append_compress_libs(const char *compress_o, const char *user_o, const char **argv, int *la, int max_la) {
    if (!argv || !la)
        return;
    if (link_abi_obj_needs_zlib(compress_o) || link_abi_obj_needs_zlib(user_o)) {
        ld_append_brew_lib_paths(argv, la, max_la);
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lz();
        /* zlib 宏包装桩：deflateInit2/inflateInit2 是宏，需真实函数符号 */
        (void)shux_ensure_runtime_compress_zlib_glue_o(NULL);
        {
            const char *glue = shux_runtime_compress_zlib_glue_o_path(NULL);
            if (glue && glue[0] && *la < max_la - 1)
                argv[(*la)++] = glue;
        }
    }
    if (link_abi_obj_needs_zstd(compress_o) || link_abi_obj_needs_zstd(user_o)) {
        ld_append_brew_lib_paths(argv, la, max_la);
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lzstd();
    }
    if (link_abi_obj_needs_brotli(compress_o) || link_abi_obj_needs_brotli(user_o)) {
        ld_append_brew_lib_paths(argv, la, max_la);
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lbrotlienc();
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lbrotlidec();
    }
}




/**
 * invoke_cc 链接：按 compress.o / 用户 .o 实际依赖追加 -lz / -lzstd / -lbrotli*。
 * 参数：argv/i/argv_cap 为 cc 链接 argv；compress_o 候选 compress .o；user_o 用户 .o（可 NULL）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-275：invoke_cc compress -l* from pure table */
void invoke_cc_append_compress_ld(char *argv[], int *i, int argv_cap, const char *compress_o, const char *user_o) {
    if (!argv || !i || *i >= argv_cap - 1)
        return;
    if (link_abi_obj_needs_zlib(compress_o) || link_abi_obj_needs_zlib(user_o)) {
        ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)labi_ld_flag_lz();
        /* zlib 宏包装桩：deflateInit2/inflateInit2 是宏，需真实函数符号 */
        (void)shux_ensure_runtime_compress_zlib_glue_o(NULL);
        (void)invoke_cc_argv_push_existing(argv, i, argv_cap,
            shux_runtime_compress_zlib_glue_o_path(NULL));
    }
    if (link_abi_obj_needs_zstd(compress_o) || link_abi_obj_needs_zstd(user_o)) {
        ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)labi_ld_flag_lzstd();
    }
    if (link_abi_obj_needs_brotli(compress_o) || link_abi_obj_needs_brotli(user_o)) {
        ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)labi_ld_flag_lbrotlienc();
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)labi_ld_flag_lbrotlidec();
    }
}




/**
 * B-20 v1：扫描生成 C 是否含任一子串（invoke_cc 按需链入判定）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int link_abi_generated_c_contains_any_substr(const char *c_path, const char **needles, int n_needles) {
    ShuxRuntimeFileView view;
    int i;
    int found = 0;

    if (!c_path || !c_path[0] || !needles || n_needles <= 0)
        return 0;
    if (runtime_read_file_view(c_path, &view) != 0)
        return 0;
    for (i = 0; i < n_needles; i++) {
        if (needles[i]) {
            size_t needle_len = strlen(needles[i]);
            if (needle_len == 0) {
                found = 1;
                break;
            }
            if (view.length >= needle_len) {
                size_t off;
                for (off = 0; off + needle_len <= view.length; off++) {
                    if (memcmp(view.data + off, needles[i], needle_len) == 0) {
                        found = 1;
                        break;
                    }
                }
                if (found)
                    break;
            }
        }
    }
    runtime_release_file_view(&view);
    return found;
}




/** G-02f-39：单 needle 包装，供 .x generated_c_needs_* 调用。 */
int link_abi_generated_c_contains_substr(const char *c_path, const char *needle) {
    const char *needles[1];
    if (!needle || !needle[0])
        return 0;
    needles[0] = needle;
    return link_abi_generated_c_contains_any_substr(c_path, needles, 1);
}

/**
 * 生成 C 是否含 needle，且命中行不是 `extern` 声明 / `#define` 宏头。
 * 【Why】rt_preamble 恒注入 `extern ... std_context_background(` 与
 * `#define std_net_net_close_socket_c`；裸 substr 会让 hello 假链 context/net。
 * 仅当某行出现真实调用/定义体时才视为 need。
 */
int link_abi_generated_c_contains_substr_use_line(const char *c_path, const char *needle) {
    ShuxRuntimeFileView view;
    size_t needle_len;
    size_t off;
    if (!c_path || !c_path[0] || !needle || !needle[0])
        return 0;
    needle_len = strlen(needle);
    if (runtime_read_file_view(c_path, &view) != 0)
        return 0;
    if (view.length < needle_len) {
        runtime_release_file_view(&view);
        return 0;
    }
    for (off = 0; off + needle_len <= view.length; off++) {
        size_t line_start;
        size_t line_end;
        size_t k;
        int is_extern = 0;
        int is_define = 0;
        int is_comment = 0;
        if (memcmp(view.data + off, needle, needle_len) != 0)
            continue;
        line_start = off;
        while (line_start > 0 && view.data[line_start - 1] != '\n')
            line_start--;
        line_end = off + needle_len;
        while (line_end < view.length && view.data[line_end] != '\n')
            line_end++;
        /* 跳过行首空白后的 extern / #define / // */
        k = line_start;
        while (k < line_end && (view.data[k] == ' ' || view.data[k] == '\t'))
            k++;
        if (k + 6 <= line_end && memcmp(view.data + k, "extern", 6) == 0)
            is_extern = 1;
        if (k < line_end && view.data[k] == '#') {
            size_t k2 = k + 1;
            while (k2 < line_end && (view.data[k2] == ' ' || view.data[k2] == '\t'))
                k2++;
            if (k2 + 6 <= line_end && memcmp(view.data + k2, "define", 6) == 0)
                is_define = 1;
        }
        if (k + 2 <= line_end && view.data[k] == '/' && view.data[k + 1] == '/')
            is_comment = 1;
        if (k + 2 <= line_end && view.data[k] == '/' && view.data[k + 1] == '*')
            is_comment = 1;
        /*
         * PLATFORM: SHARED — preamble type decls (struct/typedef std_net_*) are NOT real refs.
         * But variable decls like "struct Foo x = std_net_listen(...)" ARE real refs: the needle
         * is the function call (std_net_listen), not the struct name (Foo). The legacy check
         * "line-startswith struct/typedef" falsely skipped such lines → need_net=0 → net.o not
         * pushed → BLD001 undefined _std_net_listen.
         * Root cause fix (2026-07-19): distinguish struct/typedef DEFINITION (needle is the
         * type name, preceded by "struct "/"typedef ") from variable decl (needle is the
         * function call, preceded by "= "/"("/"," etc.). Only skip the former.
         */
        {
            size_t p = off;
            while (p > line_start && (view.data[p - 1] == ' ' || view.data[p - 1] == '\t'))
                p--;
            if (p >= line_start + 7 && memcmp(view.data + p - 7, "struct ", 7) == 0)
                is_extern = 1; /* needle is the struct name in a definition or variable decl */
            if (p >= line_start + 8 && memcmp(view.data + p - 8, "typedef ", 8) == 0)
                is_extern = 1; /* needle is the typedef name */
        }
        /* weak placeholder 体：仅当本行含 placeholder（如 std_string_placeholder）才跳过 */
        {
            size_t li;
            for (li = k; li + 11 <= line_end; li++) {
                if (memcmp(view.data + li, "placeholder", 11) == 0) {
                    is_extern = 1;
                    break;
                }
            }
        }
        /*
         * PLATFORM: SHARED — skip rt_preamble weak stub bodies.
         * Preamble always emits weak process_args_* → process_shux_* (and similar).
         * Counting those as "use" forced every -o to ensure runtime_process_argv.o
         * (pure rv/hello residual). Real user calls are non-weak use_lines.
         * G.7: complete use_line authority; no second skip table for process only.
         */
        {
            size_t li;
            /* "__attribute__((weak))" is 21 chars */
            for (li = k; li + 21 <= line_end; li++) {
                if (memcmp(view.data + li, "__attribute__((weak))", 21) == 0) {
                    is_extern = 1;
                    break;
                }
            }
        }
        if (!is_extern && !is_define && !is_comment) {
            runtime_release_file_view(&view);
            return 1;
        }
    }
    runtime_release_file_view(&view);
    return 0;
}

int link_abi_generated_c_contains_any_substr_use_line(const char *c_path, const char **needles, int n_needles) {
    int i;
    if (!c_path || !needles || n_needles <= 0)
        return 0;
    for (i = 0; i < n_needles; i++) {
        if (needles[i] && needles[i][0] &&
            link_abi_generated_c_contains_substr_use_line(c_path, needles[i]))
            return 1;
    }
    return 0;
}


/*
 * wave117: needs_libc_heap / freestanding_nostdlib_face pure orch live in
 * labi_freestanding_list (tables + orch). Full-seed path: bodies via #include above
 * (!FROM_X). Hybrid FROM_X: L7 pure .x provides; decls in #else of freestanding include.
 * wave136: link_abi_generated_c_needs_{fs,random,time,runtime} pure orch same L7
 * wave137: link_abi_generated_c_needs_{zlib,zstd,brotli} pure orch same L7
 * wave138: link_abi_generated_c_needs_{core_slice,db_kv,db_arrow} pure orch same L7
 * wave139: link_abi_generated_c_provides_{core_mem,std_heap} pure orch same L7
 * (C-path PRIMARY OS/fs string needles; Cap residual contains_substr).
 * Cap residual: contains_substr / undef_sym stay mega. PLATFORM: SHARED.
 */
/* (definitions: seeds/labi_freestanding_list.from_x.c or L7 pure .x) */

/**
 * PLATFORM: LINUX — path to bootstrap_nostdlib_stubs.o (mmap bump malloc/free face).
 * Same object as compiler nostdlib bag; freestanding user link pulls it on demand.
 */
const char *shux_bootstrap_nostdlib_stubs_o_path(const char *argv0) {
    static char buf[PATH_MAX];
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    buf[0] = resolved[0] = '\0';
    if (realpath("compiler/src/asm/bootstrap_nostdlib_stubs.o", resolved) != NULL)
        return resolved;
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) == 0) {
        nn = snprintf(buf, sizeof buf, "%s/src/asm/bootstrap_nostdlib_stubs.o", comp_dir);
        if (nn > 0 && (size_t)nn < sizeof buf) {
            if (realpath(buf, resolved) != NULL)
                return resolved;
            return buf;
        }
    }
    return buf;
}

/**
 * PLATFORM: LINUX — ensure bootstrap_nostdlib_stubs.o exists (cc seed if missing).
 * G.7: one face for freestanding malloc (page-backed), shared with compiler nostdlib bag.
 */
int shux_ensure_bootstrap_nostdlib_stubs_o(const char *argv0) {
    const char *existing = shux_bootstrap_nostdlib_stubs_o_path(argv0);
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char cmd[PATH_MAX * 3];
    int rc;
    if (existing && existing[0] && asm_link_obj_skip_missing(existing))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("bootstrap_nostdlib_stubs.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/src/asm/bootstrap_nostdlib_stubs.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/seeds/bootstrap_nostdlib_stubs.from_x.c", comp) >= sizeof src_c
        || !asm_link_obj_skip_missing(src_c)) {
        link_diag_runtime_source_missing("bootstrap_nostdlib_stubs", src_c);
        return -1;
    }
    /* PLATFORM: LINUX — same seed as g05 ensure_bootstrap_nostdlib_stubs_obj. */
    rc = snprintf(cmd, sizeof cmd, "cc -c -O2 -fno-builtin -I%s -I%s/include -I%s/src -o %s %s",
                  comp, comp, comp, out_o, src_c);
    if (rc < 0 || (size_t)rc >= sizeof cmd)
        return -1;
    rc = system(cmd);
    if (rc != 0) {
        link_diag_runtime_obj_build_status("bootstrap_nostdlib_stubs.o", rc);
        return -1;
    }
    if (!asm_link_obj_skip_missing(shux_bootstrap_nostdlib_stubs_o_path(argv0))) {
        link_diag_runtime_obj_missing("bootstrap_nostdlib_stubs.o", out_o);
        return -1;
    }
    return 0;
}

int link_abi_generated_c_needs_win32(const char *c_path) {
  (void)(({   {
    if ((link_abi_generated_c_contains_substr(c_path, "GetStdHandle") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "WriteFile") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "CreateFileA") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "ReadFile") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "CloseHandle") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "ExitProcess") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "win32_write") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "win32_read_file_into") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "win32_exit_process") !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/**
 * 生成的 .c 是否引用 winsock2（F-02 v2：按需 -lws2_32，无 win32_net.inc.c）。
 */
int link_abi_generated_c_needs_win32_wsa(const char *c_path) {
  (void)(({   {
    if ((link_abi_generated_c_contains_substr(c_path, "WSAStartup") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "WSACleanup") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "win32_net_available") !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}

/**
 * 生成的 .c 是否引用 core.builtin 位运算（G-01：__builtin_* 内联，不再链 builtin.o）。
 */
int link_abi_generated_c_needs_core_builtin(const char *c_path) {
  return 0;
}

/** 扫描生成 C 是否引用 core.mem volatile/fence 符号（G-01：纯 .x，不再链 mem.o）。 */
int link_abi_generated_c_needs_core_mem(const char *c_path) {
  (void)c_path;
  return 0;
}

/**
 * 产品轨 std 模块：预编 std/*.o 为符号权威时，禁止 pipeline co-emit 函数体。
 * 与 ast_pool pipeline_codegen_std_dep_link_only 同形；放 link_abi 保证产品二进制必有符号
 * （Darwin 上 pipeline_x.o 与 glue standalone 双定义时 glue 可能未胜出）。
 */
int pipeline_codegen_std_dep_link_only(uint8_t *path) {
  static const char *const k[] = {
      "std.base64", "std.json", "std.csv", "std.heap", "std.heap.libc", "std.http",
      "std.crypto", "std.encoding", "std.log", "std.net", "std.regex",
      /* 勿 link_only std.unicode：unicode.o 为 std.unicode.unicode 内部符号
       *（std_unicode_unicode_*），与 mod.x API（std_unicode_category）不一致；
       * co-emit mod 再导出 + unicode.x 体为权威。 */
      "std.dynlib", "std.tar",
      /* 勿 link_only std.channel / std.backtrace：*.o 仅为 marker，API 在 mod.x 包装
       * channel_i32_*_c / backtrace_*_c（runtime_*_glue / platform）。 */
      "std.atomic", "std.sync", "std.thread",
      "std.time", "std.random",
      /* 勿 link_only std.env：C 路径仍可 co-emit mod；formal env.o 现为
       * mod.x（std_env_*）+ runtime_env_os.o（env_*_c），asm 由 fk0 按需推入。 */
      "std.math", "std.hash",
      /* 勿 link_only std.sort：C 路径仍可 co-emit mod；formal sort.o 现为
       * mod.x+sort.x（std_sort_sort_*），asm 由 fk0 探针按需推入。 */
      "std.ffi",
      "std.db", "std.test",
      /* 勿 link_only std.compress：纯 .x、无 compress.o；link_only 只留 extern → 未定义符号 */
      /* set/map/queue/vec：预编 .o 权威；-o co-emit 重载/布局易与 preamble 漂移 */
      "std.set", "std.map", "std.queue", "std.vec",
      /* path：path.o = runtime_path_fast 权威；co-emit mod.x 再链 path.o → duplicate */
      "std.path",
      /* error：error.o 权威；co-emit 现仅 extern，须链 .o 补符号 */
      "std.error",
      /* context：context.o (mod.x + context.x) 权威；co-emit mod.x 的 deadline_ns/with_deadline
       * etc. 与 context.o 强符号 duplicate（net-context gate 红）。G.7 single authority. */
      "std.context", NULL};
  int i;
  size_t n;
  size_t plen;
  if (!path || !path[0])
    return 0;
  /* 安全取长：dep path 缓冲可能无尾 0（仅靠 len）；仍兼容 C 字符串 */
  plen = 0;
  while (plen < 64 && path[plen] != 0)
    plen++;
  for (i = 0; k[i]; i++) {
    n = strlen(k[i]);
    if (n > plen)
      continue;
    if (memcmp(path, k[i], n) == 0 && (n == plen || path[n] == '.' || path[n] == 0)) {
      if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [link_only] hit exact/prefix key=%s path=%s -> 1\n", k[i], path);
      return 1;
    }
  }
  /* 前缀兜底：std.heap* / std.json* 等 */
  if (plen >= 8 && memcmp(path, "std.heap", 8) == 0)
    return 1;
  if (plen >= 8 && memcmp(path, "std.json", 8) == 0)
    return 1;
  if (plen >= 7 && memcmp(path, "std.csv", 7) == 0)
    return 1;
  if (plen >= 10 && memcmp(path, "std.base64", 10) == 0)
    return 1;
  if (getenv("SHUX_DEBUG_PIPE"))
    fprintf(stderr, "shux: [link_only] miss path=%s plen=%zu -> 0\n", path, plen);
  return 0;
}

/* wave139: link_abi_generated_c_provides_core_mem pure orch lives in labi_freestanding_list
 * (3 definition-line needles + pure scan; Cap residual contains_substr). Was mega body.
 * Cold twin under #ifndef FREESTANDING_LIST_FROM_X; hybrid L7 pure .x.
 * Why: co-emit core_mem_* bodies in user TU; hard-link mem.o → duplicate.
 * PLATFORM: SHARED — G.7 complete product surface; dual-end L2.
 */
int link_abi_generated_c_provides_core_mem(const char *c_path);

/* wave139: link_abi_generated_c_provides_std_heap pure orch (L7 freestanding).
 * Why: co-emit heap_libc bodies; hard-link heap.o → duplicate.
 */
int link_abi_generated_c_provides_std_heap(const char *c_path);

/* wave138: link_abi_generated_c_needs_db_kv pure orch lives in labi_freestanding_list
 * (7 needles + pure scan; Cap residual contains_substr). Was mega body.
 * Cold twin under #ifndef FREESTANDING_LIST_FROM_X; hybrid L7 pure .x.
 * PLATFORM: SHARED — G.7 complete product surface; dual-end L2.
 */
int link_abi_generated_c_needs_db_kv(const char *c_path);

/* wave138: link_abi_generated_c_needs_db_arrow pure orch (L7 freestanding). */
int link_abi_generated_c_needs_db_arrow(const char *c_path);

/* wave138: link_abi_generated_c_needs_core_slice pure orch (L7 freestanding). */
int link_abi_generated_c_needs_core_slice(const char *c_path);


/* wave136: link_abi_generated_c_needs_fs pure orch lives in labi_freestanding_list
 * (5 needles + pure scan; Cap residual contains_substr). Was mega body.
 * Cold twin under #ifndef FREESTANDING_LIST_FROM_X; hybrid L7 pure .x.
 * PLATFORM: SHARED — G.7 complete product surface; dual-end L2.
 */
int link_abi_generated_c_needs_fs(const char *c_path);

/* wave137: link_abi_generated_c_needs_zlib pure orch lives in labi_freestanding_list
 * (7 needles + pure scan; Cap residual contains_substr). Was mega body.
 * Cold twin under #ifndef FREESTANDING_LIST_FROM_X; hybrid L7 pure .x.
 * PLATFORM: SHARED — G.7 complete product surface; dual-end L2.
 */
int link_abi_generated_c_needs_zlib(const char *c_path);

/* wave137: link_abi_generated_c_needs_zstd pure orch (L7 freestanding). */
int link_abi_generated_c_needs_zstd(const char *c_path);

/* wave137: link_abi_generated_c_needs_brotli pure orch (L7 freestanding). */
int link_abi_generated_c_needs_brotli(const char *c_path);

/* wave136: link_abi_generated_c_needs_random pure orch (L7 freestanding). */
int link_abi_generated_c_needs_random(const char *c_path);

/* wave136: link_abi_generated_c_needs_time pure orch (L7 freestanding). */
int link_abi_generated_c_needs_time(const char *c_path);

/* wave136: link_abi_generated_c_needs_runtime pure orch (L7 freestanding). */
int link_abi_generated_c_needs_runtime(const char *c_path);

/**
 * 生成的 .c 是否引用 std.async scheduler（C 前端 invoke_cc 按需链 scheduler.o）。
 */
int shux_generated_c_needs_async_scheduler(const char *c_path) {
  (void)(({   {
    if ((link_abi_generated_c_contains_substr(c_path, "shux_async_run_i32") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "shux_async_cps_suspend") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "shux_async_task_submit") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "shux_async_run_seed_") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "shux_async_coop_pingpong_jmp") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "shux_async_coop_pingpong") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "shux_async_run_drain_until_idle") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "shux_async_queue_reset") !=0)) {
      return 1;
    }
    if ((link_abi_generated_c_contains_substr(c_path, "shux_async_bind_context_c") !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}
/** G-02f-47/65：path 为已存在且 size>0 的常规文件。stat 在 _impl；.x 门闩。 */
/* G-02f-270/L L3 path IO：stat 主体始终在 rest（与 gates _impl 同构）；
 * 公共 thin shell 由 labi_path_io seed/.x 在 SHUX_LABI_PATH_IO_FROM_X 时提供。 */
int shux_path_is_nonempty_regular_file_impl(const char *path) {
    struct stat st;
    if (!path || !path[0])
        return 0;
    if (stat(path, &st) != 0 || !S_ISREG(st.st_mode))
        return 0;
    if (st.st_size <= 0)
        return 0;
    return 1;
}


/* G-02f-270 L3 path IO */
#ifndef SHUX_LABI_PATH_IO_FROM_X
int shux_path_is_nonempty_regular_file(const char *path) {
  if (path == NULL) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  {
    return shux_path_is_nonempty_regular_file_impl(path);
  }
  return 0;
}
#else
int shux_path_is_nonempty_regular_file(const char *path);
#endif


/* G-02f-270 L3 path IO */
#ifndef SHUX_LABI_PATH_IO_FROM_X
const char *asm_link_obj_skip_missing(const char *path) {
  if ((path ==NULL)) {
    return NULL;
  }
  (void)(({   {
    if (((path)[0] ==0)) {
      return NULL;
    }
    if ((shux_path_is_nonempty_regular_file(path) ==0)) {
      return NULL;
    }
    return path;
  }
 }));
  return NULL;
}
#else
const char *asm_link_obj_skip_missing(const char *path);
#endif


/* F-06 v1 前向声明：invoke_cc 按需链入 heap.o 时复用 ASM 后端检测逻辑 */
int link_abi_user_o_needs_std_heap_api(const char *user_o);
int link_abi_user_o_needs_heap_user_syms(const char *user_o);
int link_abi_user_o_needs_async_scheduler(const char *user_o);
int link_abi_link_needs_std_heap_import(const char *user_o, const char **argv, int la);
int link_abi_link_needs_std_heap_import(const char *user_o, const char **argv, int la);

/* ============================================================================
 * User-specified .o files from command line (single authority, G.3/G.4 / G.7).
 *
 * Why: `shux -o exe file.x extra.o` drops extra.o because:
 *   - C path: shux_invoke_cc takes a fixed variadic list of std/core .o paths
 *   - ASM path: shux_invoke_ld_for_exe only receives the temp user object, not
 *     CLI extra .o (e.g. runtime_atomic_glue.o, runtime_time_os.o)
 * Authority: this global + setter/clearer is the SINGLE path for user .o files
 *   to reach BOTH link lines (cc and asm ld). Historical name says "cc" but
 *   G.7 forbids a second parallel table — asm ld consumes the same globals.
 * Callers wrap invoke_cc OR invoke_ld with set/clear:
 *     shux_invoke_cc_set_user_o_files_from_argv(argc, argv);
 *     shux_invoke_cc(...)  OR  shux_invoke_ld_for_exe(...);
 *     shux_invoke_cc_clear_user_o_files();
 * Invariant: g_shux_n_user_extra_o_files == 0 means no user .o (safe default).
 * PLATFORM: SHARED — argv is plain char**; macOS/Linux/Windows.
 * ========================================================================== */
#define SHUX_USER_EXTRA_O_FILES_MAX 32
static const char *g_shux_user_extra_o_files[SHUX_USER_EXTRA_O_FILES_MAX];
static int g_shux_n_user_extra_o_files = 0;

/**
 * Append CLI user .o paths (g_shux_user_extra_o_files) onto an asm ld argv.
 * PLATFORM: SHARED — same authority as invoke_cc push loop; skip unreadable paths.
 * Call immediately before terminating argv with NULL on every asm ld branch.
 */
static void shux_asm_ld_append_user_extra_o_files(const char **argv, int *la, int max_la) {
    int ui;
    if (!argv || !la)
        return;
    for (ui = 0; ui < g_shux_n_user_extra_o_files; ui++) {
        const char *p = g_shux_user_extra_o_files[ui];
        if (!p || !p[0])
            continue;
        if (*la >= max_la - 1)
            break;
        if (access(p, R_OK) != 0)
            continue;
        argv[(*la)++] = p;
    }
}

/* Extract .o file args from argv. Skips options (-o/-L/-I/-target/-backend/-O
 * and their value), -D<def>, --<flag>, and any arg not ending in ".o".
 * Stores up to SHUX_USER_EXTRA_O_FILES_MAX pointers (no copy; argv lifetime
 * must cover the subsequent shux_invoke_cc call). Resets state first. */
void shux_invoke_cc_set_user_o_files_from_argv(int argc, char **argv) {
    int i;
    g_shux_n_user_extra_o_files = 0;
    if (!argv)
        return;
    for (i = 1; i < argc; i++) {
        const char *a = argv[i];
        size_t len;
        if (!a || !a[0])
            continue;
        if (a[0] == '-') {
            /* Two-token options: skip the value arg too. */
            if ((!strcmp(a, "-o") || !strcmp(a, "-L") || !strcmp(a, "-I") ||
                 !strcmp(a, "-target") || !strcmp(a, "-backend") ||
                 !strcmp(a, "-O") || !strcmp(a, "-opt")) && i + 1 < argc) {
                i++; /* consume value */
            }
            continue;
        }
        len = strlen(a);
        if (len >= 2 && a[len - 2] == '.' && a[len - 1] == 'o') {
            if (g_shux_n_user_extra_o_files < SHUX_USER_EXTRA_O_FILES_MAX) {
                g_shux_user_extra_o_files[g_shux_n_user_extra_o_files++] = a;
            }
        }
    }
}

/* Reset user .o state. Call after shux_invoke_cc to prevent stale pointers. */
void shux_invoke_cc_clear_user_o_files(void) {
    g_shux_n_user_extra_o_files = 0;
}

/**
 * 调用系统 cc 将多个 C 文件编译链接为可执行文件（fork/exec + 可选 strip）。
 * 参数：c_paths/n 源文件；各 *_o 可选 std/core .o；include_root 用于 -I 与按需 .o 解析。
 * 返回值：0 成功，-1 失败。
 */
int shux_invoke_cc_impl(const char **c_paths, int n, const char *out_path, const char *target, const char *opt_level, int use_lto, const char *io_o, const char *fs_o, const char *process_o, const char *string_o, const char *heap_o, const char *path_o, const char *runtime_o, const char *runtime_panic_o, const char *net_o, const char *thread_o, const char *time_o, const char *random_o, const char *env_o, const char *sync_o, const char *encoding_o, const char *base64_o, const char *crypto_o, const char *log_o, const char *atomic_o, const char *channel_o, const char *backtrace_o, const char *hash_o, const char *math_o, const char *sort_o, const char *ffi_o, const char *db_o, const char *elf_o, const char *json_o, const char *csv_o, const char *regex_o, const char *compress_o, const char *unicode_o, const char *dynlib_o, const char *http_o, const char *tar_o, const char *simd_o, const char *context_o, const char *datetime_o, const char *uuid_o, const char *url_o, const char *cli_o, const char *security_o, const char *config_o, const char *cache_o, const char *trace_o, const char *task_o, const char *schema_o, const char *test_o, const char *include_root, const char *async_scheduler_o) {
    (void)target;
    (void)json_o;
    (void)csv_o;
    (void)log_o;
    /* #region debug-point B:invoke-cc-enter */
    shux_debug_hello_stage1_report("B", "runtime_link_abi.c:2954", "invoke_cc_enter", n, use_lto, (include_root && include_root[0]) ? 1 : 0);
    /* #endregion */
    if (!c_paths || n < 1) return -1;
    if (!opt_level || !*opt_level) opt_level = "2";
    if (include_root && include_root[0])
        ensure_std_net_o_auto_tls(include_root);
    /*
     * PLATFORM: SHARED — do NOT pre-ensure runtime_time_os.o merely because
     * std/time/time.o exists on a warm tree. That forced every pure rv/hello
     * C link (and Darwin paths that still hit invoke_cc) to rebuild time_os.
     * Authority: ensure only under need_time (below) + ASM PRIMARY/on_demand
     * gated by labi_user_needs_runtime_time_os. G.7 complete existing need path.
     */
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    pid_t pid = 0;  /* Windows: 模拟 child 分支，直接构造 argv + _spawnvp */
#else
    pid_t pid = fork();
    if (pid < 0) {
        perror("fork");
        return -1;
    }
    if (pid == 0) {
        /* #region debug-point C:invoke-cc-child */
        shux_debug_hello_stage1_report("C", "runtime_link_abi.c:2978", "invoke_cc_child", n, use_lto, 0);
        /* #endregion */
        /* 静态链 shux_asm 子进程可能继承空 PATH，gcc 找不到 ld；显式补齐常见路径。 */
        (void)setenv("PATH", "/usr/local/bin:/usr/bin:/bin", 1);
#endif
        /* 容量须容纳：cc -O -std... [-DNDEBUG] [-flto] -o out [-I inc] + n 个 .c + 若干 .o + -pthread -lc + SHUX_CC_EXTRA(至多 8) + NULL */
        char *argv[SHUX_INVOKE_CC_MAX_C_FILES + 48];
        int i = 0;
        const int argv_cap = SHUX_INVOKE_CC_MAX_C_FILES + 48;
        argv[i++] = (char *)"cc";
        /* preamble 中 std_io_* / std_net_* 使用 C11 _Generic，须传 -std=gnu11（不能 -x c，否则 .o 会被当 C 源码编译） */
        argv[i++] = (char *)"-std=gnu11";
        /* `shux run` / bare `shux file.x`: compile in memory for direct exec, so
         * suppress the generated-C diagnostic noise (the preamble/codegen emit
         * trips -Wparentheses-equality etc.). Errors still surface; only warnings
         * (cc -w and linker -Wl,-w) are muted. PLATFORM: SHARED. */
        if (i + 2 < argv_cap && getenv("SHUX_RUN_QUIET")) {
            argv[i++] = (char *)"-w";
            argv[i++] = (char *)"-Wl,-w";
        }
#if defined(__linux__)
        if (i < argv_cap - 1)
            argv[i++] = (char *)"-B/usr/bin";
#endif
        {
            static char oopt_buf[8];
            (void)snprintf(oopt_buf, sizeof(oopt_buf), "-O%s", opt_level);
            argv[i++] = oopt_buf;
            /* 极致性能：-O3 时加 march=native mtune=native；-O2 时加 march=native；CI/Docker 跳过。 */
            if (!invoke_cc_skip_native_tuning() && (strcmp(opt_level, "3") == 0 || strcmp(opt_level, "2") == 0)) {
                argv[i++] = (char *)"-march=native";
                if (strcmp(opt_level, "3") == 0)
                    argv[i++] = (char *)"-mtune=native";
            }
        }
        /* 阶段 8：非调试时传 -DNDEBUG；-flto 便于跨模块内联（2.3 构建与链接） */
        if (strcmp(opt_level, "0") != 0)
            argv[i++] = (char *)"-DNDEBUG";
        if (use_lto && strcmp(opt_level, "0") != 0 && !invoke_cc_skip_native_tuning())
            argv[i++] = (char *)"-flto";
#if defined(__linux__)
        /* P1-7：release 可执行文件默认 PIE + NX + RELRO（与 asm 链接路径一致）。 */
        if (strcmp(opt_level, "0") != 0)
            shux_append_linux_link_harden(argv, &i, argv_cap);
#endif
        argv[i++] = (char *)"-o";
        argv[i++] = (char *)out_path;
        /*
         * 死代码剥离：preamble / co-emit 常带 std_io_*_ctx / read_batch 等「可能用」体，
         * 其 U 引用 context/error/driver；hello 与 io.print 等未调用路径须 GC 掉，
         * 否则会假依赖链 context.o→atomic，或直接 ld UNDEF（bstrict27 run-io）。
         *
         * 【Invariant】与 freestanding asm / std 模块编译同权威：
         *   - 编译：-ffunction-sections -fdata-sections（每函数独立 section）
         *   - 链接：--gc-sections / Darwin -dead_strip（从 main 可达性剔除）
         * 仅传 --gc-sections 而无 function-sections 时，整块 .text 要么全留要么
         * （偶发）全丢；io 的 print 落在 .text 会拖死整段 U，hello 因全内联进
         * .text.startup 才碰巧绿。二者必须成对，禁止只加链接侧 GC。
         */
        if (i < argv_cap - 2) {
            argv[i++] = (char *)"-ffunction-sections";
            argv[i++] = (char *)"-fdata-sections";
        }
#if defined(__APPLE__)
        if (i < argv_cap - 1)
            argv[i++] = (char *)"-Wl,-dead_strip";
#elif defined(__linux__)
        if (i < argv_cap - 1)
            argv[i++] = (char *)"-Wl,--gc-sections";
#endif
        if (include_root && include_root[0]) {
            argv[i++] = (char *)"-I";
            argv[i++] = (char *)include_root;
        }
        for (int j = 0; j < n && i < SHUX_INVOKE_CC_MAX_C_FILES + 8; j++)
            argv[i++] = (char *)c_paths[j];
        {
            int needs_core_builtin = 0;
            int needs_core_mem = 0;
            int needs_core_slice = 0;
            int needs_db_kv = 0;
            int needs_db_arrow = 0;
            int needs_fs = 0;
            int needs_random = 0;
            int needs_time = 0;
            int needs_runtime = 0;
            int needs_win32 = 0;
            int needs_win32_wsa = 0;
            int needs_libc_heap = 0;
            for (int j = 0; j < n; j++) {
                if (link_abi_generated_c_needs_core_builtin(c_paths[j]))
                    needs_core_builtin = 1;
                if (link_abi_generated_c_needs_core_mem(c_paths[j]))
                    needs_core_mem = 1;
                if (link_abi_generated_c_needs_core_slice(c_paths[j]))
                    needs_core_slice = 1;
                if (link_abi_generated_c_needs_db_kv(c_paths[j]))
                    needs_db_kv = 1;
                if (link_abi_generated_c_needs_db_arrow(c_paths[j]))
                    needs_db_arrow = 1;
                if (link_abi_generated_c_needs_fs(c_paths[j]))
                    needs_fs = 1;
                if (link_abi_generated_c_needs_random(c_paths[j]))
                    needs_random = 1;
                if (link_abi_generated_c_needs_time(c_paths[j]))
                    needs_time = 1;
                if (link_abi_generated_c_needs_runtime(c_paths[j]))
                    needs_runtime = 1;
                if (link_abi_generated_c_needs_win32(c_paths[j]))
                    needs_win32 = 1;
                if (link_abi_generated_c_needs_win32_wsa(c_paths[j]))
                    needs_win32_wsa = 1;
                if (link_abi_generated_c_needs_libc_heap(c_paths[j]))
                    needs_libc_heap = 1;
            }
            if (needs_core_builtin) {
                const char *abi_h = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_abi_h());
                if (abi_h && abi_h[0]) {
                    if (i < argv_cap - 2) {
                        argv[i++] = (char *)"-include";
                        argv[i++] = (char *)abi_h;
                    }
                }
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_o()));
            }
            if (needs_core_mem)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
            if (needs_core_slice)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_slice_o()));

            if (needs_db_kv) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_db_kv_o()));
                {
                    const char *rkv = shux_runtime_kv_mmap_glue_o_path(NULL);
                    if (rkv && rkv[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rkv);
                }
            }
            if (needs_db_arrow) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_db_arrow_o()));
                {
                    const char *rar = shux_runtime_arrow_simd_glue_o_path(NULL);
                    if (rar && rar[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rar);
                }
            }
            if (needs_fs) {
#if defined(__linux__) || defined(__APPLE__)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-lc";
#endif
            }
            if (needs_random) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, random_o);
                {
                    /* PLATFORM: SHARED — random_fill_bytes_c 在 runtime_random_fill.o。
                     * 此 early 路径会先 push random.o；若仅 push_existing glue 而不 ensure，
                     * L4 冷树缺 .o 时 silent skip，且下方 need_random 因去重 push 返回 0
                     * 永远进不了 ensure → UNDEF random_fill_bytes_c（mac/Ubuntu 同）。
                     * 权威：链 random 必先 ensure 再 push fill。 */
                    (void)shux_ensure_runtime_random_fill_o(NULL);
                    const char *rrf = shux_runtime_random_fill_o_path(NULL);
                    if (rrf && rrf[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rrf);
                }
#if defined(_WIN32) || defined(_WIN64)
                /* 【Why 根源】runtime_random_fill.inc 在 Windows 用 BCryptGenRandom/BCryptOpenAlgorithmProvider，
                 * MinGW 不自动链 bcrypt；needs_random 路径须显式加 -lbcrypt，与下方 random_o 存在性路径对齐。
                 * 【Invariant】仅 Windows 需 -lbcrypt；Linux/macOS 走 getrandom/getentropy。 */
                if (i < argv_cap - 1)
                    argv[i++] = (char *)labi_ld_flag_lbcrypt();
#endif
            }
            if (needs_time) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, time_o);
                {
                    /* PLATFORM: SHARED — 同 needs_random：early push 后 ensure，防 L4 冷缺 time_os。 */
                    (void)shux_ensure_runtime_time_os_o(NULL);
                    const char *rto = shux_runtime_time_os_o_path(NULL);
                    if (rto && rto[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rto);
                }
            }
            if (needs_runtime) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_o);
                /* PLATFORM: SHARED — L4 冷树可无 runtime_panic.o；仅 push_existing 会静默跳过 → UNDEF shux_panic_。 */
                (void)shux_ensure_runtime_panic_o(NULL);
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_panic_o);
                {
                    const char *rp = shux_runtime_panic_o_path(NULL);
                    if (rp && rp[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rp);
                }
            }
            if (needs_win32) {
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-lkernel32";
#endif
            }
            if (needs_win32_wsa) {
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)labi_ld_flag_lws2_32();
#endif
            }
            if (needs_libc_heap) {
#if defined(__linux__) || defined(__APPLE__)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-lc";
#endif
            }
        }
        /* CORE-009 / Docker musl：仅链已按需推入的 core/*.o + -lc；shux_process_* 由生成 C weak 定义。
         * 【Why 根源】Windows codegen 生成 extern 声明（非 weak 定义），minimal 链须显式链入
         * runtime_process_argv.o 提供 shux_process_argc/argv 定义，否则链接报 undefined reference。
         * Linux/macOS 仍由生成 C 的 weak 定义提供默认值（minimal 链不链 runtime_process_argv.o）。 */
        if (getenv("SHUX_MINIMAL_CC_LINK")) {
#if defined(_WIN32) || defined(_WIN64)
            {
                const char *rpav = shux_runtime_process_argv_o_path(NULL);
                if (rpav && rpav[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rpav);
            }
#endif
#if defined(__linux__) || defined(__APPLE__)
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-lc";
#endif
            if (i < argv_cap)
                argv[i++] = NULL;
#if defined(__linux__)
            argv[0] = (char *)"gcc";
            execvp("gcc", argv);
            argv[0] = (char *)"cc";
            execvp("cc", argv);
            argv[0] = (char *)"/usr/bin/gcc";
            execv("/usr/bin/gcc", argv);
            argv[0] = (char *)"/usr/bin/cc";
            execv("/usr/bin/cc", argv);
        argv[0] = (char *)"/usr/local/bin/gcc";
        execv("/usr/local/bin/gcc", argv);
        argv[0] = (char *)"/usr/local/bin/cc";
        execv("/usr/local/bin/cc", argv);
#else
            argv[0] = (char *)"cc";
            execvp("cc", argv);
            argv[0] = (char *)"gcc";
            execvp("gcc", argv);
#endif
            perror("cc/gcc");
            _exit(127);
        }
        /*
         * 【权威】std/*.o 仅在生成 C 真正引用「模块 API」时链入。
         * 禁止裸前缀 std_net_/std_context_/std_string_：rt_preamble 恒注入类型/宏/extern，
         * hello 也会假阳性 → 链 net.o/context.o → 再拖 thread/atomic（与用户无关）。
         * 针脚与 ASM 路径 link_abi_user_o_needs_std_net 等同权威（具体 API 名）。
         * 配合上方 -dead_strip/--gc-sections：co-emit 的未引用 io_ctx 体不迫使链 context。
         */
        {
            int need_process = 0, need_string = 0, need_path = 0, need_runtime = 0;
            /* preamble weak process_args_* 转发 process_shux_*_get；export_dynamic（backtrace）
             * 等会保活 weak → 须链 runtime_process_argv.o（或 process.o 已含 glue）。 */
            int need_process_argv_glue = 0;
            int need_net = 0, need_thread = 0, need_time = 0, need_random = 0, need_env = 0;
            int need_sync = 0, need_encoding = 0, need_base64 = 0, need_crypto = 0;
            int need_log = 0, need_atomic = 0, need_channel = 0, need_backtrace = 0;
            int need_hash = 0, need_math = 0, need_sort = 0, need_vec = 0, need_ffi = 0, need_db = 0;
            int need_elf = 0, need_json = 0, need_csv = 0, need_regex = 0, need_compress = 0, need_unicode = 0;
            int need_dynlib = 0, need_http = 0, need_tar = 0, need_simd = 0, need_context = 0;
            int need_error = 0, need_datetime = 0, need_uuid = 0, need_url = 0, need_cli = 0;
            int need_security = 0, need_config = 0, need_cache = 0, need_trace = 0;
            int need_task = 0, need_schema = 0, need_test = 0, need_socketio = 0;
            int need_set = 0, need_map = 0, need_queue = 0;
            int need_panic = 0;
            /* 使用 use_line：忽略 preamble 的 extern/#define 行，只认真实引用 */
            static const char *net_api[] = {
                "std_net_listen", "std_net_connect", "std_net_udp_bind", "std_net_udp_recv",
                "std_net_udp_send", "std_net_addr_to_u32", "std_net_close_udp",
                "net_tcp_connect_c", "net_tcp_listen_c", "net_udp_bind_c",
                "net_udp_recv_many_buf_c", "net_udp_send_many_buf_c",
                "net_udp_send_c", "net_dns_resolve_c", "net_sock_create_c",
                "net_stream_write_batch_c", "net_close_socket_c_real",
                "net_run_accept_workers_c_real"
            };
            /* string：用 std_string_ 前缀 + use_line（已跳过 struct/typedef/extern/placeholder） */
            static const char *context_api[] = {
                "std_context_background(", "std_context_with_cancel(",
                "std_context_with_deadline(", "std_context_with_timeout(",
                "std_context_cancel(", "std_context_set_value(",
                "std_context_get_value(", "std_context_free(",
                "std_context_is_cancelled(", "std_context_deadline_ns(",
                "std_context_remaining_ns("
            };
            static const char *crypto_api[] = {
                "std_crypto_", "core_crypto_mem_eq", "core_crypto_sha",
                "crypto_sha", "ed25519_"
            };
            int jscan;
            for (jscan = 0; jscan < n; jscan++) {
                const char *cp = c_paths[jscan];
                if (!cp)
                    continue;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_process_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "shux_process_spawn") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "shux_process_wait") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "process_spawn") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "process_exec"))
                    need_process = 1;
                /*
                 * PLATFORM: SHARED — process_argv glue only on real use_line.
                 * Do NOT bare-substr process_shux_*: rt_preamble always injects weak
                 * process_args_* → process_shux_* (pure rv/hello false positive →
                 * every -o ensure runtime_process_argv.o). use_line skips weak stubs
                 * (see link_abi_generated_c_contains_substr_use_line). Transitive U
                 * from pushed std/*.o: post-module scan below (asm path complement).
                 * G.7: complete need_process_argv_glue; no second always-on ensure.
                 */
                if (link_abi_generated_c_contains_substr_use_line(cp, "process_shux_argc_get") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "process_shux_argv_get") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "process_args_count_c") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "process_arg_c") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "args_iter_count_c") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "args_iter_at_c") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_process_args") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_env_args_iter"))
                    need_process_argv_glue = 1;
                /* std_string_* API 或 string.o 内 bare C 辅助（vec_add_verify 等直接 extern shux_string_memcmp_c） */
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_string_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "shux_string_"))
                    need_string = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_path_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "path_join") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "path_dirname"))
                    need_path = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_runtime_"))
                    need_runtime = 1;
                if (link_abi_generated_c_contains_any_substr_use_line(cp, net_api, (int)(sizeof net_api / sizeof net_api[0])))
                    need_net = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_thread_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "thread_create_c") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "thread_join_c"))
                    need_thread = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_time_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "time_now_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "time_sleep_"))
                    need_time = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_random_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "random_fill_"))
                    need_random = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_env_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "env_get_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "env_set_"))
                    need_env = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_sync_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "sync_mutex_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "sync_rwlock_"))
                    need_sync = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_encoding_"))
                    need_encoding = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_base64_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "base64_encode") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "base64_decode"))
                    need_base64 = 1;
                if (link_abi_generated_c_contains_any_substr_use_line(cp, crypto_api, (int)(sizeof crypto_api / sizeof crypto_api[0])))
                    need_crypto = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_log_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "log_write_c") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "log_info_"))
                    need_log = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_atomic_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "atomic_load_i32_c") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "atomic_store_i32_c") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "atomic_fetch_"))
                    need_atomic = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_channel_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "channel_send") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "channel_recv"))
                    need_channel = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_backtrace_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "backtrace_capture"))
                    need_backtrace = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_hash_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "hash_fnv") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "hash_sip"))
                    need_hash = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_math_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "math_sin") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "math_cos"))
                    need_math = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_sort_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "sort_i32") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "sort_stable"))
                    need_sort = 1;
                /* PLATFORM: SHARED — std.vec is link_only; user C has extern + calls only.
                 * Ignore weak preamble std_vec_len_empty / placeholder lines (use_line). */
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_vec_new") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_vec_push") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_vec_len_Vec") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_vec_len_ptr") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_vec_with_capacity") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_vec_from_slice") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_vec_append") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_vec_reserve") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_vec_clear") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_vec_free"))
                    need_vec = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_ffi_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "ffi_call"))
                    need_ffi = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_db_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "sqlite3_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "db_sqlite_"))
                    need_db = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_elf_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "elf_parse"))
                    need_elf = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_json_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "json_parse_"))
                    need_json = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_csv_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "csv_next_field"))
                    need_csv = 1;
                /* set/map：link_only 后用户 C 仅有 extern/call；按需链预编 .o */
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_set_"))
                    need_set = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_map_"))
                    need_map = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_queue_"))
                    need_queue = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_regex_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "regex_match"))
                    need_regex = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_compress_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "compress_gzip") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "compress_zstd") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "compress_brotli"))
                    need_compress = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_unicode_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "unicode_utf8"))
                    need_unicode = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_dynlib_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "dynlib_open"))
                    need_dynlib = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_http_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "http_request") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "http2_"))
                    need_http = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_tar_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "tar_open") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "tar_extract"))
                    need_tar = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_simd_"))
                    need_simd = 1;
                /*
                 * context：use_line 会命中 co-emit 的 std_io_timeout_from_ctx 体内
                 * std_context_is_cancelled 调用；靠 -dead_strip 去掉未引用体后，
                 * 若仍 need 链 context 会拖 atomic。策略：仅用户入口 API 触发 need；
                 * io 体里的 is_cancelled/deadline/remaining 不单独成 need（依赖 GC）。
                 */
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_context_background(") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_context_with_cancel(") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_context_with_deadline(") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_context_with_timeout(") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_context_cancel(") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_context_set_value(") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_context_get_value(") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_context_free("))
                    need_context = 1;
                (void)context_api; /* 文档表；入口 API 已逐条 use_line */
                /* 含 std_error_ok / chain_* / is_* 等；勿只扫 new/format（tests/error 用 ok） */
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_error_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "error_wrap_"))
                    need_error = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_datetime_"))
                    need_datetime = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_uuid_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "uuid_v4") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "uuid_parse"))
                    need_uuid = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_url_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "url_parse") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "url_join"))
                    need_url = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_cli_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "cli_parse"))
                    need_cli = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_security_"))
                    need_security = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_config_"))
                    need_config = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_cache_"))
                    need_cache = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_trace_"))
                    need_trace = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_task_"))
                    need_task = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_schema_"))
                    need_schema = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_test_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "test_call_"))
                    need_test = 1;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_socketio_") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "socketio_emit") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "socketio_on"))
                    need_socketio = 1;
                /* panic：co-emit 已有 void shux_panic_(...) 体则不链 panic.o */
                if (link_abi_generated_c_contains_substr_use_line(cp, "shux_panic_(") &&
                    !link_abi_generated_c_contains_substr(cp, "void shux_panic_(int has_msg, int msg_val) {") &&
                    !link_abi_generated_c_contains_substr(cp, "void shux_panic_(int has_msg, int msg_val){"))
                    need_panic = 1;
            }
            /* co-emit 已有函数体时勿再链同模块 .o（防 duplicate）。anchor 体 = co-emit 标志。 */
            if (need_string) {
                int has = 0;
                for (jscan = 0; jscan < n; jscan++)
                    if (link_abi_generated_c_contains_substr(c_paths[jscan], "std_string_string_module_anchor(void) {") ||
                        link_abi_generated_c_contains_substr(c_paths[jscan], "int32_t std_string_new("))
                        has = 1;
                /* string 常部分 co-emit；只要引用就链 string.o（.o 与部分 T 若冲突再另修） */
                (void)has;
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, string_o);
            }
            {
                int pushed_process_o = 0;
                if (need_process && invoke_cc_argv_push_existing(argv, &i, argv_cap, process_o)) {
                    pushed_process_o = 1;
#if defined(__linux__)
                    if (i < argv_cap - 1)
                        argv[i++] = (char *)"-pthread";
#endif
                }
                /* process.o 已 ld -r 含 argv glue；否则链 runtime_process_argv.o（constructor 绑 CRT argc）。
                 * need_process 但 process.o 缺失时也必须推 glue，否则 co-emit 的 process_shux_argc_get
                 * 只读 BSS=0 → args_count()<1（bstrict31 run-process args）。
                 * 禁止 process.o + runtime_process_argv.o 双链（process_shux_* 强符号重复）。 */
                if (!pushed_process_o && (need_process || need_env || need_process_argv_glue)) {
                    (void)shux_ensure_runtime_process_argv_o(NULL);
                    {
                        const char *rpa = shux_runtime_process_argv_o_path(NULL);
                        if (rpa && rpa[0])
                            (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rpa);
                    }
                }
            }
            if (heap_o && heap_o[0])
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, heap_o);
            if (need_path)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, path_o);
            if (need_runtime)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_o);
            /* PLATFORM: SHARED — need_panic 时必须 ensure 再建链；cold 缺 .o 时 push_existing 静默 skip
             * 会 UNDEF shux_panic_（run-panic L4）。path 可能为空串（文件尚不存在），ensure 后再取 path。 */
            if (need_panic || need_runtime) {
                (void)shux_ensure_runtime_panic_o(NULL);
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_panic_o);
                {
                    const char *rp = shux_runtime_panic_o_path(NULL);
                    if (rp && rp[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rp);
                }
            }
            if (need_net && invoke_cc_argv_push_existing(argv, &i, argv_cap, net_o)) {
                (void)invoke_cc_append_net_tls_ld(argv, &i, argv_cap, net_o, include_root);
                (void)shux_ensure_runtime_net_udp_batch_o(NULL);
                {
                    const char *rnub = shux_runtime_net_udp_batch_o_path(NULL);
                    if (rnub && rnub[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rnub);
                }
                (void)shux_ensure_runtime_net_workers_o(NULL);
                {
                    const char *rnw = shux_runtime_net_workers_o_path(NULL);
                    if (rnw && rnw[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rnw);
                }
                /*
                 * workers.x → U thread_create_c / thread_join_c（net.o 内，非用户 C use_line）。
                 * 与 asm on_demand（labi 在 have_net 后推 thread）同权威：C 后端链 net 时亦 need_thread。
                 */
                need_thread = 1;
#if defined(__linux__)
                {
                    (void)shux_ensure_runtime_asm_io_stubs_o(NULL);
                    const char *ris = shux_runtime_asm_io_stubs_o_path(NULL);
                    if (ris && ris[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, ris);
                }
#endif
#if defined(_WIN32) || defined(_WIN64)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)labi_ld_flag_lws2_32();
#endif
            }
            /* PLATFORM: SHARED — ensure glue before push_existing (cold tree may lack .o). */
            if (need_thread && invoke_cc_argv_push_existing(argv, &i, argv_cap, thread_o)) {
                (void)shux_ensure_runtime_thread_glue_o(NULL);
                {
                    const char *rtg = shux_runtime_thread_glue_o_path(NULL);
                    if (rtg && rtg[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rtg);
                }
            }
            /* PLATFORM: SHARED — push 与 ensure 解耦：needs_* early 路径已 push 时
             * invoke_cc_argv_push_existing 因去重返回 0，不得跳过 glue ensure。
             * L4 wipe: formal time.o is gitignored; push_existing alone silent-skips
             * → U std_time_* (tests/time). G.7: complete need_time like need_math/env. */
            if (need_time) {
                if (include_root && include_root[0])
                    (void)shux_ensure_formal_std_make_o(include_root, "std/time/time.o",
                                                        "../std/time/time.o");
                {
                    const char *time_push = shux_rel_o_path_from_argv0(include_root, "std/time/time.o");
                    if ((!time_push || !time_push[0]) && time_o && time_o[0])
                        time_push = time_o;
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, time_push);
                }
                (void)shux_ensure_runtime_time_os_o(NULL);
                {
                    const char *rto = shux_runtime_time_os_o_path(NULL);
                    if (rto && rto[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rto);
                }
            }
            if (need_random) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, random_o);
                (void)shux_ensure_runtime_random_fill_o(NULL);
                {
                    const char *rrf = shux_runtime_random_fill_o_path(NULL);
                    if (rrf && rrf[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rrf);
                }
#if defined(_WIN32) || defined(_WIN64)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)labi_ld_flag_lbcrypt();
#endif
            }
            if (need_env) {
                /* mod.x co-emit 提供 std_env_*；env.o 可选。argv glue 已在上方统一推入。 */
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, env_o);
                (void)shux_ensure_runtime_env_os_o(NULL);
                {
                    const char *reo = shux_runtime_env_os_o_path(NULL);
                    if (reo && reo[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, reo);
                }
            }
            /* PLATFORM: SHARED — cold tree often lacks runtime_sync_*.o; push_existing alone
             * is a silent no-op when missing → U sync_mutex_*_c from sync.o (mac bstrict).
             * Authority: ensure (same as process_argv / net glue) then push. */
            if (need_sync && invoke_cc_argv_push_existing(argv, &i, argv_cap, sync_o)) {
                (void)shux_ensure_runtime_sync_lock_diag_tls_o(NULL);
                {
                    const char *rsld = shux_runtime_sync_lock_diag_tls_o_path(NULL);
                    if (rsld && rsld[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rsld);
                }
                (void)shux_ensure_runtime_sync_os_o(NULL);
                {
                    const char *rso = shux_runtime_sync_os_o_path(NULL);
                    if (rso && rso[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rso);
                }
            }
            if (need_encoding)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, encoding_o);
            if (need_base64)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, base64_o);
            if (need_crypto) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, crypto_o);
                (void)shux_ensure_runtime_ed25519_ref10_glue_o(NULL);
                {
                    const char *red = shux_runtime_ed25519_ref10_glue_o_path(NULL);
                    if (red && red[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, red);
                }
                (void)shux_ensure_runtime_crypto_inc_glue_o(NULL);
                {
                    const char *rci = shux_runtime_crypto_inc_glue_o_path(NULL);
                    if (rci && rci[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rci);
                }
            }
            if (need_log && invoke_cc_argv_push_existing(argv, &i, argv_cap,
                    shux_rel_o_path_from_argv0(include_root, labi_icc_rel_log_o()))) {
                (void)shux_ensure_runtime_log_os_o(NULL);
                {
                    const char *rlo = shux_runtime_log_os_o_path(NULL);
                    if (rlo && rlo[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rlo);
                }
            }
            /* PLATFORM: SHARED — mac cold bstrict: U atomic_*_c from atomic.o when
             * runtime_atomic_glue.o missing; ensure then push (same as channel/sync). */
            if (need_atomic && invoke_cc_argv_push_existing(argv, &i, argv_cap, atomic_o)) {
                (void)shux_ensure_runtime_atomic_glue_o(NULL);
                {
                    const char *rag = shux_runtime_atomic_glue_o_path(NULL);
                    if (rag && rag[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rag);
                }
            }
            if (need_channel) {
                /* marker channel.o 可选；API 由 co-emit mod.x，实现由 runtime_channel_glue.o */
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, channel_o);
                (void)shux_ensure_runtime_channel_glue_o(NULL);
                {
                    const char *rcg = shux_runtime_channel_glue_o_path(NULL);
                    if (rcg && rcg[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rcg);
                }
            }
            if (need_backtrace) {
                /* marker backtrace.o 可选；API 由 co-emit mod.x，平台由 runtime_backtrace_platform.o */
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, backtrace_o);
                (void)shux_ensure_runtime_backtrace_platform_o(NULL);
                {
                    const char *rbp = shux_runtime_backtrace_platform_o_path(NULL);
                    if (rbp && rbp[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rbp);
                }
#if defined(__linux__)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-rdynamic";
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-ldl";
#elif defined(__APPLE__)
                if (i < argv_cap - 2)
                    argv[i++] = (char *)"-Wl,-export_dynamic";
#elif defined(_WIN32) || defined(_WIN64)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-ldbghelp";
#endif
            }
            if (need_hash)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, hash_o);
            /* PLATFORM: SHARED — L4 wipe removes formal math.o; ensure before push.
             * math_o is resolved at invoke entry via shux_rel_o_path_from_argv0; when the
             * file is missing that returns "" and stays empty for the whole invoke.
             * After ensure, re-resolve (same as need_vec/set/map) — do not push stale math_o. */
            if (need_math) {
                if (include_root && include_root[0])
                    (void)shux_ensure_formal_std_make_o(include_root, "std/math/math.o", "../std/math/math.o");
                {
                    const char *math_push = shux_rel_o_path_from_argv0(include_root, "std/math/math.o");
                    if ((!math_push || !math_push[0]) && math_o && math_o[0])
                        math_push = math_o;
                    if (invoke_cc_argv_push_existing(argv, &i, argv_cap, math_push)) {
                        (void)shux_ensure_runtime_math_libm_o(NULL);
                        {
                            const char *rml = shux_runtime_math_libm_o_path(NULL);
                            if (rml && rml[0])
                                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rml);
                        }
                        if (i < argv_cap - 1)
                            argv[i++] = (char *)"-lm";
                    }
                }
            }
            /* sort.o：仅当未 co-emit 实现时链入（co-emit 定义形如 void std_sort_sort_…） */
            if (need_sort) {
                int have_sort_body = 0;
                for (jscan = 0; jscan < n; jscan++) {
                    const char *cp = c_paths[jscan];
                    if (!cp)
                        continue;
                    if (link_abi_generated_c_contains_substr(cp, "void std_sort_sort_") != 0 ||
                        link_abi_generated_c_contains_substr(cp, "void std_sort_sort(") != 0) {
                        have_sort_body = 1;
                        break;
                    }
                }
                if (!have_sort_body)
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, sort_o);
            }
            /* PLATFORM: SHARED — vec.o authority for link_only std.vec (same as set/map).
             * Must key on *body* open-brace, not "int32_t std_vec_*(..." which matches
             * link_only extern prototypes and would skip the product .o (false co-emit).
             * Formal vec.o U: std_heap_default_alloc / kind_arena / alloc_Allocator_* /
             * realloc_Allocator_* — user C has no std_heap_* use_line, so mirror set/map and
             * push heap.o + core mem with vec.o (G.7 complete need_vec path).
             * L4 wipe: formal .o gitignored → ensure via Makefile before push_existing. */
            if (need_vec) {
                int have_vec_body = 0;
                for (jscan = 0; jscan < n; jscan++) {
                    const char *cp = c_paths[jscan];
                    if (!cp)
                        continue;
                    if (link_abi_generated_c_contains_substr(cp, "std_vec_new_retVec_u8(void) {") != 0 ||
                        link_abi_generated_c_contains_substr(cp, "std_vec_new_retVec_u8(void){") != 0 ||
                        link_abi_generated_c_contains_substr(cp, "std_vec_push_Vec_u8_ptr_u8(struct std_vec_Vec_u8 * v, uint8_t x) {") != 0 ||
                        link_abi_generated_c_contains_substr(cp, "std_vec_push_Vec_u8_ptr_u8(struct std_vec_Vec_u8 *v, uint8_t x){") != 0) {
                        have_vec_body = 1;
                        break;
                    }
                }
                if (!have_vec_body) {
                    int c_prov_cm_v = 0;
                    int c_prov_sh_v = 0;
                    for (jscan = 0; jscan < n; jscan++) {
                        const char *cp = c_paths[jscan];
                        if (!cp) continue;
                        if (link_abi_generated_c_provides_core_mem(cp)) c_prov_cm_v = 1;
                        if (link_abi_generated_c_provides_std_heap(cp)) c_prov_sh_v = 1;
                    }
                    if (include_root && include_root[0]) {
                        (void)shux_ensure_formal_std_make_o(include_root, "std/vec/vec.o", "../std/vec/vec.o");
                        if (!c_prov_sh_v) (void)shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
                        if (!c_prov_cm_v) (void)shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
                    }
                    if (invoke_cc_argv_push_existing(argv, &i, argv_cap,
                        shux_rel_o_path_from_argv0(include_root, "std/vec/vec.o"))) {
                        if (!c_prov_sh_v) (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                            shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
                        if (!c_prov_cm_v) (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                            shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
                    }
                }
            }
            if (need_ffi)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, ffi_o);
            if (need_db && invoke_cc_argv_push_existing(argv, &i, argv_cap, db_o)) {
                (void)shux_ensure_runtime_sqlite_glue_o(NULL);
                {
                    const char *rsg = shux_runtime_sqlite_glue_o_path(NULL);
                    if (rsg && rsg[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rsg);
                }
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-lsqlite3";
            }
            if (need_elf)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, elf_o);
            if (need_json)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                    shux_rel_o_path_from_argv0(include_root, labi_icc_rel_json_o()));
            if (need_csv)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                    shux_rel_o_path_from_argv0(include_root, labi_icc_rel_csv_o()));
            /*
             * set.o U：std_heap_libc_heap_alloc_*_c / std_heap_map_find / std_hash_bytes。
             * 现有 heap_import 探针不含 *_i32_c 等符号，故 need_set 时显式链 heap+hash+mem。
             * L4 wipe: formal set/heap/mem via Makefile ensure before push.
             */
            if (need_set) {
                int c_prov_cm_s = 0, c_prov_sh_s = 0;
                for (jscan = 0; jscan < n; jscan++) {
                    const char *cp = c_paths[jscan];
                    if (!cp) continue;
                    if (link_abi_generated_c_provides_core_mem(cp)) c_prov_cm_s = 1;
                    if (link_abi_generated_c_provides_std_heap(cp)) c_prov_sh_s = 1;
                }
                if (include_root && include_root[0]) {
                    (void)shux_ensure_formal_std_make_o(include_root, "std/set/set.o", "../std/set/set.o");
                    if (!c_prov_sh_s) (void)shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
                    if (!c_prov_cm_s) (void)shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
                }
                if (invoke_cc_argv_push_existing(argv, &i, argv_cap,
                        shux_rel_o_path_from_argv0(include_root, "std/set/set.o"))) {
                    if (!c_prov_sh_s) (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
                    if (!c_prov_cm_s) (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, hash_o);
                }
            }
            if (need_map) {
                int c_prov_cm_m = 0, c_prov_sh_m = 0;
                for (jscan = 0; jscan < n; jscan++) {
                    const char *cp = c_paths[jscan];
                    if (!cp) continue;
                    if (link_abi_generated_c_provides_core_mem(cp)) c_prov_cm_m = 1;
                    if (link_abi_generated_c_provides_std_heap(cp)) c_prov_sh_m = 1;
                }
                if (include_root && include_root[0]) {
                    (void)shux_ensure_formal_std_make_o(include_root, "std/map/map.o", "../std/map/map.o");
                    if (!c_prov_sh_m) (void)shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
                    if (!c_prov_cm_m) (void)shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
                }
                if (invoke_cc_argv_push_existing(argv, &i, argv_cap,
                        shux_rel_o_path_from_argv0(include_root, "std/map/map.o"))) {
                    if (!c_prov_sh_m) (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
                    if (!c_prov_cm_m) (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
                }
            }
            if (need_queue && invoke_cc_argv_push_existing(argv, &i, argv_cap,
                    shux_rel_o_path_from_argv0(include_root, "std/queue/queue.o"))) {
                int c_prov_cm_q = 0, c_prov_sh_q = 0;
                for (jscan = 0; jscan < n; jscan++) {
                    const char *cp = c_paths[jscan];
                    if (!cp) continue;
                    if (link_abi_generated_c_provides_core_mem(cp)) c_prov_cm_q = 1;
                    if (link_abi_generated_c_provides_std_heap(cp)) c_prov_sh_q = 1;
                }
                if (!c_prov_sh_q) (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                    shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
                if (!c_prov_cm_q) (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                    shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
            }
            if (need_regex)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, regex_o);
            /* compress.o 仅 need_compress；库路径仍可按生成 C 的 zlib/zstd/brotli 引用按需 -l* */
            if (need_compress && invoke_cc_argv_push_existing(argv, &i, argv_cap, compress_o))
                invoke_cc_append_compress_ld(argv, &i, argv_cap, compress_o, NULL);
            else {
                int needs_zlib = 0, needs_zstd = 0, needs_brotli = 0, j;
                for (j = 0; j < n; j++) {
                    if (link_abi_generated_c_needs_zlib(c_paths[j]))
                        needs_zlib = 1;
                    if (link_abi_generated_c_needs_zstd(c_paths[j]))
                        needs_zstd = 1;
                    if (link_abi_generated_c_needs_brotli(c_paths[j]))
                        needs_brotli = 1;
                }
                if (needs_zlib || needs_zstd || needs_brotli) {
                    ld_append_brew_lib_paths((const char **)argv, &i, argv_cap);
                    if (needs_zlib && i < argv_cap - 1) {
                        argv[i++] = (char *)"-lz";
                        (void)shux_ensure_runtime_compress_zlib_glue_o(NULL);
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                            shux_runtime_compress_zlib_glue_o_path(NULL));
                    }
                    if (needs_zstd && i < argv_cap - 1)
                        argv[i++] = (char *)"-lzstd";
                    if (needs_brotli && i < argv_cap - 1) {
                        argv[i++] = (char *)"-lbrotlienc";
                        if (i < argv_cap - 1)
                            argv[i++] = (char *)"-lbrotlidec";
                    }
                }
            }
            /* unicode.o：co-emit mod+unicode.x 时勿再链，否则 std_unicode_unicode_* 双定义 */
            if (need_unicode) {
                int have_unicode_body = 0;
                for (jscan = 0; jscan < n; jscan++) {
                    const char *cp = c_paths[jscan];
                    if (!cp)
                        continue;
                    if (link_abi_generated_c_contains_substr(cp, "int32_t std_unicode_category(") != 0 ||
                        link_abi_generated_c_contains_substr(cp, "int32_t std_unicode_unicode_category(") != 0) {
                        have_unicode_body = 1;
                        break;
                    }
                }
                if (!have_unicode_body)
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, unicode_o);
            }
            if (need_dynlib && invoke_cc_argv_push_existing(argv, &i, argv_cap, dynlib_o)) {
                (void)shux_ensure_runtime_dynlib_os_o(NULL);
                {
                    const char *rdo = shux_runtime_dynlib_os_o_path(NULL);
                    if (rdo && rdo[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rdo);
                }
#if defined(__linux__)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-ldl";
#endif
            }
            if (need_http && invoke_cc_argv_push_existing(argv, &i, argv_cap, http_o)) {
                (void)shux_ensure_runtime_http_glue_o(NULL);
                {
                    const char *rhg = shux_runtime_http_glue_o_path(NULL);
                    if (rhg && rhg[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rhg);
                }
#if defined(_WIN32) || defined(_WIN64)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)labi_ld_flag_lws2_32();
#endif
                need_error = 1; /* http 依赖 error.o 符号 */
            }
            if (need_socketio)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                    shux_rel_o_path_from_argv0(include_root, labi_icc_rel_socketio_o()));
            if (need_tar)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, tar_o);
            if (need_simd)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, simd_o);
            if (need_context)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, context_o);
            if (need_error)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                    shux_rel_o_path_from_argv0(include_root, labi_icc_rel_error_o()));
            if (need_datetime)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, datetime_o);
            if (need_uuid)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, uuid_o);
            if (need_url)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, url_o);
            if (need_cli)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, cli_o);
            if (need_security)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, security_o);
            if (need_config)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, config_o);
            if (need_cache)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, cache_o);
            if (need_trace)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, trace_o);
            {
                const char *sched_link = async_scheduler_o;
                int j;
                int task_linked = 0;
                if (need_task)
                    task_linked = invoke_cc_argv_push_existing(argv, &i, argv_cap, task_o);
                if (need_schema)
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, schema_o);
                if (need_test && invoke_cc_argv_push_existing(argv, &i, argv_cap, test_o)) {
                    (void)shux_ensure_runtime_test_fn_invoke_o(NULL);
                    {
                        const char *rtfi = shux_runtime_test_fn_invoke_o_path(NULL);
                        if (rtfi && rtfi[0])
                            (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rtfi);
                    }
                }
                if (!sched_link) {
                    for (j = 0; j < n; j++) {
                        if (shux_generated_c_needs_async_scheduler(c_paths[j])) {
                            sched_link = shux_std_async_scheduler_o_path(include_root);
                            break;
                        }
                    }
                }
                if (task_linked) {
                    const char *sched = scheduler_o_for_task_link(task_o, sched_link);
                    if (invoke_cc_argv_push_existing(argv, &i, argv_cap, sched)) {
#if defined(__linux__)
                        if (i < argv_cap - 1)
                            argv[i++] = (char *)"-pthread";
#endif
                        (void)shux_ensure_runtime_scheduler_glue_o(NULL);
                        {
                            const char *rsg = shux_runtime_scheduler_glue_o_path(NULL);
                            if (rsg && rsg[0])
                                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rsg);
                        }
                    }
                } else if (sched_link && invoke_cc_argv_push_existing(argv, &i, argv_cap, sched_link)) {
#if defined(__linux__)
                    if (i < argv_cap - 1)
                        argv[i++] = (char *)"-pthread";
#endif
                    (void)shux_ensure_runtime_scheduler_glue_o(NULL);
                    {
                        const char *rsg = shux_runtime_scheduler_glue_o_path(NULL);
                        if (rsg && rsg[0])
                            (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rsg);
                    }
                }
            }
            /*
             * PLATFORM: SHARED — after std/*.o pushes, complement process_argv when any
             * linked .o has U process_shux_* (string/math/… preamble weak). Early gate
             * only sees user C use_line; formal .o U is invisible until push.
             * Same authority as asm post-on_demand scan. Skip if process.o already on line.
             * G.7: complete existing C-backend process_argv path; no second plan table.
             */
            {
                int need_pav = 0;
                int have_process_o = 0;
                int have_pav = 0;
                int ai;
                for (ai = 0; ai < i && argv[ai]; ai++) {
                    const char *e = argv[ai];
                    if (!e || e[0] == '-')
                        continue;
                    if (strstr(e, "process.o") && !strstr(e, "process_argv"))
                        have_process_o = 1;
                    if (strstr(e, "runtime_process_argv.o") || strstr(e, "process_argv.o"))
                        have_pav = 1;
                    if (shux_link_obj_needs_undef_sym(e, "process_shux_argc_get")
                        || shux_link_obj_needs_undef_sym(e, "process_shux_argv_get"))
                        need_pav = 1;
                }
                if (need_pav && !have_process_o && !have_pav) {
                    (void)shux_ensure_runtime_process_argv_o(NULL);
                    {
                        const char *rpa = shux_runtime_process_argv_o_path(NULL);
                        if (rpa && rpa[0])
                            (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rpa);
                    }
                }
            }
        }
        /* F-06 v1：heap.o 按需链入。
         * 【Why】① 已入链 std/*.o 的 U（nm）；② 用户生成 C 的真实引用（use_line）。
         * 仅扫 argv 会漏：C 后端是「源码直链」，此时用户 .c 尚未成 .o，nm 不可见。
         * link_only 后 tests/heap 仅有 extern std_heap_alloc_size_zero → 须②。 */
        {
            int need_heap_from_c = 0;
            int cj;
            if (link_abi_link_needs_std_heap_import(NULL, (const char **)argv, i))
                need_heap_from_c = 1;
            for (cj = 0; cj < n && !need_heap_from_c; cj++) {
                const char *cp = c_paths[cj];
                if (!cp)
                    continue;
                if (link_abi_generated_c_contains_substr_use_line(cp, "std_heap_alloc_size_zero") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_alloc_usize") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_default_alloc") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_kind_arena") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_heap_alloc") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_alloc_Allocator") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_realloc_Allocator") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_free_Allocator") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_arena64_alloc") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_map_find") ||
                    link_abi_generated_c_contains_substr_use_line(cp, "std_heap_libc_heap_alloc"))
                    need_heap_from_c = 1;
            }
            if (need_heap_from_c) {
                int c_provides_core_mem = 0;
                int c_provides_std_heap = 0;
                for (cj = 0; cj < n; cj++) {
                    if (link_abi_generated_c_provides_core_mem(c_paths[cj]))
                        c_provides_core_mem = 1;
                    if (link_abi_generated_c_provides_std_heap(c_paths[cj]))
                        c_provides_std_heap = 1;
                }
                if (!c_provides_core_mem) {
                    const char *mem_o_ondemand = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o());
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, mem_o_ondemand);
                }
                if (!c_provides_std_heap) {
                    const char *heap_o_ondemand = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o());
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, heap_o_ondemand);
                }
                /*
                 * PLATFORM: SHARED / LINUX gold — heap.o (mod.x) imports page_mmap and
                 * references std_heap_page_mmap_page_mmap_heap_{init,alloc,deinit,available,
                 * free} unconditionally (freestanding bump-heap path). On Ubuntu L4 cold the
                 * C backend pushes heap.o but NOT page_mmap.o, so the link fails with
                 * 'undefined reference to std_heap_page_mmap_page_mmap_heap_*'. Symmetric with
                 * the asm on-demand path (link_abi_user_o_needs_std_heap_page_mmap push of
                 * labi_od_rel_page_mmap). Also ensure + push runtime_asm_io_stubs.o which
                 * provides the weak shux_sys_mmap / shux_sys_munmap that page_mmap.o calls
                 * (same authority as the need_net block below for #if defined(__linux__)).
                 * Root fix 2026-07-19: backtrace L4 cold was red on Ubuntu only because the
                 * C backend heap chain missed page_mmap + asm_io_stubs companions.
                 */
                {
                    const char *pm_o = shux_rel_o_path_from_argv0(include_root, labi_od_rel_page_mmap());
                    if (invoke_cc_argv_push_existing(argv, &i, argv_cap, pm_o)) {
                        (void)shux_ensure_runtime_asm_io_stubs_o(NULL);
                        {
                            const char *ris = shux_runtime_asm_io_stubs_o_path(NULL);
                            if (ris && ris[0])
                                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, ris);
                        }
                    }
                }
            }
        }
#if defined(__linux__) || defined(__APPLE__)
        /* Unix 上 thread.o 使用 CPU_ZERO/CPU_SET（sched.h）；用 -pthread 让 cc 以正确顺序拉取 libpthread/libc */
        if ((asm_link_obj_skip_missing(thread_o) || asm_link_obj_skip_missing(sync_o) ||
             asm_link_obj_skip_missing(channel_o)) &&
            i < argv_cap - 1)
            argv[i++] = (char *)"-pthread";
        if (i < argv_cap - 1)
            argv[i++] = (char *)"-lc";
#endif
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
        /* 【Why 根源】PE/COFF 格式不支持 weak 符号：SHUX_WEAK 函数被 MinGW 当
           普通强符号定义。shux codegen 对 std/*.o 中函数生成 weak 别名（如 log_write_c、
           core_crypto_mem_eq_c），多份 .o 链入时产生 multiple definition error。
           --allow-multiple-definition 让 ld 选第一个定义，与 ELF weak 语义对齐。
           【Invariant】仅 PE 格式（Windows/Cygwin）需此 flag；ELF/Mach-O weak 原生支持。
           【Asm/Perf】链接期选第一个定义，无运行时开销。 */
        if (i < argv_cap - 1)
            argv[i++] = (char *)"-Wl,--allow-multiple-definition";
#endif
        /* User-specified .o files from command line (single authority:
         * g_shux_user_extra_o_files, set by shux_invoke_cc_set_user_o_files_from_argv).
         * Pushed AFTER all std/core .o and link flags so user glue resolves last
         * (resolves UNDEF symbols from std .o that user glue provides, e.g.
         * runtime_atomic_glue.o provides atomic_load_i32_c referenced by context.o). */
        {
            int ui;
            for (ui = 0; ui < g_shux_n_user_extra_o_files; ui++) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                                                    g_shux_user_extra_o_files[ui]);
            }
        }
        if (i < argv_cap)
            argv[i++] = NULL;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
        {
            /* Windows 无 cc，用 gcc；_spawnvp 第一参数为 PATH 查找的程序名 */
            argv[0] = (char *)"gcc";
            intptr_t rc = _spawnvp(_P_WAIT, "gcc", (const char *const *)argv);
            if (rc == -1) {
                perror("_spawnvp (cc)");
                return -1;
            }
            {
                int status = (int)rc;
                if (rc != 0) {
                    link_diag_tool_status("cc", status);
                    return -1;
                }
            }
        }
        return 0;
#else
#if defined(__linux__)
        /* Alpine 等环境下优先用 gcc 并传 argv[0]=gcc，确保 -std=gnu11 等参数被正确识别（部分 cc 包装可能行为不同） */
        argv[0] = (char *)"gcc";
        execvp("gcc", argv);
        argv[0] = (char *)"cc";
        execvp("cc", argv);
        argv[0] = (char *)"/usr/bin/gcc";
        execv("/usr/bin/gcc", argv);
        argv[0] = (char *)"/usr/bin/cc";
        execv("/usr/bin/cc", argv);
        argv[0] = (char *)"/usr/local/bin/gcc";
        execv("/usr/local/bin/gcc", argv);
        argv[0] = (char *)"/usr/local/bin/cc";
        execv("/usr/local/bin/cc", argv);
#else
        argv[0] = (char *)"cc";
        execvp("cc", argv);
        argv[0] = (char *)"gcc";
        execvp("gcc", argv);
#endif
        perror("cc/gcc");
        _exit(127);
    }
    int status;
    if (shu_waitpid_retry(pid, &status) != 0)
        return -1;
    /* #region debug-point D:invoke-cc-wait */
    shux_debug_hello_stage1_report("D", "runtime_link_abi.c:3455", "invoke_cc_wait", status, WIFSIGNALED(status) ? WTERMSIG(status) : -1, WIFEXITED(status) ? WEXITSTATUS(status) : -1);
    /* #endregion */
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        link_diag_tool_status("cc", status);
        return -1;
    }
#endif
    /* 阶段 8：非 -O0 时 strip 减体积。必须用 strip -x（仅剥局部符号）：
     * 裸 strip 在 Darwin 会去掉 _main 等全局符号，导致 LC_MAIN 仍可跑但 nm/otool
     * 无 _main: 标签 → run-asm-* 反汇编门禁假红、调试符号丢失。禁止 -s 给 cc（obsolete）。 */
    if (strcmp(opt_level, "0") != 0) {
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
        {
            const char *sargv[4];
            sargv[0] = "strip";
            sargv[1] = "-x";
            sargv[2] = out_path;
            sargv[3] = NULL;
            (void)_spawnvp(_P_WAIT, "strip", (const char *const *)sargv);
        }
#else
        pid_t spid = fork();
        if (spid == 0) {
            execlp("strip", "strip", "-x", out_path, (char *)NULL);
            _exit(127);
        }
        if (spid > 0) {
            int sstatus;
            (void)shu_waitpid_retry(spid, &sstatus);
        }
#endif
    }
    return 0;
}

/* G-02f-277 L9 gates */
#ifndef SHUX_LABI_GATES_FROM_X
int shux_invoke_cc(const char **c_paths, int n, const char *out_path, const char *target, const char *opt_level, int use_lto, const char *io_o, const char *fs_o, const char *process_o, const char *string_o, const char *heap_o, const char *path_o, const char *runtime_o, const char *runtime_panic_o, const char *net_o, const char *thread_o, const char *time_o, const char *random_o, const char *env_o, const char *sync_o, const char *encoding_o, const char *base64_o, const char *crypto_o, const char *log_o, const char *atomic_o, const char *channel_o, const char *backtrace_o, const char *hash_o, const char *math_o, const char *sort_o, const char *ffi_o, const char *db_o, const char *elf_o, const char *json_o, const char *csv_o, const char *regex_o, const char *compress_o, const char *unicode_o, const char *dynlib_o, const char *http_o, const char *tar_o, const char *simd_o, const char *context_o, const char *datetime_o, const char *uuid_o, const char *url_o, const char *cli_o, const char *security_o, const char *config_o, const char *cache_o, const char *trace_o, const char *task_o, const char *schema_o, const char *test_o, const char *include_root, const char *async_scheduler_o) {
  if (c_paths == NULL) {
    return -1;
  }
  if (out_path == NULL) {
    return -1;
  }
  {
    return shux_invoke_cc_impl(c_paths, n, out_path, target, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, include_root, async_scheduler_o);
  }
  return -1;
}
#else
int shux_invoke_cc(const char **c_paths, int n, const char *out_path, const char *target, const char *opt_level, int use_lto, const char *io_o, const char *fs_o, const char *process_o, const char *string_o, const char *heap_o, const char *path_o, const char *runtime_o, const char *runtime_panic_o, const char *net_o, const char *thread_o, const char *time_o, const char *random_o, const char *env_o, const char *sync_o, const char *encoding_o, const char *base64_o, const char *crypto_o, const char *log_o, const char *atomic_o, const char *channel_o, const char *backtrace_o, const char *hash_o, const char *math_o, const char *sort_o, const char *ffi_o, const char *db_o, const char *elf_o, const char *json_o, const char *csv_o, const char *regex_o, const char *compress_o, const char *unicode_o, const char *dynlib_o, const char *http_o, const char *tar_o, const char *simd_o, const char *context_o, const char *datetime_o, const char *uuid_o, const char *url_o, const char *cli_o, const char *security_o, const char *config_o, const char *cache_o, const char *trace_o, const char *task_o, const char *schema_o, const char *test_o, const char *include_root, const char *async_scheduler_o);
#endif


/**
 * PLATFORM: SHARED — formal std|core .o under repo (gitignored) vanish after L4 wipe.
 * Authority = Makefile + shux_compile_std_module (G.7); link push_existing alone silent-skips.
 * If rel_from_repo is missing, run: SHUX=<product> make -C <repo>/compiler <make_target>
 * make_target is relative to compiler/ (e.g. ../std/vec/vec.o).
 * Reentrancy: make → shux_compile_std_module → same product host → need_math/vec/set/map
 * would call ensure again and fork-bomb. Export SHUX_FORMAL_STD_ENSURE=1 on the make
 * child; nested ensure only checks existence (no second make).
 * Returns 1 if object exists after ensure, 0 otherwise.
 */
static int shux_ensure_formal_std_make_o(const char *repo_root, const char *rel_from_repo, const char *make_target) {
    char abs[PATH_MAX];
    char cmd[768];
    char shux_bin[PATH_MAX];
    const char *env_shux;
    const char *ensuring;
    int nn;
    if (!repo_root || !repo_root[0] || !rel_from_repo || !rel_from_repo[0] || !make_target || !make_target[0])
        return 0;
    nn = snprintf(abs, sizeof abs, "%s/%s", repo_root, rel_from_repo);
    if (nn < 0 || (size_t)nn >= sizeof abs)
        return 0;
    if (asm_link_obj_skip_missing(abs))
        return 1;
    /* Nested ensure while compiling formal .o: do not system(make) again. */
    ensuring = getenv("SHUX_FORMAL_STD_ENSURE");
    if (ensuring && ensuring[0] && ensuring[0] != '0')
        return 0;
    env_shux = getenv("SHUX");
    shux_bin[0] = '\0';
    if (env_shux && env_shux[0] && access(env_shux, X_OK) == 0) {
        if (realpath(env_shux, shux_bin) == NULL)
            (void)snprintf(shux_bin, sizeof shux_bin, "%s", env_shux);
    } else {
        static const char *names[] = { "shux_asm", "shux", "shux-c", NULL };
        int i;
        for (i = 0; names[i]; i++) {
            char cand[PATH_MAX];
            nn = snprintf(cand, sizeof cand, "%s/compiler/%s", repo_root, names[i]);
            if (nn < 0 || (size_t)nn >= sizeof cand)
                continue;
            if (access(cand, X_OK) == 0) {
                if (realpath(cand, shux_bin) == NULL)
                    (void)snprintf(shux_bin, sizeof shux_bin, "%s", cand);
                break;
            }
        }
    }
    if (!shux_bin[0])
        return 0;
    /* freestanding system() = fork+execvp sh -c; PATH fixed in invoke_cc child too. */
    nn = snprintf(cmd, sizeof cmd,
                  "SHUX_FORMAL_STD_ENSURE=1 SHUX='%s' make -C '%s/compiler' '%s'",
                  shux_bin, repo_root, make_target);
    if (nn < 0 || (size_t)nn >= sizeof cmd)
        return 0;
    (void)system(cmd);
    return asm_link_obj_skip_missing(abs) ? 1 : 0;
}

/**
 * 若 net.o / tls_openssl.o 仍为 TLS 桩且 SHUX_NET_TLS 非 stub，尝试 make net-o-openssl / net-o-mbedtls。
 * F-04 v8：OpenSSL 标记在 std/net/tls_openssl.o，不再编译进 net.o。
 * SHUX_NET_TLS：stub | openssl | mbedtls | auto（默认 auto）。
 * 参数：repo_root 仓库根目录绝对路径。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void ensure_std_net_o_auto_tls(const char *repo_root) {
    char cmd[640];
    char resolved[PATH_MAX];
    const char *mode;
    if (!repo_root || !repo_root[0])
        return;
    mode = getenv("SHUX_NET_TLS");
    if (!mode || !mode[0])
        return;
    if (strcmp(mode, "stub") == 0) {
        snprintf(cmd, sizeof(cmd), "make -C '%s/compiler' net-o-stub >/dev/null 2>&1", repo_root);
        (void)system(cmd);
        return;
    }
    snprintf(cmd, sizeof(cmd), "%s/std/net/tls_openssl.o", repo_root);
    if (realpath(cmd, resolved) != NULL &&
        link_abi_obj_exports_marker(resolved, "shu_net_tls_openssl_marker"))
        return;
    snprintf(cmd, sizeof(cmd), "%s/std/net/tls_mbedtls.o", repo_root);
    if (realpath(cmd, resolved) != NULL &&
        link_abi_obj_exports_marker(resolved, "shu_net_tls_mbedtls_marker"))
        return;
    snprintf(cmd, sizeof(cmd), "%s/std/net/net.o", repo_root);
    if (realpath(cmd, resolved) == NULL && realpath("std/net/net.o", resolved) == NULL)
        resolved[0] = '\0';
    if (resolved[0] &&
        (link_abi_obj_exports_marker(resolved, "shu_net_tls_openssl_marker") ||
         link_abi_obj_exports_marker(resolved, "shu_net_tls_mbedtls_marker")))
        return;
    if (strcmp(mode, "openssl") == 0) {
        snprintf(cmd, sizeof(cmd), "make -C '%s/compiler' net-o-openssl >/dev/null 2>&1", repo_root);
        (void)system(cmd);
        return;
    }
    if (strcmp(mode, "mbedtls") == 0) {
        snprintf(cmd, sizeof(cmd), "make -C '%s/compiler' net-o-mbedtls >/dev/null 2>&1", repo_root);
        (void)system(cmd);
        return;
    }
    if (strcmp(mode, "auto") != 0)
        return;
    snprintf(cmd, sizeof(cmd), "make -C '%s/compiler' net-o-openssl >/dev/null 2>&1", repo_root);
    if (system(cmd) != 0) {
        snprintf(cmd, sizeof(cmd), "make -C '%s/compiler' net-o-mbedtls >/dev/null 2>&1", repo_root);
        (void)system(cmd);
    }
}




/**
 * net.o / tls_openssl.o / tls_mbedtls.o 为 OpenSSL/mbedTLS 后端时追加对应 -L/-l 链接参数。
 * F-04 v8/v9：marker 在 std/net/tls_*.o（.x 产物），不再编译进 net.o。
 * 参数：argv/i/argv_cap 为 cc 链接 argv；net_o std/net .o；repo_root 仓库根（查 tls_openssl.o）。
 * 返回值：1 已追加 TLS 库，0 否。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int invoke_cc_append_net_tls_ld(char *argv[], int *i, int argv_cap, const char *net_o, const char *repo_root) {
    static char hb_ssl_lib[72] = "-L/opt/homebrew/opt/openssl/lib";
    static char hb_mb_lib[72] = "-L/opt/homebrew/opt/mbedtls/lib";
    const char *use = net_o;
    static char resolved[PATH_MAX];
    const char *tls_o;
    if (!i || *i >= argv_cap - 1)
        return 0;
    if (net_o && net_o[0]) {
#if !defined(_WIN32) && !defined(_WIN64)
        if (realpath(net_o, resolved) != NULL)
            use = resolved;
#endif
        if (link_abi_obj_exports_marker(use, "shu_net_tls_openssl_marker")) {
#if defined(__APPLE__)
            if (*i < argv_cap - 1)
                argv[(*i)++] = hb_ssl_lib;
#endif
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lssl";
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lcrypto";
            return 1;
        }
        if (link_abi_obj_exports_marker(use, "shu_net_tls_mbedtls_marker")) {
#if defined(__APPLE__)
            if (*i < argv_cap - 1)
                argv[(*i)++] = hb_mb_lib;
#endif
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lmbedtls";
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lmbedx509";
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lmbedcrypto";
            return 1;
        }
    }
    if (!repo_root || !repo_root[0])
        return 0;
    tls_o = shux_rel_o_path_from_argv0(repo_root, "std/net/tls_openssl.o");
    if (tls_o && tls_o[0]) {
        use = tls_o;
#if !defined(_WIN32) && !defined(_WIN64)
        if (realpath(tls_o, resolved) != NULL)
            use = resolved;
#endif
        if (link_abi_obj_exports_marker(use, "shu_net_tls_openssl_marker")) {
            (void)invoke_cc_argv_push_existing(argv, i, argv_cap, tls_o);
#if defined(__APPLE__)
            if (*i < argv_cap - 1)
                argv[(*i)++] = hb_ssl_lib;
#endif
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lssl";
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lcrypto";
            return 1;
        }
    }
    tls_o = shux_rel_o_path_from_argv0(repo_root, "std/net/tls_mbedtls.o");
    if (tls_o && tls_o[0]) {
        use = tls_o;
#if !defined(_WIN32) && !defined(_WIN64)
        if (realpath(tls_o, resolved) != NULL)
            use = resolved;
#endif
        if (link_abi_obj_exports_marker(use, "shu_net_tls_mbedtls_marker")) {
            (void)invoke_cc_argv_push_existing(argv, i, argv_cap, tls_o);
#if defined(__APPLE__)
            if (*i < argv_cap - 1)
                argv[(*i)++] = hb_mb_lib;
#endif
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lmbedtls";
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lmbedx509";
            if (*i < argv_cap - 1)
                argv[(*i)++] = (char *)"-lmbedcrypto";
            return 1;
        }
    }
    return 0;
}




/**
 * 相对仓库根的 .o 路径解析：realpath(rel)、cwd/rel、argv0/../rel。
 */
const char *shux_rel_o_path_from_argv0(const char *argv0, const char *rel) {
    /* 【Why 逻辑根源】返回独立堆分配内存而非静态缓冲：runtime.c 中 shux_invoke_cc 之前
     * 连续调用 30+ 次本函数（path_o/runtime_o/.../crypto_o/.../test_o）保存到局部变量，
     * 若返回静态缓冲则所有指针指向同一缓冲，最终只剩最后一次调用的内容——crypto_o 实际
     * 指向 test.o 路径，链接器找不到 crypto.o 触发 _core_crypto_mem_eq_c 未定义错误。
     * 【Invariant】调用方无需 free；进程退出自动回收（编译器短生命周期）。
     * 【Asm/Perf】strdup 一次 ~50ns，30+ 次仅 ~1.5us，可忽略。 */
    char buf[512];
    char resolved[PATH_MAX];
    size_t rel_len;
    buf[0] = resolved[0] = '\0';
    if (!rel || !rel[0])
        return strdup("");
    rel_len = strlen(rel);
    if (realpath(rel, resolved) != NULL)
        return strdup(resolved);
    {
        char cwd[512];
        if (getcwd(cwd, sizeof(cwd) - 2) != NULL) {
            size_t L = strlen(cwd);
            if (L + 1 + rel_len + 1 <= sizeof(cwd)) {
                cwd[L] = '/';
                memcpy(cwd + L + 1, rel, rel_len + 1);
                if (realpath(cwd, resolved) != NULL)
                    return strdup(resolved);
            }
        }
    }
    if (argv0 && argv0[0]) {
        const char *last_slash = shux_path_last_sep(argv0);
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - (int)(3 + rel_len))
                return strdup("");
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.';
            buf[1] = '\0';
            n = 1;
        }
        if ((size_t)n + 3 + rel_len < sizeof(buf)) {
            strcat(buf, "/../");
            strcat(buf, rel);
            if (realpath(buf, resolved) != NULL)
                return strdup(resolved);
            /* realpath 失败时勿返回臆造路径：仅当 stat 命中常规文件才返回 buf。 */
            if (asm_link_obj_skip_missing(buf))
                return strdup(buf);
            return strdup("");
        }
    }
    return strdup("");
}

/**
 * PLATFORM: LINUX — freestanding product popen is a NULL stub (bootstrap_nostdlib_stubs).
 * Without this, on_demand never sees U symbols and -backend asm takes minimal gcc only.
 * Scan ELF64 .symtab for SHN_UNDEF. want_sym NULL → any global UNDEF; else match name.
 * Returns 1 on match, 0 on none/error. G.7 authority for freestanding undef probes.
 */
#if defined(__linux__)
static int shux_elf64_obj_scan_undef(const char *o_path, const char *want_sym) {
    int fd;
    struct stat st;
    unsigned char *map = NULL;
    size_t sz;
    Elf64_Ehdr *eh;
    Elf64_Shdr *sh;
    Elf64_Shdr *symtab = NULL;
    Elf64_Shdr *strtab = NULL;
    Elf64_Sym *syms;
    const char *strs;
    size_t i, nsym;
    int found = 0;
    if (!o_path || !o_path[0])
        return 0;
    fd = open(o_path, O_RDONLY, 0);
    if (fd < 0)
        return 0;
    if (fstat(fd, &st) != 0 || st.st_size < (off_t)sizeof(Elf64_Ehdr)) {
        close(fd);
        return 0;
    }
    sz = (size_t)st.st_size;
    map = (unsigned char *)mmap(NULL, sz, PROT_READ, MAP_PRIVATE, fd, 0);
    close(fd);
    if (map == MAP_FAILED)
        return 0;
    eh = (Elf64_Ehdr *)map;
    if (memcmp(eh->e_ident, ELFMAG, SELFMAG) != 0 || eh->e_ident[EI_CLASS] != ELFCLASS64) {
        munmap(map, sz);
        return 0;
    }
    if (eh->e_shoff == 0 || eh->e_shentsize != sizeof(Elf64_Shdr) || eh->e_shnum == 0) {
        munmap(map, sz);
        return 0;
    }
    if ((size_t)eh->e_shoff + (size_t)eh->e_shnum * sizeof(Elf64_Shdr) > sz) {
        munmap(map, sz);
        return 0;
    }
    sh = (Elf64_Shdr *)(map + eh->e_shoff);
    for (i = 0; i < eh->e_shnum; i++) {
        if (sh[i].sh_type == SHT_SYMTAB) {
            symtab = &sh[i];
            if (sh[i].sh_link < eh->e_shnum)
                strtab = &sh[sh[i].sh_link];
            break;
        }
    }
    if (!symtab || !strtab || symtab->sh_entsize != sizeof(Elf64_Sym) ||
        symtab->sh_offset + symtab->sh_size > sz || strtab->sh_offset + strtab->sh_size > sz) {
        munmap(map, sz);
        return 0;
    }
    nsym = symtab->sh_size / sizeof(Elf64_Sym);
    syms = (Elf64_Sym *)(map + symtab->sh_offset);
    strs = (const char *)(map + strtab->sh_offset);
    for (i = 0; i < nsym; i++) {
        const char *name;
        if (syms[i].st_shndx != SHN_UNDEF)
            continue;
        if (ELF64_ST_BIND(syms[i].st_info) == STB_LOCAL)
            continue;
        if (syms[i].st_name >= strtab->sh_size)
            continue;
        name = strs + syms[i].st_name;
        if (!name[0])
            continue;
        if (!want_sym) {
            found = 1;
            break;
        }
        if (strcmp(name, want_sym) == 0) {
            found = 1;
            break;
        }
    }
    munmap(map, sz);
    return found;
}
#endif /* __linux__ */

/** 扫描用户 .o 未定义符号；nm/popen 失败时 LINUX 走 ELF 扫描（freestanding 产品）。
 * G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc
 *
 * 【Why 根源】Darwin `nm -u` 输出为 `_sym` 单行（无类型字母 U），且 Mach-O 符号带前导 `_`。
 * 旧实现用 `nm -u --porcelain`（Apple nm 常空输出）且只匹配无 `_` 的裸名 / 含 `U` 的行，
 * 导致 http.o 等对 std_heap_* 的 U 永远测不到 → on_demand 不推 heap.o → 链接失败。
 * Freestanding：popen 桩恒 NULL → 旧实现永远 0 → minimal gcc 永不 on_demand（si UNDEF）。
 * 【Invariant】匹配时跳过可选的 `U` 类型字段与可选的前导 `_`，再与裸 sym 比较。 */
int shux_link_obj_needs_undef_sym(const char *o_path, const char *sym) {
    char cmd[PATH_MAX + 160];
    FILE *fp;
    char line[512];
    size_t sym_len;
    if (!o_path || !o_path[0] || !sym || !sym[0])
        return 0;
    sym_len = strlen(sym);
    /* 统一 nm -u；勿用 Apple 上常失效的 --porcelain */
    if ((size_t)snprintf(cmd, sizeof cmd, "nm -u '%s' 2>/dev/null", o_path) >= sizeof cmd)
        return 0;
    fp = popen(cmd, "r");
    if (!fp) {
#if defined(__linux__)
        /* PLATFORM: LINUX freestanding — popen stub; ELF UNDEF scan authority. */
        return shux_elf64_obj_scan_undef(o_path, sym);
#else
        return 0; /* nm 不可用时不臆测缺符号，避免 on_demand 全量误链 net/heap 等 */
#endif
    }
    while (fgets(line, sizeof line, fp)) {
        char *p = line;
        size_t rest;
        while (*p == ' ' || *p == '\t')
            p++;
        /* GNU/ELF: "U sym" 或 "U _sym"；部分工具行内含 U */
        if (*p == 'U' && (p[1] == ' ' || p[1] == '\t')) {
            p += 2;
            while (*p == ' ' || *p == '\t')
                p++;
        }
        /* Mach-O nm -u: "_std_heap_alloc_usize\n" */
        if (*p == '_')
            p++;
        rest = strlen(p);
        while (rest > 0 && (p[rest - 1] == '\n' || p[rest - 1] == '\r' || p[rest - 1] == ' '))
            rest--;
        if (rest == sym_len && strncmp(p, sym, sym_len) == 0) {
            pclose(fp);
            return 1;
        }
        /* 兼容：行内任意位置出现 U 与符号（旧 ELF 多列格式） */
        if (strchr(line, 'U') != NULL && strstr(line, sym) != NULL) {
            pclose(fp);
            return 1;
        }
    }
    pclose(fp);
    return 0;
}

/**
 * 扫描 .o 是否已定义（T/t）给定符号。用于 co-emit 后避免再链 mem.o。
 * Darwin: `nm` → `0000 T _sym`；ELF: `0000 T sym`。
 */
int shux_link_obj_has_defined_sym(const char *o_path, const char *sym) {
    char cmd[PATH_MAX + 160];
    FILE *fp;
    char line[512];
    size_t sym_len;
    if (!o_path || !o_path[0] || !sym || !sym[0])
        return 0;
    sym_len = strlen(sym);
    if ((size_t)snprintf(cmd, sizeof cmd, "nm '%s' 2>/dev/null", o_path) >= sizeof cmd)
        return 0;
    fp = popen(cmd, "r");
    if (!fp)
        return 0;
    while (fgets(line, sizeof line, fp)) {
        char *p = line;
        char *type_p;
        size_t rest;
        /* 跳过地址列 */
        while (*p == ' ' || *p == '\t' || (*p >= '0' && *p <= '9') ||
               (*p >= 'a' && *p <= 'f') || (*p >= 'A' && *p <= 'F'))
            p++;
        while (*p == ' ' || *p == '\t')
            p++;
        if (*p != 'T' && *p != 't')
            continue;
        type_p = p;
        p++;
        if (*p != ' ' && *p != '\t')
            continue;
        while (*p == ' ' || *p == '\t')
            p++;
        if (*p == '_')
            p++;
        rest = strlen(p);
        while (rest > 0 && (p[rest - 1] == '\n' || p[rest - 1] == '\r' || p[rest - 1] == ' '))
            rest--;
        (void)type_p;
        if (rest == sym_len && strncmp(p, sym, sym_len) == 0) {
            pclose(fp);
            return 1;
        }
    }
    pclose(fp);
    return 0;
}

/* wave140: link_abi_user_o_provides_core_mem pure orch lives in labi_ondemand_list
 * (2 defined-sym needles + pure scan; Cap residual has_defined_sym). Was mega body.
 * Cold twin under #ifndef ONDEMAND_LIST_FROM_X; hybrid L8b pure .x.
 * Why: co-emit core_mem_* strong defs in user.o; hard-link mem.o → duplicate.
 * PLATFORM: SHARED — G.7 complete product surface; dual-end L2.
 */
int link_abi_user_o_provides_core_mem(const char *user_o);

/* wave140: link_abi_user_o_provides_std_heap pure orch (L8b ondemand).
 * Why: co-emit heap strong defs; hard-link heap.o → duplicate.
 */
int link_abi_user_o_provides_std_heap(const char *user_o);




/** ld argv 项是否为已解析的 .o/.obj 路径（跳过 -o、编译器驱动等）。 */
/* G-02f-65：真逻辑来自 .x（.o / .obj 后缀；原 static 提升为导出）。 */
/* G-02f-267 L0 path pure */
#ifndef SHUX_LABI_PATH_PURE_FROM_X
int link_abi_ld_argv_entry_is_obj(const char *s) {
    size_t n;
    if (s == NULL) {
        return 0;
    }
    if (s[0] == 0) {
        return 0;
    }
    n = 0;
    while (s[n] != 0) {
        n = n + 1;
    }
    if (n >= 2) {
        if (s[n - 2] == '.') {
            if (s[n - 1] == 'o') {
                return 1;
            }
        }
    }
    if (n >= 4) {
        if (s[n - 4] == '.') {
            if (s[n - 3] == 'o') {
                if (s[n - 2] == 'b') {
                    if (s[n - 1] == 'j') {
                        return 1;
                    }
                }
            }
        }
    }
    return 0;
}
#else
int link_abi_ld_argv_entry_is_obj(const char *s);
#endif


/**
 * 用户主 .o 或已入链 argv 中的 std/*.o 是否仍引用 heap_*_c。
 * hash/sort 等经 libc.x 编译，hello 全量 std 链时 user.o 本身可无 heap 符号。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int link_abi_link_needs_heap_user_c(const char *user_o, const char **argv, int la) {
    /* G-02f-37：单路径探针 .x link_abi_user_o_needs_heap_user_syms；argv 循环仍 C。 */
    int i;
    if (user_o && user_o[0] && link_abi_user_o_needs_heap_user_syms(user_o))
        return 1;
    if (!argv || la <= 0)
        return 0;
    for (i = 0; i < la && argv[i]; i++) {
        if (!link_abi_ld_argv_entry_is_obj(argv[i]))
            continue;
        if (link_abi_user_o_needs_heap_user_syms(argv[i]))
            return 1;
    }
    return 0;
}




/* G-02f-276：needs_io from pure symbol table */
int shux_freestanding_user_o_needs_io(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_fs_io_sym_count();
  for (i = 0; i < n; i++) {
    const char *s = labi_fs_io_sym_at(i);
    if (s && s[0] && shux_link_obj_needs_undef_sym(user_o, s))
      return 1;
  }
  return 0;
}

/* G-02f-276：needs_panic from pure table */
int shux_freestanding_user_o_needs_panic(const char *user_o) {
  const char *s;
  if (!user_o || !user_o[0])
    return 0;
  s = labi_fs_panic_sym();
  if (!s || !s[0])
    return 0;
  return shux_link_obj_needs_undef_sym(user_o, s);
}

/*
 * wave118: needs_std_net pure orch lives in labi_ondemand_list (net sym table + orch).
 * wave119: needs_std_set pure orch lives in labi_ondemand_list (set sym table + orch).
 * wave120: needs_std_map pure orch lives in labi_ondemand_list (map sym table + orch).
 * wave121: needs_std_queue pure orch lives in labi_ondemand_list (queue_api sym table + orch).
 * wave122: needs_std_test pure orch lives in labi_ondemand_list (test sym table + orch).
 * wave123: needs_core_mem pure orch lives in labi_ondemand_list (core_mem sym table + orch).
 * wave124: needs_core_slice pure orch lives in labi_ondemand_list (core_slice sym table + orch).
 * wave125: needs_std_heap_page_mmap pure orch lives in labi_ondemand_list (page_mmap sym table + orch).
 * wave126: needs_std_sys_linux pure orch lives in labi_ondemand_list (sys_linux sym table + orch).
 * wave127: needs_std_sys pure orch lives in labi_ondemand_list (sys facade sym table + orch).
 * wave128: needs_std_heap_api pure orch lives in labi_ondemand_list (heap_api sym table + orch).
 * wave129: needs_heap_user_syms pure orch lives in labi_ondemand_list (heap_user sym table + orch).
 * wave130: needs_async_scheduler pure orch lives in labi_ondemand_list (async_scheduler sym table + orch).
 * wave131: compress family pure orch lives in labi_ondemand_list (zlib/zstd/brotli marker+undef + needs_compress_libs).
 * wave132: labi_user_needs_runtime_{time_os,random_fill,env_os} pure orch lives in labi_ondemand_list
 *   (PRIMARY OS tables; null/empty → 1).
 * wave133: labi_user_needs_runtime_process_argv pure orch (9 needles).
 * wave134: labi_user_needs_std_task pure orch (29 needles; TASK_SPECIAL bulk gate).
 * wave135: labi_std_fk0_user_needs_rel pure orch (16 rel × 106 exact UNDEF).
 * Full-seed path: bodies via #include below (!FROM_X). Hybrid FROM_X: L8b pure .x provides;
 * decls in #else of ondemand include. Cap residual: undef_sym stays mega. PLATFORM: SHARED.
 */

/**
 * wave128: needs_std_heap_api pure orch lives in labi_ondemand_list
 * (labi_od_heap_api_sym_* product table + pure scan; not here).
 * Exact symbols only (no prefix probes).
 * Why: F-闭合删除 import_alias C 桩后 std/*.o 直接引用 std_heap_*；product heap.o gate.
 * Invariant: link_abi_link_needs_std_heap_import still scans user_o + argv via this orch.
 */

/**
 * wave129: needs_heap_user_syms pure orch lives in labi_ondemand_list
 * (labi_od_heap_user_sym_* product table ×7 exact + pure scan; not here).
 * Exact symbols only (no prefix probes). Product complete: alloc/free/realloc/arena64_alloc
 * + with_arena heap_arena_init_c / heap_arena64_{init,deinit}_c (G.7 close incomplete mega.x residual).
 * Invariant: link_abi_link_needs_heap_user_c still scans user_o + argv via this orch.
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

int link_abi_link_needs_std_heap_import(const char *user_o, const char **argv, int la) {
    /* G-02f-37：单路径探针 .x link_abi_user_o_needs_std_heap_api；argv 循环仍 C。 */
    int i;
    if (user_o && user_o[0] && link_abi_user_o_needs_std_heap_api(user_o))
        return 1;
    if (!argv || la <= 0)
        return 0;
    for (i = 0; i < la && argv[i]; i++) {
        if (!link_abi_ld_argv_entry_is_obj(argv[i]))
            continue;
        if (link_abi_user_o_needs_std_heap_api(argv[i]))
            return 1;
    }
    return 0;
}




/**
 * wave121: needs_std_queue pure orch lives in labi_ondemand_list
 * (labi_od_queue_api_sym_* product table + pure scan; not here).
 * Contention/smoke stays labi_od_queue_sym_* (separate table).
 */

/**
 * wave122: needs_std_test pure orch lives in labi_ondemand_list
 * (labi_od_test_sym_* product table + pure scan; not here).
 * Prefix probes (test_runner_ etc.) rely on Cap residual strstr in undef_sym.
 */

/**
 * wave123: needs_core_mem pure orch lives in labi_ondemand_list
 * (labi_od_core_mem_sym_* product table + pure scan; not here).
 * Exact symbols only (no prefix probes).
 */

/**
 * wave124: needs_core_slice pure orch lives in labi_ondemand_list
 * (labi_od_core_slice_sym_* product table + pure scan; not here).
 * Exact symbols only (no prefix probes).
 */

/**
 * 检查 path 是否已在 ld argv 中（realpath 去重，避免 /src/std/... 与 -L 解析路径重复入链）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int link_abi_asm_ld_argv_has_obj(const char **argv, int la, const char *path) {
    int k;
    /** 勿放栈上：nostdlib shux_asm 在 elf emit 后主栈已深，8KiB×递归 realpath 易 SIGSEGV。 */
    static char abs_new[PATH_MAX];
    static char abs_exist[PATH_MAX];
    const char *use_new;
    if (!argv || la <= 0 || !path || !path[0])
        return 0;
    use_new = path;
#if !defined(_WIN32) && !defined(_WIN64)
    if (realpath(path, abs_new) != NULL)
        use_new = abs_new;
#endif
    for (k = 0; k < la; k++) {
        const char *exist = argv[k];
        if (!exist || !exist[0])
            continue;
        if (strcmp(exist, path) == 0 || strcmp(exist, use_new) == 0)
            return 1;
#if !defined(_WIN32) && !defined(_WIN64)
        if (realpath(exist, abs_exist) != NULL && strcmp(abs_exist, use_new) == 0)
            return 1;
#endif
    }
    return 0;
}




/**
 * 将已解析 .o 路径拷入 bank 后追加到 ld argv（避免静态路径缓冲被后续解析覆盖）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void link_abi_asm_ld_argv_push_stable(ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la,
    const char *p) {
    if (!p || !p[0] || !la || *la >= max_la - 1)
        return;
    if (bank) {
        const char *bp = shux_asm_ld_bank_push(bank, p);
        if (bp)
            p = bp;
    }
    if (link_abi_asm_ld_argv_has_obj(argv, *la, p))
        return;
    argv[(*la)++] = p;
}
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */




int link_abi_asm_ld_push_obj(const char *primary, const char *link_argv0, const char *rel,
    const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank,
    const char **argv, int *la, int max_la, int *flag_out) {
    const char *p = NULL;
    int debug_runtime_obj = 0;
    if (!la || *la >= max_la - 1)
        return 0;
    if (rel && (strcmp(rel, "compiler/runtime_asm_io_stubs.o") == 0
            || strcmp(rel, "compiler/runtime_process_argv.o") == 0))
        debug_runtime_obj = 1;
    if (debug_runtime_obj && getenv("SHUX_DEBUG_LD"))
        link_diag_ld_debug_push(rel, "primary", primary ? primary : "(null)");
    if (primary && primary[0])
        p = asm_link_obj_skip_missing(primary);
    if (debug_runtime_obj && getenv("SHUX_DEBUG_LD"))
        link_diag_ld_debug_push(rel, "after-primary", p ? p : "(null)");
    if (!p && rel && rel[0])
        p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, rel));
    if (!p && bank && rel && rel[0])
        p = shux_asm_ld_try_under_lib_roots(rel, lib_roots, n_lib_roots, bank);
    if (!p)
        return 0;
    /* 路径须拷入 bank：shux_rel_o_path_from_argv0 / shux_runtime_*_o_path 用静态缓冲，勿把裸指针留到 argv。 */
    if (bank) {
        const char *bp = shux_asm_ld_bank_push(bank, p);
        if (bp)
            p = bp;
        else
            return 0;
    }
    if (debug_runtime_obj && getenv("SHUX_DEBUG_LD"))
        link_diag_ld_debug_push(rel, "final", p ? p : "(null)");
    if (link_abi_asm_ld_argv_has_obj(argv, *la, p))
        return 0;
    argv[(*la)++] = p;
    if (flag_out)
        *flag_out = 1;
    return 1;
}




/**
 * F-03：仅当对应 std/*.o 已入链时才追加 runtime_*_glue.o，避免 glue 引用 log_write_c 等未定义符号。
 * ensure_fn 非 NULL 时在 push 前 cc -c 生成 glue .o（Docker/CI 无预编译 glue 时须 ensure）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void link_abi_asm_ld_push_glue_after_std(int have_std, int (*ensure_fn)(const char *argv0),
    const char *glue_primary, const char *link_argv0, const char *glue_rel, const char **lib_roots, int n_lib_roots,
    ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la) {
    if (!have_std)
        return;
    if (ensure_fn && ensure_fn(link_argv0) != 0)
        return;
    link_abi_asm_ld_push_obj(glue_primary, link_argv0, glue_rel, lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
}




/* PLATFORM: POSIX (linux||apple) — block historically opened around needs_async_scheduler;
 * wave130 moved pure orch to labi_ondemand_list; keep #if for push_minimal + nested linux only. */
#if defined(__linux__) || defined(__APPLE__)
/**
 * wave130: needs_async_scheduler pure orch lives in labi_ondemand_list
 * (labi_od_async_scheduler_sym_* product table ×35 exact + pure scan; not here).
 * Exact symbols only (no prefix probes). Product complete: coop/cps/frame/run/task/worker/io
 * + async read/write complete surface (G.7 single product table).
 * Invariant: on_demand push of std/async/scheduler.o still gates via this orch.
 * PLATFORM: SHARED (hybrid L8b; cold twin under ondemand include).
 */

/**
 * wave123: needs_core_mem pure orch lives in labi_ondemand_list
 * (labi_od_core_mem_sym_* product table + pure scan; not here).
 * Exact symbols only (no prefix probes).
 */

/**
 * wave124: needs_core_slice pure orch lives in labi_ondemand_list
 * (labi_od_core_slice_sym_* product table + pure scan; not here).
 * Exact symbols only (no prefix probes).
 */

/**
 * wave125: needs_std_heap_page_mmap pure orch lives in labi_ondemand_list
 * (labi_od_page_mmap_sym_* product table + pure scan; not here).
 * Exact symbols only (no prefix probes).
 * F-no-libc NL-03: freestanding mmap bump heap gate; page_mmap.o + transitive linux/core_mem.
 */

/**
 * wave126: needs_std_sys_linux pure orch lives in labi_ondemand_list
 * (labi_od_sys_linux_sym_* product table + pure scan; not here).
 * Exact symbols only (no prefix probes).
 * F-no-libc: freestanding Linux syscall thin wrappers; product linux.o gate.
 */

/**
 * wave127: needs_std_sys pure orch lives in labi_ondemand_list
 * (labi_od_sys_sym_* product table + pure scan; not here).
 * Exact symbols only (no prefix probes).
 * F-no-libc: std.sys facade (write_stdout/read/close/exit); product sys.o gate.
 * On Linux sys.o may transitively need linux.o via cfg target_os.
 */

/**
 * nostdlib minimal gcc link still needs compiler runtime stubs; hello depends on
 * std_fmt_print / std_fmt_println (runtime_asm_io_stubs; PLATFORM: SHARED).
 * popen 桩恒失败时 has_undef 误判为自包含，勿因此省略 io_stubs。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void link_abi_asm_ld_push_minimal_runtime_objs(const char *link_argv0, const char **lib_roots, int n_lib_roots,
    ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la) {
    char io_stubs_o[PATH_MAX];
    char process_argv_o[PATH_MAX];
    const char *io_stubs_p = NULL;
    const char *process_argv_p = NULL;
    if (shux_runtime_compiler_o_path_copy(link_argv0, "runtime_asm_io_stubs.o", io_stubs_o, sizeof io_stubs_o) == 0)
        io_stubs_p = io_stubs_o;
    if (shux_runtime_compiler_o_path_copy(link_argv0, "runtime_process_argv.o", process_argv_o, sizeof process_argv_o) == 0)
        process_argv_p = process_argv_o;
    link_abi_asm_ld_push_obj(io_stubs_p, link_argv0,
        "compiler/runtime_asm_io_stubs.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(process_argv_p, link_argv0,
        "compiler/runtime_process_argv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(shux_runtime_panic_o_path(link_argv0), link_argv0,
        "compiler/runtime_panic.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
}




#if defined(__linux__)
/**
 * nostdlib shux_asm：自包含 user.o 的 gcc 最小链（user.o + runtime 桩 + -lc）。
 * pipeline/elf emit 后主栈已很深，完整 ld argv 构建（realpath 去重、popen nm）易 SIGSEGV；
 * 固定小 argv + static path bank，不扫描 std/*.o。
 * 参数：link_eff 有效 argv0/compiler 目录；lib_roots 与 driver -L 一致。
 * 返回值：0 成功，-1 失败。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_asm_nostdlib_minimal_selfcontained_exe_link(const char *o_path, const char *exe_path,
    const char *link_eff, const char **lib_roots, int n_lib_roots) {
    static ShuAsmLdPathBank bank;
    const char *argv[24];
    int la = 0;
    pid_t pid;
    int status;

    if (!o_path || !exe_path || !link_eff)
        return -1;
    bank.n = 0;
    memset(bank.slots, 0, sizeof bank.slots);
    argv[la++] = shux_linux_host_gcc_path();
    shux_append_linux_link_harden((char **)argv, &la, (int)(sizeof argv / sizeof argv[0]));
    argv[la++] = "-o";
    argv[la++] = exe_path;
    argv[la++] = o_path;
    link_abi_asm_ld_push_minimal_runtime_objs(link_eff, lib_roots, n_lib_roots, &bank, argv, &la,
        (int)(sizeof argv / sizeof argv[0]));
    if (la < (int)(sizeof argv / sizeof argv[0]) - 1)
        argv[la++] = "-lc";
    /* G.7: CLI user .o on self-contained minimal asm link too. */
    shux_asm_ld_append_user_extra_o_files(argv, &la, (int)(sizeof argv / sizeof argv[0]));
    argv[la] = NULL;
    if (getenv("SHUX_DEBUG_LD"))
        link_diag_ld_debug_argv("minimal gcc argv", argv);
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    {
        intptr_t rc = _spawnvp(_P_WAIT, argv[0], (const char *const *)argv);
        if (rc == -1) {
            perror("spawnvp (ld nostdlib minimal)");
            return -1;
        }
        if (rc != 0) {
            link_diag_tool_status("ld", (int)rc);
            return -1;
        }
    }
#else
    pid = fork();
    if (pid < 0) {
        perror("fork (ld nostdlib minimal)");
        return -1;
    }
    if (pid == 0) {
        shux_linux_ld_child_path();
        execvp(argv[0], (char *const *)argv);
        execv("/usr/bin/gcc", (char *const *)argv);
        execv("/usr/local/bin/gcc", (char *const *)argv);
        perror("gcc (nostdlib minimal user.o)");
        _exit(127);
    }
    if (shu_waitpid_retry(pid, &status) != 0)
        return -1;
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        link_diag_tool_status("ld", status);
        return -1;
    }
#endif
    return 0;
}



#endif /* __linux__ */
#endif
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

/* G-02f-271 L8 std list pure plan (+ accessors) */
#ifndef SHUX_LABI_STD_LIST_FROM_X
enum {
  LABI_STD_OP_STD = 1,
  LABI_STD_OP_IO_STUBS = 2,
  LABI_STD_OP_PRIMARY_PANIC = 3,
  LABI_STD_OP_PRIMARY_TIME_OS = 4,
  LABI_STD_OP_PRIMARY_RANDOM_FILL = 5,
  LABI_STD_OP_PRIMARY_ENV_OS = 6,
  LABI_STD_OP_GLUE_THREAD = 10,
  LABI_STD_OP_GLUE_SYNC_PAIR = 11,
  LABI_STD_OP_GLUE_CRYPTO_PAIR = 12,
  LABI_STD_OP_GLUE_LOG = 13,
  LABI_STD_OP_GLUE_ATOMIC = 14,
  LABI_STD_OP_GLUE_CHANNEL = 15,
  LABI_STD_OP_GLUE_BACKTRACE = 16,
  LABI_STD_OP_GLUE_MATH = 17,
  LABI_STD_OP_GLUE_SQLITE = 18,
  LABI_STD_OP_GLUE_DYNLIB = 19,
  LABI_STD_OP_GLUE_HTTP = 20,
  LABI_STD_OP_TASK_SPECIAL = 30
};
typedef struct LabiStdPlanStep {
  int op;
  const char *rel;
  int flag_kind;
} LabiStdPlanStep;
static const LabiStdPlanStep g_labi_std_plan[] = {
    {LABI_STD_OP_IO_STUBS, "compiler/runtime_asm_io_stubs.o", 0},
    /* 勿无条件硬链 core/mem/mem.o 与 heap.o：用户 co-emit 已提供 core_mem_* 时会 duplicate。
     * heap/core_mem 仅走 on_demand（link_abi_link_needs_std_heap_import /
     * link_abi_user_o_needs_core_mem）；bank/argv 已扩到 192 防漏推。 */
    {LABI_STD_OP_STD, "std/process/process.o", 1},
    {LABI_STD_OP_STD, "std/string/string.o", 0},
    {LABI_STD_OP_STD, "std/path/path.o", 0},
    {LABI_STD_OP_STD, "std/runtime/runtime.o", 0},
    {LABI_STD_OP_PRIMARY_PANIC, "compiler/runtime_panic.o", 0},
    {LABI_STD_OP_STD, "std/thread/thread.o", 2},
    {LABI_STD_OP_GLUE_THREAD, "compiler/runtime_thread_glue.o", 0},
    {LABI_STD_OP_PRIMARY_TIME_OS, "compiler/runtime_time_os.o", 0},
    {LABI_STD_OP_STD, "std/time/time.o", 0},
    {LABI_STD_OP_PRIMARY_RANDOM_FILL, "compiler/runtime_random_fill.o", 0},
    {LABI_STD_OP_STD, "std/random/random.o", 0},
    {LABI_STD_OP_PRIMARY_ENV_OS, "compiler/runtime_env_os.o", 0},
    {LABI_STD_OP_STD, "std/env/env.o", 0},
    /* PLATFORM: SHARED — formal fs.o for asm (std.fs co-emit skipped); fk0 gated. */
    {LABI_STD_OP_STD, "std/fs/fs.o", 0},
    {LABI_STD_OP_STD, "std/sync/sync.o", 3},
    {LABI_STD_OP_GLUE_SYNC_PAIR, "compiler/runtime_sync_lock_diag_tls.o", 0},
    {LABI_STD_OP_STD, "std/encoding/encoding.o", 0},
    {LABI_STD_OP_STD, "std/base64/base64.o", 0},
    {LABI_STD_OP_STD, "std/crypto/crypto.o", 4},
    {LABI_STD_OP_GLUE_CRYPTO_PAIR, "compiler/runtime_ed25519_ref10_glue.o", 0},
    {LABI_STD_OP_STD, "std/log/log.o", 5},
    {LABI_STD_OP_GLUE_LOG, "compiler/runtime_log_os.o", 0},
    {LABI_STD_OP_STD, "std/atomic/atomic.o", 6},
    {LABI_STD_OP_GLUE_ATOMIC, "compiler/runtime_atomic_glue.o", 0},
    {LABI_STD_OP_STD, "std/channel/channel.o", 7},
    {LABI_STD_OP_GLUE_CHANNEL, "compiler/runtime_channel_glue.o", 0},
    {LABI_STD_OP_STD, "std/backtrace/backtrace.o", 8},
    {LABI_STD_OP_GLUE_BACKTRACE, "compiler/runtime_backtrace_platform.o", 0},
    {LABI_STD_OP_STD, "std/hash/hash.o", 0},
    {LABI_STD_OP_STD, "std/math/math.o", 9},
    {LABI_STD_OP_GLUE_MATH, "compiler/runtime_math_libm.o", 0},
    {LABI_STD_OP_STD, "std/sort/sort.o", 0},
    /* PLATFORM: SHARED — std.vec is link_only; on-demand via fk0 UNDEF probes. */
    {LABI_STD_OP_STD, "std/vec/vec.o", 0},
    {LABI_STD_OP_STD, "std/ffi/ffi.o", 0},
    {LABI_STD_OP_STD, "std/db/sqlite/sqlite.o", 10},
    {LABI_STD_OP_GLUE_SQLITE, "compiler/runtime_sqlite_glue.o", 0},
    {LABI_STD_OP_STD, "std/elf/elf.o", 11},
    {LABI_STD_OP_STD, "std/json/json.o", 0},
    {LABI_STD_OP_STD, "std/csv/csv.o", 0},
    {LABI_STD_OP_STD, "std/regex/regex.o", 0},
    {LABI_STD_OP_STD, "std/unicode/unicode.o", 0},
    {LABI_STD_OP_STD, "std/dynlib/dynlib.o", 12},
    {LABI_STD_OP_GLUE_DYNLIB, "compiler/runtime_dynlib_os.o", 0},
    {LABI_STD_OP_STD, "std/http/http.o", 13},
    {LABI_STD_OP_GLUE_HTTP, "compiler/runtime_http_glue.o", 0},
    {LABI_STD_OP_STD, "std/socketio/socketio.o", 0},
    {LABI_STD_OP_STD, "std/tar/tar.o", 0},
    {LABI_STD_OP_STD, "std/simd/simd.o", 0},
    {LABI_STD_OP_STD, "std/context/context.o", 0},
    {LABI_STD_OP_STD, "std/error/error.o", 0},
    {LABI_STD_OP_STD, "std/datetime/datetime.o", 0},
    {LABI_STD_OP_STD, "std/uuid/uuid.o", 0},
    {LABI_STD_OP_STD, "std/url/url.o", 0},
    {LABI_STD_OP_STD, "std/cli/cli.o", 0},
    {LABI_STD_OP_STD, "std/security/security.o", 0},
    {LABI_STD_OP_STD, "std/config/config.o", 0},
    {LABI_STD_OP_STD, "std/cache/cache.o", 0},
    {LABI_STD_OP_STD, "std/trace/trace.o", 0},
    {LABI_STD_OP_TASK_SPECIAL, "std/task/task.o", 0},
};
int labi_std_plan_count(void) {
  return (int)(sizeof g_labi_std_plan / sizeof g_labi_std_plan[0]);
}
int labi_std_plan_step_at(int i, int *op_out, const char **rel_out, int *flag_kind_out) {
  int n = labi_std_plan_count();
  if (i < 0 || i >= n)
    return 0;
  if (op_out)
    *op_out = g_labi_std_plan[i].op;
  if (rel_out)
    *rel_out = g_labi_std_plan[i].rel;
  if (flag_kind_out)
    *flag_kind_out = g_labi_std_plan[i].flag_kind;
  return 1;
}
int labi_std_default_std_rel_count(void) {
  int n = labi_std_plan_count();
  int i;
  int c = 0;
  for (i = 0; i < n; i++) {
    if (g_labi_std_plan[i].op == LABI_STD_OP_STD)
      c = c + 1;
  }
  return c;
}
const char *labi_std_default_std_rel_at(int j) {
  int n = labi_std_plan_count();
  int i;
  int c = 0;
  if (j < 0)
    return NULL;
  for (i = 0; i < n; i++) {
    if (g_labi_std_plan[i].op != LABI_STD_OP_STD)
      continue;
    if (c == j)
      return g_labi_std_plan[i].rel;
    c = c + 1;
  }
  return NULL;
}
#else
enum {
  LABI_STD_OP_STD = 1,
  LABI_STD_OP_IO_STUBS = 2,
  LABI_STD_OP_PRIMARY_PANIC = 3,
  LABI_STD_OP_PRIMARY_TIME_OS = 4,
  LABI_STD_OP_PRIMARY_RANDOM_FILL = 5,
  LABI_STD_OP_PRIMARY_ENV_OS = 6,
  LABI_STD_OP_GLUE_THREAD = 10,
  LABI_STD_OP_GLUE_SYNC_PAIR = 11,
  LABI_STD_OP_GLUE_CRYPTO_PAIR = 12,
  LABI_STD_OP_GLUE_LOG = 13,
  LABI_STD_OP_GLUE_ATOMIC = 14,
  LABI_STD_OP_GLUE_CHANNEL = 15,
  LABI_STD_OP_GLUE_BACKTRACE = 16,
  LABI_STD_OP_GLUE_MATH = 17,
  LABI_STD_OP_GLUE_SQLITE = 18,
  LABI_STD_OP_GLUE_DYNLIB = 19,
  LABI_STD_OP_GLUE_HTTP = 20,
  LABI_STD_OP_TASK_SPECIAL = 30
};
int labi_std_plan_count(void);
int labi_std_plan_step_at(int i, int *op_out, const char **rel_out, int *flag_kind_out);
int labi_std_default_std_rel_count(void);
const char *labi_std_default_std_rel_at(int j);
#endif

/* wave135: labi_std_fk0_user_needs_rel pure orch lives in labi_ondemand_list
 * (16 rel path needles × 106 exact UNDEF; Cap strstr + undef_sym).
 * null/empty user_o → 1; unknown rel → 0. Was static mega body (G-02f-165/271).
 * Cold twin under #ifndef ONDEMAND_LIST_FROM_X; hybrid L8b pure .x.
 * PLATFORM: SHARED — G.7 complete product surface; dual-end L2.
 */
int labi_std_fk0_user_needs_rel(const char *user_o, const char *rel);

/*
 * wave132–134: labi_user_needs_runtime_{time_os,random_fill,env_os,process_argv}
 * + labi_user_needs_std_task pure orch live in labi_ondemand_list
 * (product tables + pure scan; null/empty → 1).
 * wave135: labi_std_fk0_user_needs_rel pure (fk0 plan gate; Cap strstr).
 * Cap residual: undef_sym stays mega. Call sites need forward decls before
 * the ondemand include block. PLATFORM: SHARED.
 */
int labi_user_needs_runtime_time_os(const char *user_o);
int labi_user_needs_runtime_random_fill(const char *user_o);
int labi_user_needs_runtime_env_os(const char *user_o);
int labi_user_needs_runtime_process_argv(const char *user_o);
/* wave134: TASK_SPECIAL bulk gate pure; was static mega body. */
int labi_user_needs_std_task(const char *user_o);

void shux_asm_ld_append_std_objs(const char *link_argv0, const char **lib_roots, int n_lib_roots,
    ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags) {
    /* 兼容旧调用：无 user_o 时走硬链。新调用经 wrapper 传入 o_path。 */
    shux_asm_ld_append_std_objs_for_user(link_argv0, NULL, lib_roots, n_lib_roots, bank, argv, la, max_la, flags);
}

void shux_asm_ld_append_std_objs_for_user(const char *link_argv0, const char *user_o,
    const char **lib_roots, int n_lib_roots,
    ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags) {
    const char *p;
    char io_stubs_o[PATH_MAX];
    const char *io_stubs_p = NULL;
    int have_process = 0;
    int have_log = 0;
    int have_crypto = 0;
    int have_atomic = 0;
    int have_backtrace = 0;
    int have_http = 0;
    int n_steps;
    int si;
    if (flags)
        memset(flags, 0, sizeof *flags);
    if (flags)
        flags->have_fs = 1;
    if (flags)
        flags->have_io = 1;
    n_steps = labi_std_plan_count();
    for (si = 0; si < n_steps; si++) {
        int op = 0;
        const char *rel = NULL;
        int fk = 0;
        int *flag_out = NULL;
        if (!labi_std_plan_step_at(si, &op, &rel, &fk))
            continue;
        switch (op) {
        case LABI_STD_OP_IO_STUBS:
            if (shux_runtime_compiler_o_path_copy(link_argv0, "runtime_asm_io_stubs.o", io_stubs_o, sizeof io_stubs_o) == 0)
                io_stubs_p = io_stubs_o;
            link_abi_asm_ld_push_obj(io_stubs_p, link_argv0,
                rel ? rel : "compiler/runtime_asm_io_stubs.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            break;
        case LABI_STD_OP_PRIMARY_PANIC:
            link_abi_asm_ld_push_obj(shux_runtime_panic_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_panic.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            break;
        case LABI_STD_OP_PRIMARY_TIME_OS:
            /* PLATFORM: SHARED — on_demand also covers time.o+time_os; skip bulk when pure.
             * ensure at push (glue pattern): prepare may have skipped or been bypassed. */
            if (!labi_user_needs_runtime_time_os(user_o))
                break;
            (void)shux_ensure_runtime_time_os_o(link_argv0);
            link_abi_asm_ld_push_obj(shux_runtime_time_os_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_time_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            break;
        case LABI_STD_OP_PRIMARY_RANDOM_FILL:
            if (!labi_user_needs_runtime_random_fill(user_o))
                break;
            (void)shux_ensure_runtime_random_fill_o(link_argv0);
            link_abi_asm_ld_push_obj(shux_runtime_random_fill_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_random_fill.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            break;
        case LABI_STD_OP_PRIMARY_ENV_OS:
            if (!labi_user_needs_runtime_env_os(user_o))
                break;
            (void)shux_ensure_runtime_env_os_o(link_argv0);
            link_abi_asm_ld_push_obj(shux_runtime_env_os_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_env_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            break;
        case LABI_STD_OP_STD:
            flag_out = NULL;
            if (fk == 1)
                flag_out = &have_process;
            else if (fk == 2)
                flag_out = flags ? &flags->have_thread : NULL;
            else if (fk == 3)
                flag_out = flags ? &flags->have_sync : NULL;
            else if (fk == 4)
                flag_out = &have_crypto;
            else if (fk == 5)
                flag_out = &have_log;
            else if (fk == 6)
                flag_out = &have_atomic;
            else if (fk == 7)
                flag_out = flags ? &flags->have_channel : NULL;
            else if (fk == 8)
                flag_out = &have_backtrace;
            else if (fk == 9)
                flag_out = flags ? &flags->have_math : NULL;
            else if (fk == 10)
                flag_out = flags ? &flags->have_sqlite : NULL;
            else if (fk == 11)
                flag_out = flags ? &flags->have_elf : NULL;
            else if (fk == 12)
                flag_out = flags ? &flags->have_dynlib : NULL;
            else if (fk == 13)
                flag_out = &have_http;
            /* 残缺预编 .o 勿无条件硬链：仅 user.o 有对应 UNDEF 时推入 */
            if (rel && rel[0] && user_o && user_o[0]) {
                if (fk == 0 && !labi_std_fk0_user_needs_rel(user_o, rel))
                    break;
                if (fk == 4 /* crypto */ && !shux_link_obj_needs_undef_sym(user_o, "std_crypto_mem_eq")
                    && !shux_link_obj_needs_undef_sym(user_o, "crypto_mem_eq_c")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_crypto_sha256"))
                    break;
                if (fk == 1 /* process */ && !shux_link_obj_needs_undef_sym(user_o, "process_shux_argv_get")
                    && !shux_link_obj_needs_undef_sym(user_o, "process_arg_c")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_process_exit")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_process_args"))
                    break;
                /*
                 * 【Why 根源】sync/atomic 预编 .o 经 -backend c 带 preamble weak process_arg*_c，
                 *   对 process_shux_* 有 U。无条件硬链 → 纯 asm（binop_var 等仅 U shux_panic_）
                 *   也拖入 sync/atomic → ld 缺 process_shux_argc_get（bstrict26）。
                 * 【Invariant】与 crypto/process 同：仅 user.o 有 std_sync_ 或 std_atomic_ 前缀 UNDEF 才推。
                 */
                if (fk == 2 /* thread */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_thread_spawn")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_thread_join")
                    && !shux_link_obj_needs_undef_sym(user_o, "thread_create_c")
                    && !shux_link_obj_needs_undef_sym(user_o, "thread_join_c"))
                    break;
                /* PLATFORM: SHARED — gate names must match std/sync export symbols
                 * (std_sync_lock / std_sync_new_mutex / …), not stale mutex_* mangling.
                 * Wrong probes → never push sync.o → never set have_sync → glue ensure skipped. */
                if (fk == 3 /* sync */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_sync_lock")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_sync_new_mutex")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_sync_try_lock")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_sync_wait")
                    && !shux_link_obj_needs_undef_sym(user_o, "sync_mutex_lock_c"))
                    break;
                if (fk == 6 /* atomic */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_atomic_store_i32_ptr_i32")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_atomic_load_i32_ptr")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_atomic_fetch_add_i32_ptr_i32")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_atomic_store_i64_ptr_i64")
                    && !shux_link_obj_needs_undef_sym(user_o, "atomic_store_i32_c"))
                    break;
                /*
                 * http.o 对 context/error/heap 有 U；无条件硬链 → 纯 asm（binop 仅 U panic）
                 * 也拖入 http → ld 缺 std_context_* / std_error_http_* / std_heap_*（bstrict29）。
                 * 与 crypto/sync 同：仅 user 有 std_http_ 入口 UNDEF 才推。
                 */
                if (fk == 13 /* http */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_http_get")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_http_request")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_http_client_new")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_http_request_timeout_ms_for_ctx"))
                    break;
                /*
                 * log.o 预编带 preamble weak process_arg*_c → U process_shux_*。
                 * 无条件硬链 → 纯 asm（binop_var 仅 U panic）在 run-log 建出 log.o 后
                 * 全红（bstrict42）。与 crypto/http 同：仅 user 有 std_log_ 入口才推。
                 */
                if (fk == 5 /* log */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_log_log")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_log_level_info")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_log_set_min_level")
                    && !shux_link_obj_needs_undef_sym(user_o, "log_write_c")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_log_structured_kv"))
                    break;
                /*
                 * channel/backtrace/math/sqlite/elf/dynlib：预编 .o 常带 preamble weak
                 * process_arg*_c → U process_shux_*。无条件硬链会毒化纯 asm（bstrict44：
                 * 预建 dynlib.o 后 binop_var 红）。与 log/crypto 同：仅 user 有入口 UNDEF 才推。
                 */
                if (fk == 7 /* channel */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_channel_send")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_channel_recv")
                    && !shux_link_obj_needs_undef_sym(user_o, "channel_send")
                    && !shux_link_obj_needs_undef_sym(user_o, "channel_recv"))
                    break;
                if (fk == 8 /* backtrace */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_backtrace_capture")
                    && !shux_link_obj_needs_undef_sym(user_o, "backtrace_capture"))
                    break;
                /*
                 * PLATFORM: SHARED — math gate must cover full std.math surface, not only sin/cos.
                 * Residual: tests/math/main.x uses pi/e/floor/ceil/sqrt/abs/signum → U std_math_*
                 * but old probes only sin/cos → -backend asm never pushed math.o (Ubuntu L2).
                 * G.7: complete existing fk==9 authority (no second needs_math path).
                 * have_math also pulls GLUE_MATH (libm) + process_argv complement below.
                 */
                if (fk == 9 /* math */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_sin")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_cos")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_tan")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_pi")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_e")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_tau")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_floor")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_ceil")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_trunc")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_round")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_sqrt")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_cbrt")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_pow")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_exp")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_log")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_abs")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_signum")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_min")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_max")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_asin")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_acos")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_atan")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_math_atan2")
                    && !shux_link_obj_needs_undef_sym(user_o, "math_sin")
                    && !shux_link_obj_needs_undef_sym(user_o, "math_cos")
                    && !shux_link_obj_needs_undef_sym(user_o, "math_sin_c")
                    && !shux_link_obj_needs_undef_sym(user_o, "math_cos_c")
                    && !shux_link_obj_needs_undef_sym(user_o, "math_floor_c")
                    && !shux_link_obj_needs_undef_sym(user_o, "math_pi_c"))
                    break;
                if (fk == 10 /* sqlite */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_db_sqlite")
                    && !shux_link_obj_needs_undef_sym(user_o, "sqlite3_open")
                    && !shux_link_obj_needs_undef_sym(user_o, "db_sqlite_open"))
                    break;
                if (fk == 11 /* elf */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_elf_parse")
                    && !shux_link_obj_needs_undef_sym(user_o, "elf_parse"))
                    break;
                if (fk == 12 /* dynlib */
                    && !shux_link_obj_needs_undef_sym(user_o, "std_dynlib_open")
                    && !shux_link_obj_needs_undef_sym(user_o, "std_dynlib_sym")
                    && !shux_link_obj_needs_undef_sym(user_o, "dynlib_open_c")
                    && !shux_link_obj_needs_undef_sym(user_o, "dynlib_open"))
                    break;
            } else if (fk == 0 && rel && rel[0] && !labi_std_fk0_user_needs_rel(user_o, rel)) {
                break;
            }
            if (rel && rel[0]) {
                /*
                 * PLATFORM: SHARED — L4 wipe deletes gitignored formal std|core .o.
                 * push_obj alone silent-skips missing files → Ubuntu asm BLD001 UNDEF
                 * (e.g. std_vec_len_empty after true-cold). G.7: complete the existing
                 * ensure authority (was only fk==9 math); do not invent a second path.
                 * make_target is relative to compiler/ (../std/... or ../core/...).
                 */
                if (user_o && user_o[0]
                    && ((rel[0] == 's' && strncmp(rel, "std/", 4) == 0)
                        || (rel[0] == 'c' && strncmp(rel, "core/", 5) == 0))) {
                    const char *include_root = shux_repo_root_from_argv0(link_argv0);
                    char make_tgt[PATH_MAX];
                    if (include_root && include_root[0]
                        && (size_t)snprintf(make_tgt, sizeof make_tgt, "../%s", rel) < sizeof make_tgt) {
                        (void)shux_ensure_formal_std_make_o(include_root, rel, make_tgt);
                        /*
                         * Formal vec/set/map .o carry U std_heap_* / core_mem_*.
                         * Mirror invoke_cc need_vec companions (ensure + push).
                         */
                        if (strstr(rel, "std/vec/vec.o") || strstr(rel, "std/set/set.o")
                            || strstr(rel, "std/map/map.o")) {
                            (void)shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o",
                                                                "../std/heap/heap.o");
                            (void)shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o",
                                                                "../core/mem/mem.o");
                            link_abi_asm_ld_push_obj(NULL, link_argv0, "std/heap/heap.o", lib_roots,
                                                     n_lib_roots, bank, argv, la, max_la, NULL);
                            link_abi_asm_ld_push_obj(NULL, link_argv0, "core/mem/mem.o", lib_roots,
                                                     n_lib_roots, bank, argv, la, max_la, NULL);
                        }
                        /*
                         * PLATFORM: SHARED — formal env.o U env_*_c lives in runtime_env_os.o.
                         * PRIMARY_ENV_OS may already have pushed; companion here covers the case
                         * where env.o is pulled via fk0 after PRIMARY was gated off incorrectly.
                         */
                        if (strstr(rel, "std/env/env.o")) {
                            if (shux_ensure_runtime_env_os_o(link_argv0) == 0)
                                link_abi_asm_ld_push_obj(shux_runtime_env_os_o_path(link_argv0), link_argv0,
                                    "compiler/runtime_env_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
                        }
                        /* PLATFORM: SHARED — formal random.o U random_fill_bytes_c. */
                        if (strstr(rel, "std/random/random.o")) {
                            if (shux_ensure_runtime_random_fill_o(link_argv0) == 0)
                                link_abi_asm_ld_push_obj(shux_runtime_random_fill_o_path(link_argv0), link_argv0,
                                    "compiler/runtime_random_fill.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
                        }
                        /* PLATFORM: SHARED — formal time.o U time_*_c (mirrors on_demand pair). */
                        if (strstr(rel, "std/time/time.o")) {
                            if (shux_ensure_runtime_time_os_o(link_argv0) == 0)
                                link_abi_asm_ld_push_obj(shux_runtime_time_os_o_path(link_argv0), link_argv0,
                                    "compiler/runtime_time_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
                        }
                    }
                }
                link_abi_asm_ld_push_obj(NULL, link_argv0, rel, lib_roots, n_lib_roots, bank, argv, la, max_la, flag_out);
            }
            break;
        case LABI_STD_OP_GLUE_THREAD:
            link_abi_asm_ld_push_glue_after_std(flags && flags->have_thread, shux_ensure_runtime_thread_glue_o,
                shux_runtime_thread_glue_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_thread_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            break;
        case LABI_STD_OP_GLUE_SYNC_PAIR:
            if (flags && flags->have_sync) {
                link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_sync_lock_diag_tls_o,
                    shux_runtime_sync_lock_diag_tls_o_path(link_argv0), link_argv0,
                    "compiler/runtime_sync_lock_diag_tls.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
                link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_sync_os_o,
                    shux_runtime_sync_os_o_path(link_argv0), link_argv0,
                    "compiler/runtime_sync_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            }
            break;
        case LABI_STD_OP_GLUE_CRYPTO_PAIR:
            if (have_crypto) {
                link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_ed25519_ref10_glue_o,
                    shux_runtime_ed25519_ref10_glue_o_path(link_argv0), link_argv0,
                    "compiler/runtime_ed25519_ref10_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
                link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_crypto_inc_glue_o,
                    shux_runtime_crypto_inc_glue_o_path(link_argv0), link_argv0,
                    "compiler/runtime_crypto_inc_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            }
            break;
        case LABI_STD_OP_GLUE_LOG:
            link_abi_asm_ld_push_glue_after_std(have_log, shux_ensure_runtime_log_os_o,
                shux_runtime_log_os_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_log_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            break;
        case LABI_STD_OP_GLUE_ATOMIC:
            link_abi_asm_ld_push_glue_after_std(have_atomic, shux_ensure_runtime_atomic_glue_o,
                shux_runtime_atomic_glue_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_atomic_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            break;
        case LABI_STD_OP_GLUE_CHANNEL:
            link_abi_asm_ld_push_glue_after_std(flags && flags->have_channel, shux_ensure_runtime_channel_glue_o,
                shux_runtime_channel_glue_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_channel_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            break;
        case LABI_STD_OP_GLUE_BACKTRACE:
            link_abi_asm_ld_push_glue_after_std(have_backtrace, shux_ensure_runtime_backtrace_platform_o,
                shux_runtime_backtrace_platform_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_backtrace_platform.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            break;
        case LABI_STD_OP_GLUE_MATH:
            link_abi_asm_ld_push_glue_after_std(flags && flags->have_math, shux_ensure_runtime_math_libm_o,
                shux_runtime_math_libm_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_math_libm.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            break;
        case LABI_STD_OP_GLUE_SQLITE:
            link_abi_asm_ld_push_glue_after_std(flags && flags->have_sqlite, shux_ensure_runtime_sqlite_glue_o,
                shux_runtime_sqlite_glue_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_sqlite_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            break;
        case LABI_STD_OP_GLUE_DYNLIB:
            link_abi_asm_ld_push_glue_after_std(flags && flags->have_dynlib, shux_ensure_runtime_dynlib_os_o,
                shux_runtime_dynlib_os_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_dynlib_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            break;
        case LABI_STD_OP_GLUE_HTTP:
            link_abi_asm_ld_push_glue_after_std(have_http, shux_ensure_runtime_http_glue_o,
                shux_runtime_http_glue_o_path(link_argv0), link_argv0,
                rel ? rel : "compiler/runtime_http_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            break;
        case LABI_STD_OP_TASK_SPECIAL:
            /* PLATFORM: SHARED — gate bulk task+scheduler on user UNDEF (see labi_user_needs_std_task). */
            if (user_o && user_o[0] && !labi_user_needs_std_task(user_o))
                break;
            {
                const char *task_rel = rel ? rel : "std/task/task.o";
                /* L4 wipe: formal ensure when user actually needs task (G.7 complete). */
                if (user_o && user_o[0]) {
                    const char *include_root = shux_repo_root_from_argv0(link_argv0);
                    char make_tgt[PATH_MAX];
                    if (include_root && include_root[0]
                        && (size_t)snprintf(make_tgt, sizeof make_tgt, "../%s", task_rel) < sizeof make_tgt) {
                        (void)shux_ensure_formal_std_make_o(include_root, task_rel, make_tgt);
                    }
                }
                p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, task_rel));
                if (!p && bank)
                    p = shux_asm_ld_try_under_lib_roots(task_rel, lib_roots, n_lib_roots, bank);
                if (p && la && *la < max_la - 1) {
                    const char *task_o;
                    if (bank) {
                        const char *bp = shux_asm_ld_bank_push(bank, p);
                        if (bp)
                            p = bp;
                    }
                    task_o = p;
                    if (!link_abi_asm_ld_argv_has_obj(argv, *la, p))
                        argv[(*la)++] = p;
                    {
                        const char *sched = scheduler_o_for_task_link(task_o, NULL);
                        if (!sched)
                            sched = asm_link_obj_skip_missing(shux_std_async_scheduler_o_path(link_argv0));
                        if (!sched && bank)
                            sched = shux_asm_ld_try_under_lib_roots("std/async/scheduler.o", lib_roots, n_lib_roots, bank);
                        if (sched && bank) {
                            const char *sb = shux_asm_ld_bank_push(bank, sched);
                            if (sb)
                                sched = sb;
                        }
                        if (sched && *la < max_la - 1 && !link_abi_asm_ld_argv_has_obj(argv, *la, sched))
                            argv[(*la)++] = sched;
                        if (sched && *la < max_la - 1) {
                            (void)shux_ensure_runtime_scheduler_glue_o(link_argv0);
                            {
                                const char *rsg = asm_link_obj_skip_missing(shux_runtime_scheduler_glue_o_path(link_argv0));
                                if (!rsg && bank)
                                    rsg = shux_asm_ld_try_under_lib_roots("compiler/runtime_scheduler_glue.o", lib_roots, n_lib_roots, bank);
                                if (rsg && bank) {
                                    const char *rb = shux_asm_ld_bank_push(bank, rsg);
                                    if (rb)
                                        rsg = rb;
                                }
                                if (rsg && *la < max_la - 1 && !link_abi_asm_ld_argv_has_obj(argv, *la, rsg))
                                    argv[(*la)++] = rsg;
                            }
                        }
                    }
                }
            }
            break;
        default:
            break;
        }
    }
    /*
     * thread/sync/atomic/log/dynlib/… 预编 .o 内 preamble weak process_arg*_c → U process_shux_*。
     * 已推且未推 process.o 时补 runtime_process_argv.o（勿与 process.o 双链）。
     */
    if ((have_atomic || have_log || have_backtrace
         || (flags && (flags->have_sync || flags->have_thread || flags->have_dynlib
                       || flags->have_channel || flags->have_math || flags->have_elf
                       || flags->have_sqlite)))
        && !have_process) {
        (void)shux_ensure_runtime_process_argv_o(link_argv0);
        link_abi_asm_ld_push_obj(shux_runtime_process_argv_o_path(link_argv0), link_argv0,
            "compiler/runtime_process_argv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
}

/* G-02f-272 L8b on_demand list pure */
#ifndef SHUX_LABI_ONDEMAND_LIST_FROM_X
#include "seeds/labi_ondemand_list.from_x.c"
#else
int labi_od_simple_group_count(void);
int labi_od_simple_group_sym_count(int g);
const char *labi_od_simple_group_sym_at(int g, int i);
const char *labi_od_simple_group_rel(int g);
int labi_od_kv_sym_count(void);
const char *labi_od_kv_sym_at(int i);
const char *labi_od_kv_rel(void);
const char *labi_od_kv_glue_rel(void);
int labi_od_arrow_sym_count(void);
const char *labi_od_arrow_sym_at(int i);
const char *labi_od_arrow_rel(void);
const char *labi_od_arrow_glue_rel(void);
int labi_od_time_sym_count(void);
const char *labi_od_time_sym_at(int i);
const char *labi_od_time_rel(void);
const char *labi_od_time_os_rel(void);
int labi_od_queue_sym_count(void);
const char *labi_od_queue_sym_at(int i);
const char *labi_od_queue_rel(void);
const char *labi_od_queue_contention_rel(void);
/* wave118–135 needs_std_net/set/map/queue/test + needs_core_mem/slice + needs_std_heap_page_mmap + needs_std_sys_linux + needs_std_sys + needs_std_heap_api + needs_heap_user_syms + needs_async_scheduler + compress family + labi_user_needs_runtime time_os/random_fill/env_os/process_argv + labi_user_needs_std_task + labi_std_fk0_user_needs_rel pure orch (L8b pure .x / cold seed). */
int labi_od_net_sym_count(void);
const char *labi_od_net_sym_at(int i);
int link_abi_user_o_needs_std_net(const char *user_o);
int labi_od_set_sym_count(void);
const char *labi_od_set_sym_at(int i);
int link_abi_user_o_needs_std_set(const char *user_o);
int labi_od_map_sym_count(void);
const char *labi_od_map_sym_at(int i);
int link_abi_user_o_needs_std_map(const char *user_o);
int labi_od_queue_api_sym_count(void);
const char *labi_od_queue_api_sym_at(int i);
int link_abi_user_o_needs_std_queue(const char *user_o);
int labi_od_test_sym_count(void);
const char *labi_od_test_sym_at(int i);
int link_abi_user_o_needs_std_test(const char *user_o);
int labi_od_core_mem_sym_count(void);
const char *labi_od_core_mem_sym_at(int i);
int link_abi_user_o_needs_core_mem(const char *user_o);
int labi_od_core_slice_sym_count(void);
const char *labi_od_core_slice_sym_at(int i);
int link_abi_user_o_needs_core_slice(const char *user_o);
int labi_od_page_mmap_sym_count(void);
const char *labi_od_page_mmap_sym_at(int i);
int link_abi_user_o_needs_std_heap_page_mmap(const char *user_o);
int labi_od_sys_linux_sym_count(void);
const char *labi_od_sys_linux_sym_at(int i);
int link_abi_user_o_needs_std_sys_linux(const char *user_o);
int labi_od_sys_sym_count(void);
const char *labi_od_sys_sym_at(int i);
int link_abi_user_o_needs_std_sys(const char *user_o);
int labi_od_heap_api_sym_count(void);
const char *labi_od_heap_api_sym_at(int i);
int link_abi_user_o_needs_std_heap_api(const char *user_o);
int labi_od_heap_user_sym_count(void);
const char *labi_od_heap_user_sym_at(int i);
int link_abi_user_o_needs_heap_user_syms(const char *user_o);
int labi_od_async_scheduler_sym_count(void);
const char *labi_od_async_scheduler_sym_at(int i);
int link_abi_user_o_needs_async_scheduler(const char *user_o);
int labi_od_zlib_undef_sym_count(void);
const char *labi_od_zlib_undef_sym_at(int i);
const char *labi_od_compress_zlib_marker(void);
int labi_od_zstd_undef_sym_count(void);
const char *labi_od_zstd_undef_sym_at(int i);
const char *labi_od_compress_zstd_marker(void);
int labi_od_brotli_undef_sym_count(void);
const char *labi_od_brotli_undef_sym_at(int i);
const char *labi_od_compress_brotli_marker(void);
int link_abi_obj_needs_zlib(const char *obj_o);
int link_abi_obj_needs_zstd(const char *obj_o);
int link_abi_obj_needs_brotli(const char *obj_o);
int link_abi_user_o_needs_compress_libs(const char *user_o);
int labi_od_runtime_time_os_sym_count(void);
const char *labi_od_runtime_time_os_sym_at(int i);
int labi_user_needs_runtime_time_os(const char *user_o);
int labi_od_runtime_random_fill_sym_count(void);
const char *labi_od_runtime_random_fill_sym_at(int i);
int labi_user_needs_runtime_random_fill(const char *user_o);
int labi_od_runtime_env_os_sym_count(void);
const char *labi_od_runtime_env_os_sym_at(int i);
int labi_user_needs_runtime_env_os(const char *user_o);
int labi_od_runtime_process_argv_sym_count(void);
const char *labi_od_runtime_process_argv_sym_at(int i);
int labi_user_needs_runtime_process_argv(const char *user_o);
int labi_od_std_task_sym_count(void);
const char *labi_od_std_task_sym_at(int i);
int labi_user_needs_std_task(const char *user_o);
int labi_fk0_rel_count(void);
const char *labi_fk0_rel_at(int k);
int labi_fk0_sym_count(int k);
const char *labi_fk0_sym_at(int k, int i);
int labi_std_fk0_user_needs_rel(const char *user_o, const char *rel);
const char *labi_od_rel_net(void);
const char *labi_od_rel_thread(void);
const char *labi_od_rel_heap(void);
const char *labi_od_rel_set(void);
const char *labi_od_rel_map(void);
const char *labi_od_rel_async_scheduler(void);
const char *labi_od_rel_core_mem(void);
const char *labi_od_rel_sys_linux(void);
const char *labi_od_rel_page_mmap(void);
const char *labi_od_rel_sys(void);
const char *labi_od_rel_core_slice(void);
const char *labi_od_rel_test(void);
const char *labi_od_rel_heap_user(void);
const char *labi_od_rel_scheduler_glue(void);
const char *labi_od_rel_thread_glue(void);
const char *labi_od_rel_net_udp_batch(void);
const char *labi_od_rel_net_workers(void);
const char *labi_od_rel_test_fn_invoke(void);
#endif

/* local helper: any of pure-table syms undefined in user_o (nm). */
static int labi_od_user_needs_any_sym_table(const char *user_o, int n, const char *(*sym_at)(int)) {
    int i;
    if (!user_o || !user_o[0] || n <= 0 || !sym_at)
        return 0;
    for (i = 0; i < n; i++) {
        const char *s = sym_at(i);
        if (s && s[0] && shux_link_obj_needs_undef_sym(user_o, s))
            return 1;
    }
    return 0;
}

static int labi_od_user_needs_simple_group(const char *user_o, int g) {
    int n = labi_od_simple_group_sym_count(g);
    int i;
    if (!user_o || !user_o[0] || n <= 0)
        return 0;
    for (i = 0; i < n; i++) {
        const char *s = labi_od_simple_group_sym_at(g, i);
        if (s && s[0] && shux_link_obj_needs_undef_sym(user_o, s))
            return 1;
    }
    return 0;
}

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-272：on_demand 列表纯表 + 本函数 IO 解释 */
void shux_asm_ld_append_on_demand_user_objs(const char *link_argv0, const char *user_o,
    const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank,
    const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags) {
#if defined(__linux__) || defined(__APPLE__)
    const char *p;
    int sg;
    if (!user_o || !user_o[0] || !la || *la >= max_la - 1)
        return;
    if (link_abi_user_o_needs_std_net(user_o)) {
        int have_net = 0;
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_net(), lib_roots, n_lib_roots, bank, argv, la, max_la, &have_net);
        if (have_net) {
            if (flags)
                flags->have_net = 1;
            /* workers.x 依赖 thread_create_c；按需再推 thread.o + glue（默认 ld 可能未链）。 */
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_thread(), lib_roots, n_lib_roots, bank, argv, la, max_la,
                flags ? &flags->have_thread : NULL);
            if (flags && flags->have_thread) {
                link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_thread_glue_o,
                    shux_runtime_thread_glue_o_path(link_argv0), link_argv0,
                    labi_od_rel_thread_glue(), lib_roots, n_lib_roots, bank, argv, la, max_la);
            }
            link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_net_udp_batch_o,
                shux_runtime_net_udp_batch_o_path(link_argv0), link_argv0,
                labi_od_rel_net_udp_batch(), lib_roots, n_lib_roots, bank, argv, la, max_la);
            link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_net_workers_o,
                shux_runtime_net_workers_o_path(link_argv0), link_argv0,
                labi_od_rel_net_workers(), lib_roots, n_lib_roots, bank, argv, la, max_la);
        }
    }
    if (link_abi_link_needs_std_heap_import(user_o, argv, la ? *la : 0)) {
        /* heap.o → core.mem：user 已 co-emit 提供 T 时勿链 mem/heap（duplicate）。 */
        if (!link_abi_user_o_provides_core_mem(user_o)) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (!link_abi_user_o_provides_std_heap(user_o)) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_heap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    /*
     * PLATFORM: SHARED — set/map product asm: formal .o + heap/core_mem/(hash for set).
     * Align companions with C invoke_cc need_set/need_map (G.7 complete, no second path).
     * L4 wipe: ensure formal .o via Makefile before push.
     */
    if (link_abi_user_o_needs_std_set(user_o)) {
        const char *include_root = shux_repo_root_from_argv0(link_argv0);
        if (include_root && include_root[0]) {
            (void)shux_ensure_formal_std_make_o(include_root, "std/set/set.o", "../std/set/set.o");
            (void)shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
            (void)shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
            (void)shux_ensure_formal_std_make_o(include_root, "std/hash/hash.o", "../std/hash/hash.o");
        }
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_set(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_heap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        /* set.o → U std_hash_bytes; fk0 hash gate is user-only and misses set.o. */
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/hash/hash.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    if (link_abi_user_o_needs_std_map(user_o)) {
        const char *include_root = shux_repo_root_from_argv0(link_argv0);
        if (include_root && include_root[0]) {
            (void)shux_ensure_formal_std_make_o(include_root, "std/map/map.o", "../std/map/map.o");
            (void)shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
            (void)shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
        }
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_map(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        /* map.o U: typed libc heap + map_find; user may only U empty_size. */
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_heap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    if (link_abi_user_o_needs_async_scheduler(user_o)) {
        p = asm_link_obj_skip_missing(shux_std_async_scheduler_o_path(link_argv0));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots(labi_od_rel_async_scheduler(), lib_roots, n_lib_roots, bank);
        if (p && *la < max_la - 1)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p && *la < max_la - 1) {
            const char *rsg = asm_link_obj_skip_missing(shux_runtime_scheduler_glue_o_path(link_argv0));
            if (!rsg && bank)
                rsg = shux_asm_ld_try_under_lib_roots(labi_od_rel_scheduler_glue(), lib_roots, n_lib_roots, bank);
            if (rsg)
                link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, rsg);
        }
    }
    if (link_abi_user_o_needs_core_mem(user_o)) {
        p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, labi_od_rel_core_mem()));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots(labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
    }
    /*
     * F-no-libc NL-03：freestanding mmap bump 堆按需链入。
     * 【Why 根源】page_mmap.x 固定 import std.sys.linux + core.mem，故链 page_mmap.o 须同时
     * 链 linux.o + core_mem.o；sys.o 传递依赖 linux.o。--gc-sections 移除未引用的 hosted 函数。
     * 【Invariant】顺序：linux.o → core_mem.o → page_mmap.o / sys.o（被依赖者先入链）。
     *
     * G-03 freestanding co-emit 守卫：freestanding 模式下 dep 模块经 co-emit 已 emit 到 user.o
     * （#[cfg(not(freestanding))] 剪枝 hosted 函数，仅留 syscall 桩/const）。预编译 std/sys/linux.o
     * 等是 hosted 编译产物（含 linux_mmap_rw → libc open/lseek/ftruncate），链入会泄漏 undefined
     * 引用；且 consts（syscall_nr_write）与 co-emit 重复定义。故 freestanding 模式跳过整块，
     * 完全依赖 co-emit 提供的 freestanding-safe 子集。
     */
    if (!driver_freestanding_get()) {
        int need_page_mmap = link_abi_user_o_needs_std_heap_page_mmap(user_o);
        int need_sys_linux = link_abi_user_o_needs_std_sys_linux(user_o);
        int need_sys = link_abi_user_o_needs_std_sys(user_o);
        int ai;
        /*
         * PLATFORM: SHARED / LINUX gold — formal heap.o carries U page_mmap_* even when
         * user.o only has std_string_* / std_heap_* API UNDEFs. Scan already-pushed argv
         * (heap.o from on_demand above) so string/wa chain gets page_mmap.o.
         * G.7: extend existing page_mmap probe authority (no second path).
         */
        if (argv && la) {
            for (ai = 0; ai < *la && argv[ai]; ai++) {
                if (!link_abi_ld_argv_entry_is_obj(argv[ai]))
                    continue;
                if (link_abi_user_o_needs_std_heap_page_mmap(argv[ai]))
                    need_page_mmap = 1;
                if (link_abi_user_o_needs_std_sys_linux(argv[ai]))
                    need_sys_linux = 1;
                if (link_abi_user_o_needs_std_sys(argv[ai]))
                    need_sys = 1;
            }
        }
        if (need_sys_linux || need_page_mmap || need_sys) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_sys_linux(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (need_page_mmap || need_sys) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (need_page_mmap) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_page_mmap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (need_sys) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_sys(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    if (link_abi_user_o_needs_core_slice(user_o)) {
        p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, labi_od_rel_core_slice()));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots(labi_od_rel_core_slice(), lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
    }
    if (labi_od_user_needs_any_sym_table(user_o, labi_od_kv_sym_count(), labi_od_kv_sym_at)) {
        p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, labi_od_kv_rel()));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots(labi_od_kv_rel(), lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p && *la < max_la - 1) {
            const char *rkv = asm_link_obj_skip_missing(shux_runtime_kv_mmap_glue_o_path(link_argv0));
            if (!rkv && bank)
                rkv = shux_asm_ld_try_under_lib_roots(labi_od_kv_glue_rel(), lib_roots, n_lib_roots, bank);
            if (rkv)
                link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, rkv);
        }
    }
    if (labi_od_user_needs_any_sym_table(user_o, labi_od_arrow_sym_count(), labi_od_arrow_sym_at)) {
        p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, labi_od_arrow_rel()));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots(labi_od_arrow_rel(), lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p && *la < max_la - 1) {
            const char *rar = asm_link_obj_skip_missing(shux_runtime_arrow_simd_glue_o_path(link_argv0));
            if (!rar && bank)
                rar = shux_asm_ld_try_under_lib_roots(labi_od_arrow_glue_rel(), lib_roots, n_lib_roots, bank);
            if (rar)
                link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, rar);
        }
    }
    if (link_abi_user_o_needs_std_test(user_o)) {
        int have_test = 0;
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_test(), lib_roots, n_lib_roots, bank, argv, la, max_la, &have_test);
        link_abi_asm_ld_push_glue_after_std(have_test, shux_ensure_runtime_test_fn_invoke_o,
            shux_runtime_test_fn_invoke_o_path(link_argv0), link_argv0,
            labi_od_rel_test_fn_invoke(), lib_roots, n_lib_roots, bank, argv, la, max_la);
    }
    /*
     * PLATFORM: LINUX freestanding / SHARED gate —
     * runtime_heap_user.o wraps libc malloc/free/realloc. Under -freestanding
     * (-nostdlib) that yields U malloc. Zero-libc product heap is page_mmap
     * (co-emit or formal); never push heap_user on freestanding links.
     * G.7: complete existing heap_user on_demand authority (no second path).
     */
    if (!driver_freestanding_get() && link_abi_link_needs_heap_user_c(user_o, argv, la ? *la : 0)) {
        if (shux_ensure_runtime_heap_user_o(link_argv0) != 0)
            return;
        link_abi_asm_ld_push_obj(shux_runtime_heap_user_o_path(link_argv0), link_argv0, labi_od_rel_heap_user(),
                                 lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        if (flags)
            flags->have_libc_heap = 1;
    }
    /* Simple multi-sym groups → single rel (pure table). Formal ensure for core/*.o. */
    {
        int pushed_core_formal = 0;
        for (sg = 0; sg < labi_od_simple_group_count(); sg++) {
            const char *rel = labi_od_simple_group_rel(sg);
            if (!rel || !rel[0])
                continue;
            if (!labi_od_user_needs_simple_group(user_o, sg))
                continue;
            /* PLATFORM: SHARED — L4 wipe drops gitignored core types/option/result/debug/slice .o;
             * ensure via Makefile before push (same pattern as formal vec/math).
             * g9 core/slice/mod.o is formal API; glue slice.o is pushed immediately after. */
            if (strstr(rel, "core/types/") || strstr(rel, "core/option/") || strstr(rel, "core/result/")
                || strstr(rel, "core/debug/") || strstr(rel, "core/slice/")) {
                const char *include_root = shux_repo_root_from_argv0(link_argv0);
                char make_tgt[PATH_MAX];
                if (include_root && include_root[0] &&
                    (size_t)snprintf(make_tgt, sizeof make_tgt, "../%s", rel) < sizeof make_tgt)
                    (void)shux_ensure_formal_std_make_o(include_root, rel, make_tgt);
                pushed_core_formal = 1;
            }
            link_abi_asm_ld_push_obj(NULL, link_argv0, rel, lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            /* PLATFORM: SHARED — formal mod.o U from_ptr/subslice → always co-push glue slice.o.
             * User.o for length.x has no U core_slice_*_from_ptr_c, so needs_core_slice alone misses glue. */
            if (strstr(rel, "core/slice/mod.o")) {
                const char *include_root = shux_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0])
                    (void)shux_ensure_formal_std_make_o(include_root, "core/slice/slice.o",
                                                        "../core/slice/slice.o");
                link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_slice(), lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
            }
        }
        /*
         * Formal core/*.o from shux_compile_std_module carry preamble weak process_arg*_c
         * → U process_shux_*. Same complement as sync/atomic: push process_argv (not process.o).
         * PLATFORM: SHARED — Ubuntu asm si residual after ELF UNDEF scan.
         */
        if (pushed_core_formal) {
            (void)shux_ensure_runtime_process_argv_o(link_argv0);
            link_abi_asm_ld_push_obj(shux_runtime_process_argv_o_path(link_argv0), link_argv0,
                "compiler/runtime_process_argv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    /*
     * PLATFORM: SHARED — string/heap/vec/mem formal .o carry preamble weak process_arg*_c
     * → U process_shux_*. fk0 string push does not set have_math/sync flags, so the std_objs
     * process_argv complement never fired (Ubuntu string_asm residual).
     * G.7: complete existing process_argv complement by scanning argv after on_demand.
     */
    if (argv && la) {
        int need_pav = 0;
        int ai;
        int have_process_o = 0;
        for (ai = 0; ai < *la && argv[ai]; ai++) {
            const char *e = argv[ai];
            if (!link_abi_ld_argv_entry_is_obj(e))
                continue;
            if (strstr(e, "process.o") && !strstr(e, "process_argv"))
                have_process_o = 1;
            if (shux_link_obj_needs_undef_sym(e, "process_shux_argc_get")
                || shux_link_obj_needs_undef_sym(e, "process_shux_argv_get"))
                need_pav = 1;
        }
        if (need_pav && !have_process_o) {
            (void)shux_ensure_runtime_process_argv_o(link_argv0);
            link_abi_asm_ld_push_obj(shux_runtime_process_argv_o_path(link_argv0), link_argv0,
                "compiler/runtime_process_argv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    if (labi_od_user_needs_any_sym_table(user_o, labi_od_time_sym_count(), labi_od_time_sym_at)) {
        /* PLATFORM: SHARED — L4 wipe drops formal time.o; push_obj skip_missing alone
         * leaves U std_time_*. G.7: ensure formal before push (same as plan STD block). */
        {
            const char *include_root = shux_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0])
                (void)shux_ensure_formal_std_make_o(include_root, "std/time/time.o",
                                                    "../std/time/time.o");
        }
        if (shux_ensure_runtime_time_os_o(link_argv0) == 0)
            link_abi_asm_ld_push_obj(shux_runtime_time_os_o_path(link_argv0), link_argv0,
                                     labi_od_time_os_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_time_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    /*
     * PLATFORM: SHARED — product queue (std_queue_*) + contention table.
     * G.7: complete queue on_demand (product needs_std_queue + existing od_queue table).
     */
    {
        int need_q_product = link_abi_user_o_needs_std_queue(user_o);
        int need_q_contention = labi_od_user_needs_any_sym_table(user_o, labi_od_queue_sym_count(), labi_od_queue_sym_at);
        if (need_q_product || need_q_contention) {
            const char *include_root = shux_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0]) {
                (void)shux_ensure_formal_std_make_o(include_root, "std/queue/queue.o", "../std/queue/queue.o");
                (void)shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
                (void)shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
            }
            if (need_q_contention) {
                (void)shux_ensure_runtime_queue_contention_o(link_argv0);
                link_abi_asm_ld_push_obj(shux_runtime_queue_contention_o_path(link_argv0), link_argv0,
                    labi_od_queue_contention_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            }
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_queue_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_heap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
#else
    (void)link_argv0;
    (void)user_o;
    (void)lib_roots;
    (void)n_lib_roots;
    (void)bank;
    (void)argv;
    (void)la;
    (void)max_la;
    (void)flags;
#endif
}




/**
 * invoke_ld / driver_asm_invoke_ld 共用：ensure 链入对象并校验 freestanding 仅 Linux ELF。
 * 参数：link_eff 有效 link argv0；user_o 用户 .o；driver_freestanding 同 shux_link_freestanding_enabled。
 * 返回值：0 成功，-1 失败。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_asm_ld_prepare_for_exe_link(const char *link_eff, const char *user_o, int driver_freestanding,
    int use_macho_o, int use_coff_o) {
    /* #region debug-point A:prepare-enter */
    shux_debug_hello_stage1_report("A", "runtime_link_abi.c:4427", "prepare_for_exe_link_enter", driver_freestanding, use_macho_o, use_coff_o);
    /* #endregion */
    if (!link_eff || !user_o)
        return -1;
#if defined(__linux__)
    if (shux_link_freestanding_enabled(driver_freestanding)) {
        if (shux_freestanding_user_o_needs_panic(user_o)) {
            if (shux_ensure_runtime_panic_o(link_eff) != 0)
                return -1;
        }
    } else
#endif
    {
        if (shux_ensure_runtime_panic_o(link_eff) != 0)
            return -1;
    }
    if (!shux_link_freestanding_enabled(driver_freestanding)) {
        /*
         * PLATFORM: SHARED — minimal always-on runtime for hosted asm links:
         * io stubs only. process_argv + random_fill / time_os / env_os: gate on
         * user.o UNDEF (labi_user_needs_runtime_*). Pure rv/hello must not fork-cc
         * those seeds on every -o. Complements + C post-module scan ensure transitive
         * process_shux_*. G.7: complete existing prepare_for_exe_link.
         * glue (sqlite/http/sync/…) stays on-demand via plan steps / skip_missing.
         */
        if (shux_ensure_runtime_asm_io_stubs_o(link_eff) != 0)
            return -1;
        if (labi_user_needs_runtime_process_argv(user_o)) {
            if (shux_ensure_runtime_process_argv_o(link_eff) != 0)
                return -1;
        }
        if (labi_user_needs_runtime_random_fill(user_o)) {
            if (shux_ensure_runtime_random_fill_o(link_eff) != 0)
                return -1;
        }
        if (labi_user_needs_runtime_time_os(user_o)) {
            if (shux_ensure_runtime_time_os_o(link_eff) != 0)
                return -1;
        }
        if (labi_user_needs_runtime_env_os(user_o)) {
            if (shux_ensure_runtime_env_os_o(link_eff) != 0)
                return -1;
        }
    }
    if (shux_ensure_crt0_user_o(link_eff, driver_freestanding) != 0)
        return -1;
#if defined(__linux__)
    if (shux_link_freestanding_enabled(driver_freestanding) && shux_freestanding_user_o_needs_io(user_o)) {
        if (shux_ensure_freestanding_io_o(link_eff, driver_freestanding) != 0)
            return -1;
    }
#endif
    if (shux_link_freestanding_enabled(driver_freestanding) && (use_macho_o || use_coff_o)) {
        link_diag_freestanding_unsupported();
        return -1;
    }
    /* #region debug-point E:prepare-exit */
    shux_debug_hello_stage1_report("A", "runtime_link_abi.c:4468", "prepare_for_exe_link_exit", 0, 0, 0);
    /* #endregion */
    return 0;
}




#if defined(__linux__) || defined(__APPLE__)
/**
 * 用户 .o 是否无任何未定义符号（nm -u 为空）；用于 Linux 最小 gcc 链 user.o+-lc。
 * 参数：o_path 用户对象路径。
 * 返回值：1 有未定义符号或 nm 失败（保守），0 完全自包含。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_asm_user_o_has_undef_syms(const char *o_path) {
    char cmd[PATH_MAX + 160];
    FILE *fp;
    char line[512];
    size_t i;
    if (!o_path || !o_path[0])
        return 1;
    if ((size_t)snprintf(cmd, sizeof cmd, "nm -u '%s' 2>/dev/null", o_path) >= sizeof cmd)
        return 1;
    fp = popen(cmd, "r");
    if (!fp) {
#if defined(__linux__)
        /* PLATFORM: LINUX freestanding — popen stub; any ELF UNDEF forces full on_demand path. */
        return shux_elf64_obj_scan_undef(o_path, NULL) ? 1 : 0;
#else
        return 0; /* nostdlib 无 popen：优先 gcc 最小链 user.o+-lc */
#endif
    }
    while (fgets(line, sizeof line, fp)) {
        for (i = 0; line[i]; i++) {
            if (line[i] != ' ' && line[i] != '\t' && line[i] != '\n' && line[i] != '\r') {
                pclose(fp);
                return 1;
            }
        }
    }
    pclose(fp);
    return 0;
}




#endif /* __linux__ || __APPLE__ */

/**
 * macOS asm ld/clang：按 std 链入标记追加 -lm、压缩库、-lsqlite3、-pthread、-lSystem。
 * G-02f-66：主体 _impl；.x 门闩 null 检查后转发。
 */
/* G-02f-275：mach tail -l* from pure table */
void shux_asm_ld_append_mach_tail_libs_impl(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    const char **argv, int *la, int max_la, int append_lsystem) {
    int need_pt;
    need_pt = flags->have_thread || flags->have_sync || flags->have_channel;
    if (flags->have_math && *la < max_la - 1)
        argv[(*la)++] = labi_ld_flag_lm();
    if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
        asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
    if (flags->have_sqlite && *la < max_la - 1)
        argv[(*la)++] = labi_ld_flag_lsqlite3();
    if (need_pt && *la < max_la - 1)
        argv[(*la)++] = labi_ld_flag_pthread();
    if (append_lsystem && *la < max_la - 1)
        argv[(*la)++] = labi_ld_flag_lSystem();
}

/* G-02f-277 L9 gates */
#ifndef SHUX_LABI_GATES_FROM_X
void shux_asm_ld_append_mach_tail_libs(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    const char **argv, int *la, int max_la, int append_lsystem) {
  if (flags == NULL) {
    return;
  }
  if (argv == NULL) {
    return;
  }
  if (la == NULL) {
    return;
  }
  if (*la < 0) {
    return;
  }
  {
    shux_asm_ld_append_mach_tail_libs_impl(compress_o, user_o, flags, argv, la, max_la, append_lsystem);
  }
}
#else
void shux_asm_ld_append_mach_tail_libs(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    const char **argv, int *la, int max_la, int append_lsystem);
#endif

/**
 * Linux/Unix gcc 或裸 ld 路径：按 std 链入标记追加 -pthread、-lm、压缩库、-ldl、-lc（F-03 v2/v3 无 -luring）。
 * G-02f-66：主体 _impl；.x 门闩 null 检查后转发。
 */
/* G-02f-275：unix tail -l* from pure table */
void shux_asm_ld_append_unix_gcc_tail_libs_impl(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    int need_pt, const char **argv, int *la, int max_la) {
    if (flags->have_io) {
        if (need_pt && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_pthread();
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lm();
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lsqlite3();
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_ldl();
#endif
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lc();
    } else if (flags->have_net && need_pt) {
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lpthread();
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lm();
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lsqlite3();
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_ldl();
#endif
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lc();
    } else if (flags->have_net) {
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lm();
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lsqlite3();
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_ldl();
#endif
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lc();
    } else if (need_pt) {
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lpthread();
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lm();
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lsqlite3();
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_ldl();
#endif
        if (*la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lc();
    } else {
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lm();
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lsqlite3();
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_ldl();
#endif
#if defined(__linux__) || defined(__APPLE__)
        if ((flags->have_libc_heap || flags->have_fs || flags->have_math || flags->have_compress || flags->have_sqlite
                || flags->have_dynlib) && *la < max_la - 1)
            argv[(*la)++] = labi_ld_flag_lc();
#endif
    }
}

/* G-02f-277 L9 gates */
#ifndef SHUX_LABI_GATES_FROM_X
void shux_asm_ld_append_unix_gcc_tail_libs(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    int need_pt, const char **argv, int *la, int max_la) {
  if (flags == NULL) {
    return;
  }
  if (argv == NULL) {
    return;
  }
  if (la == NULL) {
    return;
  }
  if (*la < 0) {
    return;
  }
  {
    shux_asm_ld_append_unix_gcc_tail_libs_impl(compress_o, user_o, flags, need_pt, argv, la, max_la);
  }
}
#else
void shux_asm_ld_append_unix_gcc_tail_libs(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    int need_pt, const char **argv, int *la, int max_la);
#endif

#if defined(__linux__)
/**
 * Linux release 链接硬化：PIE + NX（GNU_STACK 无 E）+ partial RELRO。
 * 参数：argv/la/cap 为 gcc/ld 链接 argv 构建状态。
 */
/* G-02f-274：linux harden flags from pure table */
void shux_append_linux_link_harden_impl(char *argv[], int *la, int cap) {
    int n;
    int k;
    if (!argv || !la || *la < 0)
        return;
    n = labi_linux_harden_flag_count();
    for (k = 0; k < n; k++) {
        const char *f = labi_linux_harden_flag_at(k);
        if (!f || !f[0])
            continue;
        if (*la < cap - 1)
            argv[(*la)++] = (char *)f;
    }
}


#else
void shux_append_linux_link_harden_impl(char *argv[], int *la, int cap) {
    (void)argv;
    (void)la;
    (void)cap;
}
#endif

/* G-02f-277 L9 gates */
#ifndef SHUX_LABI_GATES_FROM_X
void shux_append_linux_link_harden(char *argv[], int *la, int cap) {
  if (argv == NULL) {
    return;
  }
  if (la == NULL) {
    return;
  }
  {
    shux_append_linux_link_harden_impl(argv, la, cap);
  }
}
#else
void shux_append_linux_link_harden(char *argv[], int *la, int cap);
#endif


/**
 * ASM -o exe：fork 子进程执行 clang/ld 或 lld-link/ld；调用方须先 shux_asm_ld_prepare_for_exe_link。
 * 参数：driver_freestanding 同 shux_link_freestanding_enabled；link_argv0 用于 std/.o 路径解析。
 * 返回值：0 成功，-1 失败。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shux_asm_invoke_ld_platform(const char *o_path, const char *exe_path, const char *target,
    int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots,
    int driver_freestanding) {
    char link_argv_syn[PATH_MAX];
    const char *link_eff;

    (void)target;
#if !defined(__linux__)
    (void)driver_freestanding;
#endif
    if (!o_path || !exe_path)
        return -1;
    link_eff = shux_asm_ld_effective_link_argv0(link_argv0, link_argv_syn, sizeof link_argv_syn);
    if (!link_eff)
        return -1;

    {
        static char shux_asm_ld_lib_root_bufs[24][512];
        static const char *shux_asm_ld_lib_roots[24];
        const char **lib_roots_eff = lib_roots;
        int n_lib_roots_eff = n_lib_roots;
        int li;

        if (!lib_roots_eff || (uintptr_t)lib_roots_eff < 4096u || n_lib_roots_eff <= 0 || n_lib_roots_eff > 24) {
            shux_asm_ld_lib_root_default(shux_asm_ld_lib_root_bufs[0]);
            shux_asm_ld_lib_roots[0] = shux_asm_ld_lib_root_bufs[0];
            lib_roots_eff = shux_asm_ld_lib_roots;
            n_lib_roots_eff = 1;
        } else {
            for (li = 0; li < n_lib_roots_eff; li++) {
                const char *r = lib_roots_eff[li];
                if (!r || (uintptr_t)r < 4096u) {
                    shux_asm_ld_lib_root_default(shux_asm_ld_lib_root_bufs[li]);
                    shux_asm_ld_lib_roots[li] = shux_asm_ld_lib_root_bufs[li];
                } else if (!r[0]) {
                    shux_asm_ld_lib_root_default(shux_asm_ld_lib_root_bufs[li]);
                    shux_asm_ld_lib_roots[li] = shux_asm_ld_lib_root_bufs[li];
                } else {
                    if (strlen(r) >= sizeof(shux_asm_ld_lib_root_bufs[li]))
                        r = ".";
                    memcpy(shux_asm_ld_lib_root_bufs[li], r, strlen(r) + 1);
                    shux_asm_ld_lib_roots[li] = shux_asm_ld_lib_root_bufs[li];
                }
            }
            lib_roots_eff = shux_asm_ld_lib_roots;
        }

        /* slots[42][4096] 勿放栈上：driver 深栈 + ld_bank 易溢出并踩坏 rel/lib_roots。 */
        static ShuAsmLdPathBank shux_asm_ld_exe_bank;
        ShuAsmLdPathBank *ld_bank = &shux_asm_ld_exe_bank;
        ShuAsmLdStdLinkFlags ldflags;
        const char *argv[SHUX_LD_ARGV_CAP];
        char out_opt[512];
        int la = 0;
        int need_pt;
        const char *compress_o;
        pid_t pid;

        memset(ld_bank, 0, sizeof *ld_bank);
        compress_o = NULL; /* F-06 v1 / F-04 v7：无 compress.o，tail libs 由 user_o 扫描 */
#if defined(__APPLE__)
        if (use_macho_o) {
            argv[la++] = labi_ld_driver_clang();
            argv[la++] = labi_ld_flag_o();
            argv[la++] = exe_path;
            argv[la++] = o_path;
            shux_asm_ld_append_std_objs_for_user(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_mach_tail_libs(compress_o, o_path, &ldflags, (const char **)argv, &la, SHUX_LD_ARGV_CAP, 0);
            /* G.7: CLI user .o after std/on_demand (same globals as invoke_cc). */
            shux_asm_ld_append_user_extra_o_files(argv, &la, SHUX_LD_ARGV_CAP);
            argv[la] = NULL;
            {
                int rc = shux_spawn_sync(labi_ld_driver_clang(), (const char *const *)argv);
                if (rc == 0)
                    return 0;
            }
            la = 0;
            ld_bank->n = 0;
            memset(ld_bank->slots, 0, sizeof ld_bank->slots);
            argv[la++] = labi_ld_driver_ld();
            argv[la++] = labi_ld_flag_e();
            argv[la++] = labi_ld_mach_entry_main();
            argv[la++] = labi_ld_flag_o();
            argv[la++] = exe_path;
            argv[la++] = o_path;
            shux_asm_ld_append_std_objs_for_user(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_mach_tail_libs(compress_o, o_path, &ldflags, (const char **)argv, &la, SHUX_LD_ARGV_CAP, 1);
            shux_asm_ld_append_user_extra_o_files(argv, &la, SHUX_LD_ARGV_CAP);
            argv[la] = NULL;
            {
                int rc = shux_spawn_sync(labi_ld_driver_ld(), (const char *const *)argv);
                if (rc != 0) {
                    link_diag_tool_status("ld", rc);
                    return -1;
                }
            }
            return 0;
        }
#endif
        if (use_coff_o) {
            int nn = snprintf(out_opt, sizeof(out_opt), "/out:%s", exe_path);
            if (nn < 0 || nn >= (int)sizeof(out_opt))
                return -1;
            la = 0;
            ld_bank->n = 0;
            memset(ld_bank->slots, 0, sizeof ld_bank->slots);
            argv[la++] = "lld-link";
            argv[la++] = "/entry:_main";
            argv[la++] = out_opt;
            argv[la++] = o_path;
            shux_asm_ld_append_std_objs_for_user(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_user_extra_o_files(argv, &la, SHUX_LD_ARGV_CAP);
            argv[la++] = "ws2_32.lib";
            argv[la] = NULL;
            {
                int rc = shux_spawn_sync("lld-link", (const char *const *)argv);
                if (rc != 0) {
                    link_diag_tool_status("ld", rc);
                    return -1;
                }
            }
            return 0;
        }
        la = 0;
        ld_bank->n = 0;
        memset(ld_bank->slots, 0, sizeof ld_bank->slots);
#if defined(__linux__)
        /* F-no-libc NL-05 BEGIN: freestanding 用户链（ld -nostdlib -static，禁止 -lc） */
        if (shux_link_freestanding_enabled(driver_freestanding)) {
            const char *crt0_p;
            const char *panic_p;
            const char *io_p;
            const char *stubs_p;
            int need_io = 0;
            int need_panic = 0;
            int need_nostdlib_face = 0;
            need_io = shux_freestanding_user_o_needs_io(o_path);
            need_panic = shux_freestanding_user_o_needs_panic(o_path);
            /*
             * PLATFORM: LINUX freestanding product residual —
             * co-emit std.heap.libc → U malloc/free/…; zero-libc face is
             * bootstrap_nostdlib_stubs (mmap bump), same as compiler nostdlib bag.
             * Stubs need shux_sys_mmap from freestanding_io → force need_io.
             * G.7: complete freestanding ld on_demand (no second malloc path).
             */
            need_nostdlib_face = link_abi_user_o_needs_freestanding_nostdlib_face(o_path);
            if (need_nostdlib_face)
                need_io = 1;
            argv[la++] = "ld";
            argv[la++] = "-nostdlib";
            argv[la++] = "-static";
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "--gc-sections";
            /*
             * G-03 freestanding co-emit 去重未做：dep 模块（如 linux.x）经多条 import 路径
             * （std.sys → linux, page_mmap → linux, 直接 import linux）被 co-emit 多次，
             * 同一 function 在 user.o 内重复定义（如 syscall_nr_write_amd64/arm64）。
             * 【Why 根源】co-emit 不做 reach 过滤 + 所有函数在同一 .text section，
             * --gc-sections 仅移除未引用 section，无法消除单 .o 内的同名重复定义。
             * --allow-multiple-definition 让 ld 选第一个定义，与项目既有 weak+multi-def
             * 模式（line 3565 PE/COFF、line 4919 core.mem）对齐。重复 function 体相同，安全。
             * 【Invariant】仅 freestanding ld 路径；ELF weak 原生支持但 co-emit 产生强符号重复。
             * 【Asm/Perf】链接期选第一个定义，无运行时开销。
             */
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "--allow-multiple-definition";
            argv[la++] = "-o";
            argv[la++] = exe_path;
            crt0_p = asm_link_obj_skip_missing(shux_crt0_user_o_path(link_eff));
            if (!crt0_p) {
                link_diag_freestanding_missing("crt0_user.o", NULL);
                return -1;
            }
            panic_p = NULL;
            if (need_panic)
                panic_p = asm_link_obj_skip_missing(shux_runtime_panic_o_path(link_eff));
            if (need_panic && !panic_p) {
                link_diag_freestanding_missing("runtime_panic.o", "shux_panic_");
                return -1;
            }
            io_p = NULL;
            if (need_io)
                io_p = asm_link_obj_skip_missing(shux_freestanding_io_o_path(link_eff));
            if (need_io && !io_p) {
                link_diag_freestanding_missing("freestanding_io.o", "shux_sys_write");
                return -1;
            }
            stubs_p = NULL;
            if (need_nostdlib_face) {
                if (shux_ensure_bootstrap_nostdlib_stubs_o(link_eff) != 0)
                    return -1;
                stubs_p = asm_link_obj_skip_missing(shux_bootstrap_nostdlib_stubs_o_path(link_eff));
                if (!stubs_p) {
                    link_diag_freestanding_missing("bootstrap_nostdlib_stubs.o", "malloc");
                    return -1;
                }
            }
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = crt0_p;
            if (need_panic && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = panic_p;
            if (need_io && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = io_p;
            if (need_nostdlib_face && stubs_p && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = stubs_p;
            /*
             * F-no-libc NL-03/04/06：freestanding 按需链入 import 的 std/*.o（page_mmap/sys/linux/core_mem）。
             * 【Why 根源】freestanding -nostdlib 链接默认只链 crt0+panic+io+user.o，不扫描 std 依赖；
             * user.o import std.heap.page_mmap / std.sys / std.sys.linux 时，其 .o 须显式按需链入。
             * 【Invariant】on_demand 在 o_path 之前调用；--gc-sections 从 entry(crt0→main) 做可达性
             * 分析，所有 .o 须在 ld argv 中，未引用的 hosted 函数被 GC 移除。
             */
            shux_asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots_eff, n_lib_roots_eff,
                ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = o_path;
            /* G.7: CLI user .o (atomic_glue/time_os/…) after primary user.o. */
            shux_asm_ld_append_user_extra_o_files(argv, &la, SHUX_LD_ARGV_CAP);
            argv[la] = NULL;
            {
                /*
                 * nostdlib 链 shux_asm 的 environ 可能无 PATH：ld 子进程须显式设置 PATH，
                 * 否则 execvp("ld") 找不到 /usr/bin/ld → ENOENT → BLD001。
                 * 【Why】strict link shux_asm 用 -nostdlib -static 链接，environ 不一定
                 * 继承完整 PATH；gcc 路径用 shux_linux_host_gcc_path() 绕过，ld 亦须设 PATH。
                 */
                shux_linux_ld_child_path();
                int rc = shux_spawn_sync("ld", (const char *const *)argv);
                if (rc != 0) {
                    link_diag_tool_status("ld", rc);
                    return -1;
                }
            }
            return 0;
        }
        /* F-no-libc NL-05 END */
        /*
         * 自包含 .o（nm -u 为空）：gcc 仅链 user.o + libc crt。
         * nostdlib shux_asm 无 popen：保守走全量 gcc 链（return-value 等）。
         */
        if (!shux_asm_user_o_has_undef_syms(o_path)) {
#if defined(__linux__)
            /*
             * nostdlib shux_asm：popen 恒 NULL 时走自包含最小链；勿再 push string/base64 等
             * （realpath 去重 + 深栈易 SIGSEGV，见 C6 return-value -o）。
             */
            if (bootstrap_nostdlib_pthread_is_stub())
                return shux_asm_nostdlib_minimal_selfcontained_exe_link(o_path, exe_path, link_eff,
                    lib_roots_eff, n_lib_roots_eff);
#endif
            argv[la++] = shux_linux_host_gcc_path();
            shux_append_linux_link_harden((char **)argv, &la, SHUX_LD_ARGV_CAP);
            argv[la++] = "-o";
            argv[la++] = exe_path;
            argv[la++] = o_path;
            link_abi_asm_ld_push_minimal_runtime_objs(link_eff, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP);
            /*
             * user.o 无 UNDEF：co-emit 已自洽。勿再硬链 string.o/base64.o/encoding.o
             * （string 入口-only 库 .o 对 heap 有 U，硬链会缺 std_heap_libc_*；且与 co-emit 体重复时 duplicate）。
             * 有 UNDEF 时走下方 full append_std / on_demand。
             */
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lc";
            shux_asm_ld_append_user_extra_o_files(argv, &la, SHUX_LD_ARGV_CAP);
            argv[la] = NULL;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
            {
                intptr_t rc = _spawnvp(_P_WAIT, argv[0], (const char *const *)argv);
                if (rc == -1) {
                    perror("spawnvp (ld)");
                    return -1;
                }
                if (rc != 0) {
                    link_diag_tool_status("ld", (int)rc);
                    return -1;
                }
            }
#else
            pid = fork();
            if (pid < 0) {
                perror("fork (ld)");
                return -1;
            }
            if (pid == 0) {
                shux_linux_ld_child_path();
                execvp(argv[0], (char *const *)argv);
#if defined(__linux__)
                execv("/usr/local/bin/gcc", (char *const *)argv);
                execv("/usr/local/bin/cc", (char *const *)argv);
                execv("/usr/bin/gcc", (char *const *)argv);
                execv("/usr/bin/cc", (char *const *)argv);
                execvp("gcc", (char *const *)argv);
                execvp("cc", (char *const *)argv);
#endif
                perror("gcc (minimal user.o)");
                _exit(127);
            }
            {
                int status;
                if (shu_waitpid_retry(pid, &status) != 0)
                    return -1;
                if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
                    link_diag_tool_status("ld", status);
                    return -1;
                }
            }
#endif
            return 0;
        }
#endif
#if defined(__linux__)
        /* Linux ELF：gcc 驱动链接（crt _start→main）；裸 ld -e main 缺 crt 初始化易 SIGSEGV。 */
        argv[la++] = shux_linux_host_gcc_path();
        shux_append_linux_link_harden((char **)argv, &la, SHUX_LD_ARGV_CAP);
        /*
         * PLATFORM: LINUX hosted asm — same GC invariant as C invoke_cc + freestanding asm ld.
         * Formal std/*.o are built with -ffunction-sections; without --gc-sections, unused
         * map/set/queue bodies retain U heap/hash and BLD001 even when user only needs empty_size.
         * G.7: complete hosted asm link authority (do not invent a second GC path).
         */
        if (la < SHUX_LD_ARGV_CAP - 1)
            argv[la++] = "-Wl,--gc-sections";
#else
        argv[la++] = "ld";
        argv[la++] = "-e";
        argv[la++] = "_main";
#endif
        argv[la++] = "-o";
        argv[la++] = exe_path;
        argv[la++] = o_path;
        shux_asm_ld_append_std_objs_for_user(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
        shux_asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
        if (link_abi_user_o_needs_libc_heap(o_path))
            ldflags.have_libc_heap = 1;
        need_pt = ldflags.have_thread || ldflags.have_sync || ldflags.have_channel;
        shux_asm_ld_append_unix_gcc_tail_libs(compress_o, o_path, &ldflags, need_pt, (const char **)argv, &la, SHUX_LD_ARGV_CAP);
        /* G.7: CLI user .o after std/on_demand/tail libs (mirrors invoke_cc order). */
        shux_asm_ld_append_user_extra_o_files(argv, &la, SHUX_LD_ARGV_CAP);
        argv[la] = NULL;
        if (getenv("SHUX_DEBUG_LD"))
            link_diag_ld_debug_argv("gcc argv", argv);
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
        {
            intptr_t rc = _spawnvp(_P_WAIT, argv[0], (const char *const *)argv);
            if (rc == -1) {
                perror("spawnvp (ld)");
                return -1;
            }
            if (rc != 0) {
                link_diag_tool_status("ld", (int)rc);
                return -1;
            }
        }
#else
        pid = fork();
        if (pid < 0) {
            perror("fork (ld)");
            return -1;
        }
        if (pid == 0) {
#if defined(__linux__)
            shux_linux_ld_child_path();
            execvp(argv[0], (char *const *)argv);
            perror("gcc");
#else
            execvp("ld", (char *const *)argv);
            perror("ld");
#endif
            _exit(127);
        }
        {
            int status;
            if (shu_waitpid_retry(pid, &status) != 0)
                return -1;
            if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
                link_diag_tool_status("ld", status);
                return -1;
            }
        }
#endif
    }
    return 0;
}




/**
 * 判断 -o 路径是否写出对象文件（.o / .obj 则写 ELF/Mach-O/COFF 而非 .s）。
 * 参数：path 为 -o 参数；NULL 则返回 0。
 * 返回值：非 0 表示对象文件后缀。
 */
/* G-02f-64：真逻辑来自 .x（逐字节后缀；无 _impl）。 */
/* G-02f-267 L0 path pure */
#ifndef SHUX_LABI_PATH_PURE_FROM_X
int shux_output_is_elf_o(const char *path) {
    size_t n;
    if (path == NULL) {
        return 0;
    }
    n = 0;
    while (path[n] != 0) {
        n = n + 1;
    }
    if (n >= 2) {
        if (path[n - 2] == '.') {
            if (path[n - 1] == 'o') {
                return 1;
            }
            if (path[n - 1] == 'O') {
                return 1;
            }
        }
    }
    if (n >= 4) {
        if (path[n - 4] == '.') {
            if (path[n - 3] == 'o') {
                if (path[n - 2] == 'b') {
                    if (path[n - 1] == 'j') {
                        return 1;
                    }
                }
            }
        }
    }
    return 0;
}
#else
int shux_output_is_elf_o(const char *path);
#endif


/**
 * 判断 -o 路径是否表示可执行文件名（非 .o/.obj/.s 后缀）。
 * 参数：path 为 -o 参数；空串或 NULL 则返回 0。
 * 返回值：非 0 表示 -backend asm 应自动调 ld 出 exe。
 * G-02f-64：真逻辑来自 .x。
 */
/* G-02f-430：.x 真迁到 labi_path_pure.x */
#ifndef SHUX_LABI_PATH_PURE_FROM_X
int shux_output_want_exe(const char *path) {
    size_t n;
    if (path == NULL) {
        return 0;
    }
    if (path[0] == 0) {
        return 0;
    }
    n = 0;
    while (path[n] != 0) {
        n = n + 1;
    }
    if (n >= 2) {
        if (path[n - 2] == '.') {
            if (path[n - 1] == 'o') {
                return 0;
            }
            if (path[n - 1] == 'O') {
                return 0;
            }
            if (path[n - 1] == 's') {
                return 0;
            }
        }
    }
    if (n >= 4) {
        if (path[n - 4] == '.') {
            if (path[n - 3] == 'o') {
                if (path[n - 2] == 'b') {
                    if (path[n - 1] == 'j') {
                        return 0;
                    }
                }
            }
        }
    }
    return 1;
}
#else
int shux_output_want_exe(const char *path);
#endif

/**
 * ASM -o exe 薄包装：ensure .o + shux_asm_ld_prepare_for_exe_link + shux_asm_invoke_ld_platform。
 * G-02f-66：主体 _impl（PATH_MAX 合成缓冲）；.x 门闩 null 检查后转发。
 */
int shux_invoke_ld_for_exe_impl(const char *o_path, const char *exe_path, const char *target,
    int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots) {
    char link_argv_syn[PATH_MAX];
    const char *link_eff;
    int freestanding;

    link_eff = shux_asm_ld_effective_link_argv0(link_argv0, link_argv_syn, sizeof link_argv_syn);
    if (!link_eff)
        return -1;
    freestanding = driver_freestanding_get();
    if (shux_asm_ld_prepare_for_exe_link(link_eff, o_path, freestanding, use_macho_o, use_coff_o) != 0)
        return -1;
    return shux_asm_invoke_ld_platform(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots,
        freestanding);
}

/* G-02f-277 L9 gates */
#ifndef SHUX_LABI_GATES_FROM_X
int shux_invoke_ld_for_exe(const char *o_path, const char *exe_path, const char *target,
    int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots) {
  if (o_path == NULL) {
    return -1;
  }
  if (exe_path == NULL) {
    return -1;
  }
  {
    return shux_invoke_ld_for_exe_impl(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots);
  }
  return -1;
}
#else
int shux_invoke_ld_for_exe(const char *o_path, const char *exe_path, const char *target,
    int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots);
int labi_gates_count(void);
#endif

/* -------------------------------------------------------------------------- */
/* G-02e：原 runtime_proc_abi.c 并入本 TU（产品链减 1 个手写 C 文件）。 */
/* -------------------------------------------------------------------------- */

/**
 * 等待子进程；EINTR 时重试，避免 invoke_cc/asm_invoke_ld 误判失败。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int shu_waitpid_retry(pid_t pid, int *status_out) {
    int st = 0;
    for (;;) {
        pid_t w = waitpid(pid, &st, 0);
        if (w == pid) {
            if (status_out)
                *status_out = st;
            return 0;
        }
        if (w == -1 && errno == EINTR)
            continue;
        {
            int saved_errno = errno;
            const char *err = strerror(saved_errno);
            diag_reportf_with_code(NULL, 0, 0, "process error", SHUX_DIAG_CODE_PROCESS_PRC001, NULL,
                                   "waitpid failed: %s",
                                   err ? err : "unknown error");
        }
        return -1;
    }
}




/**
 * 仅当 path 指向已存在且非空的常规文件时返回 path，供 clang/ld argv 追加。
 */




/* -------------------------------------------------------------------------- */
/* G-02e：原 runtime_abi.c 并入本 TU（argv/target 薄原语 + nostdlib weak 桩）。 */
/* -------------------------------------------------------------------------- */


/** G-02f-44：argv 下标与 C 串拷贝（.x driver_get_argv_i 用）。 */
const char *driver_argv_at(char **argv, int i) {
    if (!argv || i < 0 || !argv[i])
        return NULL;
    return argv[i];
}
/* G-02f-118：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int driver_copy_cstr_n(const char *src, char *buf, int max) {
    size_t n;
    size_t j;
    if (!src || !buf || max <= 0)
        return -1;
    n = (size_t)max - 1;
    j = 0;
    while (src[j] && j < n) {
        buf[j] = src[j];
        j++;
    }
    buf[j] = '\0';
    return (int)j;
}




int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max) {
  if ((argv ==NULL)) {
    return (0 - 1);
  }
  if ((buf ==NULL)) {
    return (0 - 1);
  }
  if ((max <=0)) {
    return (0 - 1);
  }
  if ((i < 0)) {
    return (0 - 1);
  }
  if ((i >=argc)) {
    return (0 - 1);
  }
  (void)(({   {
    char *s = driver_argv_at(argv, i);
    if ((s ==NULL)) {
      return (0 - 1);
    }
    int r = driver_copy_cstr_n(s, buf, max);
    return r;
  }
 }));
  return (0 - 1);
}

uint8_t *driver_argv_drop_subcommand(int argc, uint8_t *argv_opaque) {
    static char *adj[512];
    char **argv;
    int i;

    if (argc < 2 || !argv_opaque)
        return argv_opaque;
    argv = (char **)argv_opaque;
    if (argc > 512)
        return argv_opaque;
    adj[0] = argv[0];
    for (i = 2; i < argc; i++)
        adj[i - 1] = argv[i];
    return (uint8_t *)adj;
}

/* Build the argv used by `shux run` / bare `shux file.x`: if the user already
 * passed -o, return argv unchanged (and *out_argc = argc) so the explicit
 * product path is compiled and exec'd. Otherwise append `-o <temp>` where
 * <temp> is a unique /tmp path, so the C/asm backend links a real executable
 * (no a.out in cwd, no generated C to stdout) and driver_exec_compiled execs
 * that temp. The temp is a unique name obtained via mkstemp+unlink; the
 * compiler (cc -o / ld -o) creates the actual executable file.
 * PLATFORM: SHARED — /tmp on POSIX, current dir fallback on Windows. */
#ifndef SHUX_RUN_TMP_PREFIX
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
#define SHUX_RUN_TMP_PREFIX "shux_run_"
#else
#define SHUX_RUN_TMP_PREFIX "/tmp/shux_run_"
#endif
#endif
uint8_t *driver_argv_ensure_run_o(int argc, uint8_t *argv_opaque, int *out_argc) {
    static char *adj[512];
    static char temp_path[96];
    char **argv;
    int has_o = 0;
    int i;
    if (out_argc)
        *out_argc = argc;
    if (!argv_opaque || argc < 1)
        return argv_opaque;
    argv = (char **)argv_opaque;
    /* Respect an explicit -o: scan like driver_exec_scan_out_path. */
    for (i = 1; i < argc - 1; i++) {
        if (argv[i] && strcmp(argv[i], "-o") == 0) {
            has_o = 1;
            break;
        }
    }
    if (has_o)
        return argv_opaque;
    if (argc + 2 > 512)
        return argv_opaque;
    snprintf(temp_path, sizeof temp_path, "%sXXXXXX", SHUX_RUN_TMP_PREFIX);
    {
#if !defined(_WIN32) && !defined(_WIN64) && !defined(__CYGWIN__)
        /* POSIX: mkstemp yields an atomically unique name; free it so cc -o
         * creates the executable itself (mkstemp leaves an empty regular file). */
        int fd = mkstemp(temp_path);
        if (fd >= 0) {
            close(fd);
            unlink(temp_path);
        } else {
            snprintf(temp_path, sizeof temp_path, "%s%ld", SHUX_RUN_TMP_PREFIX, (long)getpid());
        }
#else
        /* Windows: no mkstemp here; use a per-process counter for uniqueness. */
        static long run_counter = 0;
        run_counter = run_counter + 1;
        snprintf(temp_path, sizeof temp_path, "%s%ld", SHUX_RUN_TMP_PREFIX, run_counter);
#endif
    }
    for (i = 0; i < argc; i++)
        adj[i] = argv[i];
    adj[argc] = (char *)"-o";
    adj[argc + 1] = temp_path;
    adj[argc + 2] = (char *)0;
    if (out_argc)
        *out_argc = argc + 2;
    return (uint8_t *)adj;
}

int32_t driver_resolve_target_arch(int parsed_target, int saw_target_flag) {
  if ((saw_target_flag !=0)) {
    return parsed_target;
  }
  (void)(({   {
    if ((shux_host_is_apple_aarch64() !=0)) {
      return 1;
    }
    return parsed_target;
  }
 }));
  return parsed_target;
}

extern int main_entry(int argc, char **argv);

int shux_forward_main_to_main_entry(int argc, char **argv) {
  (void)(({   {
    int r = main_entry(argc, argv);
    return r;
  }
 }));
  return 0;
}

SHUX_WEAK void bootstrap_init_static_tls(void) {
  (void)(0);
}

SHUX_WEAK void bootstrap_init_environ(int argc, char **argv) {
  (void)(0);
}

/* PLATFORM: SHARED — pthread large-stack availability gate.
 *   POSIX (Linux/macOS): winpthreads absent; real pthreads support 256MiB
 *     posix_memalign'd custom stack via pthread_attr_setstack. Return 0
 *     so driver_run_thread_on_large_stack takes the pthread path for
 *     deep recursion beyond main thread's 8MiB RLIMIT_STACK.
 *   WINDOWS (MSYS/MinGW): winpthreads exist but pthread_attr_setstack
 *     with 256MiB posix_memalign'd stack crashes during pthread_join
 *     cleanup (exit=127 after thread fn returns). Return 1 to force
 *     driver_run_fn_on_current_large_stack path (driver_bump_stack_limit
 *     raises soft limit; pipeline runs on main thread). See AGENTS.md
 *     "平台边界必须标注" + project memory "Windows/MinGW weak" constraints.
 *   Authority: this SHUX_WEAK def is the sole linked definition on all
 *     platforms; the strong def in bootstrap_nostdlib_stubs.from_x.c
 *     (returns 1) is an orphan target never linked. G.4 single authority. */
SHUX_WEAK int bootstrap_nostdlib_pthread_is_stub(void) {
#if defined(_WIN32) || defined(_WIN64)
  return 1;
#else
  return 0;
#endif
}

