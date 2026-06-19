/**
 * fmt_check_cmd.c — shux fmt / shux check CLI（对标 deno fmt、deno check）
 *
 * fmt：无路径参数时递归处理当前目录 *.sx；--check 全通过时无输出；失败时列出需格式化的文件。
 * check：多文件/目录；诊断格式 path:line:col - error: message；全通过时无输出。
 */

#include "driver/fmt_check_cmd.h"
#include "lsp/lsp_diag.h"
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

extern int driver_fmt_one_file(const uint8_t *path, int path_len);
extern void driver_fmt_check_only_set(int32_t v);
extern int32_t driver_fmt_check_only_get(void);
extern void driver_check_only_set(int32_t v);
extern int run_compiler_c(int argc, char **argv);
#ifdef SHUX_USE_SX_PIPELINE
extern int driver_run_compiler_full(int argc, char **argv);
extern void driver_dep_seeded_clear_all(void);
#endif

/** 单目录遍历时最多收集的 .sx 路径数。 */
#define DRIVER_FMT_MAX_FILES 8192
/** 忽略规则条数（CLI --ignore + 内置）。 */
#define DRIVER_FMT_MAX_IGNORE 32

static char s_check_current_file[512];

static const char *s_builtin_ignore[] = {
    "/.git/", "/build_asm/", "/build/", "/node_modules/", "/.cursor/", "/compiler/build_asm/",
    "/compiler/build/", "/compiler/tests/", NULL};

/** check 全部成功时不打印 check OK（deno check 静默成功）。 */
static int s_check_quiet_ok = 1;

/**
 * 供 runtime.c 查询：check 子命令是否抑制逐文件 check OK 行。
 */
int driver_check_quiet_ok_get(void) {
    return s_check_quiet_ok;
}

static char s_unformatted_paths[DRIVER_FMT_MAX_FILES][512];
static int s_unformatted_count;

static char s_ignore_paths[DRIVER_FMT_MAX_IGNORE][256];
static int s_n_ignore;

static char *s_file_list[DRIVER_FMT_MAX_FILES];
static int s_n_files;

/** check 默认 -L：cwd；用户未传 -L 时按路径追加（见 check_argv_append_default_libs_for_path）。 */
static char s_check_lib_bufs[8][512];
static int s_n_check_lib_bufs;
static int s_user_passed_L;

/**
 * 若 dir 下同时存在 core/ 与 std/ 子目录，则作为仓库 lib 根注入 -L（去重）。
 */
static void check_try_append_lib_root(char **check_argv, int *n, const char *dir) {
    char core_path[560];
    char std_path[560];
    struct stat st;
    int i;

    if (s_user_passed_L || *n >= 58 || !dir || !dir[0])
        return;
    snprintf(core_path, sizeof core_path, "%s/core", dir);
    snprintf(std_path, sizeof std_path, "%s/std", dir);
    if (stat(core_path, &st) != 0 || !S_ISDIR(st.st_mode))
        return;
    if (stat(std_path, &st) != 0 || !S_ISDIR(st.st_mode))
        return;
    for (i = 0; i < s_n_check_lib_bufs; i++) {
        if (strcmp(s_check_lib_bufs[i], dir) == 0)
            return;
    }
    if (s_n_check_lib_bufs >= 8)
        return;
    snprintf(s_check_lib_bufs[s_n_check_lib_bufs], sizeof s_check_lib_bufs[0], "%s", dir);
    check_argv[(*n)++] = "-L";
    check_argv[(*n)++] = s_check_lib_bufs[s_n_check_lib_bufs++];
}

/**
 * 从 path 所在目录向上查找含 core/ + std/ 的仓库根并注入 -L。
 */
