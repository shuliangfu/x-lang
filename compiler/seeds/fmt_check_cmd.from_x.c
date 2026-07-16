/* R2 thin + Cap residual pure 深迁（续 lib path slots + try_append pure）：
 * PREFER hybrid thin 由 src/driver/fmt_check_cmd_thin.x（lit/entry + pure 真体）；
 * rest SHUX_L2_FMT_CHECK_THIN_FROM_X：无 thin 公共体；pure-duplicate _impl 剔除
 * （含 set_current_file / print / cwd_fallback / try_walk / path_resolve_abs /
 *  append_repo_lib_roots / missing_diag / invoke/dep_clear /
 *  collect_mode is_check / user_passed_L_get / init_user_lib_flags /
 *  file_list_n / user_ignore_count / lib_bufs_n / user_ignore_at /
 *  parse_ignore_opt / try_append_lib_root / …）；
 * Cap residual：walk opendir/stat/argv/大 BSS（file_list ptrs）/ one_file_body /
 *  store/clear / argv_append / run_fmt / run_check 仍 rest（ALWAYS residual 8）。
 * 冷启动无宏：全 C 体（含 pure _impl + public 门闩）。
 * Regen thin surface: shux -E src/driver/fmt_check_cmd_thin.x → thin_surface.
 */
#include "win32_compat.h"
#include "driver/fmt_check_cmd.h"
#include "diag.h"
#include "lsp/lsp_diag.h"
#include "runtime_driver_abi.h"
#include "runtime_io_abi.h"
#ifdef _WIN32
#include <stdlib.h>
/* MinGW 无 dirent.h 的 d_type/DT_REG——用 _findfirst/_findnext 兼容层 */
#include <io.h>
#include <direct.h>
#define DT_DIR _A_SUBDIR
#define DT_REG _A_NORMAL
#define DT_UNKNOWN 0
struct dirent {
    char d_name[260];
    unsigned char d_type;
};
typedef struct { intptr_t handle; struct _finddata_t fd; int first; struct dirent ent; } DIR;
static DIR *opendir_win(const char *name) {
    char pattern[512];
    DIR *d = (DIR *)calloc(1, sizeof(DIR));
    if (!d) return NULL;
    snprintf(pattern, sizeof(pattern), "%s/*", name);
    d->handle = _findfirst(pattern, &d->fd);
    if (d->handle == -1) { free(d); return NULL; }
    d->first = 1;
    return d;
}
static struct dirent *readdir_win(DIR *d) {
    if (!d || d->handle == -1) return NULL;
    if (d->first) { d->first = 0; }
    else { if (_findnext(d->handle, &d->fd) != 0) return NULL; }
    strncpy(d->ent.d_name, d->fd.name, sizeof(d->ent.d_name) - 1);
    d->ent.d_name[sizeof(d->ent.d_name) - 1] = 0;
    d->ent.d_type = (d->fd.attrib & _A_SUBDIR) ? DT_DIR : DT_REG;
    return &d->ent;
}
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void closedir_win(DIR *d) {
    if (d && d->handle != -1) _findclose(d->handle);
    free(d);
}




#define opendir opendir_win
#define readdir readdir_win
#define closedir closedir_win
#else
#include <dirent.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#ifndef _WIN32
#include <unistd.h>
#endif

#ifdef SHUX_L2_FMT_CHECK_THIN_FROM_X
int32_t driver_check_quiet_ok_get(void);
int fmt_walk_skip_dot_name(const char *name);
int check_one_need_fallback_diag(int rc, int nd, int nd_errors, int nd_warnings, int nd_infos, int direct_diag);
int shux_path_is_absolute(const char *path);
int check_one_finalize_rc(int rc, int warn_count);
const char *driver_collect_error_kind(void);
const char *driver_collect_missing_path_code(void);
int32_t driver_collect_mode_is_check(void);
void driver_collect_mode_set(int32_t v);
int32_t check_user_passed_L_get(void);
void check_user_passed_L_set(int32_t v);
int fmt_user_ignore_count(void);
void fmt_user_ignore_count_set(int32_t v);
int fmt_path_ends_with_dot_x(const char *path);
int fmt_file_list_n(void);
void fmt_file_list_n_set(int32_t v);
int fmt_check_lib_bufs_n(void);
void fmt_check_lib_bufs_n_set(int32_t v);
void fmt_check_lib_bufs_reset(void);
const char *fmt_check_lib_buf_at(int i);
int fmt_check_lib_buf_store(int i, const char *path);
int check_lint_fail_on_warnings(void);
int fmt_check_invoke_compile(int argc, char **check_argv);
void fmt_check_dep_clear(void);
int fmt_path_stat_kind(const char *path);
void check_try_append_lib_root(char **check_argv, int *n, const char *dir);
void check_init_user_lib_flags(int argc, char **argv, int path_start);
void driver_check_set_current_file(const char *path);
int driver_check_print_collected_diagnostics(const char *path);
int check_one_file(const char *path, int argc, char **argv);
int path_should_ignore(const char *path);
int file_list_push(const char *path);
void walk_dir_collect_process_child(const char *child, int is_dir, int is_reg);
void walk_dir_collect(const char *dir);
void parse_ignore_opt(const char *arg);
void file_list_clear(void);
int fmt_try_walk_if_product_subdir(const char *sub);
void check_collect_default_product_dirs(void);
void collect_paths_from_arg(const char *arg);
void check_append_repo_lib_roots(const char *path, char **check_argv, int *n);
void check_argv_append_default_libs_for_path(const char *path, char **check_argv, int *n);
const char *fmt_builtin_ignore_at(int i);
const char *fmt_default_product_sub_at(int i);
const char *driver_fmt_check_lit_check_error(void);
const char *driver_fmt_check_lit_fmt_error(void);
const char *driver_fmt_check_lit_chk002(void);
const char *driver_fmt_check_lit_fmt001(void);
#endif

