/**
 * runtime_link_abi.c — 编译器 C 侧链接/cc 辅助 ABI 实现（Phase E-04 v5～v23）
 *
 * 文件职责：invoke_cc / asm_ld 链接 argv 辅助；E-04 v23 起 invoke_ld 薄包装与 -o 后缀判断。
 * 所属模块：compiler 运行时；被 runtime.c driver 链接。
 * 与其它文件的关系：E-04 v17 起 invoke_cc 主体在本文件；main.c crt0 仍延后。
 */

#include "win32_compat.h"
#include "runtime_link_abi.h"
#include "runtime_proc_abi.h"
#include "runtime_io_abi.h"
#include "runtime_driver_abi.h"
#include "runtime_abi.h"
#include "diag.h"
#include "runtime_diag_codes.h"

#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef _WIN32
#include <unistd.h>
#endif
#ifndef _WIN32
#include <sys/wait.h>
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
static char *shux_path_last_sep(const char *s) {
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

/** 字符串是否包含任意路径分隔符（POSIX '/' 或 Windows '\\')。 */
static int shux_path_has_sep(const char *s) {
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

/**
 * 同步执行 cc 编译 .c/.s → .o；POSIX 上 fork+execvp+waitpid，Windows 上 _spawnvp(_P_WAIT,...)。
 * 参数：src 源文件；out_o 输出 .o 路径；inc0/inc1/inc2 三个 -I 包含路径；
 *       from_asm_s != 0 表示源是 .s 汇编，仅传 -c -o out src，不传 -Wall/-Wextra/-I。
 *       extra_flags 可选额外标志数组（NULL 或 NULL-terminated），插在 -I 之后、-c 之前。
 * 返回值：0 成功，非 0 失败（exit code 或 -1）。
 * 设计目的：消除 30+ 处 ensure_runtime_*_o 函数中重复的 fork+execlp+waitpid 三段式，
 *           并让 Windows 宿主走 _spawnvp 同步路径（无 fork）。
 */
static int shux_cc_compile_sync_ex(const char *src, const char *out_o,
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

/** shux_cc_compile_sync 的简化包装：无额外标志。 */
static int shux_cc_compile_sync(const char *src, const char *out_o,
                                const char *inc0, const char *inc1, const char *inc2,
                                int from_asm_s) {
    return shux_cc_compile_sync_ex(src, out_o, inc0, inc1, inc2, from_asm_s, NULL);
}

/**
 * 同步执行子进程：POSIX 上 fork+execvp+waitpid，Windows 上 _spawnvp(_P_WAIT,...)。
 * 参数：prog 程序名（PATH 查找）；argv 参数数组，须以 NULL 结尾。
 * 返回值：0 成功（exit 0），非 0 失败（exit code 或 -1）。
 * 设计目的：shux_asm_invoke_ld_platform 中 6 处 fork+execvp+waitpid 统一封装。
 */
static int shux_spawn_sync(const char *prog, const char *const *argv) {
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

static const char *link_diag_code_for_kind(const char *kind) {
    if (!kind)
        return SHUX_DIAG_CODE_PROCESS_PRC001;
    if (strcmp(kind, "build error") == 0)
        return SHUX_DIAG_CODE_BUILD_BLD001;
    if (strcmp(kind, "process error") == 0)
        return SHUX_DIAG_CODE_PROCESS_PRC001;
    return NULL;
}

static void link_diag_tool_status(const char *tool, int status) {
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

static void link_diag_runtime_obj_resolve_fail(const char *obj_name, const char *hint) {
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

static void link_diag_runtime_source_missing(const char *obj_name, const char *source_path) {
    if (!obj_name)
        obj_name = "runtime object";
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "%s source not found at %s",
                           obj_name, source_path ? source_path : "?");
}

static void link_diag_runtime_source_missing_under(const char *obj_name, const char *base_dir,
                                                   const char *suffix) {
    if (!obj_name)
        obj_name = "runtime object";
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "%s source not found under %s%s",
                           obj_name, base_dir ? base_dir : "?", suffix ? suffix : "");
}

static void link_diag_runtime_obj_missing(const char *obj_name, const char *out_o) {
    if (!obj_name)
        obj_name = "runtime object";
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "%s missing after cc -c (expected near %s)",
                           obj_name, out_o ? out_o : "?");
}

static void link_diag_runtime_obj_build_status(const char *obj_name, int status) {
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

static void link_diag_errno(const char *kind, const char *op) {
    int saved_errno = errno;
    const char *err = strerror(saved_errno);
    const char *resolved_kind = kind ? kind : "process error";
    const char *code = link_diag_code_for_kind(resolved_kind);
    if (code) {
        diag_reportf_with_code(NULL, 0, 0, resolved_kind, code, NULL,
                               "%s failed: %s",
                               op ? op : "system call",
                               err ? err : "unknown error");
    } else {
        diag_reportf(NULL, 0, 0, resolved_kind, NULL,
                     "%s failed: %s",
                     op ? op : "system call",
                     err ? err : "unknown error");
    }
}

static void link_diag_errno_path(const char *kind, const char *op, const char *path) {
    int saved_errno = errno;
    const char *err = strerror(saved_errno);
    const char *resolved_kind = kind ? kind : "process error";
    const char *code = link_diag_code_for_kind(resolved_kind);
    if (path && path[0] != '\0') {
        if (code) {
            diag_reportf_with_code(NULL, 0, 0, resolved_kind, code, NULL,
                                   "%s failed for '%s': %s",
                                   op ? op : "system call",
                                   path,
                                   err ? err : "unknown error");
        } else {
            diag_reportf(NULL, 0, 0, resolved_kind, NULL,
                         "%s failed for '%s': %s",
                         op ? op : "system call",
                         path,
                         err ? err : "unknown error");
        }
        return;
    }
    link_diag_errno(resolved_kind, op);
}

#if defined(__GNUC__) || defined(__clang__)
__attribute__((unused))
#endif
static void link_diag_freestanding_missing(const char *obj_name, const char *symbol_name) {
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

static void link_diag_freestanding_unsupported(void) {
    diag_report_with_code(NULL, 0, 0, "link error", SHUX_DIAG_CODE_BUILD_BLD001,
                "-freestanding / SHUX_FREESTANDING is only supported for Linux ELF x86_64 (-o prog, not .o/.obj on macOS/COFF)",
                NULL);
}

static void link_diag_ld_debug_push(const char *rel, const char *stage, const char *path) {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "ld debug: push %s %s=%s",
                 rel ? rel : "(null)",
                 stage ? stage : "path",
                 path ? path : "(null)");
}

static void link_diag_ld_debug_argv(const char *label, const char *const *argv) {
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

static void shux_link_perror(const char *msg) {
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

#define perror(msg) shux_link_perror((msg))

/**
 * 判断 lib root 指针可安全解引用（避开 NULL/low tag/getenv 脏值）。
 * 参数：p 候选 lib root 字符串指针。
 * 返回值：非 0 表示可用。
 */
static int shux_asm_ld_lib_root_ptr_usable(const char *p) {
    return p && (uintptr_t)p >= 4096u && p[0] != '\0';
}

/**
 * 写入默认 lib root 到 root_buf（SHUX_LIB 或 "."）。
 * 参数：root_buf 至少 512 字节。
 */
static void shux_asm_ld_lib_root_default(char root_buf[512]) {
    const char *def = getenv("SHUX_LIB");
    root_buf[0] = '.';
    root_buf[1] = '\0';
    if (!shux_asm_ld_lib_root_ptr_usable(def))
        return;
    strncpy(root_buf, def, 511);
    root_buf[511] = '\0';
}

#if defined(__linux__)
/** nostdlib 链 environ 可能无 PATH：链接子进程优先用绝对路径 gcc（含 gcc 官方镜像 /usr/local/bin）。 */
static const char *shux_linux_host_gcc_path(void) {
    if (access("/usr/bin/gcc", X_OK) == 0)
        return "/usr/bin/gcc";
    if (access("/usr/local/bin/gcc", X_OK) == 0)
        return "/usr/local/bin/gcc";
    return "gcc";
}

/** Linux 链接子进程 PATH：gcc 官方镜像仅提供 /usr/local/bin/gcc。 */
static void shux_linux_ld_child_path(void) {
    (void)setenv("PATH", "/usr/local/bin:/usr/bin:/bin", 1);
}
#endif

/* #region debug-point A:hello-stage1-segv */
static void shux_debug_hello_stage1_report(const char *hypothesis_id, const char *location,
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
    static char buf[1];
    buf[0] = '\0';
    return buf;
}

/**
 * F-04 v7 + F-06 v1：std.compress 已纯 .x，无 compress.o；保留 API 兼容，返回空串。
 * 参数：argv0 可选 shux 路径。
 * 返回值：空串（压缩库由 user .o / 生成 C 扫描按需 -lz/-lzstd/-lbrotli*）。
 */
const char *shux_std_compress_o_path(const char *argv0) {
    (void)argv0;
    static char buf[1];
    buf[0] = '\0';
    return buf;
}

/**
 * 由 argv0 推导仓库根目录（基于 std/process/process.o 路径向上取三级目录）。
 * 参数：argv0 可选 shux 路径。
 * 返回值：仓库根路径或空串。
 */
const char *shux_repo_root_from_argv0(const char *argv0) {
    static char buf[512];
    const char *proc_o = shux_rel_o_path_from_argv0(argv0, "std/process/process.o");
    int k;
    buf[0] = '\0';
    if (!proc_o || !proc_o[0])
        return buf;
    if (strlen(proc_o) >= sizeof(buf))
        return buf;
    strcpy(buf, proc_o);
    for (k = 0; k < 3; k++) {
        char *last = shux_path_last_sep(buf);
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
const char *shux_asm_ld_bank_push(ShuAsmLdPathBank *b, const char *path) {
    if (!b || !path || !path[0] || b->n >= SHUX_ASM_LD_PATH_BANK_SLOTS)
        return NULL;
    if (snprintf(b->slots[b->n], sizeof(b->slots[0]), "%s", path) >= (int)sizeof(b->slots[0]))
        return NULL;
    return b->slots[b->n++];
}

/**
 * 在每个 -L（lib root）根下尝试 rel（如 std/process/process.o）；命中则拷入 bank 并返回指针。
 * 参数：rel 相对路径；lib_roots/n_lib_roots -L 根；bank 路径持久化。
 */
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

/**
 * 对 path 做 realpath，仅当目标为已存在常规文件时返回 resolved（避免 nostdlib realpath 拼出不存在的路径）。
 * 参数：path 候选；resolved 输出缓冲（PATH_MAX）。
 * 返回值：resolved 或 NULL。
 */
static const char *shux_runtime_o_realpath_if_exists(const char *path, char *resolved) {
    if (!path || !path[0] || !resolved || realpath(path, resolved) == NULL)
        return NULL;
    return asm_link_obj_skip_missing(resolved);
}

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

static int shux_runtime_compiler_o_path_copy(const char *argv0, const char *leaf, char *out, size_t out_sz) {
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
 * seed asm 用户程序：std.io 桩 .o（与 io.o 同链）；见 src/asm/runtime_asm_io_stubs.c。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：.o 路径或空串。
 */
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
 * 与 verify-selfhost.sh / Makefile 规则对齐：Linux 优先 x86_64 .s；Apple arm64 优先 runtime_panic_arm64.c；否则 runtime_panic.c。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
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
    if (!src && (size_t)snprintf(src_arm, sizeof src_arm, "%s/src/asm/runtime_panic_arm64.c", comp) < sizeof src_arm && access(src_arm, R_OK) == 0)
        src = src_arm;
#endif
    if (!src) {
        if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_panic.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
            link_diag_runtime_source_missing_under("runtime_panic", comp, "/src/asm/");
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
int shux_link_freestanding_enabled(int driver_freestanding) {
    const char *e;
#if !defined(__linux__)
    (void)driver_freestanding;
    return 0;
#else
    if (driver_freestanding)
        return 1;
    e = getenv("SHUX_FREESTANDING");
    return e && e[0] && e[0] != '0';
#endif
}

/**
 * 若 runtime_asm_io_stubs.o 尚不存在则用 cc -c 从 src/asm/runtime_asm_io_stubs.c 生成到 shux 同目录，
 * 以便 ASM -o exe 链 hello 等 import std.io 的程序时提供 std_io_print_str。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_asm_io_stubs_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_asm_io_stubs_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_asm_io_stubs.o", "try: make -C compiler runtime_asm_io_stubs.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_asm_io_stubs.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_asm_io_stubs.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_asm_io_stubs", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        const char *extra_flags[] = { "-fPIE", NULL };
        int rc = shux_cc_compile_sync_ex(src_c, out_o, inc0, inc1, inc2, 0, extra_flags);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_asm_io_stubs.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_asm_io_stubs_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_asm_io_stubs.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_process_argv.o 尚不存在则用 cc -c 从 src/asm/runtime_process_argv.c 生成到 shux 同目录，
 * 以便链 process.o 时提供 shux_process_argc/argv 与 process_shux_argc_get。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_process_argv_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_process_argv_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_process_argv.o", "try: make -C compiler runtime_process_argv.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_process_argv.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_process_argv.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_process_argv", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_process_argv.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_process_argv_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_process_argv.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_process_os_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_process_os_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_process_os_glue.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_process_os_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_process_os_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_process_os_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_process_os_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_process_os_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_process_os_glue.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_test_fn_invoke.o 尚不存在则用 cc -c 从 src/asm/runtime_test_fn_invoke.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_test_fn_invoke_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_test_fn_invoke_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_test_fn_invoke.o", "try: make -C compiler runtime_test_fn_invoke.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_test_fn_invoke.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_test_fn_invoke.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_test_fn_invoke", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
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
 * 若 runtime_random_fill.o 尚不存在则用 cc -c 从 src/asm/runtime_random_fill.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_random_fill_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_random_fill_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_random_fill.o", "try: make -C compiler runtime_random_fill.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_random_fill.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_random_fill.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_random_fill", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_random_fill.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_random_fill_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_random_fill.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_compress_zlib_glue.o 尚不存在则用 cc -c 从 src/asm/runtime_compress_zlib_glue.c 生成。
 * 提供 deflateInit2/inflateInit2 真实函数符号（zlib.h 中为宏，无函数符号）。
 */
int shux_ensure_runtime_compress_zlib_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_compress_zlib_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_compress_zlib_glue.o", "try: make -C compiler runtime_compress_zlib_glue.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_compress_zlib_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_compress_zlib_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_compress_zlib_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_compress_zlib_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_compress_zlib_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_compress_zlib_glue.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_heap_user.o 尚不存在则用 cc -c 从 src/runtime_heap_user.c 生成到 shux 同目录。
 * co-emit std.heap allocator_* redirect 的 heap_alloc_c / heap_arena64_alloc_c 等符号。
 */
int shux_ensure_runtime_heap_user_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_heap_user_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_heap_user.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_heap_user.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/runtime_heap_user.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_heap_user", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
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
 * 若 runtime_time_os.o 尚不存在则用 cc -c 从 src/asm/runtime_time_os.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_time_os_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_time_os_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_time_os.o", "try: make -C compiler runtime_time_os.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_time_os.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_time_os.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_time_os", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_time_os.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_time_os_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_time_os.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_queue_contention.o 尚不存在则用 cc -c 从 src/asm/runtime_queue_contention.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_queue_contention_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_queue_contention_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_queue_contention.o", "try: make -C compiler runtime_queue_contention.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_queue_contention.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_queue_contention.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_queue_contention", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_queue_contention.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_queue_contention_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_queue_contention.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_dynlib_os.o 尚不存在则用 cc -c 从 src/asm/runtime_dynlib_os.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_dynlib_os_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_dynlib_os_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_dynlib_os.o", "try: make -C compiler runtime_dynlib_os.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_dynlib_os.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_dynlib_os.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_dynlib_os", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_dynlib_os.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_dynlib_os_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_dynlib_os.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_env_os.o 尚不存在则用 cc -c 从 src/asm/runtime_env_os.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_env_os_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_env_os_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_env_os.o", "try: make -C compiler runtime_env_os.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_env_os.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_env_os.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_env_os", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_env_os.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_env_os_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_env_os.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_backtrace_platform.o 尚不存在则用 cc -c 从 src/asm/runtime_backtrace_platform.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_backtrace_platform_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_backtrace_platform_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_backtrace_platform.o", "try: make -C compiler runtime_backtrace_platform.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_backtrace_platform.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_backtrace_platform.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_backtrace_platform", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_backtrace_platform.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_backtrace_platform_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_backtrace_platform.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_log_os.o 尚不存在则用 cc -c 从 src/asm/runtime_log_os.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_log_os_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_log_os_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_log_os.o", "try: make -C compiler runtime_log_os.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_log_os.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_log_os.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_log_os", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_log_os.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_log_os_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_log_os.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_math_libm.o 尚不存在则用 cc -c 从 src/asm/runtime_math_libm.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_math_libm_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_math_libm_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_math_libm.o", "try: make -C compiler runtime_math_libm.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_math_libm.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_math_libm.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_math_libm", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_math_libm.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_math_libm_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_math_libm.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_atomic_glue.o 尚不存在则用 cc -c 从 src/asm/runtime_atomic_glue.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_atomic_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_atomic_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_atomic_glue.o", "try: make -C compiler runtime_atomic_glue.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_atomic_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_atomic_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_atomic_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_atomic_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_atomic_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_atomic_glue.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_channel_glue.o 尚不存在则用 cc -c 从 src/asm/runtime_channel_glue.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_channel_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_channel_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_channel_glue.o", "try: make -C compiler runtime_channel_glue.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_channel_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_channel_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_channel_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_channel_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_channel_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_channel_glue.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_net_udp_batch.o 尚不存在则用 cc -c 从 src/asm/runtime_net_udp_batch.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_net_udp_batch_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_net_udp_batch_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_net_udp_batch.o", "try: make -C compiler runtime_net_udp_batch.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_net_udp_batch.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_net_udp_batch.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_net_udp_batch", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_net_udp_batch.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_net_udp_batch_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_net_udp_batch.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 runtime_net_workers.o 尚不存在则用 cc -c 从 src/asm/runtime_net_workers.c 生成到 shux 同目录。
 * 参数：argv0 用于解析 compiler 目录。
 * 返回值：0 成功，-1 失败并已写 stderr。
 */
int shux_ensure_runtime_net_workers_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_net_workers_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_net_workers.o", "try: make -C compiler runtime_net_workers.o");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_net_workers.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_net_workers.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_net_workers", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_net_workers.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_net_workers_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_net_workers.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_sync_os_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_sync_os_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_sync_os.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_sync_os.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_sync_os.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_sync_os", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_sync_os.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_sync_os_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_sync_os.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_sync_lock_diag_tls_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_sync_lock_diag_tls_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_sync_lock_diag_tls.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_sync_lock_diag_tls.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_sync_lock_diag_tls.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_sync_lock_diag_tls", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_sync_lock_diag_tls.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_sync_lock_diag_tls_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_sync_lock_diag_tls.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_thread_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_thread_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_thread_glue.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_thread_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_thread_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_thread_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_thread_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_thread_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_thread_glue.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_scheduler_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_scheduler_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_scheduler_glue.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_scheduler_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_scheduler_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_scheduler_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s/src/asm", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_scheduler_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_scheduler_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_scheduler_glue.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_http_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_http_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_http_glue.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_http_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/http/runtime_http_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_http_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s/src/asm/http", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_http_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_http_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_http_glue.o", out_o);
        return -1;
    }
    return 0;
}

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
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_tls_mbedtls_bio.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
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

int shux_ensure_runtime_kv_mmap_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_kv_mmap_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_kv_mmap_glue.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_kv_mmap_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_kv_mmap_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_kv_mmap_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_kv_mmap_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_kv_mmap_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_kv_mmap_glue.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_arrow_simd_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_arrow_simd_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_arrow_simd_glue.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_arrow_simd_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_arrow_simd_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_arrow_simd_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_arrow_simd_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_arrow_simd_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_arrow_simd_glue.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_sqlite_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_sqlite_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_sqlite_glue.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_sqlite_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_sqlite_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_sqlite_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        const char *extra_flags[] = { "-DSHUX_DB_USE_SQLITE3", NULL };
        int rc = shux_cc_compile_sync_ex(src_c, out_o, inc0, inc1, inc2, 0, extra_flags);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_sqlite_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_sqlite_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_sqlite_glue.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_crypto_inc_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_crypto_inc_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_crypto_inc_glue.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_crypto_inc_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_crypto_inc_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_crypto_inc_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_crypto_inc_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_crypto_inc_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_crypto_inc_glue.o", out_o);
        return -1;
    }
    return 0;
}

int shux_ensure_runtime_ed25519_ref10_glue_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_c[PATH_MAX];
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if (asm_link_obj_skip_missing(shux_runtime_ed25519_ref10_glue_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("runtime_ed25519_ref10_glue.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/runtime_ed25519_ref10_glue.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_c, sizeof src_c, "%s/src/asm/runtime_ed25519_ref10_glue.c", comp) >= sizeof src_c || access(src_c, R_OK) != 0) {
        link_diag_runtime_source_missing("runtime_ed25519_ref10_glue", src_c);
        return -1;
    }
    if ((size_t)snprintf(inc0, sizeof inc0, "%s/src/asm", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    {
        int rc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("runtime_ed25519_ref10_glue.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_runtime_ed25519_ref10_glue_o_path(argv0))) {
        link_diag_runtime_obj_missing("runtime_ed25519_ref10_glue.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 crt0_user.o 尚不存在则从 crt0_user_x86_64.s 编译到 shux 同目录（仅 SHUX_FREESTANDING 路径需要）。
 * 参数：argv0；driver_freestanding 同 shux_link_freestanding_enabled。
 * 返回值：0 成功；未启用 freestanding 时 no-op 返回 0。
 */
int shux_ensure_crt0_user_o(const char *argv0, int driver_freestanding) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_s[PATH_MAX];
    if (!shux_link_freestanding_enabled(driver_freestanding))
        return 0;
    if (asm_link_obj_skip_missing(shux_crt0_user_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("crt0_user.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/crt0_user.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_s, sizeof src_s, "%s/src/asm/crt0_user_x86_64.s", comp) >= sizeof src_s
        || access(src_s, R_OK) != 0) {
        link_diag_runtime_source_missing("crt0_user", src_s);
        return -1;
    }
    {
        int rc = shux_cc_compile_sync(src_s, out_o, NULL, NULL, NULL, 1);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("crt0_user.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_crt0_user_o_path(argv0))) {
        link_diag_runtime_obj_missing("crt0_user.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 freestanding_io.o 尚不存在则从 freestanding_io_x86_64.s 编译（SHUX_FREESTANDING 链入 shux_sys_write）。
 * 参数：argv0；driver_freestanding 同 shux_link_freestanding_enabled。
 * 返回值：0 成功；未启用 freestanding 时 no-op 返回 0。
 */
int shux_ensure_freestanding_io_o(const char *argv0, int driver_freestanding) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_s[PATH_MAX];
    if (!shux_link_freestanding_enabled(driver_freestanding))
        return 0;
    if (asm_link_obj_skip_missing(shux_freestanding_io_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        link_diag_runtime_obj_resolve_fail("freestanding_io.o", NULL);
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/freestanding_io.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_s, sizeof src_s, "%s/src/asm/freestanding_io_x86_64.s", comp) >= sizeof src_s
        || access(src_s, R_OK) != 0) {
        link_diag_runtime_source_missing("freestanding_io", src_s);
        return -1;
    }
    {
        int rc = shux_cc_compile_sync(src_s, out_o, NULL, NULL, NULL, 1);
        if (rc != 0) {
            link_diag_runtime_obj_build_status("freestanding_io.o", rc);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(shux_freestanding_io_o_path(argv0))) {
        link_diag_runtime_obj_missing("freestanding_io.o", out_o);
        return -1;
    }
    return 0;
}

/**
 * CI/Docker/musl 上 -march=native/-flto 可能导致 cc 异常退出（exit -1）。
 * 参数：无。
 * 返回值：非 0 表示跳过 native 调优。
 */
int invoke_cc_skip_native_tuning(void) {
    if (getenv("CI") || getenv("SHUX_CI_DOCKER") || getenv("SHUX_NO_MARCH_NATIVE"))
        return 1;
    return 0;
}

/**
 * invoke_cc 子进程：仅当 path 指向已存在的 .o 时追加到 argv（可选 realpath）。
 * 参数：见 runtime_link_abi.h。
 * 返回值：1 已追加，0 跳过。
 */
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
static int link_abi_obj_exports_marker(const char *obj_o, const char *marker) {
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
static int link_abi_obj_has_undef_sym(const char *obj_o, const char *sym) {
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

/** 任意 .o 是否依赖 libz（marker 或 zlib 未定义符号）。F-04 v4：含用户 .x 链出的 .o。 */
static int link_abi_obj_needs_zlib(const char *obj_o) {
    if (!obj_o || !obj_o[0])
        return 0;
    if (link_abi_obj_exports_marker(obj_o, "shu_compress_zlib_marker"))
        return 1;
    return link_abi_obj_has_undef_sym(obj_o, "_compress2")
        || link_abi_obj_has_undef_sym(obj_o, "_deflate")
        || link_abi_obj_has_undef_sym(obj_o, "_inflate")
        || link_abi_obj_has_undef_sym(obj_o, "_uncompress");
}

/** 任意 .o 是否依赖 libzstd（F-04 v7+：zstd .x 用户链）。 */
static int link_abi_obj_needs_zstd(const char *obj_o) {
    if (!obj_o || !obj_o[0])
        return 0;
    if (link_abi_obj_exports_marker(obj_o, "shu_compress_zstd_marker"))
        return 1;
    return link_abi_obj_has_undef_sym(obj_o, "ZSTD_") || link_abi_obj_has_undef_sym(obj_o, "_ZSTD");
}

/** 任意 .o 是否依赖 libbrotli（F-04 v6：lib.x 用户链）。 */
static int link_abi_obj_needs_brotli(const char *obj_o) {
    if (!obj_o || !obj_o[0])
        return 0;
    if (link_abi_obj_exports_marker(obj_o, "shu_compress_brotli_marker"))
        return 1;
    return link_abi_obj_has_undef_sym(obj_o, "BrotliEncoderCompress")
        || link_abi_obj_has_undef_sym(obj_o, "BrotliDecoderDecompress");
}

/** 用户 .o 是否引用任一压缩库（F-04 v7：全 .x 按需 -lz/-lzstd/-lbrotli*）。 */
static int link_abi_user_o_needs_compress_libs(const char *user_o) {
    return link_abi_obj_needs_zlib(user_o) || link_abi_obj_needs_zstd(user_o)
        || link_abi_obj_needs_brotli(user_o);
}

/** macOS Homebrew /usr/local：便于 -lz / -lzstd 解析。 */
static void ld_append_brew_lib_paths(const char **argv, int *la, int max_la) {
#if defined(__APPLE__)
    if (*la < max_la - 1)
        argv[(*la)++] = "-L/opt/homebrew/lib";
    if (*la < max_la - 1)
        argv[(*la)++] = "-L/usr/local/lib";
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
void asm_ld_append_compress_libs(const char *compress_o, const char *user_o, const char **argv, int *la, int max_la) {
    if (!argv || !la)
        return;
    if (link_abi_obj_needs_zlib(compress_o) || link_abi_obj_needs_zlib(user_o)) {
        ld_append_brew_lib_paths(argv, la, max_la);
        if (*la < max_la - 1)
            argv[(*la)++] = "-lz";
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
            argv[(*la)++] = "-lzstd";
    }
    if (link_abi_obj_needs_brotli(compress_o) || link_abi_obj_needs_brotli(user_o)) {
        ld_append_brew_lib_paths(argv, la, max_la);
        if (*la < max_la - 1)
            argv[(*la)++] = "-lbrotlienc";
        if (*la < max_la - 1)
            argv[(*la)++] = "-lbrotlidec";
    }
}

/**
 * invoke_cc 链接：按 compress.o / 用户 .o 实际依赖追加 -lz / -lzstd / -lbrotli*。
 * 参数：argv/i/argv_cap 为 cc 链接 argv；compress_o 候选 compress .o；user_o 用户 .o（可 NULL）。
 */
void invoke_cc_append_compress_ld(char *argv[], int *i, int argv_cap, const char *compress_o, const char *user_o) {
    if (!argv || !i || *i >= argv_cap - 1)
        return;
    if (link_abi_obj_needs_zlib(compress_o) || link_abi_obj_needs_zlib(user_o)) {
        ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)"-lz";
        /* zlib 宏包装桩：deflateInit2/inflateInit2 是宏，需真实函数符号 */
        (void)shux_ensure_runtime_compress_zlib_glue_o(NULL);
        (void)invoke_cc_argv_push_existing(argv, i, argv_cap,
            shux_runtime_compress_zlib_glue_o_path(NULL));
    }
    if (link_abi_obj_needs_zstd(compress_o) || link_abi_obj_needs_zstd(user_o)) {
        ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)"-lzstd";
    }
    if (link_abi_obj_needs_brotli(compress_o) || link_abi_obj_needs_brotli(user_o)) {
        ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)"-lbrotlienc";
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)"-lbrotlidec";
    }
}


/**
 * B-20 v1：扫描生成 C 是否含任一子串（invoke_cc 按需链入判定）。
 */
static int link_abi_generated_c_contains_any_substr(const char *c_path, const char **needles, int n_needles) {
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

/**
 * 生成的 .c 是否引用 libc 堆符号（F-03 v2：libc.x 经 codegen 生成 extern malloc 等，按需 -lc）。
 */
static int link_abi_generated_c_needs_libc_heap(const char *c_path) {
    static const char *needles[] = {
        "malloc(", "calloc(", "realloc(", "free(", "posix_memalign(",
        "heap_alloc_c(", "heap_free_c(", "heap_realloc_c(", "heap_alloc_zeroed_c(",
        "getenv(",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/**
 * 用户 .o 是否仍引用 libc 堆符号（F-03 v2：无 heap.o，由 -lc 解析）。
 */
static int link_abi_user_o_needs_libc_heap(const char *user_o) {
    return shux_link_obj_needs_undef_sym(user_o, "malloc")
        || shux_link_obj_needs_undef_sym(user_o, "calloc")
        || shux_link_obj_needs_undef_sym(user_o, "realloc")
        || shux_link_obj_needs_undef_sym(user_o, "free")
        || shux_link_obj_needs_undef_sym(user_o, "posix_memalign")
        || shux_link_obj_needs_undef_sym(user_o, "getenv");
}

static int link_abi_generated_c_needs_win32(const char *c_path) {
    static const char *needles[] = {
        "GetStdHandle", "WriteFile", "CreateFileA", "ReadFile", "CloseHandle", "ExitProcess",
        "win32_write", "win32_read_file_into", "win32_exit_process",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/**
 * 生成的 .c 是否引用 winsock2（F-02 v2：按需 -lws2_32，无 win32_net.inc.c）。
 */
static int link_abi_generated_c_needs_win32_wsa(const char *c_path) {
    static const char *needles[] = {
        "WSAStartup", "WSACleanup", "win32_net_available",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/**
 * 生成的 .c 是否引用 core.builtin 位运算（G-01：__builtin_* 内联，不再链 builtin.o）。
 */
static int link_abi_generated_c_needs_core_builtin(const char *c_path) {
    (void)c_path;
    return 0;
}

/** 扫描生成 C 是否引用 core.mem volatile/fence 符号（G-01：纯 .x，不再链 mem.o）。 */
static int link_abi_generated_c_needs_core_mem(const char *c_path) {
    (void)c_path;
    return 0;
}

/** 扫描生成 C 是否引用 std.db.kv 符号（按需链 std/db/kv/kv.o）。 */
static int link_abi_generated_c_needs_db_kv(const char *c_path) {
    static const char *needles[] = {
        "db_kv_open_c", "db_kv_put_c", "db_kv_get_c", "db_kv_append_ts_c",
        "db_kv_wal_flush_c", "db_kv_compact_c", "db_kv_sst_level_count_c",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 std.db.arrow 符号（按需链 std/db/arrow/arrow.o）。 */
static int link_abi_generated_c_needs_db_arrow(const char *c_path) {
    static const char *needles[] = {
        "arrow_column_", "arrow_batch_", "arrow_smoke_c",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 core.slice C 辅助符号（G-01：纯 .x，不再链 slice.o）。 */
static int link_abi_generated_c_needs_core_slice(const char *c_path) {
    /* core.slice subslice/chunk 经 core/slice/slice.c 薄封装构造（语言暂无 slice 复合字面量）。 */
    static const char *needles[] = {
        "core_slice_i32_from_ptr_c", "core_subslice_i32_c",
        "core_slice_u8_from_ptr_c", "core_subslice_u8_c",
        "core_slice_u64_from_ptr_c", "core_subslice_u64_c",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}


/** 扫描生成 C 是否引用 std.fs 符号（F-03 v2：按需链 -lc，无 fs.o）。 */
static int link_abi_generated_c_needs_fs(const char *c_path) {
    static const char *needles[] = {
        "fs_open_read_c", "fs_last_error_c", "fs_close_c", "fs_read_c", "fs_write_c",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 libz（F-06 v1 / F-04 v7：无 compress.o，按需 -lz）。 */
static int link_abi_generated_c_needs_zlib(const char *c_path) {
    static const char *needles[] = {
        "_compress2", "_deflate", "_inflate", "_uncompress", "compress2(", "deflate(", "inflate(",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 libzstd（F-06 v1 / F-04 v7：无 compress.o，按需 -lzstd）。 */
static int link_abi_generated_c_needs_zstd(const char *c_path) {
    static const char *needles[] = {
        "ZSTD_compress", "ZSTD_decompress", "ZSTD_create", "ZSTD_free", "ZSTD_isError",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 libbrotli（F-06 v1 / F-04 v7：无 compress.o，按需 -lbrotli*）。 */
static int link_abi_generated_c_needs_brotli(const char *c_path) {
    static const char *needles[] = {
        "BrotliEncoder", "BrotliDecoder",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 std.random C 符号（按需链 std/random/random.o）。 */
static int link_abi_generated_c_needs_random(const char *c_path) {
    static const char *needles[] = {
        "random_rng_smoke_c", "random_fill_bytes_c", "random_u64_c",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 std.time 符号（按需链 std/time/time.o + runtime_time_os.o）。 */
static int link_abi_generated_c_needs_time(const char *c_path) {
    static const char *needles[] = {
        "std_time_now_monotonic_ns", "std_time_sleep_ms", "std_time_duration_ns",
        "std_time_now_wall_ns", "std_time_format_timezone_smoke",
        "time_now_monotonic_ns_c", "time_sleep_ms_c", "time_duration_ns_c",
        "time_now_wall_ns_c", "time_format_timezone_smoke_c",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 std.runtime C 符号（按需链 std/runtime/runtime.o）。 */
static int link_abi_generated_c_needs_runtime(const char *c_path) {
    static const char *needles[] = {
        "runtime_crash_evidence_collect_c", "runtime_panic", "runtime_abort",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/**
 * 生成的 .c 是否引用 std.async scheduler（C 前端 invoke_cc 按需链 scheduler.o）。
 */
int shux_generated_c_needs_async_scheduler(const char *c_path) {
    static const char *needles[] = {
        "shux_async_run_i32", "shux_async_cps_suspend",
        "shux_async_task_submit", "shux_async_run_seed_",
        "shux_async_coop_pingpong_jmp", "shux_async_coop_pingpong",
        /* STD-118 hooks_smoke：runtime_drain/reset 走 scheduler 队列与 context 绑定 */
        "shux_async_run_drain_until_idle", "shux_async_queue_reset",
        "shux_async_bind_context_c",
    };
    return link_abi_generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/**
 * 调用系统 cc 将多个 C 文件编译链接为可执行文件（fork/exec + 可选 strip）。
 * 参数：c_paths/n 源文件；各 *_o 可选 std/core .o；include_root 用于 -I 与按需 .o 解析。
 * 返回值：0 成功，-1 失败。
 */
int shux_invoke_cc(const char **c_paths, int n, const char *out_path, const char *target, const char *opt_level, int use_lto, const char *io_o, const char *fs_o, const char *process_o, const char *string_o, const char *heap_o, const char *path_o, const char *runtime_o, const char *runtime_panic_o, const char *net_o, const char *thread_o, const char *time_o, const char *random_o, const char *env_o, const char *sync_o, const char *encoding_o, const char *base64_o, const char *crypto_o, const char *log_o, const char *atomic_o, const char *channel_o, const char *backtrace_o, const char *hash_o, const char *math_o, const char *sort_o, const char *ffi_o, const char *db_o, const char *elf_o, const char *json_o, const char *csv_o, const char *regex_o, const char *compress_o, const char *unicode_o, const char *dynlib_o, const char *http_o, const char *tar_o, const char *simd_o, const char *context_o, const char *datetime_o, const char *uuid_o, const char *url_o, const char *cli_o, const char *security_o, const char *config_o, const char *cache_o, const char *trace_o, const char *task_o, const char *schema_o, const char *test_o, const char *include_root, const char *async_scheduler_o) {
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
    if (time_o && time_o[0] && access(time_o, R_OK) == 0) {
        if (shux_ensure_runtime_time_os_o(NULL) != 0)
            return -1;
    }
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
                const char *abi_h = shux_rel_o_path_from_argv0(include_root, "core/builtin/builtin_abi.h");
                if (abi_h && abi_h[0]) {
                    if (i < argv_cap - 2) {
                        argv[i++] = (char *)"-include";
                        argv[i++] = (char *)abi_h;
                    }
                }
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, "core/builtin/builtin.o"));
            }
            if (needs_core_mem)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, "core/mem/mem.o"));
            if (needs_core_slice)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, "core/slice/slice.o"));

            if (needs_db_kv) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, "std/db/kv/kv.o"));
                {
                    const char *rkv = shux_runtime_kv_mmap_glue_o_path(NULL);
                    if (rkv && rkv[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rkv);
                }
            }
            if (needs_db_arrow) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, "std/db/arrow/arrow.o"));
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
                    /* 【Why】random_fill_bytes_c 是 extern C 桩，实现在 runtime_random_fill.o；
                     * shux-c 链路径需显式链入，否则 _random_fill_bytes_c undefined。
                     * 【Invariant】shux_runtime_random_fill_o_path 返回静态缓冲，同 needs_time 模式。 */
                    const char *rrf = shux_runtime_random_fill_o_path(NULL);
                    if (rrf && rrf[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rrf);
                }
            }
            if (needs_time) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, time_o);
                {
                    const char *rto = shux_runtime_time_os_o_path(NULL);
                    if (rto && rto[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rto);
                }
            }
            if (needs_runtime) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_o);
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_panic_o);
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
                    argv[i++] = (char *)"-lws2_32";
#endif
            }
            if (needs_libc_heap) {
#if defined(__linux__) || defined(__APPLE__)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-lc";
#endif
            }
        }
        /* CORE-009 / Docker musl：仅链已按需推入的 core/*.o + -lc；shux_process_* 由生成 C weak 定义。 */
        if (getenv("SHUX_MINIMAL_CC_LINK")) {
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
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, process_o)) {
#if defined(__linux__)
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-pthread";
#endif
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, string_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, heap_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, path_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_panic_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, net_o)) {
            (void)invoke_cc_append_net_tls_ld(argv, &i, argv_cap, net_o, include_root);
            {
                const char *rnub = shux_runtime_net_udp_batch_o_path(NULL);
                if (rnub && rnub[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rnub);
            }
            {
                const char *rnw = shux_runtime_net_workers_o_path(NULL);
                if (rnw && rnw[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rnw);
            }
            /* 【Why 逻辑根源】net.o 引用 io_uring_* weak 符号（io_uring_connect /
               io_uring_accept / io_uring_accept_many / io_uring_connect_many /
               io_uring_prefetch_fd）及 shu_net_udp_recvmmsg2_c / shu_net_udp_sendmmsg2_c /
               shu_net_udp_recvmmsg_buf_c / shu_net_udp_sendmmsg_buf_c 等 weak 符号。
               这些符号定义在 runtime_asm_io_stubs.o（src/asm/runtime_asm_io_stubs.c）。
               若不链入此 .o，Linux 链接器报 undefined reference to 'io_uring_*' /
               'shu_net_udp_*'。
               macOS 上 Mach-O 不支持 weak 符号，io_stubs.o 中 std_io_write_stdout 等
               符号变为强定义，会覆盖 std.io 模块的实现，导致 write_stdout 等测试回归。
               故仅 Linux 需链入 io_stubs.o；macOS 上 net.o 的 io_uring 引用由
               net_import_alias.c 的 C 桥桩或系统库解析。
               【Invariant】Linux: net_o 链入时 runtime_asm_io_stubs.o 必须同时链入；
               macOS: 不链入 io_stubs.o，避免 std_io_* 强符号冲突。
               【Asm/Perf】Linux 上为 weak 符号，链接器选第一个定义，无运行时开销。 */
#if defined(__linux__)
            {
                const char *ris = shux_runtime_asm_io_stubs_o_path(NULL);
                if (ris && ris[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, ris);
            }
#endif
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, thread_o)) {
            {
                const char *rtg = shux_runtime_thread_glue_o_path(NULL);
                if (rtg && rtg[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rtg);
            }
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, time_o)) {
            {
                const char *rto = shux_runtime_time_os_o_path(NULL);
                if (rto && rto[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rto);
            }
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, random_o)) {
            {
                const char *rrf = shux_runtime_random_fill_o_path(NULL);
                if (rrf && rrf[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rrf);
            }
#if defined(_WIN32) || defined(_WIN64)
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-lbcrypt";
#endif
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, env_o)) {
            {
                const char *reo = shux_runtime_env_os_o_path(NULL);
                if (reo && reo[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, reo);
            }
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, sync_o)) {
            {
                const char *rsld = shux_runtime_sync_lock_diag_tls_o_path(NULL);
                if (rsld && rsld[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rsld);
            }
            {
                const char *rso = shux_runtime_sync_os_o_path(NULL);
                if (rso && rso[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rso);
            }
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, encoding_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, base64_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, crypto_o);
        {
            const char *red = shux_runtime_ed25519_ref10_glue_o_path(NULL);
            if (red && red[0])
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, red);
            {
                const char *rci = shux_runtime_crypto_inc_glue_o_path(NULL);
                if (rci && rci[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rci);
            }
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap,
                shux_rel_o_path_from_argv0(include_root, "std/log/log.o"))) {
            {
                const char *rlo = shux_runtime_log_os_o_path(NULL);
                if (rlo && rlo[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rlo);
            }
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, atomic_o)) {
            {
                const char *rag = shux_runtime_atomic_glue_o_path(NULL);
                if (rag && rag[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rag);
            }
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, channel_o)) {
            {
                const char *rcg = shux_runtime_channel_glue_o_path(NULL);
                if (rcg && rcg[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rcg);
            }
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, backtrace_o)) {
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
#endif
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, hash_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, math_o)) {
            {
                const char *rml = shux_runtime_math_libm_o_path(NULL);
                if (rml && rml[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rml);
            }
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-lm";
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, sort_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, ffi_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, db_o)) {
            {
                const char *rsg = shux_runtime_sqlite_glue_o_path(NULL);
                if (rsg && rsg[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rsg);
            }
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-lsqlite3";
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, elf_o);
        /* shux_rel_o_path_from_argv0 用静态缓冲；须在 push 时按 rel 重解析，勿用 runtime.c 早先保存的 json_o 指针。 */
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
            shux_rel_o_path_from_argv0(include_root, "std/json/json.o"));
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
            shux_rel_o_path_from_argv0(include_root, "std/csv/csv.o"));
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, regex_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, compress_o))
            invoke_cc_append_compress_ld(argv, &i, argv_cap, compress_o, NULL);
        else {
            /* F-06 v1 / F-04 v7：无 compress.o，扫描生成 C 按需 -lz/-lzstd/-lbrotli* */
            int needs_zlib = 0;
            int needs_zstd = 0;
            int needs_brotli = 0;
            int j;
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
                    /* zlib 宏包装桩：deflateInit2/inflateInit2 是宏，需真实函数符号 */
                    (void)shux_ensure_runtime_compress_zlib_glue_o(NULL);
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap,
                        shux_runtime_compress_zlib_glue_o_path(NULL));
                }
                if (needs_zstd && i < argv_cap - 1)
                    argv[i++] = (char *)"-lzstd";
                if (needs_brotli && i < argv_cap - 1) {
                    if (i < argv_cap - 1)
                        argv[i++] = (char *)"-lbrotlienc";
                    if (i < argv_cap - 1)
                        argv[i++] = (char *)"-lbrotlidec";
                }
            }
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, unicode_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, dynlib_o)) {
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
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, http_o)) {
            {
                const char *rhg = shux_runtime_http_glue_o_path(NULL);
                if (rhg && rhg[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rhg);
            }
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, shux_rel_o_path_from_argv0(include_root, "std/socketio/socketio.o"));
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, tar_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, simd_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, context_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, datetime_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, uuid_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, url_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, cli_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, security_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, config_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, cache_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, trace_o);
        {
            const char *sched_link = async_scheduler_o;
            int j;
            int task_linked = invoke_cc_argv_push_existing(argv, &i, argv_cap, task_o);
            (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, schema_o);
            if (invoke_cc_argv_push_existing(argv, &i, argv_cap, test_o)) {
                const char *rtfi = shux_runtime_test_fn_invoke_o_path(NULL);
                if (rtfi && rtfi[0])
                    (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rtfi);
            }
            /* 调用方未预检时，扫描生成 C 是否引用 runtime_drain 等 scheduler 符号。 */
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
                    {
                        const char *rsg = shux_runtime_scheduler_glue_o_path(NULL);
                        if (rsg && rsg[0])
                            (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rsg);
                    }
                }
            } else if (invoke_cc_argv_push_existing(argv, &i, argv_cap, sched_link)) {
#if defined(__linux__)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-pthread";
#endif
                {
                    const char *rsg = shux_runtime_scheduler_glue_o_path(NULL);
                    if (rsg && rsg[0])
                        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, rsg);
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
    /* 阶段 8：非调试（-O0）时对产出执行 strip，减小体积（避免传 -s 给 cc 触发 ld 的 obsolete 警告） */
    if (strcmp(opt_level, "0") != 0) {
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
        {
            const char *sargv[3];
            sargv[0] = "strip";
            sargv[1] = out_path;
            sargv[2] = NULL;
            (void)_spawnvp(_P_WAIT, "strip", (const char *const *)sargv);
        }
#else
        pid_t spid = fork();
        if (spid == 0) {
            execlp("strip", "strip", out_path, (char *)NULL);
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

/**
 * 若 net.o / tls_openssl.o 仍为 TLS 桩且 SHUX_NET_TLS 非 stub，尝试 make net-o-openssl / net-o-mbedtls。
 * F-04 v8：OpenSSL 标记在 std/net/tls_openssl.o，不再编译进 net.o。
 * SHUX_NET_TLS：stub | openssl | mbedtls | auto（默认 auto）。
 * 参数：repo_root 仓库根目录绝对路径。
 */
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

/** 扫描用户 .o 未定义符号；nm 失败时返回 0（勿臆测缺符号，避免 on_demand 误链 net/heap）。 */
int shux_link_obj_needs_undef_sym(const char *o_path, const char *sym) {
    char cmd[PATH_MAX + 160];
    FILE *fp;
    char line[512];
    size_t sym_len;
    if (!o_path || !o_path[0] || !sym || !sym[0])
        return 0;
    sym_len = strlen(sym);
#if defined(__APPLE__)
    if ((size_t)snprintf(cmd, sizeof cmd, "nm -u --porcelain '%s' 2>/dev/null", o_path) >= sizeof cmd)
        return 0;
#else
    if ((size_t)snprintf(cmd, sizeof cmd, "nm -u '%s' 2>/dev/null", o_path) >= sizeof cmd)
        return 0;
#endif
    fp = popen(cmd, "r");
    if (!fp)
        return 0; /* nm 不可用时不臆测缺符号，避免 on_demand 全量误链 net/heap 等 */
    while (fgets(line, sizeof line, fp)) {
        if (strncmp(line, sym, sym_len) == 0 &&
            (line[sym_len] == ' ' || line[sym_len] == '\n' || line[sym_len] == '\0')) {
            pclose(fp);
            return 1;
        }
        if (strchr(line, 'U') != NULL && strstr(line, sym) != NULL) {
            pclose(fp);
            return 1;
        }
    }
    pclose(fp);
    return 0;
}

/** ld argv 项是否为已解析的 .o/.obj 路径（跳过 -o、编译器驱动等）。 */
static int link_abi_ld_argv_entry_is_obj(const char *s) {
    size_t n;
    if (!s || !s[0])
        return 0;
    n = strlen(s);
    if (n >= 2u && s[n - 2u] == '.' && s[n - 1u] == 'o')
        return 1;
    if (n >= 4u && strcmp(s + n - 4u, ".obj") == 0)
        return 1;
    return 0;
}

/**
 * 用户主 .o 或已入链 argv 中的 std/*.o 是否仍引用 heap_*_c。
 * hash/sort 等经 libc.x 编译，hello 全量 std 链时 user.o 本身可无 heap 符号。
 */
static int link_abi_link_needs_heap_user_c(const char *user_o, const char **argv, int la) {
    static const char *heap_syms[] = {
        "heap_alloc_c", "heap_free_c", "heap_realloc_c", "heap_arena64_alloc_c",
    };
    size_t si;
    int i;
    if (user_o && user_o[0]) {
        for (si = 0; si < sizeof(heap_syms) / sizeof(heap_syms[0]); si++) {
            if (shux_link_obj_needs_undef_sym(user_o, heap_syms[si]))
                return 1;
        }
    }
    if (!argv || la <= 0)
        return 0;
    for (i = 0; i < la && argv[i]; i++) {
        if (!link_abi_ld_argv_entry_is_obj(argv[i]))
            continue;
        for (si = 0; si < sizeof(heap_syms) / sizeof(heap_syms[0]); si++) {
            if (shux_link_obj_needs_undef_sym(argv[i], heap_syms[si]))
                return 1;
        }
    }
    return 0;
}

int shux_freestanding_user_o_needs_io(const char *user_o) {
    return shux_link_obj_needs_undef_sym(user_o, "shux_sys_write")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_read")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_close")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_exit")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_open")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_openat")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_mmap")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_munmap")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_socket")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_connect")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_bind")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_listen")
        || shux_link_obj_needs_undef_sym(user_o, "shux_sys_accept");
}

int shux_freestanding_user_o_needs_panic(const char *user_o) {
    return shux_link_obj_needs_undef_sym(user_o, "shux_panic_");
}

/**
 * 判断用户 .o 是否引用 std.net API（按需链 net.o，避免 hello 等最小链无条件链 net.o 触发 PIE/未定义符号）。
 */
static int link_abi_user_o_needs_std_net(const char *user_o) {
    if (!user_o || !user_o[0])
        return 0;
    return shux_link_obj_needs_undef_sym(user_o, "std_net_listen")
        || shux_link_obj_needs_undef_sym(user_o, "std_net_connect")
        || shux_link_obj_needs_undef_sym(user_o, "std_net_udp_bind")
        || shux_link_obj_needs_undef_sym(user_o, "std_net_udp_recv_many_buf")
        || shux_link_obj_needs_undef_sym(user_o, "std_net_udp_send_many_buf")
        || shux_link_obj_needs_undef_sym(user_o, "std_net_addr_to_u32")
        || shux_link_obj_needs_undef_sym(user_o, "std_net_close_udp")
        || shux_link_obj_needs_undef_sym(user_o, "net_stream_write_batch_c")
        || shux_link_obj_needs_undef_sym(user_o, "net_tcp_connect_c")
        || shux_link_obj_needs_undef_sym(user_o, "net_tcp_listen_c")
        || shux_link_obj_needs_undef_sym(user_o, "net_udp_bind_c")
        || shux_link_obj_needs_undef_sym(user_o, "net_udp_recv_many_buf_c")
        || shux_link_obj_needs_undef_sym(user_o, "net_udp_send_many_buf_c")
        || shux_link_obj_needs_undef_sym(user_o, "net_close_socket_c")
        || shux_link_obj_needs_undef_sym(user_o, "net_udp_send_c")
        || shux_link_obj_needs_undef_sym(user_o, "net_dns_resolve_c")
        || shux_link_obj_needs_undef_sym(user_o, "net_sock_create_c");
}

/**
 * 判断用户 .o 是否引用 std.set API（按需链 set.o + heap.o）。
 */
static int link_abi_user_o_needs_std_set(const char *user_o) {
    if (!user_o || !user_o[0])
        return 0;
    return shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_insert")
        || shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_contains")
        || shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_remove")
        || shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_len")
        || shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_deinit");
}

/**
 * 判断用户 .o 是否引用 std.heap import 符号（按需链 heap.o bootstrap 桩）。
 */
static int link_abi_user_o_needs_std_heap_import(const char *user_o) {
    if (!user_o || !user_o[0])
        return 0;
    return shux_link_obj_needs_undef_sym(user_o, "std_heap_alloc_i32")
        || shux_link_obj_needs_undef_sym(user_o, "std_heap_alloc_u8")
        || shux_link_obj_needs_undef_sym(user_o, "std_heap_free_i32")
        || shux_link_obj_needs_undef_sym(user_o, "std_heap_free_u8")
        || shux_link_obj_needs_undef_sym(user_o, "std_heap_alloc_size_zero");
}

/**
 * 判断用户 .o 是否引用 std.map API（按需链 map.o）。
 */
static int link_abi_user_o_needs_std_map(const char *user_o) {
    if (!user_o || !user_o[0])
        return 0;
    return shux_link_obj_needs_undef_sym(user_o, "std_map_empty_size");
}

/**
 * 判断用户 .o 是否引用 std.test API（按需链 test.o，避免 hello 等最小链无条件链 test.o 触发 ld 重复）。
 */
static int link_abi_user_o_needs_std_test(const char *user_o) {
    if (!user_o || !user_o[0])
        return 0;
    return shux_link_obj_needs_undef_sym(user_o, "test_call_i32_void_c")
        || shux_link_obj_needs_undef_sym(user_o, "test_runner_")
        || shux_link_obj_needs_undef_sym(user_o, "test_expect_")
        || shux_link_obj_needs_undef_sym(user_o, "test_bench_")
        || shux_link_obj_needs_undef_sym(user_o, "test_f_test_")
        || shux_link_obj_needs_undef_sym(user_o, "test_io_")
        || shux_link_obj_needs_undef_sym(user_o, "test_fuzz_");
}

/**
 * 检查 path 是否已在 ld argv 中（realpath 去重，避免 /src/std/... 与 -L 解析路径重复入链）。
 */
static int link_abi_asm_ld_argv_has_obj(const char **argv, int la, const char *path) {
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
static void link_abi_asm_ld_argv_push_stable(ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la,
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

static int link_abi_asm_ld_push_obj(const char *primary, const char *link_argv0, const char *rel,
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
static void link_abi_asm_ld_push_glue_after_std(int have_std, int (*ensure_fn)(const char *argv0),
    const char *glue_primary, const char *link_argv0, const char *glue_rel, const char **lib_roots, int n_lib_roots,
    ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la) {
    if (!have_std)
        return;
    if (ensure_fn && ensure_fn(link_argv0) != 0)
        return;
    link_abi_asm_ld_push_obj(glue_primary, link_argv0, glue_rel, lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
}

#if defined(__linux__) || defined(__APPLE__)
static int link_abi_user_o_needs_async_scheduler(const char *user_o) {
    static const char *syms[] = {
        "shux_async_coop_pingpong", "shux_async_coop_pingpong_jmp", "shux_async_cps_suspend",
        "shux_async_asm_frame_phase_by_id", "shux_async_asm_frame_store_from_ptr",
        "shux_async_asm_frame_load_to_ptr", "shux_async_asm_frame_reset_by_id",
        "shux_async_cps_suspend_io", "shux_async_run_i32", "shux_async_task_submit",
        "shux_async_task_submit_to", "shux_async_scheduler_drain", "shux_async_worker_drain",
        "shux_async_worker_count", "shux_async_worker_pending", "shux_async_queue_reset",
        "shux_async_scheduler_pending", "shux_async_io_wake_all", "shux_async_io_waiters_pending",
        "shux_async_io_completions_ready", "shux_async_run_seed_set_i32", "shux_async_run_seed_reset",
        "shux_async_run_seed_push_i32", "shux_async_run_seed_push_u32", "shux_async_run_seed_push_i64",
        "shux_async_run_seed_valid", "shux_async_run_seed_take_i32", "shux_async_run_seed_take_u32",
        "shux_async_run_seed_take_i64", "shux_io_submit_read_async", "shux_io_complete_read_async",
        "shux_io_complete_read_async_slot", "shux_io_submit_write_async", "shux_io_complete_write_async",
        "shux_io_complete_write_async_slot",
    };
    size_t i;
    for (i = 0; i < sizeof(syms) / sizeof(syms[0]); i++) {
        if (shux_link_obj_needs_undef_sym(user_o, syms[i]))
            return 1;
    }
    return 0;
}

static int link_abi_user_o_needs_core_mem(const char *user_o) {
    (void)user_o;
    return 0;
}

static int link_abi_user_o_needs_core_slice(const char *user_o) {
    return shux_link_obj_needs_undef_sym(user_o, "core_slice_i32_from_ptr_c")
        || shux_link_obj_needs_undef_sym(user_o, "core_subslice_i32_c")
        || shux_link_obj_needs_undef_sym(user_o, "core_slice_u8_from_ptr_c")
        || shux_link_obj_needs_undef_sym(user_o, "core_subslice_u8_c")
        || shux_link_obj_needs_undef_sym(user_o, "core_slice_u64_from_ptr_c")
        || shux_link_obj_needs_undef_sym(user_o, "core_subslice_u64_c");
}

/**
 * nostdlib 最小 gcc 链（user.o+-lc）仍须链入的 compiler runtime 桩；hello 等依赖 std_fmt_println。
 * popen 桩恒失败时 has_undef 误判为自包含，勿因此省略 io_stubs。
 */
static void link_abi_asm_ld_push_minimal_runtime_objs(const char *link_argv0, const char **lib_roots, int n_lib_roots,
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
static int shux_asm_nostdlib_minimal_selfcontained_exe_link(const char *o_path, const char *exe_path,
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

void shux_asm_ld_append_std_objs(const char *link_argv0, const char **lib_roots, int n_lib_roots,
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
    if (flags)
        memset(flags, 0, sizeof *flags);
    if (flags)
        flags->have_fs = 1;
    if (flags)
        flags->have_io = 1;
    if (shux_runtime_compiler_o_path_copy(link_argv0, "runtime_asm_io_stubs.o", io_stubs_o, sizeof io_stubs_o) == 0)
        io_stubs_p = io_stubs_o;
    link_abi_asm_ld_push_obj(io_stubs_p, link_argv0,
        "compiler/runtime_asm_io_stubs.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);

    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/process/process.o", lib_roots, n_lib_roots, bank, argv, la, max_la, &have_process);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/string/string.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/path/path.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/runtime/runtime.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(shux_runtime_panic_o_path(link_argv0), link_argv0,
        "compiler/runtime_panic.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/thread/thread.o", lib_roots, n_lib_roots, bank, argv, la, max_la, flags ? &flags->have_thread : NULL);
    link_abi_asm_ld_push_glue_after_std(flags && flags->have_thread, shux_ensure_runtime_thread_glue_o,
        shux_runtime_thread_glue_o_path(link_argv0), link_argv0,
        "compiler/runtime_thread_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    link_abi_asm_ld_push_obj(shux_runtime_time_os_o_path(link_argv0), link_argv0,
        "compiler/runtime_time_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/time/time.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(shux_runtime_random_fill_o_path(link_argv0), link_argv0,
        "compiler/runtime_random_fill.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/random/random.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(shux_runtime_env_os_o_path(link_argv0), link_argv0,
        "compiler/runtime_env_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/env/env.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/sync/sync.o", lib_roots, n_lib_roots, bank, argv, la, max_la, flags ? &flags->have_sync : NULL);
    if (flags && flags->have_sync) {
        link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_sync_lock_diag_tls_o,
            shux_runtime_sync_lock_diag_tls_o_path(link_argv0), link_argv0,
            "compiler/runtime_sync_lock_diag_tls.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
        link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_sync_os_o,
            shux_runtime_sync_os_o_path(link_argv0), link_argv0,
            "compiler/runtime_sync_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    }
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/encoding/encoding.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/base64/base64.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/crypto/crypto.o", lib_roots, n_lib_roots, bank, argv, la, max_la, &have_crypto);
    if (have_crypto) {
        link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_ed25519_ref10_glue_o,
            shux_runtime_ed25519_ref10_glue_o_path(link_argv0), link_argv0,
            "compiler/runtime_ed25519_ref10_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
        link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_crypto_inc_glue_o,
            shux_runtime_crypto_inc_glue_o_path(link_argv0), link_argv0,
            "compiler/runtime_crypto_inc_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    }
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/log/log.o", lib_roots, n_lib_roots, bank, argv, la, max_la, &have_log);
    link_abi_asm_ld_push_glue_after_std(have_log, shux_ensure_runtime_log_os_o,
        shux_runtime_log_os_o_path(link_argv0), link_argv0,
        "compiler/runtime_log_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/atomic/atomic.o", lib_roots, n_lib_roots, bank, argv, la, max_la, &have_atomic);
    link_abi_asm_ld_push_glue_after_std(have_atomic, shux_ensure_runtime_atomic_glue_o,
        shux_runtime_atomic_glue_o_path(link_argv0), link_argv0,
        "compiler/runtime_atomic_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/channel/channel.o", lib_roots, n_lib_roots, bank, argv, la, max_la, flags ? &flags->have_channel : NULL);
    link_abi_asm_ld_push_glue_after_std(flags && flags->have_channel, shux_ensure_runtime_channel_glue_o,
        shux_runtime_channel_glue_o_path(link_argv0), link_argv0,
        "compiler/runtime_channel_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/backtrace/backtrace.o", lib_roots, n_lib_roots, bank, argv, la, max_la, &have_backtrace);
    link_abi_asm_ld_push_glue_after_std(have_backtrace, shux_ensure_runtime_backtrace_platform_o,
        shux_runtime_backtrace_platform_o_path(link_argv0), link_argv0,
        "compiler/runtime_backtrace_platform.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/hash/hash.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/math/math.o", lib_roots, n_lib_roots, bank, argv, la, max_la, flags ? &flags->have_math : NULL);
    link_abi_asm_ld_push_glue_after_std(flags && flags->have_math, shux_ensure_runtime_math_libm_o,
        shux_runtime_math_libm_o_path(link_argv0), link_argv0,
        "compiler/runtime_math_libm.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/sort/sort.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/ffi/ffi.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/db/sqlite/sqlite.o", lib_roots, n_lib_roots, bank, argv, la, max_la, flags ? &flags->have_sqlite : NULL);
    link_abi_asm_ld_push_glue_after_std(flags && flags->have_sqlite, shux_ensure_runtime_sqlite_glue_o,
        shux_runtime_sqlite_glue_o_path(link_argv0), link_argv0,
        "compiler/runtime_sqlite_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/elf/elf.o", lib_roots, n_lib_roots, bank, argv, la, max_la, flags ? &flags->have_elf : NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/json/json.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/csv/csv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/regex/regex.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    /* F-06 v1 / F-04 v7：compress 已纯 .x，无 compress.o；tail libs 由 user_o 扫描按需 -lz/-lzstd/-lbrotli* */
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/unicode/unicode.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/dynlib/dynlib.o", lib_roots, n_lib_roots, bank, argv, la, max_la, flags ? &flags->have_dynlib : NULL);
    link_abi_asm_ld_push_glue_after_std(flags && flags->have_dynlib, shux_ensure_runtime_dynlib_os_o,
        shux_runtime_dynlib_os_o_path(link_argv0), link_argv0,
        "compiler/runtime_dynlib_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/http/http.o", lib_roots, n_lib_roots, bank, argv, la, max_la, &have_http);
    link_abi_asm_ld_push_glue_after_std(have_http, shux_ensure_runtime_http_glue_o,
        shux_runtime_http_glue_o_path(link_argv0), link_argv0,
        "compiler/runtime_http_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/socketio/socketio.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/tar/tar.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/simd/simd.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/context/context.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/datetime/datetime.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/uuid/uuid.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/url/url.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/cli/cli.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/security/security.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/config/config.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/cache/cache.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    link_abi_asm_ld_push_obj(NULL, link_argv0, "std/trace/trace.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, "std/task/task.o"));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/task/task.o", lib_roots, n_lib_roots, bank);
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

void shux_asm_ld_append_on_demand_user_objs(const char *link_argv0, const char *user_o,
    const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank,
    const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags) {
#if defined(__linux__) || defined(__APPLE__)
    const char *p;
    if (!user_o || !user_o[0] || !la || *la >= max_la - 1)
        return;
    if (link_abi_user_o_needs_std_net(user_o)) {
        int have_net = 0;
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/net/net.o", lib_roots, n_lib_roots, bank, argv, la, max_la, &have_net);
        if (have_net) {
            if (flags)
                flags->have_net = 1;
            /* workers.x 依赖 thread_create_c；按需再推 thread.o + glue（默认 ld 可能未链）。 */
            link_abi_asm_ld_push_obj(NULL, link_argv0, "std/thread/thread.o", lib_roots, n_lib_roots, bank, argv, la, max_la,
                flags ? &flags->have_thread : NULL);
            if (flags && flags->have_thread) {
                link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_thread_glue_o,
                    shux_runtime_thread_glue_o_path(link_argv0), link_argv0,
                    "compiler/runtime_thread_glue.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            }
            link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_net_udp_batch_o,
                shux_runtime_net_udp_batch_o_path(link_argv0), link_argv0,
                "compiler/runtime_net_udp_batch.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
            link_abi_asm_ld_push_glue_after_std(1, shux_ensure_runtime_net_workers_o,
                shux_runtime_net_workers_o_path(link_argv0), link_argv0,
                "compiler/runtime_net_workers.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
        }
    }
    if (link_abi_user_o_needs_std_heap_import(user_o)) {
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/heap/heap.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    if (link_abi_user_o_needs_std_set(user_o)) {
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/set/set.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        if (!link_abi_user_o_needs_std_heap_import(user_o)) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, "std/heap/heap.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    if (link_abi_user_o_needs_std_map(user_o)) {
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/map/map.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    if (link_abi_user_o_needs_async_scheduler(user_o)) {
        p = asm_link_obj_skip_missing(shux_std_async_scheduler_o_path(link_argv0));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("std/async/scheduler.o", lib_roots, n_lib_roots, bank);
        if (p && *la < max_la - 1)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p && *la < max_la - 1) {
            const char *rsg = asm_link_obj_skip_missing(shux_runtime_scheduler_glue_o_path(link_argv0));
            if (!rsg && bank)
                rsg = shux_asm_ld_try_under_lib_roots("compiler/runtime_scheduler_glue.o", lib_roots, n_lib_roots, bank);
            if (rsg)
                link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, rsg);
        }
    }
    if (link_abi_user_o_needs_core_mem(user_o)) {
        p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, "core/mem/mem.o"));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("core/mem/mem.o", lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
    }
    if (link_abi_user_o_needs_core_slice(user_o)) {
        p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, "core/slice/slice.o"));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("core/slice/slice.o", lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
    }
    if (shux_link_obj_needs_undef_sym(user_o, "db_kv_open_c") || shux_link_obj_needs_undef_sym(user_o, "db_kv_get_c")) {
        p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, "std/db/kv/kv.o"));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("std/db/kv/kv.o", lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p && *la < max_la - 1) {
            const char *rkv = asm_link_obj_skip_missing(shux_runtime_kv_mmap_glue_o_path(link_argv0));
            if (!rkv && bank)
                rkv = shux_asm_ld_try_under_lib_roots("compiler/runtime_kv_mmap_glue.o", lib_roots, n_lib_roots, bank);
            if (rkv)
                link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, rkv);
        }
    }
    if (shux_link_obj_needs_undef_sym(user_o, "arrow_column_i32_create_c")
        || shux_link_obj_needs_undef_sym(user_o, "arrow_column_adopt_f32_c")) {
        p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, "std/db/arrow/arrow.o"));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("std/db/arrow/arrow.o", lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p && *la < max_la - 1) {
            const char *rar = asm_link_obj_skip_missing(shux_runtime_arrow_simd_glue_o_path(link_argv0));
            if (!rar && bank)
                rar = shux_asm_ld_try_under_lib_roots("compiler/runtime_arrow_simd_glue.o", lib_roots, n_lib_roots, bank);
            if (rar)
                link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, rar);
        }
    }
    if (link_abi_user_o_needs_std_test(user_o)) {
        int have_test = 0;
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/test/test.o", lib_roots, n_lib_roots, bank, argv, la, max_la, &have_test);
        link_abi_asm_ld_push_glue_after_std(have_test, shux_ensure_runtime_test_fn_invoke_o,
            shux_runtime_test_fn_invoke_o_path(link_argv0), link_argv0,
            "compiler/runtime_test_fn_invoke.o", lib_roots, n_lib_roots, bank, argv, la, max_la);
    }
    if (link_abi_link_needs_heap_user_c(user_o, argv, la ? *la : 0)) {
        if (shux_ensure_runtime_heap_user_o(link_argv0) != 0)
            return;
        link_abi_asm_ld_push_obj(shux_runtime_heap_user_o_path(link_argv0), link_argv0, "compiler/runtime_heap_user.o",
                                 lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        if (flags)
            flags->have_libc_heap = 1;
    }
    /** co-emit std.string/mod.x 时 call 重定向到 string.o 内 shux_string_*；import binding 走 std_string_* 别名桩。 */
    if (shux_link_obj_needs_undef_sym(user_o, "shux_string_copy_c")
        || shux_link_obj_needs_undef_sym(user_o, "shux_string_memcmp_c")
        || shux_link_obj_needs_undef_sym(user_o, "shux_string_memchr_c")
        || shux_link_obj_needs_undef_sym(user_o, "shux_string_memmem_c")
        || shux_link_obj_needs_undef_sym(user_o, "shux_string_memrchr_c")
        || shux_link_obj_needs_undef_sym(user_o, "std_string_string_new")
        || shux_link_obj_needs_undef_sym(user_o, "std_string_string_from_slice")
        || shux_link_obj_needs_undef_sym(user_o, "std_string_string_view")
        || shux_link_obj_needs_undef_sym(user_o, "std_string_string_len")) {
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/string/string.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    /** core.types 跳过 co-emit；size_of/align_of 由 base64.o 导出 core_types_*。 */
    if (shux_link_obj_needs_undef_sym(user_o, "core_types_size_of_i32")
        || shux_link_obj_needs_undef_sym(user_o, "core_types_placeholder")) {
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/base64/base64.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    /** co-emit std.encoding/mod.x 调用 encoding_*_c；按需链 encoding.o。 */
    if (shux_link_obj_needs_undef_sym(user_o, "encoding_utf8_valid_c")
        || shux_link_obj_needs_undef_sym(user_o, "encoding_hex_encode_c")
        || shux_link_obj_needs_undef_sym(user_o, "encoding_ascii_is_alpha_c")
        || shux_link_obj_needs_undef_sym(user_o, "std_encoding_utf8_valid")
        || shux_link_obj_needs_undef_sym(user_o, "std_encoding_utf8_decode_rune")
        || shux_link_obj_needs_undef_sym(user_o, "std_encoding_ascii_is_alpha")) {
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/encoding/encoding.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    /** co-emit std.base64/mod.x 调用 base64_*_c；按需链 base64.o（含 std_base64_* 别名桩）。 */
    if (shux_link_obj_needs_undef_sym(user_o, "base64_encode_standard_c")
        || shux_link_obj_needs_undef_sym(user_o, "std_base64_encode_standard")
        || shux_link_obj_needs_undef_sym(user_o, "std_base64_decode_standard")
        || shux_link_obj_needs_undef_sym(user_o, "std_base64_encode_url")) {
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/base64/base64.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    /** co-emit std.time/mod.x 调用 time_*_c；按需链 time.o + runtime_time_os.o。 */
    if (shux_link_obj_needs_undef_sym(user_o, "std_time_now_monotonic_ns")
        || shux_link_obj_needs_undef_sym(user_o, "std_time_sleep_ms")
        || shux_link_obj_needs_undef_sym(user_o, "std_time_timer_start")
        || shux_link_obj_needs_undef_sym(user_o, "time_now_monotonic_ns_c")) {
        if (shux_ensure_runtime_time_os_o(link_argv0) == 0)
            link_abi_asm_ld_push_obj(shux_runtime_time_os_o_path(link_argv0), link_argv0,
                                     "compiler/runtime_time_os.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/time/time.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    /** import std.csv 按需链 csv.o（含 std_csv_escape 别名桩）。 */
    if (shux_link_obj_needs_undef_sym(user_o, "std_csv_next_field")
        || shux_link_obj_needs_undef_sym(user_o, "std_csv_escape")
        || shux_link_obj_needs_undef_sym(user_o, "std_csv_csv_test_quoted_first")) {
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/csv/csv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    if (shux_link_obj_needs_undef_sym(user_o, "schema_create_c")
        || shux_link_obj_needs_undef_sym(user_o, "schema_decode_json_c")
        || shux_link_obj_needs_undef_sym(user_o, "schema_smoke_c")) {
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/schema/schema.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    if (shux_link_obj_needs_undef_sym(user_o, "sync_queue_contention_smoke_c")
        || shux_link_obj_needs_undef_sym(user_o, "queue_os_run_two_workers_c")
        || shux_link_obj_needs_undef_sym(user_o, "queue_contention_worker_push_c")) {
        (void)shux_ensure_runtime_queue_contention_o(link_argv0);
        link_abi_asm_ld_push_obj(shux_runtime_queue_contention_o_path(link_argv0), link_argv0,
            "compiler/runtime_queue_contention.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/queue/queue.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
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
        /* hello 等最小链：仅 ensure 恒链 runtime 对象；glue 随 std/*.o 按需 skip_missing，勿预编译 sqlite/http 等。 */
        if (shux_ensure_runtime_asm_io_stubs_o(link_eff) != 0)
            return -1;
        if (shux_ensure_runtime_process_argv_o(link_eff) != 0)
            return -1;
        if (shux_ensure_runtime_random_fill_o(link_eff) != 0)
            return -1;
        if (shux_ensure_runtime_time_os_o(link_eff) != 0)
            return -1;
        if (shux_ensure_runtime_env_os_o(link_eff) != 0)
            return -1;
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
    if (!fp)
        return 0; /* nostdlib 无 popen：优先 gcc 最小链 user.o+-lc，避免 append 全量 std/*.o 栈溢出 */
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
 * 参数：compress_o std/compress/compress.o 路径；user_o 用户主 .o；append_lsystem 非 0 时在 ld 路径追加 -lSystem。
 */
void shux_asm_ld_append_mach_tail_libs(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    const char **argv, int *la, int max_la, int append_lsystem) {
    int need_pt;
    if (!flags || !argv || !la || *la < 0)
        return;
    need_pt = flags->have_thread || flags->have_sync || flags->have_channel;
    if (flags->have_math && *la < max_la - 1)
        argv[(*la)++] = "-lm";
    if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
        asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
    if (flags->have_sqlite && *la < max_la - 1)
        argv[(*la)++] = "-lsqlite3";
    if (need_pt && *la < max_la - 1)
        argv[(*la)++] = "-pthread";
    if (append_lsystem && *la < max_la - 1)
        argv[(*la)++] = "-lSystem";
}

/**
 * Linux/Unix gcc 或裸 ld 路径：按 std 链入标记追加 -pthread、-lm、压缩库、-ldl、-lc（F-03 v2/v3 无 -luring）。
 * 参数：compress_o std/compress/compress.o 路径；user_o 用户主 .o；need_pt 已由 thread/sync/channel 推导。
 */
void shux_asm_ld_append_unix_gcc_tail_libs(const char *compress_o, const char *user_o, const ShuAsmLdStdLinkFlags *flags,
    int need_pt, const char **argv, int *la, int max_la) {
    if (!flags || !argv || !la || *la < 0)
        return;
    if (flags->have_io) {
        if (need_pt && *la < max_la - 1)
            argv[(*la)++] = "-pthread";
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = "-lm";
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = "-lsqlite3";
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = "-ldl";
#endif
        if (*la < max_la - 1)
            argv[(*la)++] = "-lc";
    } else if (flags->have_net && need_pt) {
        if (*la < max_la - 1)
            argv[(*la)++] = "-lpthread";
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = "-lm";
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = "-lsqlite3";
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = "-ldl";
#endif
        if (*la < max_la - 1)
            argv[(*la)++] = "-lc";
    } else if (flags->have_net) {
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = "-lm";
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = "-lsqlite3";
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = "-ldl";
#endif
        if (*la < max_la - 1)
            argv[(*la)++] = "-lc";
    } else if (need_pt) {
        if (*la < max_la - 1)
            argv[(*la)++] = "-lpthread";
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = "-lm";
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = "-lsqlite3";
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = "-ldl";
#endif
        if (*la < max_la - 1)
            argv[(*la)++] = "-lc";
    } else {
        if (flags->have_math && *la < max_la - 1)
            argv[(*la)++] = "-lm";
        if (flags->have_compress || link_abi_user_o_needs_compress_libs(user_o))
            asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
        if (flags->have_sqlite && *la < max_la - 1)
            argv[(*la)++] = "-lsqlite3";
#if defined(__linux__)
        if (flags->have_dynlib && *la < max_la - 1)
            argv[(*la)++] = "-ldl";
#endif
#if defined(__linux__) || defined(__APPLE__)
        if ((flags->have_libc_heap || flags->have_fs || flags->have_math || flags->have_compress || flags->have_sqlite
                || flags->have_dynlib) && *la < max_la - 1)
            argv[(*la)++] = "-lc";
#endif
    }
}

#if defined(__linux__)
/**
 * Linux release 链接硬化：PIE + NX（GNU_STACK 无 E）+ partial RELRO。
 * 参数：argv/la/cap 为 gcc/ld 链接 argv 构建状态。
 */
void shux_append_linux_link_harden(char *argv[], int *la, int cap) {
    if (!argv || !la || *la < 0)
        return;
    if (*la < cap - 1)
        argv[(*la)++] = "-pie";
    if (*la < cap - 1)
        argv[(*la)++] = "-fpie";
    if (*la < cap - 1)
        argv[(*la)++] = "-Wl,-z,noexecstack";
    if (*la < cap - 1)
        argv[(*la)++] = "-Wl,-z,relro";
    /** import("core.mem") 将 mem 符号编入用户 .o；全量 std 链 sort/net 等亦内联 mem，须允许多定义。 */
    if (*la < cap - 1)
        argv[(*la)++] = "-Wl,--allow-multiple-definition";
}
#endif

/**
 * ASM -o exe：fork 子进程执行 clang/ld 或 lld-link/ld；调用方须先 shux_asm_ld_prepare_for_exe_link。
 * 参数：driver_freestanding 同 shux_link_freestanding_enabled；link_argv0 用于 std/.o 路径解析。
 * 返回值：0 成功，-1 失败。
 */
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
            argv[la++] = "clang";
            argv[la++] = "-o";
            argv[la++] = exe_path;
            argv[la++] = o_path;
            shux_asm_ld_append_std_objs(link_eff, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_mach_tail_libs(compress_o, o_path, &ldflags, (const char **)argv, &la, SHUX_LD_ARGV_CAP, 0);
            argv[la] = NULL;
            {
                int rc = shux_spawn_sync("clang", (const char *const *)argv);
                if (rc == 0)
                    return 0;
            }
            la = 0;
            ld_bank->n = 0;
            memset(ld_bank->slots, 0, sizeof ld_bank->slots);
            argv[la++] = "ld";
            argv[la++] = "-e";
            argv[la++] = "_main";
            argv[la++] = "-o";
            argv[la++] = exe_path;
            argv[la++] = o_path;
            shux_asm_ld_append_std_objs(link_eff, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_mach_tail_libs(compress_o, o_path, &ldflags, (const char **)argv, &la, SHUX_LD_ARGV_CAP, 1);
            argv[la] = NULL;
            {
                int rc = shux_spawn_sync("ld", (const char *const *)argv);
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
            shux_asm_ld_append_std_objs(link_eff, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            shux_asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
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
            int need_io = 0;
            int need_panic = 0;
            need_io = shux_freestanding_user_o_needs_io(o_path);
            need_panic = shux_freestanding_user_o_needs_panic(o_path);
            argv[la++] = "ld";
            argv[la++] = "-nostdlib";
            argv[la++] = "-static";
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "--gc-sections";
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
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = crt0_p;
            if (need_panic && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = panic_p;
            if (need_io && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = io_p;
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = o_path;
            argv[la] = NULL;
            {
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
            /** co-emit std.string 时 user.o 常引用 shux_string_*；最小链亦尝试链 string.o（~2KB，popen/nm 不可用时仍绿）。 */
            link_abi_asm_ld_push_obj(NULL, link_eff, "std/string/string.o", lib_roots_eff, n_lib_roots_eff, ld_bank, argv,
                                     &la, SHUX_LD_ARGV_CAP, NULL);
            /** core.types 符号由 base64.o 提供（skip co-emit）；core-types gate 等最小链亦须链入。 */
            link_abi_asm_ld_push_obj(NULL, link_eff, "std/base64/base64.o", lib_roots_eff, n_lib_roots_eff, ld_bank, argv,
                                     &la, SHUX_LD_ARGV_CAP, NULL);
            link_abi_asm_ld_push_obj(NULL, link_eff, "std/encoding/encoding.o", lib_roots_eff, n_lib_roots_eff, ld_bank, argv,
                                     &la, SHUX_LD_ARGV_CAP, NULL);
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lc";
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
#else
        argv[la++] = "ld";
        argv[la++] = "-e";
        argv[la++] = "_main";
#endif
        argv[la++] = "-o";
        argv[la++] = exe_path;
        argv[la++] = o_path;
        shux_asm_ld_append_std_objs(link_eff, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
        shux_asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots_eff, n_lib_roots_eff, ld_bank, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
        if (link_abi_user_o_needs_libc_heap(o_path))
            ldflags.have_libc_heap = 1;
        need_pt = ldflags.have_thread || ldflags.have_sync || ldflags.have_channel;
        shux_asm_ld_append_unix_gcc_tail_libs(compress_o, o_path, &ldflags, need_pt, (const char **)argv, &la, SHUX_LD_ARGV_CAP);
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
int shux_output_is_elf_o(const char *path) {
    if (!path)
        return 0;
    size_t n = strlen(path);
    if (n >= 2 && path[n - 2] == '.' && (path[n - 1] == 'o' || path[n - 1] == 'O'))
        return 1;
    return n >= 4 && path[n - 4] == '.' && path[n - 3] == 'o' && path[n - 2] == 'b' && path[n - 1] == 'j';
}

/**
 * 判断 -o 路径是否表示可执行文件名（非 .o/.obj/.s 后缀）。
 * 参数：path 为 -o 参数；空串或 NULL 则返回 0。
 * 返回值：非 0 表示 -backend asm 应自动调 ld 出 exe。
 */
int shux_output_want_exe(const char *path) {
    if (!path || !*path)
        return 0;
    size_t n = strlen(path);
    if (n >= 2 && path[n - 2] == '.' && (path[n - 1] == 'o' || path[n - 1] == 'O'))
        return 0;
    if (n >= 4 && path[n - 4] == '.' && path[n - 3] == 'o' && path[n - 2] == 'b' && path[n - 1] == 'j')
        return 0;
    if (n >= 2 && path[n - 2] == '.' && path[n - 1] == 's')
        return 0;
    return 1;
}

/**
 * ASM -o exe 薄包装：ensure .o + shux_asm_ld_prepare_for_exe_link + shux_asm_invoke_ld_platform。
 * 参数：link_argv0 用于 std/.o 路径解析，可为 NULL；lib_roots 与 driver -L 一致。
 * 返回值：0 成功，-1 失败。
 */
int shux_invoke_ld_for_exe(const char *o_path, const char *exe_path, const char *target,
    int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots) {
    char link_argv_syn[PATH_MAX];
    const char *link_eff;
    int freestanding;

    if (!o_path || !exe_path)
        return -1;
    link_eff = shux_asm_ld_effective_link_argv0(link_argv0, link_argv_syn, sizeof link_argv_syn);
    if (!link_eff)
        return -1;
    freestanding = driver_freestanding_get();
    if (shux_asm_ld_prepare_for_exe_link(link_eff, o_path, freestanding, use_macho_o, use_coff_o) != 0)
        return -1;
    return shux_asm_invoke_ld_platform(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots,
        freestanding);
}