static void check_append_repo_lib_roots(const char *path, char **check_argv, int *n) {
    char start[512];
    char cur[512];
    char parent[512];
    int depth;

    if (s_user_passed_L || *n >= 58)
        return;
    if (!path || !path[0]) {
        if (getcwd(start, sizeof start))
            check_try_append_lib_root(check_argv, n, start);
        return;
    }
    if (path[0] == '/') {
        snprintf(start, sizeof start, "%s", path);
    } else {
        if (!getcwd(start, sizeof start))
            return;
        size_t sl = strlen(start);
        snprintf(start + sl, sizeof start - sl, "/%s", path);
    }
    /* 取目录部分 */
    {
        char *slash = strrchr(start, '/');
        if (slash && slash != start)
            *slash = '\0';
        else if (slash == start)
            start[1] = '\0';
    }
    snprintf(cur, sizeof cur, "%s", start);
    for (depth = 0; depth < 8; depth++) {
        check_try_append_lib_root(check_argv, n, cur);
        if (strcmp(cur, "/") == 0)
            break;
        snprintf(parent, sizeof parent, "%s", cur);
        {
            char *slash = strrchr(parent, '/');
            if (!slash)
                break;
            if (slash == parent)
                strcpy(cur, "/");
            else {
                *slash = '\0';
                snprintf(cur, sizeof cur, "%s", parent);
            }
        }
    }
}

/**
 * 扫描 argv：用户是否已传 -L（有则不再注入默认库根）。
 */
static void check_init_user_lib_flags(int argc, char **argv, int path_start) {
    int i;
    s_user_passed_L = 0;
    s_n_check_lib_bufs = 0;
    for (i = path_start; i < argc; i++) {
        if (argv[i] && strcmp(argv[i], "-L") == 0) {
            s_user_passed_L = 1;
            return;
        }
    }
}

/**
 * 按待检查文件路径注入默认 -L（在单文件路径之前）。
 * 始终注入仓库根；compiler/src 下文件再追加 compiler/src 库根（裸 import lexer/token）。
 */
static void check_argv_append_default_libs_for_path(const char *path, char **check_argv, int *n) {
    char cwd_buf[512];
    char cs[560];
    struct stat st;

    if (s_user_passed_L || *n >= 58)
        return;
    check_append_repo_lib_roots(path, check_argv, n);
    if (!getcwd(cwd_buf, sizeof cwd_buf))
        return;
    check_try_append_lib_root(check_argv, n, cwd_buf);
    if (path && strstr(path, "compiler/src/") && *n < 56) {
        snprintf(cs, sizeof cs, "%s/compiler/src", cwd_buf);
        if (stat(cs, &st) == 0 && S_ISDIR(st.st_mode)) {
            snprintf(s_check_lib_bufs[s_n_check_lib_bufs], sizeof s_check_lib_bufs[0], "%s", cs);
            check_argv[(*n)++] = "-L";
            check_argv[(*n)++] = s_check_lib_bufs[s_n_check_lib_bufs++];
        }
        if (strstr(path, "compiler/src/asm/") && *n < 56) {
            snprintf(cs, sizeof cs, "%s/compiler/src/asm", cwd_buf);
            if (stat(cs, &st) == 0 && S_ISDIR(st.st_mode)) {
                snprintf(s_check_lib_bufs[s_n_check_lib_bufs], sizeof s_check_lib_bufs[0], "%s", cs);
                check_argv[(*n)++] = "-L";
                check_argv[(*n)++] = s_check_lib_bufs[s_n_check_lib_bufs++];
            }
        }
    }
}

/**
 * SHUX_LINT_CI_FAIL_ON=warn 时 warning 层诊断亦令 check 非零退出。
 */
static int check_lint_fail_on_warnings(void) {
    const char *v = getenv("SHUX_LINT_CI_FAIL_ON");
    return v && (strcmp(v, "warn") == 0 || strcmp(v, "warning") == 0);
}

/**
 * 单文件 check：SU pipeline 走 driver_run_compiler_full，shux-c 走 run_compiler_c。
 */
static int fmt_check_invoke_compile(int argc, char **check_argv) {
#ifdef SHUX_USE_SX_PIPELINE
    return driver_run_compiler_full(argc, check_argv);
#else
    return run_compiler_c(argc, check_argv);
#endif
}

/**
 * check 批次结束后清理 dep 槽（仅 SU pipeline 需要）。
 */
static void fmt_check_dep_clear(void) {
#ifdef SHUX_USE_SX_PIPELINE
    driver_dep_seeded_clear_all();
#endif
}

/**
 * 记录当前 check 的源文件路径，供诊断前缀使用。
 */