extern int driver_fmt_one_file(const uint8_t *path, int path_len);
extern int run_compiler_c(int argc, char **argv);
#ifdef SHUX_USE_X_PIPELINE
extern int driver_run_compiler_full(int argc, char **argv);
extern void driver_dep_seeded_clear_all(void);
#endif

/* 【Why 根源】Windows 绝对路径格式 C:/... 或 C:\...（驱动器盘符+冒号）不被 POSIX
 * path[0]=='/' 判断识别，导致 file_list_push/collect_paths_from_arg 把 Windows
 * 绝对路径当相对路径拼接到 getcwd，产生 C:\cwd/C:/abs/path 双重前缀。
 * 【Invariant】path 非空时返回 1 表示绝对路径（POSIX / 或 Windows 盘符）。
 * 【Asm/Perf】纯 ASCII 比较，零运行时开销。 */
/* G-02f-118/351：逻辑源 .x；hybrid 时 pure 由 fmt_check_cmd_thin */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int shux_path_is_absolute(const char *path) {
    if (!path || !path[0])
        return 0;
    if (path[0] == '/')
        return 1;
#ifdef _WIN32
    if (((path[0] >= 'A' && path[0] <= 'Z') || (path[0] >= 'a' && path[0] <= 'z'))
        && path[1] == ':')
        return 1;
#endif
    return 0;
}
#endif





/** 单目录遍历时最多收集的 .x 路径数。 */
#define DRIVER_FMT_MAX_FILES 8192
/** 忽略规则条数（CLI --ignore + 内置）。 */
#define DRIVER_FMT_MAX_IGNORE 32

/* 冷启动 set_current_file / print 用；hybrid 时 thin.x g_check_current_file 权威 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
static char s_check_current_file[512];
#endif

/* 冷启动 pure _impl / public 用；hybrid 时 thin.x 字节表权威 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
static const char *s_builtin_ignore[] = {
    "/.git/", "/build_asm/", "/build/", "/node_modules/", "/.cursor/", "/compiler/build_asm/",
    "/compiler/build/", "/compiler/tests/", NULL};
#endif

/** check 全部成功时不打印 check OK（deno check 静默成功）。 */
static int s_check_quiet_ok = 1;

/**
 * 供 runtime.c 查询：check 子命令是否抑制逐文件 check OK 行。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int32_t driver_check_quiet_ok_get(void) {
  return 1;
}
#endif


static char s_unformatted_paths[DRIVER_FMT_MAX_FILES][512];
static int s_unformatted_count;

/* Cap residual pure：hybrid thin owns s_n_ignore + s_ignore_paths slots
 * (g_fmt_user_ignore_paths 32×256 flat); cold keeps statics. */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
static char s_ignore_paths[DRIVER_FMT_MAX_IGNORE][256];
static int s_n_ignore;
#endif

/* Cap residual：thin pure 可写路径 BSS（0=current_file，1=resolve_abs）。
 * -E 顶层 u8[N] 退化为悬空指针；codegen.x 已根修，codegen_gen 再生后可收回。 */
static char s_fmt_check_path_bss[2][512];

char *fmt_check_path_bss_slot(int which) {
    if (which < 0 || which > 1)
        return s_fmt_check_path_bss[0];
    return s_fmt_check_path_bss[which];
}

static char *s_file_list[DRIVER_FMT_MAX_FILES];
/* Cap residual pure：hybrid thin owns s_n_files; cold keeps static. Cap residual: s_file_list[]. */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
static int s_n_files;
#endif

/** check 默认 -L：cwd；用户未传 -L 时按路径追加（见 check_argv_append_default_libs_for_path）。 */
/* Cap residual pure：hybrid thin owns s_n_check_lib_bufs + s_check_lib_bufs slots
 * (g_fmt_check_lib_bufs 8×512 flat); cold keeps statics. */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
static char s_check_lib_bufs[8][512];
static int s_n_check_lib_bufs;
#endif

/* Cap residual pure：hybrid thin owns s_user_passed_L / s_collect_mode; cold keeps statics. */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
static int s_user_passed_L;

typedef enum DriverCollectMode {
    DRIVER_COLLECT_MODE_FMT = 1,
    DRIVER_COLLECT_MODE_CHECK = 2,
} DriverCollectMode;

static DriverCollectMode s_collect_mode = DRIVER_COLLECT_MODE_FMT;
#else
/* Hybrid: thin owns mode/user_passed_L; rest still needs enum constants for mode_set. */
enum {
    DRIVER_COLLECT_MODE_FMT = 1,
    DRIVER_COLLECT_MODE_CHECK = 2
};
#endif

