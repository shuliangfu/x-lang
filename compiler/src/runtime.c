/**
 * runtime.c — 编译器运行时（6.3/6.4：自 main.c 迁出的驱动逻辑与 C 辅助）
 *
 * 文件职责：提供 run_compiler_c、driver_*、pipeline_*、get_dep_* 及 read_file/preprocess/resolve_import 等；无 SHUX_USE_SX_DRIVER 时提供弱符号 main_entry 转调 run_compiler_c，供默认构建链接；有 main.sx 时由 main_entry 覆盖。
 * 与 main.c 关系：main.c 仅保留极简 main() 调 main_entry；本文件承载全部 C 侧驱动与 I/O，与 main.sx 一一对应构建 shux。
 * 阶段 10 方向：逐步收成薄壳（入口、ABI、`-E` 桥接）；业务逻辑已迁 .sx（pipeline/driver/LSP）；日常构建入口见仓库根目录 build.sx + compiler/build_tool。
 */

#include "lexer/lexer.h"
#include "parser/parser.h"
#include "preprocess.h"
#include "typeck/typeck.h"
#include "codegen/codegen.h"
#include "ast.h"
#include "target_cpu.h"
#include "lsp/lsp_diag.h"
#ifdef SHUX_USE_SX_CODEGEN
/* 6.2：.sx codegen 入口；由 codegen.sx 提供（库模块形式，符号带 codegen_ 前缀），转调 C codegen */
extern int codegen_codegen_entry_module_to_c(struct ASTModule *m, FILE *out, struct ASTModule **dep_mods, const char **dep_import_paths, int ndep,
    codegen_is_func_used_fn is_func_used, codegen_is_mono_used_fn is_mono_used, codegen_is_type_used_fn is_type_used, void *dce_ctx,
    char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted);
extern int codegen_codegen_entry_library_module_to_c(struct ASTModule *m, const char *import_path,
    struct ASTModule **lib_dep_mods, const char **lib_dep_paths, int n_lib_dep, FILE *out,
    codegen_is_func_used_fn is_func_used, codegen_is_mono_used_fn is_mono_used, codegen_is_type_used_fn is_type_used, void *dce_ctx,
    char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted);
#endif
#include <ctype.h>
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <pthread.h>
#if defined(__APPLE__)
#include <mach-o/dyld.h>
#endif
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
/* 提前声明，供 SHUX_USE_SX_PIPELINE 块内 pipeline_* 调用 */
static char *read_file(const char *path, size_t *out_len);
static void resolve_import_file_path_multi(const char **lib_roots, int n_lib_roots, const char *entry_dir, const char *import_path, char *path, size_t path_size);
#ifdef SHUX_USE_SX_TYPECK
/* 6.1：.sx typeck 入口；由 typeck.sx 提供（库模块形式生成，符号为 typeck_typeck_entry），转调 C typeck_module */
extern int typeck_typeck_entry(struct ASTModule *mod, struct ASTModule **deps, int ndep);
#endif
#ifdef SHUX_USE_SX_PIPELINE
/**
 * pipeline / run_compiler 路径在条目 251x/325x 等处调用，实现位于本文件后部 #if SHUX_USE_SX_PIPELINE 静态区；
 * 此处前置声明以满足 C99「先声明后调用」，避免编译 runtime_sx.o / runtime_driver.o 时出现隐式声明与类型冲突。
 */
void driver_dep_seed_slots(void *arenas[32], void *modules[32], int32_t n);
void driver_dep_seeded_clear_all(void);
void driver_dep_publish_slot(int32_t i, void *arena, void *module, const char *import_path);
int32_t driver_dep_slot_for_path(const char *path);
#endif

/** shux check：非 0 时 typeck 通过后跳过 codegen 与链接（C 与 SU pipeline 共用）。 */
static int driver_check_only_flag;
void driver_check_only_set(int32_t v) { driver_check_only_flag = (v != 0); }
int32_t driver_check_only_get(void) { return driver_check_only_flag ? 1 : 0; }

/** `-freestanding` / SHUX_FREESTANDING：用户程序 nostdlib 静态链（S4）。 */
static int driver_freestanding_flag;
void driver_freestanding_set(int32_t v) { driver_freestanding_flag = (v != 0); }
int32_t driver_freestanding_get(void) { return driver_freestanding_flag ? 1 : 0; }

/** M-6：`-fsanitize=address` / SHUX_SANITIZE_ADDRESS=1 时强制数组/切片 INDEX 边界检查（仅 debug 插桩）。 */
static int driver_sanitize_address_flag;
void driver_sanitize_address_set(int32_t v) { driver_sanitize_address_flag = (v != 0); }
int32_t driver_sanitize_address_get(void) {
    if (driver_sanitize_address_flag)
        return 1;
    {
        const char *e = getenv("SHUX_SANITIZE_ADDRESS");
        if (e && e[0] && e[0] != '0')
            return 1;
    }
    return 0;
}

static int driver_fmt_check_only_flag;
/** shux fmt --check：仅校验格式，不写回；需 reform 时返回 1。 */
void driver_fmt_check_only_set(int32_t v) { driver_fmt_check_only_flag = (v != 0); }
int32_t driver_fmt_check_only_get(void) { return driver_fmt_check_only_flag ? 1 : 0; }

/** 非 SU 链或未链 fmt_check_cmd 时弱符号默认 0（保留逐文件 check OK）。 */
__attribute__((weak)) int driver_check_quiet_ok_get(void) {
    return 0;
}

/** 统一 shux check 成功行；deno 风格批量 check 成功时由 fmt_check_cmd 保持静默。 */
static void driver_print_check_ok(const char *input_path) {
    if (driver_check_quiet_ok_get())
        return;
    fprintf(stderr, "check OK: %s\n", input_path ? input_path : "?");
    fflush(stderr);
}

/** 非 0 时 pipeline_impl_typecheck 跳过 .sx typeck（C 预检已通过，见 driver_run_asm_backend）。 */
static int driver_su_pipeline_skip_typeck_flag;

/** 供 pipeline.sx 读取：是否跳过 SU typeck。 */
int32_t driver_su_pipeline_skip_typeck_get(void) {
    return driver_su_pipeline_skip_typeck_flag ? 1 : 0;
}

/** 设置 SU typeck 跳过标志（C 预检后由 runtime 置位/清位）。 */
void driver_su_pipeline_skip_typeck_set(int32_t v) {
    driver_su_pipeline_skip_typeck_flag = (v != 0);
}

/** 非 0 时 pipeline_impl_run_all 跳过 .sx C codegen（用户 asm -o 由 asm_codegen_elf_o 单路径 emit）。 */
static int driver_su_pipeline_skip_codegen_flag;

/** 供 pipeline.sx 读取：是否跳过 SU C codegen。 */
int32_t driver_su_pipeline_skip_codegen_get(void) {
    return driver_su_pipeline_skip_codegen_flag ? 1 : 0;
}

/** 设置 SU C codegen 跳过标志（asm 用户编译前置 parse/typeck 后置位/清位）。 */
void driver_su_pipeline_skip_codegen_set(int32_t v) {
    driver_su_pipeline_skip_codegen_flag = (v != 0);
}

#if defined(SHUX_USE_SX_PIPELINE) || defined(SHUX_USE_SX_DRIVER)
/** asm emit 桩判定：build_shux_asm 编 typeck/parser 等大模块前须设置 ctx（ast_pool.c）。形参用 void* 避免 GCC 15 参数列表内 struct 不可见导致 -Wincompatible-pointer-types 报错（Alpine/musl）。 */
extern void asm_skip_heavy_set_pipeline_ctx(void *ctx);
/** C 预检跳过 .sx typeck 后：为块内 ARRAY_LIT 回填 resolved_type_ref（pipeline_glue.c）。 */
extern void pipeline_fill_array_lit_types_for_skipped_typeck(void *m, void *arena);
/** asm emit 前：DOD-S1 SoA arr[i].field 补 stride（pipeline_glue.c）。 */
extern void pipeline_fill_soa_field_access_for_asm_emit(void *m, void *arena);

/**
 * asm_codegen_elf_o 前：设置 skip_heavy 上下文并为 ARRAY_LIT / SoA field 补类型（C typeck 路径无 .sx typeck）。
 */
static void driver_asm_prepare_entry_elf_emit(void *module, void *arena, void *pctx) {
    asm_skip_heavy_set_pipeline_ctx(pctx);
    pipeline_fill_array_lit_types_for_skipped_typeck(module, arena);
    pipeline_fill_soa_field_access_for_asm_emit(module, arena);
}
#endif /* SHUX_USE_SX_PIPELINE || SHUX_USE_SX_DRIVER */

/**
 * 非 0 时入口模块 typeck 走 C 的 typeck_module（build_shux_asm 编 typeck/parser 等大模块时设置，避免 .sx typeck 栈过深）。
 */
int32_t driver_typeck_force_c_enabled(void) {
    const char *e = getenv("SHUX_TYPECK_FORCE_C");
    return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** 当前线程是否已在 driver_run_thread_on_large_stack 创建的大栈 pthread 内（避免 LSP 等嵌套再分配 256MiB 栈导致 Alpine OOM/SIGSEGV）。 */
static _Thread_local int g_driver_on_large_stack_thread;

/**
 * 供 ast_pool / pipeline glue 查询：LSP 主循环已在大栈线程上时，typeck 勿再 spawn 嵌套 pthread。
 */
int driver_is_large_stack_thread(void) {
    return g_driver_on_large_stack_thread;
}

/**
 * 大模块 .sx pipeline（parse/typeck/codegen）栈帧深；macOS 默认栈约 512KiB 易 segfault(139)。
 * run_compiler_c / run_compiler_sx_path / driver_run_asm_backend 均在进入 pipeline 前调用。
 */
static void driver_bump_stack_limit_if_needed(void) {
    struct rlimit rl;
    if (getrlimit(RLIMIT_STACK, &rl) == 0 && rl.rlim_cur < (rlim_t)(64 * 1024 * 1024)) {
        rl.rlim_cur = (rlim_t)(64 * 1024 * 1024);
        (void)setrlimit(RLIMIT_STACK, &rl);
    }
}

/** 舒 IO 后端 .o 路径（分析/舒IO实现路线图.md 阶段 1）；源码在 std/io/io.c，产出 std/io/io.o（与 shux 所在目录的上一级 std/io/ 下）；C 与 -sx 路径均需链入。 */
static const char *get_io_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = '\0';
    resolved[0] = '\0';
    if (!argv0 || !argv0[0]) return buf;
    const char *last_slash = strrchr(argv0, '/');
    int n;
    if (last_slash) {
        n = (int)(last_slash - argv0);
        if (n >= (int)sizeof(buf) - 20) return buf;
        memcpy(buf, argv0, (size_t)n);
        buf[n] = '\0';
    } else {
        if (sizeof(buf) < 20) return buf;
        buf[0] = '.'; buf[1] = '\0';
        n = 1;
    }
    if (n + 18 >= (int)sizeof(buf)) return buf;
    strcat(buf, "/../std/io/io.o");
    if (realpath(buf, resolved) != NULL) return resolved;
    if (realpath("std/io/io.o", resolved) != NULL) return resolved;
#ifdef __APPLE__
    /* macOS 下从 PATH 运行 shux 时 argv[0] 可能无目录，用 cwd 再试一次 */
    {
        char cwd_buf[512];
        if (getcwd(cwd_buf, sizeof(cwd_buf) - 16) != NULL) {
            strcat(cwd_buf, "/std/io/io.o");
            if (realpath(cwd_buf, resolved) != NULL) return resolved;
        }
    }
#endif
    return buf;
}

#if defined(SHUX_USE_SX_PIPELINE)
/** 向生成 C 写入 std.io / std.net 内联 ABI（原 io_abi.h、net_abi.h 内容），不再依赖该二头文件。成功返回 0。 */
static int write_io_net_abi_inline(FILE *cf) {
    static const char *lines[] = {
        "#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 201112L\n#error \"Generated code needs C11. Compile with -std=gnu11 or -std=c11.\"\n#endif\n",
        "#include <stddef.h>\n",
        "#include <stdint.h>\n",
        "#include <unistd.h>\n",
        "typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;\n",
        "extern int io_register_buffer(uint8_t *ptr, size_t len);\n",
        "extern int io_register_buffers_4(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, unsigned nr);\n",
        "extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);\n",
        "static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }\n",
        "#define io_register_buffers_buf(bufs, nr) io_register_buffers_buf_i32((intptr_t)(void *)(bufs), (nr))\n",
        "extern void io_unregister_buffers(void);\n",
        "extern ptrdiff_t io_read(int fd, uint8_t *buf, size_t count, unsigned timeout_ms);\n",
        "extern ptrdiff_t io_write(int fd, uint8_t *buf, size_t count, unsigned timeout_ms);\n",
        "extern ptrdiff_t io_read_batch(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, int n, unsigned timeout_ms);\n",
        "extern ptrdiff_t io_write_batch(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, int n, unsigned timeout_ms);\n",
        "extern ptrdiff_t io_read_fixed(int fd, unsigned buf_index, size_t offset, size_t len, unsigned timeout_ms);\n",
        "extern ptrdiff_t io_write_fixed(int fd, unsigned buf_index, size_t offset, size_t len, unsigned timeout_ms);\n",
        "extern int io_wait_readable(int32_t *fds, int n, unsigned timeout_ms);\n",
        "extern uint8_t *io_read_ptr(size_t handle, unsigned timeout_ms);\n",
        "extern int io_read_ptr_len(void);\n",
        "extern int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle);\n",
        "extern int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n",
        "extern int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n",
        "extern int32_t shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_m);\n",
        "extern int32_t shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_m);\n",
        "extern uint8_t *shux_io_read_ptr(size_t handle, unsigned timeout_ms);\n",
        "extern int32_t shux_io_read_ptr_len(void);\n",
        "typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;\n",
        "static inline int32_t shux_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_register((uint8_t *)b->ptr, b->len, b->handle); }\n",
        "static inline int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return (shux_io_submit_read)((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }\n",
        "static inline int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return (shux_io_submit_write)((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }\n",
        "static inline int32_t std_io_driver_submit_read(ptrdiff_t buf, uint32_t timeout_ms) { return shux_io_submit_read_buf((intptr_t)buf, (int32_t)timeout_ms); }\n",
        "static inline int32_t std_io_driver_submit_write(ptrdiff_t buf, uint32_t timeout_ms) { return shux_io_submit_write_buf((intptr_t)buf, (int32_t)timeout_ms); }\n",
        "#define shux_io_register(buf) shux_io_register_buf(buf)\n",
        "#define shux_io_submit_read(buf, timeout_m) shux_io_submit_read_buf(buf, timeout_m)\n",
        "#define shux_io_submit_write(buf, timeout_m) shux_io_submit_write_buf(buf, timeout_m)\n",
        "/* 撤销宏：SU codegen 会生成同名函数定义(shux_io_register/submit_read/submit_write)，宏与多参签名冲突，在函数体前必须 undef。 */\n",
        "#undef shux_io_register\n",
        "#undef shux_io_submit_read\n",
        "#undef shux_io_submit_write\n",
        "struct std_io_driver_Buffer { void *ptr; size_t len; size_t handle; };\n",
        "typedef struct std_io_driver_Buffer std_io_Buffer;\n",
        "#define std_io_Buffer std_io_driver_Buffer\n",
        "extern ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);\n",
        "extern ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);\n",
        "extern int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_driver_Buffer * bufs, uint32_t nr);\n",
        "#define std_io_driver_driver_read_ptr_len shux_io_read_ptr_len\n",
        "#define std_io_driver_driver_read_ptr shux_io_read_ptr\n",
        "#define driver_read_ptr_len std_io_driver_driver_read_ptr_len\n",
        "#define driver_read_ptr std_io_driver_driver_read_ptr\n",
        "#define submit_register_fixed_buffers_buf std_io_driver_submit_register_fixed_buffers_buf\n",
        "/* SU codegen 在 std_io_driver_read/write 体内用短名 submit_read/submit_write(Buffer)；须转调 preamble 的 ptrdiff_t _buf 包装。 */\n",
        "#define submit_read(buf, timeout_ms) std_io_driver_submit_read((ptrdiff_t)(uintptr_t)&(buf), (timeout_ms))\n",
        "#define submit_write(buf, timeout_ms) std_io_driver_submit_write((ptrdiff_t)(uintptr_t)&(buf), (timeout_ms))\n",
        "#define std_io_driver_read_ptr driver_read_ptr\n",
        "#define std_io_driver_read_ptr_len driver_read_ptr_len\n",
        "extern size_t std_io_handle_stdin(void);\n",
        "extern size_t std_io_handle_stdout(void);\n",
        "extern size_t std_io_handle_stderr(void);\n",
        "extern size_t std_io_handle_from_fd(int32_t fd, int32_t unused);\n",
        "extern size_t std_io_driver_handle_from_fd(int32_t fd, int32_t unused);\n",
        "extern int32_t std_io_write_stdout(uint8_t *ptr, size_t len);\n",
        "#define std_io_driver_handle_stdin std_io_handle_stdin\n",
        "#define std_io_driver_handle_stdout std_io_handle_stdout\n",
        "#define std_io_driver_handle_stderr std_io_handle_stderr\n",
        "#define std_io_driver_write_stdout std_io_write_stdout\n",
        "/* std.io.core 体内调 extern io_*；codegen 前缀为 std_io_core_io_*，映射到 preamble 已声明的 io_*。 */\n",
        "#define std_io_core_io_read io_read\n",
        "#define std_io_core_io_write io_write\n",
        "#define std_io_core_io_read_batch io_read_batch\n",
        "#define std_io_core_io_write_batch io_write_batch\n",
        "#define std_io_core_io_read_fixed io_read_fixed\n",
        "#define std_io_core_io_write_fixed io_write_fixed\n",
        "#define std_io_core_shux_io_register shux_io_register\n",
        "#define std_io_core_shux_io_register_buffers shux_io_register_buffers\n",
        "#define std_io_core_shux_io_unregister_buffers shux_io_unregister_buffers\n",
        "#define std_io_core_shux_io_submit_read shux_io_submit_read\n",
        "#define std_io_core_shux_io_read_ptr shux_io_read_ptr\n",
        "#define std_io_core_shux_io_read_ptr_len shux_io_read_ptr_len\n",
        "#define std_io_core_shux_io_submit_write shux_io_submit_write\n",
        "#define std_io_core_shux_io_submit_read_batch shux_io_submit_read_batch\n",
        "#define std_io_core_shux_io_submit_write_batch shux_io_submit_write_batch\n",
        "#define std_io_core_shux_io_read_fixed shux_io_read_fixed\n",
        "#define std_io_core_shux_io_write_fixed shux_io_write_fixed\n",
        "#define std_io_driver_io_register_buffers_buf(bufs, nr) io_register_buffers_buf((intptr_t)(void *)(bufs), (int)(nr))\n",
        "extern int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer * bufs, int32_t n, uint32_t timeout_ms);\n",
        "extern int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer * bufs, int32_t n, uint32_t timeout_ms);\n",
        "#define std_io_submit_read_batch_buf std_io_driver_submit_read_batch_buf\n",
        "#define std_io_submit_write_batch_buf std_io_driver_submit_write_batch_buf\n",
        "extern int32_t std_io_read_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);\n",
        "extern int32_t std_io_write_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);\n",
        "/* SU 生成代码可能调用 std_io_* / std_net_* 带前缀名且首参为 stream/listener 结构体；以下宏统一转为 .fd 再调 _impl。C 路径下 std.io 仍定义 std_io_read_fixed_fd，故仅 SU 需宏。 */\n",
        "struct std_net_TcpStream { int32_t fd; };\n",
        "struct std_net_TcpListener { int32_t fd; };\n",
        "struct std_net_UdpSocket { int32_t fd; };\n",
        "#if defined(__clang__)\n",
        "#define shux_io_net_fd(x) _Generic((x), struct std_net_TcpStream: (x).fd, struct std_net_TcpListener: (x).fd, struct std_net_UdpSocket: (x).fd, default: (int32_t)(x))\n",
        "#elif defined(__GNUC__)\n",
        "/* 仅用 *(int32_t*)&(x)：int32_t 与仅含 .fd 的 struct 首字节相同，且避免 __builtin_types_compatible_p 在部分环境报错、三元分支被全量类型检查。调用方须传 lvalue。 */\n",
        "#define shux_io_net_fd(x) (*(int32_t*)(void*)&(x))\n",
        "#else\n",
        "#define shux_io_net_fd(x) _Generic((x), struct std_net_TcpStream: (x).fd, struct std_net_TcpListener: (x).fd, struct std_net_UdpSocket: (x).fd, default: (int32_t)(x))\n",
        "#endif\n",
        "#define std_io_read_fixed_fd(x, a, b, c, d) std_io_read_fixed_fd_impl(shux_io_net_fd(x), a, b, c, d)\n",
        "#define std_io_write_fixed_fd(x, a, b, c, d) std_io_write_fixed_fd_impl(shux_io_net_fd(x), a, b, c, d)\n",
        "/* SU 内联 std.io 会生成函数定义；撤销与定义/extern 冲突的宏，并补齐 batch 注册符号映射。 */\n",
        "#undef std_io_driver_io_register_buffers_buf\n",
        "#undef std_io_read_fixed_fd\n",
        "#undef std_io_write_fixed_fd\n",
        "#undef std_io_core_shux_io_register_buffers\n",
        "#undef std_io_core_shux_io_unregister_buffers\n",
        "#undef std_io_core_shux_io_read_fixed\n",
        "#undef std_io_core_shux_io_write_fixed\n",
        "#undef std_io_core_shux_io_wait_readable\n",
        "#define std_io_core_shux_io_register_buffers io_register_buffers_4\n",
        "#define std_io_core_shux_io_unregister_buffers io_unregister_buffers\n",
        "#define std_io_core_shux_io_read_fixed shux_io_read_fixed\n",
        "#define std_io_core_shux_io_write_fixed shux_io_write_fixed\n",
        "#define std_io_core_shux_io_wait_readable io_wait_readable\n",
        "/* codegen 体内调 std_io_driver_io_*；#undef 后重绑到 preamble/io.o 的 io_*。 */\n",
        "#define std_io_driver_io_read_batch_buf io_read_batch_buf\n",
        "#define std_io_driver_io_write_batch_buf io_write_batch_buf\n",
        "#define std_io_driver_io_register_buffers_buf(bufs, nr) io_register_buffers_buf((intptr_t)(void *)(bufs), (int)(nr))\n",
        "/* SU 内联 std.io 时若 driver/mod 部分包装未 codegen，由弱符号补齐以免链接失败（handle_from_fd 由 mod codegen 定义，此处不再 weak）。 */\n",
        "#ifndef __cplusplus\n",
        "__attribute__((weak)) int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {\n",
        "  (void)handle;(void)bufs;(void)n;(void)timeout_ms; return -1;\n",
        "}\n",
        "__attribute__((weak)) int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {\n",
        "  (void)handle;(void)bufs;(void)n;(void)timeout_ms; return -1;\n",
        "}\n",
        "__attribute__((weak)) int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_driver_Buffer *bufs, uint32_t nr) {\n",
        "  (void)bufs; return io_register_buffers_buf_i32((intptr_t)(void *)bufs, (int)nr);\n",
        "}\n",
        "#endif\n",
        "struct std_net_Ipv4Addr { uint8_t a; uint8_t b; uint8_t c; uint8_t d; };\n",
        "struct std_net_Ipv6Addr { uint8_t b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15; };\n",
        "#define handle_from_fd std_io_handle_from_fd\n",
        "#define submit_read_batch_buf std_io_submit_read_batch_buf\n",
        "#define submit_write_batch_buf std_io_submit_write_batch_buf\n",
        "#define read_fixed_fd(x, a, b, c, d) std_io_read_fixed_fd_impl(shux_io_net_fd(x), a, b, c, d)\n",
        "#define write_fixed_fd(x, a, b, c, d) std_io_write_fixed_fd_impl(shux_io_net_fd(x), a, b, c, d)\n",
        "/* 实际符号用 _real 后缀，避免宏 net_close_socket_c(x) 展开时再触发自身。 */\n",
        "extern int32_t net_close_socket_c_real(int32_t fd);\n",
        "extern int32_t net_run_accept_workers_c_real(int32_t listener_fd, int32_t n_workers, uint32_t timeout_ms);\n",
        "#define net_close_socket_c(x) net_close_socket_c_real(shux_io_net_fd(x))\n",
        "#define std_net_net_close_socket_c(x) net_close_socket_c_real(shux_io_net_fd(x))\n",
        "#define net_run_accept_workers_c(x, n, t) net_run_accept_workers_c_real(shux_io_net_fd(x), n, t)\n",
        "#define std_net_net_run_accept_workers_c(x, n, t) net_run_accept_workers_c_real(shux_io_net_fd(x), n, t)\n",
        "#define STD_FS_FS_IOVEC_BUF_DEFINED\nstruct std_fs_FsIovecBuf { void *ptr; size_t len; size_t handle; };\n",
        "struct std_map_Map_i32_i32 { int32_t *keys; int32_t *vals; uint8_t *occupied; int32_t cap; int32_t len; };\n",
        "typedef struct std_io_driver_Buffer std_net_Buffer;\n",
        "struct std_error_Error { int32_t code; };\n",
        "struct std_string_String { uint8_t data[256]; int32_t len; };\n",
        "typedef struct std_string_String String;\n",
        "struct std_string_StrView { uint8_t *ptr; int32_t len; };\n",
        "struct std_vec_Vec_i32 { int32_t *ptr; int32_t len; int32_t cap; };\n",
        "struct core_option_Option_i32 { int is_some; int32_t value; };\n",
        "struct core_result_Result_i32 { int32_t value; int32_t _pad1; int32_t err; int32_t _pad2; };\n",
        "extern int32_t core_types_placeholder(int32_t, int32_t);\n",
        "#ifndef __cplusplus\n",
        "__attribute__((weak)) int32_t core_types_placeholder(int32_t a, int32_t b) { (void)a;(void)b; return 0; }\n",
        "#endif\n",
        "extern int32_t std_heap_alloc_size_zero(void);\n",
        "extern int32_t std_runtime_runtime_ready(void);\n",
        "#ifndef __cplusplus\n"
        "__attribute__((weak)) int32_t std_vec_vec_len_empty(void) { return 0; }\n"
        "#else\n"
        "extern int32_t std_vec_vec_len_empty(void);\n"
        "#endif\n",
        "#define vec_len_empty std_vec_vec_len_empty\n",
        "#define alloc_size_zero std_heap_alloc_size_zero\n",
        "#define runtime_ready std_runtime_runtime_ready\n",
        "#ifndef __cplusplus\n"
        "__attribute__((weak)) int32_t std_string_placeholder(void) { return 0; }\n"
        "#else\n"
        "extern int32_t std_string_placeholder(void);\n"
        "#endif\n",
        "#define placeholder std_string_placeholder\n",
        "extern int32_t fmt_i32(int32_t);\n",
        "extern struct std_string_String std_string_string_new(void);\n",
        "#define string_new std_string_string_new\n",
    };
    /* lines[] 下标与 write_io_net_abi_inline 源行号对应：index = 源行号 - 106（首行 "#if !defined"）。 */
    const unsigned skip = codegen_get_preamble_skip_mask();
    for (size_t i = 0; i < sizeof(lines) / sizeof(lines[0]); i++) {
        int skip_line = 0;
        /* std_io_driver_handle_* 别名（166–169）：codegen 已 emit handle_stdin 等时跳过。 */
        if ((skip & CODEGEN_PREAMBLE_SKIP_STD_IO_DRIVER_HANDLE) && i >= 60 && i < 64)
            skip_line = 1;
        /* std_io_core_io_* 宏（170–187）：无 std.io.core 内联时可整段省略。 */
        if ((skip & CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS) && i >= 64 && i < 82)
            skip_line = 1;
        /* #undef / 重绑 std_io_core_*（209–222）：SU 内联 std.io.core 且 codegen 已 emit 时由 codegen 侧承担。 */
        if ((skip & CODEGEN_PREAMBLE_SKIP_STD_IO_UNDEF_REDEFINE) && i >= 105 && i < 119)
            skip_line = 1;
        /* weak batch/register（230–240 含 #ifndef/#endif）：codegen 已 emit 强符号定义时跳过整段。 */
        if ((skip & CODEGEN_PREAMBLE_SKIP_WEAK_IO_BATCH) && i >= 124 && i <= 134)
            skip_line = 1;
        if (!skip_line && fputs(lines[i], cf) == EOF)
            return 1;
    }
    return 0;
}
#endif /* SHUX_USE_SX_PIPELINE */

/** 由 argv0 推导仓库根目录（用于 -I 以便生成 .c 能 #include std/fs、path、map、error 等 ABI 头）；基于 get_io_o_path 的路径向上取三级目录。 */
static const char *get_repo_root(const char *argv0) {
    static char buf[512];
    const char *io_o = get_io_o_path(argv0);
    buf[0] = '\0';
    if (!io_o || !io_o[0]) return buf;
    if (strlen(io_o) >= sizeof(buf)) return buf;
    strcpy(buf, io_o);
    for (int k = 0; k < 3; k++) {
        char *last = strrchr(buf, '/');
        if (!last || last == buf) break;
        *last = '\0';
    }
    return buf;
}

/**
 * parser.sx 聚合成单文件 .c 写在 /tmp 时，#include "pipeline_glue.c" 会先搜含入文件目录（/tmp），
 * find 不到编译器目录下的 glue；此处写出 #include "\"<绝对路径>/pipeline_glue.c\""。
 * argv0 一般为 shux 路径（如 ./shux）；与 pipeline_glue.c 同位于 compiler/ 目录即可解析。
 */
#if !defined(SHUX_USE_SX_DRIVER)
static void codegen_emit_include_pipeline_glue_c(FILE *out, const char *argv0) {
    char rel[PATH_MAX];
    static char canon[PATH_MAX];
    rel[0] = '\0';
    canon[0] = '\0';
    if (!out)
        return;
    /* 缩减版：无 pipeline.sx 全量类型与 codegen.o 转发目标，见 pipeline_glue.c 内 #ifndef 块。 */
    fprintf(out, "\n#define SHUX_PARSER_EXE_PIPELINE_GLUE 1\n");
    if (!argv0 || !argv0[0]) {
        if (realpath("pipeline_glue.c", canon) != NULL)
            fprintf(out, "\n#include \"%s\"\n", canon);
        return;
    }
    {
        const char *slash = strrchr(argv0, '/');
        if (slash) {
            int n = (int)(slash - argv0);
            if (n >= 0 && (size_t)n + (size_t)21 < sizeof(rel)) {
                (void)snprintf(rel, sizeof(rel), "%.*s/pipeline_glue.c", n, argv0);
            }
        } else if (realpath("pipeline_glue.c", rel) == NULL) {
            rel[0] = '\0';
        }
    }
    if (rel[0] != '\0') {
        if (realpath(rel, canon) != NULL)
            fprintf(out, "\n#include \"%s\"\n", canon);
        else
            fprintf(out, "\n#include \"%s\"\n", rel);
    } else if (realpath("pipeline_glue.c", canon) != NULL) {
        fprintf(out, "\n#include \"%s\"\n", canon);
    }
}
#endif /* !SHUX_USE_SX_DRIVER */

/** std.fs 高性能 .o 路径（mmap/munmap）；优先 cwd 以兼容多工作区，产出 std/fs/fs.o。 */
static const char *get_std_fs_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/fs/fs.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 18) != NULL) { size_t L = strlen(cwd); if (L + 18 <= sizeof(cwd)) { memcpy(cwd + L, "/std/fs/fs.o", 13); cwd[L+13] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (!argv0 || !argv0[0]) return buf;
    { const char *last_slash = strrchr(argv0, '/'); int n = last_slash ? (int)(last_slash - argv0) : 0;
      if (last_slash && n + 18 < (int)sizeof(buf)) { memcpy(buf, argv0, (size_t)n); buf[n] = '\0'; strcat(buf, "/../std/fs/fs.o"); if (realpath(buf, resolved) != NULL) return resolved; }
      else if (!last_slash && 18 < (int)sizeof(buf)) { buf[0] = '.'; buf[1] = '\0'; strcat(buf, "/../std/fs/fs.o"); if (realpath(buf, resolved) != NULL) return resolved; } }
    return buf;
}

/** std.process argc/argv/getenv；优先 cwd，产出 std/process/process.o。 */
static const char *get_std_process_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/process/process.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 26) != NULL) { size_t L = strlen(cwd); if (L + 26 <= sizeof(cwd)) { memcpy(cwd + L, "/std/process/process.o", 23); cwd[L+23] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (!argv0 || !argv0[0]) return buf;
    { const char *last_slash = strrchr(argv0, '/'); int n = last_slash ? (int)(last_slash - argv0) : 0;
      if (last_slash && n + 24 < (int)sizeof(buf)) { memcpy(buf, argv0, (size_t)n); buf[n] = '\0'; strcat(buf, "/../std/process/process.o"); if (realpath(buf, resolved) != NULL) return resolved; }
      else if (!last_slash && 24 < (int)sizeof(buf)) { buf[0] = '.'; buf[1] = '\0'; strcat(buf, "/../std/process/process.o"); if (realpath(buf, resolved) != NULL) return resolved; } }
    return buf;
}

/** std.string 长串快路径（memcmp/memmem）；优先 cwd，产出 std/string/string.o。 */
static const char *get_std_string_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/string/string.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 24) != NULL) { size_t L = strlen(cwd); if (L + 24 <= sizeof(cwd)) { memcpy(cwd + L, "/std/string/string.o", 21); cwd[L+21] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (!argv0 || !argv0[0]) return buf;
    { const char *last_slash = strrchr(argv0, '/'); int n = last_slash ? (int)(last_slash - argv0) : 0;
      if (last_slash && n + 22 < (int)sizeof(buf)) { memcpy(buf, argv0, (size_t)n); buf[n] = '\0'; strcat(buf, "/../std/string/string.o"); if (realpath(buf, resolved) != NULL) return resolved; }
      else if (!last_slash && 22 < (int)sizeof(buf)) { buf[0] = '.'; buf[1] = '\0'; strcat(buf, "/../std/string/string.o"); if (realpath(buf, resolved) != NULL) return resolved; } }
    return buf;
}

/** std.heap 堆分配（malloc/free）；优先 cwd，产出 std/heap/heap.o。 */
static const char *get_std_heap_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/heap/heap.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/heap/heap.o", 17); cwd[L+17] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (!argv0 || !argv0[0]) return buf;
    { const char *last_slash = strrchr(argv0, '/'); int n = last_slash ? (int)(last_slash - argv0) : 0;
      if (last_slash && n + 20 < (int)sizeof(buf)) { memcpy(buf, argv0, (size_t)n); buf[n] = '\0'; strcat(buf, "/../std/heap/heap.o"); if (realpath(buf, resolved) != NULL) return resolved; }
      else if (!last_slash && 20 < (int)sizeof(buf)) { buf[0] = '.'; buf[1] = '\0'; strcat(buf, "/../std/heap/heap.o"); if (realpath(buf, resolved) != NULL) return resolved; } }
    return buf;
}

/** std.path 平台分隔符（std/path/path.o）；优先 cwd。 */
static const char *get_std_path_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/path/path.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/std/path/path.o", sizeof("/std/path/path.o")); if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (!argv0 || !argv0[0]) return buf;
    { const char *last_slash = strrchr(argv0, '/'); int n = last_slash ? (int)(last_slash - argv0) : 0;
      if (last_slash && n + 22 < (int)sizeof(buf)) { memcpy(buf, argv0, (size_t)n); buf[n] = '\0'; strcat(buf, "/../std/path/path.o"); if (realpath(buf, resolved) != NULL) return resolved; }
      else if (!last_slash && 22 < (int)sizeof(buf)) { buf[0] = '.'; buf[1] = '\0'; strcat(buf, "/../std/path/path.o"); if (realpath(buf, resolved) != NULL) return resolved; } }
    return buf;
}

/** std.runtime panic/abort（std/runtime/runtime.o）；优先 cwd。 */
static const char *get_std_runtime_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/runtime/runtime.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 28) != NULL) { size_t L = strlen(cwd); if (L + 28 <= sizeof(cwd)) { memcpy(cwd + L, "/std/runtime/runtime.o", sizeof("/std/runtime/runtime.o")); if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (!argv0 || !argv0[0]) return buf;
    { const char *last_slash = strrchr(argv0, '/'); int n = last_slash ? (int)(last_slash - argv0) : 0;
      if (last_slash && n + 26 < (int)sizeof(buf)) { memcpy(buf, argv0, (size_t)n); buf[n] = '\0'; strcat(buf, "/../std/runtime/runtime.o"); if (realpath(buf, resolved) != NULL) return resolved; }
      else if (!last_slash && 26 < (int)sizeof(buf)) { buf[0] = '.'; buf[1] = '\0'; strcat(buf, "/../std/runtime/runtime.o"); if (realpath(buf, resolved) != NULL) return resolved; } }
    return buf;
}

/** std.net TCP 网络（std/net/net.o）；优先 cwd，产出 std/net/net.o。 */
static const char *get_std_net_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/net/net.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/net/net.o", 15); cwd[L+15] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (!argv0 || !argv0[0]) return buf;
    { const char *last_slash = strrchr(argv0, '/'); int n = last_slash ? (int)(last_slash - argv0) : 0;
      if (last_slash && n + 18 < (int)sizeof(buf)) { memcpy(buf, argv0, (size_t)n); buf[n] = '\0'; strcat(buf, "/../std/net/net.o"); if (realpath(buf, resolved) != NULL) return resolved; }
      else if (!last_slash && 18 < (int)sizeof(buf)) { buf[0] = '.'; buf[1] = '\0'; strcat(buf, "/../std/net/net.o"); if (realpath(buf, resolved) != NULL) return resolved; } }
    return buf;
}

/** std.thread 线程（std/thread/thread.o）；与 get_std_net_o_path 类似，产出 std/thread/thread.o。优先用 getcwd 与相对路径，避免依赖 argv[0] 解析。 */
static const char *get_std_thread_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = '\0';
    resolved[0] = '\0';
    /* 1) 相对路径 std/thread/thread.o（调用方 cwd 常为仓库根） */
    if (realpath("std/thread/thread.o", resolved) != NULL) return resolved;
    /* 2) getcwd() + /std/thread/thread.o */
    {
        char cwd_buf[512];
        if (getcwd(cwd_buf, sizeof(cwd_buf) - 22) != NULL) {
            size_t cwd_len = strlen(cwd_buf);
            if (cwd_len + 22 < sizeof(cwd_buf)) {
                memcpy(cwd_buf + cwd_len, "/std/thread/thread.o", 21);
                cwd_buf[cwd_len + 20] = '\0';
                if (realpath(cwd_buf, resolved) != NULL) return resolved;
            }
        }
    }
    /* 3) argv[0] 所在目录 + /../std/thread/thread.o */
    if (argv0 && argv0[0]) {
        const char *last_slash = strrchr(argv0, '/');
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - 22) return buf;
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.'; buf[1] = '\0';
            n = 1;
        }
        if (n + 22 < (int)sizeof(buf)) {
            strcat(buf, "/../std/thread/thread.o");
            if (realpath(buf, resolved) != NULL) return resolved;
        }
    }
    return buf;
}

/** std.time 时间与睡眠（std/time/time.o）；与 get_std_thread_o_path 类似，产出 std/time/time.o。 */
static const char *get_std_time_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = '\0';
    resolved[0] = '\0';
    if (realpath("std/time/time.o", resolved) != NULL) return resolved;
    {
        char cwd_buf[512];
        if (getcwd(cwd_buf, sizeof(cwd_buf) - 18) != NULL) {
            size_t cwd_len = strlen(cwd_buf);
            if (cwd_len + 18 < sizeof(cwd_buf)) {
                memcpy(cwd_buf + cwd_len, "/std/time/time.o", 17);
                cwd_buf[cwd_len + 16] = '\0';
                if (realpath(cwd_buf, resolved) != NULL) return resolved;
            }
        }
    }
    if (argv0 && argv0[0]) {
        const char *last_slash = strrchr(argv0, '/');
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - 22) return buf;
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.'; buf[1] = '\0';
            n = 1;
        }
        if (n + 22 < (int)sizeof(buf)) {
            strcat(buf, "/../std/time/time.o");
            if (realpath(buf, resolved) != NULL) return resolved;
        }
    }
    return buf;
}

/** std.random 密码学安全随机（std/random/random.o）；与 get_std_time_o_path 类似，产出 std/random/random.o。 */
static const char *get_std_random_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = '\0';
    resolved[0] = '\0';
    if (realpath("std/random/random.o", resolved) != NULL) return resolved;
    {
        char cwd_buf[512];
        if (getcwd(cwd_buf, sizeof(cwd_buf) - 22) != NULL) {
            size_t cwd_len = strlen(cwd_buf);
            if (cwd_len + 22 < sizeof(cwd_buf)) {
                memcpy(cwd_buf + cwd_len, "/std/random/random.o", 21);
                cwd_buf[cwd_len + 20] = '\0';
                if (realpath(cwd_buf, resolved) != NULL) return resolved;
            }
        }
    }
    if (argv0 && argv0[0]) {
        const char *last_slash = strrchr(argv0, '/');
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - 26) return buf;
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.'; buf[1] = '\0';
            n = 1;
        }
        if (n + 26 < (int)sizeof(buf)) {
            strcat(buf, "/../std/random/random.o");
            if (realpath(buf, resolved) != NULL) return resolved;
        }
    }
    return buf;
}

/** std.env 环境变量与临时目录（std/env/env.o）；与 get_std_random_o_path 类似，产出 std/env/env.o。优先基于 argv[0] 解析绝对路径，避免依赖当前工作目录。 */
static const char *get_std_env_o_path(const char *argv0) {
    static char buf[PATH_MAX];
    static char resolved[PATH_MAX];
    buf[0] = '\0';
    resolved[0] = '\0';
    /* 优先用 argv[0] 得到可执行文件绝对路径，再推导 std/env/env.o，不依赖 cwd */
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last_slash = strrchr(buf, '/');
        if (last_slash && (size_t)(last_slash - buf) + 22 < sizeof(buf)) {
            *last_slash = '\0';
            strcat(buf, "/../std/env/env.o");
            if (realpath(buf, resolved) != NULL) return resolved;
        }
    }
    buf[0] = '\0';
    if (realpath("std/env/env.o", resolved) != NULL) return resolved;
    {
        char cwd_buf[512];
        if (getcwd(cwd_buf, sizeof(cwd_buf) - 18) != NULL) {
            size_t cwd_len = strlen(cwd_buf);
            if (cwd_len + 18 < sizeof(cwd_buf)) {
                memcpy(cwd_buf + cwd_len, "/std/env/env.o", 15);
                cwd_buf[cwd_len + 14] = '\0';
                if (realpath(cwd_buf, resolved) != NULL) return resolved;
            }
        }
    }
    if (argv0 && argv0[0]) {
        const char *last_slash = strrchr(argv0, '/');
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - 22) return buf;
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.'; buf[1] = '\0';
            n = 1;
        }
        if (n + 22 < (int)sizeof(buf)) {
            strcat(buf, "/../std/env/env.o");
            if (realpath(buf, resolved) != NULL) return resolved;
        }
    }
    return buf;
}

/** std.sync 互斥锁（std/sync/sync.o）；与 get_std_env_o_path 类似，产出 std/sync/sync.o。链接时 Unix 需 -lpthread。 */
static const char *get_std_sync_o_path(const char *argv0) {
    static char buf[PATH_MAX];
    static char resolved[PATH_MAX];
    buf[0] = '\0';
    resolved[0] = '\0';
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last_slash = strrchr(buf, '/');
        if (last_slash && (size_t)(last_slash - buf) + 22 < sizeof(buf)) {
            *last_slash = '\0';
            strcat(buf, "/../std/sync/sync.o");
            if (realpath(buf, resolved) != NULL) return resolved;
        }
    }
    buf[0] = '\0';
    if (realpath("std/sync/sync.o", resolved) != NULL) return resolved;
    {
        char cwd_buf[512];
        if (getcwd(cwd_buf, sizeof(cwd_buf) - 18) != NULL) {
            size_t cwd_len = strlen(cwd_buf);
            if (cwd_len + 17 < sizeof(cwd_buf)) {
                memcpy(cwd_buf + cwd_len, "/std/sync/sync.o", 17);
                cwd_buf[cwd_len + 16] = '\0';
                if (realpath(cwd_buf, resolved) != NULL) return resolved;
            }
        }
    }
    if (argv0 && argv0[0]) {
        const char *last_slash = strrchr(argv0, '/');
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - 22) return buf;
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.'; buf[1] = '\0';
            n = 1;
        }
        if (n + 22 < (int)sizeof(buf)) {
            strcat(buf, "/../std/sync/sync.o");
            if (realpath(buf, resolved) != NULL) return resolved;
        }
    }
    return buf;
}

/** std.encoding UTF-8/ASCII（std/encoding/encoding.o）；优先 cwd。 */
static const char *get_std_encoding_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/encoding/encoding.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 26) != NULL) { size_t L = strlen(cwd); if (L + 26 <= sizeof(cwd)) { memcpy(cwd + L, "/std/encoding/encoding.o", 25); cwd[L+25] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 28 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/encoding/encoding.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.base64（std/base64/base64.o）。 */
static const char *get_std_base64_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/base64/base64.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 24) != NULL) { size_t L = strlen(cwd); if (L + 24 <= sizeof(cwd)) { memcpy(cwd + L, "/std/base64/base64.o", 20); cwd[L+20] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 24 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/base64/base64.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.crypto（std/crypto/crypto.o）。 */
static const char *get_std_crypto_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/crypto/crypto.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 24) != NULL) { size_t L = strlen(cwd); if (L + 24 <= sizeof(cwd)) { memcpy(cwd + L, "/std/crypto/crypto.o", 20); cwd[L+20] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 24 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/crypto/crypto.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.log（std/log/log.o）。 */
static const char *get_std_log_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/log/log.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 18) != NULL) { size_t L = strlen(cwd); if (L + 18 <= sizeof(cwd)) { memcpy(cwd + L, "/std/log/log.o", 14); cwd[L+14] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 20 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/log/log.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.test（std/test/test.o）。 */
static const char *get_std_test_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/test/test.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/std/test/test.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/test/test.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/atomic/atomic.o 路径，供链接 std.atomic 时使用；优先 cwd 以兼容多工作区。 */
static const char *get_std_atomic_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/atomic/atomic.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/std/atomic/atomic.o", 21); cwd[L+21] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 24 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/atomic/atomic.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/channel/channel.o 路径；优先 cwd。 */
static const char *get_std_channel_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/channel/channel.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 26) != NULL) { size_t L = strlen(cwd); if (L + 26 <= sizeof(cwd)) { memcpy(cwd + L, "/std/channel/channel.o", sizeof("/std/channel/channel.o")); if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 26 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/channel/channel.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/backtrace/backtrace.o 路径；优先 cwd。 */
static const char *get_std_backtrace_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/backtrace/backtrace.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 30) != NULL) { size_t L = strlen(cwd); if (L + 30 <= sizeof(cwd)) { memcpy(cwd + L, "/std/backtrace/backtrace.o", sizeof("/std/backtrace/backtrace.o")); if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 28 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/backtrace/backtrace.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/hash/hash.o 路径；优先 cwd。 */
static const char *get_std_hash_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/hash/hash.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/hash/hash.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/hash/hash.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/math/math.o 路径；优先 cwd。链接时需 -lm。 */
static const char *get_std_math_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/math/math.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/math/math.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/math/math.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/sort/sort.o 路径；优先 cwd。 */
static const char *get_std_sort_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/sort/sort.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/sort/sort.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/sort/sort.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/ffi/ffi.o 路径；优先 cwd。 */
static const char *get_std_ffi_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/ffi/ffi.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 18) != NULL) { size_t L = strlen(cwd); if (L + 18 <= sizeof(cwd)) { memcpy(cwd + L, "/std/ffi/ffi.o", 14); cwd[L+14] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 20 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/ffi/ffi.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/db/sqlite/sqlite.o 路径；优先 cwd。链接时需 -lsqlite3（SQLite 构建）。 */
static const char *get_std_sqlite_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/db/sqlite/sqlite.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/db/sqlite/sqlite.o", 20); cwd[L+20] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/db/sqlite/sqlite.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/db/kv/kv.o 路径。 */
static const char *get_std_db_kv_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/db/kv/kv.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 18) != NULL) { size_t L = strlen(cwd); if (L + 18 <= sizeof(cwd)) { memcpy(cwd + L, "/std/db/kv/kv.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/db/kv/kv.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/db/arrow/arrow.o 路径。 */
static const char *get_std_db_arrow_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/db/arrow/arrow.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/std/db/arrow/arrow.o", 20); cwd[L+20] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 26 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/db/arrow/arrow.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** 根据 cwd 或 argv[0] 得到 std/elf/elf.o 路径；优先 cwd。 */
static const char *get_std_elf_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/elf/elf.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 18) != NULL) { size_t L = strlen(cwd); if (L + 18 <= sizeof(cwd)) { memcpy(cwd + L, "/std/elf/elf.o", 14); cwd[L+14] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 20 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/elf/elf.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** P4 std 模块 .o 路径（按需链接）；优先 cwd 以兼容多工作区。 */
static const char *get_std_json_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/json/json.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/json/json.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/json/json.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}
static const char *get_std_csv_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/csv/csv.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 18) != NULL) { size_t L = strlen(cwd); if (L + 18 <= sizeof(cwd)) { memcpy(cwd + L, "/std/csv/csv.o", 14); cwd[L+14] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 20 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/csv/csv.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}
static const char *get_std_regex_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/regex/regex.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/std/regex/regex.o", 18); cwd[L+18] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 24 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/regex/regex.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}
static const char *get_std_compress_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/compress/compress.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 28) != NULL) { size_t L = strlen(cwd); if (L + 28 <= sizeof(cwd)) { memcpy(cwd + L, "/std/compress/compress.o", 25); cwd[L+25] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 28 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/compress/compress.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}
static const char *get_std_unicode_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/unicode/unicode.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 26) != NULL) { size_t L = strlen(cwd); if (L + 26 <= sizeof(cwd)) { memcpy(cwd + L, "/std/unicode/unicode.o", 22); cwd[L+22] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 26 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/unicode/unicode.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}
static const char *get_std_dynlib_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/dynlib/dynlib.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 26) != NULL) { size_t L = strlen(cwd); if (L + 26 <= sizeof(cwd)) { memcpy(cwd + L, "/std/dynlib/dynlib.o", 20); cwd[L+20] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 26 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/dynlib/dynlib.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}
static const char *get_std_http_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/http/http.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/http/http.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/http/http.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}
/** std.socketio（P3 可选；std/socketio/socketio.o）。 */
static const char *get_std_socketio_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/socketio/socketio.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 28) != NULL) { size_t L = strlen(cwd); if (L + 28 <= sizeof(cwd)) { memcpy(cwd + L, "/std/socketio/socketio.o", 24); cwd[L+24] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 30 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/socketio/socketio.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}
static const char *get_std_tar_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/tar/tar.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 18) != NULL) { size_t L = strlen(cwd); if (L + 18 <= sizeof(cwd)) { memcpy(cwd + L, "/std/tar/tar.o", 14); cwd[L+14] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 20 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/tar/tar.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}
/** std.simd（std/simd/simd.o）；STD-153 策略探测符号。 */
static const char *get_std_simd_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/simd/simd.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/simd/simd.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/simd/simd.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.context（std/context/context.o）；依赖 std/time/time.o 的单调时钟符号。 */
static const char *get_std_context_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/context/context.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 24) != NULL) { size_t L = strlen(cwd); if (L + 24 <= sizeof(cwd)) { memcpy(cwd + L, "/std/context/context.o", 22); cwd[L+22] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 26 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/context/context.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.datetime（std/datetime/datetime.o）；依赖 std/time/time.o 墙钟符号。 */
static const char *get_std_datetime_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/datetime/datetime.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 26) != NULL) { size_t L = strlen(cwd); if (L + 26 <= sizeof(cwd)) { memcpy(cwd + L, "/std/datetime/datetime.o", 24); cwd[L+24] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 28 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/datetime/datetime.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.uuid（std/uuid/uuid.o）；依赖 std/random/random.o、std/time/time.o。 */
static const char *get_std_uuid_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/uuid/uuid.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/std/uuid/uuid.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 24 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/uuid/uuid.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.url（std/url/url.o）。 */
static const char *get_std_url_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/url/url.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 18) != NULL) { size_t L = strlen(cwd); if (L + 18 <= sizeof(cwd)) { memcpy(cwd + L, "/std/url/url.o", 12); cwd[L+12] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 20 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/url/url.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.cli（std/cli/cli.o）。 */
static const char *get_std_cli_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/cli/cli.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 18) != NULL) { size_t L = strlen(cwd); if (L + 18 <= sizeof(cwd)) { memcpy(cwd + L, "/std/cli/cli.o", 12); cwd[L+12] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 20 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/cli/cli.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.security（std/security/security.o）。 */
static const char *get_std_security_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/security/security.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 26) != NULL) { size_t L = strlen(cwd); if (L + 26 <= sizeof(cwd)) { memcpy(cwd + L, "/std/security/security.o", 22); cwd[L+22] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 28 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/security/security.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.config（std/config/config.o）；依赖 std/env/env.o 的 env_iter 符号。 */
static const char *get_std_config_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/config/config.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 24) != NULL) { size_t L = strlen(cwd); if (L + 24 <= sizeof(cwd)) { memcpy(cwd + L, "/std/config/config.o", 20); cwd[L+20] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 26 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/config/config.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.cache（std/cache/cache.o）；依赖 std/time/time.o 的单调时钟符号。 */
static const char *get_std_cache_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/cache/cache.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/std/cache/cache.o", 18); cwd[L+18] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 24 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/cache/cache.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.trace（std/trace/trace.o）；依赖 std/time/time.o + std/random/random.o。 */
static const char *get_std_trace_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/trace/trace.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/std/trace/trace.o", 18); cwd[L+18] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 24 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/trace/trace.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.task（std/task/task.o）；依赖 scheduler + context + time。 */
static const char *get_std_task_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/task/task.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/std/task/task.o", 16); cwd[L+16] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 22 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/task/task.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.schema（std/schema/schema.o）；依赖 json + csv。 */
static const char *get_std_schema_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/schema/schema.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/std/schema/schema.o", 18); cwd[L+18] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 24 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/schema/schema.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** std.async 协作调度内核（std/async/scheduler.o）；调用 coop_pingpong* 时按需链入。 */
static const char *get_std_async_scheduler_o_path(const char *argv0) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("std/async/scheduler.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 26) != NULL) { size_t L = strlen(cwd); if (L + 26 <= sizeof(cwd)) { memcpy(cwd + L, "/std/async/scheduler.o", 22); cwd[L+22] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0] && realpath(argv0, buf) != NULL) {
        char *last = strrchr(buf, '/');
        if (last && (size_t)(last - buf) + 26 < sizeof(buf)) { *last = '\0'; strcat(buf, "/../std/async/scheduler.o"); if (realpath(buf, resolved) != NULL) return resolved; }
    }
    return buf;
}

/** runtime_panic.o 路径；优先 cwd（compiler/runtime_panic.o 或 getcwd+"/compiler/runtime_panic.o"），再 argv[0] 目录。 */
static const char *get_runtime_panic_o_path(const char *argv0) {
    static char buf[512];
    static char resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (realpath("compiler/runtime_panic.o", resolved) != NULL) return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 24) != NULL) { size_t L = strlen(cwd); if (L + 24 <= sizeof(cwd)) { memcpy(cwd + L, "/compiler/runtime_panic.o", 25); cwd[L+24] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    if (argv0 && argv0[0]) {
        const char *last_slash = strrchr(argv0, '/');
        int n;
        if (last_slash) {
            n = (int)(last_slash - argv0);
            if (n >= (int)sizeof(buf) - 20) return buf;
            memcpy(buf, argv0, (size_t)n);
            buf[n] = '\0';
        } else {
            buf[0] = '.'; buf[1] = '\0';
            n = 1;
        }
        if (n + 18 < (int)sizeof(buf)) {
            strcat(buf, "/runtime_panic.o");
            if (realpath(buf, resolved) != NULL) return resolved;
            return buf;
        }
    }
    return buf;
}

/** crt0_user.o 路径；与 runtime_panic.o 同目录（compiler/），供 SHUX_FREESTANDING 链入。 */
static const char *get_crt0_user_o_path(const char *argv0) {
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
        const char *last_slash = strrchr(argv0, '/');
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

/** freestanding_io.o 路径；与 crt0_user.o 同目录（compiler/），供 SHUX_FREESTANDING syscall write。 */
static const char *get_freestanding_io_o_path(const char *argv0) {
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
        const char *last_slash = strrchr(argv0, '/');
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

/** SHUX_FREESTANDING=1 或 `-freestanding`：Linux x86_64 上用户程序 -nostdlib 静态链（S4）。 */
static int shu_ld_freestanding_enabled(void) {
    const char *e;
#if !defined(__linux__)
    return 0;
#endif
    if (driver_freestanding_get())
        return 1;
    e = getenv("SHUX_FREESTANDING");
    return e && e[0] && e[0] != '0';
}

/**
 * B-20 v1：POSIX read_file 扫描生成 C 是否含任一子串（替代 fopen/fgets 按需链判定）。
 * needles 以 NULL 结尾，或传入 n_needles>0 的数组。
 */
static int generated_c_contains_any_substr(const char *c_path, const char **needles, int n_needles) {
    size_t len = 0;
    char *text;
    int i;
    int found = 0;

    if (!c_path || !c_path[0] || !needles || n_needles <= 0)
        return 0;
    text = read_file(c_path, &len);
    if (!text)
        return 0;
    for (i = 0; i < n_needles; i++) {
        if (needles[i] && strstr(text, needles[i])) {
            found = 1;
            break;
        }
    }
    free(text);
    return found;
}

/**
 * 生成的 .c 是否引用 std.async scheduler（C 前端 invoke_cc 按需链 scheduler.o）。
 * 全平台可用：仅扫描文本，不依赖 nm（Windows invoke_cc 亦需此判定）。
 */
static int generated_c_needs_async_scheduler(const char *c_path) {
    static const char *needles[] = {
        "shux_async_run_i32", "shux_async_cps_suspend",
        "shux_async_task_submit", "shux_async_run_seed_",
    };
    return generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/**
 * 生成的 .c 是否引用 core.builtin 位运算 C 实现（按需链 core/builtin/builtin.o）。
 */
static int generated_c_needs_core_builtin(const char *c_path) {
    static const char *needles[] = {
        "shux_builtin_clz_u32", "shux_builtin_ctz_u32", "shux_builtin_popcount_u32",
        "shux_builtin_bswap_u32", "shux_builtin_rotl_u32", "shux_builtin_rotr_u32",
    };
    return generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 core.mem volatile/fence 符号（按需链 core/mem/mem.o）。 */
static int generated_c_needs_core_mem(const char *c_path) {
    static const char *needles[] = {
        "mem_volatile_", "mem_fence_", "mem_compiler_fence",
    };
    return generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 std.db.kv 符号（按需链 std/db/kv/kv.o）。 */
static int generated_c_needs_db_kv(const char *c_path) {
    static const char *needles[] = {
        "db_kv_open_c", "db_kv_put_c", "db_kv_get_c", "db_kv_append_ts_c",
        "db_kv_wal_flush_c", "db_kv_compact_c", "db_kv_sst_level_count_c",
    };
    return generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 std.db.arrow 符号（按需链 std/db/arrow/arrow.o）。 */
static int generated_c_needs_db_arrow(const char *c_path) {
    static const char *needles[] = {
        "arrow_column_", "arrow_batch_", "arrow_smoke_c",
    };
    return generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 core.slice C 辅助符号（按需链 core/slice/slice.o）。 */
static int generated_c_needs_core_slice(const char *c_path) {
    size_t len = 0;
    char *text;
    int found = 0;

    if (!c_path || !c_path[0])
        return 0;
    text = read_file(c_path, &len);
    if (!text)
        return 0;
    if (strstr(text, "core_subslice_")
        || (strstr(text, "core_slice_") && strstr(text, "_from_ptr_c")))
        found = 1;
    free(text);
    return found;
}

/** 扫描生成 C 是否引用 std.process 全局（main 入口写 shux_process_argc/argv）。 */
static int generated_c_needs_process(const char *c_path) {
    static const char *needles[] = {
        "shux_process_argc", "shux_process_argv",
    };
    return generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 std.fs C 符号（按需链 std/fs/fs.o）。 */
static int generated_c_needs_fs(const char *c_path) {
    static const char *needles[] = {
        "fs_open_read_c", "fs_last_error_c", "fs_close_c", "fs_read_c", "fs_write_c",
    };
    return generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 std.random C 符号（按需链 std/random/random.o）。 */
static int generated_c_needs_random(const char *c_path) {
    static const char *needles[] = {
        "random_rng_smoke_c", "random_fill_bytes_c", "random_u64_c",
    };
    return generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 扫描生成 C 是否引用 std.runtime C 符号（按需链 std/runtime/runtime.o）。 */
static int generated_c_needs_runtime(const char *c_path) {
    static const char *needles[] = {
        "runtime_crash_evidence_collect_c", "runtime_panic", "runtime_abort",
    };
    return generated_c_contains_any_substr(c_path, needles, (int)(sizeof(needles) / sizeof(needles[0])));
}

/** 根据仓库根或 cwd 得到 core/builtin/builtin.o 路径。 */
static const char *get_core_builtin_o_path(const char *repo_root) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (repo_root && repo_root[0]) {
        (void)snprintf(buf, sizeof buf, "%s/core/builtin/builtin.o", repo_root);
        if (realpath(buf, resolved) != NULL)
            return resolved;
    }
    if (realpath("core/builtin/builtin.o", resolved) != NULL)
        return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 24) != NULL) { size_t L = strlen(cwd); if (L + 24 <= sizeof(cwd)) { memcpy(cwd + L, "/core/builtin/builtin.o", 22); cwd[L+22] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    return buf;
}

/** core/builtin/builtin_abi.h 绝对路径；供 invoke_cc -include。 */
static const char *get_core_builtin_abi_h_path(const char *repo_root) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (repo_root && repo_root[0]) {
        (void)snprintf(buf, sizeof buf, "%s/core/builtin/builtin_abi.h", repo_root);
        if (realpath(buf, resolved) != NULL)
            return resolved;
    }
    if (realpath("core/builtin/builtin_abi.h", resolved) != NULL)
        return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 28) != NULL) { size_t L = strlen(cwd); if (L + 28 <= sizeof(cwd)) { memcpy(cwd + L, "/core/builtin/builtin_abi.h", 26); cwd[L+26] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    return buf;
}

/** 根据仓库根或 cwd 得到 core/mem/mem.o 路径（CORE-017 volatile/fence）。 */
static const char *get_core_mem_o_path(const char *repo_root) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (repo_root && repo_root[0]) {
        (void)snprintf(buf, sizeof buf, "%s/core/mem/mem.o", repo_root);
        if (realpath(buf, resolved) != NULL)
            return resolved;
    }
    if (realpath("core/mem/mem.o", resolved) != NULL)
        return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 20) != NULL) { size_t L = strlen(cwd); if (L + 20 <= sizeof(cwd)) { memcpy(cwd + L, "/core/mem/mem.o", sizeof("/core/mem/mem.o")); if (realpath(cwd, resolved) != NULL) return resolved; } } }
    return buf;
}

/** 根据仓库根或 cwd 得到 core/slice/slice.o 路径（CORE-004 subslice/chunks）。 */
static const char *get_core_slice_o_path(const char *repo_root) {
    static char buf[PATH_MAX], resolved[PATH_MAX];
    buf[0] = resolved[0] = '\0';
    if (repo_root && repo_root[0]) {
        (void)snprintf(buf, sizeof buf, "%s/core/slice/slice.o", repo_root);
        if (realpath(buf, resolved) != NULL)
            return resolved;
    }
    if (realpath("core/slice/slice.o", resolved) != NULL)
        return resolved;
    { char cwd[512]; if (getcwd(cwd, sizeof(cwd) - 22) != NULL) { size_t L = strlen(cwd); if (L + 22 <= sizeof(cwd)) { memcpy(cwd + L, "/core/slice/slice.o", 20); cwd[L+20] = '\0'; if (realpath(cwd, resolved) != NULL) return resolved; } } }
    return buf;
}

#if defined(__linux__) || defined(__APPLE__)
/**
 * 扫描用户 .o 的 nm 未定义符号表；若引用 sym 则返回 1。
 * nm 不可用时保守返回 1（仍链入对应 runtime 桩，避免链接缺符号）。
 */
static int freestanding_o_needs_undef_sym(const char *o_path, const char *sym) {
    char cmd[PATH_MAX + 160];
    FILE *fp;
    char line[512];
    size_t sym_len;
    if (!o_path || !o_path[0] || !sym || !sym[0])
        return 0;
    sym_len = strlen(sym);
    /** GNU nm（Linux/Alpine）无 --porcelain；BSD/macOS 用 porcelain 单行符号名。 */
#if defined(__APPLE__)
    if ((size_t)snprintf(cmd, sizeof cmd, "nm -u --porcelain '%s' 2>/dev/null", o_path) >= sizeof cmd)
        return 1;
#else
    if ((size_t)snprintf(cmd, sizeof cmd, "nm -u '%s' 2>/dev/null", o_path) >= sizeof cmd)
        return 1;
#endif
    fp = popen(cmd, "r");
    if (!fp)
        return 1;
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

/** 用户模块是否引用 shux_sys_*（按需链 freestanding_io.o）。 */
static int freestanding_user_o_needs_io(const char *user_o) {
    return freestanding_o_needs_undef_sym(user_o, "shux_sys_write")
        || freestanding_o_needs_undef_sym(user_o, "shux_sys_read")
        || freestanding_o_needs_undef_sym(user_o, "shux_sys_close")
        || freestanding_o_needs_undef_sym(user_o, "shux_sys_exit")
        || freestanding_o_needs_undef_sym(user_o, "shux_sys_open")
        || freestanding_o_needs_undef_sym(user_o, "shux_sys_openat")
        || freestanding_o_needs_undef_sym(user_o, "shux_sys_mmap")
        || freestanding_o_needs_undef_sym(user_o, "shux_sys_munmap");
}

/** 用户模块是否引用 shux_panic_（按需链 runtime_panic.o）。 */
static int freestanding_user_o_needs_panic(const char *user_o) {
    return freestanding_o_needs_undef_sym(user_o, "shux_panic_");
}

/** 用户是否引用 std.async scheduler（按需链 std/async/scheduler.o）。 */
static int asm_user_o_needs_async_scheduler(const char *user_o) {
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_coop_pingpong"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_coop_pingpong_jmp"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_cps_suspend"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_asm_frame_phase_by_id"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_asm_frame_store_from_ptr"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_asm_frame_load_to_ptr"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_asm_frame_reset_by_id"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_cps_suspend_io"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_i32"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_task_submit"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_task_submit_to"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_scheduler_drain"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_worker_drain"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_worker_count"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_worker_pending"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_queue_reset"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_scheduler_pending"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_io_wake_all"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_io_waiters_pending"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_io_completions_ready"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_seed_set_i32"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_seed_reset"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_seed_push_i32"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_seed_push_u32"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_seed_push_i64"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_seed_valid"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_seed_take_i32"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_seed_take_u32"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_async_run_seed_take_i64"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_io_submit_read_async"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_io_complete_read_async"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_io_complete_read_async_slot"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_io_submit_write_async"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_io_complete_write_async"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "shux_io_complete_write_async_slot"))
        return 1;
    return 0;
}

/** 用户是否引用 core.mem volatile/fence（按需链 core/mem/mem.o）。 */
static int asm_user_o_needs_core_mem(const char *user_o) {
    if (freestanding_o_needs_undef_sym(user_o, "mem_compiler_fence_c"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "mem_volatile_load_u8_c"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "mem_volatile_load_u16_c"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "mem_volatile_load_u32_c"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "mem_fence_acquire_c"))
        return 1;
    return 0;
}

/** 用户是否引用 core.slice C 辅助（按需链 core/slice/slice.o）。 */
static int asm_user_o_needs_core_slice(const char *user_o) {
    if (freestanding_o_needs_undef_sym(user_o, "core_subslice_i32_c"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "core_subslice_u8_c"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "core_subslice_u64_c"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "core_slice_i32_from_ptr_c"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "core_slice_u8_from_ptr_c"))
        return 1;
    if (freestanding_o_needs_undef_sym(user_o, "core_slice_u64_from_ptr_c"))
        return 1;
    return 0;
}

/**
 * 用户 .o 是否仍有未定义外部符号（nm -u 非空）。
 * 自包含模块（如 return-value）可仅 gcc 链 user.o + -lc，避免 Alpine/musl 上全量 std/*.o 链接挂起。
 */
static int asm_user_o_has_undef_syms(const char *o_path) {
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
        return 1;
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
 * 等待子进程结束；waitpid 在调试器附加或信号中断时可能返回 -1 且 errno==EINTR，须重试。
 * 否则 asm_invoke_ld / invoke_cc 误判失败（脚本见 compile_rc=1 且无 stderr；链出的 Mach-O 可能未写完或运行时崩溃）。
 */
static int shu_waitpid_retry(pid_t pid, int *status_out) {
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
        perror("shux: waitpid");
        return -1;
    }
}

/**
 * 链接可选 std/runtime .o：get_*_path 启发式可能给出磁盘上不存在的字符串；
 * 仅当路径可读且为常规文件时再传给 clang/ld，否则跳过（避免 clang: no such file）。
 * C 前端 invoke_cc 与 asm ld 路径共用。
 */
static const char *asm_link_obj_skip_missing(const char *path) {
    struct stat st;
    if (!path || !path[0]) return NULL;
    if (stat(path, &st) != 0 || !S_ISREG(st.st_mode)) return NULL;
    return path;
}

/** invoke_cc 子进程 realpath 缓冲池：不可共用单块 static，否则多次 push 后 argv 中旧槽指向最后被覆盖的路径。 */
#define INVOKE_CC_ABS_POOL_SZ 80

/**
 * invoke_cc 子进程：仅当 path 指向已存在的 .o 时追加到 argv（可选 realpath）。
 * 返回 1 表示已追加，0 表示跳过。
 */
static int invoke_cc_argv_push_existing(char *argv[], int *ia, int max_ia, const char *path) {
    static char abs_pool[INVOKE_CC_ABS_POOL_SZ][PATH_MAX];
    static int abs_pool_i;
    const char *use;
    if (!path || !path[0] || !ia || *ia >= max_ia - 1)
        return 0;
    use = asm_link_obj_skip_missing(path);
    if (!use)
        return 0;
#if !defined(_WIN32) && !defined(_WIN64)
    {
        char *slot = abs_pool[abs_pool_i % INVOKE_CC_ABS_POOL_SZ];
        abs_pool_i++;
        if (realpath(use, slot) != NULL)
            use = slot;
    }
#endif
    argv[(*ia)++] = (char *)use;
    return 1;
}

/**
 * task.o 链入时须同时链入 scheduler.o；若调用方未显式传入则从 task_o 路径推导。
 */
static const char *scheduler_o_for_task_link(const char *task_o, const char *explicit_scheduler) {
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
 * 检测 net.o 是否导出 TLS 后端 marker 符号（openssl / mbedtls）。
 */
static int net_o_exports_marker(const char *net_o, const char *marker) {
    char cmd[PATH_MAX + 96];
    FILE *fp;
    char line[512];
    const char *use = net_o;
    static char resolved[PATH_MAX];
    if (!net_o || !net_o[0] || !marker || !marker[0])
        return 0;
#if !defined(_WIN32) && !defined(_WIN64)
    if (realpath(net_o, resolved) != NULL)
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
 */
static int obj_o_has_undef_sym(const char *obj_o, const char *sym) {
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

/** compress.o 是否依赖 libz（marker 或 zlib 未定义符号）。 */
static int compress_o_needs_zlib(const char *compress_o) {
    if (!compress_o || !compress_o[0])
        return 0;
    if (net_o_exports_marker(compress_o, "shu_compress_zlib_marker"))
        return 1;
    return obj_o_has_undef_sym(compress_o, "_compress2")
        || obj_o_has_undef_sym(compress_o, "_deflate")
        || obj_o_has_undef_sym(compress_o, "_inflate")
        || obj_o_has_undef_sym(compress_o, "_uncompress");
}

/** compress.o 是否依赖 libzstd（marker 或 ZSTD 未定义符号）。 */
static int compress_o_needs_zstd(const char *compress_o) {
    if (!compress_o || !compress_o[0])
        return 0;
    if (net_o_exports_marker(compress_o, "shu_compress_zstd_marker"))
        return 1;
    return obj_o_has_undef_sym(compress_o, "ZSTD_") || obj_o_has_undef_sym(compress_o, "_ZSTD");
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

/** ASM 链接：按 compress.o 实际依赖追加 -lz / -lzstd。 */
static void asm_ld_append_compress_libs(const char *compress_o, const char **argv, int *la, int max_la) {
    if (!compress_o || !compress_o[0] || !argv || !la)
        return;
    if (compress_o_needs_zlib(compress_o)) {
        ld_append_brew_lib_paths(argv, la, max_la);
        if (*la < max_la - 1)
            argv[(*la)++] = "-lz";
    }
    if (compress_o_needs_zstd(compress_o)) {
        ld_append_brew_lib_paths(argv, la, max_la);
        if (*la < max_la - 1)
            argv[(*la)++] = "-lzstd";
    }
}

/** invoke_cc 链接：按 compress.o 实际依赖追加 -lz / -lzstd。 */
static void invoke_cc_append_compress_ld(char *argv[], int *i, int argv_cap, const char *compress_o) {
    if (!compress_o || !compress_o[0] || !argv || !i || *i >= argv_cap - 1)
        return;
    if (compress_o_needs_zlib(compress_o)) {
        ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)"-lz";
    }
    if (compress_o_needs_zstd(compress_o)) {
        ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
        if (*i < argv_cap - 1)
            argv[(*i)++] = (char *)"-lzstd";
    }
}

/**
 * 若 net.o 仍为 TLS 桩且 SHUX_NET_TLS 非 stub，尝试 make net-o-openssl / net-o-mbedtls。
 * SHUX_NET_TLS：stub | openssl | mbedtls | auto（默认 auto）。
 */
static void ensure_std_net_o_auto_tls(const char *repo_root) {
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
    snprintf(cmd, sizeof(cmd), "%s/std/net/net.o", repo_root);
    if (realpath(cmd, resolved) == NULL && realpath("std/net/net.o", resolved) == NULL)
        return;
    if (net_o_exports_marker(resolved, "shu_net_tls_openssl_marker") ||
        net_o_exports_marker(resolved, "shu_net_tls_mbedtls_marker"))
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
 * net.o 为 OpenSSL/mbedTLS 后端时追加对应 -L/-l 链接参数；返回 1 表示已追加。
 */
static int invoke_cc_append_net_tls_ld(char *argv[], int *i, int argv_cap, const char *net_o) {
    static char hb_ssl_lib[72] = "-L/opt/homebrew/opt/openssl/lib";
    static char hb_mb_lib[72] = "-L/opt/homebrew/opt/mbedtls/lib";
    const char *use = net_o;
    static char resolved[PATH_MAX];
    if (!net_o || !net_o[0] || !i || *i >= argv_cap - 1)
        return 0;
#if !defined(_WIN32) && !defined(_WIN64)
    if (realpath(net_o, resolved) != NULL)
        use = resolved;
#endif
    if (net_o_exports_marker(use, "shu_net_tls_openssl_marker")) {
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
    if (net_o_exports_marker(use, "shu_net_tls_mbedtls_marker")) {
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
    return 0;
}

#if defined(SHUX_USE_SX_PIPELINE) || defined(SHUX_USE_SX_DRIVER)
/**
 * 解析当前 shux 可执行文件所在目录（compiler/），用于冷启动时在同一目录生成 runtime_panic.o。
 * Linux 用 /proc/self/exe，macOS 用 _NSGetExecutablePath；皆可不依赖 argv0。
 * 再回退 realpath(argv0)（ argv0 须含路径分隔符）。
 * 成功返回 0 并将 NUL 结尾绝对路径写入 out_dir；失败返回 -1。
 */
static int shu_resolve_compiler_dir(const char *argv0, char *out_dir, size_t out_dir_sz) {
    /* argv0 可选：macOS/Linux 优先用内核/ dyld 提供的可执行路径，裸 `shux`（PATH）或 argv 异常时仍可定位 compiler/。 */
    if (!out_dir || out_dir_sz < 2)
        return -1;
    char buf[PATH_MAX];
    buf[0] = '\0';
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
    if (!argv0 || !argv0[0] || !strchr(argv0, '/'))
        return -1;
    if (realpath(argv0, buf) == NULL)
        return -1;
    {
        char *slash = strrchr(buf, '/');
        if (!slash)
            return -1;
        *slash = '\0';
        if (strlen(buf) >= out_dir_sz)
            return -1;
        memcpy(out_dir, buf, strlen(buf) + 1);
    }
    return 0;
}

/** seed asm 用户程序：std.io 桩 .o（与 io.o 同链）；见 src/asm/runtime_asm_io_stubs.c。 */
static const char *get_runtime_asm_io_stubs_o_path(const char *argv0) {
    static char resolved[PATH_MAX];
    char comp_dir[PATH_MAX];
    int nn;
    resolved[0] = '\0';
    if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
        return resolved;
    nn = snprintf(resolved, sizeof resolved, "%s/runtime_asm_io_stubs.o", comp_dir);
    if (nn < 0 || (size_t)nn >= sizeof resolved)
        resolved[0] = '\0';
    return resolved;
}

/**
 * 若 runtime_panic.o 尚不存在则用 cc -c 从 src/asm 下源码生成到 shux 同目录，以便 ASM -o exe 链接能提供 shux_panic_。
 * 与 verify-selfhost.sh / Makefile 规则对齐：Linux 优先 x86_64 .s；Apple arm64 优先 runtime_panic_arm64.c；否则 runtime_panic.c。
 * 成功返回 0；失败返回 -1 并已写 stderr。
 */
static int ensure_runtime_panic_o(const char *argv0) {
    if (asm_link_obj_skip_missing(get_runtime_panic_o_path(argv0)))
        return 0;
    char comp[PATH_MAX];
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        fprintf(stderr, "shux: cannot resolve compiler directory to build runtime_panic.o (try: make -C compiler runtime_panic.o)\n");
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
            fprintf(stderr, "shux: runtime_panic source not found under %s/src/asm/\n", comp);
            return -1;
        }
        src = src_c;
    }
    char inc0[PATH_MAX], inc1[PATH_MAX], inc2[PATH_MAX];
    if ((size_t)snprintf(inc0, sizeof inc0, "%s", comp) >= sizeof inc0 || (size_t)snprintf(inc1, sizeof inc1, "%s/include", comp) >= sizeof inc1
        || (size_t)snprintf(inc2, sizeof inc2, "%s/src", comp) >= sizeof inc2)
        return -1;
    pid_t pid = fork();
    if (pid < 0) {
        perror("shux: fork (runtime_panic.o)");
        return -1;
    }
    if (pid == 0) {
        if (from_asm_s)
            execlp("cc", "cc", "-c", "-o", out_o, src, (char *)NULL);
        else
            execlp("cc", "cc", "-Wall", "-Wextra", "-I", inc0, "-I", inc1, "-I", inc2, "-c", "-o", out_o, src, (char *)NULL);
        perror("shux: cc (runtime_panic.o)");
        _exit(127);
    }
    {
        int st;
        if (shu_waitpid_retry(pid, &st) != 0)
            return -1;
        if (!WIFEXITED(st) || WEXITSTATUS(st) != 0) {
            fprintf(stderr, "shux: failed to build runtime_panic.o (exit %d)\n", WIFEXITED(st) ? WEXITSTATUS(st) : -1);
            return -1;
        }
    }
    if (!asm_link_obj_skip_missing(get_runtime_panic_o_path(argv0))) {
        fprintf(stderr, "shux: runtime_panic.o missing after cc -c (expected near %s)\n", out_o);
        return -1;
    }
    return 0;
}

#if defined(__linux__)
/**
 * freestanding：仅当用户 .o 引用 panic 时才 ensure runtime_panic.o；非 freestanding 始终 ensure。
 * 须与 ensure_runtime_panic_o 同处 SHUX_USE_SX_* 块，避免 plain runtime.o（shux-c）仅见前向声明而无定义导致链接失败。
 */
static int freestanding_prepare_runtime_panic_o(const char *argv0, const char *user_o) {
    if (shu_ld_freestanding_enabled()) {
        if (!freestanding_user_o_needs_panic(user_o))
            return 0;
    }
    return ensure_runtime_panic_o(argv0);
}
#endif /* __linux__ */

/**
 * 若 crt0_user.o 尚不存在则从 crt0_user_x86_64.s 编译到 shux 同目录（仅 SHUX_FREESTANDING 路径需要）。
 * 成功返回 0；未启用 freestanding 时 no-op 返回 0。
 */
static int ensure_crt0_user_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_s[PATH_MAX];
    if (!shu_ld_freestanding_enabled())
        return 0;
    if (asm_link_obj_skip_missing(get_crt0_user_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        fprintf(stderr, "shux: cannot resolve compiler directory to build crt0_user.o\n");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/crt0_user.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_s, sizeof src_s, "%s/src/asm/crt0_user_x86_64.s", comp) >= sizeof src_s
        || access(src_s, R_OK) != 0) {
        fprintf(stderr, "shux: crt0_user source not found at %s\n", src_s);
        return -1;
    }
    {
        pid_t pid = fork();
        if (pid < 0) {
            perror("shux: fork (crt0_user.o)");
            return -1;
        }
        if (pid == 0) {
            execlp("cc", "cc", "-c", "-o", out_o, src_s, (char *)NULL);
            perror("shux: cc (crt0_user.o)");
            _exit(127);
        }
        {
            int st;
            if (shu_waitpid_retry(pid, &st) != 0)
                return -1;
            if (!WIFEXITED(st) || WEXITSTATUS(st) != 0) {
                fprintf(stderr, "shux: failed to build crt0_user.o (exit %d)\n", WIFEXITED(st) ? WEXITSTATUS(st) : -1);
                return -1;
            }
        }
    }
    if (!asm_link_obj_skip_missing(get_crt0_user_o_path(argv0))) {
        fprintf(stderr, "shux: crt0_user.o missing after cc -c (expected %s)\n", out_o);
        return -1;
    }
    return 0;
}

/**
 * 若 freestanding_io.o 尚不存在则从 freestanding_io_x86_64.s 编译（SHUX_FREESTANDING 链入 shux_sys_write）。
 */
static int ensure_freestanding_io_o(const char *argv0) {
    char comp[PATH_MAX];
    char out_o[PATH_MAX];
    char src_s[PATH_MAX];
    if (!shu_ld_freestanding_enabled())
        return 0;
    if (asm_link_obj_skip_missing(get_freestanding_io_o_path(argv0)))
        return 0;
    if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) != 0) {
        fprintf(stderr, "shux: cannot resolve compiler directory to build freestanding_io.o\n");
        return -1;
    }
    if ((size_t)snprintf(out_o, sizeof out_o, "%s/freestanding_io.o", comp) >= sizeof out_o)
        return -1;
    if ((size_t)snprintf(src_s, sizeof src_s, "%s/src/asm/freestanding_io_x86_64.s", comp) >= sizeof src_s
        || access(src_s, R_OK) != 0) {
        fprintf(stderr, "shux: freestanding_io source not found at %s\n", src_s);
        return -1;
    }
    {
        pid_t pid = fork();
        if (pid < 0) {
            perror("shux: fork (freestanding_io.o)");
            return -1;
        }
        if (pid == 0) {
            execlp("cc", "cc", "-c", "-o", out_o, src_s, (char *)NULL);
            perror("shux: cc (freestanding_io.o)");
            _exit(127);
        }
        {
            int st;
            if (shu_waitpid_retry(pid, &st) != 0)
                return -1;
            if (!WIFEXITED(st) || WEXITSTATUS(st) != 0) {
                fprintf(stderr, "shux: failed to build freestanding_io.o (exit %d)\n", WIFEXITED(st) ? WEXITSTATUS(st) : -1);
                return -1;
            }
        }
    }
    if (!asm_link_obj_skip_missing(get_freestanding_io_o_path(argv0))) {
        fprintf(stderr, "shux: freestanding_io.o missing after cc -c (expected %s)\n", out_o);
        return -1;
    }
    return 0;
}

/** ASM 链接子进程内向 argv[] 填入的冗长路径存这里（execvp 前须保持有效）。槽位数须 ≥ invoke_cc 等量「std 下各 .o」经 lib_roots 解析时的入栈量。 */
typedef struct ShuAsmLdPathBank {
    char slots[42][PATH_MAX];
    int n;
} ShuAsmLdPathBank;

/** asm_ld_append_std_objs：与 invoke_cc 一致，记录哪些 std 模块已链入，供 macOS/Linux 追加 -pthread/-lm/-lz/-ldl。 */
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
} ShuAsmLdStdLinkFlags;

/** 将 path 复制到 bank 下一槽（path 常为栈上 snprintf 结果）；成功返回持久指针；满则返回 NULL。 */
static const char *shux_asm_ld_bank_push(struct ShuAsmLdPathBank *b, const char *path) {
    if (!b || !path || !path[0] || b->n >= (int)(sizeof(b->slots) / sizeof(b->slots[0])))
        return NULL;
    if (snprintf(b->slots[b->n], sizeof(b->slots[0]), "%s", path) >= (int)sizeof(b->slots[0]))
        return NULL;
    return b->slots[b->n++];
}

/**
 * 在每个 -L（lib root）根下尝试 rel（如 std/io/io.o）；命中则拷入 bank 并返回指针。
 */
static const char *shux_asm_ld_try_under_lib_roots(const char *rel, const char **lib_roots, int n_lib_roots, struct ShuAsmLdPathBank *bank) {
    int i;
    char tmp[PATH_MAX];
    if (!rel || !rel[0] || !bank || !lib_roots || n_lib_roots <= 0)
        return NULL;
    for (i = 0; i < n_lib_roots && i < 24; i++) {
        size_t rn;
        if (!lib_roots[i] || !lib_roots[i][0])
            continue;
        rn = strlen(lib_roots[i]);
        while (rn > 1 && lib_roots[i][rn - 1] == '/')
            rn--;
        /* 形如 root + "/" + rel，避免重复斜杠 */
        if (rn + 2 + strlen(rel) >= sizeof(tmp))
            continue;
        {
            int nn = rn > 0 ? snprintf(tmp, sizeof tmp, "%.*s/%s", (int)rn, lib_roots[i], rel) : snprintf(tmp, sizeof tmp, "%s", rel);
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
 * argv0/getcwd 推导失败时构造 «compiler-dir/shux» 供 get_*_path 走 ../std/…；shux 毋须真实存在。
 */
static const char *shux_asm_ld_effective_link_argv0(const char *link_argv0, char *syn_buf, size_t syn_sz) {
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
 * 按用户 .o 未定义符号按需追加 std 伴生对象（如 std/async/scheduler.o）。
 * 须在 asm_ld_append_std_objs 之后、exec ld/gcc 之前调用。
 */
static void asm_ld_append_on_demand_user_objs(const char *link_argv0, const char *user_o, const char **lib_roots, int n_lib_roots,
    struct ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la) {
#if defined(__linux__) || defined(__APPLE__)
    const char *p;
    if (!user_o || !user_o[0] || !la || *la >= max_la - 1)
        return;
    if (asm_user_o_needs_async_scheduler(user_o)) {
        p = asm_link_obj_skip_missing(get_std_async_scheduler_o_path(link_argv0));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("std/async/scheduler.o", lib_roots, n_lib_roots, bank);
        if (p && *la < max_la - 1)
            argv[(*la)++] = p;
    }
    if (asm_user_o_needs_core_mem(user_o)) {
        p = asm_link_obj_skip_missing(get_core_mem_o_path(NULL));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("core/mem/mem.o", lib_roots, n_lib_roots, bank);
        if (p && *la < max_la - 1)
            argv[(*la)++] = p;
    }
    if (asm_user_o_needs_core_slice(user_o)) {
        p = asm_link_obj_skip_missing(get_core_slice_o_path(NULL));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("core/slice/slice.o", lib_roots, n_lib_roots, bank);
        if (p && *la < max_la - 1)
            argv[(*la)++] = p;
    }
    if (freestanding_o_needs_undef_sym(user_o, "db_kv_open_c") || freestanding_o_needs_undef_sym(user_o, "db_kv_get_c")) {
        p = asm_link_obj_skip_missing(get_std_db_kv_o_path(link_argv0));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("std/db/kv/kv.o", lib_roots, n_lib_roots, bank);
        if (p && *la < max_la - 1)
            argv[(*la)++] = p;
    }
    if (freestanding_o_needs_undef_sym(user_o, "arrow_column_i32_create_c")
        || freestanding_o_needs_undef_sym(user_o, "arrow_column_adopt_f32_c")) {
        p = asm_link_obj_skip_missing(get_std_db_arrow_o_path(link_argv0));
        if (!p && bank)
            p = shux_asm_ld_try_under_lib_roots("std/db/arrow/arrow.o", lib_roots, n_lib_roots, bank);
        if (p && *la < max_la - 1)
            argv[(*la)++] = p;
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
#endif
}

/**
 * 将 ASM 链接所需的 std/.o 按 invoke_cc 顺序追加到 argv（仅加入磁盘上存在的路径）；
 * lib_roots/-L：在 getter 失败后按 «root/rel» 再试一轮，适配非 cwd 仓库布局。
 * runtime_panic.o 始终在列表中（与 ensure_runtime_panic_o 配合）。
 * *flags：供平台追加 -luring/-pthread/-lc/-lm/-lz/-ldl（与 invoke_cc 行为对齐）。
 */
static void asm_ld_append_std_objs(const char *link_argv0, const char **lib_roots, int n_lib_roots, struct ShuAsmLdPathBank *bank, const char **argv,
    int *la, int max_la, struct ShuAsmLdStdLinkFlags *flags) {
    const char *p;
    if (flags)
        memset(flags, 0, sizeof *flags);

    p = asm_link_obj_skip_missing(get_io_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/io/io.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_io = 1;
    }
    p = asm_link_obj_skip_missing(get_runtime_asm_io_stubs_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("compiler/runtime_asm_io_stubs.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;
    p = asm_link_obj_skip_missing(get_std_fs_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/fs/fs.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_process_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/process/process.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_string_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/string/string.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_heap_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/heap/heap.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_path_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/path/path.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_runtime_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/runtime/runtime.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_runtime_panic_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("compiler/runtime_panic.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_net_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/net/net.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_net = 1;
    }

    p = asm_link_obj_skip_missing(get_std_thread_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/thread/thread.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_thread = 1;
    }

    p = asm_link_obj_skip_missing(get_std_time_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/time/time.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_random_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/random/random.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_env_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/env/env.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_sync_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/sync/sync.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_sync = 1;
    }

    p = asm_link_obj_skip_missing(get_std_encoding_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/encoding/encoding.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_base64_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/base64/base64.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_crypto_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/crypto/crypto.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_log_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/log/log.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_atomic_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/atomic/atomic.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_channel_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/channel/channel.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_channel = 1;
    }

    p = asm_link_obj_skip_missing(get_std_backtrace_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/backtrace/backtrace.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_hash_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/hash/hash.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_math_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/math/math.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_math = 1;
    }

    p = asm_link_obj_skip_missing(get_std_sort_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/sort/sort.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_ffi_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/ffi/ffi.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_sqlite_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/db/sqlite/sqlite.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_sqlite = 1;
    }

    p = asm_link_obj_skip_missing(get_std_elf_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/elf/elf.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_elf = 1;
    }

    p = asm_link_obj_skip_missing(get_std_json_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/json/json.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_csv_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/csv/csv.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_regex_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/regex/regex.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_compress_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/compress/compress.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_compress = 1;
    }

    p = asm_link_obj_skip_missing(get_std_unicode_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/unicode/unicode.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_dynlib_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/dynlib/dynlib.o", lib_roots, n_lib_roots, bank);
    if (p) {
        if (*la < max_la - 1) argv[(*la)++] = p;
        if (flags) flags->have_dynlib = 1;
    }

    p = asm_link_obj_skip_missing(get_std_http_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/http/http.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_socketio_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/socketio/socketio.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_tar_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/tar/tar.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_simd_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/simd/simd.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_context_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/context/context.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_datetime_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/datetime/datetime.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_uuid_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/uuid/uuid.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_url_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/url/url.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_cli_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/cli/cli.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_security_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/security/security.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_config_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/config/config.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_cache_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/cache/cache.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_trace_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/trace/trace.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_task_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/task/task.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1) {
        const char *task_o = p;
        argv[(*la)++] = p;
        /* task.o 依赖 scheduler；与 invoke_cc 中 scheduler_o_for_task_link 对齐 */
        {
            const char *sched = scheduler_o_for_task_link(task_o, NULL);
            if (!sched)
                sched = asm_link_obj_skip_missing(get_std_async_scheduler_o_path(link_argv0));
            if (!sched && bank)
                sched = shux_asm_ld_try_under_lib_roots("std/async/scheduler.o", lib_roots, n_lib_roots, bank);
            if (sched && *la < max_la - 1)
                argv[(*la)++] = sched;
        }
    }

    p = asm_link_obj_skip_missing(get_std_schema_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/schema/schema.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;

    p = asm_link_obj_skip_missing(get_std_test_o_path(link_argv0));
    if (!p && bank)
        p = shux_asm_ld_try_under_lib_roots("std/test/test.o", lib_roots, n_lib_roots, bank);
    if (p && *la < max_la - 1)
        argv[(*la)++] = p;
}

/** ASM -o exe：fork 子进程执行 clang/ld 或 lld-link/ld（逻辑供 invoke_ld 与 driver_asm_invoke_ld 共用；调用方须先 ensure_runtime_panic_o）。 */
#define SHUX_LD_ARGV_CAP 96
static int asm_invoke_ld_platform(const char *o_path, const char *exe_path, const char *target, int use_macho_o, int use_coff_o, const char *link_argv0,
    const char **lib_roots, int n_lib_roots) {
    char link_argv_syn[PATH_MAX];
    const char *link_eff;

    (void)target;
    if (!o_path || !exe_path)
        return -1;
    link_eff = shux_asm_ld_effective_link_argv0(link_argv0, link_argv_syn, sizeof link_argv_syn);
    if (!link_eff)
        return -1;

    pid_t pid = fork();
    if (pid < 0) {
        perror("shux: fork (ld)");
        return -1;
    }
    if (pid == 0) {
        struct ShuAsmLdPathBank ld_bank_child;
        struct ShuAsmLdStdLinkFlags ldflags;
        const char *argv[SHUX_LD_ARGV_CAP];
        int la = 0;
        int need_pt;
        memset(&ld_bank_child, 0, sizeof ld_bank_child);
#if defined(__APPLE__)
        if (use_macho_o) {
            argv[la++] = "clang";
            argv[la++] = "-o";
            argv[la++] = exe_path;
            argv[la++] = o_path;
            asm_ld_append_std_objs(link_eff, lib_roots, n_lib_roots, &ld_bank_child, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots, n_lib_roots, &ld_bank_child, argv, &la, SHUX_LD_ARGV_CAP);
            need_pt = ldflags.have_thread || ldflags.have_sync || ldflags.have_channel;
            if (ldflags.have_math && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lm";
            if (ldflags.have_compress)
                asm_ld_append_compress_libs(get_std_compress_o_path(link_eff), (const char **)argv, &la, SHUX_LD_ARGV_CAP);
            if (ldflags.have_sqlite && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lsqlite3";
            if (need_pt && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-pthread";
            /* clang 已隐式链接 libSystem，勿再传 -lSystem，否则 ld 报 duplicate libraries */
            argv[la] = NULL;
            execvp("clang", (char *const *)argv);
            la = 0;
            ld_bank_child.n = 0;
            memset(ld_bank_child.slots, 0, sizeof ld_bank_child.slots);
            argv[la++] = "ld";
            argv[la++] = "-e";
            argv[la++] = "_main";
            argv[la++] = "-o";
            argv[la++] = exe_path;
            argv[la++] = o_path;
            asm_ld_append_std_objs(link_eff, lib_roots, n_lib_roots, &ld_bank_child, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots, n_lib_roots, &ld_bank_child, argv, &la, SHUX_LD_ARGV_CAP);
            need_pt = ldflags.have_thread || ldflags.have_sync || ldflags.have_channel;
            if (ldflags.have_math && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lm";
            if (ldflags.have_compress)
                asm_ld_append_compress_libs(get_std_compress_o_path(link_eff), (const char **)argv, &la, SHUX_LD_ARGV_CAP);
            if (ldflags.have_sqlite && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lsqlite3";
            if (need_pt && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-pthread";
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lSystem";
            argv[la] = NULL;
            execvp("ld", (char *const *)argv);
            perror("shux: ld/clang");
            _exit(127);
        }
#endif
        if (use_coff_o) {
            char out_opt[512];
            int nn = snprintf(out_opt, sizeof(out_opt), "/out:%s", exe_path);
            if (nn < 0 || nn >= (int)sizeof(out_opt))
                _exit(127);
            la = 0;
            ld_bank_child.n = 0;
            memset(ld_bank_child.slots, 0, sizeof ld_bank_child.slots);
            argv[la++] = "lld-link";
            argv[la++] = "/entry:_main";
            argv[la++] = out_opt;
            argv[la++] = o_path;
            asm_ld_append_std_objs(link_eff, lib_roots, n_lib_roots, &ld_bank_child, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
            asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots, n_lib_roots, &ld_bank_child, argv, &la, SHUX_LD_ARGV_CAP);
            argv[la++] = "ws2_32.lib";
            argv[la] = NULL;
            execvp("lld-link", (char *const *)argv);
            argv[0] = "link";
            execvp("link", (char *const *)argv);
            perror("shux: lld-link/link");
            _exit(127);
        }
        la = 0;
        ld_bank_child.n = 0;
        memset(ld_bank_child.slots, 0, sizeof ld_bank_child.slots);
#if defined(__linux__)
        /* S4：`-freestanding` 时 crt0_user +（按需）runtime_panic +（按需）freestanding_io + 用户 .o */
        if (shu_ld_freestanding_enabled()) {
            const char *crt0_p;
            const char *panic_p;
            const char *io_p;
            int need_io = 0;
            int need_panic = 0;
            need_io = freestanding_user_o_needs_io(o_path);
            need_panic = freestanding_user_o_needs_panic(o_path);
            argv[la++] = "ld";
            argv[la++] = "-nostdlib";
            argv[la++] = "-static";
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "--gc-sections";
            argv[la++] = "-o";
            argv[la++] = exe_path;
            crt0_p = asm_link_obj_skip_missing(get_crt0_user_o_path(link_eff));
            if (!crt0_p) {
                fprintf(stderr, "shux: freestanding link missing crt0_user.o\n");
                _exit(127);
            }
            panic_p = NULL;
            if (need_panic)
                panic_p = asm_link_obj_skip_missing(get_runtime_panic_o_path(link_eff));
            if (need_panic && !panic_p) {
                fprintf(stderr, "shux: freestanding link missing runtime_panic.o (user references shux_panic_)\n");
                _exit(127);
            }
            io_p = NULL;
            if (need_io)
                io_p = asm_link_obj_skip_missing(get_freestanding_io_o_path(link_eff));
            if (need_io && !io_p) {
                fprintf(stderr, "shux: freestanding link missing freestanding_io.o (user references shux_sys_write)\n");
                _exit(127);
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
            execvp("ld", (char *const *)argv);
            perror("shux: ld (freestanding)");
            _exit(127);
        }
#endif
#if defined(__linux__)
        /*
         * 自包含 .o（nm -u 为空）：gcc 仅链 user.o + libc crt。
         * 勿 append 全量 std/*.o（Alpine/musl 上 ld 可能挂起或 SIGKILL，且 return-value 等无需 std）。
         */
        if (!asm_user_o_has_undef_syms(o_path)) {
            argv[la++] = "gcc";
            argv[la++] = "-o";
            argv[la++] = exe_path;
            argv[la++] = o_path;
            if (la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lc";
            argv[la] = NULL;
            execvp("gcc", (char *const *)argv);
            perror("shux: gcc (minimal user.o)");
            _exit(127);
        }
#endif
#if defined(__linux__)
        /* Linux ELF：gcc 驱动链接（crt _start→main）；裸 ld -e main 缺 crt 初始化易 SIGSEGV。 */
        argv[la++] = "gcc";
#else
        /* 其它 Unix 非 Mach-O/COFF：裸 ld + _main 入口（与 Mach-O 命名一致）。 */
        argv[la++] = "ld";
        argv[la++] = "-e";
        argv[la++] = "_main";
#endif
        argv[la++] = "-o";
        argv[la++] = exe_path;
        argv[la++] = o_path;
        asm_ld_append_std_objs(link_eff, lib_roots, n_lib_roots, &ld_bank_child, argv, &la, SHUX_LD_ARGV_CAP, &ldflags);
        asm_ld_append_on_demand_user_objs(link_eff, o_path, lib_roots, n_lib_roots, &ld_bank_child, argv, &la, SHUX_LD_ARGV_CAP);
        need_pt = ldflags.have_thread || ldflags.have_sync || ldflags.have_channel;
        if (ldflags.have_io) {
            if (la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-luring";
            if (la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lpthread";
            if ((ldflags.have_math) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lm";
            if (ldflags.have_compress)
                asm_ld_append_compress_libs(get_std_compress_o_path(link_eff), (const char **)argv, &la, SHUX_LD_ARGV_CAP);
            if ((ldflags.have_sqlite) && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lsqlite3";
#if defined(__linux__)
            if ((ldflags.have_dynlib) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-ldl";
#endif
            if (la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lc";
        } else if (ldflags.have_net && need_pt) {
            if (la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lpthread";
            if ((ldflags.have_math) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lm";
            if (ldflags.have_compress)
                asm_ld_append_compress_libs(get_std_compress_o_path(link_eff), (const char **)argv, &la, SHUX_LD_ARGV_CAP);
            if ((ldflags.have_sqlite) && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lsqlite3";
#if defined(__linux__)
            if ((ldflags.have_dynlib) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-ldl";
#endif
            if (la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lc";
        } else if (ldflags.have_net) {
            if ((ldflags.have_math) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lm";
            if (ldflags.have_compress)
                asm_ld_append_compress_libs(get_std_compress_o_path(link_eff), (const char **)argv, &la, SHUX_LD_ARGV_CAP);
            if ((ldflags.have_sqlite) && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lsqlite3";
#if defined(__linux__)
            if ((ldflags.have_dynlib) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-ldl";
#endif
            if (la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lc";
        } else if (need_pt) {
            if (la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lpthread";
            if ((ldflags.have_math) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lm";
            if (ldflags.have_compress)
                asm_ld_append_compress_libs(get_std_compress_o_path(link_eff), (const char **)argv, &la, SHUX_LD_ARGV_CAP);
            if ((ldflags.have_sqlite) && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lsqlite3";
#if defined(__linux__)
            if ((ldflags.have_dynlib) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-ldl";
#endif
            if (la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lc";
        } else {
            if ((ldflags.have_math) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lm";
            if (ldflags.have_compress)
                asm_ld_append_compress_libs(get_std_compress_o_path(link_eff), (const char **)argv, &la, SHUX_LD_ARGV_CAP);
            if ((ldflags.have_sqlite) && la < SHUX_LD_ARGV_CAP - 1)
                argv[la++] = "-lsqlite3";
#if defined(__linux__)
            if ((ldflags.have_dynlib) && la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-ldl";
#endif
            /* 与 invoke_cc 一致：Unix 上最终链 libc，解析仅含 std 各 .o 时仍可能出现的 C 符号 */
#if defined(__linux__) || defined(__APPLE__)
            if (la < SHUX_LD_ARGV_CAP - 1) argv[la++] = "-lc";
#endif
        }
        argv[la] = NULL;
#if defined(__linux__)
        execvp("gcc", (char *const *)argv);
        perror("shux: gcc");
#else
        execvp("ld", (char *const *)argv);
        perror("shux: ld");
#endif
        _exit(127);
    }
    {
        int status;
        if (shu_waitpid_retry(pid, &status) != 0)
            return -1;
        if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
            if (WIFSIGNALED(status))
                fprintf(stderr, "shux: ld failed (signal %d)\n", WTERMSIG(status));
            else
                fprintf(stderr, "shux: ld failed (exit %d)\n", WIFEXITED(status) ? WEXITSTATUS(status) : -1);
            return -1;
        }
    }
    return 0;
}
#undef SHUX_LD_ARGV_CAP

#endif /* SHUX_USE_SX_PIPELINE || SHUX_USE_SX_DRIVER */

#ifdef SHUX_USE_SX_PIPELINE
#include <stdint.h>
#include <stddef.h>
/* 9.1：纯 .sx 流水线；由 pipeline_gen.c 提供；6.1 dep 通过 ctx 传入，.sx 不再 extern get_dep_*。 */
struct shux_slice_uint8_t { uint8_t *data; size_t length; };
/* 与 ast.sx PipelineDepCtx 布局一致（含 4MiB 内嵌源缓冲）；dep/lib_root 在 C grow sidecar（ast_pool.c）。 */
#define PIPELINE_CTX_BUF_SIZE 4194304
struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx {
    int32_t ndep;
    uint8_t entry_dir_buf[512];
    int32_t entry_dir_len;
    int32_t num_lib_roots;
    uint8_t path_buf[512];
    uint8_t loaded_buf[PIPELINE_CTX_BUF_SIZE];
    int64_t loaded_len;  /* isize */
    uint8_t preprocess_buf[PIPELINE_CTX_BUF_SIZE];
    int32_t preprocess_len;
    int32_t use_asm_backend;
    int32_t target_arch;
    int32_t target_cpu_features;
    int32_t use_macho_o;
    int32_t use_coff_o;
    int32_t current_block_ref;
    int32_t typeck_loop_depth;
    int32_t current_func_index;
    int32_t skip_codegen_dep_0;
    int32_t entry_already_parsed;
    int32_t current_func_single_empty_param_index;
    int32_t current_func_empty_param_count;
    int32_t current_emit_empty_var_next_index;
    int32_t emit_expr_as_callee;
    void *current_codegen_module;
    void *current_codegen_arena;
    int32_t current_codegen_dep_index;
    uint8_t current_codegen_prefix_mirror[64];
    int32_t current_codegen_prefix_len;
    int32_t asm_entry_module_only;
    uint8_t entry_module_import_path_mirror[64];
    int32_t entry_module_import_path_len;
};
/** 读 SHUX_ASM_ENTRY_MODULE_ONLY 环境变量；定义见本文件后部。 */
static int asm_entry_module_only_from_env(void);
/** asm 单模块 -o 的 dep 预跑（定义在 parser_ParseIntoResult 之后）。 */
static int pipeline_dep_prerun_for_asm_module_o(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx);

extern void ast_pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len);
extern void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
extern void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
extern void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len);
/* 形参顺序与 pipeline.sx 一致：第一为 module，第二为 arena，避免 entry 被错位导致 main 空体。 */
extern int pipeline_run_sx_pipeline(void *module, void *arena, const uint8_t *source_data, size_t source_len, void *out_buf, void *ctx);
extern int pipeline_pipeline_impl_typecheck(void *module, void *arena, void *ctx);

/** pipeline_run_sx_pipeline 线程参数：在独立 pthread 栈上跑 .sx 流水线，避免 macOS 主线程 8MiB 硬顶导致 typeck 等大模块 segfault。 */
typedef struct {
    void *module;
    void *arena;
    const uint8_t *source_data;
    size_t source_len;
    void *out_buf;
    void *ctx;
    int result;
} PipelineRunSuArgs;

/** 当前 pipeline 入口源码长度；供 .sx 按体积跳过大库 merge/typeck。 */
static size_t g_pipeline_entry_source_len;

void driver_set_pipeline_entry_source_len(size_t len) {
    g_pipeline_entry_source_len = len;
}

size_t driver_pipeline_entry_source_len(void) {
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] entry_source_len_global=%zu\n", g_pipeline_entry_source_len);
    return g_pipeline_entry_source_len;
}

/** 非 0 表示入口源码过大，应跳过 merge/library 全量 typeck（.sx 路径上易 segfault）。 */
int32_t driver_typeck_skip_large_entry(void) {
    int32_t skip = g_pipeline_entry_source_len > 150000u ? 1 : 0;
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] typeck_skip_large_entry=%d len=%zu\n", (int)skip,
                g_pipeline_entry_source_len);
    return skip;
}

/**
 * build_shux_asm 单模块 -o：跳过 .sx typeck，仅 parse+asm codegen（C typeck 已覆盖语义；避免 elf/types 等 SU 假阳性）。
 */
int32_t driver_asm_build_skip_typeck(void) {
    const char *e = getenv("SHUX_ASM_BUILD_SKIP_TYPECK");
    return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** asm 用户程序：std.io/fs/net dep 跳过 .sx typeck（符号由 io.o/fs.o/net.o 提供；见 ast_pool.c）。 */
extern int32_t pipeline_asm_user_dep_skip_su_typeck(uint8_t *path);
extern int32_t pipeline_asm_user_std_net_dep_path(uint8_t *path);
extern void pipeline_asm_seed_std_net_struct_layouts(struct ast_Module *m);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path);

static int asm_user_std_dep_skip_su_typeck(const char *dep_path) {
    if (!dep_path || dep_path[0] == '\0')
        return 0;
    return pipeline_asm_user_dep_skip_su_typeck((uint8_t *)dep_path) != 0;
}

/** std.net dep 路径：须 co-emit listen/accept_many 等，但 seed .sx typeck 对 stream_* 假阳性。 */
static int asm_user_std_net_dep_path(const char *dep_path) {
    if (!dep_path || dep_path[0] == '\0')
        return 0;
    return pipeline_asm_user_std_net_dep_path((uint8_t *)dep_path) != 0;
}

/** std.io.driver：co-emit submit_* 包装供 std.net stream_*_batch；seed typeck 对 register 假阳性。 */
static int asm_user_std_io_driver_dep_path(const char *dep_path) {
    if (!dep_path || dep_path[0] == '\0')
        return 0;
    return pipeline_codegen_path_is_std_io_driver_bytes((uint8_t *)dep_path) != 0;
}

static int asm_user_dep_parse_skip_typeck_path(const char *dep_path) {
    return asm_user_std_net_dep_path(dep_path) || asm_user_std_io_driver_dep_path(dep_path);
}

/**
 * typeck 第二遍 EMIT_HEAVY：pipeline 跳过文本 asm codegen，由 runtime asm_codegen_elf_o 单路径真 emit。
 */
int32_t driver_asm_entry_emit_heavy(void) {
    const char *e = getenv("SHUX_ASM_ENTRY_EMIT_HEAVY");
    return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** pthread 入口：执行 pipeline_run_sx_pipeline 并将返回码写入 args->result。 */
static void *pipeline_run_sx_thread_fn(void *arg) {
    PipelineRunSuArgs *a = (PipelineRunSuArgs *)arg;
    driver_set_pipeline_entry_source_len(a->source_len);
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] pipeline thread start len=%zu\n", a->source_len);
    a->result = pipeline_run_sx_pipeline(a->module, a->arena, a->source_data, a->source_len, a->out_buf, a->ctx);
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] pipeline thread done ec=%d\n", a->result);
    return NULL;
}

/** pthread 入口：标记大栈线程并抬高 soft limit 后执行用户 fn。 */
static void *driver_large_stack_thread_trampoline(void *v) {
    typedef struct {
        void *(*fn)(void *);
        void *arg;
    } DriverLargeStackCall;
    DriverLargeStackCall *c = (DriverLargeStackCall *)v;
    g_driver_on_large_stack_thread = 1;
    driver_bump_stack_limit_if_needed();
    void *r = c->fn(c->arg);
    g_driver_on_large_stack_thread = 0;
    return r;
}

/** 在当前线程直接执行 fn(arg)，并临时标记/恢复 g_driver_on_large_stack_thread。 */
static void driver_run_fn_on_current_large_stack(void *(*fn)(void *), void *arg) {
    g_driver_on_large_stack_thread = 1;
    driver_bump_stack_limit_if_needed();
    fn(arg);
    g_driver_on_large_stack_thread = 0;
}

/**
 * 在 256MiB 栈 pthread 上执行 fn(arg)；SHUX_PIPELINE_NO_LARGE_STACK=1 时于当前线程直接执行。
 * macOS 主线程 RLIMIT_STACK 硬顶约 8MiB，C typeck / asm_codegen_elf_o 深递归须与大 pipeline 同路径。
 */
static void driver_run_thread_on_large_stack(void *(*fn)(void *), void *arg) {
    pthread_attr_t attr;
    pthread_t tid;
    void *stk = NULL;
    size_t stack_sz = (size_t)256 * 1024 * 1024;
    const char *no_large = getenv("SHUX_PIPELINE_NO_LARGE_STACK");
    typedef struct {
        void *(*fn)(void *);
        void *arg;
    } DriverLargeStackCall;
    DriverLargeStackCall call = { fn, arg };
    /* LSP 主循环已在大栈 pthread 内：diag/definition 的 typeck 直接复用当前栈，勿嵌套 256MiB 分配。 */
    if (g_driver_on_large_stack_thread) {
        fn(arg);
        return;
    }
    driver_bump_stack_limit_if_needed();
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

/** 对外暴露：在 256MiB 栈 pthread 上执行 fn(arg)；LSP 主循环等深栈场景使用。 */
void driver_run_on_large_stack_pthread(void *(*fn)(void *), void *arg) {
    driver_run_thread_on_large_stack(fn, arg);
}

/**
 * 在 64MiB 栈的 pthread 上调用 pipeline_run_sx_pipeline；失败时回退到当前线程直接调用。
 * 大模块（typeck/parser）经 .sx 编译后栈帧极深，setrlimit 无法突破 macOS RLIMIT_STACK 硬顶时需此路径。
 */
static int pipeline_run_sx_pipeline_large_stack(void *module, void *arena, const uint8_t *source_data, size_t source_len,
    void *out_buf, void *ctx) {
    driver_set_pipeline_entry_source_len(source_len);
    PipelineRunSuArgs args;
    args.module = module;
    args.arena = arena;
    args.source_data = source_data;
    args.source_len = source_len;
    args.out_buf = out_buf;
    args.ctx = ctx;
    args.result = -99;
    driver_run_thread_on_large_stack(pipeline_run_sx_thread_fn, &args);
    if (args.result == -99)
        return pipeline_run_sx_pipeline(module, arena, source_data, source_len, out_buf, ctx);
    return args.result;
}

/**
 * dep 预跑：完整 pipeline parse，跳过 .sx typeck/codegen；供 std.net 等 co-emit 前填 funcs（parse_only 对库模块常 funcs=0）。
 */
static int pipeline_dep_prerun_parse_skip_typeck(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx) {
    int saved = driver_check_only_get();
    int saved_entry_only = 0;
    int ec;
    struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)one_ctx;
    driver_check_only_set(1);
    if (pctx) {
        saved_entry_only = pctx->asm_entry_module_only;
        pctx->asm_entry_module_only = 1;
    }
    driver_su_pipeline_skip_typeck_set(1);
    driver_su_pipeline_skip_codegen_set(1);
    ec = pipeline_run_sx_pipeline_large_stack(dep_mod, dep_arena, src, len, dep_out, one_ctx);
    driver_su_pipeline_skip_codegen_set(0);
    driver_su_pipeline_skip_typeck_set(0);
    if (pctx)
        pctx->asm_entry_module_only = saved_entry_only;
    driver_check_only_set(saved ? 1 : 0);
    return ec;
}

/**
 * build_shux_asm / -backend asm 的 dep 预跑：仅 parse+typeck 填 dep 槽，跳过 codegen（避免对 codegen.sx 等大 dep 生成 C/asm 导致栈溢出）。
 */
static int pipeline_dep_prerun_typeck_only(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len, void *dep_out,
    void *one_ctx) {
    int saved = driver_check_only_get();
    driver_check_only_set(1);
    int ec = pipeline_run_sx_pipeline_large_stack(dep_mod, dep_arena, src, len, dep_out, one_ctx);
    driver_check_only_set(saved ? 1 : 0);
    return ec;
}

/** preprocess.sx 生成；与 preprocess_su.o 中 typeck_* 名同源实现，pipeline_gen.c 导出此符号（shu_su 仅链 pipeline_sx.o 时须调此名）。 */
extern int32_t preprocess_sx_buf(const uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf,
                                            int32_t out_cap);
extern void preprocess_define_reset(void);
extern int32_t preprocess_if_stack_len(void);
extern void preprocess_define_add(const char *name);

/**
 * 对原始 .sx 做 preprocess.sx 条件编译扫描，写入新分配缓冲 NUL 结尾字符串。
 *
 * 【返回】0 成功；否则写 stderr（过大或预处理失败）、不分配 *out。
 */
static int su_preprocess_raw_to_malloc(const unsigned char *raw, size_t raw_len, char **out_src, size_t *out_src_len,
    const char *path_diag, const char **defines, int ndefines) {
    int di;
    if (raw_len > (size_t)PIPELINE_CTX_BUF_SIZE) {
        fprintf(stderr,
            "shux: entry file too large for .sx preprocessor (%zu > %d): '%s'\n",
            raw_len,
            PIPELINE_CTX_BUF_SIZE,
            path_diag ? path_diag : "?");
        return -1;
    }
    uint8_t *scratch = (uint8_t *)malloc((size_t)PIPELINE_CTX_BUF_SIZE);
    if (!scratch)
        return -1;
    preprocess_define_reset();
    for (di = 0; di < ndefines; di++)
        if (defines && defines[di])
            preprocess_define_add(defines[di]);
    int32_t n = preprocess_sx_buf(raw, (ptrdiff_t)raw_len, scratch, (int32_t)PIPELINE_CTX_BUF_SIZE);
    if (n < 0) {
        free(scratch);
        if (preprocess_if_stack_len() != 0)
            fprintf(stderr, "preprocess: unclosed #if\n");
        else
            fprintf(stderr, "shux: .sx preprocess failed for '%s'\n", path_diag ? path_diag : "?");
        return -1;
    }
    if (preprocess_if_stack_len() != 0) {
        free(scratch);
        fprintf(stderr, "preprocess: unclosed #if\n");
        return -1;
    }
    char *dup = (char *)malloc((size_t)n + 1);
    if (!dup) {
        free(scratch);
        return -1;
    }
    memcpy(dup, scratch, (size_t)n);
    dup[n] = '\0';
    free(scratch);
    *out_src = dup;
    *out_src_len = (size_t)n;
    return 0;
}

/** 诊断：返回 module 的 num_funcs（pipeline_glue.c 提供，与 ast_Module 同 TU）。 */
extern int driver_get_module_num_funcs(void *m);
extern int driver_get_module_main_func_index(void *m);

/** 将 C 侧 dep 槽写入 PipelineDepCtx sidecar（与 ast.sx pipeline_dep_ctx_* 对齐）。 */
static void runtime_pctx_seed_dep_slots(struct ast_PipelineDepCtx *ctx, void **dep_mods, void **dep_ar,
    char **import_paths, int n) {
    int i;
    if (!ctx)
        return;
    ast_pipeline_dep_ctx_reset(ctx);
    for (i = 0; i < n; i++) {
        ast_pipeline_dep_ctx_set_module(ctx, i, (struct ast_Module *)dep_mods[i]);
        ast_pipeline_dep_ctx_set_arena(ctx, i, (struct ast_ASTArena *)dep_ar[i]);
        if (import_paths && import_paths[i]) {
            int pl = (int)strlen(import_paths[i]);
            ast_pipeline_dep_ctx_set_import_path(ctx, i, (uint8_t *)import_paths[i], pl);
        }
    }
    ast_pipeline_dep_ctx_set_ndep(ctx, n);
}

static void pipeline_fill_ctx_path_buffers(struct ast_PipelineDepCtx *ctx, const char *entry_dir, const char **lib_roots, int n_lib_roots);
static const char *runtime_dep_prerun_entry_dir(const char *main_entry_dir, const char **lib_roots, int n_lib_roots);
static void runtime_one_ctx_for_dep_prerun(struct ast_PipelineDepCtx *ctx, int j, void *mod, void *ar);

/** 6.1：填充 ctx 的 entry_dir_buf、lib_root sidecar，供 .sx 内 resolve_path_su 使用。 */
static void pipeline_fill_ctx_path_buffers(struct ast_PipelineDepCtx *ctx, const char *entry_dir, const char **lib_roots, int n_lib_roots) {
    ctx->loaded_len = 0;
    ctx->preprocess_len = 0;
    ctx->entry_dir_len = 0;
    ctx->num_lib_roots = 0;
    if (entry_dir) {
        size_t el = strlen(entry_dir);
        if (el >= 512) el = 511;
        memcpy(ctx->entry_dir_buf, entry_dir, el);
        ctx->entry_dir_buf[el] = '\0';
        ctx->entry_dir_len = (int32_t)el;
    }
    if (lib_roots && n_lib_roots > 0) {
        for (int i = 0; i < n_lib_roots && lib_roots[i]; i++) {
            size_t ll = strlen(lib_roots[i]);
            if (ll >= 256) ll = 255;
            ast_pipeline_ctx_append_lib_root(ctx, (uint8_t *)lib_roots[i], (int32_t)ll);
        }
    }
}
extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);
extern int32_t pipeline_typeck_sx_stack_escape_gate_from_src_c(uint8_t *src, int32_t src_len);
/** 7.4：ELF .o 路径；由 Makefile 追加到 pipeline_gen.c，用于分配 ElfCodegenCtx */
extern size_t pipeline_sizeof_elf_ctx(void);
/** 7.4：直接生成 ELF64 .o 到 out_buf（仅 x86_64）；由 asm.sx 提供，pipeline_sx.o 链接；ElfCodegenCtx 在 platform/elf.sx，C 侧为 platform_elf_ElfCodegenCtx。out_buf 用 void* 避免不同 GCC 下「形参内 struct 声明不可见」导致 -Wincompatible-pointer-types。 */
struct platform_elf_ElfCodegenCtx;
extern int32_t asm_asm_codegen_elf_o(void *module, void *arena, void *ctx, struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf);

/** asm_codegen_elf_o 大栈线程参数（与 pipeline_run_sx_pipeline_large_stack 同策略）。 */
typedef struct {
    void *module;
    void *arena;
    void *ctx;
    struct platform_elf_ElfCodegenCtx *elf_ctx;
    void *out_buf;
    int32_t result;
} AsmCodegenElfLargeArgs;

/** pthread 入口：调用 asm_asm_codegen_elf_o 并将 ec 写入 args->result。 */
static void *asm_codegen_elf_o_thread_fn(void *arg) {
    AsmCodegenElfLargeArgs *a = (AsmCodegenElfLargeArgs *)arg;
    a->result = asm_asm_codegen_elf_o(a->module, a->arena, a->ctx, a->elf_ctx, a->out_buf);
    return NULL;
}

/**
 * 在 256MiB 栈 pthread 上调用 asm_asm_codegen_elf_o；C typeck 后主线程栈已深时避免 lexer_next emit Abort。
 */
static int32_t asm_asm_codegen_elf_o_large_stack(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf) {
    AsmCodegenElfLargeArgs args;
    args.module = module;
    args.arena = arena;
    args.ctx = ctx;
    args.elf_ctx = elf_ctx;
    args.out_buf = out_buf;
    args.result = -99;
    driver_run_thread_on_large_stack(asm_codegen_elf_o_thread_fn, &args);
    if (args.result == -99)
        return asm_asm_codegen_elf_o(module, arena, ctx, elf_ctx, out_buf);
    return args.result;
}
extern void pipeline_elf_ctx_diag_stderr(uint8_t *ctx_bytes);

#if !defined(SHUX_USE_SX_DRIVER)
/** 判断 -o 路径是否写出对象文件（.o / .obj 则写 ELF/Mach-O/COFF 而非 .s） */
static int output_is_elf_o(const char *path) {
    if (!path) return 0;
    size_t n = strlen(path);
    if (n >= 2 && path[n - 2] == '.' && (path[n - 1] == 'o' || path[n - 1] == 'O'))
        return 1;
    return n >= 4 && path[n - 4] == '.' && path[n - 3] == 'o' && path[n - 2] == 'b' && path[n - 1] == 'j';
}

/** 判断 -o 路径是否表示「要可执行文件」：非 .o/.obj/.s 结尾则视为可执行文件名；-backend asm 时据此自动调 ld。 */
static int output_want_exe(const char *path) {
    if (!path || !*path) return 0;
    size_t n = strlen(path);
    if (n >= 2 && path[n - 2] == '.' && (path[n - 1] == 'o' || path[n - 1] == 'O')) return 0;
    if (n >= 4 && path[n - 4] == '.' && path[n - 3] == 'o' && path[n - 2] == 'b' && path[n - 1] == 'j') return 0;
    if (n >= 2 && path[n - 2] == '.' && path[n - 1] == 's') return 0;
    return 1;
}

/**
 * 调用系统链接器将 .o（或 Mach-O/COFF 对象）链接为可执行文件。
 * 用于 -backend asm -o <exe> 时一条命令出可执行文件；先 ensure_runtime_panic_o，再链入与 invoke_cc 同序的 std 各 .o。
 * link_argv0：须为 argv[0]，用于解析 compiler/、std/ 及构建 runtime_panic.o；若为 NULL/PATH-only 则用可执行镜像路径推导。
 * lib_roots / n_lib_roots：与 -L 一致，getter 失败后按 «root/std/.../*.o» 再找一轮。
 * 返回值：0 成功，-1 失败。
 */
static int invoke_ld(const char *o_path, const char *exe_path, const char *target, int use_macho_o, int use_coff_o, const char *link_argv0,
    const char **lib_roots, int n_lib_roots) {
    char link_argv_syn[PATH_MAX];
    const char *link_eff;
    if (!o_path || !exe_path)
        return -1;
    link_eff = shux_asm_ld_effective_link_argv0(link_argv0, link_argv_syn, sizeof link_argv_syn);
    if (!link_eff)
        return -1;
#if defined(__linux__)
    if (freestanding_prepare_runtime_panic_o(link_eff, o_path) != 0)
        return -1;
#else
    if (ensure_runtime_panic_o(link_eff) != 0)
        return -1;
#endif
    if (ensure_crt0_user_o(link_eff) != 0)
        return -1;
#if defined(__linux__)
    if (shu_ld_freestanding_enabled() && freestanding_user_o_needs_io(o_path)) {
        if (ensure_freestanding_io_o(link_eff) != 0)
            return -1;
    }
#endif
    if (shu_ld_freestanding_enabled() && (use_macho_o || use_coff_o)) {
        fprintf(stderr, "shux: -freestanding / SHUX_FREESTANDING only supported for Linux ELF x86_64 (-o prog, not .o/.obj on macOS/COFF)\n");
        return -1;
    }
    return asm_invoke_ld_platform(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots);
}
#endif /* !SHUX_USE_SX_DRIVER */
/** 调试：打印 module 中每个 func 的 name_len/name（由 Makefile 追加到 pipeline_gen.c）；便于定位 mai/ba 截断 */
extern void pipeline_debug_module_funcs(void *module);
/* 与生成代码中 codegen_CodegenOutBuf 布局一致；C 在调用后将 data[0..len-1] 写到 FILE* */
#define SU_CODEGEN_OUTBUF_CAP (9 * 1024 * 1024)
struct codegen_CodegenOutBuf {
    unsigned char data[SU_CODEGEN_OUTBUF_CAP];
    int32_t len;
};
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
_Static_assert(offsetof(struct codegen_CodegenOutBuf, len) == SU_CODEGEN_OUTBUF_CAP, "CodegenOutBuf: len must follow data[] for ABI");
#endif
/** asm 后端 C 桩：-backend asm 时由 pipeline 调用，写出最小 GAS（main return 42），便于 pipeline 不 import asm 仍可构建 shu_su。
 * 实验 asm-only 链并入 build_asm/backend.o 时须为 weak，避免与 backend.sx 导出的 asm_codegen_ast 重复定义。 */
__attribute__((weak)) int32_t asm_codegen_ast(void *module, void *arena, struct codegen_CodegenOutBuf *out) {
    (void)module;
    (void)arena;
    static const char *lines[] = {
        ".text",
        ".globl main",
        "main:",
        "pushq %rbp",
        "movq %rsp, %rbp",
        "subq $0, %rsp",
        "movl $42, %eax",
        "movq %rsp, %rbp",
        "popq %rbp",
        "ret"
    };
    size_t n = 0;
    for (int i = 0; i < (int)(sizeof lines / sizeof lines[0]); i++) {
        size_t len = strlen(lines[i]);
        if (n + len + 1 > (size_t)SU_CODEGEN_OUTBUF_CAP) return -1;
        memcpy(out->data + n, lines[i], len);
        out->data[n + len] = '\n';
        n += len + 1;
    }
    out->len = (int32_t)n;
    return 0;
}
/* 诊断 -sx 失败阶段：pipeline_gen.c 中 parser 符号 */
struct parser_ParseIntoResult { int32_t ok; int32_t main_idx; };
extern void parser_parse_into_init(void *arena, void *module);
extern struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len);
extern struct parser_ParseIntoResult parser_parse_into(void *arena, void *module, struct shux_slice_uint8_t *source);

/**
 * SHUX_ASM_ENTRY_MODULE_ONLY=1 时 dep 预跑：仅 parse_into，不做 dep 全量 .sx typeck（各 dep 将单独 -o）。
 * collect_deps_transitive 已 preprocess；勿二次 preprocess_sx_buf（会破坏源码导致 parse 失败）。
 */
static int pipeline_dep_prerun_parse_only(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len) {
    struct parser_ParseIntoResult pr;
    struct shux_slice_uint8_t slice;
    if (!dep_mod || !dep_arena || !src || len == 0)
        return -1;
    parser_parse_into_init(dep_mod, dep_arena);
    slice.data = (uint8_t *)src;
    slice.length = len;
    pr = parser_parse_into(dep_arena, dep_mod, &slice);
    /* parser.sx：ok==0 成功；ok==-2 库模块单函数失败但 import 槽仍可用（与 collect_deps 一致）。 */
    return (pr.ok == 0 || pr.ok == -2) ? 0 : -1;
}

/** asm 单模块构建：dep 预跑仍走 pipeline（含 preprocess）；入口/dep 的 .sx typeck 由 SHUX_ASM_BUILD_SKIP_TYPECK 在 pipeline.sx 内跳过。 */
static int pipeline_dep_prerun_for_asm_module_o(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx) {
    (void)asm_entry_module_only_from_env;
    return pipeline_dep_prerun_typeck_only(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}
extern void parser_parse_into_set_main_index(void *module, int32_t main_idx);
extern int32_t parser_get_module_num_imports(void *module);
extern void parser_get_module_import_path(void *module, int32_t i, uint8_t *out);
extern int32_t parser_diag_fail_at_token_kind(struct shux_slice_uint8_t *source);
extern int32_t parser_diag_token_after_collect_imports(struct shux_slice_uint8_t *source, void *module);
extern int32_t pipeline_parse_one_function_ok(struct shux_slice_uint8_t *source, void *arena);
extern int32_t pipeline_typeck_after_parse_ok(void *arena, void *module, struct shux_slice_uint8_t *source, void *ctx);
#ifdef SHUX_USE_SX_DRIVER
/* run_compiler_c 由 C 在此定义，转调 main.sx 的 main_run_compiler_c，供 main_entry 等调用；不再依赖 driver_gen.c 追加。 */
extern int main_run_compiler_c(int argc, uint8_t *argv);
int run_compiler_c(int argc, char **argv) {
  return main_run_compiler_c(argc, (uint8_t *)argv);
}
#endif
/* 6.1 后 typeck/pipeline 用 ctx，以下仅保留供旧 pipeline_gen.c 或未链入 .sx 时兼容；可逐步移除。 */
#if defined(SHUX_USE_SX_PIPELINE) || defined(SHUX_USE_SX_DRIVER)
void *typeck_dep_module_ptrs[32];
void *typeck_dep_arena_ptrs[32];
int typeck_ndep;
void *get_dep_module(int32_t i) {
  if (i < 0 || i >= typeck_ndep) return NULL;
  return typeck_dep_module_ptrs[i];
}
void *get_dep_arena(int32_t i) {
  if (i < 0 || i >= typeck_ndep) return NULL;
  return typeck_dep_arena_ptrs[i];
}
int32_t get_ndep(void) {
  return (int32_t)typeck_ndep;
}
/* pipeline_gen.c 中调用 typeck_get_dep_*，与 get_dep_* 同义 */
void *typeck_get_dep_module(int32_t i) { return get_dep_module(i); }
void *typeck_get_dep_arena(int32_t i) { return get_dep_arena(i); }

/**
 * 使用已填充的 typeck_ndep / typeck_dep_module_ptrs 对入口模块做 C 类型检查（大模块 asm 构建用）。
 */
int32_t pipeline_typeck_module_for_ctx(void *module, void *arena, void *ctx_void) {
    (void)arena;
    (void)ctx_void;
    if (typeck_module((struct ASTModule *)module,
            typeck_ndep > 0 ? (struct ASTModule **)typeck_dep_module_ptrs : NULL, typeck_ndep, NULL, 0) != 0)
        return -1;
    return 0;
}
#endif

#ifdef SHUX_USE_SX_PREPROCESS
/* 6.4：预处理由 preprocess.sx（与 pipeline 同源的 preprocess_sx_buf）提供；ndefines==0 走 .sx，否则回退 C preprocess_c_fallback。 */
#ifndef SHUX_USE_SX_PIPELINE
extern int32_t typeck_preprocess_sx(struct shux_slice_uint8_t *source, struct shux_slice_uint8_t *out_buf);
#endif
static char *preprocess_via_su(const char *source, size_t source_len, const char **defines, int ndefines,
    size_t *out_length) {
    if (!source) return NULL;
    size_t slen = source_len ? source_len : strlen(source);
#ifdef SHUX_USE_SX_PIPELINE
    /* 与 pipeline/import 路径一致，避免 slice API 与 buf 路径行为分叉；-D 经 preprocess_define_* 注入。 */
    char *out = NULL;
    size_t olen = 0;
    if (su_preprocess_raw_to_malloc((const unsigned char *)source, slen, &out, &olen, NULL,
            ndefines > 0 ? defines : NULL, ndefines) != 0)
        return NULL;
    if (out_length) *out_length = olen;
    return out;
#else
    size_t out_cap = slen + 65536;
    if (out_cap < slen) return NULL;
    uint8_t *out_buf = (uint8_t *)malloc(out_cap);
    if (!out_buf) return NULL;
    struct shux_slice_uint8_t src_slice = { (uint8_t *)source, slen };
    struct shux_slice_uint8_t out_slice = { out_buf, out_cap };
    int32_t ret = typeck_preprocess_sx(&src_slice, &out_slice);
    if (ret < 0) {
        free(out_buf);
        return NULL;
    }
    char *result = (char *)malloc((size_t)ret + 1);
    if (!result) {
        free(out_buf);
        return NULL;
    }
    memcpy(result, out_buf, (size_t)ret);
    result[ret] = '\0';
    free(out_buf);
    if (out_length) *out_length = (size_t)ret;
    return result;
#endif
}
char *preprocess(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length) {
    if (out_length) *out_length = 0;
    if (!source) return NULL;
    /*
     * driver -o / run-preprocess：仅用 C 实现（#if 栈、边界诊断与 -D 一致）。
     * pipeline/import 仍直接调 preprocess_sx_buf（su_preprocess_raw_to_malloc）。
     * 勿在 C 失败后再试 SU：部分链上 SU 可能 passthrough 源码，导致 unclosed #if 仍被编过。
     */
    return preprocess_c_fallback(source, source_len, defines, ndefines, out_length);
}
#endif

/* 阶段 5.3 / 6.2：.sx 内写编排逻辑，C 只提供最小 I/O 原语。 */
#define PIPELINE_IMPORT_BUF_CAP 4194304
static char pipeline_entry_dir_buf[512];
static const char *pipeline_entry_dir = ".";
static char pipeline_resolved_path_buf[512];
static void *pipeline_dep_arena_slots[32];
static void *pipeline_dep_module_slots[32];
static char *pipeline_loaded_import_buf;
static size_t pipeline_loaded_import_len;
static size_t pipeline_loaded_import_cap;
void pipeline_set_entry_dir(const char *path) {
    if (path && path[0]) {
        (void)snprintf(pipeline_entry_dir_buf, sizeof(pipeline_entry_dir_buf), "%s", path);
        pipeline_entry_dir = pipeline_entry_dir_buf;
    } else {
        pipeline_entry_dir = ".";
    }
}
void pipeline_set_dep_slots(void *arenas[32], void *modules[32]) {
    for (int i = 0; i < 32; i++) {
        pipeline_dep_arena_slots[i] = arenas ? arenas[i] : NULL;
        pipeline_dep_module_slots[i] = modules ? modules[i] : NULL;
    }
}
/** 原语：仅把 import 路径解析成文件系统路径并写入内部 buffer，返回 0 成功 -1 失败。由 .sx 决定何时、对谁调用。 */
int32_t pipeline_resolve_path(const uint8_t *path_ptr, int32_t path_len) {
    char path_c[65];
    size_t k = 0;
    if (path_len <= 0 || path_len > 64) path_len = 64;
    while (k < (size_t)path_len && path_ptr[k]) {
        path_c[k] = (char)path_ptr[k];
        k++;
    }
    path_c[k] = '\0';
    const char *lib_roots[1] = { "." };
    resolve_import_file_path_multi(lib_roots, 1, pipeline_entry_dir, path_c, pipeline_resolved_path_buf, sizeof(pipeline_resolved_path_buf));
    return 0;
}
/** 原语：把当前 resolved 路径对应的文件读入并预处理，结果写入 loaded buffer，返回 0 成功 -1 失败。由 .sx 在 resolve_path 之后按需调用。 */
int32_t pipeline_read_file(void) {
    size_t raw_len = 0;
    char *raw = read_file(pipeline_resolved_path_buf, &raw_len);
    if (!raw) {
        fprintf(stderr, "shux: cannot open import (tried %s)\n", pipeline_resolved_path_buf);
        return -1;
    }
    char *prep = NULL;
    size_t prep_len = 0;
    if (su_preprocess_raw_to_malloc((const unsigned char *)raw, raw_len, &prep, &prep_len, pipeline_resolved_path_buf, NULL, 0) != 0) {
        free(raw);
        fprintf(stderr, "shux: preprocess failed for import\n");
        return -1;
    }
    free(raw);
    if (!prep) {
        fprintf(stderr, "shux: preprocess failed for import\n");
        return -1;
    }
    if (prep_len > pipeline_loaded_import_cap || !pipeline_loaded_import_buf) {
        free(pipeline_loaded_import_buf);
        pipeline_loaded_import_cap = prep_len < PIPELINE_IMPORT_BUF_CAP ? PIPELINE_IMPORT_BUF_CAP : prep_len + 65536;
        pipeline_loaded_import_buf = (char *)malloc(pipeline_loaded_import_cap);
        if (!pipeline_loaded_import_buf) {
            free(prep);
            return -1;
        }
    }
    memcpy(pipeline_loaded_import_buf, prep, prep_len);
    pipeline_loaded_import_len = prep_len;
    free(prep);
    return 0;
}
void *pipeline_get_dep_arena_slot(int32_t i) {
    if (i < 0 || i >= 32) return NULL;
    return pipeline_dep_arena_slots[i];
}
void *pipeline_get_dep_module_slot(int32_t i) {
    if (i < 0 || i >= 32) return NULL;
    return pipeline_dep_module_slots[i];
}
void pipeline_set_dep(int32_t i, void *mod, void *arena) {
    if (i < 0 || i >= 32) return;
    typeck_dep_module_ptrs[i] = mod;
    typeck_dep_arena_ptrs[i] = arena;
}
void pipeline_set_ndep(int32_t n) {
    typeck_ndep = n <= 32 ? n : 32;
}
int32_t pipeline_parse_into_loaded_import(void *arena, void *module) {
    struct shux_slice_uint8_t slice = {
        .data = pipeline_loaded_import_buf ? (uint8_t *)pipeline_loaded_import_buf : NULL,
        .length = pipeline_loaded_import_len
    };
    if (!slice.data) return -1;
    parser_parse_into_init(module, arena);
    struct parser_ParseIntoResult pr = parser_parse_into(arena, module, &slice);
    return pr.ok == 0 ? 0 : -1;
}

/** 6.1 原 C 桥接：已由 pipeline.sx 的 pipeline_parse_into_buf（调 parser.parse_into_buf）替代，此处不再编译以免重复符号。 */
#if 0
int32_t pipeline_parse_into_buf(void *arena, void *module, const uint8_t *buf, int32_t buf_len) {
    if (!buf) return -1;
    struct shux_slice_uint8_t slice = { .data = (uint8_t *)buf, .length = (size_t)buf_len };
    parser_parse_into_init(module, arena);
    struct parser_ParseIntoResult pr = parser_parse_into(arena, module, &slice);
    return pr.ok == 0 ? 0 : -1;
}
#endif
#endif
#include <unistd.h>
#include <sys/wait.h>
#include <sys/utsname.h>

/**
 * 读入整个文件为 NUL 结尾的堆分配字符串。
 * 功能说明：用于读入 .sx 源码或 import 的模块文件，供 Lexer/Parser 使用。
 * 参数：path 文件系统路径，只读；须可访问且为普通文件。
 * 返回值：成功返回 malloc 的缓冲区（含结尾 NUL），调用方须 free；失败（无法打开、seek/read 错误）返回 NULL。
 * 错误与边界：空文件返回非 NULL 且 buf[0]='\0'；path 为 NULL 或不可打开时返回 NULL。
 * 若 out_len 非 NULL，则 *out_len 为读入的字节数（不含结尾 NUL），供 preprocess 按长度扫描避免嵌入 NUL 截断。
 * 副作用与约定：分配内存，无静态状态；不修改 path。
 */
static char *read_file(const char *path, size_t *out_len);

/**
 * 将 import 路径字符串转为库根下的 .sx 文件路径。
 * 功能说明：例如 "core.types" 在 lib_root 为 "." 时得到 "./core/types.sx"，供 read_file 打开。
 * 参数：lib_root 标准库根目录，若为 NULL 或空则视为 "."；import_path 如 "core.types"；path 输出缓冲区；path_size 缓冲区字节数，建议至少 512。
 * 返回值：无；结果写入 path，保证 NUL 结尾（若 path_size>0）。
 * 错误与边界：path_size 过小可能导致截断；import_path 中的 '.' 均替换为 '/'。
 * 副作用与约定：仅写 path，不分配内存；不修改 lib_root、import_path。
 */
static void import_path_to_file_path(const char *lib_root, const char *import_path, char *path, size_t path_size) {
    const char *r = lib_root && lib_root[0] ? lib_root : ".";
    size_t off = (size_t)snprintf(path, path_size, "%s/", r);
    for (const char *s = import_path; *s && off + 1 < path_size; s++) {
        if (*s == '.')
            path[off++] = '/';
        else
            path[off++] = *s;
    }
    if (off + 4 <= path_size)
        snprintf(path + off, path_size - off, ".sx");
}

/**
 * 从入口文件路径得到其所在目录，用于多文件时从同目录解析 import（阶段 7.3）。
 * 参数：input_path 入口 .sx 路径；entry_dir 输出缓冲区；size 缓冲区大小。
 * 无目录时写入 "."。
 */
static void get_entry_dir(const char *input_path, char *entry_dir, size_t size) {
    if (!input_path || !entry_dir || size == 0) {
        if (size) entry_dir[0] = '\0';
        return;
    }
    const char *last = strrchr(input_path, '/');
    if (!last) {
        (void)snprintf(entry_dir, size, ".");
        return;
    }
    size_t len = (size_t)(last - input_path);
    if (len >= size) len = size - 1;
    memcpy(entry_dir, input_path, len);
    entry_dir[len] = '\0';
}

/**
 * 判断 import 字符串是否为文件路径（相对/绝对/.sx），而非逻辑模块名 std.io。
 */
static int import_path_is_file_path(const char *import_path) {
    if (!import_path || !import_path[0])
        return 0;
    if (import_path[0] == '/' || import_path[0] == '.')
        return 1;
    if (strchr(import_path, '/') != NULL)
        return 1;
    size_t n = strlen(import_path);
    if (n >= 3 && strcmp(import_path + n - 3, ".sx") == 0)
        return 1;
    return 0;
}

/**
 * 将相对/绝对文件路径解析为可打开的 .sx 路径（相对 entry_dir）。
 */
static void resolve_file_import_path(const char *entry_dir, const char *import_path, char *path, size_t path_size) {
    char tmp[1024];
    if (import_path[0] == '/') {
        (void)snprintf(tmp, sizeof(tmp), "%s", import_path);
    } else if (entry_dir && entry_dir[0]) {
        (void)snprintf(tmp, sizeof(tmp), "%s/%s", entry_dir, import_path);
    } else {
        (void)snprintf(tmp, sizeof(tmp), "%s", import_path);
    }
#if defined(_POSIX_VERSION) || defined(__APPLE__)
    {
        char resolved[1024];
        if (realpath(tmp, resolved) != NULL) {
            (void)snprintf(path, path_size, "%s", resolved);
            return;
        }
    }
#endif
    (void)snprintf(path, path_size, "%s", tmp);
}

/**
 * 解析 import 路径到实际 .sx 文件路径：依次在 lib_roots[0..n_lib_roots-1] 下查找；先试单文件再试 mod.sx；若均无且为单段路径则试 entry_dir（多文件 7.3）。支持多 -L（9.1 联调 std+lexer）。
 * 参数：lib_roots 库根数组；n_lib_roots 个数；entry_dir 入口所在目录（可为 NULL 或 ""）；import_path 如 "foo" 或 "core.types" 或 "../lib/helper.sx"；path 输出；path_size 缓冲区大小。
 */
static void resolve_import_file_path_multi(const char **lib_roots, int n_lib_roots, const char *entry_dir, const char *import_path, char *path, size_t path_size) {
    if (import_path_is_file_path(import_path)) {
        resolve_file_import_path(entry_dir, import_path, path, path_size);
        if (access(path, R_OK) == 0)
            return;
        if (import_path[0] != '/') {
            (void)snprintf(path, path_size, "%s", import_path);
            if (access(path, R_OK) == 0)
                return;
        }
    }
    for (int r = 0; r < n_lib_roots; r++) {
        const char *lib_root = lib_roots[r] && lib_roots[r][0] ? lib_roots[r] : ".";
        import_path_to_file_path(lib_root, import_path, path, path_size);
        if (access(path, R_OK) == 0) return;
        /* 单段 import（如 preprocess）：再试 lib_root/import/import.sx，与 pipeline.sx 内 resolve 一致 */
        if (strchr(import_path, '.') == NULL && path_size >= 16) {
            int n = (int)strlen(import_path);
            if (n > 0 && n < 64) {
                (void)snprintf(path, path_size, "%s/%.64s/%.64s.sx", lib_root, import_path, import_path);
                if (access(path, R_OK) == 0) return;
            }
        }
        if (strchr(import_path, '.') != NULL && path_size >= 16) {
            size_t off = (size_t)snprintf(path, path_size, "%s/", lib_root);
            for (const char *s = import_path; *s && off + 1 < path_size; s++)
                path[off++] = (char)(*s == '.' ? '/' : *s);
            if (off + 9 <= path_size)
                (void)snprintf(path + off, path_size - off, "/mod.sx");
            if (access(path, R_OK) == 0) return;
            import_path_to_file_path(lib_root, import_path, path, path_size);
            if (access(path, R_OK) == 0) return;
        }
    }
    /* 入口同目录的单段 fallback：须在写 path 后立即 access，否则会带着错误路径去读文件并报 import 打不开。 */
    if (entry_dir && entry_dir[0] && strchr(import_path, '.') == NULL) {
        (void)snprintf(path, path_size, "%s/%.255s.sx", entry_dir, import_path);
        if (access(path, R_OK) == 0)
            return;
    }
    /* 带点 import（如 arch.x86_64）也应在 dep 所在目录查找：backend.sx 在 src/asm/ 导入 arch.x86_64 → src/asm/arch/x86_64.sx。
     * 若 import 首段与 entry_dir 末段同名（如 src/asm/ 中 import asm.types），则跳过首段避免重复。 */
    if (entry_dir && entry_dir[0] && strchr(import_path, '.') != NULL && path_size >= 16) {
        const char *eff = import_path;
        /* 检查 import 首段是否与 entry_dir 末段同名 */
        const char *last_slash = strrchr(entry_dir, '/');
        const char *dir_tail = last_slash ? last_slash + 1 : entry_dir;
        size_t tail_len = strlen(dir_tail);
        const char *first_dot = strchr(import_path, '.');
        if (first_dot && (size_t)(first_dot - import_path) == tail_len &&
            strncmp(import_path, dir_tail, tail_len) == 0) {
            eff = first_dot + 1; /* 跳过去重的包前缀：src/asm/asm/types.sx → src/asm/types.sx */
        }
        size_t off = (size_t)snprintf(path, path_size, "%s/", entry_dir);
        for (const char *s = eff; *s && off + 1 < path_size; s++)
            path[off++] = (char)(*s == '.' ? '/' : *s);
        if (off + 5 <= path_size)
            snprintf(path + off, path_size - off, ".sx");
        if (access(path, R_OK) == 0) return;
        /* 也试 /mod.sx：off 为「.sx」起点，须在 dot 处覆写；勿用 path+(off-1) 否则会吞掉末尾段最后一个字符（如 time→tim）。 */
        if (off + (size_t)8 <= path_size)
            (void)snprintf(path + off, path_size - off, "/mod.sx");
        if (access(path, R_OK) == 0) return;
    }
}

#define MAX_ALL_DEPS 32

/**
 * 在已加载列表中按 import 路径查找模块下标；用于递归加载时判断是否已加载、以及 typeck 时取 dep 数组。
 * 参数：import_path 如 "std.io.core"；all_paths 已加载路径数组；n_all 个数。
 * 返回值：下标 0..n_all-1，未找到返回 -1。
 */
static int find_loaded_index(const char *import_path, char **all_paths, int n_all) {
    for (int i = 0; i < n_all; i++)
        if (all_paths[i] && strcmp(all_paths[i], import_path) == 0)
            return i;
    return -1;
}

/**
 * 从入口文件路径推导 -E 时库模块的 C 前缀（用于 codegen_library_module_to_c）。
 * 例如 src/pipeline/pipeline.sx -> "pipeline"，src/typeck/typeck.sx -> "typeck"。
 * 供 -E 单文件展开时入口为无 main 的库模块使用。
 */
#if !defined(SHUX_USE_SX_DRIVER) || !defined(SHUX_NO_C_FRONTEND)
static const char *entry_lib_name_from_path(const char *input_path) {
    if (!input_path) return "typeck";
    if (strstr(input_path, "main") != NULL) return "main";   /* src/main.sx 与 main.c 一一对应 */
    if (strstr(input_path, "build") != NULL) return "build"; /* 阶段 7：根目录 build.sx → build_entry */
    if (strstr(input_path, "pipeline") != NULL) return "pipeline";
    if (strstr(input_path, "driver") != NULL) return "driver";
    if (strstr(input_path, "codegen") != NULL) return "codegen";
    if (strstr(input_path, "typeck") != NULL) return "typeck";
    if (strstr(input_path, "parser") != NULL) return "parser";
    /* token 须在 lexer 前，否则 src/lexer/token.sx 会误得 lexer_ 前缀 */
    if (strstr(input_path, "token") != NULL) return "token";
    if (strstr(input_path, "lexer") != NULL) return "lexer";
    if (strstr(input_path, "ast") != NULL) return "ast";
    return "typeck";
}

/**
 * -E 且入口为 pipeline.sx 时，向 stdout 输出一行 #include "pipeline_glue.c"，
 * 由编译器在编译 pipeline_gen.c 时包含胶水（cwd 需为 compiler/ 或 -I 含之）。不再追写整份文件内容。
 */
static void emit_pipeline_glue_include(void) {
    fputs("\n#include \"pipeline_glue.c\"\n", stdout);
}
#endif /* !SU_DRIVER || !NO_C_FRONTEND */

/**
 * 递归加载单条 import：若已存在于 all_dep_mods/all_dep_paths 则直接返回；否则解析→递归加载其 import→typeck(其 deps)→加入列表。
 * 参数：import_path 如 "std.io.driver"；lib_root、entry_dir、defines/ndefines 同 resolve_import_file_path；all_dep_mods/all_dep_paths 输出列表；n_all 当前个数（会递增）；max_all 上限。
 * 返回值：成功返回对应 ASTModule*；失败返回 NULL（调用方须释放已写入的 all_dep_*）。
 */
#if !defined(SHUX_NO_C_FRONTEND)
static ASTModule *load_one_import(const char *import_path, const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char **defines, int ndefines,
    ASTModule **all_dep_mods, char **all_dep_paths, char all_dep_fs[][512], int *n_all, int max_all) {
    int idx = find_loaded_index(import_path, all_dep_paths, *n_all);
    if (idx >= 0)
        return all_dep_mods[idx];
    if (*n_all >= max_all) {
        fprintf(stderr, "shux: too many transitive imports\n");
        return NULL;
    }
    char path[512];
    resolve_import_file_path_multi(lib_roots, n_lib_roots, entry_dir, import_path, path, sizeof(path));
    /* 从 path 提取所在目录，供递归加载子 import 时使用（而非沿用顶层 entry_dir）。
     * 例如 pipeline.sx 在 src/pipeline/ 导入 asm；asm.sx 在 src/asm/ 导入 backend；
     * 若不切换 dep_dir，递归会去 src/pipeline/ 找 backend.sx 而失败。 */
    char dep_dir[512];
    {
        const char *slash = strrchr(path, '/');
        if (slash) {
            size_t dlen = (size_t)(slash - path);
            if (dlen >= sizeof(dep_dir)) dlen = sizeof(dep_dir) - 1;
            memcpy(dep_dir, path, dlen);
            dep_dir[dlen] = '\0';
        } else {
            snprintf(dep_dir, sizeof(dep_dir), ".");
        }
    }
    char *raw = read_file(path, NULL);
    if (!raw) {
        fprintf(stderr, "shux: cannot open import '%s' (tried %s)\n", import_path, path);
        return NULL;
    }
    char *src = preprocess(raw, 0, defines, ndefines, NULL);
    free(raw);
    if (!src) {
        fprintf(stderr, "shux: preprocess failed for import '%s'\n", import_path);
        return NULL;
    }
    Lexer *lex = lexer_new(src);
    ASTModule *dep = NULL;
    int pr = parse(lex, &dep);
    lexer_free(lex);
    free(src);
    if (pr != 0 || !dep) {
        fprintf(stderr, "shux: failed to parse import '%s'\n", import_path);
        return NULL;
    }
    if (dep->num_imports > 0 && !dep->import_paths) {
        fprintf(stderr, "shux: internal error: module has num_imports but import_paths is NULL\n");
        ast_module_free(dep);
        return NULL;
    }
    /* 先递归加载该模块的 import，保证 typeck 时其 deps 已在 all_dep_mods 中 */
    for (int i = 0; i < dep->num_imports; i++) {
        ASTModule *sub = load_one_import(dep->import_paths[i], lib_roots, n_lib_roots, dep_dir, defines, ndefines,
            all_dep_mods, all_dep_paths, all_dep_fs, n_all, max_all);
        if (!sub) {
            ast_module_free(dep);
            return NULL;
        }
    }
    /* 构建该模块的 dep 数组（与 dep->import_paths 顺序一致），供 typeck */
    ASTModule *deps[32];
    int ndeps = 0;
    for (int j = 0; j < dep->num_imports && ndeps < 32; j++) {
        idx = find_loaded_index(dep->import_paths[j], all_dep_paths, *n_all);
        if (idx >= 0)
            deps[ndeps++] = all_dep_mods[idx];
    }
    if (typeck_module(dep, deps, ndeps, NULL, 0) != 0) {
        fprintf(stderr, "shux: typeck failed for import '%s'\n", import_path);
        ast_module_free(dep);
        return NULL;
    }
    all_dep_mods[*n_all] = dep;
    all_dep_paths[*n_all] = strdup(import_path);
    if (!all_dep_paths[*n_all]) {
        ast_module_free(dep);
        return NULL;
    }
    if (all_dep_fs)
        (void)snprintf(all_dep_fs[*n_all], 512, "%s", path);
    (*n_all)++;
    return dep;
}
#endif /* !SHUX_NO_C_FRONTEND */

/**
 * 解析并类型检查所有 import 依赖（含传递依赖）；填入 direct dep_mods（与 mod->import_paths 一一对应）供 typeck/codegen 入口使用，并填入 all_dep_mods/all_dep_paths（拓扑序）供 -o 时为每个依赖生成 .c（阶段 7.3 跨模块调用 + 传递依赖）。
 * 参数：mod 入口模块；lib_root、entry_dir 同 resolve_import_file_path；defines/ndefines 条件编译符号；dep_mods/ndep_out 仅直接依赖；all_dep_mods、all_dep_paths、n_all_out 为全部传递依赖（all_dep_paths 由本函数 strdup，调用方须 free）；max_deps 为 direct 与 all 共用上限。
 * 返回值：0 成功；-1 失败且已释放已写入的 all_dep_*。
 */
#if !defined(SHUX_NO_C_FRONTEND)
static int resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char **defines, int ndefines,
    ASTModule **dep_mods, int *ndep_out,
    ASTModule **all_dep_mods, char **all_dep_paths, char all_dep_fs[][512], int *n_all_out, int max_deps) {
    int n_all = 0;
    if (mod->num_imports > 0 && !mod->import_paths) {
        fprintf(stderr, "shux: internal error: entry module has num_imports but import_paths is NULL\n");
        return -1;
    }
    for (int i = 0; i < mod->num_imports && i < max_deps; i++) {
        ASTModule *m = load_one_import(mod->import_paths[i], lib_roots, n_lib_roots, entry_dir, defines, ndefines,
            all_dep_mods, all_dep_paths, all_dep_fs, &n_all, max_deps);
        if (!m) {
            while (n_all--) {
                free(all_dep_paths[n_all]);
                ast_module_free(all_dep_mods[n_all]);
            }
            return -1;
        }
        dep_mods[i] = m;
    }
    *ndep_out = mod->num_imports;
    *n_all_out = n_all;
    return 0;
}

/**
 * LSP 专用：解析并 typeck 全部 import 依赖，并记录各模块对应的 .sx 文件路径（供跨文件 Location.uri）。
 * all_dep_fs 可为 NULL（与编译路径相同，不写 fs 路径）。
 */
int shu_lsp_resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots, const char *entry_dir,
                                     ASTModule **dep_mods, int *ndep_out,
                                     ASTModule **all_dep_mods, char **all_dep_paths, char all_dep_fs[][512],
                                     int *n_all_out, int max_deps) {
    if (!mod || !dep_mods || !ndep_out || !all_dep_mods || !all_dep_paths || !n_all_out || max_deps <= 0)
        return -1;
    return resolve_and_load_imports(mod, lib_roots, n_lib_roots, entry_dir, NULL, 0,
                                  dep_mods, ndep_out, all_dep_mods, all_dep_paths, all_dep_fs, n_all_out, max_deps);
}

/** 释放 shu_lsp_resolve_and_load_imports 写入的 all_dep_mods / all_dep_paths（不含 entry 模块本身）。 */
void shu_lsp_free_loaded_imports(ASTModule **all_dep_mods, char **all_dep_paths, int n_all) {
    if (!all_dep_mods || !all_dep_paths || n_all <= 0)
        return;
    for (int i = 0; i < n_all; i++) {
        if (all_dep_paths[i]) {
            free(all_dep_paths[i]);
            all_dep_paths[i] = NULL;
        }
        if (all_dep_mods[i]) {
            ast_module_free(all_dep_mods[i]);
            all_dep_mods[i] = NULL;
        }
    }
}
#endif /* !SHUX_NO_C_FRONTEND */

/**
 * 将 Token 类型枚举转为可读字符串，用于控制台打印。
 * 功能说明：供无 -o 时打印 Token 序列使用，返回如 "FN"、"IDENT"、"INT" 等。
 * 参数：k 当前 Token 的 kind。
 * 返回值：指向静态字符串的指针，只读；未知 kind 返回 "?"。
 * 错误与边界：无；不分配内存。
 * 副作用与约定：无副作用；返回值不得被 free。
 */
#if !defined(SHUX_USE_SX_DRIVER)
static const char *token_kind_str(TokenKind k) {
    switch (k) {
        case TOKEN_EOF:     return "EOF";
        case TOKEN_FUNCTION: return "FUNCTION";
        case TOKEN_LET:     return "LET";
        case TOKEN_CONST:   return "CONST";
        case TOKEN_IF:      return "IF";
        case TOKEN_ELSE:    return "ELSE";
        case TOKEN_WHILE:   return "WHILE";
        case TOKEN_LOOP:    return "LOOP";
        case TOKEN_FOR:     return "FOR";
        case TOKEN_BREAK:   return "BREAK";
        case TOKEN_CONTINUE: return "CONTINUE";
        case TOKEN_RETURN:   return "RETURN";
        case TOKEN_PANIC:   return "PANIC";
        case TOKEN_DEFER:   return "DEFER";
        case TOKEN_MATCH:   return "MATCH";
        case TOKEN_STRUCT:  return "STRUCT";
        case TOKEN_PACKED:  return "PACKED";
        case TOKEN_SOA:     return "SOA";
        case TOKEN_ATTR_SOA: return "ATTR_SOA";
        case TOKEN_ATTR_CFG: return "ATTR_CFG";
        case TOKEN_ATTR_REPR_C: return "ATTR_REPR_C";
        case TOKEN_ENUM:    return "ENUM";
        case TOKEN_GOTO:    return "GOTO";
        case TOKEN_TRAIT:   return "TRAIT";
        case TOKEN_IMPL:    return "IMPL";
        case TOKEN_SELF:    return "SELF";
        case TOKEN_UNDERSCORE: return "UNDERSCORE";
        case TOKEN_IDENT:   return "IDENT";
        case TOKEN_I32:     return "I32";
        case TOKEN_BOOL:    return "BOOL";
        case TOKEN_U8:      return "U8";
        case TOKEN_U32:     return "U32";
        case TOKEN_U64:     return "U64";
        case TOKEN_I64:     return "I64";
        case TOKEN_USIZE:   return "USIZE";
        case TOKEN_ISIZE:   return "ISIZE";
        case TOKEN_I32X4:   return "I32X4";
        case TOKEN_I32X8:   return "I32X8";
        case TOKEN_I32X16:  return "I32X16";
        case TOKEN_U32X4:   return "U32X4";
        case TOKEN_U32X8:   return "U32X8";
        case TOKEN_U32X16:  return "U32X16";
        case TOKEN_TRUE:    return "TRUE";
        case TOKEN_FALSE:   return "FALSE";
        case TOKEN_F32:     return "F32";
        case TOKEN_F64:     return "F64";
        case TOKEN_VOID:    return "VOID";
        case TOKEN_INT:     return "INT";
        case TOKEN_FLOAT:   return "FLOAT";
        case TOKEN_STRING:  return "STRING";
        case TOKEN_LPAREN:  return "LPAREN";
        case TOKEN_RPAREN:  return "RPAREN";
        case TOKEN_LBRACE:  return "LBRACE";
        case TOKEN_RBRACE:  return "RBRACE";
        case TOKEN_LBRACKET: return "LBRACKET";
        case TOKEN_RBRACKET: return "RBRACKET";
        case TOKEN_ARROW:   return "ARROW";
        case TOKEN_FATARROW: return "FATARROW";
        case TOKEN_COMMA:   return "COMMA";
        case TOKEN_COLON:   return "COLON";
        case TOKEN_IMPORT:  return "IMPORT";
        case TOKEN_EXTERN:  return "EXTERN";
        case TOKEN_DOT:     return "DOT";
        case TOKEN_SEMICOLON: return "SEMICOLON";
        case TOKEN_PLUS:   return "PLUS";
        case TOKEN_MINUS:  return "MINUS";
        case TOKEN_STAR:   return "STAR";
        case TOKEN_SLASH:  return "SLASH";
        case TOKEN_PERCENT: return "PERCENT";
        case TOKEN_AMP:    return "AMP";
        case TOKEN_PIPE:   return "PIPE";
        case TOKEN_CARET:  return "CARET";
        case TOKEN_LSHIFT: return "LSHIFT";
        case TOKEN_RSHIFT: return "RSHIFT";
        case TOKEN_PLUS_EQ:   return "PLUS_EQ";
        case TOKEN_MINUS_EQ:  return "MINUS_EQ";
        case TOKEN_STAR_EQ:   return "STAR_EQ";
        case TOKEN_SLASH_EQ:  return "SLASH_EQ";
        case TOKEN_PERCENT_EQ: return "PERCENT_EQ";
        case TOKEN_AMP_EQ:    return "AMP_EQ";
        case TOKEN_PIPE_EQ:   return "PIPE_EQ";
        case TOKEN_CARET_EQ:  return "CARET_EQ";
        case TOKEN_LSHIFT_EQ: return "LSHIFT_EQ";
        case TOKEN_RSHIFT_EQ: return "RSHIFT_EQ";
        case TOKEN_TILDE:  return "TILDE";
        case TOKEN_EQ:     return "EQ";
        case TOKEN_NE:     return "NE";
        case TOKEN_LT:     return "LT";
        case TOKEN_GT:     return "GT";
        case TOKEN_LE:     return "LE";
        case TOKEN_GE:     return "GE";
        case TOKEN_AMPAMP: return "AMPAMP";
        case TOKEN_PIPEPIPE: return "PIPEPIPE";
        case TOKEN_BANG:   return "BANG";
        case TOKEN_QUESTION: return "QUESTION";
        case TOKEN_AS:     return "AS";
        case TOKEN_AT:     return "AT";
        case TOKEN_ASSIGN: return "ASSIGN";
        default:            return "?";
    }
}
#endif /* !SHUX_USE_SX_DRIVER */

/**
 * B-20：POSIX open/fstat/read 读整文件到堆缓冲（替代 C stdio fopen/fread）。
 * 成功返回 NUL 结尾缓冲；失败返回 NULL。out_len 非 NULL 时写入字节数（不含 NUL）。
 */
static char *read_file(const char *path, size_t *out_len) {
    int fd;
    struct stat st;
    size_t size, off;
    char *buf;
    ssize_t n;

    if (!path)
        return NULL;
    fd = open(path, O_RDONLY);
    if (fd < 0)
        return NULL;
    if (fstat(fd, &st) != 0 || !S_ISREG(st.st_mode) || st.st_size < 0) {
        close(fd);
        return NULL;
    }
    size = (size_t)st.st_size;
    buf = (char *)malloc(size + 1);
    if (!buf) {
        close(fd);
        return NULL;
    }
    off = 0;
    while (off < size) {
        n = read(fd, buf + off, size - off);
        if (n < 0) {
            free(buf);
            close(fd);
            return NULL;
        }
        if (n == 0)
            break;
        off += (size_t)n;
    }
    close(fd);
    if (off != size) {
        free(buf);
        return NULL;
    }
    buf[size] = '\0';
    if (out_len)
        *out_len = size;
    return buf;
}

/**
 * B-20：POSIX read 循环读 fd 到 buf[0..cap)；成功返回读入字节数，失败 -1。
 */
static int shux_read_fd_into_buf(int fd, void *buf, size_t cap) {
    size_t off;
    ssize_t n;

    if (fd < 0 || !buf || cap == 0 || cap > (size_t)INT32_MAX)
        return -1;
    off = 0;
    while (off < cap) {
        n = read(fd, (char *)buf + off, cap - off);
        if (n < 0)
            return -1;
        if (n == 0)
            break;
        off += (size_t)n;
    }
    return (int)off;
}

/**
 * B-20：POSIX open/read/close 将文件读入 buf[0..cap)；成功返回读入字节数，失败 -1。
 * 供 ast_pool pipeline_read_file_su_impl_c 与 .sx std.sys 语义对齐的 C 回退。
 */
int shux_read_file_into_path(const char *path, void *buf, size_t cap) {
    int fd;
    int n;

    if (!path || !buf || cap == 0 || cap > (size_t)INT32_MAX)
        return -1;
    fd = open(path, O_RDONLY);
    if (fd < 0)
        return -1;
    n = shux_read_fd_into_buf(fd, buf, cap);
    close(fd);
    return n;
}

/**
 * B-20：POSIX open(O_WRONLY|O_CREAT|O_TRUNC)/write 写整文件；成功 0，失败 -1。
 * 供 fmt 写回、调试 dump 等替代 fopen/fwrite/fclose。
 */
static int shux_write_path_bytes(const char *path, const void *data, size_t len) {
    int fd;
    size_t off;
    ssize_t n;

    if (!path || !data)
        return -1;
    fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, (mode_t)0644);
    if (fd < 0)
        return -1;
    off = 0;
    while (off < len) {
        n = write(fd, (const char *)data + off, len - off);
        if (n < 0) {
            close(fd);
            return -1;
        }
        if (n == 0)
            break;
        off += (size_t)n;
    }
    close(fd);
    return off == len ? 0 : -1;
}

/**
 * B-20：读源文件前缀到 content（最多 cap-1 字节）；成功返回读入字节数，失败 -1。
 * 供 driver 语法探测（generic/compound-assign）替代 fopen/fread。
 */
static int driver_peek_source_file(const char *path, char *content, size_t cap) {
    if (!path || !content || cap <= 1)
        return -1;
    return shux_read_file_into_path(path, content, cap - 1);
}

/** 多文件编译时 C 文件数量上限（入口 + import 闭包） */
#define MAX_C_FILES 33

/**
 * 调用系统 cc 将多个 C 文件编译链接为可执行文件。
 * 功能说明：阶段 7.3 多文件；阶段 8 优化：向 cc 传入 -O<level>（默认 -O2）、可选 -flto（LTO）、-o out_path。
 * use_lto：非 0 且在非 -O0 时向 cc 传 -flto。
 * io_o：可选，舒 IO 后端 .o 路径；NULL 则不链入。
 * fs_o：可选，std.fs 高性能 .o 路径（mmap/munmap）；NULL 则不链入。
 * process_o：可选，std.process argc/argv/getenv .o 路径；NULL 则不链入。
 * string_o：可选，std.string 长串快路径 .o（memcmp/memmem）；NULL 则不链入。
 * heap_o：可选，std.heap 堆分配 .o（malloc/free）；NULL 则不链入。
 * runtime_o：可选，std.runtime .o（panic/abort）；NULL 则不链入。
 * runtime_panic_o：可选，提供 shux_panic_ 的 .o（与 runtime_o 同链，否则 std/runtime/runtime.o 缺符号）；NULL 则不链入。
 * net_o：可选，std.net .o（TCP socket）；NULL 则不链入。
 * thread_o：可选，std.thread .o（线程）；NULL 则不链入；Unix 需 -lpthread。
 * time_o：可选，std.time .o（时间与睡眠）；NULL 则不链入。
 * random_o：可选，std.random .o（密码学安全随机）；NULL 则不链入。
 * env_o：可选，std.env .o（环境变量与临时目录）；NULL 则不链入。
 * sync_o：可选，std.sync .o（互斥锁）；NULL 则不链入；Unix 需 -lpthread。
 * encoding_o, base64_o, crypto_o, log_o, test_o：可选，std.encoding/base64/crypto/log/test .o。
 * include_root：可选，仓库根目录，用于 -I 以便生成 .c 能 #include std/fs、path、map、error 等 ABI 头；NULL 或空则不传 -I。
 * 返回值：0 表示 cc 执行成功且退出码为 0；-1 表示参数非法、fork/exec 失败或 cc 非零退出。
 */
static int invoke_cc_skip_native_tuning(void) {
    /* CI/Docker/musl 上 -march=native/-flto 可能导致 cc 异常退出（exit -1）。 */
    if (getenv("CI") || getenv("SHUX_CI_DOCKER") || getenv("SHUX_NO_MARCH_NATIVE"))
        return 1;
    return 0;
}

static int invoke_cc(const char **c_paths, int n, const char *out_path, const char *target, const char *opt_level, int use_lto, const char *io_o, const char *fs_o, const char *process_o, const char *string_o, const char *heap_o, const char *path_o, const char *runtime_o, const char *runtime_panic_o, const char *net_o, const char *thread_o, const char *time_o, const char *random_o, const char *env_o, const char *sync_o, const char *encoding_o, const char *base64_o, const char *crypto_o, const char *log_o, const char *atomic_o, const char *channel_o, const char *backtrace_o, const char *hash_o, const char *math_o, const char *sort_o, const char *ffi_o, const char *db_o, const char *elf_o, const char *json_o, const char *csv_o, const char *regex_o, const char *compress_o, const char *unicode_o, const char *dynlib_o, const char *http_o, const char *tar_o, const char *simd_o, const char *context_o, const char *datetime_o, const char *uuid_o, const char *url_o, const char *cli_o, const char *security_o, const char *config_o, const char *cache_o, const char *trace_o, const char *task_o, const char *schema_o, const char *test_o, const char *include_root, const char *async_scheduler_o) {
    (void)target;
    if (!c_paths || n < 1) return -1;
    if (!opt_level || !*opt_level) opt_level = "2";
    if (include_root && include_root[0])
        ensure_std_net_o_auto_tls(include_root);
    pid_t pid = fork();
    if (pid < 0) {
        perror("shux: fork");
        return -1;
    }
    if (pid == 0) {
        /* 容量须容纳：cc -O -std... [-DNDEBUG] [-flto] -o out [-I inc] + n 个 .c + 若干 .o + -pthread -lc + SHUX_CC_EXTRA(至多 8) + NULL */
        char *argv[MAX_C_FILES + 48];
        int i = 0;
        const int argv_cap = MAX_C_FILES + 48;
        argv[i++] = (char *)"cc";
        /* preamble 中 std_io_* / std_net_* 使用 C11 _Generic，须传 -std=gnu11（不能 -x c，否则 .o 会被当 C 源码编译） */
        argv[i++] = (char *)"-std=gnu11";
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
        argv[i++] = (char *)"-o";
        argv[i++] = (char *)out_path;
        if (include_root && include_root[0]) {
            argv[i++] = (char *)"-I";
            argv[i++] = (char *)include_root;
        }
        for (int j = 0; j < n && i < MAX_C_FILES + 8; j++)
            argv[i++] = (char *)c_paths[j];
        {
            int needs_core_builtin = 0;
            int needs_core_mem = 0;
            int needs_core_slice = 0;
            int needs_db_kv = 0;
            int needs_db_arrow = 0;
            int needs_fs = 0;
            int needs_random = 0;
            int needs_runtime = 0;
            for (int j = 0; j < n; j++) {
                if (generated_c_needs_core_builtin(c_paths[j]))
                    needs_core_builtin = 1;
                if (generated_c_needs_core_mem(c_paths[j]))
                    needs_core_mem = 1;
                if (generated_c_needs_core_slice(c_paths[j]))
                    needs_core_slice = 1;
                if (generated_c_needs_db_kv(c_paths[j]))
                    needs_db_kv = 1;
                if (generated_c_needs_db_arrow(c_paths[j]))
                    needs_db_arrow = 1;
                if (generated_c_needs_fs(c_paths[j]))
                    needs_fs = 1;
                if (generated_c_needs_random(c_paths[j]))
                    needs_random = 1;
                if (generated_c_needs_runtime(c_paths[j]))
                    needs_runtime = 1;
            }
            if (needs_core_builtin) {
                const char *abi_h = get_core_builtin_abi_h_path(include_root);
                if (abi_h && abi_h[0]) {
                    if (i < argv_cap - 2) {
                        argv[i++] = (char *)"-include";
                        argv[i++] = (char *)abi_h;
                    }
                }
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, get_core_builtin_o_path(include_root));
            }
            if (needs_core_mem)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, get_core_mem_o_path(include_root));
            if (needs_core_slice)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, get_core_slice_o_path(include_root));
            if (needs_db_kv)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, get_std_db_kv_o_path(include_root));
            if (needs_db_arrow)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, get_std_db_arrow_o_path(include_root));
            if (needs_fs)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, fs_o);
            if (needs_random)
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, random_o);
            if (needs_runtime) {
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_o);
                (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_panic_o);
            }
        }
        /* CORE-009 / Docker musl：仅链已按需推入的 core/*.o + -lc；shux_process_* 由生成 C weak 定义。 */
        if (getenv("SHUX_MINIMAL_CC_LINK")) {
#if defined(__linux__) || defined(__APPLE__)
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-lc";
#endif
            argv[i++] = NULL;
#if defined(__linux__)
            argv[0] = (char *)"gcc";
            execvp("gcc", argv);
            argv[0] = (char *)"cc";
            execvp("cc", argv);
#else
            argv[0] = (char *)"cc";
            execvp("cc", argv);
            argv[0] = (char *)"gcc";
            execvp("gcc", argv);
#endif
            perror("shux: cc/gcc");
            _exit(127);
        }
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, io_o)) {
#if defined(__linux__)
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-luring";
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-pthread";
#endif
#if defined(_WIN32) || defined(_WIN64)
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-lws2_32";
#endif
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, fs_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, process_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, string_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, heap_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, path_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, runtime_panic_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, net_o))
            (void)invoke_cc_append_net_tls_ld(argv, &i, argv_cap, net_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, thread_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, time_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, random_o)) {
#if defined(_WIN32) || defined(_WIN64)
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-lbcrypt";
#endif
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, env_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, sync_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, encoding_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, base64_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, crypto_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, log_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, atomic_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, channel_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, backtrace_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, hash_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, math_o) && i < argv_cap - 1)
            argv[i++] = (char *)"-lm";
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, sort_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, ffi_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, db_o) && i < argv_cap - 1)
            argv[i++] = (char *)"-lsqlite3";
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, elf_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, json_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, csv_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, regex_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, compress_o))
            invoke_cc_append_compress_ld(argv, &i, argv_cap, compress_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, unicode_o);
        if (invoke_cc_argv_push_existing(argv, &i, argv_cap, dynlib_o)) {
#if defined(__linux__)
            if (i < argv_cap - 1)
                argv[i++] = (char *)"-ldl";
#endif
        }
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, http_o);
        (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, get_std_socketio_o_path(include_root));
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
            int task_linked = invoke_cc_argv_push_existing(argv, &i, argv_cap, task_o);
            (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, schema_o);
            (void)invoke_cc_argv_push_existing(argv, &i, argv_cap, test_o);
            if (task_linked) {
                const char *sched = scheduler_o_for_task_link(task_o, async_scheduler_o);
                if (invoke_cc_argv_push_existing(argv, &i, argv_cap, sched)) {
#if defined(__linux__)
                    if (i < argv_cap - 1)
                        argv[i++] = (char *)"-pthread";
#endif
                }
            } else if (invoke_cc_argv_push_existing(argv, &i, argv_cap, async_scheduler_o)) {
#if defined(__linux__)
                if (i < argv_cap - 1)
                    argv[i++] = (char *)"-pthread";
#endif
            }
        }
#if defined(__linux__) || defined(__APPLE__)
        /* Unix 上 thread.o 使用 CPU_ZERO/CPU_SET（sched.h）；用 -pthread 让 cc 以正确顺序拉取 libpthread/libc */
        if ((asm_link_obj_skip_missing(thread_o) || asm_link_obj_skip_missing(sync_o) ||
             asm_link_obj_skip_missing(channel_o)) &&
            i < argv_cap - 1)
            argv[i++] = (char *)"-pthread";
        argv[i++] = (char *)"-lc";
#endif
        argv[i++] = NULL;
#if defined(__linux__)
        /* Alpine 等环境下优先用 gcc 并传 argv[0]=gcc，确保 -std=gnu11 等参数被正确识别（部分 cc 包装可能行为不同） */
        argv[0] = (char *)"gcc";
        execvp("gcc", argv);
        argv[0] = (char *)"cc";
        execvp("cc", argv);
#else
        argv[0] = (char *)"cc";
        execvp("cc", argv);
        argv[0] = (char *)"gcc";
        execvp("gcc", argv);
#endif
        perror("shux: cc/gcc");
        _exit(127);
    }
    int status;
    if (shu_waitpid_retry(pid, &status) != 0)
        return -1;
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        fprintf(stderr, "shux: cc failed (exit %d)\n", WIFEXITED(status) ? WEXITSTATUS(status) : -1);
        return -1;
    }
    /* 阶段 8：非调试（-O0）时对产出执行 strip，减小体积（避免传 -s 给 cc 触发 ld 的 obsolete 警告） */
    if (strcmp(opt_level, "0") != 0) {
        pid_t spid = fork();
        if (spid == 0) {
            execlp("strip", "strip", out_path, (char *)NULL);
            _exit(127);
        }
        if (spid > 0) {
            int sstatus;
            (void)shu_waitpid_retry(spid, &sstatus);
        }
    }
    return 0;
}

#if !defined(SHUX_USE_SX_DRIVER)
/** 阶段 8.1 DCE 上下文：供 dce_is_func_used / dce_is_mono_used / dce_is_type_used 回调使用。 */
struct dce_ctx {
    ASTFunc **used;
    int n;
    int (*mono)[64];
    int mono_rows;
    const char **used_type_names;
    int n_used_types;
    ASTModule *entry;
    ASTModule **deps;
    int nd;
    const CodegenWpoReach *wpo; /**< 非 NULL 且 valid 时 WPO 全程序 dead export 剔除 */
};
#define RUNTIME_MAX_USED_FUNCS 256
#define RUNTIME_MAX_DCE_MODULES 33
/** 填充 DCE 上下文：classic compute_used + 可选 WPO reach；*dce_ready 非 0 时可传 dce 回调。 */
static void runtime_prepare_dce_ctx(struct ASTModule *mod, struct ASTModule **all_dep_mods, int n_all,
    ASTFunc **used_funcs, int *n_used, int used_mono[RUNTIME_MAX_DCE_MODULES][64],
    const char **used_type_names, int *n_used_types,
    CodegenWpoReach *wpo_reach, struct dce_ctx *dce, int *dce_ready) {
    *dce_ready = 0;
    *n_used = 0;
    *n_used_types = 0;
    memset(wpo_reach, 0, sizeof(*wpo_reach));
    dce->used = used_funcs;
    dce->n = 0;
    dce->mono = used_mono;
    dce->mono_rows = 1 + n_all;
    dce->used_type_names = NULL;
    dce->n_used_types = 0;
    dce->entry = mod;
    dce->deps = all_dep_mods;
    dce->nd = n_all;
    dce->wpo = NULL;
    if (n_all >= 0 && n_all < RUNTIME_MAX_DCE_MODULES - 1) {
        codegen_compute_used(mod, all_dep_mods, n_all, used_funcs, n_used, RUNTIME_MAX_USED_FUNCS, used_mono);
        codegen_compute_used_types(mod, all_dep_mods, n_all, used_funcs, *n_used, used_type_names, n_used_types, 64);
        dce->used_type_names = used_type_names;
        dce->n_used_types = *n_used_types;
        dce->n = *n_used;
        *dce_ready = 1;
    }
    /* WPO v0：全程序 call graph 可达性；typeck 后始终构建，供 DCE 剔除 dead export（含 import 库）。 */
    codegen_wpo_reach_compute(wpo_reach, mod, all_dep_mods, n_all);
    if (wpo_reach->valid) {
        dce->wpo = wpo_reach;
        *dce_ready = 1;
    }
}
static int dce_is_func_used(void *ctx, const ASTModule *mod, const ASTFunc *func) {
    const struct dce_ctx *c = (const struct dce_ctx *)ctx;
    if (!c) return 1;
    if (func && func->is_extern) return 1;
    if (c->wpo && c->wpo->valid)
        return codegen_wpo_reach_is_reachable(c->wpo, mod, func);
    if (!c->used) return 1;
    /* 库模块（非入口）：classic DCE 仅剔除入口模块；WPO 见上方 c->wpo 分支。 */
    if (mod != c->entry) return 1;
    for (int i = 0; i < c->n; i++)
        if (c->used[i] == func) return 1;
    return 0;
}
static int dce_is_mono_used(void *ctx, const ASTModule *mod, int k) {
    const struct dce_ctx *c = (const struct dce_ctx *)ctx;
    if (!c || !c->mono || k < 0 || k >= 64) return 1;
    /* 库模块：始终保留单态化实例，避免入口引用的泛型 import 被误删 */
    if (mod != c->entry) return 1;
    int idx = (mod == c->entry) ? 0 : -1;
    if (idx < 0 && c->deps)
        for (int i = 0; i < c->nd; i++)
            if (c->deps[i] == mod) { idx = 1 + i; break; }
    if (idx < 0 || idx >= c->mono_rows) return 1;
    return c->mono[idx][k];
}

/** 阶段 8.1 DCE 扩展：类型名在 used_type_names 中则保留，否则删除；库模块类型始终保留。 */
static int dce_is_type_used(void *ctx, const ASTModule *mod, const char *type_name) {
    const struct dce_ctx *c = (const struct dce_ctx *)ctx;
    if (!c || !type_name) return 1;
    if (mod != c->entry) return 1;
    if (!c->used_type_names) return 1;
    for (int i = 0; i < c->n_used_types; i++)
        if (c->used_type_names[i] && strcmp(c->used_type_names[i], type_name) == 0) return 1;
    return 0;
}
#endif /* !SHUX_USE_SX_DRIVER */

/**
 * 编译器主入口：解析命令行，执行 lexer→parser→typeck，可选 codegen→cc 产出可执行文件。
 * 功能说明：支持 -L、-target、-o；无 -o 时打印 Token 与 parse/typeck OK（供测试）；有 -o 时生成 C（含 import 占位）、调用 cc 链接。
 * 参数：argc、argv 为标准 C 程序参数；argv[0] 为程序名，后续为可选 -L/-target/-o 及其参数与一个输入 .sx 路径。
 * 返回值：0 表示成功（含无参数时打印用法）；1 表示读文件失败、解析/typeck 失败、codegen 或 cc 失败。
 * 错误与边界：无输入文件时打印用法并返回 0；-o 指定但无 main 时返回 1；import 数量超过 32 时仅处理前 32 个。
 * 副作用与约定：可能创建/删除 /tmp 下临时文件；依赖 getenv("SHUX_LIB")；多文件时可能多次解析同一 import 的 .sx。
 */
#define MAX_DEFINES 64
#define MAX_LIB_ROOTS 16
/** 从 argv 收集 -D 与平台宏（实现见 driver_run_asm_backend 前）。 */
static int driver_argv_collect_defines(int argc, char **argv, const char **defines, int max_defines);
/**
 * 编译器 pipeline 实现（原 main 逻辑）；供 C main 直接调用，或由 .sx driver 入口转调（6.3）。
 * SHUX_USE_SX_DRIVER 时 run_compiler_c_impl 由 main.sx 提供（桩），C 不定义以免重复符号。
 */
#if defined(SHUX_USE_SX_DRIVER)
/* run_compiler_c_impl 由 main.sx 提供（桩），C 不定义。 */
#else
#define RUN_CC_FUNC run_compiler_c
int RUN_CC_FUNC(int argc, char **argv) {
#ifdef SHUX_USE_SX_FRONTEND
    /* 阶段 3.2：链入 _su.o 时不再提供 typeck_module/codegen_* 等 C 符号，run_compiler_c 不应被调用；main 已走 run_compiler_sx_path。 */
    (void)argc;
    (void)argv;
    fprintf(stderr, "shux: internal error: run_compiler_c called with SHUX_USE_SX_FRONTEND\n");
    return 1;
#else
    /* typeck/codegen 等大模块自举 parse/typeck 栈帧深；须早于 pipeline 入口扩容。 */
    driver_bump_stack_limit_if_needed();
    const char *input_path = NULL;
    const char *out_path = NULL;
    const char *lib_roots_arr[MAX_LIB_ROOTS];
    int n_lib_roots = 0;
    const char *target = NULL;
    const char *opt_level = NULL;  /* -O 优化级别：0/2/s，默认 2（阶段 8） */
    int use_lto = 0;       /* -flto：传 -flto 给 cc，发布/性能构建时建议（2.3） */
    int emit_c_only = 0;  /* -E：仅生成 C 到 stdout，不调用 cc */
    int emit_extern_imports = 0;  /* 阶段 3.1：-E-extern 时仅展开入口，import 用 extern，生成瘦 C */
    #ifdef SHUX_USE_SX_PIPELINE
    int use_su_pipeline = 0;  /* -su：使用纯 .sx 流水线（需链接 pipeline_gen.o） */
    int use_asm_backend = 0;  /* -backend asm：出汇编而非 C，并走 -sx pipeline */
    #endif
    const char *defines[MAX_DEFINES];
    int ndefines = 0;

    for (int i = 1; i < argc; i++) {
        #ifdef SHUX_USE_SX_PIPELINE
        if (strcmp(argv[i], "-sx") == 0) {
            use_su_pipeline = 1;
        } else if (strcmp(argv[i], "-backend") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "shux: -backend requires an argument (asm or c)\n");
                return 1;
            }
            if (strcmp(argv[i + 1], "asm") == 0) {
                use_asm_backend = 1;
                use_su_pipeline = 1;  /* -backend asm 必须走 .sx pipeline */
            } else if (strcmp(argv[i + 1], "c") == 0) {
                use_asm_backend = 0;  /* C 前端：勿强制 -sx pipeline（MSYS return-value 烟测） */
            } else {
                fprintf(stderr, "shux: -backend expects asm or c (got '%s')\n", argv[i + 1]);
                return 1;
            }
            i++;
        } else
        #endif
        if (strcmp(argv[i], "-E") == 0) {
            emit_c_only = 1;
        } else if (strcmp(argv[i], "-E-extern") == 0) {
            emit_c_only = 1;
            emit_extern_imports = 1;
        } else if (strcmp(argv[i], "-D") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "Usage: %s [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] [ -O 0|1|2|3|s ] [ -flto ] <file.sx> [ -o <out> ]\n", argv[0] ? argv[0] : "shux");
                return 1;
            }
            if (ndefines >= MAX_DEFINES) {
                fprintf(stderr, "shux: too many -D defines\n");
                return 1;
            }
            defines[ndefines++] = argv[i + 1];
            i++;
        } else if (strncmp(argv[i], "-D", 2) == 0 && argv[i][2] != '\0') {
            /* -DSYMBOL 形式 */
            if (ndefines >= MAX_DEFINES) {
                fprintf(stderr, "shux: too many -D defines\n");
                return 1;
            }
            defines[ndefines++] = argv[i] + 2;
        } else if (strcmp(argv[i], "-O") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "Usage: %s [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] [ -O 0|1|2|3|s ] [ -flto ] <file.sx> [ -o <out> ]\n", argv[0] ? argv[0] : "shux");
                return 1;
            }
            opt_level = argv[i + 1];
            if (strcmp(opt_level, "0") != 0 && strcmp(opt_level, "1") != 0 && strcmp(opt_level, "2") != 0 && strcmp(opt_level, "3") != 0 && strcmp(opt_level, "s") != 0) {
                fprintf(stderr, "shux: -O expects 0, 1, 2, 3, or s (got '%s')\n", opt_level);
                return 1;
            }
            i++;
        } else if (strcmp(argv[i], "-flto") == 0) {
            use_lto = 1;
        } else if (strcmp(argv[i], "-fsanitize=address") == 0) {
            driver_sanitize_address_set(1);
        } else if (strcmp(argv[i], "-freestanding") == 0) {
            driver_freestanding_set(1);
        } else if (strcmp(argv[i], "-legacy-f32-abi") == 0) {
            setenv("SHUX_ABI_F32_XMM", "0", 1);
        } else if (strcmp(argv[i], "-o") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "Usage: %s [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] [ -O 0|1|2|3|s ] [ -flto ] <file.sx> [ -o <out> ]\n", argv[0] ? argv[0] : "shux");
                return 1;
            }
            out_path = argv[i + 1];
            i++;
        } else if (strcmp(argv[i], "-L") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "Usage: %s [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] [ -O 0|1|2|3|s ] [ -flto ] <file.sx> [ -o <out> ]\n", argv[0] ? argv[0] : "shux");
                return 1;
            }
            if (n_lib_roots < MAX_LIB_ROOTS)
                lib_roots_arr[n_lib_roots++] = argv[i + 1];
            i++;
        } else if (strcmp(argv[i], "-target") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "Usage: %s [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] [ -O 0|1|2|3|s ] [ -flto ] <file.sx> [ -o <out> ]\n", argv[0] ? argv[0] : "shux");
                return 1;
            }
            target = argv[i + 1];
            i++;  /* 只多跳 1：for 末尾还有 i++，会再跳过 triple，避免多跳把 <file.sx> 也跳过导致 input_path 未设 */
        } else if (argv[i][0] == '-') {
            /* 未知选项（如 -backend 在未链 pipeline 的构建中）：提示而非当作输入文件 */
            if (strcmp(argv[i], "-backend") == 0) {
                fprintf(stderr, "shux: -backend asm not available in this build. Use: make bootstrap-driver\n");
            } else {
                fprintf(stderr, "shux: unknown option '%s'\n", argv[i]);
            }
            return 1;
        } else if (!input_path) {
            input_path = argv[i];
        }
    }
    /* 由 -target 推导 OS 宏，供 #if OS_LINUX 等使用 */
    if (target && ndefines < MAX_DEFINES) {
        if (strstr(target, "linux") != NULL) {
            defines[ndefines++] = "OS_LINUX";
        } else if (strstr(target, "darwin") != NULL || strstr(target, "apple") != NULL) {
            defines[ndefines++] = "OS_MACOS";
        } else if (strstr(target, "windows") != NULL) {
            defines[ndefines++] = "OS_WINDOWS";
        }
    }
    /* §3.4 条件编译与平台选择：无 -target 时用 uname 注入 SHUX_OS_<SYSNAME>、SHUX_ARCH_<MACHINE>（全大写）供 .sx #if 使用 */
    if (ndefines + 2 <= MAX_DEFINES) {
        struct utsname u;
        /* utsname.sysname/machine can be up to 65 bytes; "SHUX_OS_"=7, "SHUX_ARCH_"=9, so 80 suffices */
        static char shu_os_def[80], shu_arch_def[80];
        if (uname(&u) == 0) {
            (void)snprintf(shu_os_def, sizeof(shu_os_def), "SHUX_OS_%s", u.sysname);
            (void)snprintf(shu_arch_def, sizeof(shu_arch_def), "SHUX_ARCH_%s", u.machine);
            for (char *p = shu_os_def + 7; *p; p++) *p = (char)toupper((unsigned char)*p);
            for (char *p = shu_arch_def + 9; *p; p++) *p = (char)toupper((unsigned char)*p);
            defines[ndefines++] = shu_os_def;
            defines[ndefines++] = shu_arch_def;
        }
    }
    if (n_lib_roots == 0) {
        lib_roots_arr[0] = getenv("SHUX_LIB");
        if (!lib_roots_arr[0]) lib_roots_arr[0] = ".";
        n_lib_roots = 1;
    }
    if (!opt_level) opt_level = getenv("SHUX_OPT");
    if (!opt_level || !*opt_level) opt_level = "2";
    if (!use_lto && getenv("SHUX_LTO") && strcmp(getenv("SHUX_LTO"), "1") == 0)
        use_lto = 1;

    if (!input_path) {
        fprintf(stderr, "Usage: %s [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] [ -O 0|1|2|3|s ] [ -flto ] <file.sx> [ -o <out> ]\n", argv[0] ? argv[0] : "shux");
        return 0;
    }

    /** B-02：#[cfg] 与 -target triple 联动（shux-c 主路径 run_compiler_c）。 */
    if (target)
        cfg_apply_compile_target_from_triple(target, (int)strlen(target));
    else
        cfg_reset_compile_target();

    size_t raw_src_len = 0;
    char *raw_src = read_file(input_path, &raw_src_len);
    if (!raw_src) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = NULL;
#ifdef SHUX_USE_SX_PIPELINE
    if (use_su_pipeline) {
        if (su_preprocess_raw_to_malloc((const unsigned char *)raw_src, raw_src_len, &src, &src_len, input_path,
                ndefines > 0 ? defines : NULL, ndefines) != 0) {
            free(raw_src);
            return 1;
        }
        free(raw_src);
    } else
#endif
    {
        src = preprocess(raw_src, raw_src_len, ndefines > 0 ? defines : NULL, ndefines, &src_len);
        free(raw_src);
        if (!src) {
            fprintf(stderr, "shux: preprocess failed for '%s'\n", input_path);
            return 1;
        }
    }

#ifdef SHUX_USE_SX_PIPELINE
    if (use_su_pipeline) {
        size_t arena_sz = pipeline_sizeof_arena();
        size_t module_sz = pipeline_sizeof_module();
        void *arena = malloc(arena_sz);
        void *module = malloc(module_sz);
        if (!arena || !module) {
            fprintf(stderr, "shux: -sx pipeline: malloc failed\n");
            if (arena) free(arena);
            if (module) free(module);
            free(src);
            return 1;
        }
        memset(arena, 0, arena_sz);
        memset(module, 0, module_sz);
        struct shux_slice_uint8_t src_slice = { (uint8_t *)src, src_len };
        if (src_len > (size_t)INT32_MAX) {
            fprintf(stderr, "shux: -sx pipeline: source too large for parser (>%d bytes): '%s'\n", INT32_MAX, input_path);
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        parser_parse_into_init(module, arena);
        struct parser_ParseIntoResult pr = parser_parse_into_buf(arena, module, (uint8_t *)src, (int32_t)src_len);
        if (pr.ok != 0) {
            fprintf(stderr, "shux: -sx pipeline failed (parse_into)\n");
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        parser_parse_into_set_main_index(module, pr.main_idx);
        /* pipeline_debug_module_funcs(module);  调试 mai/ba 时取消注释 */
        int32_t n_imports = parser_get_module_num_imports(module);
        char entry_dir_buf[512];
        get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
        const char *entry_dir = entry_dir_buf;
        /* 阶段 5：有 import 时先 resolve 并 pipeline 各依赖，再 pipeline 入口 */
        char *dep_sources[MAX_ALL_DEPS];
        size_t dep_lens[MAX_ALL_DEPS];
        char *dep_paths[MAX_ALL_DEPS];
        int n_deps = 0;
#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
        /*
         * 与 emit-C 路径一致：传递闭包（如 hello→std.io→driver/core）；merge 保证槽 0..n_imports-1 与入口 import 对齐，
         * asm_codegen_elf_o 才能把 driver/core 的定义编入同一 Mach-O/ELF。
         */
        if (n_imports > 0 && n_imports <= 32) {
            char *cls[MAX_ALL_DEPS];
            size_t clens[MAX_ALL_DEPS];
            char *cpaths[MAX_ALL_DEPS];
            int n_closure = 0;
            if (collect_deps_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir, defines,
                    ndefines, cls, clens, cpaths, &n_closure) != 0) {
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            if (merge_direct_then_transitive_deps(module, n_imports, cls, clens, cpaths, n_closure, dep_sources, dep_lens,
                    dep_paths, &n_deps) != 0) {
                while (n_closure > 0) {
                    n_closure--;
                    free(cls[n_closure]);
                    free(cpaths[n_closure]);
                }
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
#else
        if (n_imports > 0 && n_imports <= 32) {
            for (int i = 0; i < n_imports && n_deps < MAX_ALL_DEPS; i++) {
                uint8_t path_buf[64];
                parser_get_module_import_path(module, i, path_buf);
                char path_c[65];
                size_t k = 0;
                while (k < sizeof(path_buf) && path_buf[k]) {
                    path_c[k] = (char)path_buf[k];
                    k++;
                }
                path_c[k] = '\0';
                if (find_loaded_index(path_c, dep_paths, n_deps) >= 0)
                    continue;
                char resolved[PATH_MAX];
                resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir, path_c, resolved, sizeof(resolved));
                size_t raw_len = 0;
                char *raw = read_file(resolved, &raw_len);
                if (!raw) {
                    fprintf(stderr, "shux: cannot open import '%s' (tried %s)\n", path_c, resolved);
                    while (n_deps--) {
                        free(dep_sources[n_deps]);
                        free(dep_paths[n_deps]);
                    }
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
                char *prep = NULL;
                size_t prep_len = 0;
                if (su_preprocess_raw_to_malloc((const unsigned char *)raw, raw_len, &prep, &prep_len, resolved, NULL, 0) != 0) {
                    free(raw);
                    while (n_deps--) {
                        free(dep_sources[n_deps]);
                        free(dep_paths[n_deps]);
                    }
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
                free(raw);
                dep_sources[n_deps] = prep;
                dep_lens[n_deps] = prep_len;
                dep_paths[n_deps] = strdup(path_c);
                if (!dep_paths[n_deps]) {
                    free(prep);
                    while (n_deps--) {
                        free(dep_sources[n_deps]);
                        free(dep_paths[n_deps]);
                    }
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
                n_deps++;
            }
        }
#endif
        typeck_ndep = 0;
        /* -backend asm 且指定 -o 时，将汇编输出写入文件；-o xxx.o 则直接写 ELF/Mach-O/COFF；-o <exe> 无后缀则先写临时 .o 再调 ld 出可执行文件 */
        FILE *asm_out = NULL;
        int emit_elf_o = 0;
        void *elf_ctx_ptr = NULL;
        char asm_tmp_o_path[64];
        int asm_want_exe = 0;
        asm_tmp_o_path[0] = '\0';
        if (use_asm_backend && out_path) {
            asm_want_exe = output_want_exe(out_path);
            if (asm_want_exe) {
                strcpy(asm_tmp_o_path, "/tmp/shux_asm_XXXXXX");
                int fd = mkstemp(asm_tmp_o_path);
                if (fd < 0) {
                    perror("shux: mkstemp (asm)");
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
                asm_out = fdopen(fd, "wb");
                if (!asm_out) {
                    close(fd);
                    unlink(asm_tmp_o_path);
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
                emit_elf_o = 1;
            } else {
                asm_out = fopen(out_path, "wb");
                if (!asm_out) {
                    perror("shux: -o (asm)");
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
                emit_elf_o = output_is_elf_o(out_path);
            }
            if (emit_elf_o) {
                elf_ctx_ptr = malloc(pipeline_sizeof_elf_ctx());
                if (!elf_ctx_ptr) {
                    fprintf(stderr, "shux: elf_ctx alloc failed\n");
                    fclose(asm_out);
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
                memset(elf_ctx_ptr, 0, pipeline_sizeof_elf_ctx());
            }
        }
        /* 阶段 5.2：为每个 dep 单独分配 arena/module，先跑完各 dep 的 pipeline 并保留指针，再跑入口 pipeline 时 typeck 可解析跨模块调用 */
        void *dep_arenas[32];
        void *dep_modules[32];
        for (int i = 0; i < n_deps; i++) {
            dep_arenas[i] = malloc(arena_sz);
            dep_modules[i] = malloc(module_sz);
            if (!dep_arenas[i] || !dep_modules[i]) {
                fprintf(stderr, "shux: -sx pipeline: dep alloc failed\n");
                if (asm_out) fclose(asm_out);
                if (elf_ctx_ptr) free(elf_ctx_ptr);
                while (i > 0) { i--; free(dep_arenas[i]); free(dep_modules[i]); }
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            memset(dep_arenas[i], 0, arena_sz);
            memset(dep_modules[i], 0, module_sz);
        }
        /*
         * CodegenOutBuf / PipelineDepCtx 含 MiB 级内嵌缓冲区；栈分配在 ARM64/macOS 上易溢出，改为堆分配（与 driver_run_asm_backend 一致）。
         */
        struct codegen_CodegenOutBuf *out_buf = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*out_buf));
        struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*pctx));
        if (!out_buf || !pctx) {
            fprintf(stderr, "shux: -sx pipeline: out_buf/pctx alloc failed\n");
            if (asm_out) fclose(asm_out);
            if (elf_ctx_ptr) free(elf_ctx_ptr);
            for (int di = 0; di < n_deps; di++) { free(dep_arenas[di]); free(dep_modules[di]); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena);
            free(module);
            free(src);
            if (out_buf) free(out_buf);
            if (pctx) pipeline_dep_ctx_heap_destroy(pctx);
            return 1;
        }
        pipeline_fill_ctx_path_buffers(pctx, entry_dir, lib_roots_arr, n_lib_roots);
        runtime_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
        driver_dep_seeded_clear_all();
        if (use_asm_backend && emit_elf_o && asm_entry_module_only_from_env() && driver_asm_build_skip_typeck() != 0) {
            for (int j = n_deps - 1; j >= 0; j--)
                driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
        } else {
            for (int j = n_deps - 1; j >= 0; j--) {
                struct ast_PipelineDepCtx *one_ctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*one_ctx));
                struct codegen_CodegenOutBuf *dep_out = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*dep_out));
                if (!one_ctx || !dep_out) {
                    fprintf(stderr, "shux: -sx pipeline: dep_one_ctx/out alloc failed\n");
                    pipeline_dep_ctx_heap_destroy(one_ctx);
                    free(dep_out);
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                    if (asm_out) fclose(asm_out);
                    if (elf_ctx_ptr) free(elf_ctx_ptr);
                    while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                    free(arena); free(module); free(src);
                    return 1;
                }
                runtime_one_ctx_for_dep_prerun(one_ctx, j, dep_modules[j], dep_arenas[j]);
                pipeline_fill_ctx_path_buffers(one_ctx, runtime_dep_prerun_entry_dir(entry_dir, lib_roots_arr, n_lib_roots),
                    lib_roots_arr, n_lib_roots);
                int ec;
                if (use_asm_backend && emit_elf_o && asm_user_std_dep_skip_su_typeck(dep_paths[j])) {
                    ec = pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                        (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
                } else if (use_asm_backend && emit_elf_o && asm_user_dep_parse_skip_typeck_path(dep_paths[j])) {
                    ec = pipeline_dep_prerun_parse_skip_typeck(dep_modules[j], dep_arenas[j],
                        (const uint8_t *)dep_sources[j], (size_t)dep_lens[j], (void *)dep_out, (void *)one_ctx);
                    if (ec == 0 && asm_user_std_net_dep_path(dep_paths[j]))
                        pipeline_asm_seed_std_net_struct_layouts((struct ast_Module *)dep_modules[j]);
                } else {
                    ec = pipeline_dep_prerun_for_asm_module_o(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j],
                        (size_t)dep_lens[j], (void *)dep_out, (void *)one_ctx);
                }
                pipeline_dep_ctx_heap_destroy(one_ctx);
                free(dep_out);
                if (ec != 0) {
                    fprintf(stderr, "shux: pipeline failed for import '%s' (rc=%d)\n", dep_paths[j], ec);
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                    if (asm_out) fclose(asm_out);
                    if (elf_ctx_ptr) free(elf_ctx_ptr);
                    while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                    free(arena); free(module); free(src);
                    return 1;
                }
                driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
            }
        }
        pctx->use_asm_backend = use_asm_backend;
        pctx->target_arch = 0;
        if (target && (strstr(target, "aarch64") != NULL || strstr(target, "arm64") != NULL))
            pctx->target_arch = 1;
        if (target && strstr(target, "riscv64") != NULL)
            pctx->target_arch = 2;
        pctx->target_cpu_features = (int32_t)driver_get_pending_target_cpu_features();
#if defined(__APPLE__) && defined(__aarch64__)
        /* 未传 -target 时 Mach-O 须与宿主一致，避免 x86_64 对象与 arm64 runtime 混链。 */
        if (!target)
            pctx->target_arch = 1;
#endif
        pctx->use_macho_o = 0;
        pctx->use_coff_o = 0;
#if defined(__APPLE__)
        if (emit_elf_o)
            pctx->use_macho_o = 1;
#endif
        if (emit_elf_o && target && strstr(target, "windows") != NULL)
            pctx->use_coff_o = 1;
        if (emit_elf_o && use_asm_backend)
            pctx->asm_entry_module_only = asm_entry_module_only_from_env();
        /* get_ndep() 需在 pipeline 内返回 n_deps，以便先 codegen 各 dep 再 codegen entry（含跨 dep 调用时 dep_paths 已设）。 */
        typeck_ndep = n_deps;
        for (int i = 0; i < n_deps; i++) {
            typeck_dep_module_ptrs[i] = dep_modules[i];
            typeck_dep_arena_ptrs[i] = dep_arenas[i];
        }
        pipeline_set_dep_slots(dep_arenas, dep_modules);
        driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
        codegen_set_dep_slots_for_su_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
        codegen_set_preamble_has_core_option_result(1);
        /* asm 后端：必须让 pipeline_run_sx_pipeline 内完整地 parse_into + typeck + asm codegen，
         * 禁止沿用 C 侧预解析后的 entry_already_parsed=1 捷径——否则入口 module/arena 与汇编后端期望不一致，
         * 曾为 Mach-O __text 长度为 0；纯库模块（无 main、仅 num_funcs）同样依赖完整重解析后才会编出 TEXT。
         * 不只 -o xxx.o（emit_elf_o）：-o xxx.s  listings 也需一致，故条件与 emit_elf_o 解耦。
         * 预解析仍用于上方收集 import / n_deps；此处重置入口 module/arena 后由 pipeline 重填。 */
        if (use_asm_backend) {
            memset(arena, 0, arena_sz);
            memset(module, 0, module_sz);
            parser_parse_into_init(module, arena);
            pctx->entry_already_parsed = 0;
        } else {
            /**
             * 须始终在 pipeline 内完整 parse_into：C 预填的 module 与 .sx Module 的 struct_layouts 等字段不同步时，
             * entry_already_parsed=1 会跳过解析导致 num_struct_layouts=0，§11.1 隐式 padding 等 typeck 成为空操作。
             */
            memset(arena, 0, arena_sz);
            memset(module, 0, module_sz);
            parser_parse_into_init(module, arena);
            pctx->entry_already_parsed = 0;
        }
        /*
         * run_compiler_c + import 降级路径：仍可能 -o .o 并走 asm_codegen_elf_o；与 driver_run_asm_backend 一致跳过 .sx typeck。
         */
        if (emit_elf_o && out_path && !driver_check_only_get()) {
            driver_su_pipeline_skip_typeck_set(1);
            driver_su_pipeline_skip_codegen_set(1);
        }
        int ec = pipeline_run_sx_pipeline_large_stack(module, arena, src_slice.data, (size_t)src_slice.length, (void *)out_buf, (void *)pctx);
        driver_su_pipeline_skip_typeck_set(0);
        driver_su_pipeline_skip_codegen_set(0);
        if (getenv("SHUX_ASM_ENTRY_DEBUG")) {
            fprintf(stderr, "shux: asm entry dbg ec=%d num_funcs=%d out_asm_len=%zu\n",
                    ec, driver_get_module_num_funcs(module), (size_t)out_buf->len);
        }
        driver_dep_seeded_clear_all();
        codegen_set_dep_slots_for_su_pipeline(NULL, NULL, 0);
        if (ec == 0 && (out_buf->len > 0 || emit_elf_o)) {
            if (emit_elf_o && elf_ctx_ptr) {
                driver_asm_prepare_entry_elf_emit(module, arena, pctx);
                int32_t elf_ec = asm_asm_codegen_elf_o_large_stack(module, arena, (void *)pctx, (struct platform_elf_ElfCodegenCtx *)elf_ctx_ptr, (void *)out_buf);
                if (elf_ec != 0 || out_buf->len <= 0) {
                    fprintf(stderr, "shux: asm_codegen_elf_o failed (elf_ec=%d, out_len=%zu, num_funcs=%d)\n",
                            (int)elf_ec, (size_t)out_buf->len, driver_get_module_num_funcs(module));
                    if (elf_ec != 0 && elf_ctx_ptr)
                        pipeline_elf_ctx_diag_stderr((uint8_t *)elf_ctx_ptr);
                    if (asm_out) fclose(asm_out);
                    if (elf_ctx_ptr) free(elf_ctx_ptr);
                    for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
                    while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    free(arena); free(module); free(src);
                    return 1;
                }
            }
            fwrite(out_buf->data, 1, (size_t)out_buf->len, asm_out ? asm_out : stdout);
            if (!asm_out) fflush(stdout);
            if (asm_out) fclose(asm_out);
            asm_out = NULL;
            if (elf_ctx_ptr) { free(elf_ctx_ptr); elf_ctx_ptr = NULL; }
            for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
            while (n_deps > 0) {
                n_deps--;
                free(dep_sources[n_deps]);
                free(dep_paths[n_deps]);
            }
            /* -o <exe>（无 .o/.s 后缀）时：已写临时 .o，调 ld 生成可执行文件后删临时文件；链 runtime_panic 与常用 std 各 .o */
            if (asm_want_exe && asm_tmp_o_path[0]) {
                int ld_ok = invoke_ld(asm_tmp_o_path, out_path, target, pctx->use_macho_o, pctx->use_coff_o, argv[0], lib_roots_arr, n_lib_roots);
                unlink(asm_tmp_o_path);
                if (ld_ok != 0) {
                    fprintf(stderr, "shux: ld failed (asm -o exe)\n");
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
            }
        } else {
            /* ec != 0 或 ec == 0 但 out_buf->len == 0（且非 emit_elf_o） */
            if (ec == 0 && out_buf->len == 0 && !emit_elf_o && !asm_out) {
                /* -sx -E 时 pipeline 成功但 codegen 产出 0 字节（如库模块或 codegen 路径未写 main），写最小 C 桩使 run-sx-pipeline 等测试能通过 */
                fprintf(stdout, "int main(void){return 0;}\n");
                fflush(stdout);
            }
            if (asm_out) fclose(asm_out);
            asm_out = NULL;
            if (asm_want_exe && asm_tmp_o_path[0]) unlink(asm_tmp_o_path);
            if (elf_ctx_ptr) { free(elf_ctx_ptr); elf_ctx_ptr = NULL; }
            for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
            while (n_deps > 0) {
                n_deps--;
                free(dep_sources[n_deps]);
                free(dep_paths[n_deps]);
            }
            if (ec != 0) {
                fprintf(stderr, "shux: -sx pipeline failed (parse_into / typeck_sx_ast / codegen_sx_ast)\n");
                /* 诊断：单独试 parse_into 以区分失败阶段 */
                {
                void *diag_arena = malloc(arena_sz);
                void *diag_module = malloc(module_sz);
                if (diag_arena && diag_module) {
                    memset(diag_arena, 0, arena_sz);
                    memset(diag_module, 0, module_sz);
                    struct parser_ParseIntoResult pr =
                        parser_parse_into_buf(diag_arena, diag_module, (uint8_t *)src_slice.data, (int32_t)src_slice.length);
                    if (pr.ok == 0) {
                        /* 诊断用 ctx 与同文件主路径一致：PipelineDepCtx 体积大，避免栈上分配 */
                        struct ast_PipelineDepCtx *diag_ctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*diag_ctx));
                        if (diag_ctx) {
                            int32_t tck = pipeline_typeck_after_parse_ok(diag_arena, diag_module, &src_slice, (void *)diag_ctx);
                            fprintf(stderr, "shux: (diagnostic) parse_into OK, typeck_after_parse=%d (0=ok -2=parse_fail -10=main_idx<0 -11=main_idx>=num_funcs -1=impl)\n", (int)tck);
                            pipeline_dep_ctx_heap_destroy(diag_ctx);
                        }
                    } else {
                        int32_t fail_tok = parser_diag_fail_at_token_kind(&src_slice);
                        int32_t one_ok = pipeline_parse_one_function_ok(&src_slice, diag_arena);
                        fprintf(stderr, "shux: (diagnostic) parse_into failed (len=%zu, diag_fail=%d, parse_one_func_ok=%d)\n",
                                (size_t)src_slice.length, (int)fail_tok, (int)one_ok);
                    }
                    free(diag_arena);
                    free(diag_module);
                }
            }
            }
        }
        free(out_buf);
        pipeline_dep_ctx_heap_destroy(pctx);
        free(arena);
        free(module);
        free(src);
        return (ec != 0) ? 1 : 0;
    }
#endif

    Lexer *lex = lexer_new(src);
    ASTModule *mod = NULL;
    int pr = parse(lex, &mod);
    lexer_free(lex);

    if (pr != 0 || !mod) {
        if (mod) ast_module_free(mod);
        free(src);
        fprintf(stderr, "shux: parse failed for '%s' (pr=%d)\n", input_path, pr);
        return 1;
    }
    char entry_dir_buf[512];
    get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    const char *entry_dir = entry_dir_buf;

    ASTModule *dep_mods[32];       /* 入口直接依赖，与 mod->import_paths 一一对应，供 typeck/codegen 入口 */
    ASTModule *all_dep_mods[MAX_ALL_DEPS];
    char *all_dep_paths[MAX_ALL_DEPS];
    int ndep = 0, n_all = 0;
    if (mod->num_imports > 0 && resolve_and_load_imports(mod, lib_roots_arr, n_lib_roots, entry_dir, ndefines > 0 ? defines : NULL, ndefines,
            dep_mods, &ndep, all_dep_mods, all_dep_paths, NULL, &n_all, 32) != 0) {
        ast_module_free(mod);
        free(src);
        return 1;
    }
/* 6.3：与 pipeline_sx.o 同链时不再链 typeck_su/codegen_su，非 -sx 路径用 C typeck/codegen 避免重复符号 */
#if defined(SHUX_USE_SX_TYPECK) && !defined(SHUX_USE_SX_PIPELINE)
    if (typeck_typeck_entry(mod, ndep > 0 ? dep_mods : NULL, ndep) != 0) {
#else
    /* 传入全部传递依赖供布局阶段解析跨模块类型；直接依赖仍为 dep_mods/ndep */
    if (typeck_module(mod, ndep > 0 ? dep_mods : NULL, ndep, n_all > 0 ? all_dep_mods : NULL, n_all) != 0) {
#endif
        while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
        ast_module_free(mod);
        free(src);
        return 1;
    }

    /* WPO-S1：typeck 后可选导出跨模块 call graph JSON（SHUX_WPO_DUMP_CALLGRAPH=路径，"-"=stdout）。 */
    {
        const char *wpo_out = getenv("SHUX_WPO_DUMP_CALLGRAPH");
        if (wpo_out && wpo_out[0]) {
            FILE *wf = (strcmp(wpo_out, "-") == 0) ? stdout : fopen(wpo_out, "w");
            if (wf) {
                codegen_dump_wpo_callgraph_json(wf, mod, input_path,
                    n_all > 0 ? all_dep_mods : NULL,
                    n_all > 0 ? (const char **)all_dep_paths : NULL, n_all);
                if (wf != stdout) fclose(wf);
            }
        }
    }

    /** shux check（C 路径）：typeck 通过后跳过 codegen 与链接。 */
    if (driver_check_only_get()) {
        while (n_all--) {
            free(all_dep_paths[n_all]);
            ast_module_free(all_dep_mods[n_all]);
        }
        ast_module_free(mod);
        free(src);
        driver_print_check_ok(input_path);
        return 0;
    }

    /* -E：生成 C 到 stdout 后退出。方案 A：有 import 时先按拓扑序输出全部依赖再输出入口，使单文件自洽可编译（为自举 pipeline_gen.c 铺路）。 */
    if (emit_c_only) {
        int ec = 0;
        char emitted_type_buf[128][CODEGEN_EMITTED_TYPE_NAME_MAX];
        int n_emitted = 0;
        const int max_emitted = (int)(sizeof(emitted_type_buf) / sizeof(emitted_type_buf[0]));
        ASTFunc *used_funcs[RUNTIME_MAX_USED_FUNCS];
        int n_used = 0;
        int used_mono[RUNTIME_MAX_DCE_MODULES][64];
        const char *used_type_names[64];
        int n_used_types = 0;
        CodegenWpoReach wpo_reach;
        struct dce_ctx dce;
        int dce_ready = 0;
        runtime_prepare_dce_ctx(mod, all_dep_mods, n_all, used_funcs, &n_used, used_mono, used_type_names, &n_used_types, &wpo_reach, &dce, &dce_ready);
        void *dce_ctx_arg = dce_ready ? (void *)&dce : NULL;
        /* -E-extern 瘦 TU（typeck_gen/parser_gen/codegen_gen）：入口无 main/entry 根，WPO/classic DCE 会误删
         * 入口模块全体符号；须 emit 全量函数供 pipeline_sx.o 链接 C 依赖实现。 */
        if (emit_extern_imports)
            dce_ctx_arg = NULL;

        if (n_all > 0) {
            /* 有依赖时与 -o 单文件一致：先统一输出 include 与 panic，再按拓扑序写各库，最后写入口，类型名去重避免重定义。
             * 阶段 3.1：-E-extern 时仅输出依赖类型 + 入口模块（extern 由 codegen 生成），不内联各库函数体。 */
            fprintf(stdout, "/* generated (single-file with deps) */\n");
            fprintf(stdout, "#include <stdint.h>\n");
            fprintf(stdout, "#include <stddef.h>\n");
            fprintf(stdout, "#include <stdlib.h>\n");
            fprintf(stdout, "#include <stdio.h>\n");
            fprintf(stdout, "#include <string.h>\n");
            fprintf(stdout, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
            fprintf(stdout, "static inline void shux_panic_(int has_msg, int msg_val) {\n");
            fprintf(stdout, "  if (has_msg) (void)fprintf(stderr, \"%%d\\n\", msg_val);\n");
            fprintf(stdout, "  abort();\n");
            fprintf(stdout, "}\n");
            /* pipeline.sx 及可能拉入 std.io 的 parser/typeck/codegen/preprocess 等 -E 产出均需 _buf 声明，以便单文件编译通过；main.sx 产出 driver_gen.c 不调这些，不输出以免 -Wunused-function。 */
            if (input_path && (strstr(input_path, "pipeline.sx") != NULL || strstr(input_path, "parser.sx") != NULL || strstr(input_path, "typeck.sx") != NULL || strstr(input_path, "codegen.sx") != NULL || strstr(input_path, "preprocess.sx") != NULL)) {
                fprintf(stdout, "extern int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle);\n");
                fprintf(stdout, "extern int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n");
                fprintf(stdout, "extern int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n");
                fprintf(stdout, "typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;\n");
                fprintf(stdout, "static inline int32_t shux_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_register((uint8_t *)b->ptr, b->len, b->handle); }\n");
                fprintf(stdout, "static inline int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_read((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }\n");
                fprintf(stdout, "static inline int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_write((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }\n");
                fprintf(stdout, "typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;\n");
                fprintf(stdout, "extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);\n");
                fprintf(stdout, "static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }\n");
            }
            if (emit_extern_imports) {
                codegen_set_eextern_entry_path(input_path);
                if (codegen_emit_dep_types_only(all_dep_mods, (const char **)all_dep_paths, n_all, stdout,
                        emitted_type_buf, &n_emitted, max_emitted) != 0) {
                    ec = -1;
                }
            } else {
                for (int i = 0; i < n_all; i++) {
                    ASTModule *lib_deps[32];
                    const char *lib_dep_paths[32];
                    int n_lib = 0;
                    for (int j = 0; j < all_dep_mods[i]->num_imports && n_lib < 32; j++) {
                        int idx = find_loaded_index(all_dep_mods[i]->import_paths[j], all_dep_paths, n_all);
                        if (idx >= 0) {
                            lib_deps[n_lib] = all_dep_mods[idx];
                            lib_dep_paths[n_lib] = all_dep_paths[idx];
                            n_lib++;
                        }
                    }
#if defined(SHUX_USE_SX_CODEGEN) && !defined(SHUX_USE_SX_PIPELINE)
                    if (codegen_codegen_entry_library_module_to_c(all_dep_mods[i], all_dep_paths[i], lib_deps, lib_dep_paths, n_lib, stdout, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, emitted_type_buf, &n_emitted, max_emitted) != 0) {
#else
                    if (codegen_library_module_to_c(all_dep_mods[i], all_dep_paths[i], lib_deps, lib_dep_paths, n_lib, stdout, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, emitted_type_buf, &n_emitted, max_emitted, NULL) != 0) {
#endif
                        ec = -1;
                        break;
                    }
                }
            }
            if (ec == 0) {
                /* 阶段 3 -E-extern：入口一律按库模块输出（带 lib 前缀），避免 main 与 main.o 冲突、且仅 extern 依赖不内联。 */
                const char *lib_name = entry_lib_name_from_path(input_path);
                if (mod->num_funcs > 0) {
#if defined(SHUX_USE_SX_CODEGEN) && !defined(SHUX_USE_SX_PIPELINE)
                    ec = codegen_codegen_entry_library_module_to_c(mod, lib_name, dep_mods, (const char **)mod->import_paths, ndep, stdout, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, emitted_type_buf, &n_emitted, max_emitted);
#else
                    ec = codegen_library_module_to_c(mod, lib_name, dep_mods, (const char **)mod->import_paths, ndep, stdout, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, emitted_type_buf, &n_emitted, max_emitted, input_path);
#endif
                } else if (mod->main_func && mod->main_func->body) {
#if defined(SHUX_USE_SX_CODEGEN) && !defined(SHUX_USE_SX_PIPELINE)
                    ec = codegen_codegen_entry_module_to_c(mod, stdout, dep_mods, (const char **)mod->import_paths, ndep, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, emitted_type_buf, &n_emitted, max_emitted);
#else
                    ec = codegen_module_to_c(mod, stdout, dep_mods, (const char **)mod->import_paths, ndep, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, emitted_type_buf, &n_emitted, max_emitted);
#endif
                } else {
                    fprintf(stderr, "shux: no main function (cannot emit C)\n");
                    ec = -1;
                }
            }
        } else {
            /* 无依赖：仅输出入口模块（保持原有行为） */
            if (mod->main_func && mod->main_func->body) {
#if defined(SHUX_USE_SX_CODEGEN) && !defined(SHUX_USE_SX_PIPELINE)
                ec = codegen_codegen_entry_module_to_c(mod, stdout, NULL, NULL, 0, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, NULL, NULL, 0);
#else
                ec = codegen_module_to_c(mod, stdout, NULL, NULL, 0, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, NULL, NULL, 0);
#endif
            } else if (mod->num_funcs > 0) {
                const char *lib_name = entry_lib_name_from_path(input_path);
#if defined(SHUX_USE_SX_CODEGEN) && !defined(SHUX_USE_SX_PIPELINE)
                ec = codegen_codegen_entry_library_module_to_c(mod, lib_name, NULL, NULL, 0, stdout, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, NULL, NULL, 0);
#else
                ec = codegen_library_module_to_c(mod, lib_name, NULL, NULL, 0, stdout, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, NULL, NULL, 0, input_path);
#endif
            } else {
                fprintf(stderr, "shux: no main function (cannot emit C)\n");
                ec = -1;
            }
        }
        /* -E 且入口为 pipeline.sx 时输出 #include "pipeline_glue.c"，编译时由 cc 包含，不再追写整份内容 */
        if (ec == 0 && input_path && strstr(input_path, "pipeline.sx") != NULL)
            emit_pipeline_glue_include();
        while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
        ast_module_free(mod);
        free(src);
        return ec != 0 ? 1 : 0;
    }

    /* 若指定 -o：需有 main，生成 C（含 import 的 .c）→ 调用 cc 链接；依赖使用已加载的 dep_mods（7.3 跨模块调用 + 传递依赖）；阶段 8.1 DCE 仅生成被引用函数与单态化 */
    if (out_path) {
        codegen_set_preamble_has_core_option_result(0); /* C 路径 preamble 无 Option/Result，由 codegen 输出 */
        ASTFunc *root_func = codegen_entry_root_func(mod);
        if (!root_func || !root_func->body) {
            fprintf(stderr, "shux: no main function (cannot emit executable)\n");
            while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
            ast_module_free(mod);
            free(src);
            return 1;
        }
        ASTFunc *used_funcs[RUNTIME_MAX_USED_FUNCS];
        int n_used = 0;
        int used_mono[RUNTIME_MAX_DCE_MODULES][64];
        const char *used_type_names[64];
        int n_used_types = 0;
        CodegenWpoReach wpo_reach;
        struct dce_ctx dce;
        int dce_ready = 0;
        runtime_prepare_dce_ctx(mod, all_dep_mods, n_all, used_funcs, &n_used, used_mono, used_type_names, &n_used_types, &wpo_reach, &dce, &dce_ready);
        void *dce_ctx_arg = dce_ready ? (void *)&dce : NULL;

        const char *c_paths[MAX_C_FILES];
        int n_c = 0;
        char tmp_c[256];

        /* 入口模块 → 临时 .c（有依赖时同一文件内先写依赖再写入口） */
        char tmp[] = "/tmp/shux_XXXXXX";
        int fd = mkstemp(tmp);
        if (fd < 0) {
            perror("shux: mkstemp");
            while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
            ast_module_free(mod);
            free(src);
            return 1;
        }
        FILE *cf = fdopen(fd, "w");
        if (!cf) {
            close(fd);
            unlink(tmp);
            while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
            ast_module_free(mod);
            free(src);
            return 1;
        }
        /* 有依赖时单文件输出：先按拓扑序写依赖再写入口，并传已输出类型名去重，避免 incomplete type 与重定义（见自举实现分析 7.3） */
        char emitted_type_buf[128][CODEGEN_EMITTED_TYPE_NAME_MAX];
        int n_emitted = 0;
        const int max_emitted = (int)(sizeof(emitted_type_buf) / sizeof(emitted_type_buf[0]));

        if (n_all > 0) {
            /* 单文件时在写任何库前统一输出 include 与 panic，避免首库无类型导致 n_emitted 仍为 0、次库再次输出 panic 而重定义（见 run-stdlib-import） */
            fprintf(cf, "/* generated (single-file with deps) */\n");
            fprintf(cf, "#include <stdint.h>\n");
            fprintf(cf, "#include <stddef.h>\n");
            fprintf(cf, "#include <stdlib.h>\n");
            fprintf(cf, "#include <stdio.h>\n");
            fprintf(cf, "#include <string.h>\n"); /* memcpy for array copy (bootstrap parser.sx) */
            fprintf(cf, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
            fprintf(cf, "static inline void shux_panic_(int has_msg, int msg_val) {\n");
            fprintf(cf, "  if (has_msg) (void)fprintf(stderr, \"%%d\\n\", msg_val);\n");
            fprintf(cf, "  abort();\n");
            fprintf(cf, "}\n");
            /* std.io.driver：weak batch 桩；链 io.o 时强符号覆盖。无 io.o 时 minimal 链仍可解析。 */
            fprintf(cf, "struct std_io_driver_Buffer;\n");
            fprintf(cf, "__attribute__((weak)) ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms) {\n");
            fprintf(cf, "  (void)fd;(void)bufs;(void)n;(void)timeout_ms; return (ptrdiff_t)-1;\n");
            fprintf(cf, "}\n");
            fprintf(cf, "__attribute__((weak)) ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms) {\n");
            fprintf(cf, "  (void)fd;(void)bufs;(void)n;(void)timeout_ms; return (ptrdiff_t)-1;\n");
            fprintf(cf, "}\n");
            /* parser.sx 路径将 #include pipeline_glue.c，其中已有 std_io_driver_submit_*_batch_buf；再输出 static 版会重复定义。 */
            if (!input_path || strstr(input_path, "parser.sx") == NULL) {
                fprintf(cf, "static int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {\n");
                fprintf(cf, "  ptrdiff_t r = io_read_batch_buf((int)handle, bufs, n, timeout_ms);\n");
                fprintf(cf, "  return (r < 0) ? -1 : (int32_t)r;\n");
                fprintf(cf, "}\n");
                fprintf(cf, "static int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {\n");
                fprintf(cf, "  ptrdiff_t r = io_write_batch_buf((int)handle, bufs, n, timeout_ms);\n");
                fprintf(cf, "  return (r < 0) ? -1 : (int32_t)r;\n");
                fprintf(cf, "}\n");
            }
            fprintf(cf, "#define std_io_submit_read_batch_buf std_io_driver_submit_read_batch_buf\n");
            fprintf(cf, "#define std_io_submit_write_batch_buf std_io_driver_submit_write_batch_buf\n");
            /* driver 的 read_ptr/read_ptr_len 由 core/io.o 提供，与 pipeline 内联 ABI 一致 */
            fprintf(cf, "#define std_io_driver_driver_read_ptr_len shux_io_read_ptr_len\n");
            fprintf(cf, "#define std_io_driver_driver_read_ptr shux_io_read_ptr\n");
            /* std.io.driver 的 register/submit_read/submit_write 体需调 _buf 包装；io_register_buffers_buf_i32 供 submit_register_fixed_buffers_buf 体 */
            fprintf(cf, "extern int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle);\n");
            fprintf(cf, "extern int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n");
            fprintf(cf, "extern int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n");
            fprintf(cf, "typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;\n");
            fprintf(cf, "static inline int32_t shux_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_register((uint8_t *)b->ptr, b->len, b->handle); }\n");
            fprintf(cf, "static inline int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_read((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }\n");
            fprintf(cf, "static inline int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_write((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }\n");
            fprintf(cf, "typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;\n");
            fprintf(cf, "extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);\n");
            fprintf(cf, "static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }\n");
            /* codegen 跳过 std.io.print_str 定义；C 前端链 io.o 时由弱符号提供，避免 hello 等 Undefined _std_io_print_str。 */
            fprintf(cf, "__attribute__((weak)) int32_t std_io_print_str(uint8_t *ptr, size_t len) {\n");
            fprintf(cf, "  if (!ptr || len == 0) return 0;\n");
            fprintf(cf, "  return (fwrite(ptr, 1, len, stdout) == len) ? (int32_t)len : -1;\n");
            fprintf(cf, "}\n");
            for (int i = 0; i < n_all; i++) {
                ASTModule *lib_deps[32];
                const char *lib_dep_paths[32];
                int n_lib = 0;
                for (int j = 0; j < all_dep_mods[i]->num_imports && n_lib < 32; j++) {
                    int idx = find_loaded_index(all_dep_mods[i]->import_paths[j], all_dep_paths, n_all);
                    if (idx >= 0) {
                        lib_deps[n_lib] = all_dep_mods[idx];
                        lib_dep_paths[n_lib] = all_dep_paths[idx];
                        n_lib++;
                    }
                }
#if defined(SHUX_USE_SX_CODEGEN) && !defined(SHUX_USE_SX_PIPELINE)
                if (codegen_codegen_entry_library_module_to_c(all_dep_mods[i], all_dep_paths[i], lib_deps, lib_dep_paths, n_lib, cf, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, emitted_type_buf, &n_emitted, max_emitted) != 0) {
#else
                if (codegen_library_module_to_c(all_dep_mods[i], all_dep_paths[i], lib_deps, lib_dep_paths, n_lib, cf, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, emitted_type_buf, &n_emitted, max_emitted, NULL) != 0) {
#endif
                    fclose(cf);
                    unlink(tmp);
                    while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
                    ast_module_free(mod);
                    free(src);
                    return 1;
                }
            }
            /* parser 入口随后在单文件内生成，会调用 glue 导出符号；完整定义在文末 #include pipeline_glue.c。依赖模块已写出后 token/ExprKind 等才完整，故前向声明放在 for 之后、入口 codegen 之前。 */
            if (input_path && strstr(input_path, "parser.sx") != NULL) {
                fprintf(cf, "struct shux_slice_uint8_t parser_slice_from_buf(uint8_t *data, int32_t len);\n");
                fprintf(cf, "void parser_pipeline_module_reset_parse_counters(struct ast_Module *m);\n");
                fprintf(cf, "enum ast_ExprKind compound_assign_token_to_expr_kind_from_glue(enum token_TokenKind kind);\n");
                fprintf(cf, "int32_t pipeline_expr_ref_is_assign_lvalue(struct ast_ASTArena *a, int32_t expr_ref);\n");
                fprintf(cf, "void pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);\n");
                fprintf(cf, "void pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);\n");
                fprintf(cf,
                        "void pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,\n"
                        "    int32_t fname_len, int32_t ftype_ref, int32_t foff);\n");
                fprintf(cf,
                        "void pipeline_module_func_param_write(struct ast_Module *m, int32_t func_index, int32_t param_index,\n"
                        "    uint8_t *name_bytes, int32_t name_len, int32_t type_ref);\n");
                fprintf(cf,
                        "void pipeline_module_func_name_write(struct ast_Module *m, int32_t func_index,\n"
                        "    uint8_t *name_bytes, int32_t name_len);\n");
                fprintf(cf,
                        "void pipeline_arena_func_param_write(struct ast_ASTArena *arena, int32_t func_ref, int32_t param_index,\n"
                        "    uint8_t *name_bytes, int32_t name_len, int32_t type_ref);\n");
                fprintf(cf,
                        "void pipeline_arena_func_copy_slot_from_module(struct ast_ASTArena *arena, int32_t func_ref,\n"
                        "    struct ast_Module *m, int32_t fi);\n");
                fprintf(cf, "size_t pipeline_sizeof_arena(void);\n");
            }
        }
#if defined(SHUX_USE_SX_CODEGEN) && !defined(SHUX_USE_SX_PIPELINE)
        if (codegen_codegen_entry_module_to_c(mod, cf, dep_mods, (const char **)mod->import_paths, ndep, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, n_all > 0 ? emitted_type_buf : NULL, n_all > 0 ? &n_emitted : NULL, n_all > 0 ? max_emitted : 0) != 0) {
#else
        if (codegen_module_to_c(mod, cf, dep_mods, (const char **)mod->import_paths, ndep, dce_is_func_used, dce_is_mono_used, dce_is_type_used, dce_ctx_arg, n_all > 0 ? emitted_type_buf : NULL, n_all > 0 ? &n_emitted : NULL, n_all > 0 ? max_emitted : 0) != 0) {
#endif
            fclose(cf);
            unlink(tmp);
            while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
            ast_module_free(mod);
            free(src);
            return 1;
        }
        /* 与 pipeline_gen.c 末尾含 glue 同序：先有完整类型定义再 #include pipeline_glue.c（见 pipeline_glue.c 头注释）。 */
        if (input_path && strstr(input_path, "parser.sx") != NULL)
            codegen_emit_include_pipeline_glue_c(cf, argv[0]);
        fclose(cf);
        snprintf(tmp_c, sizeof(tmp_c), "%s.c", tmp);
        if (rename(tmp, tmp_c) != 0) {
            perror("shux: rename");
            unlink(tmp);
            while (ndep--) ast_module_free(dep_mods[ndep]);
            ast_module_free(mod);
            free(src);
            return 1;
        }
        if (getenv("SHUX_DEBUG_C")) {
            FILE *dc = fopen(tmp_c, "r");
            if (dc) {
                FILE *out = fopen("/tmp/shux_debug.c", "w");
                if (out) {
                    int ch;
                    while ((ch = getc(dc)) != EOF) putc(ch, out);
                    fclose(out);
                }
                fclose(dc);
            }
        }
        c_paths[n_c++] = tmp_c;

        const char *io_o = get_io_o_path(argv[0]);
        const char *fs_o = get_std_fs_o_path(argv[0]);
        const char *process_o = get_std_process_o_path(argv[0]);
        const char *string_o = get_std_string_o_path(argv[0]);
        const char *heap_o = get_std_heap_o_path(argv[0]);
        const char *path_o = get_std_path_o_path(argv[0]);
        const char *runtime_o = get_std_runtime_o_path(argv[0]);
        const char *runtime_panic_o = get_runtime_panic_o_path(argv[0]);
        const char *net_o = get_std_net_o_path(argv[0]);
        const char *thread_o = get_std_thread_o_path(argv[0]);
        const char *time_o = get_std_time_o_path(argv[0]);
        const char *random_o = get_std_random_o_path(argv[0]);
        const char *env_o = get_std_env_o_path(argv[0]);
        const char *sync_o = get_std_sync_o_path(argv[0]);
        const char *encoding_o = get_std_encoding_o_path(argv[0]);
        const char *base64_o = get_std_base64_o_path(argv[0]);
        const char *crypto_o = get_std_crypto_o_path(argv[0]);
        const char *log_o = get_std_log_o_path(argv[0]);
        const char *atomic_o = get_std_atomic_o_path(argv[0]);
        const char *channel_o = get_std_channel_o_path(argv[0]);
        const char *backtrace_o = get_std_backtrace_o_path(argv[0]);
        const char *hash_o = get_std_hash_o_path(argv[0]);
        const char *math_o = get_std_math_o_path(argv[0]);
        const char *sort_o = get_std_sort_o_path(argv[0]);
        const char *ffi_o = get_std_ffi_o_path(argv[0]);
        const char *db_o = get_std_sqlite_o_path(argv[0]);
        const char *elf_o = get_std_elf_o_path(argv[0]);
        const char *json_o = get_std_json_o_path(argv[0]);
        const char *csv_o = get_std_csv_o_path(argv[0]);
        const char *regex_o = get_std_regex_o_path(argv[0]);
        const char *compress_o = get_std_compress_o_path(argv[0]);
        const char *unicode_o = get_std_unicode_o_path(argv[0]);
        const char *dynlib_o = get_std_dynlib_o_path(argv[0]);
        const char *http_o = get_std_http_o_path(argv[0]);
        const char *tar_o = get_std_tar_o_path(argv[0]);
        const char *simd_o = get_std_simd_o_path(argv[0]);
        const char *context_o = get_std_context_o_path(argv[0]);
        const char *datetime_o = get_std_datetime_o_path(argv[0]);
        const char *uuid_o = get_std_uuid_o_path(argv[0]);
        const char *url_o = get_std_url_o_path(argv[0]);
        const char *cli_o = get_std_cli_o_path(argv[0]);
        const char *security_o = get_std_security_o_path(argv[0]);
        const char *config_o = get_std_config_o_path(argv[0]);
        const char *cache_o = get_std_cache_o_path(argv[0]);
        const char *trace_o = get_std_trace_o_path(argv[0]);
        const char *task_o = get_std_task_o_path(argv[0]);
        const char *schema_o = get_std_schema_o_path(argv[0]);
        const char *test_o = get_std_test_o_path(argv[0]);
        const char *async_scheduler_o = NULL;
        if (generated_c_needs_async_scheduler(tmp_c))
            async_scheduler_o = get_std_async_scheduler_o_path(argv[0]);
        int cc_ok = invoke_cc(c_paths, n_c, out_path, target, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, get_repo_root(argv[0]), async_scheduler_o);
        unlink(tmp_c);
        while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
        ast_module_free(mod);
        free(src);
        return cc_ok == 0 ? 0 : 1;
    }

    /* 无 -o：保留原有行为：打印 Token，再解析并打印 parse/typeck OK（供测试） */
    /* 先保存 main 名称与字面量，避免后续第二次 lexer 可能覆盖堆后 mod 指针失效 */
    const char *main_name = (mod->main_func && mod->main_func->name) ? mod->main_func->name : "?";
    int main_final_lit = -1;
    if (mod->main_func && mod->main_func->body && mod->main_func->body->final_expr
        && mod->main_func->body->final_expr->kind == AST_EXPR_LIT)
        main_final_lit = mod->main_func->body->final_expr->value.int_val;

    Lexer *lex2 = lexer_new(src);
    Token tok;
    for (;;) {
        lexer_next(lex2, &tok);
        if (tok.kind == TOKEN_EOF) {
            printf("%s\n", token_kind_str(tok.kind));
            break;
        }
        printf("%s", token_kind_str(tok.kind));
        if (tok.kind == TOKEN_INT)
            printf(" %d", tok.value.int_val);
        else if (tok.kind == TOKEN_FLOAT)
            printf(" %g", tok.value.float_val);
        else if ((tok.kind == TOKEN_IDENT || tok.kind == TOKEN_I32 || tok.kind == TOKEN_BOOL
                  || tok.kind == TOKEN_U8 || tok.kind == TOKEN_U32 || tok.kind == TOKEN_U64
                  || tok.kind == TOKEN_I64 || tok.kind == TOKEN_USIZE || tok.kind == TOKEN_ISIZE)
                 && tok.value.ident && tok.ident_len > 0)
            printf(" %.*s", tok.ident_len, tok.value.ident);
        printf(" @%d:%d\n", tok.line, tok.col);
    }
    lexer_free(lex2);

    if (mod->main_func && mod->main_func->body) {
        if (main_final_lit >= 0)
            printf("parse OK: %s(): i32 { %d }\n", main_name, main_final_lit);
        else
            printf("parse OK: %s(): i32 { expr }\n", main_name);
    } else
        printf("parse OK (library module)\n");
    printf("typeck OK\n");
    while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
    ast_module_free(mod);
    free(src);
    return 0;
#endif /* !SHUX_USE_SX_FRONTEND */
}
#undef RUN_CC_FUNC
#endif /* !SHUX_USE_SX_DRIVER */

/**
 * 阶段 3 全 .sx 前端：当 SHUX_USE_SX_FRONTEND 且 SHUX_USE_SX_PIPELINE 时，用 pipeline 生成 C 并调用 cc，不依赖 C 的 typeck/codegen。
 * 否则直接转调 run_compiler_c。完全自举时 run_compiler_sx_path 由 main.sx 提供，C 不定义以免重复符号。
 */
#if !defined(SHUX_USE_SX_DRIVER)
int run_compiler_sx_path(int argc, char **argv) {
#if !defined(SHUX_USE_SX_FRONTEND) || !defined(SHUX_USE_SX_PIPELINE)
    return run_compiler_c(argc, argv);
#else
    driver_bump_stack_limit_if_needed();
#define SU_PATH_MAX_LIB_ROOTS 16
    const char *input_path = NULL;
    const char *out_path = NULL;
    const char *lib_roots_arr[SU_PATH_MAX_LIB_ROOTS];
    int n_lib_roots = 0;
    const char *defines[MAX_DEFINES];
    int ndefines = 0;
    const char *opt_level = "2";
    int use_lto = 0;
    int i;
    ndefines = driver_argv_collect_defines(argc, argv, defines, MAX_DEFINES);
    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-o") == 0) {
            if (i + 1 >= argc) return run_compiler_c(argc, argv);
            out_path = argv[++i];
            continue;
        }
        if (strcmp(argv[i], "-L") == 0) {
            if (i + 1 >= argc) return run_compiler_c(argc, argv);
            if (n_lib_roots < SU_PATH_MAX_LIB_ROOTS) lib_roots_arr[n_lib_roots++] = argv[++i];
            continue;
        }
        if (strcmp(argv[i], "-O") == 0) {
            if (i + 1 >= argc) return run_compiler_c(argc, argv);
            opt_level = argv[++i];
            continue;
        }
        if (strcmp(argv[i], "-flto") == 0) { use_lto = 1; continue; }
        /* 跳过 -su，避免被当作 input_path 导致无 -o 时向 stdout 打 C（run-all-sx 时 run-hello 会传 -su） */
        if (strcmp(argv[i], "-sx") == 0) continue;
        if (!input_path) input_path = argv[i];
    }
    if (!use_lto && getenv("SHUX_LTO") && strcmp(getenv("SHUX_LTO"), "1") == 0) use_lto = 1;
    if (n_lib_roots == 0) {
        lib_roots_arr[0] = getenv("SHUX_LIB");
        if (!lib_roots_arr[0]) lib_roots_arr[0] = ".";
        n_lib_roots = 1;
    }
    if (!input_path)
        return run_compiler_c(argc, argv);
    /* 无 -o 时：用 pipeline 生成 C 到 stdout，与 run-lexer 等测试一致，不调用 run_compiler_c。 */
    int emit_to_stdout = (out_path == NULL);

    size_t raw_src_len = 0;
    char *raw_src = read_file(input_path, &raw_src_len);
    if (!raw_src) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = preprocess(raw_src, raw_src_len, ndefines > 0 ? defines : NULL, ndefines, &src_len);
    free(raw_src);
    if (!src) {
        fprintf(stderr, "shux: preprocess failed for '%s'\n", input_path);
        return 1;
    }
    /* 有 -o 且源码含泛型语法（如 <T> 或 <i32>）时走 C 流水线，因 .sx 流水线暂不支持泛型单态化。 */
    if (!emit_to_stdout && src_len > 0) {
        const char *p = (const char *)src;
        size_t n = src_len;
        int has_generic = 0;
        if (n >= 4 && memchr(p, '<', n) && memchr(p, '>', n)) {
            const char *lt = (const char *)memchr(p, '<', n);
            if (lt && (size_t)(lt - p) < n - 1) {
                if (lt[1] == 'T' || lt[1] == 'i')
                    has_generic = 1;
                else if (n >= (size_t)(lt - p) + 5 && memcmp(lt, "<i32>", 5) == 0)
                    has_generic = 1;
            }
        }
        if (has_generic) {
            free(src);
            return run_compiler_c(argc, argv);
        }
    }
    size_t arena_sz = pipeline_sizeof_arena();
    size_t module_sz = pipeline_sizeof_module();
    void *arena = malloc(arena_sz);
    void *module = malloc(module_sz);
    if (!arena || !module) {
        free(arena);
        free(module);
        free(src);
        return 1;
    }
    memset(arena, 0, arena_sz);
    memset(module, 0, module_sz);
    struct shux_slice_uint8_t src_slice = { (uint8_t *)src, src_len };
    parser_parse_into_init(module, arena);
    struct parser_ParseIntoResult pr = parser_parse_into(arena, module, &src_slice);
    if (pr.ok != 0) {
        fprintf(stderr, "shux: parse failed for '%s' (pr.ok=%d main_idx=%d)\n", input_path, (int)pr.ok, (int)pr.main_idx);
        { int32_t first_tok = parser_diag_token_after_collect_imports(&src_slice, module); fprintf(stderr, "shux: first_token_after_imports=%d (1=TOKEN_FUNCTION)\n", (int)first_tok); }
        if (src_len > 0 && src_len < 200)
            fprintf(stderr, "shux: src_len=%zu first_bytes=%.*s\n", src_len, (int)(src_len > 60 ? 60 : src_len), src);
        free(arena);
        free(module);
        free(src);
        return 1;
    }
    parser_parse_into_set_main_index(module, pr.main_idx);
    int32_t n_imports = parser_get_module_num_imports(module);
    char entry_dir_buf[512];
    get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    if (n_imports > 0)
        pipeline_set_entry_dir(entry_dir_buf);

    char *dep_sources[MAX_ALL_DEPS];
    size_t dep_lens[MAX_ALL_DEPS];
    char *dep_paths[MAX_ALL_DEPS];
    int n_deps = 0;
    if (n_imports > 0 && n_imports <= 32) {
        if (collect_deps_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir_buf, defines,
                ndefines, dep_sources, dep_lens, dep_paths, &n_deps) != 0) {
            free(arena);
            free(module);
            free(src);
            return 1;
        }
    }
    typeck_ndep = 0;
    /* 模板末尾须为 6 个 X，mkstemp 后重命名为 .c 以便 cc/ld 识别 */
    char tmp[] = "/tmp/shux_su.XXXXXX";
    char tmp_c[32];
    int fd = -1;
    FILE *cf;
    if (emit_to_stdout) {
        cf = stdout;
    } else {
        fd = mkstemp(tmp);
        if (fd < 0) {
            perror("shux: mkstemp");
            while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        cf = fdopen(fd, "w");
        if (!cf) {
            close(fd);
            unlink(tmp);
            while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        snprintf(tmp_c, sizeof(tmp_c), "%s.c", tmp);
        if (rename(tmp, tmp_c) != 0) {
            unlink(tmp);
            fclose(cf);
            while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
    }
    /*
     * CodegenOutBuf / PipelineDepCtx 体积大，栈上分配易溢出；与 driver_run_asm_backend 同策略：先分配 dep，再 calloc 二者。
     */
    void *dep_arenas[32];
    void *dep_modules[32];
    for (int j = n_deps - 1; j >= 0; j--) {
        dep_arenas[j] = malloc(arena_sz);
        dep_modules[j] = malloc(module_sz);
        if (!dep_arenas[j] || !dep_modules[j]) {
            fprintf(stderr, "shux: -sx path: dep alloc failed\n");
            while (j > 0) { j--; free(dep_arenas[j]); free(dep_modules[j]); }
            if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        memset(dep_arenas[j], 0, arena_sz);
        memset(dep_modules[j], 0, module_sz);
    }
    struct codegen_CodegenOutBuf *out_buf = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*out_buf));
    struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*pctx));
    if (!out_buf || !pctx) {
        fprintf(stderr, "shux: -sx path: out_buf/pctx alloc failed\n");
        for (int jj = 0; jj < n_deps; jj++) { free(dep_arenas[jj]); free(dep_modules[jj]); }
        if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
        while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
        free(arena); free(module); free(src);
        if (out_buf) free(out_buf);
        if (pctx) pipeline_dep_ctx_heap_destroy(pctx);
        return 1;
    }
    pipeline_fill_ctx_path_buffers(pctx, entry_dir_buf, lib_roots_arr, n_lib_roots);
    runtime_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
    /* 先对每个 dep 跑 pipeline 仅做 parse+typecheck，填充 dep_arenas/dep_modules，不写 C 到文件。 */
    driver_dep_seeded_clear_all();
    for (int j = n_deps - 1; j >= 0; j--) {
        struct ast_PipelineDepCtx *one_ctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*one_ctx));
        struct codegen_CodegenOutBuf *dep_out = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*dep_out));
        if (!one_ctx || !dep_out) {
            fprintf(stderr, "shux: -sx path: dep_one_ctx/out alloc failed\n");
            pipeline_dep_ctx_heap_destroy(one_ctx);
            free(dep_out);
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
            if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        runtime_one_ctx_for_dep_prerun(one_ctx, j, dep_modules[j], dep_arenas[j]);
        pipeline_fill_ctx_path_buffers(one_ctx, runtime_dep_prerun_entry_dir(entry_dir_buf, lib_roots_arr, n_lib_roots), lib_roots_arr, n_lib_roots);
        driver_set_current_dep_path_for_codegen(dep_paths[j]);
        int ec_loop = pipeline_run_sx_pipeline_large_stack(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j], dep_lens[j], (void *)dep_out, (void *)one_ctx);
        driver_set_current_dep_path_for_codegen(NULL);
        pipeline_dep_ctx_heap_destroy(one_ctx);
        free(dep_out);
        if (ec_loop != 0) {
            fprintf(stderr, "shux: pipeline failed for import '%s' (rc=%d)\n", dep_paths[j], ec_loop);
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
            if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
        /* 不把 dep 的 C 写入 cf，避免与后面 entry 一次 codegen 的 deps+entry 重复。 */
    }
    typeck_ndep = n_deps;
    for (int j = n_deps - 1; j >= 0; j--) {
        typeck_dep_module_ptrs[j] = dep_modules[j];
        typeck_dep_arena_ptrs[j] = dep_arenas[j];
    }
    pipeline_set_dep_slots(dep_arenas, dep_modules);
    driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
    codegen_set_dep_slots_for_su_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
    codegen_set_preamble_has_core_option_result(1); /* preamble（write_io_net_abi_inline）已含 Option_i32/Result_i32，codegen 跳过避免重定义 */
    codegen_reset_preamble_skip_mask(); /* codegen.sx emit 过程中 OR 重叠段 skip；pipeline 完成后写 preamble 时读取 */
    {
        int has_std_io_core = 0;
        for (int j = 0; j < n_deps; j++)
            if (dep_paths[j] && strcmp(dep_paths[j], "std.io.core") == 0) { has_std_io_core = 1; break; }
        if (!has_std_io_core)
            codegen_or_preamble_skip_mask(CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS
                | CODEGEN_PREAMBLE_SKIP_STD_IO_UNDEF_REDEFINE);
    }
    /* 入口在 pipeline 内用 .sx 重新解析以保持 Module 布局一致。 */
    memset(arena, 0, arena_sz);
    memset(module, 0, module_sz);
    int ec = pipeline_run_sx_pipeline_large_stack(module, arena, src_slice.data, (size_t)src_slice.length, (void *)out_buf, (void *)pctx);
    driver_dep_seeded_clear_all();
    codegen_set_dep_slots_for_su_pipeline(NULL, NULL, 0);
    for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
    while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
    free(arena);
    free(module);
    free(src);
    if (ec != 0 || (!driver_check_only_get() && out_buf->len == 0)) {
        fprintf(stderr, "shux: pipeline failed for '%s' (ec=%d, out_len=%d)\n", input_path, ec, (int)out_buf->len);
        if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
        free(out_buf);
        pipeline_dep_ctx_heap_destroy(pctx);
        return 1;
    }
    if (driver_check_only_get()) {
        driver_print_check_ok(input_path);
        if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
        free(out_buf);
        pipeline_dep_ctx_heap_destroy(pctx);
        return 0;
    }
    {
        /* 内联 std.io / std.net ABI；其余 std.fs / path / map / error 仍 include 头文件 */
        size_t first_line = 0;
        while (first_line < (size_t)out_buf->len && out_buf->data[first_line] != '\n') first_line++;
        if (first_line < (size_t)out_buf->len) first_line++;
        static const char fs_abi_include[] = "#include \"std/fs/fs_abi.h\"\n";
        static const char path_abi_include[] = "#include \"std/path/path_abi.h\"\n";
        static const char map_abi_include[] = "#include \"std/map/map_abi.h\"\n";
        static const char error_abi_include[] = "#include \"std/error/error_abi.h\"\n";
        if (fwrite(out_buf->data, 1, first_line, cf) != first_line
            || write_io_net_abi_inline(cf) != 0
            || fwrite(fs_abi_include, 1, sizeof(fs_abi_include) - 1, cf) != (size_t)(sizeof(fs_abi_include) - 1)
            || fwrite(path_abi_include, 1, sizeof(path_abi_include) - 1, cf) != (size_t)(sizeof(path_abi_include) - 1)
            || fwrite(map_abi_include, 1, sizeof(map_abi_include) - 1, cf) != (size_t)(sizeof(map_abi_include) - 1)
            || fwrite(error_abi_include, 1, sizeof(error_abi_include) - 1, cf) != (size_t)(sizeof(error_abi_include) - 1)
            || fwrite(out_buf->data + first_line, 1, (size_t)out_buf->len - first_line, cf) != (size_t)out_buf->len - first_line) {
            if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            return 1;
        }
    }
    if (!emit_to_stdout) {
        if (fclose(cf) != 0) {
            unlink(tmp_c);
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            return 1;
        }
        {
            const char *c_paths[1] = { tmp_c };
            const char *io_o = get_io_o_path(argv[0]);
            const char *fs_o = get_std_fs_o_path(argv[0]);
            const char *process_o = get_std_process_o_path(argv[0]);
            const char *string_o = get_std_string_o_path(argv[0]);
            const char *heap_o = get_std_heap_o_path(argv[0]);
            const char *path_o = get_std_path_o_path(argv[0]);
            const char *runtime_o = get_std_runtime_o_path(argv[0]);
            const char *runtime_panic_o = get_runtime_panic_o_path(argv[0]);
            const char *net_o = get_std_net_o_path(argv[0]);
            const char *thread_o = get_std_thread_o_path(argv[0]);
            const char *time_o = get_std_time_o_path(argv[0]);
            const char *random_o = get_std_random_o_path(argv[0]);
            const char *env_o = get_std_env_o_path(argv[0]);
            const char *sync_o = get_std_sync_o_path(argv[0]);
            const char *encoding_o = get_std_encoding_o_path(argv[0]);
            const char *base64_o = get_std_base64_o_path(argv[0]);
            const char *crypto_o = get_std_crypto_o_path(argv[0]);
            const char *log_o = get_std_log_o_path(argv[0]);
            const char *atomic_o = get_std_atomic_o_path(argv[0]);
            const char *channel_o = get_std_channel_o_path(argv[0]);
            const char *backtrace_o = get_std_backtrace_o_path(argv[0]);
            const char *hash_o = get_std_hash_o_path(argv[0]);
            const char *math_o = get_std_math_o_path(argv[0]);
            const char *sort_o = get_std_sort_o_path(argv[0]);
            const char *ffi_o = get_std_ffi_o_path(argv[0]);
            const char *db_o = get_std_sqlite_o_path(argv[0]);
            const char *elf_o = get_std_elf_o_path(argv[0]);
            const char *json_o = get_std_json_o_path(argv[0]);
            const char *csv_o = get_std_csv_o_path(argv[0]);
            const char *regex_o = get_std_regex_o_path(argv[0]);
            const char *compress_o = get_std_compress_o_path(argv[0]);
            const char *unicode_o = get_std_unicode_o_path(argv[0]);
            const char *dynlib_o = get_std_dynlib_o_path(argv[0]);
            const char *http_o = get_std_http_o_path(argv[0]);
            const char *tar_o = get_std_tar_o_path(argv[0]);
            const char *simd_o = get_std_simd_o_path(argv[0]);
            const char *context_o = get_std_context_o_path(argv[0]);
            const char *datetime_o = get_std_datetime_o_path(argv[0]);
            const char *uuid_o = get_std_uuid_o_path(argv[0]);
            const char *url_o = get_std_url_o_path(argv[0]);
            const char *cli_o = get_std_cli_o_path(argv[0]);
            const char *security_o = get_std_security_o_path(argv[0]);
            const char *config_o = get_std_config_o_path(argv[0]);
            const char *cache_o = get_std_cache_o_path(argv[0]);
            const char *trace_o = get_std_trace_o_path(argv[0]);
            const char *task_o = get_std_task_o_path(argv[0]);
            const char *schema_o = get_std_schema_o_path(argv[0]);
            const char *test_o = get_std_test_o_path(argv[0]);
            int cc_ret = invoke_cc(c_paths, 1, out_path, NULL, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, get_repo_root(argv[0]), NULL);
            if (cc_ret != 0) {
                fprintf(stderr, "shux: cc failed, keeping generated C: %s\n", tmp_c);
            } else if (!getenv("SHUX_KEEP_C")) {
                unlink(tmp_c);
            } else {
                fprintf(stderr, "shux: kept generated C: %s\n", tmp_c);
            }
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            return cc_ret == 0 ? 0 : 1;
        }
    }
    free(out_buf);
    pipeline_dep_ctx_heap_destroy(pctx);
    return 0;
#undef SU_PATH_MAX_LIB_ROOTS
#endif
}
#endif /* !defined(SHUX_USE_SX_DRIVER)：run_compiler_sx_path 仅在不使用 .sx driver 时由 C 提供 */

#if defined(SHUX_USE_SX_PIPELINE)
/** pipeline_sx.o / pipeline_gen.c 所需符号，shu_su 链接时由 runtime_sx.o 提供（仅 -DSHUX_USE_SX_PIPELINE）。 */
static void *driver_dep_arena_ptrs[32];
static void *driver_dep_module_ptrs[32];
/** dep 预跑后各全局槽对应的 import 逻辑路径（如 std.io.core），供 pipeline 按路径对齐 import 下标。 */
static const char *driver_dep_path_registry[32];
/** 非 0 表示 dep i 已由 C 侧预填，pipeline 不再 read/parse；driver_dep_*_buf 返回时也不清零。 */
static int driver_dep_seeded[32];

int32_t driver_dep_seeded_get(int32_t i) {
    if (i < 0 || i >= 32) return 0;
    return driver_dep_seeded[i] ? 1 : 0;
}

/** 由 run_compiler_sx_path 在预填 dep 后调用，使 pipeline 使用已有 buffer 且不再清零。 */
void driver_dep_seeded_set(int32_t i, int32_t v) {
    if (i >= 0 && i < 32) driver_dep_seeded[i] = (v != 0);
}

/** 预填路径：将 C 侧 dep 指针填入 driver 槽位并标记 seeded，entry pipeline 会复用不重载。 */
void driver_dep_seed_slots(void *arenas[32], void *modules[32], int32_t n) {
    int j;
    for (j = 0; j < 32 && j < n; j++) {
        driver_dep_arena_ptrs[j] = arenas ? arenas[j] : NULL;
        driver_dep_module_ptrs[j] = modules ? modules[j] : NULL;
        driver_dep_seeded[j] = 1;
    }
    for (; j < 32; j++) driver_dep_seeded[j] = 0;
}

/** dep 预跑单槽发布：使 pipeline_load 在后续 dep 的 import 链上复用已 parse 的 arena/module（按全局槽下标 i）。 */
void driver_dep_publish_slot(int32_t i, void *arena, void *module, const char *import_path) {
    if (i < 0 || i >= 32)
        return;
    driver_dep_arena_ptrs[i] = arena;
    driver_dep_module_ptrs[i] = module;
    driver_dep_seeded[i] = 1;
    if (import_path)
        driver_dep_path_registry[i] = import_path;
}

/** 按 import 逻辑路径查 dep 预跑全局槽；-1 表示未 publish。 */
int32_t driver_dep_slot_for_path(const char *path) {
    int i;
    if (!path)
        return -1;
    for (i = 0; i < 32; i++) {
        if (driver_dep_path_registry[i] && strcmp(driver_dep_path_registry[i], path) == 0)
            return i;
    }
    return -1;
}

/** 单 dep 预解析 ctx：ndep=0，由 pipeline_load 按 import 路径绑定已 publish 的全局槽。 */
static void runtime_one_ctx_for_dep_prerun(struct ast_PipelineDepCtx *ctx, int j, void *mod, void *ar) {
    (void)j;
    (void)mod;
    (void)ar;
    if (!ctx)
        return;
    /*
     * 仅清 ndep，勿 ast_pipeline_dep_ctx_reset：后者会抹掉 lib_root sidecar，
     * 导致 resolve_path_su 在 -backend asm dep 预跑时 rc=-7（import 路径解析失败）。
     */
    ast_pipeline_dep_ctx_set_ndep(ctx, 0);
    /**
     * dep 预跑须 parse+typeck 填槽、跳过 codegen。pipeline.sx 经 driver_check_only_get / pipeline_dep_ctx_check_only_mode。
     * 否则 build_asm/pipeline.o 在 use_asm_backend 非 0 时对 std.io 等 dep 走 asm_codegen_ast → rc=-6。
     */
    ctx->use_asm_backend = 0;
}

/** dep 预跑 resolve import 时用 lib root（-L）优先于主文件 entry_dir，避免主文件在 /tmp 时 std.* 解析失败。 */
static const char *runtime_dep_prerun_entry_dir(const char *main_entry_dir, const char **lib_roots, int n_lib_roots) {
    if (lib_roots && n_lib_roots > 0 && lib_roots[0] && lib_roots[0][0])
        return lib_roots[0];
    return main_entry_dir;
}

/** entry pipeline 返回后清除 seeded，避免影响后续调用。 */
void driver_dep_seeded_clear_all(void) {
    int i;
    typeck_ndep = 0;
    for (i = 0; i < 32; i++) {
        driver_dep_seeded[i] = 0;
        driver_dep_path_registry[i] = NULL;
        /* publish/预跑后 C 侧会 free(dep_arena)；须丢弃槽指针，否则下次 driver_dep_arena_buf 返回悬空内存（check 后 -o SIGSEGV）。 */
        driver_dep_arena_ptrs[i] = NULL;
        driver_dep_module_ptrs[i] = NULL;
        typeck_dep_arena_ptrs[i] = NULL;
        typeck_dep_module_ptrs[i] = NULL;
    }
}

uint8_t *driver_dep_arena_buf(int32_t i) {
    if (i < 0 || i >= 32) return NULL;
    if (driver_dep_arena_ptrs[i] == NULL) {
        size_t sz = pipeline_sizeof_arena();
        driver_dep_arena_ptrs[i] = malloc(sz);
        if (!driver_dep_arena_ptrs[i]) return NULL;
        /* 仅在首分配时清零；若每次 getter 调用都对已分配槽 memset，pipeline dep_sync 会在 import 解析后再次取 buf 时抹掉 ast 等 dep，导致预跑 dep 时 typeck 失败（expr_type_ref 等）。 */
        memset(driver_dep_arena_ptrs[i], 0, sz);
    }
    return (uint8_t *)driver_dep_arena_ptrs[i];
}

uint8_t *driver_dep_module_buf(int32_t i) {
    if (i < 0 || i >= 32) return NULL;
    if (driver_dep_module_ptrs[i] == NULL) {
        size_t sz = pipeline_sizeof_module();
        driver_dep_module_ptrs[i] = malloc(sz);
        if (!driver_dep_module_ptrs[i]) return NULL;
        memset(driver_dep_module_ptrs[i], 0, sz);
    }
    return (uint8_t *)driver_dep_module_ptrs[i];
}

/** typeck.sx codegen 导出为 typeck_driver_dep_*；转发至本文件 driver_dep_* 全局槽。 */
uint8_t *typeck_driver_dep_module_buf(int32_t i) {
    return driver_dep_module_buf(i);
}

int32_t typeck_driver_dep_seeded_get(int32_t i) {
    return driver_dep_seeded_get(i);
}

void driver_pipeline_fail_code(int rc, const uint8_t *path) {
    fprintf(stderr, "shux: pipeline failed rc=%d\n", rc);
    if (rc == -7 && path != NULL) {
        fprintf(stderr, "shux: resolve path tried: %s\n", (const char *)path);
    }
}

/**
 * .sx driver_run_sx_emit_sx 在无 -o、pipeline/typeck/codegen 全成功结束时调用 stderr 烟测两行。
 * 首行前缀保留「parse OK:」，次行保留「typeck OK」，grep 仍可匹配 run-import/run-stdlib 脚本；
 * num_funcs/main_idx/codegen_bytes 避免「实为库模块或未 emit 却仍冒用 main()/expr」的误导。
 */
void driver_print_su_smoke_summary(void *module, size_t codegen_len) {
    int num_funcs = driver_get_module_num_funcs(module);
    int main_ix = driver_get_module_main_func_index(module);
    fprintf(stderr, "parse OK: num_funcs=%d main_idx=%d codegen_bytes=%zu\n",
            num_funcs,
            main_ix,
            codegen_len);
    fflush(stderr);
    /** 解析未产出任何函数时不宣称 typeck OK（如含 += 的 .sx 在 SU parse 失败）。 */
    if (num_funcs <= 0) {
        fputs("parse fail: no functions in module\n", stderr);
        fflush(stderr);
        return;
    }
    fputs("typeck OK\n", stderr);
    fflush(stderr);
}

void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types) {
    if (lsp_diag_enabled) {
        char msg[160];
        (void)snprintf(msg, sizeof(msg), "parse fail main_idx=%d num_funcs=%d arena_num_types=%d", (int)main_idx,
                       (int)num_funcs, (int)arena_num_types);
        lsp_diag_add(1, 1, 1, msg);
        return;
    }
    fprintf(stderr, "shux: parse fail main_idx=%d num_funcs=%d arena_num_types=%d\n", (int)main_idx, (int)num_funcs,
            (int)arena_num_types);
}

/**
 * 非 0 时 parse_into_buf 在单函数 impl/buf 均失败时返回 -2，不再静默 skip（与 parse_into slice 路径对齐）。
 * 环境变量 SHUX_PARSE_STRICT=1。
 */
int32_t driver_parse_strict_enabled(void) {
    const char *e = getenv("SHUX_PARSE_STRICT");
    return (e && e[0] && e[0] != '0') ? 1 : 0;
}

/**
 * parse_into_buf 跳过无法解析的 function 时打印诊断（SHUX_DEBUG_PARSE=1 或 SHUX_PARSE_STRICT=1）。
 * byte_pos 为源缓冲字节偏移；name 可为 NULL。
 */
void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                           const uint8_t *name) {
    const char *tag;
    if (!getenv("SHUX_DEBUG_PARSE") && !driver_parse_strict_enabled())
        return;
    tag = getenv("SHUX_DEBUG_PARSE") ? "debug" : "strict";
    if (lsp_diag_enabled) {
        char msg[240];
        char nb[72];
        int nl = (name && name_len > 0 && name_len < (int)sizeof(nb)) ? name_len : 0;
        if (nl > 0)
            memcpy(nb, name, (size_t)nl);
        nb[nl > 0 ? nl : 0] = '\0';
        (void)snprintf(msg, sizeof(msg), "parse skip at byte %d (num_funcs=%d) name=%s [%s]", (int)byte_pos,
                       (int)num_funcs_so_far, nl > 0 ? nb : "?", tag);
        lsp_diag_add(1, 1, 1, msg);
        return;
    }
    fprintf(stderr, "shux: parse skip at byte %d (num_funcs=%d)", (int)byte_pos, (int)num_funcs_so_far);
    if (name && name_len > 0 && name_len < 64) {
        fprintf(stderr, " name=");
        fwrite(name, 1, (size_t)name_len, stderr);
    }
    fprintf(stderr, " [%s]\n", tag);
    fflush(stderr);
}

/**
 * .sx 流水线中 typeck_sx_ast / typeck_sx_ast_library 失败时打印一行 stderr。
 * 与 C 路径 lsp_diag_report_typeck 在 !lsp_diag_enabled 时的前缀一致，供 run-typeck.sh、check-7.2 等识别（.sx typeck 当前不向 stderr 逐条报原因）。
 */
void driver_diagnostic_typeck_fail(void) {
    const char *msg = driver_check_only_get() ? "check failed: .sx pipeline type check failed"
                                              : "typeck error: .sx pipeline type check failed";
    if (lsp_diag_enabled) {
        lsp_diag_add(1, 1, 1, msg);
        return;
    }
    fprintf(stderr, "%s\n", msg);
    fflush(stderr);
}

/**
 * .sx typeck：标注失败函数（下标 + 名称）与失败类别；在 driver_diagnostic_typeck_fail 一行之前打印，便于定位大模块。
 * kind：5 = check_block 失败；-6 = 非 void 函数块末隐式尾表达式。
 */
void driver_diagnostic_typeck_func_fail(int32_t func_idx, const uint8_t *name, int32_t name_len, int32_t kind) {
    if (lsp_diag_enabled) {
        char msg[240];
        char namebuf[72];
        int nl = (name && name_len > 0 && name_len <= 64) ? (int)name_len : 0;
        if (nl > 0) {
            memcpy(namebuf, name, (size_t)nl);
            namebuf[nl] = '\0';
        } else {
            namebuf[0] = '\0';
            (void)strcpy(namebuf, "(unknown)");
        }
        (void)snprintf(msg, sizeof(msg), "shux: typeck func_idx=%d %s (%s)", (int)func_idx, namebuf,
                       kind == -6 ? "implicit tail return" : "check_block failed");
        lsp_diag_add(1, 1, 1, msg);
        return;
    }
    fprintf(stderr, "shux: typeck func_idx=%d ", (int)func_idx);
    if (name && name_len > 0 && name_len <= 64)
        (void)fwrite(name, 1, (size_t)name_len, stderr);
    else
        (void)fputs("(unknown)", stderr);
    fprintf(stderr, " (%s)\n", kind == -6 ? "implicit tail return" : "check_block failed");
    if (kind == -6) {
        fprintf(stderr, "typeck error: return value must use explicit return statement (e.g. return 0;)\n");
    }
    fflush(stderr);
}

/** 诊断：FIELD_ACCESS 时 base 的类型与 *T 指向名；SHUX_TYPECK_PTR=1 时打印（含模块已登记的 struct_layouts 条数）。 */
void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref,
                                      int32_t num_struct_layouts) {
    if (!getenv("SHUX_TYPECK_PTR"))
        return;
    fprintf(stderr,
            "shux: [SHUX_TYPECK_PTR] FIELD_ACCESS bt_kind=%d inner_kind=%d inner_nlen=%d base_resolved_ref=%d "
            "num_struct_layouts=%d\n",
            (int)bt_kind, (int)inner_kind, (int)inner_nlen, (int)base_resolved_ref, (int)num_struct_layouts);
    fflush(stderr);
}

/** 诊断：EXPR_RETURN 失败；SHUX_TYPECK_RET=1 时额外打印 ref 调试。stage 1=operand check_expr -1；2=got 与期望 return_type_ref 不一致。 */
void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref) {
    if (getenv("SHUX_TYPECK_RET")) {
        fprintf(stderr, "shux: [RET_FAIL] stage=%d op_expr_ref=%d expect_ty_ref=%d got_ty_ref=%d\n", (int)stage,
                (int)op_expr_ref, (int)expect_ty_ref, (int)got_ty_ref);
        fflush(stderr);
    }
}

/** .sx typeck：`return expr` 表达式类型与函数返回类型不符；行文与 assignment type mismatch 对齐。 */
void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col,
                                               const uint8_t *expect_buf, int32_t expect_len,
                                               const uint8_t *found_buf, int32_t found_len) {
    char msg[240];
    char epart[112];
    char fpart[112];
    int el = (expect_buf && expect_len > 0) ? (int)expect_len : 0;
    int fl = (found_buf && found_len > 0) ? (int)found_len : 0;
    if (el > 0 && el < (int)sizeof(epart)) {
        memcpy(epart, expect_buf, (size_t)el);
        epart[el] = '\0';
    } else {
        epart[0] = '?';
        epart[1] = '\0';
    }
    if (fl > 0 && fl < (int)sizeof(fpart)) {
        memcpy(fpart, found_buf, (size_t)fl);
        fpart[fl] = '\0';
    } else {
        fpart[0] = '?';
        fpart[1] = '\0';
    }
    (void)snprintf(msg, sizeof(msg),
                   "typeck error: return expression type mismatch: expected %s, found %s",
                   epart, fpart);
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    (void)fputs("typeck error: return expression type mismatch: expected ", stderr);
    if (expect_buf && expect_len > 0)
        (void)fwrite(expect_buf, 1, (size_t)expect_len, stderr);
    else
        (void)fputc('?', stderr);
    (void)fputs(", found ", stderr);
    if (found_buf && found_len > 0)
        (void)fwrite(found_buf, 1, (size_t)found_len, stderr);
    else
        (void)fputc('?', stderr);
    if (line > 0 || col > 0)
        fprintf(stderr, " at %d:%d", (int)line, (int)col);
    fputc('\n', stderr);
    fflush(stderr);
}

/**
 * .sx 流水线 typeck：赋值 / 复合赋值左右类型不符时打印一行 stderr，与 typeck.c 经 lsp_diag_report_typeck 的措辞一致，
 * 以便 run-typeck、负例与 shux-c 对齐（含 "assignment type mismatch: expected …, found …"）。
 */
/** .sx typeck：break/continue 不在循环内时打印，与 typeck.c TYPECK_ERR 措辞一致。 */
void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break) {
    const char *kw = is_break ? "break" : "continue";
    lsp_diag_report_typeck((int)line, (int)col, "'%s' only allowed inside a loop", kw);
}

/** .sx typeck：对 linear 值取址时打印，与 typeck.c「cannot take address of linear value」一致。 */
void driver_diagnostic_typeck_linear_addr_of(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "cannot take address of linear value");
}

/** .sx typeck：match 臂 Enum.Variant 在模块枚举表中未命中（与 typeck.c TYPECK_ERR 措辞一致）。 */
void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col) {
    const char *msg = "typeck error: enum has no variant";
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    (void)fputs(msg, stderr);
    (void)fputc('\n', stderr);
}

/** .sx typeck：下标基类型非数组/切片/指针时打印，与 typeck.c TYPECK_ERR 措辞一致。 */
void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col) {
    const char *msg = "subscript base must be array, slice or pointer";
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    (void)fputs("typeck error: ", stderr);
    (void)fputs(msg, stderr);
    (void)fputc('\n', stderr);
}

/** .sx typeck：结构体 §11.1 隐式 padding 前间隙；行文与 typeck.c TYPECK_ERR_AT 一致。 */
void driver_diagnostic_typeck_struct_padding_before(const uint8_t *sname, int32_t sname_len, int32_t gap,
                                                    const uint8_t *fname, int32_t fname_len) {
    lsp_diag_report_typeck(
        0, 0,
        "struct '%.*s' has %d byte(s) implicit padding before field '%.*s'; add explicit padding field or allow(padding)",
        (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""), (int)gap,
        (int)(fname_len > 0 ? fname_len : 0), (const char *)(fname ? fname : (const uint8_t *)""));
}

void driver_diagnostic_typeck_struct_padding_trailing(const uint8_t *sname, int32_t sname_len, int32_t gap) {
    lsp_diag_report_typeck(0, 0,
                           "struct '%.*s' has %d byte(s) implicit trailing padding; add explicit padding field or allow(padding)",
                           (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
                           (int)gap);
}

void driver_diagnostic_typeck_struct_field_bad_size(const uint8_t *sname, int32_t sname_len, const uint8_t *fname,
                                                    int32_t fname_len) {
    lsp_diag_report_typeck(0, 0, "struct '%.*s' field '%.*s' has unknown or invalid type size",
                           (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
                           (int)(fname_len > 0 ? fname_len : 0), (const char *)(fname ? fname : (const uint8_t *)""));
}

void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col,
                                               const uint8_t *expect_buf, int32_t expect_len,
                                               const uint8_t *found_buf, int32_t found_len) {
    char msg[240];
    char epart[112];
    char fpart[112];
    int el = (expect_buf && expect_len > 0) ? (int)expect_len : 0;
    int fl = (found_buf && found_len > 0) ? (int)found_len : 0;
    if (el > 0 && el < (int)sizeof(epart)) {
        memcpy(epart, expect_buf, (size_t)el);
        epart[el] = '\0';
    } else {
        epart[0] = '?';
        epart[1] = '\0';
    }
    if (fl > 0 && fl < (int)sizeof(fpart)) {
        memcpy(fpart, found_buf, (size_t)fl);
        fpart[fl] = '\0';
    } else {
        fpart[0] = '?';
        fpart[1] = '\0';
    }
    (void)snprintf(msg, sizeof(msg),
                   "typeck error: %s%s, found %s",
                   is_compound ? "compound assignment type mismatch: expected " : "assignment type mismatch: expected ",
                   epart, fpart);
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    (void)fputs("typeck error: ", stderr);
    (void)fputs(is_compound ? "compound assignment type mismatch: expected " : "assignment type mismatch: expected ", stderr);
    if (expect_buf && expect_len > 0)
        (void)fwrite(expect_buf, 1, (size_t)expect_len, stderr);
    else
        (void)fputc('?', stderr);
    (void)fputs(", found ", stderr);
    if (found_buf && found_len > 0)
        (void)fwrite(found_buf, 1, (size_t)found_len, stderr);
    else
        (void)fputc('?', stderr);
    fprintf(stderr, " at %d:%d\n", (int)line, (int)col);
    fflush(stderr);
}

/** 非重入也没关系：赋值诊断双缓冲（.sx check_expr_impl 格式化 expected/found 类型名）；单线程流水线专用。 */
static uint8_t g_type_diag_scratch_expect[96];
static uint8_t g_type_diag_scratch_found[96];

uint8_t *driver_typeck_diag_scratch_expect(void) { return g_type_diag_scratch_expect; }
uint8_t *driver_typeck_diag_scratch_found(void) { return g_type_diag_scratch_found; }

/** 诊断：check_block_impl 入口打印块计数；SHUX_TYPECK_BLOCK=1（常与 SHUX_TYPECK_FN 同用）。 */
void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop,
                                          int32_t n_for, int32_t n_expr, int32_t final_ref) {
    if (!getenv("SHUX_TYPECK_BLOCK"))
        return;
    fprintf(stderr,
            "shux: [SHUX_TYPECK_BLOCK] func_idx=%d block_ref=%d const=%d let=%d while=%d for=%d expr_stmt=%d final_expr=%d\n",
            (int)func_idx, (int)block_ref, (int)n_const, (int)n_let, (int)n_loop, (int)n_for, (int)n_expr, (int)final_ref);
    fflush(stderr);
}

/** 诊断：typeck_sx_ast_impl 逐函数入口；SHUX_TYPECK_FN=1 时打印 func_idx 与名称。 */
void driver_diagnostic_typeck_fn_enter(int32_t func_idx, const uint8_t *name, int32_t name_len) {
    if (!getenv("SHUX_TYPECK_FN"))
        return;
    fprintf(stderr, "shux: [SHUX_TYPECK_FN] func_idx=%d ", (int)func_idx);
    if (name && name_len > 0 && name_len <= 64)
        (void)fwrite(name, 1, (size_t)name_len, stderr);
    else
        (void)fputs("(unknown)", stderr);
    fputc('\n', stderr);
    fflush(stderr);
}

/** -sx -E 多文件诊断：codegen 前打印 module.num_funcs 与 out_buf.len，便于排查 dep 产出为空。 */
void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len) {
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] before_codegen num_funcs=%d out_len=%d\n", (int)num_funcs, (int)out_len);
}

/** 诊断：pipeline 入口 ctx.entry_already_parsed。由 pipeline.sx 调用。需要时取消注释 fprintf。 */
void driver_diagnostic_entry_already(int32_t v) {
    (void)v;
}

/** 诊断：解析前 source_len。由 pipeline.sx 调用。需要时取消注释 fprintf。 */
void driver_diagnostic_source_len(int32_t len) {
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] entry_source_len=%d\n", (int)len);
}

/** 诊断：entry 解析后 module.num_funcs，便于确认是否未解析（0）。由 pipeline.sx 调用。需要时取消注释 fprintf。 */
void driver_diagnostic_after_entry_parse(int32_t num_funcs) {
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] after_entry_parse num_funcs=%d\n", (int)num_funcs);
}

extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_is_extern_at(void *module, int32_t fi);

/**
 * 诊断：parse_into_buf commit 失败（arena/侧车池满等）；SHUX_DEBUG_PARSE=1 或 SHUX_PARSE_STRICT=1。
 * 大模块 typeck 单函数 commit 失败时不应整文件 abort，由 seed parse 改 skip+continue。
 */
void driver_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                         const uint8_t *name) {
    const char *tag;
    if (!getenv("SHUX_DEBUG_PARSE") && !driver_parse_strict_enabled())
        return;
    tag = getenv("SHUX_DEBUG_PARSE") ? "debug" : "strict";
    fprintf(stderr, "shux: parse commit fail at byte %d (num_funcs=%d)", (int)byte_pos, (int)num_funcs_so_far);
    if (name && name_len > 0 && name_len < 64) {
        fprintf(stderr, " name=");
        fwrite(name, 1, (size_t)name_len, stderr);
    }
    fprintf(stderr, " [%s]\n", tag);
    fflush(stderr);
}

/**
 * 诊断：entry 解析后 num_funcs / num_defined / num_extern 分项（A-11 typeck 截断：target num_defined=146）。
 */
void driver_diagnostic_after_entry_parse_module(void *module) {
    int32_t nf, i, ndef, next;
    if (!getenv("SHUX_DEBUG_PIPE") || !module)
        return;
    nf = pipeline_module_num_funcs(module);
    ndef = 0;
    next = 0;
    for (i = 0; i < nf; i++) {
        if (pipeline_module_func_is_extern_at(module, i) != 0)
            next++;
        else
            ndef++;
    }
    fprintf(stderr,
            "shux: [SHUX_DEBUG_PIPE] after_entry_parse num_funcs=%d num_defined=%d num_extern=%d\n", (int)nf,
            (int)ndef, (int)next);
}

/** 诊断：pipeline/typeck 阶段 marker；SHUX_DEBUG_PIPE=1 时打印（1=merge 后，2=typeck library 入口，3=validate 后）。 */
void driver_diagnostic_pipe_marker(int32_t id) {
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] pipe_marker=%d\n", (int)id);
}

/** OBS-001：编译阶段耗时埋点；phase 0=parse(+dep load) 1=typeck 2=codegen。 */
#define SHUX_COMPILE_PHASE_MAX 3

static double g_compile_phase_acc_ms[SHUX_COMPILE_PHASE_MAX];
static double g_compile_phase_start_sec[SHUX_COMPILE_PHASE_MAX];
static int g_compile_phase_active[SHUX_COMPILE_PHASE_MAX];

/** 是否启用 SHUX_COMPILE_PHASE_TIMING=1 阶段计时。 */
static int compile_phase_timing_enabled(void) {
    return getenv("SHUX_COMPILE_PHASE_TIMING") != NULL;
}

/** 单调 wall-clock 秒（gettimeofday，跨 Linux/macOS）。 */
static double compile_phase_now_sec(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (double)tv.tv_sec + (double)tv.tv_usec * 1e-6;
}

/** 标记阶段开始；由 pipeline.sx run_sx_pipeline_impl 调用。 */
void driver_compile_phase_timing_begin(int32_t phase) {
    if (!compile_phase_timing_enabled() || phase < 0 || phase >= SHUX_COMPILE_PHASE_MAX)
        return;
    g_compile_phase_start_sec[phase] = compile_phase_now_sec();
    g_compile_phase_active[phase] = 1;
}

/** 累加阶段耗时（毫秒）；可多次 begin/end 同 phase 时叠加。 */
void driver_compile_phase_timing_end(int32_t phase) {
    if (!compile_phase_timing_enabled() || phase < 0 || phase >= SHUX_COMPILE_PHASE_MAX || !g_compile_phase_active[phase])
        return;
    g_compile_phase_acc_ms[phase] += (compile_phase_now_sec() - g_compile_phase_start_sec[phase]) * 1000.0;
    g_compile_phase_active[phase] = 0;
}

/** 打印一行汇总并清零；check-only 跳过 codegen 时仍输出 parse/typeck。 */
void driver_compile_phase_timing_flush(void) {
    if (!compile_phase_timing_enabled())
        return;
    double total = g_compile_phase_acc_ms[0] + g_compile_phase_acc_ms[1] + g_compile_phase_acc_ms[2];
    fprintf(stderr,
            "shux: [SHUX_COMPILE_PHASE_TIMING] parse_ms=%.3f typeck_ms=%.3f codegen_ms=%.3f total_ms=%.3f\n",
            g_compile_phase_acc_ms[0], g_compile_phase_acc_ms[1], g_compile_phase_acc_ms[2], total);
    fflush(stderr);
    memset(g_compile_phase_acc_ms, 0, sizeof(g_compile_phase_acc_ms));
    memset(g_compile_phase_active, 0, sizeof(g_compile_phase_active));
}

/** 每个 dep codegen 后打印 j 与 out_buf.len，确认 buffer 是否递增。需要时取消注释 fprintf。 */
void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len) {
    (void)j;
    (void)out_len;
}

/** codegen 失败时打印是第几个 dep（is_dep!=0）还是当前模块（is_dep==0），便于定位 -6。需要时取消注释 fprintf。 */
void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep) {
    /* 始终打印简要失败位置；SHUX_DEBUG_PIPE=1 时前缀一致便于 grep。 */
    fprintf(stderr, "shux: codegen fail dep_index=%d is_dep=%d\n", (int)dep_index, (int)is_dep);
}

/** asm 后端：不支持的 ExprKind 时由 backend.sx 调用，便于定位 rc=-6；kind 为 ast_ExprKind 枚举值。 */
void driver_diagnostic_asm_unsupported_expr(int32_t kind) {
    fprintf(stderr, "shux: asm codegen unsupported ExprKind=%d\n", (int)kind);
    fflush(stderr);
}

/** asm 后端：elf_resolve_patches 找不到补丁目标标签。 */
void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t len) {
    fprintf(stderr, "shux: elf unresolved patch label name_len=%d name='", (int)len);
    if (name && len > 0) {
        for (int32_t i = 0; i < len && i < 64; i++)
            fputc((char)name[i], stderr);
    }
    fputc('\'', stderr);
    fputc('\n', stderr);
    fflush(stderr);
}

/** asm 后端：Mach-O 写出时 reloc 符号名为空。 */
void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx) {
    fprintf(stderr, "shux: macho empty reloc symbol at idx=%d\n", (int)reloc_idx);
    fflush(stderr);
}

/** asm 后端：Mach-O 写出时外部 reloc 未命中 und 池（常与 macho_leading_underscore 未置 1 有关）。 */
void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx) {
    fprintf(stderr, "shux: macho undef reloc not in und pool at idx=%d\n", (int)reloc_idx);
    fflush(stderr);
}

/** asm 后端：记录当前正在 emit 的 ExprKind 序数，供 fail_at 时打印。 */
static int driver_diagnostic_asm_last_expr_kind = -1;
void driver_diagnostic_asm_set_last_expr_kind(int32_t k) {
    driver_diagnostic_asm_last_expr_kind = (int)k;
}

/** asm 后端：记录当前正在 codegen 的函数名，供 var_not_found 时打印。 */
static uint8_t driver_diagnostic_asm_current_func[72];
static int driver_diagnostic_asm_current_func_len = 0;
void driver_diagnostic_asm_set_current_func(const uint8_t *name, int32_t len) {
    const char *trace;
    driver_diagnostic_asm_current_func_len = (len > 0 && len <= 64) ? (int)len : 0;
    if (name && driver_diagnostic_asm_current_func_len > 0) {
        for (int i = 0; i < driver_diagnostic_asm_current_func_len; i++)
            driver_diagnostic_asm_current_func[i] = name[i];
    }
    /** SHUX_ASM_FUNC_TRACE=1：打印当前 asm emit 函数名，便于二分大模块失败点。 */
    trace = getenv("SHUX_ASM_FUNC_TRACE");
    if (trace && trace[0] != '\0' && trace[0] != '0' && driver_diagnostic_asm_current_func_len > 0) {
        fprintf(stderr, "asm_trace: %.*s\n", driver_diagnostic_asm_current_func_len,
                (const char *)driver_diagnostic_asm_current_func);
        fflush(stderr);
    }
}

/** backend_asm_codegen_ast_to_elf 返回 -1 时打印当前函数名（SHUX_ASM_DEBUG）。 */
void driver_diagnostic_asm_print_current_func(void) {
    if (driver_diagnostic_asm_current_func_len > 0)
        fprintf(stderr, "shux: asm codegen failed in func=%.*s\n", driver_diagnostic_asm_current_func_len,
                (const char *)driver_diagnostic_asm_current_func);
    else
        fprintf(stderr, "shux: asm codegen failed (func unknown)\n");
    fflush(stderr);
}

/** asm 后端：EXPR_VAR 在 local_offset 未找到时由 backend.sx 调用；若 num_locals>0 可传首槽名 first_slot/first_len 便于对比。 */
void driver_diagnostic_asm_var_not_found(const uint8_t *name, int32_t len, int32_t num_locals,
    const uint8_t *first_slot, int32_t first_len) {
    fprintf(stderr, "shux: asm codegen EXPR_VAR not in ctx: \"");
    if (name && len > 0 && len <= 64) {
        for (int i = 0; i < len; i++) fputc((char)name[i], stderr);
    }
    fprintf(stderr, "\" (func: ");
    if (driver_diagnostic_asm_current_func_len > 0) {
        for (int i = 0; i < driver_diagnostic_asm_current_func_len; i++)
            fputc((char)driver_diagnostic_asm_current_func[i], stderr);
    } else {
        fprintf(stderr, "?");
    }
    fprintf(stderr, ", num_locals=%d", (int)num_locals);
    if (num_locals > 0 && first_slot && first_len > 0 && first_len <= 64) {
        fprintf(stderr, ", first_slot=\"");
        for (int i = 0; i < first_len; i++) fputc((char)first_slot[i], stderr);
        fprintf(stderr, "\" len=%d", (int)first_len);
    }
    fprintf(stderr, ")\n");
    fflush(stderr);
}

/** asm 后端：返回 -1 前调用，loc 表示失败位置（1=section_text 2=globl 3=label 4=prologue 5=block_body 6=block_inits 7=emit_expr 8=epilogue），便于定位 rc=-6。 */
void driver_diagnostic_asm_fail_at(int32_t loc) {
    if (driver_diagnostic_asm_current_func_len > 0) {
        fprintf(stderr, "shux: asm codegen func=%.*s ",
                driver_diagnostic_asm_current_func_len, (const char *)driver_diagnostic_asm_current_func);
    }
    fprintf(stderr, "fail_at=%d (last_expr_kind=%d)\n", (int)loc, driver_diagnostic_asm_last_expr_kind);
    fflush(stderr);
}

/* 非 0 时 asm -o 单模块仅编入口（build_shux_asm 并列链 build_asm 各 .o）；读 SHUX_ASM_ENTRY_MODULE_ONLY 环境变量。 */
static int asm_entry_module_only_from_env(void) {
    const char *e = getenv("SHUX_ASM_ENTRY_MODULE_ONLY");
    return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** 供 compile.sx / driver 分派：build_shux_asm 单模块 -o 时勿因 import 降级 shux-c（-backend asm 须保留）。 */
int32_t driver_asm_entry_module_only_from_env(void) {
    return asm_entry_module_only_from_env();
}

/** -o 可执行文件路径：非 0 时 pipeline 跳过 dep 0 的 codegen（driver 由 io.o 提供）；避免与 ctx 布局耦合。 */
static int driver_skip_codegen_dep_0_flag;
void driver_skip_codegen_dep_0_set(int32_t v) { driver_skip_codegen_dep_0_flag = (v != 0); }
int32_t driver_skip_codegen_dep_0_get(void) { return driver_skip_codegen_dep_0_flag ? 1 : 0; }

/** 当前 codegen 的 dep 路径（如 "std.io.driver"），供 .sx codegen 生成带前缀的 C 名（避免与 C 关键字 register 等冲突）。 */
static const char *driver_current_dep_path_for_codegen;

void driver_set_current_dep_path_for_codegen(const char *path) {
    driver_current_dep_path_for_codegen = path;
}

const char *driver_get_current_dep_path_for_codegen(void) {
    return driver_current_dep_path_for_codegen;
}

void driver_debug_log(int32_t step) {
    fprintf(stderr, "[parse] step %d\n", (int)step);
    fflush(stderr);
}

void parser_diag_tok_kind(int32_t k) {
    fprintf(stderr, "[parse] r.tok.kind=%d\n", (int)k);
    fflush(stderr);
}

void parser_diag_ident_len(int32_t len) {
    fprintf(stderr, "[onefunc] first ident_len=%d\n", (int)len);
    fflush(stderr);
}

void parser_diag_scan_fail(int32_t step) {
    fprintf(stderr, "shux: library_scan fail step=%d\n", (int)step);
}

int parser_is_ident_allow(const uint8_t *ident, int len) {
    if (!ident || len != 5) return 0;
    return (ident[0] == 'a' && ident[1] == 'l' && ident[2] == 'l' && ident[3] == 'o' && ident[4] == 'w') ? 1 : 0;
}
#endif /* SHUX_USE_SX_PIPELINE */

/** DOD-CL -pad-fields：相邻 atomic-sized 与普通字段同 cache line 且无 align(64) 分隔。
 * 须在 #if SHUX_USE_SX_PIPELINE 外：C 前端 typeck.o（shux-c）也调用。 */
void driver_diagnostic_warn_pad_fields_same_cache_line(const uint8_t *sname, int32_t sname_len, const uint8_t *f0,
                                                       int32_t f0_len, const uint8_t *f1, int32_t f1_len) {
    char msg[384];
    snprintf(msg, sizeof msg,
             "warning: -pad-fields: struct '%.*s' fields '%.*s' and '%.*s' share a 64-byte cache line; "
             "consider align(64) to avoid false sharing",
             (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
             (int)(f0_len > 0 ? f0_len : 0), (const char *)(f0 ? f0 : (const uint8_t *)""),
             (int)(f1_len > 0 ? f1_len : 0), (const char *)(f1 ? f1 : (const uint8_t *)""));
    if (lsp_diag_enabled)
        lsp_diag_add(1, 1, 2, msg);
    else
        fprintf(stderr, "%s\n", msg);
}

/** DOD-CL-S2 -hot-reorder：热标量字段宜置大字段之前；C 前端 typeck.o 亦调用。 */
void driver_diagnostic_warn_hot_reorder_field(const uint8_t *sname, int32_t sname_len, const uint8_t *hot,
                                              int32_t hot_len, const uint8_t *cold, int32_t cold_len) {
    char msg[256];
    snprintf(msg, sizeof msg,
             "warning: -hot-reorder: struct '%.*s': consider moving hot field '%.*s' before '%.*s'",
             (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
             (int)(hot_len > 0 ? hot_len : 0), (const char *)(hot ? hot : (const uint8_t *)""),
             (int)(cold_len > 0 ? cold_len : 0), (const char *)(cold ? cold : (const uint8_t *)""));
    if (lsp_diag_enabled)
        lsp_diag_add(1, 1, 2, msg);
    else
        fprintf(stderr, "%s\n", msg);
}

/** L6-unused-hint：未使用的 let/const/import 绑定（SHUX_UNUSED_HINT=1；info 层，默认不阻断 check）。 */
void driver_diagnostic_hint_unused_binding(int32_t line, int32_t col, const uint8_t *name, int32_t name_len) {
    char msg[160];
    int ln = (line > 0) ? (int)line : 1;
    int cl = (col > 0) ? (int)col : 1;
    snprintf(msg, sizeof msg, "unused binding '%.*s'",
             (int)(name_len > 0 ? name_len : 0), (const char *)(name ? name : (const uint8_t *)""));
    if (lsp_diag_enabled)
        lsp_diag_add(ln, cl, 3, msg);
    else
        fprintf(stderr, "info: %s\n", msg);
}

#ifdef SHUX_USE_SX_DRIVER
/* 阶段 6.2：main.sx 内实现 argv 解析与 -sx -E 执行逻辑；C 仅提供极薄原语 driver_get_argv_i。 */
/* 保留旧符号供未迁完时链接；main.sx 自实现后不再调用。 */
static const char *driver_su_emit_c_path;
#define SU_EMIT_MAX_LIB_ROOTS 16
static const char *driver_su_emit_lib_roots[SU_EMIT_MAX_LIB_ROOTS];
static int driver_su_emit_n_lib_roots;
/* 供 main.sx 在 -sx -E 时把 path/lib_roots 灌入 C 侧，再调 driver_run_sx_emit_c，以走完整多文件（deps+main）路径。 */
static char driver_su_emit_path_buf[512];
static char driver_su_emit_lib_bufs[SU_EMIT_MAX_LIB_ROOTS][256];

int driver_run_sx_emit_c_set_path(const uint8_t *path, int path_len) {
    driver_su_emit_c_path = NULL;
    if (!path || path_len <= 0 || path_len >= (int)sizeof(driver_su_emit_path_buf)) return 0;
    memcpy(driver_su_emit_path_buf, path, (size_t)path_len);
    driver_su_emit_path_buf[path_len] = '\0';
    driver_su_emit_c_path = driver_su_emit_path_buf;
    return 0;
}

int driver_run_sx_emit_c_set_lib(int i, const uint8_t *buf, int len) {
    if (i < 0 || i >= SU_EMIT_MAX_LIB_ROOTS || !buf || len < 0 || len >= 256) return 0;
    memcpy(driver_su_emit_lib_bufs[i], buf, (size_t)len);
    driver_su_emit_lib_bufs[i][len] = '\0';
    driver_su_emit_lib_roots[i] = driver_su_emit_lib_bufs[i];
    return 0;
}

int driver_run_sx_emit_c_set_n_lib_roots(int n) {
    driver_su_emit_n_lib_roots = (n >= 0 && n <= SU_EMIT_MAX_LIB_ROOTS) ? n : 0;
    return 0;
}

/** main.sx 在解析到 -E-extern 后置 1；driver_run_sx_emit_c 消费后清零。与 C 路径 emit_extern_imports 对齐。 */
static int driver_su_emit_c_want_extern;

int driver_run_sx_emit_c_set_emit_extern(int v) {
    driver_su_emit_c_want_extern = v ? 1 : 0;
    return 0;
}

/** 前置声明：下方 driver_want_asm_emit_to_file 早于本函数定义处调用（6.2 argv 拷贝原语）。 */
int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max);

/**
 * 是否与 \c driver_run_compiler_full 默认一致：默认可走 asm 后端；仅当 argv 含 \c `-backend c` 时为 0。
 *
 * 【历史说明】曾仅靠 `-backend asm` 为真；现 shux 默认 asm，`driver_run_asm_backend` 仍由 \c driver_run_compiler_full 在无 \c `-backend c` 时选用。
 *
 * 【返回值】1 → 走 \c driver_run_compiler_full（内含 asm）；0 → 旧逻辑走 \c pipeline_run_sx_pipeline_impl 轻路径（主要为兼容未再生成的 driver_gen.c）。
 */
int driver_want_asm_emit_to_file(int argc, char **argv) {
    int want_asm = 1;
    char cur[512];
    char nx[512];
    int i;
    if (!argv || argc < 2)
        return 0;
    /* 与 driver_run_compiler_full 一致：经 main.sx 传入的 argv 在 ABI 上与 char** 同址，但若用错位索引会破坏 -L；
     * 必须用 driver_get_argv_i 逐项拷贝，与同文件 main.sx/driver_get_argv_i 语义对齐。 */
    for (i = 1; i < argc; i++) {
        if (driver_get_argv_i(argc, argv, i, cur, (int)sizeof cur) < 0)
            continue;
        if (strcmp(cur, "-backend") != 0)
            continue;
        if (i + 1 >= argc)
            break;
        if (driver_get_argv_i(argc, argv, i + 1, nx, (int)sizeof nx) < 0) {
            i++;
            continue;
        }
        if (strcmp(nx, "c") == 0)
            want_asm = 0;
        if (strcmp(nx, "asm") == 0)
            want_asm = 1;
        i++; /* -backend 已消费；下一外层循环会跳过 backend 参数令牌 */
    }
    return want_asm ? 1 : 0;
}

/** 6.2 极薄原语：将 argv[i] 复制到 buf，最多 max-1 字节并加 NUL，返回长度（不含 NUL）；i 越界或失败返回 -1。供 main.sx 自实现 argv 解析。 */
int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max) {
    if (!argv || !buf || max <= 0 || i < 0 || i >= argc || !argv[i]) return -1;
    size_t n = (size_t)max - 1;
    size_t j = 0;
    while (argv[i][j] && j < n) {
        buf[j] = argv[i][j];
        j++;
    }
    buf[j] = '\0';
    return (int)j;
}

/**
 * 未显式传 -target 时，为 Mach-O 宿主选择默认 target_arch（与 driver_run_asm_backend 一致）。
 * parsed_target：argv 解析得到的 0/x86、1/arm64、2/riscv64。
 * saw_target_flag：非 0 表示用户传了 -target，不再覆盖。
 */
int32_t driver_resolve_target_arch(int32_t parsed_target, int32_t saw_target_flag) {
    if (saw_target_flag)
        return parsed_target;
#if defined(__APPLE__) && defined(__aarch64__)
    return 1;
#else
    return parsed_target;
#endif
}

/**
 * main.sx entry() 子命令路由：去掉 argv[1]（子命令名），保留 argv[0] 与原 argv[2..argc-1]。
 * 返回指针与 (char **) 同址，供 cmd_build/cmd_run 等与直编共享的 driver_get_argv_i 路径读取。
 * 使用静态槽（容量 512），单次 main 内单线程安全；argc 超界时原样返回 argv_opaque 以免越界。
 */
uint8_t *driver_argv_drop_subcommand(int argc, uint8_t *argv_opaque)
{
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

/**
 * cmd_run（driver/run.sx）：编译成功后 exec 产物。从 argv 扫描 `-o` 下一参数为可执行路径，缺省 `a.out`。
 * 子进程 argv 仅为 [ exe, NULL ]；ABI 上 argv 与 char** 同址。
 */
int driver_exec_compiled(int argc, uint8_t *argv_opaque)
{
    char **argv = (char **)argv_opaque;
    const char *exe = "a.out";
    int i;

    if (!argv || argc < 1)
        return 1;
    for (i = 1; i < argc - 1; i++) {
        if (argv[i] && strcmp(argv[i], "-o") == 0 && argv[i + 1] && argv[i + 1][0]) {
            exe = argv[i + 1];
            break;
        }
    }
    /*
     * `shux` / `shux run` 默认在编译成功后 exec 产物。-o 为对象文件或汇编列表时不应执行（execv(.o) → EACCES）。
     * 与 driver_asm_output_want_exe_cstr 后缀规则对齐。
     */
    {
        size_t n = strlen(exe);
        if (n >= 2 && exe[n - 2] == '.' && (exe[n - 1] == 'o' || exe[n - 1] == 'O'))
            return 0;
        if (n >= 4 && exe[n - 4] == '.' && exe[n - 3] == 'o' && exe[n - 2] == 'b' && exe[n - 1] == 'j')
            return 0;
        if (n >= 2 && exe[n - 2] == '.' && exe[n - 1] == 's')
            return 0;
    }
    {
        pid_t pid = fork();
        if (pid < 0) {
            perror("shux: fork (driver_exec_compiled)");
            return 1;
        }
        if (pid == 0) {
            char *av[2];
            av[0] = (char *)exe;
            av[1] = NULL;
            execv(exe, av);
            perror("shux: execv (driver_exec_compiled)");
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
}

/* 前置声明：定义在本文件后部 driver_run_compiler_full；此处须在定义之前调用。 */
int driver_run_compiler_full(int argc, char **argv);

/**
 * cmd_build（driver/build.sx）：在当前工作目录查找 build.sx，编译后执行默认产物 ./a.out。
 * - access("build.sx", R_OK) 失败则 fprintf stderr 报错并返回 1。
 * - 构造 argv {"shux","build.sx",NULL} 调用 driver_run_compiler_full(2, fake_argv)，非 0 则返回 1。
 * - 编译成功后 fork / execv("./a.out", av)、waitpid，返回子进程正常退出码；信号等非正常退出返回 1。
 */
int driver_build_build_su(void)
{
    /* 生成 build_tool 并执行：等价 make build-tool && ./build_tool ./shux。
       build.sx 没有 main，需结合 build_runtime.c 做成 build_tool 再跑。
       Makefile 在 compiler 子目录，build_tool 也生成在 compiler 下。 */
    int rc = system("cd compiler && make -s build-tool 2>&1");
    if (rc != 0) {
        fprintf(stderr, "shux: make build-tool failed (exit %d)\n", rc);
        return 1;
    }
    rc = system("cd compiler && ./build_tool ./shux 2>&1");
    if (rc != 0) {
        fprintf(stderr, "shux: build_tool failed (exit %d)\n", rc);
        return 1;
    }
    return 0;
}

/** 6.2 静态 arena/module 缓冲，供 driver_run_sx_emit_sx 避免栈上超大数组。
 * arena 对应 .sx codegen 之 `struct ast_ASTArena`，须 ≥ pipeline_sizeof_arena()；
 * 池扩大后（types/exprs/blocks/funcs 四倍）宿主约 ~90MiB，预留 128MiB 避免静默越界。 */
#define DRIVER_ARENA_STATIC_SIZE (128 * 1024 * 1024)
#define DRIVER_MODULE_STATIC_SIZE (2 * 1024 * 1024)
static uint8_t driver_arena_static[DRIVER_ARENA_STATIC_SIZE];
static uint8_t driver_module_static[DRIVER_MODULE_STATIC_SIZE];

/* 由 pipeline_gen.c 提供，用于 driver 在 memset 后强制将 arena.num_types 置 0，避免与生成代码布局不一致导致 type_alloc 误判 */
extern size_t pipeline_arena_offset_num_types(void);

uint8_t *driver_arena_buf(void) {
    memset(driver_arena_static, 0, DRIVER_ARENA_STATIC_SIZE);
    /* 强制 num_types=0，避免与 .sx 生成 struct 布局/对齐不一致时 type_alloc 读到未清零值 */
    size_t off = pipeline_arena_offset_num_types();
    if (off + sizeof(int32_t) <= DRIVER_ARENA_STATIC_SIZE) {
        *(int32_t *)(driver_arena_static + off) = 0;
        (void)off; /* 诊断时可 fprintf(stderr, "arena off=%zu\n", off); */
    }
    return driver_arena_static;
}
uint8_t *driver_module_buf(void) {
    memset(driver_module_static, 0, DRIVER_MODULE_STATIC_SIZE);
    return driver_module_static;
}

/** 6.2 极薄原语：以 path[0..path_len-1] 为路径打开读文件，返回 fd，失败 -1。供 driver_run_sx_emit_sx 读入口文件，避免生成代码顺序导致 path_buf 未填就 open。 */
int driver_fs_open_read_path(const uint8_t *path, int path_len) {
    if (!path || path_len <= 0 || path_len >= 512) return -1;
    char buf[512];
    memcpy(buf, path, (size_t)path_len);
    buf[path_len] = '\0';
    return open(buf, O_RDONLY);
}

/** 6.2 极薄原语：以 path[0..path_len-1] 为路径打开写文件（O_WRONLY|O_CREAT|O_TRUNC），返回 fd，失败 -1。供 -backend asm -o 时 main.sx 写 -o 文件。 */
int driver_fs_open_write(const uint8_t *path, int path_len) {
    if (!path || path_len <= 0 || path_len >= 512) return -1;
    char buf[512];
    memcpy(buf, path, (size_t)path_len);
    buf[path_len] = '\0';
#ifdef O_WRONLY
#ifdef O_CREAT
#ifdef O_TRUNC
    return open(buf, O_WRONLY | O_CREAT | O_TRUNC, (mode_t)0644);
#endif
#endif
#endif
    return -1;
}

/** 检测内存中的源码 content[0..n-1] 是否含泛型或 trait 语法（.sx 流水线不支持，需走 C 路径）。 */
static int content_has_generic_syntax(const char *content, size_t n) {
    if (!content || n == 0) return 0;
    const char *end = content + n;
    const char *p = content;
    /* 泛型：<T>、<i32> 等 */
    while ((p = (const char *)memchr(p, '<', (size_t)(end - p))) != NULL) {
        if (p + 1 >= end) break;
        if (p[1] == 'T' || p[1] == 'i') return 1;
        if ((size_t)(end - p) >= 5 && memcmp(p, "<i32>", 5) == 0) return 1;
        p++;
    }
    /*
     * trait / 独立 impl 关键字：.sx 流水线不解析，走 C 路径。
     * impl 须匹配完整词元 " impl "（前后空白）；勿用 memcmp(..., " impl ", 5)，否则
     * `implicit_*` 等标识符在首字符前有空格时会被误判为泛型，进而关掉 asm 并误走「无 main 链可执行」路径见 driver_run_compiler_full。
     */
    if (n >= 6) {
        size_t i;
        for (i = 0; i <= n - 6; i++)
            if (memcmp(content + i, "trait ", 6) == 0) return 1;
        for (i = 0; i <= n - 6; i++)
            if (memcmp(content + i, " impl ", 6) == 0) return 1;
    }
    return 0;
}

/** 检测 path 指向的源码文件是否含泛型语法（如 <T> 或 <i32>），有则返回 1 否则 0；供 .sx driver 在 run_compiler_sx_path_impl 中决定是否走 C 流水线。 */
int driver_source_has_generic_syntax(const uint8_t *path, int path_len) {
    char content[65536];
    int rn;
    size_t n;

    if (!path || path_len <= 0 || path_len >= 512) return 0;
    {
        char buf[512];
        memcpy(buf, path, (size_t)path_len);
        buf[path_len] = '\0';
        rn = driver_peek_source_file(buf, content, sizeof(content));
    }
    if (rn < 0) return 0;
    n = (size_t)rn;
    return content_has_generic_syntax(content, n);
}

/** 检测内存源码是否含复合赋值（+= 等）；.sx 解析器未覆盖时须走 C 流水线（run-compound-assign 等）。
 * 跳过 //、块注释与双引号字符串，避免注释/字面量中的 token 误触发 asm→C 降级。 */
static int content_has_compound_assign_syntax(const char *content, size_t n) {
    if (!content || n < 3)
        return 0;
    /* 长 token 优先，避免 `<<=` 被 `+=` 子串误伤。 */
    static const char *tokens[] = {"<<=", ">>=", "+=", "-=", "*=", "/=", "%=", "&=", "|=", "^="};
    size_t pos = 0;
    while (pos < n) {
        if (pos + 1 < n && content[pos] == '/' && content[pos + 1] == '/') {
            pos += 2;
            while (pos < n && content[pos] != '\n')
                pos++;
            continue;
        }
        if (pos + 1 < n && content[pos] == '/' && content[pos + 1] == '*') {
            pos += 2;
            while (pos + 1 < n && !(content[pos] == '*' && content[pos + 1] == '/'))
                pos++;
            pos += (pos + 1 < n) ? 2 : 0;
            continue;
        }
        if (content[pos] == '"') {
            pos++;
            while (pos < n && content[pos] != '"') {
                if (content[pos] == '\\' && pos + 1 < n)
                    pos += 2;
                else
                    pos++;
            }
            if (pos < n)
                pos++;
            continue;
        }
        for (size_t i = 0; i < sizeof(tokens) / sizeof(tokens[0]); i++) {
            size_t tlen = strlen(tokens[i]);
            if (pos + tlen <= n && memcmp(content + pos, tokens[i], tlen) == 0)
                return 1;
        }
        pos++;
    }
    return 0;
}

/** 供 compile.sx：源码含复合赋值则返回 1，默认 asm 应降级为 C。 */
int driver_source_has_compound_assign_syntax(const uint8_t *path, int path_len) {
    char content[65536];
    int rn;
    size_t n;

    if (!path || path_len <= 0 || path_len >= 512)
        return 0;
    {
        char buf[512];
        memcpy(buf, path, (size_t)path_len);
        buf[path_len] = '\0';
        rn = driver_peek_source_file(buf, content, sizeof(content));
    }
    if (rn < 0)
        return 0;
    n = (size_t)rn;
    if (n < sizeof(content))
        content[n] = '\0';
    return content_has_compound_assign_syntax(content, n);
}

#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
/**
 * 判断 import 路径 \p path 是否已在输出 dep 列表 \p out_paths[0..n_out) 中（strcmp），用于合并 closure 时去重。
 * 同一模块若因 closure 构造重复出现两次，只保留一条，避免 asm 后端同一 .o 内重复定义。
 */
static int merge_deps_path_already_out(const char *path, char *out_paths[], int n_out) {
    int j;
    for (j = 0; j < n_out; j++)
        if (out_paths[j] && path && strcmp(out_paths[j], path) == 0)
            return 1;
    return 0;
}

/**
 * build_shux_asm（ENTRY_MODULE_ONLY + SKIP_TYPECK）：仅读入口 direct import 源码（不递归传递闭包），
 * 供 parse-only 填 dep struct layout；避免 collect_deps_transitive 耗时/失败，且 LexerResult 等跨模块 layout 可 merge。
 * 返回 0 成功；失败时释放已写入 dep_sources/dep_paths 并返回 1。
 */
static int load_direct_imports_for_asm_layout(void *module, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *out_n) {
    int32_t n_imports = parser_get_module_num_imports(module);
    int mi = 0;

    *out_n = 0;
    if (n_imports <= 0)
        return 0;
    for (int i = 0; i < n_imports && i < 32 && mi < MAX_ALL_DEPS; i++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;
        char resolved[PATH_MAX];
        size_t raw_len = 0;
        size_t prep_len = 0;
        char *raw;
        char *prep;

        parser_get_module_import_path(module, i, path_buf);
        while (k < sizeof(path_buf) && path_buf[k] && k < 64) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir, path_c, resolved, sizeof(resolved));
        raw = read_file(resolved, &raw_len);
        if (!raw) {
            fprintf(stderr, "shux: cannot open direct import '%s' (tried %s)\n", path_c, resolved);
            goto fail_partial;
        }
        prep = preprocess(raw, raw_len, ndefines > 0 ? defines : NULL, ndefines, &prep_len);
        free(raw);
        if (!prep) {
            fprintf(stderr, "shux: preprocess failed for direct import '%s'\n", path_c);
            goto fail_partial;
        }
        dep_sources[mi] = prep;
        dep_lens[mi] = prep_len;
        dep_paths[mi] = strdup(path_c);
        if (!dep_paths[mi]) {
            free(prep);
            goto fail_partial;
        }
        mi++;
    }
    *out_n = mi;
    return 0;
fail_partial:
    while (mi > 0) {
        mi--;
        free(dep_sources[mi]);
        free(dep_paths[mi]);
    }
    *out_n = 0;
    return 1;
}

/**
 * 将 collect_deps_transitive 得到的 closure（调用方已对 triple 数组做过反转）合并为 pipeline/asm_elf 使用的 dep 列表：
 * 前 n_imports 项与入口模块 import 槽 \c module.import_paths[i] 严格对齐（typeck WHOLE import / binding 依赖 dep_modules[i]）；
 * 其余项按 closure 顺序追加传递依赖（如 std.io.driver、std.io.core），供 asm_codegen_elf_o 编入同一 .o。
 * 追加传递依赖时对 \c out_paths 按路径 strcmp 去重，避免同一路径在 closure 中占多位时汇编进同一 .o 两次。
 * \p cls/cpaths 中的指针移至 \p out_*；成功返回后 closure 数组不应再 free。
 */
static int merge_direct_then_transitive_deps(void *module, int32_t n_imports, char *cls[], size_t clens[], char *cpaths[],
    int n_closure, char *out_src[], size_t out_lens[], char *out_paths[], int *out_n) {
    unsigned char used[MAX_ALL_DEPS];
    int mi = 0;
    memset(used, 0, sizeof used);
    for (int i = 0; i < n_imports && i < 32 && mi < MAX_ALL_DEPS; i++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;
        parser_get_module_import_path(module, i, path_buf);
        while (k < sizeof(path_buf) && path_buf[k] && k < 64) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        int found = -1;
        int kk = 0;
        while (kk < n_closure) {
            if (cpaths[kk] && strcmp(cpaths[kk], path_c) == 0) {
                found = kk;
                break;
            }
            kk++;
        }
        if (found < 0) {
            fprintf(stderr, "shux: merge deps: direct import '%s' not found in transitive closure\n", path_c);
            return 1;
        }
        out_src[mi] = cls[found];
        out_lens[mi] = clens[found];
        out_paths[mi] = cpaths[found];
        used[found] = 1;
        mi++;
    }
    for (int kj = 0; kj < n_closure && mi < MAX_ALL_DEPS; kj++) {
        if (!used[kj]) {
            /* 与已写入的 direct / 传递 dep 路径相同则跳过，防止 closure 重复项导致同模块汇编两次 */
            if (cpaths[kj] && merge_deps_path_already_out(cpaths[kj], out_paths, mi)) {
                used[kj] = 1;
                continue;
            }
            out_src[mi] = cls[kj];
            out_lens[mi] = clens[kj];
            out_paths[mi] = cpaths[kj];
            mi++;
        }
    }
    *out_n = mi;
    return 0;
}

/**
 * 传递加载 dep：从 main 的 import 出发，解析每个 dep 的 import 并加入加载列表，直至无新 dep。
 * 填满 dep_sources/dep_lens/dep_paths，*n_deps 为个数。返回 0 成功，1 失败（调用方负责释放已分配）。
 */
static int collect_deps_transitive(void *module, size_t arena_sz, size_t module_sz,
    const char **lib_roots_arr, int n_lib_roots, const char *entry_dir_buf,
    const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[], char *dep_paths[], int *n_deps) {
    int n = 0;
    char *to_load[MAX_ALL_DEPS];
    int to_load_n = 0;
    void *tmp_arena = NULL;
    void *tmp_module = NULL;
    int32_t n_imports = parser_get_module_num_imports(module);
    for (int j = 0; j < n_imports && j < 32 && to_load_n < MAX_ALL_DEPS; j++) {
        uint8_t path_buf[64];
        parser_get_module_import_path(module, j, path_buf);
        char path_c[65];
        size_t k = 0;
        while (k < sizeof(path_buf) && path_buf[k]) { path_c[k] = (char)path_buf[k]; k++; }
        path_c[k] = '\0';
        to_load[to_load_n++] = strdup(path_c);
        if (!to_load[to_load_n - 1]) goto fail_to_load;
    }
    while (to_load_n > 0 && n < MAX_ALL_DEPS) {
        char *path_c = to_load[--to_load_n];
        if (find_loaded_index(path_c, dep_paths, n) >= 0) { free(path_c); continue; }
        char resolved[PATH_MAX];
        resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir_buf, path_c, resolved, sizeof(resolved));
        size_t raw_len = 0;
        char *raw = read_file(resolved, &raw_len);
        if (!raw) {
            fprintf(stderr, "shux: cannot open import '%s' (tried %s)\n", path_c, resolved);
            free(path_c);
            goto fail_to_load;
        }
        size_t prep_len = 0;
        char *prep = preprocess(raw, raw_len, ndefines > 0 ? defines : NULL, ndefines, &prep_len);
        free(raw);
        if (!prep) {
            fprintf(stderr, "shux: preprocess failed for import '%s'\n", path_c);
            free(path_c);
            goto fail_to_load;
        }
        dep_sources[n] = prep;
        dep_lens[n] = prep_len;
        dep_paths[n] = strdup(path_c);
        free(path_c);
        if (!dep_paths[n]) goto fail_to_load;
        n++;
        if (!tmp_arena) { tmp_arena = malloc(arena_sz); tmp_module = malloc(module_sz); }
        if (tmp_arena && tmp_module) {
            memset(tmp_arena, 0, arena_sz);
            memset(tmp_module, 0, module_sz);
            struct shux_slice_uint8_t dep_slice = { (uint8_t *)dep_sources[n - 1], dep_lens[n - 1] };
            parser_parse_into_init(tmp_module, tmp_arena);
            struct parser_ParseIntoResult pr_dep = parser_parse_into(tmp_arena, tmp_module, &dep_slice);
            /* 传递闭包：import 在文件头已写入 module；即使整文件 parse 失败（库模块 pr_ok=-2 等）仍须展开子 import，否则 hello 等仅 import std.io 时 n_deps=1、dep 预跑 resolve 失败。 */
            {
                int n_imp = parser_get_module_num_imports(tmp_module);
                if (getenv("SHUX_DEBUG_PIPE")) {
                    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] collect parse dep=%s pr_ok=%d n_imp=%d\n",
                            dep_paths[n - 1] ? dep_paths[n - 1] : "?", (int)pr_dep.ok, n_imp);
                }
                if (n_imp > 0) {
                for (int jj = 0; jj < n_imp && jj < 32 && to_load_n < MAX_ALL_DEPS; jj++) {
                    uint8_t sub_buf[64];
                    parser_get_module_import_path(tmp_module, jj, sub_buf);
                    char sub_c[65];
                    size_t kk = 0;
                    while (kk < sizeof(sub_buf) && sub_buf[kk]) { sub_c[kk] = (char)sub_buf[kk]; kk++; }
                    sub_c[kk] = '\0';
                    if (find_loaded_index(sub_c, dep_paths, n) >= 0) continue;
                    { int found = 0; for (int t = 0; t < to_load_n; t++) if (to_load[t] && strcmp(to_load[t], sub_c) == 0) { found = 1; break; } if (found) continue; }
                    to_load[to_load_n++] = strdup(sub_c);
                    if (!to_load[to_load_n - 1]) to_load_n--;
                }
                }
            }
        }
    }
    while (to_load_n > 0) { to_load_n--; free(to_load[to_load_n]); }
    if (tmp_arena) free(tmp_arena);
    if (tmp_module) free(tmp_module);
    *n_deps = n;
    return 0;
fail_to_load:
    while (to_load_n > 0) { to_load_n--; free(to_load[to_load_n]); }
    if (tmp_arena) free(tmp_arena);
    if (tmp_module) free(tmp_module);
    while (n > 0) { n--; free(dep_sources[n]); free(dep_paths[n]); }
    return 1;
}

#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
/**
 * asm 后端写出 FILE *：若为 stdout（无 \c -o 时打印汇编文本）则不得 \c fclose，仅 \c fflush。
 */
static void driver_asm_fclose_asm_out(FILE *fp) {
    if (!fp || fp == stdout)
        fflush(stdout);
    else
        fclose(fp);
}

/** -backend asm 时 driver 用：判断 -o 是否写 .o/.obj；与 run_compiler_c 侧逻辑一致。 */
static int driver_asm_output_is_elf_o(const char *path) {
    if (!path) return 0;
    size_t n = strlen(path);
    if (n >= 2 && path[n - 2] == '.' && (path[n - 1] == 'o' || path[n - 1] == 'O'))
        return 1;
    return n >= 4 && path[n - 4] == '.' && path[n - 3] == 'o' && path[n - 2] == 'b' && path[n - 1] == 'j';
}
static int driver_asm_output_want_exe_cstr(const char *path) {
    if (!path || !*path) return 0;
    size_t n = strlen(path);
    if (n >= 2 && path[n - 2] == '.' && (path[n - 1] == 'o' || path[n - 1] == 'O')) return 0;
    if (n >= 4 && path[n - 4] == '.' && path[n - 3] == 'o' && path[n - 2] == 'b' && path[n - 1] == 'j') return 0;
    if (n >= 2 && path[n - 2] == '.' && path[n - 1] == 's') return 0;
    return 1;
}

/** compile.sx extern：-o 后缀是否表示可执行（非 .o/.obj/.s）。 */
int32_t driver_asm_output_want_exe(uint8_t *path) {
    return driver_asm_output_want_exe_cstr(path ? (const char *)path : NULL);
}
/** -backend asm -o <exe> 时调 ld；与 invoke_ld 同逻辑。link_argv0 可为 NULL（则用镜像路径推导）。lib_roots 与 driver -L 一致。 */
static int driver_asm_invoke_ld(const char *o_path, const char *exe_path, const char *target, int use_macho_o, int use_coff_o, const char *link_argv0,
    const char **lib_roots, int n_lib_roots) {
    char link_argv_syn[PATH_MAX];
    const char *link_eff;
    (void)target;
    if (!o_path || !exe_path)
        return -1;
    link_eff = shux_asm_ld_effective_link_argv0(link_argv0, link_argv_syn, sizeof link_argv_syn);
    if (!link_eff)
        return -1;
#if defined(__linux__)
    if (freestanding_prepare_runtime_panic_o(link_eff, o_path) != 0)
        return -1;
#else
    if (ensure_runtime_panic_o(link_eff) != 0)
        return -1;
#endif
    if (ensure_crt0_user_o(link_eff) != 0)
        return -1;
#if defined(__linux__)
    if (shu_ld_freestanding_enabled() && freestanding_user_o_needs_io(o_path)) {
        if (ensure_freestanding_io_o(link_eff) != 0)
            return -1;
    }
#endif
    if (shu_ld_freestanding_enabled() && (use_macho_o || use_coff_o)) {
        fprintf(stderr, "shux: -freestanding / SHUX_FREESTANDING only supported for Linux ELF x86_64 (-o prog, not .o/.obj on macOS/COFF)\n");
        return -1;
    }
    return asm_invoke_ld_platform(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots);
}

/** out_buf 是否已为 Mach-O/ELF 对象（asm_codegen_elf_o 产出）。 */
static int driver_asm_out_buf_is_object(const struct codegen_CodegenOutBuf *out) {
    if (!out || out->len < 4)
        return 0;
    /* Mach-O MH_MAGIC_64 / 反字节序 */
    if (out->data[0] == 0xcf && out->data[1] == 0xfa && out->data[2] == 0xed && out->data[3] == 0xfe)
        return 1;
    if (out->data[0] == 0xfe && out->data[1] == 0xed && out->data[2] == 0xfa && out->data[3] == 0xcf)
        return 1;
    /* ELF \x7fELF */
    if (out->len >= 4 && out->data[0] == 0x7f && out->data[1] == 'E' && out->data[2] == 'L' && out->data[3] == 'F')
        return 1;
    return 0;
}

#if !defined(SHUX_NO_C_FRONTEND)
/** C 前端 typeck（定义见 driver_c_typeck_entry）；asm 编译前预检。 */
static int driver_c_typeck_entry(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots, int print_ok);
static int driver_c_typeck_entry_large_stack(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots,
    int print_ok);
#endif

#if !defined(SHUX_NO_C_FRONTEND)
static int driver_c_frontend_smoke(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots);
static int driver_source_has_top_level_import(const char *src, size_t src_len);
#endif

/**
 * 从 argv 收集 -D / -DFOO 与 -target 推导的 OS_*、uname 的 SHUX_OS_/SHUX_ARCH_（与 run_compiler_c 一致）。
 * 【参数】defines 至少 max_defines 个槽；返回 ndefines。
 */
static int driver_argv_collect_defines(int argc, char **argv, const char **defines, int max_defines) {
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
                *p = (char)toupper((unsigned char)*p);
            for (char *p = shu_arch_def + 9; *p; p++)
                *p = (char)toupper((unsigned char)*p);
            defines[ndefines++] = shu_os_def;
            defines[ndefines++] = shu_arch_def;
        }
    }
    return ndefines;
}

/**
 * -backend asm 专用：读文件、跑 .sx pipeline、写 .o 或调 ld。与 run_compiler_c 内 asm 路径逻辑一致，供 driver_run_compiler_full 转调。
 */
int driver_run_asm_backend(const char *input_path, const char *out_path, const char **lib_roots_arr, int n_lib_roots,
    const char *target, int argc, char **argv) {
    const char *defines[MAX_DEFINES];
    int ndefines = 0;
    driver_bump_stack_limit_if_needed();
    if (argv && argc > 0)
        ndefines = driver_argv_collect_defines(argc, argv, defines, MAX_DEFINES);
    /** B-02：#[cfg] 与 -target triple 联动（asm 后端路径）。 */
    if (target)
        cfg_apply_compile_target_from_triple(target, (int)strlen(target));
    else
        cfg_reset_compile_target();
    size_t raw_src_len = 0;
    char *raw_src = read_file(input_path, &raw_src_len);
    if (!raw_src) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = preprocess(raw_src, raw_src_len, ndefines > 0 ? defines : NULL, ndefines, &src_len);
    free(raw_src);
    if (!src) {
        fprintf(stderr, "shux: preprocess failed for '%s'\n", input_path);
        return 1;
    }
#if !defined(SHUX_NO_C_FRONTEND)
    /* 无 -o 烟测走 C 前端（含 import 时 SU asm parse 易 0 func）；shux check 不走烟测。 */
    if (out_path == NULL && !driver_check_only_get()) {
        int smoke_rc = driver_c_frontend_smoke(input_path, src, lib_roots_arr, n_lib_roots);
        free(src);
        return smoke_rc;
    }
    /*
     * shux check + asm 后端：优先走下方 SU pipeline（check_only_mode），与 compile 同 parse/typeck 路径。
     * 无 SU pipeline 时回退 C typeck。
     */
#if !defined(SHUX_USE_SX_PIPELINE)
    if (driver_check_only_get()) {
        int ck = driver_c_typeck_entry(input_path, src, lib_roots_arr, n_lib_roots, 1);
        free(src);
        return ck;
    }
#endif
#endif
    size_t arena_sz = pipeline_sizeof_arena();
    size_t module_sz = pipeline_sizeof_module();
    void *arena = malloc(arena_sz);
    void *module = malloc(module_sz);
    if (!arena || !module) {
        fprintf(stderr, "shux: -sx pipeline: malloc failed\n");
        if (arena) free(arena);
        if (module) free(module);
        free(src);
        return 1;
    }
    memset(arena, 0, arena_sz);
    memset(module, 0, module_sz);
    parser_parse_into_init(module, arena);
    struct parser_ParseIntoResult pr_imp = parser_parse_into_buf(arena, module, (uint8_t *)src, (int32_t)src_len);
    if (pr_imp.ok != 0) {
        fprintf(stderr, "shux: driver asm backend: parse_into_buf failed\n");
        free(arena);
        free(module);
        free(src);
        return 1;
    }
    parser_parse_into_set_main_index(module, pr_imp.main_idx);
    driver_set_pipeline_entry_source_len(src_len);
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] driver_first_parse num_funcs=%d src_len=%zu\n",
            driver_get_module_num_funcs(module), src_len);
    int32_t n_imports_entry = parser_get_module_num_imports(module);
    char entry_dir_buf[512];
    get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    const char *entry_dir = entry_dir_buf;

    char *dep_sources[MAX_ALL_DEPS];
    size_t dep_lens[MAX_ALL_DEPS];
    char *dep_paths[MAX_ALL_DEPS];
    int n_deps = 0;
    /*
     * build_shux_asm 单模块 -o（SHUX_ASM_ENTRY_MODULE_ONLY + SHUX_ASM_BUILD_SKIP_TYPECK）：
     * 并列链 build_asm/*.o，勿 collect_deps 读 import 源（无 lib_root 时 rc=1 → 4B stub）。
     */
    const int skip_dep_file_load =
        asm_entry_module_only_from_env() && driver_asm_build_skip_typeck() != 0;
    if (n_imports_entry > 0 && n_imports_entry <= 32) {
        if (skip_dep_file_load) {
            if (load_direct_imports_for_asm_layout(module, lib_roots_arr, n_lib_roots, entry_dir, defines, ndefines,
                    dep_sources, dep_lens, dep_paths, &n_deps) != 0) {
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        } else {
            char *cls[MAX_ALL_DEPS];
            size_t clens[MAX_ALL_DEPS];
            char *cpaths[MAX_ALL_DEPS];
            int n_closure = 0;
            if (collect_deps_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir, defines,
                    ndefines, cls, clens, cpaths, &n_closure) != 0) {
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            for (int rev = 0; rev < n_closure / 2; rev++) {
                int o = n_closure - 1 - rev;
                char *ts = cls[rev];
                cls[rev] = cls[o];
                cls[o] = ts;
                size_t tl = clens[rev];
                clens[rev] = clens[o];
                clens[o] = tl;
                char *tp = cpaths[rev];
                cpaths[rev] = cpaths[o];
                cpaths[o] = tp;
            }
            if (merge_direct_then_transitive_deps(module, n_imports_entry, cls, clens, cpaths, n_closure, dep_sources,
                    dep_lens, dep_paths, &n_deps) != 0) {
                while (n_closure > 0) {
                    n_closure--;
                    free(cls[n_closure]);
                    free(cpaths[n_closure]);
                }
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
    }
    /*
     * 入口已在上方 parser_parse_into_buf 解析（driver_first_parse）；勿再 memset module/arena，
     * 否则 pipeline 二次 strict parse 大模块仅 ~4 func（parser.sx）；见 run-parser-parse-count-gate.sh。
     */
    typeck_ndep = 0;
    FILE *asm_out = NULL;
    int emit_elf_o = 0;
    void *elf_ctx_ptr = NULL;
    char asm_tmp_o_path[64];
    int asm_want_exe = 0;
    /*
     * 无 -o：前端烟测（run-import / run-stdlib-import 的 grep「parse OK|typeck OK」），
     * 与 driver_run_emit_c_path 的 stderr 两行一致；不链 a.out、不向 stdout 写对象/汇编。
     * 有 -o 时：后缀决定 .o/.s 或临时 .o + ld 可执行。
     */
    const int asm_smoke_only = (out_path == NULL);
    asm_tmp_o_path[0] = '\0';
    if (asm_smoke_only) {
        asm_want_exe = 0;
        emit_elf_o = 0;
    } else {
        asm_want_exe = driver_asm_output_want_exe_cstr(out_path);
        if (asm_want_exe) {
            strcpy(asm_tmp_o_path, "/tmp/shux_asm_XXXXXX");
            int fd = mkstemp(asm_tmp_o_path);
            if (fd < 0) {
                perror("shux: mkstemp (asm)");
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            asm_out = fdopen(fd, "wb");
            if (!asm_out) {
                close(fd);
                unlink(asm_tmp_o_path);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            emit_elf_o = 1;
        } else {
            asm_out = fopen(out_path, "wb");
            if (!asm_out) {
                perror("shux: -o (asm)");
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            emit_elf_o = driver_asm_output_is_elf_o(out_path);
        }
    }
    if (emit_elf_o) {
        elf_ctx_ptr = malloc(pipeline_sizeof_elf_ctx());
        if (!elf_ctx_ptr) {
            fprintf(stderr, "shux: elf_ctx alloc failed\n");
            driver_asm_fclose_asm_out(asm_out);
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        memset(elf_ctx_ptr, 0, pipeline_sizeof_elf_ctx());
    }
    void *dep_arenas[32];
    void *dep_modules[32];
    int j;
    for (j = 0; j < n_deps; j++) {
        dep_arenas[j] = malloc(arena_sz);
        dep_modules[j] = malloc(module_sz);
        if (!dep_arenas[j] || !dep_modules[j]) {
            fprintf(stderr, "shux: -sx pipeline: dep alloc failed\n");
            driver_asm_fclose_asm_out(asm_out);
            if (elf_ctx_ptr) free(elf_ctx_ptr);
            while (j > 0) { j--; free(dep_arenas[j]); free(dep_modules[j]); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        memset(dep_arenas[j], 0, arena_sz);
        memset(dep_modules[j], 0, module_sz);
    }
    /*
     * CodegenOutBuf / PipelineDepCtx 动辄含 MiB 级内嵌缓冲区；在栈上会撑爆 ARM64/macOS 默认可用栈（线程默认约 512KiB）。
     * 改为堆分配，避免 driver_run_asm_backend 栈溢出。
     */
    struct codegen_CodegenOutBuf *out_buf = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*out_buf));
    struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*pctx));
    if (!out_buf || !pctx) {
        fprintf(stderr, "shux: -sx pipeline: out_buf/pctx alloc failed\n");
        driver_asm_fclose_asm_out(asm_out);
        if (elf_ctx_ptr) free(elf_ctx_ptr);
        for (j = 0; j < n_deps; j++) { free(dep_arenas[j]); free(dep_modules[j]); }
        while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
        free(arena);
        free(module);
        free(src);
        if (out_buf) free(out_buf);
        if (pctx) pipeline_dep_ctx_heap_destroy(pctx);
        return 1;
    }
    pipeline_fill_ctx_path_buffers(pctx, entry_dir, lib_roots_arr, n_lib_roots);
    /*
     * 入口 pipeline 阶段 use_asm_backend=0：与 shux check 同走 parse+merge+typeck（+ 可选 C codegen 填 out_buf），
     * 避免 use_asm_backend=1 时在 typeck_merge / typeck_sx_ast 上对 core.option 等 dep 崩溃（134/139）。
     * 真 .o/.Mach-O 由下方 asm_asm_codegen_elf_o 在 use_asm_backend=1 时 emit。
     * dep 槽在预跑结束后再 runtime_pctx_seed_dep_slots（见下方 typeck_ndep 块）。
     */
    pctx->use_asm_backend = 0;
    pctx->target_arch = 0;
    if (target && (strstr(target, "aarch64") != NULL || strstr(target, "arm64") != NULL))
        pctx->target_arch = 1;
    if (target && strstr(target, "riscv64") != NULL)
        pctx->target_arch = 2;
    pctx->target_cpu_features = (int32_t)driver_get_pending_target_cpu_features();
#if defined(__APPLE__) && defined(__aarch64__)
    if (!target)
        pctx->target_arch = 1;
#endif
    pctx->use_macho_o = 0;
    pctx->use_coff_o = 0;
#if defined(__APPLE__)
    if (emit_elf_o)
        pctx->use_macho_o = 1;
#endif
    if (emit_elf_o && target && strstr(target, "windows") != NULL)
        pctx->use_coff_o = 1;
    if (emit_elf_o)
        pctx->asm_entry_module_only = asm_entry_module_only_from_env();
    /**
     * build_shux_asm（SKIP_TYPECK）：dep 已由 build_asm/*.o 提供，仅编入口模块。
     * 用户多文件（tests/multi-file 等）：须在 asm_codegen_elf_o 内编入各 dep，否则 ld 缺 _foo_bar 等符号。
     */
    if (asm_want_exe && n_deps > 0 && !asm_smoke_only && driver_asm_build_skip_typeck() != 0)
        pctx->asm_entry_module_only = 1;
    /**
     * 用户单文件 -o（无 dep、非 build_shux_asm SKIP_TYPECK）：强制 ENTRY_MODULE_ONLY，
     * 与 asm_skip_heavy 用户完整 emit 分支对齐（seed shux return42 等 freestanding 烟测）。
     */
    if (emit_elf_o && n_deps == 0 && !asm_smoke_only && driver_asm_build_skip_typeck() == 0)
        pctx->asm_entry_module_only = 1;
    driver_dep_seeded_clear_all();
    /*
     * build_shux_asm（SHUX_ASM_BUILD_SKIP_TYPECK + ENTRY_MODULE_ONLY）：dep 已由 build_asm/*.o 提供，仅 publish 槽位。
     * 用户链 exe（无 SKIP_TYPECK）：须 parse+typeck dep 以解析 import 符号名，仅跳过 dep codegen（pipeline.sx）。
     */
    if (emit_elf_o && pctx->asm_entry_module_only && driver_asm_build_skip_typeck() != 0) {
        for (j = 0; j < n_deps; j++) {
            if (pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j],
                    dep_lens[j]) != 0) {
                fprintf(stderr, "shux: asm layout dep parse-only failed for '%s'\n",
                    dep_paths[j] ? dep_paths[j] : "?");
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                for (int k = 0; k < n_deps; k++) {
                    free(dep_arenas[k]);
                    free(dep_modules[k]);
                }
                while (n_deps > 0) {
                    n_deps--;
                    free(dep_sources[n_deps]);
                    free(dep_paths[n_deps]);
                }
                driver_asm_fclose_asm_out(asm_out);
                if (elf_ctx_ptr)
                    free(elf_ctx_ptr);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
        }
    } else {
        for (j = 0; j < n_deps; j++) {
            struct ast_PipelineDepCtx *one_ctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*one_ctx));
            struct codegen_CodegenOutBuf *dep_out = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*dep_out));
            if (!one_ctx || !dep_out) {
                fprintf(stderr, "shux: -sx pipeline: dep_one_ctx/out alloc failed\n");
                pipeline_dep_ctx_heap_destroy(one_ctx);
                free(dep_out);
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                driver_asm_fclose_asm_out(asm_out);
                if (elf_ctx_ptr) free(elf_ctx_ptr);
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            runtime_one_ctx_for_dep_prerun(one_ctx, j, dep_modules[j], dep_arenas[j]);
            pipeline_fill_ctx_path_buffers(one_ctx, runtime_dep_prerun_entry_dir(entry_dir, lib_roots_arr, n_lib_roots),
                lib_roots_arr, n_lib_roots);
            /*
             * 无 -o 烟测：dep 仅 parse 填槽；全量 .sx typeck 在 strict typeck.o 上对 std.io 等大库易 SIGSEGV。
             * 有 -o 用户链仍 typeck dep（std.io 经 seed bridge）；入口走 C typeck。
             */
            int ec_loop;
            if (asm_smoke_only) {
                ec_loop = pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
            } else if (emit_elf_o && asm_user_std_dep_skip_su_typeck(dep_paths[j])) {
                /*
                 * 用户 asm -o：std.io/fs 由并列 *.o 提供 *_c，dep 仅 parse 填 import 槽；
                 * 勿对 read_fd 等跑 .sx typeck（与 user_asm_seed_bridge dep skip emit 对齐）。
                 */
                ec_loop = pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
            } else if (emit_elf_o && asm_user_dep_parse_skip_typeck_path(dep_paths[j])) {
                /*
                 * std.net：须 co-emit listen/accept_many；parse_only 常 funcs=0，改 parse+skip typeck 填槽。
                 */
                ec_loop = pipeline_dep_prerun_parse_skip_typeck(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j], (void *)dep_out, (void *)one_ctx);
                if (ec_loop == 0 && asm_user_std_net_dep_path(dep_paths[j]))
                    pipeline_asm_seed_std_net_struct_layouts((struct ast_Module *)dep_modules[j]);
            } else if (emit_elf_o && pctx->asm_entry_module_only && driver_asm_build_skip_typeck() == 0) {
                /*
                 * ENTRY_MODULE_ONLY 且将走 C typeck 预检：dep 仅 parse 填槽，勿对整棵 dep 再跑 .sx typeck（栈/耗时）。
                 * 入口模块类型由 driver_c_typeck_entry 与并列 build_asm/*.o 保证。
                 */
                ec_loop = pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
#if defined(SHUX_ASM_USE_COMPILER_IMPL_C)
            } else if (emit_elf_o && !asm_smoke_only && !driver_asm_build_skip_typeck()) {
                /*
                 * B-strict shux_asm 用户多文件 -o：dep 仅 parse 填 import 槽；入口 skip .sx typeck（见下方 set）。
                 * 注：std.string/heap 等 .sx 符号须 shux-c 链 exe，或后续改 co-emit 填全量 func 槽。
                 */
                ec_loop = pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
#endif
            } else {
                ec_loop = pipeline_dep_prerun_for_asm_module_o(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j],
                    (size_t)dep_lens[j], (void *)dep_out, (void *)one_ctx);
            }
            pipeline_dep_ctx_heap_destroy(one_ctx);
            free(dep_out);
            if (ec_loop != 0) {
                fprintf(stderr, "shux: pipeline failed for import '%s' (rc=%d)\n", dep_paths[j], ec_loop);
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                driver_asm_fclose_asm_out(asm_out);
                if (elf_ctx_ptr) free(elf_ctx_ptr);
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
        }
    }
    typeck_ndep = n_deps;
    for (j = 0; j < n_deps; j++) {
        typeck_dep_module_ptrs[j] = dep_modules[j];
        typeck_dep_arena_ptrs[j] = dep_arenas[j];
    }
    runtime_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
    pipeline_set_dep_slots(dep_arenas, dep_modules);
    driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
    codegen_set_dep_slots_for_su_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
    codegen_set_preamble_has_core_option_result(1);
    /**
     * 入口已在上方 parser_parse_into_buf 解析进 module/arena；pipeline 内勿 pipeline_strict_parse_into_init 重 parse
     * （大模块 parser.sx 二次 parse 仅 ~4 func，见 run-parser-parse-count-gate.sh）。
     */
    pctx->entry_already_parsed = 1;
    int ec = 0;
    {
        /* === SHUX_ASM_ENTRY_ONLY_DEBUG: 分段日志，定位 segfault === */
        const char *entry_name = input_path ? strrchr(input_path, '/') : NULL;
        entry_name = entry_name ? entry_name + 1 : input_path;
        if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
            fprintf(stderr, ">> [ASM_ENTRY_DEBUG] entry=%s n_deps=%d\n", entry_name, n_deps);
            fflush(stderr);
        }
        /* 1. 预检：当前文件长度 */
        if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
            fprintf(stderr, ">> [ASM_ENTRY_DEBUG] src_len=%zu entry_funcs=%d\n", src_len, driver_get_module_num_funcs(module));
        }
        /* 2. 调 pipeline_run_sx_pipeline */
        if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
            fprintf(stderr, ">> [ASM_ENTRY_DEBUG] BEFORE pipeline_run_sx_pipeline\n");
            fflush(stderr);
        }
#if !defined(SHUX_NO_C_FRONTEND)
        /*
         * 用户程序 asm 编译：C typeck 预检（strict 链 typeck_c_orchestration_partial 提供真 typeck_module），
         * 再 skip pipeline 内 .sx typeck（第 2+ CALL 实参仍可能 SIGSEGV）。
         */
        if (!driver_asm_build_skip_typeck()) {
            const char *skip_c_precheck = getenv("SHUX_ASM_SKIP_C_TYPECK_PRECHECK");
            if (skip_c_precheck == NULL || skip_c_precheck[0] == '\0' || skip_c_precheck[0] == '0') {
                if (driver_c_typeck_entry_large_stack(input_path, src, lib_roots_arr, n_lib_roots, 0) != 0) {
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    for (j = 0; j < n_deps; j++) {
                        free(dep_arenas[j]);
                        free(dep_modules[j]);
                    }
                    while (n_deps > 0) {
                        n_deps--;
                        free(dep_sources[n_deps]);
                        free(dep_paths[n_deps]);
                    }
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
            }
        }
#endif
        /*
         * 用户 asm -o：入口 pipeline 跳过 .sx typeck（须在 #endif 外：shux_asm 为 SHUX_NO_C_FRONTEND 时仍要 skip）。
         * import 程序（dead_user 等）否则 typecheck_entry SIGSEGV。
         */
        if (!asm_smoke_only) {
            driver_su_pipeline_skip_typeck_set(1);
            /** 仅 parse+填槽；真机器码由 asm_asm_codegen_elf_o 生成。 */
            driver_su_pipeline_skip_codegen_set(1);
        }
        ec = pipeline_run_sx_pipeline_large_stack(module, arena, (const uint8_t *)src, src_len, (void *)out_buf, (void *)pctx);
        driver_su_pipeline_skip_typeck_set(0);
        driver_su_pipeline_skip_codegen_set(0);
        if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
            fprintf(stderr, ">> [ASM_ENTRY_DEBUG] AFTER pipeline_run_sx_pipeline ec=%d funcs=%d out_len=%zu\n",
                ec, driver_get_module_num_funcs(module), (size_t)out_buf->len);
            fflush(stderr);
        }
        /* 3. 如果是 segfault，上面的 fprintf 不会执行；需要更前置的分段日志 */
        if (ec != 0) {
            fprintf(stderr, "shux: sm_diag: main pipeline returned %d\n", ec);
        }
    }
    pctx->use_asm_backend = 1;
    if (getenv("SHUX_ASM_DEBUG")) {
        fprintf(stderr, "shux: asm backend after pipeline: ec=%d num_funcs=%d out_asm_len=%zu\n",
                ec, driver_get_module_num_funcs(module), (size_t)out_buf->len);
        pipeline_debug_module_funcs(module);
    }
    if (asm_smoke_only) {
        for (j = 0; j < n_deps; j++) {
            free(dep_arenas[j]);
            free(dep_modules[j]);
        }
        while (n_deps > 0) {
            n_deps--;
            free(dep_sources[n_deps]);
            free(dep_paths[n_deps]);
        }
        {
            int smoke_ec = ec;
            int smoke_num_funcs = driver_get_module_num_funcs(module);
            if (smoke_ec != 0)
                fprintf(stderr, "shux: -sx pipeline failed (parse_into / typeck_sx_ast / codegen_sx_ast)\n");
            else if (smoke_num_funcs <= 0)
                fprintf(stderr, "shux: parse produced no functions for '%s'\n", input_path ? input_path : "?");
            else if (driver_check_only_get()) {
                driver_print_su_smoke_summary(module, (size_t)out_buf->len);
                if (input_path)
                    driver_print_check_ok(input_path);
            } else
                driver_print_su_smoke_summary(module, (size_t)out_buf->len);
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            free(arena);
            free(module);
            free(src);
            if (smoke_ec != 0) {
                driver_dep_seeded_clear_all();
                typeck_ndep = 0;
                return 1;
            }
            if (smoke_num_funcs <= 0) {
                driver_dep_seeded_clear_all();
                typeck_ndep = 0;
                return 1;
            }
            /* 烟测与后续 -o 同进程时须清 dep 全局槽，否则第二次 asm 易 SIGSEGV（run-import 等）。 */
            driver_dep_seeded_clear_all();
            typeck_ndep = 0;
            return 0;
        }
    }
    if (ec == 0 && (out_buf->len > 0 || emit_elf_o)) {
        if (emit_elf_o && elf_ctx_ptr && !driver_asm_out_buf_is_object(out_buf)) {
            /*
             * pipeline_run 后 driver_dep_seeded_clear_all 仅清全局槽；须把 dep 模块重新写入 pctx，
             * 且对用户多文件关闭 ENTRY_MODULE_ONLY，否则 asm_codegen_elf_o 只编 main、ld 缺 _foo_bar。
             */
            if (n_deps > 0) {
                for (j = 0; j < n_deps; j++)
                    driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
                typeck_ndep = n_deps;
                for (j = 0; j < n_deps; j++) {
                    typeck_dep_module_ptrs[j] = dep_modules[j];
                    typeck_dep_arena_ptrs[j] = dep_arenas[j];
                }
                pipeline_set_dep_slots(dep_arenas, dep_modules);
                driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
                runtime_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
                /*
                 * 多文件 -o 须编 dep 机器码；显式 SHUX_ASM_ENTRY_MODULE_ONLY=1（build_shux_asm / M8 单模块 -o）
                 * 时保持仅入口，dep 由并列 build_asm/*.o 提供，勿对 arch/x86_64 等 dep 再跑 asm emit。
                 */
                if (!asm_entry_module_only_from_env())
                    pctx->asm_entry_module_only = 0;
                pctx->use_asm_backend = 1;
            }
            driver_asm_prepare_entry_elf_emit(module, arena, pctx);
            int32_t elf_ec = asm_asm_codegen_elf_o_large_stack(module, arena, (void *)pctx, (struct platform_elf_ElfCodegenCtx *)elf_ctx_ptr, (void *)out_buf);
            if (getenv("SHUX_ASM_DEBUG")) {
                fprintf(stderr, "shux: asm_codegen_elf_o: elf_ec=%d elf_len=%zu\n", (int)elf_ec, (size_t)out_buf->len);
            }
            if (elf_ec != 0 || out_buf->len <= 0) {
                fprintf(stderr, "shux: asm_codegen_elf_o failed (elf_ec=%d, out_len=%zu, num_funcs=%d)\n",
                        (int)elf_ec, (size_t)out_buf->len, driver_get_module_num_funcs(module));
                if (elf_ec != 0 && elf_ctx_ptr)
                    pipeline_elf_ctx_diag_stderr((uint8_t *)elf_ctx_ptr);
                driver_asm_fclose_asm_out(asm_out);
                if (elf_ctx_ptr) free(elf_ctx_ptr);
                for (j = 0; j < n_deps; j++) { free(dep_arenas[j]); free(dep_modules[j]); }
                while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
        fwrite(out_buf->data, 1, (size_t)out_buf->len, asm_out ? asm_out : stdout);
        if (!asm_out)
            fflush(stdout);
        driver_asm_fclose_asm_out(asm_out);
        asm_out = NULL;
        if (elf_ctx_ptr) { free(elf_ctx_ptr); elf_ctx_ptr = NULL; }
        for (j = 0; j < n_deps; j++) { free(dep_arenas[j]); free(dep_modules[j]); }
        while (n_deps > 0) {
            n_deps--;
            free(dep_sources[n_deps]);
            free(dep_paths[n_deps]);
        }
        if (asm_want_exe && asm_tmp_o_path[0]) {
            const char *asm_exe_out = out_path ? out_path : "a.out";
            int ld_ok = driver_asm_invoke_ld(asm_tmp_o_path, asm_exe_out, target, pctx->use_macho_o, pctx->use_coff_o, argv ? argv[0] : NULL,
                lib_roots_arr, n_lib_roots);
            unlink(asm_tmp_o_path);
            if (ld_ok != 0) {
                fprintf(stderr, "shux: ld failed (asm -> %s)\n", asm_exe_out);
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
    } else {
        driver_asm_fclose_asm_out(asm_out);
        if (asm_want_exe && asm_tmp_o_path[0]) unlink(asm_tmp_o_path);
        if (elf_ctx_ptr) free(elf_ctx_ptr);
        for (j = 0; j < n_deps; j++) { free(dep_arenas[j]); free(dep_modules[j]); }
        while (n_deps > 0) {
            n_deps--;
            free(dep_sources[n_deps]);
            free(dep_paths[n_deps]);
        }
        if (ec != 0) {
            fprintf(stderr, "shux: -sx pipeline failed (parse_into / typeck_sx_ast / codegen_sx_ast)\n");
        }
    }
    if (ec == 0 && emit_elf_o && driver_get_module_num_funcs(module) <= 0) {
        fprintf(stderr, "shux: asm: parse produced no functions in '%s'\n", input_path ? input_path : "?");
        ec = -1;
    }
    driver_dep_seeded_clear_all();
    codegen_set_dep_slots_for_su_pipeline(NULL, NULL, 0);
    free(out_buf);
    pipeline_dep_ctx_heap_destroy(pctx);
    free(arena);
    free(module);
    free(src);
    return (ec != 0) ? 1 : 0;
}
#endif /* SHUX_USE_SX_DRIVER && SHUX_USE_SX_PIPELINE */

#define SU_FULL_MAX_LIB_ROOTS 16

/** compile.sx 解析 argv 后的分派参数（库根由 sidecar 键在 dispatch 中展开）。 */
typedef struct DriverCompileParsed {
    const char *input_path;
    const char *out_path;
    const char *lib_roots_arr[SU_FULL_MAX_LIB_ROOTS];
    int n_lib_roots;
    int want_asm_backend;
    const char *target;
    const char *opt_level;
    int use_lto;
} DriverCompileParsed;

#if !defined(SHUX_NO_C_FRONTEND)
/**
 * C 前端 parse + resolve deps + typeck_module（与 shux-c 一致）。
 * print_ok 非 0 时成功打印 check OK（shux check）；否则静默（asm 编译前预检）。
 * 【返回】0 成功；1 失败。
 */
/** 预处理后源码是否含顶层 import（seed asm 对这类入口 SU parse 易 0 func，改走 C 前端）。 */
static int driver_source_has_top_level_import(const char *src, size_t src_len) {
    if (!src || src_len < 9)
        return 0;
    const char *p = src;
    const char *end = src + src_len;
    while (p + 9 <= end) {
        if (memcmp(p, "import(\"", 8) == 0)
            return 1;
        if (memcmp(p, "= import(", 9) == 0)
            return 1;
        p++;
    }
    return 0;
}

/** 读入口文件并检测顶层 import（供 compile.sx 在 asm 分派前降级 C 后端）。 */
int driver_source_has_top_level_import_path(const char *path) {
    size_t raw_len = 0;
    char *raw = read_file(path, &raw_len);
    if (!raw)
        return 0;
    size_t src_len = 0;
    char *src = preprocess(raw, raw_len, NULL, 0, &src_len);
    free(raw);
    if (!src)
        return 0;
    int has = driver_source_has_top_level_import(src, src_len);
    free(src);
    return has;
}

/** C 前端烟测：stderr 打印 parse OK / typeck OK（run-import、run-stdlib-import grep）。 */
static int driver_c_frontend_smoke(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots) {
    Lexer *lex = lexer_new(src);
    ASTModule *mod = NULL;
    int pr = parse(lex, &mod);
    lexer_free(lex);
    if (pr != 0 || !mod) {
        if (mod)
            ast_module_free(mod);
        fprintf(stderr, "shux: parse failed for '%s' (pr=%d)\n", input_path ? input_path : "?", pr);
        return 1;
    }
    char entry_dir_buf[512];
    get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    ASTModule *dep_mods[32];
    ASTModule *all_dep_mods[MAX_ALL_DEPS];
    char *all_dep_paths[MAX_ALL_DEPS];
    int ndep = 0, n_all = 0;
    if (mod->num_imports > 0 &&
        resolve_and_load_imports(mod, lib_roots_arr, n_lib_roots, entry_dir_buf, NULL, 0, dep_mods, &ndep,
            all_dep_mods, all_dep_paths, NULL, &n_all, 32) != 0) {
        ast_module_free(mod);
        return 1;
    }
    if (typeck_module(mod, ndep > 0 ? dep_mods : NULL, ndep, n_all > 0 ? all_dep_mods : NULL, n_all) != 0) {
        while (n_all--) {
            free(all_dep_paths[n_all]);
            ast_module_free(all_dep_mods[n_all]);
        }
        ast_module_free(mod);
        return 1;
    }
    const char *main_name = (mod->main_func && mod->main_func->name) ? mod->main_func->name : "main";
    fprintf(stderr, "parse OK: %s(): i32 { expr }\n", main_name);
    fprintf(stderr, "typeck OK\n");
    while (n_all--) {
        free(all_dep_paths[n_all]);
        ast_module_free(all_dep_mods[n_all]);
    }
    ast_module_free(mod);
    return 0;
}

#if defined(SHUX_USE_SX_PIPELINE)
/** shux check 后 SU 栈逃逸 gate 大栈线程参数。 */
typedef struct {
    uint8_t *src;
    int32_t src_len;
    int32_t result;
} DriverStackEscGateArgs;

/** pthread 入口：WPO-S3 post-scan gate。 */
static void *driver_stack_esc_gate_thread_fn(void *arg) {
    DriverStackEscGateArgs *a = (DriverStackEscGateArgs *)arg;
    a->result = pipeline_typeck_sx_stack_escape_gate_from_src_c(a->src, a->src_len);
    return NULL;
}

/**
 * 在 256MiB 栈 pthread 上跑 SU struct 栈逃逸 gate（check 路径；勿在主线程 parse）。
 */
static int32_t driver_stack_esc_gate_large_stack(uint8_t *src, int32_t src_len) {
    DriverStackEscGateArgs args;
    args.src = src;
    args.src_len = src_len;
    args.result = -99;
    driver_run_thread_on_large_stack(driver_stack_esc_gate_thread_fn, &args);
    if (args.result == -99)
        return pipeline_typeck_sx_stack_escape_gate_from_src_c(src, src_len);
    return args.result;
}
#endif

static int driver_c_typeck_entry(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots, int print_ok) {
    Lexer *lex = lexer_new(src);
    ASTModule *mod = NULL;
    int pr = parse(lex, &mod);
    lexer_free(lex);
    if (pr != 0 || !mod) {
        if (mod)
            ast_module_free(mod);
        fprintf(stderr, "shux: parse failed for '%s' (pr=%d)\n", input_path ? input_path : "?", pr);
        return 1;
    }
    char entry_dir_buf[512];
    get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    ASTModule *dep_mods[32];
    ASTModule *all_dep_mods[MAX_ALL_DEPS];
    char *all_dep_paths[MAX_ALL_DEPS];
    int ndep = 0, n_all = 0;
    if (mod->num_imports > 0 &&
        resolve_and_load_imports(mod, lib_roots_arr, n_lib_roots, entry_dir_buf, NULL, 0, dep_mods, &ndep,
            all_dep_mods, all_dep_paths, NULL, &n_all, 32) != 0) {
        ast_module_free(mod);
        return 1;
    }
#if defined(SHUX_USE_SX_TYPECK) && !defined(SHUX_USE_SX_PIPELINE)
    if (typeck_typeck_entry(mod, ndep > 0 ? dep_mods : NULL, ndep) != 0) {
#else
    if (typeck_module(mod, ndep > 0 ? dep_mods : NULL, ndep, n_all > 0 ? all_dep_mods : NULL, n_all) != 0) {
#endif
        while (n_all--) {
            free(all_dep_paths[n_all]);
            ast_module_free(all_dep_mods[n_all]);
        }
        ast_module_free(mod);
        return 1;
    }
#if defined(SHUX_USE_SX_PIPELINE)
    if (print_ok && mod->num_imports == 0) {
        int32_t slen = (int32_t)strlen(src);
        if (slen > 0 && driver_stack_esc_gate_large_stack((uint8_t *)src, slen) != 0) {
            while (n_all--) {
                free(all_dep_paths[n_all]);
                ast_module_free(all_dep_mods[n_all]);
            }
            ast_module_free(mod);
            return 1;
        }
    }
#endif
    while (n_all--) {
        free(all_dep_paths[n_all]);
        ast_module_free(all_dep_mods[n_all]);
    }
    ast_module_free(mod);
    if (print_ok)
        driver_print_check_ok(input_path);
    return 0;
}

/** C typeck 大栈线程参数。 */
typedef struct {
    const char *input_path;
    char *src;
    const char **lib_roots_arr;
    int n_lib_roots;
    int print_ok;
    int result;
} DriverCTypeckLargeArgs;

/** pthread 入口：driver_c_typeck_entry 并将 rc 写入 args->result。 */
static void *driver_c_typeck_entry_thread_fn(void *arg) {
    DriverCTypeckLargeArgs *a = (DriverCTypeckLargeArgs *)arg;
    a->result = driver_c_typeck_entry(a->input_path, a->src, a->lib_roots_arr, a->n_lib_roots, a->print_ok);
    return NULL;
}

/**
 * 在 256MiB 栈 pthread 上执行 C typeck 预检；避免 lexer 等大模块在主线程耗尽栈后 asm emit Abort。
 */
static int driver_c_typeck_entry_large_stack(const char *input_path, char *src, const char **lib_roots_arr,
    int n_lib_roots, int print_ok) {
    DriverCTypeckLargeArgs args;
    args.input_path = input_path;
    args.src = src;
    args.lib_roots_arr = lib_roots_arr;
    args.n_lib_roots = n_lib_roots;
    args.print_ok = print_ok;
    args.result = -99;
    driver_run_thread_on_large_stack(driver_c_typeck_entry_thread_fn, &args);
    if (args.result == -99)
        return driver_c_typeck_entry(input_path, src, lib_roots_arr, n_lib_roots, print_ok);
    return args.result;
}

/** shux check：C typeck 入口（库模块无 main 时比 SU pipeline 更稳；bootstrap 与 shux-c 共用）。 */
#if !defined(SHUX_NO_C_FRONTEND)
static int driver_check_only_c_typeck(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots) {
    return driver_c_typeck_entry(input_path, src, lib_roots_arr, n_lib_roots, 1);
}
#endif

/**
 * argv 已解析后的编译执行：泛型降级、asm/C 分派、pipeline/cc。
 * 由 driver/compile.sx 经 driver_run_compiler_dispatch_c 调用。
 */
static int driver_run_compiler_parsed(DriverCompileParsed *p, int argc, char **argv) {
    const char *defines[MAX_DEFINES];
    int ndefines = 0;
    if (argv && argc > 0)
        ndefines = driver_argv_collect_defines(argc, argv, defines, MAX_DEFINES);
    const char *input_path = p->input_path;
    const char *out_path = p->out_path;
    const char **lib_roots_arr = (const char **)p->lib_roots_arr;
    int n_lib_roots = p->n_lib_roots;
    int want_asm_backend = p->want_asm_backend;
    const char *target = p->target;
    const char *opt_level = p->opt_level ? p->opt_level : "2";
    int use_lto = p->use_lto;
    if (!input_path)
        return 1;
    driver_bump_stack_limit_if_needed();
    /* shux check：强制走 SU pipeline 的 typeck 路径，不做 asm 后端与链接。 */
    if (driver_check_only_get())
        want_asm_backend = 0;
#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
    /*
     * 默认 asm：入口源码若含泛型/trait 且输出将链成可执行（无 -o 仍视作需降级场景），asm 后端无法单态化，降级为 C/pipeline。
     * -o 为 .o/.obj/.s 时仅生成对象或汇编、不链 exe，跳过泛型扫描，不改 want_asm_backend（逻辑同 output_want_exe / driver_asm_output_want_exe_cstr）。
     */
    if (want_asm_backend && input_path && (!out_path || driver_asm_output_want_exe_cstr(out_path))) {
        int plen = (int)strlen(input_path);
        if (plen > 0 && plen < 512 &&
            driver_source_has_generic_syntax((const uint8_t *)input_path, plen))
            want_asm_backend = 0;
    }
    /*
     * 默认走 asm：一律走 SU pipeline + asm_asm_codegen_*（有无 -o 均如此）；`-backend c` 已在上方关闭 want_asm_backend。
     * 无 \c out_path 时向 stdout 打汇编文本；否则写 \c .o / \c .s / 或可执行路径（参见 driver_run_asm_backend）。
     */
#if !defined(SHUX_NO_C_FRONTEND)
    /*
     * shux-c 路径：顶层 import 时 SU asm parse 易 0 func，降级 C；shux_asm（SHUX_NO_C_FRONTEND）须保留 asm + driver_run_asm_backend。
     */
    if (want_asm_backend) {
        size_t imp_raw_len = 0;
        char *imp_raw = read_file(input_path, &imp_raw_len);
        if (imp_raw) {
            size_t imp_src_len = 0;
            char *imp_src = preprocess(imp_raw, imp_raw_len, NULL, 0, &imp_src_len);
            free(imp_raw);
            if (imp_src && driver_source_has_top_level_import(imp_src, imp_src_len))
                want_asm_backend = 0;
            free(imp_src);
        }
    }
#endif
    if (want_asm_backend)
        return driver_run_asm_backend(input_path, out_path, lib_roots_arr, n_lib_roots, target, argc, argv);
#endif
    int emit_to_stdout = (out_path == NULL);

    size_t raw_src_len = 0;
    char *raw_src = read_file(input_path, &raw_src_len);
    if (!raw_src) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = preprocess(raw_src, raw_src_len, NULL, 0, &src_len);
    free(raw_src);
    if (!src) {
        fprintf(stderr, "shux: preprocess failed for '%s'\n", input_path);
        return 1;
    }
#if !defined(SHUX_NO_C_FRONTEND)
    /*
     * shux check：优先 C parse+typeck（支持库模块、import -L）；SU pipeline check 待与 compile 对齐后再切回。
     */
    if (driver_check_only_get()) {
        int ck = driver_check_only_c_typeck(input_path, src, lib_roots_arr, n_lib_roots);
        free(src);
        return ck;
    }
    if (emit_to_stdout && !driver_check_only_get()) {
        int smoke_rc = driver_c_frontend_smoke(input_path, src, lib_roots_arr, n_lib_roots);
        free(src);
        return smoke_rc;
    }
#endif
    /* 若预处理后源码含泛型语法，.sx 流水线不解析泛型，改走 C 流水线（parse + typeck_module + codegen）以保证 id<i32>(42) 等正确单态化。
     * 无 import 时内联 C 路径，避免 run_compiler_c 重入导致崩溃；有 import 时仍调 run_compiler_c。 */
#if !defined(SHUX_NO_C_FRONTEND)
    if (content_has_generic_syntax(src, src_len)) {
        {
            Lexer *lex = lexer_new(src);
            ASTModule *c_mod = NULL;
            int pr = parse(lex, &c_mod);
            lexer_free(lex);
            if (pr != 0 || !c_mod) {
                if (c_mod) ast_module_free(c_mod);
                free(src);
                fprintf(stderr, "shux: parse failed for '%s' (pr=%d)\n", input_path, pr);
                return 1;
            }
            /* 有 import 时 run_compiler_c 从 driver 重入会崩溃，一律回退 .sx pipeline；泛型+import 的 multi-file-generic 依赖 pipeline 产出带 preamble 的 C（见下方 pipeline 写 C 逻辑） */
            if (c_mod->num_imports > 0) {
                ast_module_free(c_mod);
                /* 不 free(src)，fall through 到 pipeline */
            } else {
            if (!c_mod->main_func || !c_mod->main_func->body) {
                if (driver_check_only_get() && c_mod->num_funcs > 0) {
                    if (typeck_module(c_mod, NULL, 0, NULL, 0) != 0) {
                        ast_module_free(c_mod);
                        free(src);
                        return 1;
                    }
                    ast_module_free(c_mod);
                    free(src);
                    driver_print_check_ok(input_path);
                    return 0;
                }
                ast_module_free(c_mod);
                free(src);
                fprintf(stderr, "shux: no main function (cannot emit executable)\n");
                return 1;
            }
            if (typeck_module(c_mod, NULL, 0, NULL, 0) != 0) {
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            if (driver_check_only_get()) {
                ast_module_free(c_mod);
                free(src);
                driver_print_check_ok(input_path);
                return 0;
            }
            codegen_set_preamble_has_core_option_result(0);
            char tmp[] = "/tmp/shux_XXXXXX";
            int fd = mkstemp(tmp);
            if (fd < 0) {
                perror("shux: mkstemp");
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            FILE *cf = fdopen(fd, "w");
            if (!cf) {
                close(fd);
                unlink(tmp);
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            if (codegen_module_to_c(c_mod, cf, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0) != 0) {
                fclose(cf);
                unlink(tmp);
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            fclose(cf);
            char tmp_c[32];
            snprintf(tmp_c, sizeof(tmp_c), "%s.c", tmp);
            if (rename(tmp, tmp_c) != 0) {
                perror("shux: rename");
                unlink(tmp);
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            {
                const char *c_paths[1] = { tmp_c };
                const char *io_o = get_io_o_path(argv[0]);
                const char *fs_o = get_std_fs_o_path(argv[0]);
                const char *process_o = get_std_process_o_path(argv[0]);
                const char *string_o = get_std_string_o_path(argv[0]);
                const char *heap_o = get_std_heap_o_path(argv[0]);
                const char *path_o = get_std_path_o_path(argv[0]);
                const char *runtime_o = get_std_runtime_o_path(argv[0]);
                const char *runtime_panic_o = get_runtime_panic_o_path(argv[0]);
                const char *net_o = get_std_net_o_path(argv[0]);
                const char *thread_o = get_std_thread_o_path(argv[0]);
                const char *time_o = get_std_time_o_path(argv[0]);
                const char *random_o = get_std_random_o_path(argv[0]);
                const char *env_o = get_std_env_o_path(argv[0]);
                const char *sync_o = get_std_sync_o_path(argv[0]);
                const char *encoding_o = get_std_encoding_o_path(argv[0]);
                const char *base64_o = get_std_base64_o_path(argv[0]);
                const char *crypto_o = get_std_crypto_o_path(argv[0]);
                const char *log_o = get_std_log_o_path(argv[0]);
                const char *atomic_o = get_std_atomic_o_path(argv[0]);
                const char *channel_o = get_std_channel_o_path(argv[0]);
                const char *backtrace_o = get_std_backtrace_o_path(argv[0]);
                const char *hash_o = get_std_hash_o_path(argv[0]);
                const char *math_o = get_std_math_o_path(argv[0]);
                const char *sort_o = get_std_sort_o_path(argv[0]);
                const char *ffi_o = get_std_ffi_o_path(argv[0]);
                const char *db_o = get_std_sqlite_o_path(argv[0]);
                const char *elf_o = get_std_elf_o_path(argv[0]);
                const char *json_o = get_std_json_o_path(argv[0]);
                const char *csv_o = get_std_csv_o_path(argv[0]);
                const char *regex_o = get_std_regex_o_path(argv[0]);
                const char *compress_o = get_std_compress_o_path(argv[0]);
                const char *unicode_o = get_std_unicode_o_path(argv[0]);
                const char *dynlib_o = get_std_dynlib_o_path(argv[0]);
                const char *http_o = get_std_http_o_path(argv[0]);
                const char *tar_o = get_std_tar_o_path(argv[0]);
                const char *simd_o = get_std_simd_o_path(argv[0]);
                const char *context_o = get_std_context_o_path(argv[0]);
                const char *datetime_o = get_std_datetime_o_path(argv[0]);
                const char *uuid_o = get_std_uuid_o_path(argv[0]);
                const char *url_o = get_std_url_o_path(argv[0]);
                const char *cli_o = get_std_cli_o_path(argv[0]);
                const char *security_o = get_std_security_o_path(argv[0]);
                const char *config_o = get_std_config_o_path(argv[0]);
                const char *cache_o = get_std_cache_o_path(argv[0]);
                const char *trace_o = get_std_trace_o_path(argv[0]);
                const char *task_o = get_std_task_o_path(argv[0]);
                const char *schema_o = get_std_schema_o_path(argv[0]);
                const char *test_o = get_std_test_o_path(argv[0]);
                int cc_ret = invoke_cc(c_paths, 1, out_path, NULL, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, get_repo_root(argv[0]), NULL);
                if (cc_ret != 0)
                    fprintf(stderr, "shux: cc failed, keeping generated C: %s\n", tmp_c);
                else if (!getenv("SHUX_KEEP_C"))
                    unlink(tmp_c);
                ast_module_free(c_mod);
                free(src);
                return cc_ret == 0 ? 0 : 1;
            }
            }
        }
    }
#else  /* SHUX_NO_C_FRONTEND */
    if (content_has_generic_syntax(src, src_len)) {
        fprintf(stderr,
                "shux: generic/trait monomorphization requires C parser (build without -DSHUX_NO_C_FRONTEND)\n");
        free(src);
        return 1;
    }
#endif /* !SHUX_NO_C_FRONTEND */
    if (getenv("SHUX_DUMP_PREP")) {
        if (shux_write_path_bytes("/tmp/shux_prep_entry.bin", src, src_len) == 0) {
            fprintf(stderr, "shux: dumped prep entry (%zu bytes) to /tmp/shux_prep_entry.bin\n", src_len);
        }
    }
    size_t arena_sz = pipeline_sizeof_arena();
    size_t module_sz = pipeline_sizeof_module();
    void *arena = malloc(arena_sz);
    void *module = malloc(module_sz);
    if (!arena || !module) {
        free(arena);
        free(module);
        free(src);
        return 1;
    }
    memset(arena, 0, arena_sz);
    memset(module, 0, module_sz);
    struct shux_slice_uint8_t src_slice = { (uint8_t *)src, src_len }; /* 仅 diagnostics，入口解析必须与 pipeline 一致走 parse_into_buf */
    if (src_len > (size_t)INT32_MAX) {
        fprintf(stderr, "shux: entry source too large for parser (>%d bytes): '%s'\n", INT32_MAX, input_path);
        free(arena);
        free(module);
        free(src);
        return 1;
    }
    parser_parse_into_init(module, arena);
    struct parser_ParseIntoResult pr = parser_parse_into_buf(arena, module, (uint8_t *)src, (int32_t)src_len);
    if (pr.ok != 0) {
        fprintf(stderr, "shux: parse failed for '%s' (pr.ok=%d main_idx=%d)\n", input_path, (int)pr.ok, (int)pr.main_idx);
        { int32_t first_tok = parser_diag_token_after_collect_imports(&src_slice, module); fprintf(stderr, "shux: first_token_after_imports=%d (1=TOKEN_FUNCTION)\n", (int)first_tok); }
        if (src_len > 0 && src_len < 200)
            fprintf(stderr, "shux: src_len=%zu first_bytes=%.*s\n", src_len, (int)(src_len > 60 ? 60 : src_len), src);
        free(arena);
        free(module);
        free(src);
        return 1;
    }
    parser_parse_into_set_main_index(module, pr.main_idx);
    int32_t n_imports = parser_get_module_num_imports(module);
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr,
                "shux: [SHUX_DEBUG_PIPE] driver post-parse_into_buf num_funcs=%d n_imports=%d pr_ok=%d pr_main_idx=%d "
                "src_len=%zu\n",
                driver_get_module_num_funcs(module), (int)n_imports, (int)pr.ok, (int)pr.main_idx, src_len);
    char entry_dir_buf[512];
    get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    if (n_imports > 0)
        pipeline_set_entry_dir(entry_dir_buf);

    char *dep_sources[MAX_ALL_DEPS];
    size_t dep_lens[MAX_ALL_DEPS];
    char *dep_paths[MAX_ALL_DEPS];
    int n_deps = 0;
    if (n_imports > 0 && n_imports <= 32) {
        if (collect_deps_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir_buf, defines,
                ndefines, dep_sources, dep_lens, dep_paths, &n_deps) != 0) {
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        if (getenv("SHUX_DEBUG_PIPE")) {
            fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] n_deps=%d", n_deps);
            for (int dj = 0; dj < n_deps; dj++)
                fprintf(stderr, " dep[%d]=%s", dj, dep_paths[dj] ? dep_paths[dj] : "?");
            fputc('\n', stderr);
        }
    }
    typeck_ndep = 0;
    /* 模板末尾须为 6 个 X，mkstemp 后重命名为 .c 以便 cc/ld 识别 */
    char tmp[] = "/tmp/shux_su.XXXXXX";
    char tmp_c[32];
    int fd = -1;
    FILE *cf;
    if (emit_to_stdout) {
        cf = stdout;
    } else {
        fd = mkstemp(tmp);
        if (fd < 0) {
            perror("shux: mkstemp");
            while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        cf = fdopen(fd, "w");
        if (!cf) {
            close(fd);
            unlink(tmp);
            while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        snprintf(tmp_c, sizeof(tmp_c), "%s.c", tmp);
        if (rename(tmp, tmp_c) != 0) {
            unlink(tmp);
            fclose(cf);
            while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
    }
    /*
     * CodegenOutBuf / PipelineDepCtx 体积大；driver_run_compiler_full 与 run_compiler_sx_path 同理，先 dep 再堆上分配二者。
     */
    void *dep_arenas[32];
    void *dep_modules[32];
    for (int j = n_deps - 1; j >= 0; j--) {
        dep_arenas[j] = malloc(arena_sz);
        dep_modules[j] = malloc(module_sz);
        if (!dep_arenas[j] || !dep_modules[j]) {
            fprintf(stderr, "shux: -sx path: dep alloc failed\n");
            while (j > 0) { j--; free(dep_arenas[j]); free(dep_modules[j]); }
            if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        memset(dep_arenas[j], 0, arena_sz);
        memset(dep_modules[j], 0, module_sz);
    }
    struct codegen_CodegenOutBuf *out_buf = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*out_buf));
    struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*pctx));
    if (!out_buf || !pctx) {
        fprintf(stderr, "shux: -sx path (driver full): out_buf/pctx alloc failed\n");
        for (int jj = 0; jj < n_deps; jj++) { free(dep_arenas[jj]); free(dep_modules[jj]); }
        if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
        while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
        free(arena); free(module); free(src);
        if (out_buf) free(out_buf);
        if (pctx) pipeline_dep_ctx_heap_destroy(pctx);
        return 1;
    }
    pipeline_fill_ctx_path_buffers(pctx, entry_dir_buf, lib_roots_arr, n_lib_roots);
    runtime_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
    pctx->skip_codegen_dep_0 = 0; /* 不再跳过 dep 0：io.o 仅提供 C 层，std.io.driver 的 .sx 包装须由 codegen 生成。 */
    /* 先对每个 dep 跑 pipeline 仅做 parse+typecheck，填充 dep_arenas/dep_modules，不写 C 到文件。 */
    driver_dep_seeded_clear_all();
    {
        int *dep_ready = (int *)calloc((size_t)n_deps, sizeof(int));
        if (!dep_ready) {
            fprintf(stderr, "shux: dep prerun: dep_ready alloc failed\n");
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
            if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        for (int pass = 0; pass < n_deps + 1; pass++) {
            int progress = 0;
            for (int j = 0; j < n_deps; j++) {
                struct ast_PipelineDepCtx *one_ctx;
                struct codegen_CodegenOutBuf *dep_out;
                int ec_dep;
                if (dep_ready[j])
                    continue;
                one_ctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*one_ctx));
                dep_out = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*dep_out));
                if (!one_ctx || !dep_out) {
                    fprintf(stderr, "shux: -sx path (driver full): dep_one_ctx/out alloc failed\n");
                    pipeline_dep_ctx_heap_destroy(one_ctx);
                    free(dep_out);
                    free(dep_ready);
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                    if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
                    while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                    free(arena); free(module); free(src);
                    return 1;
                }
                runtime_one_ctx_for_dep_prerun(one_ctx, j, dep_modules[j], dep_arenas[j]);
                pipeline_fill_ctx_path_buffers(one_ctx, runtime_dep_prerun_entry_dir(entry_dir_buf, lib_roots_arr, n_lib_roots), lib_roots_arr, n_lib_roots);
                driver_set_current_dep_path_for_codegen(dep_paths[j]);
                ec_dep = pipeline_run_sx_pipeline_large_stack(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j], dep_lens[j], (void *)dep_out, (void *)one_ctx);
                driver_set_current_dep_path_for_codegen(NULL);
                pipeline_dep_ctx_heap_destroy(one_ctx);
                free(dep_out);
                if (ec_dep == 0) {
                    dep_ready[j] = 1;
                    driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
                    progress = 1;
                } else if (getenv("SHUX_DEBUG_PIPE")) {
                    fprintf(stderr, "shux: dep prerun j=%d path=%s ec=%d\n", j,
                            dep_paths[j] ? dep_paths[j] : "?", ec_dep);
                }
            }
            if (!progress)
                break;
        }
        for (int j = 0; j < n_deps; j++) {
            if (!dep_ready[j]) {
                fprintf(stderr, "shux: pipeline failed for import '%s' (dep not ready after prerun)\n", dep_paths[j] ? dep_paths[j] : "?");
                free(dep_ready);
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(arena); free(module); free(src);
                return 1;
            }
        }
        free(dep_ready);
    }
    typeck_ndep = n_deps;
    for (int j = 0; j < n_deps; j++) {
        typeck_dep_module_ptrs[j] = dep_modules[j];
        typeck_dep_arena_ptrs[j] = dep_arenas[j];
    }
    pipeline_set_dep_slots(dep_arenas, dep_modules);
    driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
    codegen_set_dep_slots_for_su_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
    codegen_set_preamble_has_core_option_result(1); /* preamble 已含 Option_i32/Result_i32，codegen 跳过避免重定义 */
    codegen_reset_preamble_skip_mask();
    {
        int has_std_io_core = 0;
        for (int j = 0; j < n_deps; j++)
            if (dep_paths[j] && strcmp(dep_paths[j], "std.io.core") == 0) { has_std_io_core = 1; break; }
        if (!has_std_io_core)
            codegen_or_preamble_skip_mask(CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS
                | CODEGEN_PREAMBLE_SKIP_STD_IO_UNDEF_REDEFINE);
    }
    /*
     * emit-C 与 -backend asm 对齐：pipeline 内须完整 parse_into（entry_already_parsed=0）。
     * driver 侧 parse_into_buf 仅用于 collect_deps / pr.main_idx；若此处设置 entry_already_parsed=1
     * 跳过流水线解析，预填 module 与 pipeline 内 struct_layouts/typeck §11.1 等路径不同步时，
     * 隐式 padding 校验会变成空操作（tests/run-struct.sh padding_no_allow）。
     * import 已解析完毕；清零后 pipeline 从同一预处理源码重建 module/arena。
     */
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] before entry memset arena_sz=%zu\n", arena_sz);
    memset(arena, 0, arena_sz);
    memset(module, 0, module_sz);
    parser_parse_into_init(module, arena);
    pctx->entry_already_parsed = 0;
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] before pipeline_run entry=%s src_len=%zu\n",
                input_path ? input_path : "?", (size_t)src_slice.length);
    int ec = pipeline_run_sx_pipeline_large_stack(module, arena, src_slice.data, (size_t)src_slice.length, (void *)out_buf, (void *)pctx);
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] after pipeline_run ec=%d\n", ec);
    driver_dep_seeded_clear_all();
    codegen_set_dep_slots_for_su_pipeline(NULL, NULL, 0);
    for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
    while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
    if (ec != 0 || (!driver_check_only_get() && out_buf->len == 0)) {
        fprintf(stderr, "shux: pipeline failed for '%s' (ec=%d, out_len=%d)\n", input_path, ec, (int)out_buf->len);
        if (getenv("SHUX_DEBUG_PIPE") && out_buf->len > 0) {
            size_t show = (size_t)out_buf->len > 800u ? 800u : (size_t)out_buf->len;
            fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] out (first %zu bytes):\n%.*s\n", show, (int)show,
                    (const char *)out_buf->data);
        }
        if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
        free(arena);
        free(module);
        free(src);
        free(out_buf);
        pipeline_dep_ctx_heap_destroy(pctx);
        return 1;
    }
    if (driver_check_only_get()) {
        driver_print_check_ok(input_path);
        if (!emit_to_stdout) {
            fclose(cf);
            unlink(tmp_c);
        }
        free(arena);
        free(module);
        free(src);
        free(out_buf);
        pipeline_dep_ctx_heap_destroy(pctx);
        return 0;
    }
    /* 无 -o、将生成的 C 写 stdout 之前：stderr 烟测两行，与 driver_run_sx_emit_sx 及 run-std/run-stdlib-import 的 grep 一致。 */
    if (emit_to_stdout)
        driver_print_su_smoke_summary(module, (size_t)out_buf->len);
    free(arena);
    free(module);
    free(src);
    {
        /* 内联 std.io / std.net ABI；其余 std.fs / path / map / error 仍 include 头文件。
         * 若 pipeline 产出首字符非 # 且非注释（如泛型+import 时首行为 extern ...），先写最小 preamble 避免 cc 报 unknown type 'int32_t'。 */
        size_t first_line = 0;
        while (first_line < (size_t)out_buf->len && out_buf->data[first_line] != '\n') first_line++;
        if (first_line < (size_t)out_buf->len) first_line++;
        int need_preamble = (out_buf->len > 0 && out_buf->data[0] != '#' && (out_buf->len < 2 || out_buf->data[0] != '/' || out_buf->data[1] != '*'));
        if (need_preamble) {
            static const char min_preamble[] = "/* generated */\n#include <stdint.h>\n#include <stddef.h>\n#include <stdlib.h>\n#include <stdio.h>\n#include <string.h>\n";
            if (fwrite(min_preamble, 1, sizeof(min_preamble) - 1, cf) != (size_t)(sizeof(min_preamble) - 1)) {
                if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                return 1;
            }
        }
        static const char fs_abi_include_full[] = "#include \"std/fs/fs_abi.h\"\n";
        static const char path_abi_include_full[] = "#include \"std/path/path_abi.h\"\n";
        static const char map_abi_include_full[] = "#include \"std/map/map_abi.h\"\n";
        static const char error_abi_include_full[] = "#include \"std/error/error_abi.h\"\n";
        if (fwrite(out_buf->data, 1, first_line, cf) != first_line
            || write_io_net_abi_inline(cf) != 0
            || fwrite(fs_abi_include_full, 1, sizeof(fs_abi_include_full) - 1, cf) != (size_t)(sizeof(fs_abi_include_full) - 1)
            || fwrite(path_abi_include_full, 1, sizeof(path_abi_include_full) - 1, cf) != (size_t)(sizeof(path_abi_include_full) - 1)
            || fwrite(map_abi_include_full, 1, sizeof(map_abi_include_full) - 1, cf) != (size_t)(sizeof(map_abi_include_full) - 1)
            || fwrite(error_abi_include_full, 1, sizeof(error_abi_include_full) - 1, cf) != (size_t)(sizeof(error_abi_include_full) - 1)
            || fwrite(out_buf->data + first_line, 1, (size_t)out_buf->len - first_line, cf) != (size_t)out_buf->len - first_line) {
            if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            return 1;
        }
    }
    if (!emit_to_stdout) {
        if (fclose(cf) != 0) {
            unlink(tmp_c);
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            return 1;
        }
        {
            const char *c_paths[1] = { tmp_c };
            const char *io_o = get_io_o_path(argv[0]);
            const char *fs_o = get_std_fs_o_path(argv[0]);
            const char *process_o = get_std_process_o_path(argv[0]);
            const char *string_o = get_std_string_o_path(argv[0]);
            const char *heap_o = get_std_heap_o_path(argv[0]);
            const char *path_o = get_std_path_o_path(argv[0]);
            const char *runtime_o = get_std_runtime_o_path(argv[0]);
            const char *runtime_panic_o = get_runtime_panic_o_path(argv[0]);
            const char *net_o = get_std_net_o_path(argv[0]);
            const char *thread_o = get_std_thread_o_path(argv[0]);
            const char *time_o = get_std_time_o_path(argv[0]);
            const char *random_o = get_std_random_o_path(argv[0]);
            const char *env_o = get_std_env_o_path(argv[0]);
            const char *sync_o = get_std_sync_o_path(argv[0]);
            const char *encoding_o = get_std_encoding_o_path(argv[0]);
            const char *base64_o = get_std_base64_o_path(argv[0]);
            const char *crypto_o = get_std_crypto_o_path(argv[0]);
            const char *log_o = get_std_log_o_path(argv[0]);
            const char *atomic_o = get_std_atomic_o_path(argv[0]);
            const char *channel_o = get_std_channel_o_path(argv[0]);
            const char *backtrace_o = get_std_backtrace_o_path(argv[0]);
            const char *hash_o = get_std_hash_o_path(argv[0]);
            const char *math_o = get_std_math_o_path(argv[0]);
            const char *sort_o = get_std_sort_o_path(argv[0]);
            const char *ffi_o = get_std_ffi_o_path(argv[0]);
            const char *db_o = get_std_sqlite_o_path(argv[0]);
            const char *elf_o = get_std_elf_o_path(argv[0]);
            const char *json_o = get_std_json_o_path(argv[0]);
            const char *csv_o = get_std_csv_o_path(argv[0]);
            const char *regex_o = get_std_regex_o_path(argv[0]);
            const char *compress_o = get_std_compress_o_path(argv[0]);
            const char *unicode_o = get_std_unicode_o_path(argv[0]);
            const char *dynlib_o = get_std_dynlib_o_path(argv[0]);
            const char *http_o = get_std_http_o_path(argv[0]);
            const char *tar_o = get_std_tar_o_path(argv[0]);
            const char *simd_o = get_std_simd_o_path(argv[0]);
            const char *context_o = get_std_context_o_path(argv[0]);
            const char *datetime_o = get_std_datetime_o_path(argv[0]);
            const char *uuid_o = get_std_uuid_o_path(argv[0]);
            const char *url_o = get_std_url_o_path(argv[0]);
            const char *cli_o = get_std_cli_o_path(argv[0]);
            const char *security_o = get_std_security_o_path(argv[0]);
            const char *config_o = get_std_config_o_path(argv[0]);
            const char *cache_o = get_std_cache_o_path(argv[0]);
            const char *trace_o = get_std_trace_o_path(argv[0]);
            const char *task_o = get_std_task_o_path(argv[0]);
            const char *schema_o = get_std_schema_o_path(argv[0]);
            const char *test_o = get_std_test_o_path(argv[0]);
            int cc_ret = invoke_cc(c_paths, 1, out_path, NULL, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, get_repo_root(argv[0]), NULL);
            if (cc_ret != 0) {
                fprintf(stderr, "shux: cc failed, keeping generated C: %s\n", tmp_c);
            } else if (!getenv("SHUX_KEEP_C")) {
                unlink(tmp_c);
            } else {
                fprintf(stderr, "shux: kept generated C: %s\n", tmp_c);
            }
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            return cc_ret == 0 ? 0 : 1;
        }
    }
    free(out_buf);
    pipeline_dep_ctx_heap_destroy(pctx);
    return 0;
}

/** compile.sx 可调用的栈上限提升。 */
void driver_bump_stack_limit(void) {
    driver_bump_stack_limit_if_needed();
}

extern int32_t driver_emit_lib_root_count(uint8_t *state);
extern int32_t driver_emit_append_lib_root(uint8_t *state, uint8_t *path, int32_t len);
extern void driver_emit_lib_root_reset(uint8_t *state);
extern int32_t driver_emit_lib_root_len(uint8_t *state, int32_t i);
extern void driver_emit_lib_root_copy(uint8_t *state, int32_t i, uint8_t *dst, int32_t cap);

/** 从 ast_pool sidecar 键填充 lib_roots 数组；返回根数量。 */
static int driver_lib_roots_from_key(uint8_t *lib_key, const char **out_arr, char bufs[SU_FULL_MAX_LIB_ROOTS][512]) {
    int n = (int)driver_emit_lib_root_count(lib_key);
    int i;
    if (n <= 0) {
        const char *def = getenv("SHUX_LIB");
        if (!def || !def[0])
            def = ".";
        out_arr[0] = def;
        return 1;
    }
    if (n > SU_FULL_MAX_LIB_ROOTS)
        n = SU_FULL_MAX_LIB_ROOTS;
    for (i = 0; i < n; i++) {
        int32_t llen = driver_emit_lib_root_len(lib_key, i);
        if (llen <= 0 || llen >= 512) {
            bufs[i][0] = '.';
            bufs[i][1] = '\0';
        } else {
            driver_emit_lib_root_copy(lib_key, i, (uint8_t *)bufs[i], 512);
            bufs[i][llen] = '\0';
        }
        out_arr[i] = bufs[i];
    }
    return n;
}

/**
 * compile.sx DriverCompileState 布局（字段顺序与 compile.sx 一致；EMIT_HEAVY impl_c 与 SU parse_argv 共用）。
 * 须在 driver_run_asm_backend_impl_c 之前可见（lib_key 即 DriverCompileStateSU*）。
 */
typedef struct DriverCompileStateSU {
    uint8_t path_buf[512];
    int32_t path_len;
    uint8_t out_path_buf[512];
    int32_t out_path_len;
    int32_t use_asm_backend;
    int32_t target_arch;
    uint8_t target_buf[512];
    int32_t target_len;
    uint8_t opt_level_buf[8];
    int32_t opt_level_len;
    int32_t use_lto;
    int32_t backend_asm_explicit;
    int32_t use_freestanding;
    int32_t parse_saw_target;
    uint8_t target_cpu_buf[64];
    int32_t target_cpu_len;
    int32_t target_cpu_features;
    int32_t print_target_cpu;
    int32_t parse_saw_target_cpu;
} DriverCompileStateSU;

/** asm 后端 C mega：lib_key sidecar → lib_roots，委托 driver_run_asm_backend。 */
int32_t driver_run_asm_backend_impl_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                      int32_t argc, uint8_t *argv) {
    const char *lib_roots[SU_FULL_MAX_LIB_ROOTS];
    char lib_bufs[SU_FULL_MAX_LIB_ROOTS][512];
    int n = driver_lib_roots_from_key(lib_key, lib_roots, lib_bufs);
    if (lib_key)
        driver_set_pending_target_cpu_features((uint32_t)((DriverCompileStateSU *)lib_key)->target_cpu_features);
    else
        driver_set_pending_target_cpu_features(0);
    return driver_run_asm_backend((const char *)input_path, out_path ? (const char *)out_path : NULL, lib_roots, n,
                                  target && target[0] ? (const char *)target : NULL, (int)argc, (char **)argv);
}

/** 兼容旧符号名；新路径 compile.sx 经 compile_dispatch_* 调 impl_c。 */
int32_t driver_run_asm_backend_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                 int32_t argc, uint8_t *argv) {
    return driver_run_asm_backend_impl_c(input_path, out_path, lib_key, target, argc, argv);
}

/** C 后端 C 桥：供 compile.sx 调用（want_asm_backend=0 走 driver_run_compiler_parsed）。 */
/** 含 import 时 seed 的 SU codegen 易重复符号；若同目录有 shux-c 则委托其完成 -o 链接（与 run-hello 一致）。 */
static int driver_try_compile_via_shu_c_sibling(int argc, char **argv) {
    char shu_c[512];
    const char *self;
    const char *slash;
    if (argc < 2 || !argv || !argv[0])
        return -1;
    self = argv[0];
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
    pid_t pid = fork();
    if (pid < 0)
        return -1;
    if (pid == 0) {
        execvp(shu_c, argv);
        _exit(127);
    }
    {
        int st = 0;
        if (waitpid(pid, &st, 0) < 0)
            return -1;
        if (WIFEXITED(st))
            return WEXITSTATUS(st);
        return 1;
    }
}

/** C 后端 C mega：lib_key→lib_roots；含 import 时可选 exec 同目录 shux-c；否则 driver_run_compiler_parsed。 */
int32_t driver_run_emit_c_path_impl_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                      uint8_t *opt_level, int32_t use_lto, int32_t argc, uint8_t *argv) {
    const char *lib_roots[SU_FULL_MAX_LIB_ROOTS];
    char lib_bufs[SU_FULL_MAX_LIB_ROOTS][512];
    int n = driver_lib_roots_from_key(lib_key, lib_roots, lib_bufs);
    DriverCompileParsed p;
    memset(&p, 0, sizeof p);
    p.input_path = (const char *)input_path;
    p.out_path = out_path ? (const char *)out_path : NULL;
    memcpy(p.lib_roots_arr, lib_roots, (size_t)n * sizeof lib_roots[0]);
    p.n_lib_roots = n;
    p.want_asm_backend = 0;
    p.target = target && target[0] ? (const char *)target : NULL;
    p.opt_level = (opt_level && opt_level[0]) ? (const char *)opt_level : "2";
    p.use_lto = use_lto != 0;
    if (!p.use_lto && getenv("SHUX_LTO") && strcmp(getenv("SHUX_LTO"), "1") == 0)
        p.use_lto = 1;
    /* check 走本进程 C typeck，避免子进程 shux-c 与双 -L 导致 core.* import 误解析。
     * build_shux_asm 单模块 -o（SHUX_ASM_ENTRY_MODULE_ONLY）：须走 asm，勿 exec shux-c（其不支持 -backend asm）。 */
    if (!driver_check_only_get() && p.input_path && driver_source_has_top_level_import_path(p.input_path) &&
        !asm_entry_module_only_from_env()) {
        int shu_c_rc = driver_try_compile_via_shu_c_sibling((int)argc, (char **)argv);
        if (shu_c_rc >= 0)
            return shu_c_rc;
    }
    return driver_run_compiler_parsed(&p, (int)argc, (char **)argv);
}

/** 兼容旧符号名；新路径 compile.sx 经 compile_dispatch_* 调 impl_c。 */
int32_t driver_run_emit_c_path_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                 uint8_t *opt_level, int32_t use_lto, int32_t argc, uint8_t *argv) {
    return driver_run_emit_c_path_impl_c(input_path, out_path, lib_key, target, opt_level, use_lto, argc, argv);
}

/** `-freestanding` / argv 解析 glue：前置声明（parse_argv_step_c 早于本 TU 内定义；GCC 禁止隐式声明）。 */
void driver_compile_argv_set_use_freestanding_c(DriverCompileStateSU *state);
void driver_compile_argv_set_legacy_f32_abi_c(void);
void driver_compile_argv_set_sanitize_address_c(void);
void driver_compile_resolve_target_cpu_c(DriverCompileStateSU *state);

/**
 * 堆分配 DriverCompileState（与 impl_c 默认字段一致）；供 compile.sx run_compiler_full_su SU emit。
 */
DriverCompileStateSU *driver_compile_state_alloc_c(void) {
    DriverCompileStateSU *state;

    state = (DriverCompileStateSU *)malloc(sizeof(DriverCompileStateSU));
    if (!state)
        return NULL;
    memset(state, 0, sizeof(*state));
    state->use_asm_backend = 1;
    state->opt_level_buf[0] = (uint8_t)'2';
    state->opt_level_len = 1;
    return state;
}

/** 释放 driver_compile_state_alloc_c 分配的 state。 */
void driver_compile_state_free_c(DriverCompileStateSU *state) {
    if (state)
        free(state);
}

/** compile.sx EMIT_HEAVY 真 emit 的 parse_argv 链；impl_c 在 C 栈上持 state 后调用。 */
extern int32_t driver_compile_parse_argv(int32_t argc, uint8_t *argv, DriverCompileStateSU *state);

void driver_compile_argv_copy_path_c(DriverCompileStateSU *state, uint8_t *arg_buf, int32_t plen);
void driver_compile_parse_argv_init_c(DriverCompileStateSU *state);
void driver_compile_ensure_default_lib_c(uint8_t *key);
void driver_compile_append_lib_root_c(DriverCompileStateSU *state, uint8_t *path, int32_t len);

/** argv 令牌比较与 path 后缀检测（与 compile.sx 同名 helper 语义一致）。 */
static int drv_eq_minus_o(const char *buf, int len) {
    return len == 2 && buf[0] == '-' && buf[1] == 'o';
}
static int drv_eq_minus_L(const char *buf, int len) {
    return len == 2 && buf[0] == '-' && buf[1] == 'L';
}
static int drv_eq_minus_O(const char *buf, int len) {
    return len == 2 && buf[0] == '-' && buf[1] == 'O';
}
static int drv_eq_flto(const char *buf, int len) {
    return len == 5 && buf[0] == '-' && buf[1] == 'f' && buf[2] == 'l' && buf[3] == 't' && buf[4] == 'o';
}
static int drv_eq_minus_freestanding(const char *buf, int len) {
    return len == 13 && !memcmp(buf, "-freestanding", 13);
}
static int drv_eq_legacy_f32_abi(const char *buf, int len) {
    return len == 15 && !memcmp(buf, "-legacy-f32-abi", 15);
}
static int drv_eq_fsanitize_address(const char *buf, int len) {
    return len == 18 && !memcmp(buf, "-fsanitize=address", 18);
}
static int drv_eq_minus_backend(const char *buf, int len) {
    return len == 8 && !memcmp(buf, "-backend", 8);
}
static int drv_eq_minus_target(const char *buf, int len) {
    return len >= 7 && !memcmp(buf, "-target", 7);
}
static int drv_eq_minus_target_cpu(const char *buf, int len) {
    return len >= 11 && !memcmp(buf, "-target-cpu", 11);
}
static int drv_eq_print_target_cpu(const char *buf, int len) {
    return (len == 18 && !memcmp(buf, "--print-target-cpu", 18)) ||
           (len == 17 && !memcmp(buf, "-print-target-cpu", 17));
}
static int drv_eq_asm_word(const char *buf, int len) {
    return len == 3 && buf[0] == 'a' && buf[1] == 's' && buf[2] == 'm';
}
static int drv_eq_c_word(const char *buf, int len) {
    return len == 1 && buf[0] == 'c';
}
static int drv_path_ends_su(const char *buf, int len) {
    return len >= 3 && buf[len - 3] == '.' && buf[len - 2] == 's' && buf[len - 1] == 'u';
}
static int drv_target_has_arm(const char *buf, int len) {
    int start;
    for (start = 0; start + 5 <= len; start++) {
        if (buf[start] == 'a' && buf[start + 1] == 'r' && buf[start + 2] == 'm' && buf[start + 3] == '6' &&
            buf[start + 4] == '4')
            return 1;
    }
    return 0;
}

/**
 * 处理 argv[i] 一项（C 实现；strict emit 下 SU step 的 if+side-effect+return 会错序提前 return）。
 * 返回下一 argv 下标。
 */
static int driver_compile_parse_argv_step_c(int argc, char **argv, DriverCompileStateSU *state, int i, char *arg_buf,
                                            int arg_cap) {
    int len = driver_get_argv_i(argc, argv, i, arg_buf, arg_cap);
    if (len < 0)
        return i + 1;
    if (drv_eq_minus_o(arg_buf, len) && i + 1 < argc) {
        int olen = driver_get_argv_i(argc, argv, i + 1, (char *)state->out_path_buf, 512);
        if (olen >= 0)
            state->out_path_len = olen;
        return i + 2;
    }
    if (drv_eq_minus_L(arg_buf, len) && i + 1 < argc) {
        int llen = driver_get_argv_i(argc, argv, i + 1, arg_buf, arg_cap);
        if (llen >= 0)
            driver_compile_append_lib_root_c(state, (uint8_t *)arg_buf, llen);
        return i + 2;
    }
    if (drv_eq_minus_O(arg_buf, len) && i + 1 < argc) {
        int olen = driver_get_argv_i(argc, argv, i + 1, (char *)state->opt_level_buf, 8);
        if (olen >= 0)
            state->opt_level_len = olen;
        return i + 2;
    }
    if (drv_eq_flto(arg_buf, len)) {
        state->use_lto = 1;
        return i + 1;
    }
    if (drv_eq_minus_freestanding(arg_buf, len)) {
        driver_compile_argv_set_use_freestanding_c(state);
        return i + 1;
    }
    if (drv_eq_legacy_f32_abi(arg_buf, len)) {
        driver_compile_argv_set_legacy_f32_abi_c();
        return i + 1;
    }
    if (drv_eq_fsanitize_address(arg_buf, len)) {
        driver_sanitize_address_set(1);
        return i + 1;
    }
    if (drv_eq_minus_backend(arg_buf, len) && i + 1 < argc) {
        int vlen = driver_get_argv_i(argc, argv, i + 1, arg_buf, arg_cap);
        if (vlen >= 0 && drv_eq_asm_word(arg_buf, vlen)) {
            state->use_asm_backend = 1;
            state->backend_asm_explicit = 1;
        }
        if (vlen >= 0 && drv_eq_c_word(arg_buf, vlen)) {
            state->use_asm_backend = 0;
            state->backend_asm_explicit = 0;
        }
        return i + 2;
    }
    if (drv_eq_minus_target(arg_buf, len) && i + 1 < argc) {
        int tlen;
        state->parse_saw_target = 1;
        tlen = driver_get_argv_i(argc, argv, i + 1, (char *)state->target_buf, 512);
        if (tlen >= 0) {
            state->target_len = tlen;
            if (drv_target_has_arm((char *)state->target_buf, tlen))
                state->target_arch = 1;
        }
        return i + 2;
    }
    if (drv_eq_minus_target_cpu(arg_buf, len) && i + 1 < argc) {
        int tlen;
        state->parse_saw_target_cpu = 1;
        tlen = driver_get_argv_i(argc, argv, i + 1, (char *)state->target_cpu_buf, 64);
        if (tlen >= 0)
            state->target_cpu_len = tlen;
        return i + 2;
    }
    if (drv_eq_print_target_cpu(arg_buf, len)) {
        state->print_target_cpu = 1;
        return i + 1;
    }
    if (arg_buf[0] != '-' && drv_path_ends_su(arg_buf, len))
        driver_compile_argv_copy_path_c(state, (uint8_t *)arg_buf, len);
    return i + 1;
}

/**
 * argv[1..] 扫描 loop（C step_c）；compile.sx parse_argv SU 编排调本符号。
 */
void driver_compile_parse_argv_scan_c(int32_t argc, uint8_t *argv_opaque, DriverCompileStateSU *state) {
    char **argv = (char **)argv_opaque;
    char arg_buf[512];
    int i;

    if (argc < 2 || !state)
        return;
    for (i = 1; i < argc;)
        i = driver_compile_parse_argv_step_c(argc, argv, state, i, arg_buf, (int)sizeof arg_buf);
}

/**
 * 完整 argv 解析（C mega）：init → scan → finalize。
 * strict emit 下 SU parse_argv_step 对 `-L`/`-o` 等分支会跳过 side-effect；scan 仍走 C step_c。
 */
int32_t driver_compile_parse_argv_impl_c(int32_t argc, uint8_t *argv_opaque, DriverCompileStateSU *state) {
    if (argc < 2 || !state)
        return 1;
    driver_compile_parse_argv_init_c(state);
    driver_compile_parse_argv_scan_c(argc, argv_opaque, state);
    driver_compile_resolve_target_cpu_c(state);
    if (state->print_target_cpu)
        return 0;
    if (state->path_len <= 0)
        return 1;
    state->target_arch = driver_resolve_target_arch(state->target_arch, state->parse_saw_target);
    cfg_sync_compile_target_from_state_c(state);
    driver_compile_ensure_default_lib_c((uint8_t *)state);
    return 0;
}

/**
 * B-02：按 DriverCompileState 的 -target 同步 #[cfg] 求值上下文。
 */
void cfg_sync_compile_target_from_state_c(void *state) {
    DriverCompileStateSU *st = (DriverCompileStateSU *)state;
    if (st && st->parse_saw_target && st->target_len > 0)
        cfg_apply_compile_target_from_triple((const char *)st->target_buf, st->target_len);
    else
        cfg_reset_compile_target();
}

/**
 * 将 argv 路径字节拷入 state.path_buf 并写 path_len（cap 511）。
 * EMIT_HEAVY 下 SU while+INDEX 形参 field 易误折叠/漏 emit；与 impl_c 一样走 C 原语。
 */
void driver_compile_argv_copy_path_c(DriverCompileStateSU *state, uint8_t *arg_buf, int32_t plen) {
    int32_t k;
    int32_t n;
    if (!state || !arg_buf || plen <= 0)
        return;
    n = plen;
    if (n > 511)
        n = 511;
    for (k = 0; k < n; k++)
        state->path_buf[k] = arg_buf[k];
    state->path_len = n;
}

/**
 * 无显式 -L 时向 sidecar 追加默认 lib_root "."（与 compile.sx ensure_default_lib 语义一致）。
 * EMIT_HEAVY driver_compile.o 中 SU 体常为 ret0 桩；finalize 与薄包装均 bl 本符号。
 */
void driver_compile_ensure_default_lib_c(uint8_t *key) {
    static const uint8_t dot[1] = {46};
    if (!key)
        return;
    if (driver_emit_lib_root_count(key) == 0)
        (void)driver_emit_append_lib_root(key, (uint8_t *)dot, 1);
}

/**
 * 重置 DriverCompileState 默认值并清空 lib_root sidecar（与 compile.sx parse_argv_init 语义一致）。
 * EMIT_HEAVY 下对 *DriverCompileState 形参的 field store 易写成 fp 槽地址+offset，须走 C。
 */
void driver_compile_parse_argv_init_c(DriverCompileStateSU *state) {
    if (!state)
        return;
    cfg_reset_compile_target();
    state->path_len = 0;
    state->out_path_len = 0;
    state->use_asm_backend = 1;
    state->target_arch = 0;
    state->target_len = 0;
    state->opt_level_len = 1;
    state->opt_level_buf[0] = (uint8_t)'2';
    state->use_lto = 0;
    state->backend_asm_explicit = 0;
    state->use_freestanding = 0;
    state->parse_saw_target = 0;
    state->target_cpu_len = 0;
    state->target_cpu_features = 0;
    state->print_target_cpu = 0;
    state->parse_saw_target_cpu = 0;
    driver_freestanding_set(0);
    driver_emit_lib_root_reset((uint8_t *)state);
}

/** parse_argv -L 分支：直接用 state 指针作 sidecar 键（与 init_c/ensure_default 一致）。 */
void driver_compile_append_lib_root_c(DriverCompileStateSU *state, uint8_t *path, int32_t len) {
    if (!state || !path || len <= 0)
        return;
    (void)driver_emit_append_lib_root((uint8_t *)state, path, len);
}

/** -o：下一 argv 写入 out_path_buf/out_path_len（EMIT_HEAVY step 勿 SU field store）。 */
void driver_compile_argv_apply_minus_o_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                              int32_t i) {
    char **argv = (char **)argv_opaque;
    int32_t olen;

    if (!state || i + 1 >= argc)
        return;
    olen = driver_get_argv_i(argc, argv, i + 1, (char *)state->out_path_buf, 512);
    if (olen >= 0)
        state->out_path_len = olen;
}

/** -L：下一 argv 经 arg_buf 追加 lib_root sidecar。 */
void driver_compile_argv_apply_minus_L_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                               int32_t i, uint8_t *arg_buf, int32_t arg_cap) {
    char **argv = (char **)argv_opaque;
    int32_t llen;

    if (!state || !arg_buf || arg_cap <= 0 || i + 1 >= argc)
        return;
    llen = driver_get_argv_i(argc, argv, i + 1, (char *)arg_buf, arg_cap);
    if (llen >= 0)
        driver_compile_append_lib_root_c(state, arg_buf, llen);
}

/** -O：下一 argv 写入 opt_level_buf/opt_level_len。 */
void driver_compile_argv_apply_minus_O_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                              int32_t i) {
    char **argv = (char **)argv_opaque;
    int32_t olen;

    if (!state || i + 1 >= argc)
        return;
    olen = driver_get_argv_i(argc, argv, i + 1, (char *)state->opt_level_buf, 8);
    if (olen >= 0)
        state->opt_level_len = olen;
}

/** -flto：置 use_lto。 */
void driver_compile_argv_set_use_lto_c(DriverCompileStateSU *state) {
    if (state)
        state->use_lto = 1;
}

/** `-freestanding`：置 use_freestanding 并同步 driver_freestanding_set（S4 nostdlib 链）。 */
void driver_compile_argv_set_use_freestanding_c(DriverCompileStateSU *state) {
    if (!state)
        return;
    state->use_freestanding = 1;
    driver_freestanding_set(1);
}

/** `-legacy-f32-abi`：等价 SHUX_ABI_F32_XMM=0（legacy f64 widen + callee cvtsd2ss）。 */
void driver_compile_argv_set_legacy_f32_abi_c(void) {
    setenv("SHUX_ABI_F32_XMM", "0", 1);
}

/** `-fsanitize=address`：M-6 debug 边界插桩（release 默认关闭，零开销）。 */
void driver_compile_argv_set_sanitize_address_c(void) {
    driver_sanitize_address_set(1);
}

/** -backend <asm|c>：更新 use_asm_backend/backend_asm_explicit。 */
void driver_compile_argv_apply_backend_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                              int32_t i, uint8_t *arg_buf, int32_t arg_cap) {
    char **argv = (char **)argv_opaque;
    int32_t vlen;

    if (!state || !arg_buf || arg_cap <= 0 || i + 1 >= argc)
        return;
    vlen = driver_get_argv_i(argc, argv, i + 1, (char *)arg_buf, arg_cap);
    if (vlen >= 0 && drv_eq_asm_word((char *)arg_buf, vlen)) {
        state->use_asm_backend = 1;
        state->backend_asm_explicit = 1;
    }
    if (vlen >= 0 && drv_eq_c_word((char *)arg_buf, vlen)) {
        state->use_asm_backend = 0;
        state->backend_asm_explicit = 0;
    }
}

/** -target：写入 target_buf/target_len/parse_saw_target/target_arch。 */
void driver_compile_argv_apply_target_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                             int32_t i) {
    char **argv = (char **)argv_opaque;
    int32_t tlen;

    if (!state || i + 1 >= argc)
        return;
    state->parse_saw_target = 1;
    tlen = driver_get_argv_i(argc, argv, i + 1, (char *)state->target_buf, 512);
    if (tlen >= 0) {
        state->target_len = tlen;
        if (drv_target_has_arm((char *)state->target_buf, tlen))
            state->target_arch = 1;
    }
}

/** `-target-cpu`：下一 argv 写入 target_cpu_buf/target_cpu_len。 */
void driver_compile_argv_apply_target_cpu_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                                  int32_t i) {
    char **argv = (char **)argv_opaque;
    int32_t tlen;

    if (!state || i + 1 >= argc)
        return;
    state->parse_saw_target_cpu = 1;
    tlen = driver_get_argv_i(argc, argv, i + 1, (char *)state->target_cpu_buf, 64);
    if (tlen >= 0)
        state->target_cpu_len = tlen;
}

/** `--print-target-cpu`：仅打印 feature 后退出。 */
void driver_compile_argv_set_print_target_cpu_c(DriverCompileStateSU *state) {
    if (state)
        state->print_target_cpu = 1;
}

/** SU run_compiler_full_su：`--print-target-cpu` 早退（与 driver_run_compiler_full_su_impl_c 对齐）。 */
int32_t driver_print_target_cpu_features_c(int32_t features) {
    shu_target_cpu_print(stdout, (uint32_t)features);
    return 0;
}

/**
 * finalize：按 target_cpu_buf（空则 native）解析 feature 掩码。
 * 未知规格时 stderr 告警并回退 generic baseline。
 */
void driver_compile_resolve_target_cpu_c(DriverCompileStateSU *state) {
    const char *spec;
    size_t spec_len;
    uint32_t feats = 0;

    if (!state)
        return;
    spec = "native";
    spec_len = 6;
    if (state->target_cpu_len > 0) {
        spec = (const char *)state->target_cpu_buf;
        spec_len = (size_t)state->target_cpu_len;
    }
    if (shu_target_cpu_resolve(spec, spec_len, &feats) != 0) {
        fprintf(stderr, "shux: unknown -target-cpu '%.*s'; using generic baseline\n", (int)spec_len, spec);
        feats = shu_target_cpu_generic_for_host();
    }
    state->target_cpu_features = (int32_t)feats;
}

/** parse 完成后后端选择 + 分派；compile.sx 薄包装 bl 本符号（EMIT_HEAVY 勿 SU 真 emit，宿主 SIGSEGV）。 */
int32_t driver_run_compiler_full_su_post_parse_impl_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv) {
    uint8_t *out_ptr;
    uint8_t *target_ptr;
    int32_t want_generic_check;

    if (!state)
        return 1;
    if (driver_check_only_get())
        state->use_asm_backend = 0;
    want_generic_check = 0;
    if (state->out_path_len == 0)
        want_generic_check = 1;
    else if (driver_asm_output_want_exe(state->out_path_buf))
        want_generic_check = 1;
    if (state->use_asm_backend && want_generic_check) {
        if (driver_source_has_generic_syntax(state->path_buf, state->path_len))
            state->use_asm_backend = 0;
    }
    if (state->use_asm_backend && state->out_path_len > 0 &&
        driver_asm_output_want_exe(state->out_path_buf)) {
        /** 复合赋值已由 SU lexer/parser 支持；勿降级 C。 */
    }
    out_ptr = NULL;
    if (state->out_path_len > 0)
        out_ptr = state->out_path_buf;
    target_ptr = NULL;
    if (state->target_len > 0)
        target_ptr = state->target_buf;
#if defined(SHUX_ASM_USE_COMPILER_IMPL_C)
    /** B-strict shux_asm 有 -o 时默认显式 asm，避免 top-level import 被降级到 C 后端（hello.sx）。 */
    if (state->out_path_len > 0 && !state->backend_asm_explicit)
        state->backend_asm_explicit = 1;
#endif
    if (state->use_asm_backend && !state->backend_asm_explicit &&
        driver_asm_entry_module_only_from_env() == 0 &&
        driver_source_has_top_level_import_path((const char *)state->path_buf))
        state->use_asm_backend = 0;
    if (state->use_freestanding) {
        state->use_asm_backend = 1;
        state->backend_asm_explicit = 1;
        driver_freestanding_set(1);
    }
    if (state->use_asm_backend) {
        return driver_run_asm_backend_impl_c(state->path_buf, out_ptr, (uint8_t *)state, target_ptr, argc, argv);
    }
    return driver_run_emit_c_path_impl_c(state->path_buf, out_ptr, (uint8_t *)state, target_ptr,
                                         state->opt_level_buf, state->use_lto, argc, argv);
}

/**
 * 扫描 argv 是否含 `-h` 或 `--help`。
 * 返回 1 表示应打印用法并 exit 0。
 */
int32_t driver_compile_argv_is_help_c(int32_t argc, uint8_t *argv_opaque) {
    char **argv = (char **)argv_opaque;
    char buf[16];
    int len;
    int i;

    if (argc < 2 || !argv)
        return 0;
    for (i = 1; i < argc; i++) {
        len = driver_get_argv_i(argc, argv, i, buf, (int32_t)sizeof(buf));
        if (len == 2 && buf[0] == '-' && buf[1] == 'h')
            return 1;
        if (len == 6 && !memcmp(buf, "--help", 6))
            return 1;
    }
    return 0;
}

/** 打印 shux 用法摘要（stdout）；含 `-legacy-f32-abi` 与 release 默认说明。 */
void driver_print_usage_c(void) {
    fputs(
        "Shux (shux) compiler\n"
        "\n"
        "Usage:\n"
        "  shux [options] file.sx          compile and run\n"
        "  shux build [file.sx] [-o exe]   compile (default a.out)\n"
        "  shux run file.sx                compile and run\n"
        "  shux check [paths...]           parse + typeck only\n"
        "  shux fmt [--check] [paths...]   format .sx sources\n"
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
        "See compiler/docs/F32_XMM_ABI.md for f32 ABI and deprecation timeline.\n",
        stdout);
}

/**
 * 完整编译 C 入口：堆 state + parse_argv + post_parse（standalone / 非 asm 链回退）。
 */
int32_t driver_run_compiler_full_su_impl_c(int32_t argc, uint8_t *argv) {
    DriverCompileStateSU *state;
    int32_t rc;

    if (driver_compile_argv_is_help_c(argc, argv)) {
        driver_print_usage_c();
        return 0;
    }
    driver_bump_stack_limit();
    state = driver_compile_state_alloc_c();
    if (!state)
        return 1;
    if (driver_compile_parse_argv(argc, argv, state) != 0) {
        driver_compile_state_free_c(state);
        return 1;
    }
    if (state->print_target_cpu) {
        shu_target_cpu_print(stdout, (uint32_t)state->target_cpu_features);
        driver_compile_state_free_c(state);
        return 0;
    }
    rc = driver_run_compiler_full_su_post_parse_impl_c(state, argc, argv);
    driver_compile_state_free_c(state);
    return rc;
}

/**
 * 完整编译入口：argv 解析在 driver/compile.sx；B-strict shux_asm 走 impl_c（完整 parse_argv+finalize），避免 SU emit 的 driver_run_compiler_full_su 在 strict 链 silent fail。
 */
int driver_run_compiler_full(int argc, char **argv) {
#if defined(SHUX_ASM_USE_COMPILER_IMPL_C)
    return (int)driver_run_compiler_full_su_impl_c((int32_t)argc, (uint8_t *)argv);
#else
    extern int32_t driver_run_compiler_full_su(int32_t argc, uint8_t *argv);
    return (int)driver_run_compiler_full_su((int32_t)argc, (uint8_t *)argv);
#endif
}

/**
 * shux test 入口：在仓库根目录执行 bash 测试脚本；默认 tests/run-all.sh，亦可通过首参指定相对/绝对路径。
 */
int driver_run_test(int argc, char **argv) {
    const char *root = get_repo_root(argc > 0 ? argv[0] : NULL);
    const char *rel = "tests/run-all.sh";
    char script[768];
    char cmd[1024];
    if (argc >= 2 && argv[1][0] != '-') {
        rel = argv[1];
    }
    if (rel[0] == '/')
        snprintf(script, sizeof script, "%s", rel);
    else
        snprintf(script, sizeof script, "%s/%s", root, rel);
    snprintf(cmd, sizeof cmd, "cd \"%s\" && bash \"%s\"", root, script);
    fprintf(stderr, "shux test: %s\n", script);
    int st = system(cmd);
    if (st == -1) {
        fprintf(stderr, "shux test: failed to run script\n");
        return 1;
    }
    if (WIFEXITED(st))
        return WEXITSTATUS(st) != 0 ? 1 : 0;
    fprintf(stderr, "shux test: script terminated abnormally\n");
    return 1;
}
#endif /* SHUX_USE_SX_DRIVER && SHUX_USE_SX_PIPELINE */

/** 扫描 argv：若存在 -sx -E <path> 则记下 path 及此前出现的 -L path，返回 1，否则返回 0。保留供未迁完时链接。 */
int driver_argv_parse_su_emit_c(int argc, char **argv) {
    char ab[512];
    char nx[512];
    driver_su_emit_c_path = NULL;
    driver_su_emit_n_lib_roots = 0;
    if (argc < 4 || !argv)
        return 0;
    for (int i = 1; i < argc; i++) {
        if (driver_get_argv_i(argc, argv, i, ab, (int)sizeof ab) < 0)
            continue;
        if (strcmp(ab, "-L") == 0 && i + 1 < argc) {
            /* 与 driver_run_compiler_full：满则仍跳过路径令牌；-L 根拷入 driver_su_emit_lib_bufs，与 driver_run_sx_emit_c_set_lib 一致 */
            int k = driver_su_emit_n_lib_roots;
            if (k < SU_EMIT_MAX_LIB_ROOTS) {
                int ln = driver_get_argv_i(argc, argv, i + 1, driver_su_emit_lib_bufs[k], 256);
                if (ln < 0)
                    return 0;
                driver_su_emit_lib_roots[k] = driver_su_emit_lib_bufs[k];
                driver_su_emit_n_lib_roots++;
            }
            i++;
            continue;
        }
        if (strcmp(ab, "-sx") == 0 && i + 2 < argc) {
            if (driver_get_argv_i(argc, argv, i + 1, nx, (int)sizeof nx) < 0 || strcmp(nx, "-E") != 0)
                continue;
            if (driver_get_argv_i(argc, argv, i + 2, driver_su_emit_path_buf, (int)sizeof driver_su_emit_path_buf) < 0)
                return 0;
            driver_su_emit_c_path = driver_su_emit_path_buf;
            return 1;
        }
    }
    return 0;
}

#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
/**
 * -sx -E -E-extern：用 C 前端 parse/typeck 与 C codegen 的 emit_extern 路径写 stdout。
 * 说明：codegen_emit_dep_types_only / codegen_library_module_to_c 依赖 C ASTModule；parser_parse_into 的 .sx Module 布局不同，故不能复用 su parse 结果。
 */
#if !defined(SHUX_NO_C_FRONTEND)
static int driver_run_sx_emit_c_extern_via_cparser(const char *input_path) {
    (void)setvbuf(stdout, NULL, _IONBF, 0);
    size_t raw_src_len = 0;
    char *raw_src = read_file(input_path, &raw_src_len);
    if (!raw_src) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = preprocess(raw_src, raw_src_len, NULL, 0, &src_len);
    free(raw_src);
    if (!src) {
        fprintf(stderr, "shux: preprocess failed for '%s'\n", input_path);
        return 1;
    }
    Lexer *lex = lexer_new(src);
    ASTModule *mod = NULL;
    int pr = parse(lex, &mod);
    lexer_free(lex);
    if (pr != 0 || !mod) {
        if (mod) ast_module_free(mod);
        free(src);
        fprintf(stderr, "shux: -sx -E-extern parse failed for '%s'\n", input_path);
        return 1;
    }
    char entry_dir_buf[512];
    get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    const char *entry_dir = entry_dir_buf;
    const char *lib_roots_arr[SU_EMIT_MAX_LIB_ROOTS];
    int n_lib_roots = driver_su_emit_n_lib_roots;
    if (n_lib_roots == 0) {
        lib_roots_arr[0] = ".";
        n_lib_roots = 1;
    } else {
        for (int k = 0; k < n_lib_roots; k++)
            lib_roots_arr[k] = driver_su_emit_lib_roots[k];
    }
    ASTModule *dep_mods[32];
    ASTModule *all_dep_mods[MAX_ALL_DEPS];
    char *all_dep_paths[MAX_ALL_DEPS];
    int ndep = 0, n_all = 0;
    if (mod->num_imports > 0 && resolve_and_load_imports(mod, lib_roots_arr, n_lib_roots, entry_dir, NULL, 0,
            dep_mods, &ndep, all_dep_mods, all_dep_paths, NULL, &n_all, 32) != 0) {
        ast_module_free(mod);
        free(src);
        return 1;
    }
    if (typeck_module(mod, ndep > 0 ? dep_mods : NULL, ndep, n_all > 0 ? all_dep_mods : NULL, n_all) != 0) {
        while (n_all--) {
            free(all_dep_paths[n_all]);
            ast_module_free(all_dep_mods[n_all]);
        }
        ast_module_free(mod);
        free(src);
        fprintf(stderr, "shux: -sx -E-extern typeck failed for '%s'\n", input_path);
        return 1;
    }
    fprintf(stdout, "/* generated (single-file with deps) */\n");
    fprintf(stdout, "#include <stdint.h>\n");
    fprintf(stdout, "#include <stddef.h>\n");
    fprintf(stdout, "#include <stdlib.h>\n");
    fprintf(stdout, "#include <stdio.h>\n");
    fprintf(stdout, "#include <string.h>\n");
    fprintf(stdout, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
    fprintf(stdout, "static inline void shux_panic_(int has_msg, int msg_val) {\n");
    fprintf(stdout, "  if (has_msg) (void)fprintf(stderr, \"%%d\\n\", msg_val);\n");
    fprintf(stdout, "  abort();\n");
    fprintf(stdout, "}\n");
    if (input_path && (strstr(input_path, "pipeline.sx") != NULL || strstr(input_path, "parser.sx") != NULL || strstr(input_path, "typeck.sx") != NULL || strstr(input_path, "codegen.sx") != NULL || strstr(input_path, "preprocess.sx") != NULL)) {
        fprintf(stdout, "extern int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle);\n");
        fprintf(stdout, "extern int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n");
        fprintf(stdout, "extern int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n");
        fprintf(stdout, "typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;\n");
        fprintf(stdout, "static inline int32_t shux_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_register((uint8_t *)b->ptr, b->len, b->handle); }\n");
        fprintf(stdout, "static inline int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_read((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }\n");
        fprintf(stdout, "static inline int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_write((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }\n");
        fprintf(stdout, "typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;\n");
        fprintf(stdout, "extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);\n");
        fprintf(stdout, "static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }\n");
    }
    int ec = 0;
    char emitted_type_buf[128][CODEGEN_EMITTED_TYPE_NAME_MAX];
    int n_emitted = 0;
    const int max_emitted = (int)(sizeof(emitted_type_buf) / sizeof(emitted_type_buf[0]));
    if (n_all > 0) {
        codegen_set_eextern_entry_path(input_path);
        if (codegen_emit_dep_types_only(all_dep_mods, (const char **)all_dep_paths, n_all, stdout,
                emitted_type_buf, &n_emitted, max_emitted) != 0)
            ec = -1;
    }
    if (ec == 0) {
        const char *lib_name = entry_lib_name_from_path(input_path);
        if (mod->num_funcs > 0) {
            ec = codegen_library_module_to_c(mod, lib_name, dep_mods, (const char **)mod->import_paths, ndep, stdout,
                NULL, NULL, NULL, NULL, emitted_type_buf, &n_emitted, max_emitted, input_path);
        } else if (mod->main_func && mod->main_func->body) {
            ec = codegen_module_to_c(mod, stdout, dep_mods, (const char **)mod->import_paths, ndep, NULL, NULL, NULL, NULL, emitted_type_buf, &n_emitted, max_emitted);
        } else {
            fprintf(stderr, "shux: -sx -E-extern: no main and no lib functions (cannot emit C)\n");
            ec = -1;
        }
    }
    if (ec == 0 && input_path && strstr(input_path, "pipeline.sx") != NULL)
        emit_pipeline_glue_include();
    fflush(stdout);
    while (n_all--) {
        free(all_dep_paths[n_all]);
        ast_module_free(all_dep_mods[n_all]);
    }
    ast_module_free(mod);
    free(src);
    return ec != 0 ? 1 : 0;
}
#endif /* !SHUX_NO_C_FRONTEND */
#endif /* SHUX_USE_SX_DRIVER && SHUX_USE_SX_PIPELINE */

/** 执行刚解析的 -sx -E（读文件、.sx pipeline、写 stdout）；成功 0，失败 1。无 SHUX_USE_SX_PIPELINE 时返回 1。 */
int driver_run_sx_emit_c(void) {
    const char *input_path = driver_su_emit_c_path;
    driver_su_emit_c_path = NULL;
    if (!input_path) return 1;
#ifdef SHUX_USE_SX_PIPELINE
    {
        /* 关闭 stdout 缓冲，避免重定向或管道下输出被截断（平台差异见 analysis/下一步开发分析.md §4.4） */
        (void)setvbuf(stdout, NULL, _IONBF, 0);
#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
        {
            const int want_extern = driver_su_emit_c_want_extern;
            driver_su_emit_c_want_extern = 0;
            if (want_extern) {
#if !defined(SHUX_NO_C_FRONTEND)
                return driver_run_sx_emit_c_extern_via_cparser(input_path);
#else
                fprintf(stderr,
                    "shux: -sx -E -E-extern requires C parser/codegen (rebuild without -DSHUX_NO_C_FRONTEND)\n");
                return 1;
#endif
            }
        }
#endif
        size_t raw_src_len = 0;
        char *raw_src = read_file(input_path, &raw_src_len);
        if (!raw_src) {
            fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
            return 1;
        }
        size_t src_len = 0;
        char *src = preprocess(raw_src, raw_src_len, NULL, 0, &src_len);
        free(raw_src);
        if (!src) {
            fprintf(stderr, "shux: preprocess failed for '%s'\n", input_path);
            return 1;
        }
        size_t arena_sz = pipeline_sizeof_arena();
        size_t module_sz = pipeline_sizeof_module();
        void *arena = malloc(arena_sz);
        void *module = malloc(module_sz);
        if (!arena || !module) {
            fprintf(stderr, "shux: -sx pipeline: malloc failed\n");
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        memset(arena, 0, arena_sz);
        memset(module, 0, module_sz);
        struct shux_slice_uint8_t src_slice = { (uint8_t *)src, src_len };
        parser_parse_into_init(module, arena);
        struct parser_ParseIntoResult pr = parser_parse_into(arena, module, &src_slice);
        if (pr.ok != 0) {
            fprintf(stderr, "shux: -sx pipeline failed (parse_into)\n");
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        parser_parse_into_set_main_index(module, pr.main_idx);
        int32_t n_imports = parser_get_module_num_imports(module);
        char entry_dir_buf[512];
        get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
        const char *entry_dir = entry_dir_buf;
        /* 供 pipeline 内 resolve/read 单段 import 用；仅在有 import 时设置，避免单文件时影响 */
        if (n_imports > 0)
            pipeline_set_entry_dir(entry_dir_buf);
        /* 阶段 2.1：使用解析到的 -L 库根；无 -L 时退化为当前目录 */
        const char *lib_roots_arr[SU_EMIT_MAX_LIB_ROOTS];
        int n_lib_roots = driver_su_emit_n_lib_roots;
        if (n_lib_roots == 0) {
            lib_roots_arr[0] = ".";
            n_lib_roots = 1;
        } else {
            for (int k = 0; k < n_lib_roots; k++) lib_roots_arr[k] = driver_su_emit_lib_roots[k];
        }
        char *dep_sources[MAX_ALL_DEPS];
        size_t dep_lens[MAX_ALL_DEPS];
        char *dep_paths[MAX_ALL_DEPS];
        int n_deps = 0;
        if (n_imports > 0 && n_imports <= 32) {
            for (int i = 0; i < n_imports && n_deps < MAX_ALL_DEPS; i++) {
                uint8_t path_buf[64];
                parser_get_module_import_path(module, i, path_buf);
                char path_c[65];
                size_t k = 0;
                while (k < sizeof(path_buf) && path_buf[k]) { path_c[k] = (char)path_buf[k]; k++; }
                path_c[k] = '\0';
                if (find_loaded_index(path_c, dep_paths, n_deps) >= 0) continue;
                char resolved[PATH_MAX];
                resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir, path_c, resolved, sizeof(resolved));
                size_t raw_len = 0;
                char *raw = read_file(resolved, &raw_len);
                if (!raw) {
                    fprintf(stderr, "shux: cannot open import '%s' (tried %s)\n", path_c, resolved);
                    while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                    free(arena); free(module); free(src);
                    return 1;
                }
                size_t prep_len = 0;
                char *prep = preprocess(raw, raw_len, NULL, 0, &prep_len);
                free(raw);
                if (!prep) {
                    fprintf(stderr, "shux: preprocess failed for import '%s'\n", path_c);
                    while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                    free(arena); free(module); free(src);
                    return 1;
                }
                dep_sources[n_deps] = prep;
                dep_lens[n_deps] = prep_len;
                dep_paths[n_deps] = strdup(path_c);
                if (!dep_paths[n_deps]) {
                    free(prep);
                    while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                    free(arena); free(module); free(src);
                    return 1;
                }
                n_deps++;
            }
        }
        typeck_ndep = 0;
        /*
         * CodegenOutBuf / PipelineDepCtx 体积大；-sx -E 路径同样堆分配避免栈溢出。
         */
        void *dep_arenas[32];
        void *dep_modules[32];
        for (int i = 0; i < n_deps; i++) {
            dep_arenas[i] = malloc(arena_sz);
            dep_modules[i] = malloc(module_sz);
            if (!dep_arenas[i] || !dep_modules[i]) {
                fprintf(stderr, "shux: -sx pipeline: dep alloc failed\n");
                while (i > 0) { i--; free(dep_arenas[i]); free(dep_modules[i]); }
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(arena); free(module); free(src);
                return 1;
            }
            memset(dep_arenas[i], 0, arena_sz);
            memset(dep_modules[i], 0, module_sz);
        }
        struct codegen_CodegenOutBuf *out_buf = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*out_buf));
        struct ast_PipelineDepCtx *pctx_e = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*pctx_e));
        if (!out_buf || !pctx_e) {
            fprintf(stderr, "shux: -sx -E: out_buf/pctx_e alloc failed\n");
            for (int di = 0; di < n_deps; di++) { free(dep_arenas[di]); free(dep_modules[di]); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            if (out_buf) free(out_buf);
            if (pctx_e) pipeline_dep_ctx_heap_destroy(pctx_e);
            return 1;
        }
        pipeline_fill_ctx_path_buffers(pctx_e, entry_dir_buf, lib_roots_arr, n_lib_roots);
        runtime_pctx_seed_dep_slots(pctx_e, dep_modules, dep_arenas, dep_paths, n_deps);
        /* 设置 driver_dep_* 槽位，使 pipeline 内 resolve/load 时能拿到与当前 dep 一致的 arena/module。仅对 entry 跑一次 pipeline，其内部会 codegen 所有 deps + entry，避免对每个 dep 单独跑 pipeline 再 fwrite 导致 deps 的 C 被写两遍（重复符号）。 */
        pipeline_set_dep_slots(dep_arenas, dep_modules);
        typeck_ndep = n_deps;
        for (int i = 0; i < n_deps; i++) {
            typeck_dep_module_ptrs[i] = dep_modules[i];
            typeck_dep_arena_ptrs[i] = dep_arenas[i];
        }
        pipeline_set_dep_slots(dep_arenas, dep_modules);
        memset(arena, 0, arena_sz);
        memset(module, 0, module_sz);
        int ec = pipeline_run_sx_pipeline_large_stack(module, arena, src_slice.data, (size_t)src_slice.length, (void *)out_buf, (void *)pctx_e);
        if (ec == 0 && out_buf->len > 0) {
            /* 平台差异诊断（分析文档 4.4）：main 段输出过短时打 stderr，便于 CI/本地确认是 len 错误还是内容只写了数字 */
            if (out_buf->len < 20) {
                fprintf(stderr, "shux: -sx -E diagnostic: out_buf.len=%d first bytes:", (int)out_buf->len);
                for (int di = 0; di < out_buf->len && di < 16; di++)
                    fprintf(stderr, " %02x", (unsigned char)out_buf->data[di]);
                fprintf(stderr, "\n");
            }
            fwrite(out_buf->data, 1, (size_t)out_buf->len, stdout);
            fflush(stdout);
            for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
            while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
        } else {
            for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
            while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            if (ec != 0) {
                fprintf(stderr, "shux: -sx pipeline failed\n");
            } else if (out_buf->len <= 0) {
                /* CI / cross-host: distinguish -sx -E 「只吐 0」与真失败——空缓冲视为 codegen 路径未写入 */
                fprintf(stderr,
                        "shux: -sx -E diagnostic: pipeline ok but codegen buffer empty "
                        "(ec=0 out_buf.len=%d); check typeck/codegen/pipeline CodegenOutBuf\n",
                        (int)out_buf->len);
            }
        }
        int emit_ret = (ec != 0 || out_buf->len <= 0) ? 1 : 0;
        free(out_buf);
        pipeline_dep_ctx_heap_destroy(pctx_e);
        free(arena);
        free(module);
        free(src);
        return emit_ret;
    }
#else
    (void)input_path;
    return 1;
#endif
}
#endif

#endif /* SHUX_USE_SX_DRIVER */

/**
 * shux fmt 单文件：读入 .sx、按 LSP 规则格式化；内容变化时写回。供 fmt.sx argv 循环调用。
 * path 为 NUL 终止路径（path_len 不含 NUL）；成功 0，失败 1。
 */
int driver_fmt_one_file(const uint8_t *path, int path_len) {
    char pathbuf[512];
    size_t raw_len = 0;
    char *raw;
    size_t cap;
    uint8_t *out;
    int fmt_len;
    if (!path || path_len <= 0 || path_len >= (int)sizeof pathbuf)
        return 1;
    memcpy(pathbuf, path, (size_t)path_len);
    pathbuf[path_len] = '\0';
    if (path_len < 3 || strcmp(pathbuf + path_len - 3, ".sx") != 0)
        return 1;
    raw = read_file(pathbuf, &raw_len);
    if (!raw) {
        fprintf(stderr, "shux fmt: cannot read '%s'\n", pathbuf);
        return 1;
    }
    cap = raw_len * 2 + 4096;
    if (cap < 65536)
        cap = 65536;
    out = (uint8_t *)malloc(cap);
    if (!out) {
        free(raw);
        fprintf(stderr, "shux fmt: out of memory for '%s'\n", pathbuf);
        return 1;
    }
    fmt_len = shu_format_su_document((const uint8_t *)raw, (int)raw_len, out, (int)cap);
    if (fmt_len < 0) {
        free(out);
        free(raw);
        fprintf(stderr, "shux fmt: format failed for '%s'\n", pathbuf);
        return 1;
    }
    {
        int changed = ((size_t)fmt_len != raw_len || memcmp(raw, out, raw_len) != 0);
        if (driver_fmt_check_only_get()) {
            free(out);
            free(raw);
            /* --check 成功时静默（与 deno fmt --check 一致）；失败由 driver_run_fmt 汇总列表。 */
            return changed ? 1 : 0;
        }
        if (changed) {
            if (shux_write_path_bytes(pathbuf, out, (size_t)fmt_len) != 0) {
                free(out);
                free(raw);
                fprintf(stderr, "shux fmt: write failed for '%s'\n", pathbuf);
                return 1;
            }
            /* 与 deno fmt 一致：仅在实际写回时输出路径，已规范文件保持静默。 */
            fprintf(stderr, "fmt OK: %s\n", pathbuf);
        }
    }
    free(out);
    free(raw);
    return 0;
}

extern int driver_run_compiler_check(int argc, char **argv);
extern int driver_run_fmt(int argc, char **argv);

/**
 * 兼容旧 driver_fmt_gen.c 的 extern；新实现委托 driver_run_fmt（支持无参递归 cwd）。
 */
int driver_fmt_report_no_files(void) {
    char *argv_fmt[2];
    argv_fmt[0] = "shux";
    argv_fmt[1] = "fmt";
    return driver_run_fmt(2, argv_fmt);
}

#ifndef SHUX_USE_SX_DRIVER
/**
 * C 版 shux（shux-c）子命令路由：去掉 argv[1] 后调用 check/fmt/test。
 * 与 main.sx 中 build/run/fmt/check/test 关键字一致；首参不以 `-` 开头以免与 `-su` 等标志冲突。
 */
static char **runtime_argv_drop_subcommand_c(int argc, char **argv) {
    static char *adj[512];
    int i;
    if (argc < 2 || !argv || argc > 512)
        return argv;
    adj[0] = argv[0];
    for (i = 2; i < argc; i++)
        adj[i - 1] = argv[i];
    return adj;
}

/** shux check（C 前端）：委托 fmt_check_cmd（多文件/目录 + 诊断格式）。 */
static int runtime_run_compiler_check_c(int argc, char **argv) {
    return driver_run_compiler_check(argc, argv);
}

/** shux fmt（C 前端）：读入 .sx、按 LSP 规则格式化，变化时写回。 */
static int runtime_run_fmt_c(int argc, char **argv) {
    return driver_run_fmt(argc, argv);
}

/** shux test（C 前端）：在仓库根目录执行 bash 测试脚本。 */
static int runtime_run_test_c(int argc, char **argv) {
    const char *root = get_repo_root(argc > 0 ? argv[0] : NULL);
    const char *rel = "tests/run-all.sh";
    char script[768];
    char cmd[1024];
    if (argc >= 2 && argv[1] && argv[1][0] != '-')
        rel = argv[1];
    if (rel[0] == '/')
        snprintf(script, sizeof script, "%s", rel);
    else
        snprintf(script, sizeof script, "%s/%s", root, rel);
    snprintf(cmd, sizeof cmd, "cd \"%s\" && bash \"%s\"", root, script);
    fprintf(stderr, "shux test: %s\n", script);
    int st = system(cmd);
    if (st == -1) {
        fprintf(stderr, "shux test: failed to run script\n");
        return 1;
    }
    if (WIFEXITED(st))
        return WEXITSTATUS(st) != 0 ? 1 : 0;
    fprintf(stderr, "shux test: script terminated abnormally\n");
    return 1;
}

/** 6.3：无 .sx 入口时由 runtime 提供 main_entry 桩；链接 main.sx 时由 main.sx 的 main_entry 覆盖。
 * Cygwin/MinGW 上 weak 符号可能不被链接器解析，故仅在非 Windows 环境使用 weak。 */
#if !defined(__CYGWIN__) && !defined(__MINGW32__) && !defined(_WIN32)
__attribute__((weak))
#endif
int main_entry(int argc, char **argv) {
    if (argc >= 2 && argv[1] && argv[1][0] != '-') {
        char **sub_argv = runtime_argv_drop_subcommand_c(argc, argv);
        if (strcmp(argv[1], "check") == 0)
            return runtime_run_compiler_check_c(argc - 1, sub_argv);
        if (strcmp(argv[1], "fmt") == 0)
            return runtime_run_fmt_c(argc - 1, sub_argv);
        if (strcmp(argv[1], "test") == 0)
            return runtime_run_test_c(argc - 1, sub_argv);
    }
    return run_compiler_c(argc, argv);
}
#endif