void driver_check_set_current_file(const char *path) {
    if (!path) {
        s_check_current_file[0] = '\0';
        return;
    }
    snprintf(s_check_current_file, sizeof s_check_current_file, "%s", path);
}

/**
 * 将 lsp_diag 收集器中的条目打印为 deno 风格行；返回条数。
 */
int driver_check_print_collected_diagnostics(const char *path) {
    extern int lsp_diag_enabled;
    (void)lsp_diag_enabled;
    return lsp_diag_print_stderr_human(path ? path : s_check_current_file);
}

/**
 * 路径是否应忽略（内置 + --ignore 子串匹配）。
 */
static int path_should_ignore(const char *path) {
    int i;
    if (!path)
        return 1;
    for (i = 0; s_builtin_ignore[i]; i++) {
        if (strstr(path, s_builtin_ignore[i]))
            return 1;
    }
    for (i = 0; i < s_n_ignore; i++) {
        if (s_ignore_paths[i][0] && strstr(path, s_ignore_paths[i]))
            return 1;
    }
    return 0;
}

/**
 * 将相对/绝对路径加入待处理列表（去重由调用方保证顺序）。
 */
static int file_list_push(const char *path) {
    char ab[512];
    if (!path || s_n_files >= DRIVER_FMT_MAX_FILES)
        return -1;
    if (path[0] != '/') {
        if (!getcwd(ab, sizeof ab))
            return -1;
        size_t n = strlen(ab);
        if (n + 1 + strlen(path) >= sizeof ab)
            return -1;
        ab[n] = '/';
        strcpy(ab + n + 1, path);
        path = ab;
    } else {
        snprintf(ab, sizeof ab, "%s", path);
        path = ab;
    }
    if (path_should_ignore(path))
        return 0;
    size_t len = strlen(path);
    if (len < 4 || strcmp(path + len - 3, ".sx") != 0)
        return 0;
    s_file_list[s_n_files] = strdup(path);
    if (!s_file_list[s_n_files])
        return -1;
    s_n_files++;
    return 0;
}

/**
 * 递归遍历目录，收集 .sx 文件。
 */
static void walk_dir_collect(const char *dir) {
    DIR *d = opendir(dir);
    struct dirent *ent;
    char child[768];
    if (!d)
        return;
    while ((ent = readdir(d)) != NULL) {
        if (ent->d_name[0] == '.')
            continue;
        snprintf(child, sizeof child, "%s/%s", dir, ent->d_name);
        if (path_should_ignore(child))
            continue;
        if (ent->d_type == DT_DIR || ent->d_type == DT_UNKNOWN) {
            struct stat st;
            if (stat(child, &st) == 0 && S_ISDIR(st.st_mode)) {
                walk_dir_collect(child);
                continue;
            }
        }
        if (ent->d_type == DT_REG || ent->d_type == DT_UNKNOWN) {
            size_t n = strlen(child);
            if (n > 3 && strcmp(child + n - 3, ".sx") == 0)
                file_list_push(child);
        }
    }
    closedir(d);
}

/**
 * 无路径参数时 check 的默认扫描范围（产品树，不含 tests 负例目录）。
 */
static void check_collect_default_product_dirs(void) {
    char cwd[512];
    char sub[560];
    struct stat st;
    static const char *subs[] = {"compiler/src", "core", "std", "examples", NULL};
    int i;
    int any_product = 0;

    if (!getcwd(cwd, sizeof cwd))
        return;
    for (i = 0; subs[i]; i++) {
        snprintf(sub, sizeof sub, "%s/%s", cwd, subs[i]);
        if (stat(sub, &st) == 0 && S_ISDIR(st.st_mode)) {
            walk_dir_collect(sub);
            any_product = 1;
        }
    }
    /* 在 tests/xxx 等子目录无产品树时，仍只检查当前目录（run-check 子目录用例）。 */
    if (!any_product)
        walk_dir_collect(cwd);
}

/**
 * 解析路径参数：文件直接加入；目录递归收集。
 */