/* pure 权威：thin.x fmt_check_lib_bufs_n / n_set / reset / buf_at / buf_store；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup（H↓）。
 * Cap residual pure：hybrid thin owns path slots；cold keeps s_check_lib_bufs[].
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int fmt_check_lib_bufs_n_impl(void) {
    return s_n_check_lib_bufs;
}

int fmt_check_lib_bufs_n(void) {
    return fmt_check_lib_bufs_n_impl();
}

void fmt_check_lib_bufs_n_set(int32_t v) {
    s_n_check_lib_bufs = v < 0 ? 0 : (int)v;
}

void fmt_check_lib_bufs_reset(void) {
    fmt_check_lib_bufs_n_set(0);
}

const char *fmt_check_lib_buf_at(int i) {
    if (i < 0 || i >= 8)
        return NULL;
    return s_check_lib_bufs[i];
}

int fmt_check_lib_buf_store(int i, const char *path) {
    if (i < 0 || i >= 8 || !path)
        return 0;
    snprintf(s_check_lib_bufs[i], sizeof s_check_lib_bufs[0], "%s", path);
    return 1;
}
#endif

/* pure 权威：thin.x driver_collect_mode_is_check / driver_collect_mode_set；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）。 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int32_t driver_collect_mode_is_check_impl(void) {
    return s_collect_mode == DRIVER_COLLECT_MODE_CHECK ? 1 : 0;
}

int32_t driver_collect_mode_is_check(void) {
    return driver_collect_mode_is_check_impl();
}

void driver_collect_mode_set(int32_t v) {
    s_collect_mode = (DriverCollectMode)v;
}
#endif

#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
const char *driver_fmt_check_lit_check_error(void) { return "check error"; }
const char *driver_fmt_check_lit_fmt_error(void) { return "fmt error"; }
const char *driver_fmt_check_lit_chk002(void) { return "CHK002"; }
const char *driver_fmt_check_lit_fmt001(void) { return "FMT001"; }
#endif

/* G-02f-247/351：逻辑源 .x（mode→lit）；hybrid 时由 thin 门闩 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
const char *driver_collect_error_kind(void) {
    if (driver_collect_mode_is_check())
        return driver_fmt_check_lit_check_error();
    return driver_fmt_check_lit_fmt_error();
}

const char *driver_collect_missing_path_code(void) {
    if (driver_collect_mode_is_check())
        return driver_fmt_check_lit_chk002();
    return driver_fmt_check_lit_fmt001();
}
#endif

/* G-02f-247：ignore 槽访问（.x path_should_ignore pure） */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
const char *fmt_builtin_ignore_at(int i) {
    int n = 0;
    while (s_builtin_ignore[n])
        n++;
    if (i < 0 || i >= n)
        return NULL;
    return s_builtin_ignore[i];
}
#endif

/* pure 权威：thin.x fmt_user_ignore_count / count_set / at / parse_ignore_opt；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）。
 * Hybrid thin owns ignore path slots (32×256); cold keeps s_ignore_paths[][].
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int fmt_user_ignore_count_impl(void) {
    return s_n_ignore;
}

int fmt_user_ignore_count(void) {
    return fmt_user_ignore_count_impl();
}

void fmt_user_ignore_count_set(int32_t v) {
    s_n_ignore = v < 0 ? 0 : (int)v;
}

const char *fmt_user_ignore_at_impl(int i) {
    if (i < 0 || i >= fmt_user_ignore_count())
        return NULL;
    return s_ignore_paths[i];
}

const char *fmt_user_ignore_at(int i) {
    return fmt_user_ignore_at_impl(i);
}
#endif




/* pure 权威：thin.x check_user_passed_L_get / check_user_passed_L_set；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）。 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int32_t check_user_passed_L_get_impl(void) {
    return s_user_passed_L ? 1 : 0;
}

int32_t check_user_passed_L_get(void) {
    return check_user_passed_L_get_impl();
}

void check_user_passed_L_set(int32_t v) {
    s_user_passed_L = v ? 1 : 0;
}
#endif

/**
 * 若 dir 下同时存在 core/ 与 std/ 子目录，则作为仓库 lib 根注入 -L（去重）。
 * pure 权威：thin.x check_try_append_lib_root（path_stat public + pure lib path slots +
 *   shux_ptr_slot_set）；冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void check_try_append_lib_root_impl(char **check_argv, int *n, const char *dir) {
    char core_path[560];
    char std_path[560];
    struct stat st;
    int i;
    int nb;

    if (!check_argv || !n || !dir || !dir[0])
        return;
    /* public get：hybrid thin pure BSS / 冷 seed static */
    if (check_user_passed_L_get() || *n >= 58)
        return;
    snprintf(core_path, sizeof core_path, "%s/core", dir);
    snprintf(std_path, sizeof std_path, "%s/std", dir);
    if (stat(core_path, &st) != 0 || !S_ISDIR(st.st_mode))
        return;
    if (stat(std_path, &st) != 0 || !S_ISDIR(st.st_mode))
        return;
    /* public n + at/store：冷 seed path slots */
    nb = fmt_check_lib_bufs_n();
    for (i = 0; i < nb; i++) {
        const char *slot = fmt_check_lib_buf_at(i);
        if (slot && strcmp(slot, dir) == 0)
            return;
    }
    if (nb >= 8)
        return;
    if (!fmt_check_lib_buf_store(nb, dir))
        return;
    check_argv[(*n)++] = "-L";
    check_argv[(*n)++] = (char *)fmt_check_lib_buf_at(nb);
    fmt_check_lib_bufs_n_set(nb + 1);
}

void check_try_append_lib_root(char **check_argv, int *n, const char *dir) {
    if (!check_argv || !n || !dir)
        return;
    if (!dir[0])
        return;
    if (check_user_passed_L_get())
        return;
    if (*n >= 58)
        return;
    check_try_append_lib_root_impl(check_argv, n, dir);
}
#endif




/**
 * 从 path 所在目录向上查找含 core/ + std/ 的仓库根并注入 -L。
 * pure 权威：thin.x check_append_repo_lib_roots（getcwd+字节拼+dirname 上溯+try_append）；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void check_append_repo_lib_roots_impl(const char *path, char **check_argv, int *n) {
    char start[512];
    char cur[512];
    char parent[512];
    int depth;

    if (check_user_passed_L_get() || *n >= 58)
        return;
    if (!path || !path[0]) {
        if (getcwd(start, sizeof start))
            /* public：hybrid thin pure 早退 / 冷 seed public→_impl */
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
        /* public：hybrid thin pure 早退 / 冷 seed public→_impl */
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

void check_append_repo_lib_roots(const char *path, char **check_argv, int *n) {
  check_append_repo_lib_roots_impl(path, check_argv, n);
}
#endif




/**
 * 扫描 argv：用户是否已传 -L（有则不再注入默认库根）。
 * pure 权威：thin.x check_init_user_lib_flags（shux_ptr_slot_get + user_passed_L BSS +
 *   fmt_check_lib_bufs_reset pure）；冷启动保留 _impl + public；FROM_X 剔除 pure-dup。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void check_init_user_lib_flags_impl(int argc, char **argv, int path_start) {
    int i;
    check_user_passed_L_set(0);
    fmt_check_lib_bufs_reset();
    for (i = path_start; i < argc; i++) {
        if (argv[i] && strcmp(argv[i], "-L") == 0) {
            check_user_passed_L_set(1);
            return;
        }
    }
}

void check_init_user_lib_flags(int argc, char **argv, int path_start) {
  check_init_user_lib_flags_impl(argc, argv, path_start);
}
#endif




/**
 * 按待检查文件路径注入默认 -L（在单文件路径之前）。
 * 始终注入仓库根；compiler/src 下文件再追加 compiler/src 库根（裸 import lexer/token）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-408：实现体始终 seed；public PREFER 时 thin forward */
void check_argv_append_default_libs_for_path_impl(const char *path, char **check_argv, int *n) {
    char cwd_buf[512];
    char cs[560];
    struct stat st;
    int nb;

    if (check_user_passed_L_get() || *n >= 58)
        return;
    check_append_repo_lib_roots(path, check_argv, n);
    if (!getcwd(cwd_buf, sizeof cwd_buf))
        return;
    /* public：hybrid thin pure try_append / 冷 seed public→_impl */
    check_try_append_lib_root(check_argv, n, cwd_buf);
    if (path && strstr(path, "compiler/src/") && *n < 56) {
        snprintf(cs, sizeof cs, "%s/compiler/src", cwd_buf);
        if (stat(cs, &st) == 0 && S_ISDIR(st.st_mode)) {
            /* public n + pure/hybrid path slots via at/store */
            nb = fmt_check_lib_bufs_n();
            if (nb < 8 && fmt_check_lib_buf_store(nb, cs)) {
                check_argv[(*n)++] = "-L";
                check_argv[(*n)++] = (char *)fmt_check_lib_buf_at(nb);
                fmt_check_lib_bufs_n_set(nb + 1);
            }
        }
        if (strstr(path, "compiler/src/asm/") && *n < 56) {
            snprintf(cs, sizeof cs, "%s/compiler/src/asm", cwd_buf);
            if (stat(cs, &st) == 0 && S_ISDIR(st.st_mode)) {
                nb = fmt_check_lib_bufs_n();
                if (nb < 8 && fmt_check_lib_buf_store(nb, cs)) {
                    check_argv[(*n)++] = "-L";
                    check_argv[(*n)++] = (char *)fmt_check_lib_buf_at(nb);
                    fmt_check_lib_bufs_n_set(nb + 1);
                }
            }
        }
    }
}

#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void check_argv_append_default_libs_for_path(const char *path, char **check_argv, int *n) {
  check_argv_append_default_libs_for_path_impl(path, check_argv, n);
}
#endif




/**
 * SHUX_LINT_CI_FAIL_ON=warn 时 warning 层诊断亦令 check 非零退出。
 */
/* pure 权威：thin.x check_lint_fail_on_warnings；冷启动保留 _impl + public */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int check_lint_fail_on_warnings_impl(void) {
  const char *v = getenv("SHUX_LINT_CI_FAIL_ON");
  return v && (strcmp(v, "warn") == 0 || strcmp(v, "warning") == 0);
}

int check_lint_fail_on_warnings(void) {
  return check_lint_fail_on_warnings_impl();
}
#endif



/**
 * 单文件 check：X pipeline 走 driver_run_compiler_full，shux-c 走 run_compiler_c。
 * pure 分派权威：thin.x fmt_check_invoke_compile → driver_run_compiler_full；
 * 冷启动保留 _impl + public（#ifdef 双路径）；FROM_X 下剔除 pure-dup _impl（H↓）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int fmt_check_invoke_compile_impl(int argc, char **check_argv) {
#ifdef SHUX_USE_X_PIPELINE
    return driver_run_compiler_full(argc, check_argv);
#else
    return run_compiler_c(argc, check_argv);
#endif
}

int fmt_check_invoke_compile(int argc, char **check_argv) {
  return fmt_check_invoke_compile_impl(argc, check_argv);
}
#endif




/**
 * check 批次结束后清理 dep 槽（仅 X pipeline 需要）。
 * pure 分派权威：thin.x fmt_check_dep_clear → driver_dep_seeded_clear_all；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void fmt_check_dep_clear_impl(void) {
#ifdef SHUX_USE_X_PIPELINE
    driver_dep_seeded_clear_all();
#endif
}

void fmt_check_dep_clear(void) {
  fmt_check_dep_clear_impl();
}
#endif




/**
 * 记录当前 check 的源文件路径，供诊断前缀使用。
 * pure 权威：thin.x driver_check_set_current_file（512B BSS 字节拷贝）；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void driver_check_set_current_file_impl(const char *path) {
    if (!path) {
        s_check_current_file[0] = '\0';
        return;
    }
    snprintf(s_check_current_file, sizeof s_check_current_file, "%s", path);
}

void driver_check_set_current_file(const char *path) {
  driver_check_set_current_file_impl(path);
}
#endif

/**
 * 将 lsp_diag 收集器中的条目打印为 deno 风格行；返回条数。
 * pure 权威：thin.x driver_check_print_collected_diagnostics → lsp_diag_print_stderr_human；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int driver_check_print_collected_diagnostics_impl(const char *path) {
    extern int lsp_diag_enabled;
    (void)lsp_diag_enabled;
    return lsp_diag_print_stderr_human(path ? path : s_check_current_file);
}

int driver_check_print_collected_diagnostics(const char *path) {
  return driver_check_print_collected_diagnostics_impl(path);
}
#endif

/**
 * 路径是否应忽略（内置 + --ignore 子串匹配）。
 * pure 权威：thin.x path_should_ignore；冷启动保留 _impl + public 门闩。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int path_should_ignore_impl(const char *path) {
    int i;
    int n;
    if (!path)
        return 1;
    for (i = 0;; i++) {
        const char *b = fmt_builtin_ignore_at(i);
        if (!b)
            break;
        if (strstr(path, b))
            return 1;
    }
    n = fmt_user_ignore_count();
    for (i = 0; i < n; i++) {
        const char *u = fmt_user_ignore_at_impl(i);
        if (u && u[0] && strstr(path, u))
            return 1;
    }
    return 0;
}

int path_should_ignore(const char *path) {
  return path_should_ignore_impl(path);
}
#endif




/* pure 权威：thin.x fmt_path_ends_with_dot_x；冷启动保留 _impl + public */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int fmt_path_ends_with_dot_x_impl(const char *path) {
    size_t len;
    if (!path)
        return 0;
    len = strlen(path);
    if (len < 2)
        return 0;
    return path[len - 2] == '.' && path[len - 1] == 'x';
}