static void collect_paths_from_arg(const char *arg) {
    struct stat st;
    if (!arg)
        return;
    if (stat(arg, &st) != 0) {
        fprintf(stderr, "shux: cannot access '%s'\n", arg);
        return;
    }
    if (S_ISDIR(st.st_mode)) {
        char base[512];
        if (arg[0] == '/')
            snprintf(base, sizeof base, "%s", arg);
        else {
            if (!getcwd(base, sizeof base))
                return;
            size_t n = strlen(base);
            snprintf(base + n, sizeof base - n, "/%s", arg);
        }
        walk_dir_collect(base);
        return;
    }
    file_list_push(arg);
}

/**
 * 解析 --ignore=a,b,c 写入 s_ignore_paths。
 */
static void parse_ignore_opt(const char *arg) {
    char buf[512];
    char *p;
    char *tok;
    if (!arg || strncmp(arg, "--ignore=", 9) != 0)
        return;
    snprintf(buf, sizeof buf, "%s", arg + 9);
    p = buf;
    while (p && *p && s_n_ignore < DRIVER_FMT_MAX_IGNORE) {
        tok = p;
        while (*p && *p != ',')
            p++;
        if (*p)
            *p++ = '\0';
        if (tok[0]) {
            snprintf(s_ignore_paths[s_n_ignore], sizeof s_ignore_paths[0], "%s", tok);
            s_n_ignore++;
        }
    }
}

/**
 * 释放文件列表。
 */
static void file_list_clear(void) {
    int i;
    for (i = 0; i < s_n_files; i++)
        free(s_file_list[i]);
    s_n_files = 0;
}

/**
 * 运行 shux fmt（deno fmt 语义）。
 */
int driver_run_fmt(int argc, char **argv) {
    int i;
    int fail_fast = 0;
    int any_path_arg = 0;
    int failed = 0;
    int formatted = 0;
    int check_mode = 0;

    s_n_ignore = 0;
    s_unformatted_count = 0;
    file_list_clear();

    for (i = 1; i < argc; i++) {
        if (!argv[i])
            continue;
        if (strcmp(argv[i], "--check") == 0) {
            driver_fmt_check_only_set(1);
            check_mode = 1;
            continue;
        }
        if (strcmp(argv[i], "--fail-fast") == 0) {
            fail_fast = 1;
            continue;
        }
        if (strncmp(argv[i], "--ignore=", 9) == 0) {
            parse_ignore_opt(argv[i]);
            continue;
        }
        if (argv[i][0] == '-')
            continue;
        any_path_arg = 1;
        collect_paths_from_arg(argv[i]);
    }

    if (!any_path_arg) {
        char cwd[512];
        if (getcwd(cwd, sizeof cwd))
            walk_dir_collect(cwd);
    }

    if (s_n_files == 0) {
        if (any_path_arg)
            fprintf(stderr, "shux fmt: no .sx files found under given path(s)\n");
        else
            fprintf(stderr, "shux fmt: no .sx files found in current directory\n");
        return 1;
    }

    for (i = 0; i < s_n_files; i++) {
        const char *path = s_file_list[i];
        int plen = (int)strlen(path);
        int rc = driver_fmt_one_file((const uint8_t *)path, plen);
        if (rc != 0) {
            if (driver_fmt_check_only_get() && s_unformatted_count < DRIVER_FMT_MAX_FILES) {
                snprintf(s_unformatted_paths[s_unformatted_count], sizeof s_unformatted_paths[0], "%s", path);
                s_unformatted_count++;
            }
            failed = 1;
            if (fail_fast)
                break;
        } else if (!driver_fmt_check_only_get()) {
            formatted++;
        }
    }

    driver_fmt_check_only_set(0);
    file_list_clear();

    if (failed && check_mode) {
        int j;
        fprintf(stderr, "\nFound %d not formatted file%s:\n\n", s_unformatted_count, s_unformatted_count == 1 ? "" : "s");
        for (j = 0; j < s_unformatted_count; j++)
            fprintf(stderr, "  %s\n", s_unformatted_paths[j]);
        fprintf(stderr, "\nRun `shux fmt` to format these files.\n");
        return 1;
    }

    if (failed)
        return 1;

    if (!check_mode && formatted > 0 && getenv("SHUX_FMT_VERBOSE"))
        fprintf(stderr, "Formatted %d file%s\n", formatted, formatted == 1 ? "" : "s");

    return 0;
}

/**
 * 对单个 .sx 运行 check；复用 driver_run_compiler_full。
 */