int fmt_path_ends_with_dot_x(const char *path) {
    return fmt_path_ends_with_dot_x_impl(path);
}
#endif

/* pure 权威：thin.x fmt_file_list_n / fmt_file_list_n_set；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）。
 * Cap residual：s_file_list[] + store strdup / clear free 始终 seed。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int fmt_file_list_n_impl(void) {
    return s_n_files;
}

int fmt_file_list_n(void) {
    return fmt_file_list_n_impl();
}

void fmt_file_list_n_set(int32_t v) {
    s_n_files = v < 0 ? 0 : (int)v;
}
#endif

/* pure 权威：thin.x fmt_path_resolve_abs（getcwd+字节拼/拷贝；512B BSS）；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）；
 * 返回静态缓冲指针（勿 free；与 thin g_resolve_abs_buf 同语义）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
const char *fmt_path_resolve_abs_impl(const char *path) {
    static char ab[512];
    if (!path)
        return NULL;
    if (!shux_path_is_absolute(path)) {
        if (!getcwd(ab, sizeof ab))
            return NULL;
        size_t n = strlen(ab);
        if (n + 1 + strlen(path) >= sizeof ab)
            return NULL;
        ab[n] = '/';
        strcpy(ab + n + 1, path);
    } else {
        snprintf(ab, sizeof ab, "%s", path);
    }
    return ab;
}

const char *fmt_path_resolve_abs(const char *path) {
    return fmt_path_resolve_abs_impl(path);
}
#endif

/* Cap residual：strdup 入 s_file_list[]；n 走 public get/set（hybrid thin / 冷 seed）。 */
int fmt_file_list_store_impl(const char *abs_path) {
    int n = fmt_file_list_n();
    if (!abs_path || n >= DRIVER_FMT_MAX_FILES)
        return -1;
    s_file_list[n] = strdup(abs_path);
    if (!s_file_list[n])
        return -1;
    fmt_file_list_n_set(n + 1);
    return 0;
}

/**
 * 将相对/绝对路径加入待处理列表（去重由调用方保证顺序）。
 * pure 编排权威：thin.x file_list_push；冷启动保留 _impl + public。
 * Cap residual store：fmt_file_list_store_impl（strdup）始终 seed。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int file_list_push_impl(const char *path) {
    const char *abs_path;
    if (!path)
        return -1;
    if (fmt_file_list_n() >= DRIVER_FMT_MAX_FILES)
        return -1;
    abs_path = fmt_path_resolve_abs_impl(path);
    if (!abs_path)
        return -1;
    if (path_should_ignore_impl(abs_path))
        return 0;
    if (!fmt_path_ends_with_dot_x(abs_path))
        return 0;
    return fmt_file_list_store_impl(abs_path);
}

int file_list_push(const char *path) {
  return file_list_push_impl(path);
}
#endif




/* G-02f-249：逻辑源 .x（真迁 skip '.' 名）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int fmt_walk_skip_dot_name(const char *name) {
    if (!name || !name[0])
        return 1;
    if (name[0] == '.')
        return 1;
    return 0;
}
#endif


void walk_dir_collect(const char *dir);
void walk_dir_collect_impl(const char *dir);

/* pure 权威：thin.x walk_dir_collect_process_child；冷启动保留 _impl + public */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void walk_dir_collect_process_child_impl(const char *child, int is_dir, int is_reg) {
    if (!child)
        return;
    if (path_should_ignore_impl(child))
        return;
    if (is_dir) {
        walk_dir_collect_impl(child);
        return;
    }
    if (is_reg && fmt_path_ends_with_dot_x_impl(child))
        file_list_push_impl(child);
}

void walk_dir_collect_process_child(const char *child, int is_dir, int is_reg) {
  walk_dir_collect_process_child_impl(child, is_dir, is_reg);
}
#endif

/**
 * 递归遍历目录，收集 .x 文件。
 * Cap residual：opendir 循环 🔒；过滤/递归编排调 public walk_dir_collect_process_child
 * （hybrid 时 thin pure；冷启动时 seed public→_impl）。
 *
 * 【Why 根源】dir 可能指向 fmt_path_resolve_abs 的静态/小 BSS 缓冲
 * （collect_paths_from_arg → resolve_abs → walk_dir_collect 传入；hybrid thin
 * g_resolve_abs_buf / 冷 seed static ab[512]）。
 * 循环中 file_list_push → resolve_abs 会覆盖该缓冲，
 * 导致 dir 指针内容变为上一个 .x 文件路径，snprintf 拼接出
 * "compiler/foo.x/bar.x" 这样的错误路径。拷贝到本地 dir_buf 隔离别名。
 * 【Invariant】dir_buf 在本函数栈帧内，不受下游调用影响。
 * 【Asm/Perf】单次 snprintf 拷贝，零热路径影响（目录遍历非热路径）。
 */
void walk_dir_collect_impl(const char *dir) {
    DIR *d;
    struct dirent *ent;
    char child[768];
    char dir_buf[512];
    if (!dir)
        return;
    snprintf(dir_buf, sizeof dir_buf, "%s", dir);
    d = opendir(dir_buf);
    if (!d)
        return;
    while ((ent = readdir(d)) != NULL) {
        int is_dir = 0;
        int is_reg = 0;
        if (fmt_walk_skip_dot_name(ent->d_name))
            continue;
        snprintf(child, sizeof child, "%s/%s", dir_buf, ent->d_name);
        if (ent->d_type == DT_DIR || ent->d_type == DT_UNKNOWN) {
            struct stat st;
            if (stat(child, &st) == 0 && S_ISDIR(st.st_mode))
                is_dir = 1;
        }
        if (!is_dir && (ent->d_type == DT_REG || ent->d_type == DT_UNKNOWN)) {
            struct stat st;
            if (ent->d_type == DT_REG)
                is_reg = 1;
            else if (stat(child, &st) == 0 && S_ISREG(st.st_mode))
                is_reg = 1;
        }
        /* 调 public：hybrid thin pure / 冷 seed public */
        walk_dir_collect_process_child(child, is_dir, is_reg);
    }
    closedir(d);
}

/* G-02f-249：逻辑源 .x（门闩）；seed 保留同语义 C 供产品 cc */
/* G-02f-407：public PREFER 时 thin → existing impl */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void walk_dir_collect(const char *dir) {
    if (!dir)
        return;
    walk_dir_collect_impl(dir);
}
#endif




/* G-02f-250：逻辑源 .x（真迁 sub 表）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
const char *fmt_default_product_sub_at(int i) {
    static const char *subs[] = {"compiler/src", "core", "std", "examples", NULL};
    int n = 0;
    while (subs[n])
        n++;
    if (i < 0 || i >= n)
        return NULL;
    return subs[i];
}
#endif

/* pure 权威：thin.x fmt_try_walk_if_product_subdir（getcwd+字节拼+stat_kind+walk）；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup _impl（H↓）；
 * cold public 与 hybrid pure 同形语义（getcwd/stat/walk）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int fmt_try_walk_if_product_subdir_impl(const char *sub) {
    char cwd[512];
    char subp[560];
    struct stat st;
    if (!sub)
        return 0;
    if (!getcwd(cwd, sizeof cwd))
        return 0;
    snprintf(subp, sizeof subp, "%s/%s", cwd, sub);
    if (stat(subp, &st) == 0 && S_ISDIR(st.st_mode)) {
        walk_dir_collect(subp);
        return 1;
    }
    return 0;
}

int fmt_try_walk_if_product_subdir(const char *sub) {
  return fmt_try_walk_if_product_subdir_impl(sub);
}
#endif

/**
 * pure 权威：thin.x fmt_walk_cwd_fallback（getcwd + walk_dir_collect public）；
 * 冷启动保留 _impl；FROM_X 下剔除 pure-dup _impl（H↓）；
 * cold orch 与 hybrid pure orch 同形：调 public 语义（cold 时 _impl 即 public 体）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void fmt_walk_cwd_fallback_impl(void) {
    char cwd[512];
    if (!getcwd(cwd, sizeof cwd))
        return;
    walk_dir_collect(cwd);
}

void fmt_walk_cwd_fallback(void) {
    fmt_walk_cwd_fallback_impl();
}
#endif

/**
 * 无路径参数时 check 的默认扫描范围（产品树，不含 tests 负例目录）。
 * pure 编排权威：thin.x check_collect_default_product_dirs；
 * 冷启动保留 _impl + public；try_walk getcwd/stat 🔒 Cap residual；
 * cwd fallback 调 public fmt_walk_cwd_fallback（hybrid thin pure / 冷 seed）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void check_collect_default_product_dirs_impl(void) {
    int any_product = 0;
    int i;
    for (i = 0;; i++) {
        const char *sub = fmt_default_product_sub_at(i);
        if (!sub)
            break;
        /* 调 public：与 thin pure 同形 */
        if (fmt_try_walk_if_product_subdir(sub))
            any_product = 1;
    }
    if (!any_product)
        fmt_walk_cwd_fallback();
}

void check_collect_default_product_dirs(void) {
  check_collect_default_product_dirs_impl();
}
#endif




/* G-02f-249：-1 不可访问；1 目录；0 文件/其它 */
/* G-02f-405：实现体始终 seed；public PREFER 时 thin forward */
int fmt_path_stat_kind_impl(const char *path) {
    struct stat st;
    if (!path)
        return -1;
    if (stat(path, &st) != 0)
        return -1;
    if (S_ISDIR(st.st_mode))
        return 1;
    return 0;
}

#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int fmt_path_stat_kind(const char *path) {
  return fmt_path_stat_kind_impl(path);
}
#endif

/* pure 权威：thin.x collect_paths_missing_diag_pure（字节拼 msg + diag_report_with_code）；
 * 冷启动保留 _impl（reportf）；FROM_X 下剔除 pure-dup _impl（H↓）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void collect_paths_missing_diag_impl(const char *path) {
    diag_reportf_with_code(path, 0, 0, driver_collect_error_kind(),
                           driver_collect_missing_path_code(), NULL,
                           "cannot access path '%s'", path);
}
#endif

/**
 * 解析路径参数：文件直接加入；目录递归收集。
 * pure 编排权威：thin.x collect_paths_from_arg；
 * 冷启动保留 _impl + public；stat/resolve/missing-diag 🔒 Cap residual。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void collect_paths_from_arg_impl(const char *arg) {
    int k;
    if (!arg)
        return;
    /* 调 public Cap 门闩：与 thin pure 同形 */
    k = fmt_path_stat_kind(arg);
    if (k < 0) {
        collect_paths_missing_diag_impl(arg);
        return;
    }
    if (k == 1) {
        const char *base = fmt_path_resolve_abs(arg);
        if (base)
            walk_dir_collect(base);
        return;
    }
    file_list_push(arg);
}