static int check_one_file(const char *path, int argc, char **argv) {
    char *check_argv[64];
    int n = 0;
    int i;
    int rc;

    lsp_diag_collect_begin();
    driver_check_set_current_file(path);

    /* 每个文件独立构建 check_argv；-L 缓冲须按文件重置，否则跨文件 dedup 会漏注入仓库根。 */
    s_n_check_lib_bufs = 0;

    check_argv[n++] = argv[0];
#ifdef SHUX_USE_SX_PIPELINE
    check_argv[n++] = "check";
#endif
    for (i = 2; i < argc && n < 60; i++) {
        if (!argv[i])
            continue;
        if (argv[i][0] == '-') {
            check_argv[n++] = argv[i];
            if ((strcmp(argv[i], "-L") == 0 || strcmp(argv[i], "-I") == 0 || strcmp(argv[i], "-o") == 0
                 || strcmp(argv[i], "-backend") == 0 || strcmp(argv[i], "-O") == 0)
                && i + 1 < argc)
                check_argv[n++] = argv[++i];
        } else if (strcmp(argv[i], "--fail-fast") == 0) {
            check_argv[n++] = argv[i];
        }
    }
    check_argv_append_default_libs_for_path(path, check_argv, &n);
    check_argv[n++] = (char *)path;

    driver_check_only_set(1);
    rc = fmt_check_invoke_compile(n, check_argv);
    driver_check_only_set(0);

    {
        int nd = lsp_diag_print_stderr_human(path);
        if (rc != 0) {
            if (nd == 0)
                fprintf(stderr, "check failed: %s\n", path);
        } else if (check_lint_fail_on_warnings() && lsp_diag_count_severity(2) > 0) {
            rc = 1;
        }
    }

    lsp_diag_collect_end();
    fmt_check_dep_clear();
    return rc;
}

/**
 * 运行 shux check（deno check 语义：多文件/目录，失败打印诊断）。
 */
int driver_run_compiler_check(int argc, char **argv) {
    int i;
    int fail_fast = 0;
    int any_path = 0;
    int failed = 0;
    int checked = 0;
    int path_start = 1;

    s_check_quiet_ok = 1;
    file_list_clear();

    /* main.sx 传入 argv[1]=check；shux-c 已 drop 子命令时 argv[1] 为首个路径。 */
    if (argc >= 2 && argv[1] && strcmp(argv[1], "check") == 0)
        path_start = 2;

    check_init_user_lib_flags(argc, argv, path_start);

    for (i = path_start; i < argc; i++) {
        if (!argv[i])
            continue;
        if (strcmp(argv[i], "--fail-fast") == 0) {
            fail_fast = 1;
            continue;
        }
        if (strncmp(argv[i], "--ignore=", 9) == 0) {
            parse_ignore_opt(argv[i]);
            continue;
        }
        if (strcmp(argv[i], "-L") == 0 || strcmp(argv[i], "-I") == 0 || strcmp(argv[i], "-o") == 0) {
            i++;
            continue;
        }
        if (strcmp(argv[i], "-backend") == 0 || strcmp(argv[i], "-O") == 0) {
            i++;
            continue;
        }
        if (argv[i][0] == '-')
            continue;
        any_path = 1;
        collect_paths_from_arg(argv[i]);
    }

    /*
     * 无路径：仅 check 产品目录（compiler/src、core、std、examples），避免扫 tests 负例。
     * 有路径时仍由 collect_paths_from_arg 处理（可显式 shux check tests/...）。
     */
    if (!any_path)
        check_collect_default_product_dirs();

    if (s_n_files == 0) {
        if (any_path)
            fprintf(stderr, "shux check: no .sx files found under given path(s)\n");
        else
            fprintf(stderr, "shux check: no .sx files found in current directory\n");
        return 1;
    }

    for (i = 0; i < s_n_files; i++) {
        if (check_one_file(s_file_list[i], argc, argv) != 0) {
            failed = 1;
            if (fail_fast)
                break;
        }
        checked++;
    }

    file_list_clear();

    if (failed)
        return 1;

    if (!s_check_quiet_ok && checked > 0)
        fprintf(stderr, "check OK (%d file%s)\n", checked, checked == 1 ? "" : "s");

    return 0;
}