void collect_paths_from_arg(const char *arg) {
  collect_paths_from_arg_impl(arg);
}
#endif




/**
 * 解析 --ignore=a,b,c 写入 ignore path slots。
 * pure 权威：thin.x parse_ignore_opt（前缀 + token 写槽）；
 * 冷启动保留 _impl + public；FROM_X 下剔除 pure-dup（H↓）。
 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void parse_ignore_opt_impl(const char *arg) {
    char buf[512];
    char *p;
    char *tok;
    int n;
    if (!arg || strncmp(arg, "--ignore=", 9) != 0)
        return;
    snprintf(buf, sizeof buf, "%s", arg + 9);
    p = buf;
    n = fmt_user_ignore_count();
    while (p && *p && n < DRIVER_FMT_MAX_IGNORE) {
        tok = p;
        while (*p && *p != ',')
            p++;
        if (*p)
            *p++ = '\0';
        if (tok[0]) {
            snprintf(s_ignore_paths[n], sizeof s_ignore_paths[0], "%s", tok);
            n++;
            fmt_user_ignore_count_set(n);
        }
    }
}

void parse_ignore_opt(const char *arg) {
    if (!arg)
        return;
    if (strncmp(arg, "--ignore=", 9) != 0)
        return;
    parse_ignore_opt_impl(arg);
}
#endif




/**
 * 释放文件列表。
 * Cap residual：free s_file_list[] 槽；n 走 public get/set（hybrid thin / 冷 seed）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-407：实现体始终 seed；public PREFER 时 thin forward */
void file_list_clear_impl(void) {
    int i;
    int n = fmt_file_list_n();
    for (i = 0; i < n; i++)
        free(s_file_list[i]);
    fmt_file_list_n_set(0);
}

#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
void file_list_clear(void) {
  file_list_clear_impl();
}
#endif




/**
 * 运行 shux fmt（deno fmt 语义）。
 * G-02f-410：实现体始终 seed；public PREFER 时 thin pure forward。
 */
int driver_run_fmt_impl(int argc, char **argv) {
    int i;
    int fail_fast = 0;
    int any_path_arg = 0;
    int failed = 0;
    int formatted = 0;
    int check_mode = 0;

    /* public n：hybrid thin pure BSS / 冷 seed static */
    fmt_user_ignore_count_set(0);
    s_unformatted_count = 0;
    /* public set：hybrid thin pure BSS / 冷 seed static */
    driver_collect_mode_set(DRIVER_COLLECT_MODE_FMT);
    file_list_clear_impl();

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
            /* public：hybrid thin pure 前缀 / 冷 seed public→_impl */
            parse_ignore_opt(argv[i]);
            continue;
        }
        if (argv[i][0] == '-')
            continue;
        any_path_arg = 1;
        /* public：hybrid thin pure / 冷 seed public→_impl */
        collect_paths_from_arg(argv[i]);
    }

    if (!any_path_arg) {
        char cwd[512];
        if (getcwd(cwd, sizeof cwd))
            walk_dir_collect(cwd);
    }

    /* public n：hybrid thin pure BSS / 冷 seed static */
    if (fmt_file_list_n() == 0) {
        if (any_path_arg)
            diag_report_with_code(NULL, 0, 0, "fmt error", "FMT001",
                                  "no .x files found under given path(s)", NULL);
        else
            diag_report_with_code(NULL, 0, 0, "fmt error", "FMT001",
                                  "no .x files found in current directory", NULL);
        return 1;
    }

    for (i = 0; i < fmt_file_list_n(); i++) {
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
    file_list_clear_impl();

    if (failed && check_mode) {
        int j;
        diag_reportf_with_code(NULL, 0, 0, "fmt error", "FMT001", NULL,
                               "found %d not formatted file%s",
                               s_unformatted_count, s_unformatted_count == 1 ? "" : "s");
        for (j = 0; j < s_unformatted_count; j++)
            diag_reportf(s_unformatted_paths[j], 0, 0, "note", NULL,
                         "needs formatting: %s", s_unformatted_paths[j]);
        diag_report(NULL, 0, 0, "note",
                    "run `shux fmt` to format these files", NULL);
        return 1;
    }

    if (failed)
        return 1;

    if (!check_mode && formatted > 0 && getenv("SHUX_FMT_VERBOSE"))
        diag_reportf(NULL, 0, 0, "info", NULL,
                     "Formatted %d file%s", formatted, formatted == 1 ? "" : "s");

    return 0;
}
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int driver_run_fmt(int argc, char **argv) {
    return driver_run_fmt_impl(argc, argv);
}
#endif

/* G-02f-250：逻辑源 .x（真迁 fallback/lint 判定）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int check_one_need_fallback_diag(int rc, int nd, int nd_errors, int nd_warnings, int nd_infos,
                                int direct_diag) {
    if (rc == 0)
        return 0;
    if (direct_diag != 0)
        return 0;
    if (nd == 0)
        return 1;
    if (nd_errors == 0 && nd_warnings == 0 && nd_infos == 0)
        return 1;
    return 0;
}
#endif


/* pure 权威：thin.x check_one_finalize_rc；冷启动保留 public 体 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int check_one_finalize_rc(int rc, int warn_count) {
    if (rc != 0)
        return rc;
    if (check_lint_fail_on_warnings_impl() && warn_count > 0)
        return 1;
    return rc;
}
#endif


/**
 * 对单个 .x 运行 check；复用 driver_run_compiler_full。
 * G-02f-250：主体 🔒；结果判定 pure。
 */
int check_one_file_body_impl(const char *path, int argc, char **argv) {
    char *check_argv[64];
    ShuxRuntimeFileView diag_view = {0};
    int have_diag_view = 0;
    int n = 0;
    int i;
    int rc;

    if (runtime_read_file_view(path, &diag_view) == 0) {
        diag_set_file(path, (const char *)diag_view.data, diag_view.length);
        have_diag_view = 1;
    } else {
        diag_set_file(path, NULL, 0);
    }
    lsp_diag_collect_begin();
    driver_check_diag_emitted_reset();
    /* public：hybrid thin pure BSS / 冷 seed public→_impl */
    driver_check_set_current_file(path);

    /* 每个文件独立构建 check_argv；-L 缓冲须按文件重置，否则跨文件 dedup 会漏注入仓库根。
     * public reset：hybrid thin pure BSS / 冷 seed static。 */
    fmt_check_lib_bufs_reset();

    check_argv[n++] = argv[0];
#ifdef SHUX_USE_X_PIPELINE
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
    /* public：hybrid thin pure 分派 / 冷 seed public→_impl */
    rc = fmt_check_invoke_compile(n, check_argv);
    driver_check_only_set(0);

    {
        DiagContextSnapshot diag_snapshot;
        int nd;
        int nd_errors;
        int nd_warnings;
        int nd_infos;
        int direct_diag_emitted;
        if (have_diag_view)
            diag_push_file(&diag_snapshot, path, (const char *)diag_view.data, diag_view.length);
        else
            diag_push_file(&diag_snapshot, path, NULL, 0);
        nd = lsp_diag_print_stderr_human(path);
        nd_errors = lsp_diag_count_severity(1);
        nd_warnings = lsp_diag_count_severity(2);
        nd_infos = lsp_diag_count_severity(3);
        direct_diag_emitted = driver_check_diag_emitted_get();
        diag_restore(&diag_snapshot);
        if (check_one_need_fallback_diag(rc, nd, nd_errors, nd_warnings, nd_infos, direct_diag_emitted))
            diag_reportf_with_code(path, 0, 0, "check error", "CHK001", NULL,
                                   "check failed: %s", path);
        /* 【Why 根源】recovery/typeck 错误经 lsp_diag 打印时 compile rc 可能仍为 0（假绿）。 */
        if (nd_errors > 0)
            rc = 1;
        rc = check_one_finalize_rc(rc, nd_warnings);
    }

    lsp_diag_collect_end();
    if (have_diag_view)
        runtime_release_file_view(&diag_view);
    /* public：hybrid thin pure 分派 / 冷 seed public→_impl */
    fmt_check_dep_clear();
    return rc;
}

/* pure 门闩权威：thin.x check_one_file → body_impl；
 * 冷启动保留 pure-dup check_one_file_impl；FROM_X 下剔除（H↓）。 */
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int check_one_file_impl(const char *path, int argc, char **argv) {
    if (!path || !argv || argc <= 0)
        return -1;
    return check_one_file_body_impl(path, argc, argv);
}

int check_one_file(const char *path, int argc, char **argv) {
  return check_one_file_impl(path, argc, argv);
}
#endif




/**
 * 运行 shux check（deno check 语义：多文件/目录，失败打印诊断）。
 * G-02f-410：实现体始终 seed；public PREFER 时 thin pure forward。
 */
int driver_run_compiler_check_impl(int argc, char **argv) {
    int i;
    int fail_fast = 0;
    int any_path = 0;
    int failed = 0;
    int checked = 0;
    int path_start = 1;

    s_check_quiet_ok = 1;
    /* public set：hybrid thin pure BSS / 冷 seed static */
    driver_collect_mode_set(DRIVER_COLLECT_MODE_CHECK);
    file_list_clear_impl();

    /* main.x 传入 argv[1]=check；shux-c 已 drop 子命令时 argv[1] 为首个路径。 */
    if (argc >= 2 && argv[1] && strcmp(argv[1], "check") == 0)
        path_start = 2;

    /* public：hybrid thin pure init / 冷 seed public→_impl */
    check_init_user_lib_flags(argc, argv, path_start);

    for (i = path_start; i < argc; i++) {
        if (!argv[i])
            continue;
        if (strcmp(argv[i], "--fail-fast") == 0) {
            fail_fast = 1;
            continue;
        }
        if (strncmp(argv[i], "--ignore=", 9) == 0) {
            /* public：hybrid thin pure 前缀 / 冷 seed public→_impl */
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
        /* public：hybrid thin pure / 冷 seed public→_impl */
        collect_paths_from_arg(argv[i]);
    }

    /*
     * 无路径：仅 check 产品目录（compiler/src、core、std、examples），避免扫 tests 负例。
     * 有路径时仍由 collect_paths_from_arg 处理（可显式 shux check tests/...）。
     */
    if (!any_path)
        check_collect_default_product_dirs();

    /* public n：hybrid thin pure BSS / 冷 seed static */
    if (fmt_file_list_n() == 0) {
        if (any_path)
            diag_report_with_code(NULL, 0, 0, "check error", "CHK002",
                                  "no .x files found under given path(s)", NULL);
        else
            diag_report_with_code(NULL, 0, 0, "check error", "CHK002",
                                  "no .x files found in current directory", NULL);
        return 1;
    }

    for (i = 0; i < fmt_file_list_n(); i++) {
        /* public：hybrid thin pure 门闩→body / 冷 seed public→_impl→body */
        if (check_one_file(s_file_list[i], argc, argv) != 0) {
            failed = 1;
            if (fail_fast)
                break;
        }
        checked++;
    }

    file_list_clear_impl();

    if (failed)
        return 1;

    if (!s_check_quiet_ok && checked > 0)
        diag_reportf(NULL, 0, 0, "info", NULL,
                     "check OK (%d file%s)", checked, checked == 1 ? "" : "s");

    return 0;
}
#ifndef SHUX_L2_FMT_CHECK_THIN_FROM_X
int driver_run_compiler_check(int argc, char **argv) {
    return driver_run_compiler_check_impl(argc, argv);
}
#endif

int fmt_check_cmd_slice_marker(void) {
    return 1;
}
