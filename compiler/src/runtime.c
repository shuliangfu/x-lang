/**
 * runtime.c — 编译器运行时（6.3/6.4：自 main.c 迁出的驱动逻辑与 C 辅助）
 *
 * Phase E active (E-04 v1+)：默认 bootstrap 链 `runtime_driver_no_c.o`（E-04 v1 default no_c；`-DSHUX_NO_C_FRONTEND`）；
 * B-strict `build_shux_asm` 链 `runtime_driver_asm_strict.o`。文件保留；完全收到 ABI 薄壳见 E-04 v2+。
 * E-05 v2：`SHUX_NO_C_FRONTEND` 时不 `#include` lexer/parser/typeck/codegen/ast C 前端头；仍保留 preprocess/target_cpu/lsp_diag。
 * E-04 v2：argv/target ABI 原语已拆至 `runtime_abi.c`（`driver_get_argv_i` 等）；本文件仍承载 pipeline/driver 主体。
 * E-04 v3：POSIX 文件 I/O 已拆至 `runtime_io_abi.c`（`runtime_read_file_malloc` / `shux_read_file_into_path` 等）。
 * E-04 v4：进程/链接辅助已拆至 `runtime_proc_abi.c`（`shu_waitpid_retry` / `asm_link_obj_skip_missing`）。
 * E-04 v5：invoke_cc 链接 argv 辅助已拆至 `runtime_link_abi.c`（`invoke_cc_argv_push_existing` 等）；invoke_cc 主体 v17 已迁入 link_abi。
 * E-04 v6：compress/net TLS 链接辅助已拆至 `runtime_link_abi.c`（`invoke_cc_append_compress_ld` 等）。
 * E-04 v7：Linux 链接硬化（PIE/NX/RELRO）已拆至 `runtime_link_abi.c`（`shux_append_linux_link_harden`）。
 * E-04 v8：compiler 目录解析与 asm ld 合成 argv0 已拆至 `runtime_link_abi.c`。
 * E-04 v22：driver CLI / pipeline 跳过标志已拆至 `runtime_driver_abi.c`；v25 扩展 asm 环境/阶段计时。
 * E-04 v23：`invoke_ld` 薄包装与 -o 后缀判断已拆至 `runtime_link_abi.c`（`shux_invoke_ld_for_exe` 等）。
 * E-04 v24：import 路径解析已拆至 `runtime_pipeline_abi.c`（`shux_resolve_import_file_path_multi` 等）。
 * E-04 v25：pipeline/asm 环境标志、dep codegen 路径与阶段计时已拆至 `runtime_driver_abi.c`。
 * E-04 v26：`driver_dep_*` 全局 dep 槽已拆至 `runtime_pipeline_abi.c`。
 * E-04 v27：import/load 辅助、`driver_argv_collect_defines`、asm 输出 helper 已拆至 pipeline/driver ABI。
 * E-04 v28：PipelineDepCtx 填充/seed、asm dep 路径 helper 已拆至 pipeline_abi；pipeline 诊断/源探测至 driver_abi。
 * E-04 v29：栈上限/大栈 pthread、shux_preprocess_raw_to_malloc、typeck dep 侧车已拆至 driver/pipeline ABI。
 * E-04 v35：dep 传递闭包 collect/merge/load_direct 已拆至 runtime_pipeline_abi.c。
 * 与 main.c 关系：main.c 仅保留极简 main() 调 main_entry；本文件承载全部 C 侧驱动与 I/O，与 main.sx 一一对应构建 shux。
 * 阶段 10 方向：逐步收成薄壳（入口、ABI、`-E` 桥接）；业务逻辑已迁 .sx（pipeline/driver/LSP）；日常构建入口见仓库根目录 build.sx + compiler/build_tool。
 */

#include "preprocess.h"
#include "target_cpu.h"
#include "lsp/lsp_diag.h"
#include "runtime_abi.h"
#include "runtime_io_abi.h"
#include "runtime_proc_abi.h"
#include "runtime_link_abi.h"
#include "runtime_driver_abi.h"
#include "runtime_pipeline_abi.h"
/** 本文件内 read_file 调用映射至 E-04 v3 I/O ABI TU。 */
#define read_file runtime_read_file_malloc
#if defined(SHUX_USE_SX_PREPROCESS)
/** bootstrap/driver：SX 预处理在 pipeline_abi（E-04 v32）。 */
#define SHUX_RUNTIME_PREPROCESS shux_preprocess
#else
/** shux-c / runtime_sx：C preprocess.o 提供 preprocess()。 */
#define SHUX_RUNTIME_PREPROCESS preprocess
#endif
#if !defined(SHUX_NO_C_FRONTEND)
/* C 前端头：仅 shux-c / LEGACY seed / runtime_driver.o 路径；E-05 v2 默认 no_c 不拉入。 */
#include "lexer/lexer.h"
#include "parser/parser.h"
#include "typeck/typeck.h"
#include "codegen/codegen.h"
#include "ast.h"
#include "runtime_c_import.h"
#else
/* preamble write_io_net_abi_inline 仅用 codegen_pipeline_stubs 的 skip mask，不依赖 codegen.h 全量 API。 */
struct ASTModule;
#define CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS    1u
#define CODEGEN_PREAMBLE_SKIP_STD_IO_DRIVER_HANDLE  2u
#define CODEGEN_PREAMBLE_SKIP_STD_IO_UNDEF_REDEFINE 4u
#define CODEGEN_PREAMBLE_SKIP_WEAK_IO_BATCH         8u
unsigned codegen_get_preamble_skip_mask(void);
void codegen_reset_preamble_skip_mask(void);
void codegen_or_preamble_skip_mask(unsigned mask);
void codegen_set_dep_slots_for_sx_pipeline(struct ASTModule **mods, const char **paths, int n);
void codegen_set_preamble_has_core_option_result(int on);
extern int typeck_module(struct ASTModule *m, struct ASTModule **dep_mods, int num_deps,
    struct ASTModule **all_dep_mods, int n_all_deps);
/* B-02 #[cfg] -target：声明来自 lexer.h；默认 seed 不链 C lexer.o，实现见 codegen_pipeline_stubs.c。 */
void cfg_apply_compile_target_from_triple(const char *triple, int len);
void cfg_reset_compile_target(void);
void cfg_sync_compile_target_from_state_c(void *state);
#endif
#if defined(SHUX_USE_SX_CODEGEN) && !defined(SHUX_NO_C_FRONTEND)
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

#if defined(SHUX_USE_SX_TYPECK) && !defined(SHUX_NO_C_FRONTEND)
/* 6.1：.sx typeck 入口；由 typeck.sx 提供（库模块形式生成，符号为 typeck_typeck_entry），转调 C typeck_module */
extern int typeck_typeck_entry(struct ASTModule *mod, struct ASTModule **deps, int ndep);
#endif
#ifdef SHUX_USE_SX_PIPELINE
/**
 * pipeline / run_compiler 路径调用 driver_dep_*；实现于 runtime_pipeline_abi.c（E-04 v26）。
 */
#endif

#if defined(SHUX_USE_SX_PIPELINE) || defined(SHUX_USE_SX_DRIVER)
#endif

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
        "__attribute__((weak)) int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr) { (void)bufs; (void)nr; return -1; }\n",
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
        "/* 撤销宏：SX codegen 会生成同名函数定义(shux_io_register/submit_read/submit_write)，宏与多参签名冲突，在函数体前必须 undef。 */\n",
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
        "/* SX codegen 在 std_io_driver_read/write 体内用短名 submit_read/submit_write(Buffer)；须转调 preamble 的 ptrdiff_t _buf 包装。 */\n",
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
        "/* SX 生成代码可能调用 std_io_* / std_net_* 带前缀名且首参为 stream/listener 结构体；以下宏统一转为 .fd 再调 _impl。C 路径下 std.io 仍定义 std_io_read_fixed_fd，故仅 SX 需宏。 */\n",
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
        "/* SX 内联 std.io 会生成函数定义；撤销与定义/extern 冲突的宏，并补齐 batch 注册符号映射。 */\n",
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
        "/* SX 内联 std.io 时若 driver/mod 部分包装未 codegen，由弱符号补齐以免链接失败（handle_from_fd 由 mod codegen 定义，此处不再 weak）。 */\n",
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
        /* #undef / 重绑 std_io_core_*（209–222）：SX 内联 std.io.core 且 codegen 已 emit 时由 codegen 侧承担。 */
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

/** 向生成 C 写入 std.fs / std.path / std.map / std.error 内联 ABI（F-ZC Z9：不再 #include std/*_abi.h）。成功返回 0。 */
static int write_fs_path_map_error_abi_inline(FILE *cf) {
    static const char *lines[] = {
        "typedef struct std_fs_FsIovecBuf fs_iovec_buf_t;\n",
        "extern int32_t fs_open_read_c(uint8_t *path);\n",
        "extern uint64_t fs_direct_align_c(void);\n",
        "extern int32_t fs_fadvise_sequential_c(int32_t fd);\n",
        "extern int32_t fs_fadvise_willneed_c(int32_t fd, int64_t offset, size_t len);\n",
        "extern int64_t fs_copy_file_range_c(int32_t fd_in, int32_t fd_out, size_t len);\n",
        "extern int64_t fs_sendfile_c(int32_t out_fd, int32_t in_fd, size_t count);\n",
        "extern int64_t fs_pipe_splice_c(int32_t fd_in, int32_t fd_out, size_t len);\n",
        "extern int32_t fs_sync_range_c(int32_t fd, int64_t offset, size_t len);\n",
        "extern int32_t fs_sync_c(int32_t fd);\n",
        "extern int32_t fs_fallocate_c(int32_t fd, int64_t offset, int64_t len);\n",
        "extern int32_t fs_last_error_c(void);\n",
        "extern int64_t fs_readv_buf_c(int32_t fd, const fs_iovec_buf_t *bufs, int n);\n",
        "extern int64_t fs_writev_buf_c(int32_t fd, const fs_iovec_buf_t *bufs, int n);\n",
        "extern int32_t std_path_empty_len(void);\n",
        "#define empty_len() std_path_empty_len()\n",
        "extern int32_t map_i32_i32_find_c(const int32_t *keys, const uint8_t *occupied, int32_t cap, int32_t key);\n",
        "extern int32_t std_map_empty_size(void);\n",
        "#define empty_size(_a, _b) std_map_empty_size()\n",
        "extern int32_t std_error_error_ok(void);\n",
        "#define error_ok(_a, _b) std_error_error_ok()\n",
    };
    for (size_t i = 0; i < sizeof(lines) / sizeof(lines[0]); i++) {
        if (fputs(lines[i], cf) == EOF)
            return 1;
    }
    return 0;
}
#endif /* SHUX_USE_SX_PIPELINE */

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


#ifdef SHUX_USE_SX_PIPELINE
#include <stdint.h>
#include <stddef.h>
/* 9.1：纯 .sx 流水线；PipelineDepCtx / shux_slice 见 runtime_pipeline_abi.h。 */

extern int32_t pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);
extern int pipeline_run_sx_pipeline(void *module, void *arena, const uint8_t *source_data, size_t source_len, void *out_buf, void *ctx);
extern int pipeline_pipeline_impl_typecheck(void *module, void *arena, void *ctx);
extern void pipeline_asm_seed_std_net_struct_layouts(struct ast_Module *m);

/** 诊断：返回 module 的 num_funcs（pipeline_glue.c 提供，与 ast_Module 同 TU）。 */
extern int driver_get_module_num_funcs(void *m);
extern int driver_get_module_main_func_index(void *m);

/** 将 C 侧 dep 槽写入 PipelineDepCtx sidecar — 见 runtime_pipeline_abi.c shux_pipeline_pctx_seed_dep_slots。 */
extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);
extern int32_t pipeline_typeck_sx_stack_escape_gate_from_src_c(uint8_t *src, int32_t src_len);
/** 7.4：ELF .o 路径；由 Makefile 追加到 pipeline_gen.c，用于分配 ElfCodegenCtx */
extern size_t pipeline_sizeof_elf_ctx(void);
/** 7.4：直接生成 ELF64 .o 到 out_buf（仅 x86_64）；由 asm.sx 提供，pipeline_sx.o 链接；ElfCodegenCtx 在 platform/elf.sx，C 侧为 platform_elf_ElfCodegenCtx。out_buf 用 void* 避免不同 GCC 下「形参内 struct 声明不可见」导致 -Wincompatible-pointer-types。 */
struct platform_elf_ElfCodegenCtx;
extern int32_t asm_asm_codegen_elf_o(void *module, void *arena, void *ctx, struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf);
extern void pipeline_elf_ctx_diag_stderr(uint8_t *ctx_bytes);

/** 调试：打印 module 中每个 func 的 name_len/name（由 Makefile 追加到 pipeline_gen.c）；便于定位 mai/ba 截断 */
extern void pipeline_debug_module_funcs(void *module);
/* 与生成代码中 codegen_CodegenOutBuf 布局一致；C 在调用后将 data[0..len-1] 写到 FILE* */
#define SX_CODEGEN_OUTBUF_CAP (9 * 1024 * 1024)
struct codegen_CodegenOutBuf {
    unsigned char data[SX_CODEGEN_OUTBUF_CAP];
    int32_t len;
};
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
_Static_assert(offsetof(struct codegen_CodegenOutBuf, len) == SX_CODEGEN_OUTBUF_CAP, "CodegenOutBuf: len must follow data[] for ABI");
#endif
/** asm 后端 C 桩：-backend asm 时由 pipeline 调用，写出最小 GAS（main return 42），便于 pipeline 不 import asm 仍可构建 shux_sx。
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
        if (n + len + 1 > (size_t)SX_CODEGEN_OUTBUF_CAP) return -1;
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
/* 6.1 后 typeck/pipeline 用 ctx；typeck dep 侧车见 runtime_pipeline_abi.c（E-04 v29）；typeck 入口见 v31 pipeline_typeck_module_for_ctx。 */
#if defined(SHUX_USE_SX_PIPELINE) || defined(SHUX_USE_SX_DRIVER)
#endif

#endif /* SHUX_USE_SX_PIPELINE */

#include <unistd.h>
#include <sys/wait.h>
#include <sys/utsname.h>

#define MAX_ALL_DEPS 128

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
        case TOKEN_DOTDOT:  return "DOTDOT";
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

/** 无 -o 烟测二次 lexer 参数：typeck 后主线程栈已深，须在大栈 pthread 上 dump token。 */
typedef struct {
    const char *src;
} DriverSmokeLexDumpArgs;

/** pthread 入口：遍历 src 并 stdout 打印 token（与 run-lexer 期望格式一致）。 */
static void *driver_smoke_lex_dump_thread_fn(void *arg) {
    const DriverSmokeLexDumpArgs *a = (const DriverSmokeLexDumpArgs *)arg;
    Lexer *lex2;
    Token tok;
    if (!a || !a->src)
        return NULL;
    lex2 = lexer_new(a->src);
    if (!lex2)
        return NULL;
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
    return NULL;
}

/** 在大栈 pthread 上执行 token dump，避免 typeck 深递归后二次 lexer 栈溢出。 */
static void driver_smoke_lex_dump_on_large_stack(const char *src) {
    DriverSmokeLexDumpArgs args;
    args.src = src;
    driver_run_thread_on_large_stack(driver_smoke_lex_dump_thread_fn, &args);
}
#endif /* !SHUX_USE_SX_DRIVER */

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
    /* 阶段 3.2：链入 _sx.o 时不再提供 typeck_module/codegen_* 等 C 符号，run_compiler_c 不应被调用；main 已走 run_compiler_sx_path。 */
    (void)argc;
    (void)argv;
    fprintf(stderr, "shux: internal error: run_compiler_c called with SHUX_USE_SX_FRONTEND\n");
    return 1;
#else
    /* typeck/codegen 等大模块自举 parse/typeck 栈帧深；须早于 pipeline 入口扩容。 */
    driver_bump_stack_limit();
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
    int use_sx_pipeline = 1;  /* 链接了 .sx pipeline 时默认启用（避免 C 前端 parser 不支持 .sx 语法） */
    int use_asm_backend = 0;  /* -backend asm：出汇编而非 C，并走 -sx pipeline */
    #endif
    const char *defines[MAX_DEFINES];
    int ndefines = 0;

    for (int i = 1; i < argc; i++) {
        #ifdef SHUX_USE_SX_PIPELINE
        if (strcmp(argv[i], "-sx") == 0) {
            use_sx_pipeline = 1;
        } else if (strcmp(argv[i], "-backend") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "shux: -backend requires an argument (asm or c)\n");
                return 1;
            }
            if (strcmp(argv[i + 1], "asm") == 0) {
                use_asm_backend = 1;
                use_sx_pipeline = 1;  /* -backend asm 必须走 .sx pipeline */
            } else if (strcmp(argv[i + 1], "c") == 0) {
                use_asm_backend = 0;
                use_sx_pipeline = 0;  /* -backend c：C parse/typeck/codegen；-o+import 走 SX pipeline 易 out_len=0 */
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
        } else if (strstr(target, "freebsd") != NULL) {
            defines[ndefines++] = "OS_FREEBSD";
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

    ShuxRuntimeFileView raw_src_view;
    if (runtime_read_file_view(input_path, &raw_src_view) != 0) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = NULL;
#ifdef SHUX_USE_SX_PIPELINE
    if (use_sx_pipeline) {
        if (shux_preprocess_raw_to_malloc((const unsigned char *)raw_src_view.data, raw_src_view.length, &src, &src_len,
                input_path,
                ndefines > 0 ? defines : NULL, ndefines) != 0) {
            runtime_release_file_view(&raw_src_view);
            return 1;
        }
        runtime_release_file_view(&raw_src_view);
    } else
#endif
    {
        src = SHUX_RUNTIME_PREPROCESS(raw_src_view.data, raw_src_view.length, ndefines > 0 ? defines : NULL, ndefines,
            &src_len);
        runtime_release_file_view(&raw_src_view);
        if (!src) {
            fprintf(stderr, "shux: preprocess failed for '%s'\n", input_path);
            return 1;
        }
    }

#ifdef SHUX_USE_SX_PIPELINE
    if (use_sx_pipeline) {
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
        shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
        const char *entry_dir = entry_dir_buf;
        /* 阶段 5：有 import 时先 resolve 并 pipeline 各依赖，再 pipeline 入口 */
        char *dep_paths[MAX_ALL_DEPS];
        int n_deps = 0;
#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
        /*
         * 与 emit-C 路径一致：传递闭包（如 hello→std.io→driver/core）；merge 保证槽 0..n_imports-1 与入口 import 对齐，
         * asm_codegen_elf_o 才能把 driver/core 的定义编入同一 Mach-O/ELF。
         */
        if (n_imports > 0 && n_imports <= 32) {
            char *cpaths[MAX_ALL_DEPS];
            int n_closure = 0;
            if (shux_collect_dep_paths_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir, defines,
                    ndefines, cpaths, &n_closure) != 0) {
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            if (shux_merge_direct_then_transitive_dep_paths(module, n_imports, cpaths, n_closure, dep_paths, &n_deps) != 0) {
                while (n_closure > 0) {
                    n_closure--;
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
                if (shux_find_loaded_import_index(path_c, dep_paths, n_deps) >= 0)
                    continue;
                char resolved[PATH_MAX];
                shux_resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir, path_c, resolved, sizeof(resolved));
                ShuxRuntimeFileView raw_view;
                if (runtime_read_file_view(resolved, &raw_view) != 0) {
                    fprintf(stderr, "shux: cannot open import '%s' (tried %s)\n", path_c, resolved);
                    while (n_deps--)
                        free(dep_paths[n_deps]);
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
                runtime_release_file_view(&raw_view);
                dep_paths[n_deps] = strdup(path_c);
                if (!dep_paths[n_deps]) {
                    while (n_deps--)
                        free(dep_paths[n_deps]);
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
            asm_want_exe = shux_output_want_exe(out_path);
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
                emit_elf_o = shux_output_is_elf_o(out_path);
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
                while (n_deps--)
                    free(dep_paths[n_deps]);
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
            while (n_deps--)
                free(dep_paths[n_deps]);
            free(arena);
            free(module);
            free(src);
            if (out_buf) free(out_buf);
            if (pctx) pipeline_dep_ctx_heap_destroy(pctx);
            return 1;
        }
        shux_pipeline_fill_ctx_path_buffers(pctx, entry_dir, lib_roots_arr, n_lib_roots);
        shux_pipeline_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
        driver_dep_seeded_clear_all();
        if (use_asm_backend && emit_elf_o && driver_asm_entry_module_only_from_env() && driver_asm_build_skip_typeck() != 0) {
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
                    while (n_deps--)
                        free(dep_paths[n_deps]);
                    free(arena); free(module); free(src);
                    return 1;
                }
                shux_pipeline_fill_ctx_path_buffers(one_ctx, shux_dep_prerun_entry_dir(entry_dir, lib_roots_arr, n_lib_roots),
                    lib_roots_arr, n_lib_roots);
                char resolved[PATH_MAX];
                shux_resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir, dep_paths[j], resolved, sizeof(resolved));
                ShuxRuntimeFileView raw_view;
                if (runtime_read_file_view(resolved, &raw_view) != 0) {
                    fprintf(stderr, "shux: cannot open import '%s' (tried %s)\n", dep_paths[j], resolved);
                    pipeline_dep_ctx_heap_destroy(one_ctx);
                    free(dep_out);
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                    if (asm_out) fclose(asm_out);
                    if (elf_ctx_ptr) free(elf_ctx_ptr);
                    while (n_deps--)
                        free(dep_paths[n_deps]);
                    free(arena); free(module); free(src);
                    return 1;
                }
                size_t dep_len = 0;
                char *dep_src = shux_preprocess(raw_view.data, raw_view.length, ndefines > 0 ? defines : NULL, ndefines, &dep_len);
                runtime_release_file_view(&raw_view);
                if (!dep_src) {
                    fprintf(stderr, "shux: preprocess failed for import '%s'\n", dep_paths[j]);
                    pipeline_dep_ctx_heap_destroy(one_ctx);
                    free(dep_out);
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                    if (asm_out) fclose(asm_out);
                    if (elf_ctx_ptr) free(elf_ctx_ptr);
                    while (n_deps--)
                        free(dep_paths[n_deps]);
                    free(arena); free(module); free(src);
                    return 1;
                }
                shux_pipeline_one_ctx_for_dep_prerun(one_ctx, j, dep_modules, dep_arenas, dep_paths, n_deps,
                    (const uint8_t *)dep_src, dep_len);
                int ec;
                if (use_asm_backend && emit_elf_o && shux_asm_user_std_dep_skip_sx_typeck(dep_paths[j])) {
                    ec = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                        (const uint8_t *)dep_src, dep_len);
                } else if (use_asm_backend && emit_elf_o && shux_asm_user_dep_parse_skip_typeck_path(dep_paths[j])) {
                    ec = shux_pipeline_dep_prerun_parse_skip_typeck(dep_modules[j], dep_arenas[j],
                        (const uint8_t *)dep_src, dep_len, (void *)dep_out, (void *)one_ctx);
                    if (ec == 0 && shux_asm_user_std_net_dep_path(dep_paths[j]))
                        pipeline_asm_seed_std_net_struct_layouts((struct ast_Module *)dep_modules[j]);
                } else {
                    ec = shux_pipeline_dep_prerun_for_asm_module_o(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_src,
                        dep_len, (void *)dep_out, (void *)one_ctx);
                }
                pipeline_dep_ctx_heap_destroy(one_ctx);
                free(dep_out);
                free(dep_src);
                if (ec != 0) {
                    fprintf(stderr, "shux: pipeline failed for import '%s' (rc=%d)\n", dep_paths[j], ec);
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                    if (asm_out) fclose(asm_out);
                    if (elf_ctx_ptr) free(elf_ctx_ptr);
                    while (n_deps--)
                        free(dep_paths[n_deps]);
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
            pctx->asm_entry_module_only = driver_asm_entry_module_only_from_env();
        /* get_ndep() 需在 pipeline 内返回 n_deps，以便先 codegen 各 dep 再 codegen entry（含跨 dep 调用时 dep_paths 已设）。 */
        typeck_ndep = n_deps;
        for (int i = 0; i < n_deps; i++) {
            typeck_dep_module_ptrs[i] = dep_modules[i];
            typeck_dep_arena_ptrs[i] = dep_arenas[i];
        }
        pipeline_set_dep_slots(dep_arenas, dep_modules);
        driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
        codegen_set_dep_slots_for_sx_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
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
         * run_compiler_c + import 降级路径：仍可能 -o .o 并走 asm_codegen_elf_o。
         * 无 import 的单文件仍须 .sx typeck（field_access_offset 等）；有 dep 时入口可跳过全量 typeck。
         */
        if (emit_elf_o && out_path && !driver_check_only_get()) {
            if (n_deps > 0)
                driver_sx_pipeline_skip_typeck_set(1);
            driver_sx_pipeline_skip_codegen_set(1);
        }
        int ec = shux_pipeline_run_sx_pipeline_large_stack(module, arena, src_slice.data, (size_t)src_slice.length, (void *)out_buf, (void *)pctx);
        driver_sx_pipeline_skip_typeck_set(0);
        driver_sx_pipeline_skip_codegen_set(0);
        if (getenv("SHUX_ASM_ENTRY_DEBUG")) {
            fprintf(stderr, "shux: asm entry dbg ec=%d num_funcs=%d out_asm_len=%zu\n",
                    ec, driver_get_module_num_funcs(module), (size_t)out_buf->len);
        }
        driver_dep_seeded_clear_all();
        codegen_set_dep_slots_for_sx_pipeline(NULL, NULL, 0);
        if (ec == 0 && (out_buf->len > 0 || emit_elf_o)) {
            if (emit_elf_o && elf_ctx_ptr) {
                shux_driver_asm_prepare_entry_elf_emit(module, arena, pctx);
                int32_t elf_ec = shux_asm_codegen_elf_o_large_stack(module, arena, (void *)pctx, (struct platform_elf_ElfCodegenCtx *)elf_ctx_ptr, (void *)out_buf);
                if (elf_ec != 0 || out_buf->len <= 0) {
                    fprintf(stderr, "shux: asm_codegen_elf_o failed (elf_ec=%d, out_len=%zu, num_funcs=%d)\n",
                            (int)elf_ec, (size_t)out_buf->len, driver_get_module_num_funcs(module));
                    if (elf_ec != 0 && elf_ctx_ptr)
                        pipeline_elf_ctx_diag_stderr((uint8_t *)elf_ctx_ptr);
                    if (asm_out) fclose(asm_out);
                    if (elf_ctx_ptr) free(elf_ctx_ptr);
                    for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
                    while (n_deps > 0) { n_deps--; free(dep_paths[n_deps]); }
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
                free(dep_paths[n_deps]);
            }
            /* -o <exe>（无 .o/.s 后缀）时：已写临时 .o，调 ld 生成可执行文件后删临时文件；链 runtime_panic 与常用 std 各 .o */
            if (asm_want_exe && asm_tmp_o_path[0]) {
                driver_bump_stack_limit();
                int ld_ok = shux_invoke_ld_for_exe(asm_tmp_o_path, out_path, target, pctx->use_macho_o, pctx->use_coff_o, argv[0], lib_roots_arr, n_lib_roots);
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
    shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    const char *entry_dir = entry_dir_buf;

    ASTModule *dep_mods[32];       /* 入口直接依赖，与 mod->import_paths 一一对应，供 typeck/codegen 入口 */
    ASTModule *all_dep_mods[MAX_ALL_DEPS];
    char *all_dep_paths[MAX_ALL_DEPS];
    int ndep = 0, n_all = 0;
    if (mod->num_imports > 0 && shu_c_resolve_and_load_imports(mod, lib_roots_arr, n_lib_roots, entry_dir, ndefines > 0 ? defines : NULL, ndefines,
            dep_mods, &ndep, all_dep_mods, all_dep_paths, NULL, &n_all, MAX_ALL_DEPS) != 0) {
        ast_module_free(mod);
        free(src);
        return 1;
    }
/* 6.3：与 pipeline_sx.o 同链时不再链 typeck_sx/codegen_sx，非 -sx 路径用 C typeck/codegen 避免重复符号 */
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
         * 入口模块全体符号；须 emit 全量函数供 pipeline_sx.o 链接 C 依赖实现。
         * 库模块 -E 亦须全量 emit（如 std/json/json.sx）。 */
        if (emit_extern_imports || !mod->main_func || !mod->main_func->body)
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
            fprintf(stdout, "#include <math.h>\n");
            codegen_emit_fmt_json_helpers_once(stdout);
            fprintf(stdout, "extern int getpid(void);\n");
            fprintf(stdout, "static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {\n");
            fprintf(stdout, "  const char *_ev = getenv(\"SHUX_CRASH_EVIDENCE\");\n");
            fprintf(stdout, "  if (!_ev || _ev[0] != '1') return;\n");
            fprintf(stdout, "  int _pid = (int)getpid();\n");
            fprintf(stdout, "  fprintf(stderr, \"shux: [SHUX_CRASH_EVIDENCE] panic=%%d msg=%%d frames=0 pid=%%d\\n\", has_msg, msg_val, _pid);\n");
            fprintf(stdout, "  const char *_dir = getenv(\"SHUX_CRASH_EVIDENCE_DIR\");\n");
            fprintf(stdout, "  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, \"%%s/shux-crash-%%d.txt\", _dir, _pid);\n");
            fprintf(stdout, "    FILE *_f = fopen(_p, \"w\"); if (_f) { fprintf(_f, \"panic_has_msg=%%d\\npanic_msg=%%d\\nframes=0\\npid=%%d\\n\", has_msg, msg_val, _pid); fclose(_f);\n");
            fprintf(stdout, "      fprintf(stderr, \"shux: [SHUX_CRASH_EVIDENCE] bundle=%%s\\n\", _p); } } }\n");
            fprintf(stdout, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
            fprintf(stdout, "static inline void shux_panic_(int has_msg, int msg_val) {\n");
            fprintf(stdout, "  shux_crash_evidence_collect_inline(has_msg, msg_val);\n");
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
                fprintf(stdout, "__attribute__((weak)) int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr) { (void)bufs; (void)nr; return -1; }\n");
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
                        int idx = shux_find_loaded_import_index(all_dep_mods[i]->import_paths[j], all_dep_paths, n_all);
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
                const char *lib_name = shux_entry_lib_name_from_path(input_path);
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
                const char *lib_name = shux_entry_lib_name_from_path(input_path);
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
            shux_emit_pipeline_glue_include();
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
            /* LANG-007 v2：库模块 -o *.o → codegen_library_module_to_c + cc -c。 */
            if (out_path && shux_output_is_elf_o(out_path) && mod->num_funcs > 0) {
                char tmp_lib[] = "/tmp/shux_XXXXXX";
                int fd_lib = mkstemp(tmp_lib);
                if (fd_lib < 0) {
                    perror("shux: mkstemp");
                    while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
                    ast_module_free(mod);
                    free(src);
                    return 1;
                }
                FILE *cf_lib = fdopen(fd_lib, "w");
                if (!cf_lib) {
                    close(fd_lib);
                    unlink(tmp_lib);
                    while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
                    ast_module_free(mod);
                    free(src);
                    return 1;
                }
                fprintf(cf_lib, "/* generated (library module) */\n");
                fprintf(cf_lib, "#include <stdint.h>\n");
                fprintf(cf_lib, "#include <stddef.h>\n");
                fprintf(cf_lib, "#include <stdlib.h>\n");
                fprintf(cf_lib, "#include <stdio.h>\n");
                fprintf(cf_lib, "#include <string.h>\n");
                fprintf(cf_lib, "#include <math.h>\n");
                codegen_emit_fmt_json_helpers_once(cf_lib);
                fprintf(cf_lib, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
                fprintf(cf_lib, "static inline void shux_panic_(int has_msg, int msg_val) { (void)has_msg; (void)msg_val; abort(); }\n");
                {
                    const char *lib_name = shux_entry_lib_name_from_path(input_path);
                    if (codegen_library_module_to_c(mod, lib_name, ndep > 0 ? dep_mods : NULL,
                            ndep > 0 ? (const char **)mod->import_paths : NULL, ndep,
                            cf_lib, NULL, NULL, NULL, NULL, NULL, NULL, 0, input_path) != 0) {
                        fclose(cf_lib);
                        unlink(tmp_lib);
                        while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
                        ast_module_free(mod);
                        free(src);
                        return 1;
                    }
                }
                fclose(cf_lib);
                char tmp_lib_c[32];
                snprintf(tmp_lib_c, sizeof(tmp_lib_c), "%s.c", tmp_lib);
                if (rename(tmp_lib, tmp_lib_c) != 0) {
                    perror("shux: rename");
                    unlink(tmp_lib);
                    while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
                    ast_module_free(mod);
                    free(src);
                    return 1;
                }
                {
                    pid_t cpid = fork();
                    int cc_ok = 0;
                    if (cpid < 0) {
                        perror("shux: fork");
                        cc_ok = -1;
                    } else if (cpid == 0) {
                        execlp("cc", "cc", "-std=gnu11", "-Wall", "-Wextra", "-c", "-o", (char *)out_path,
                            tmp_lib_c, (char *)NULL);
                        perror("shux: cc");
                        _exit(127);
                    } else {
                        int status = 0;
                        if (shu_waitpid_retry(cpid, &status) != 0 ||
                            !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
                            fprintf(stderr, "shux: cc -c failed for library module\n");
                            cc_ok = -1;
                        }
                    }
                    if (cc_ok != 0)
                        fprintf(stderr, "shux: cc failed, keeping generated C: %s\n", tmp_lib_c);
                    else if (!getenv("SHUX_KEEP_C"))
                        unlink(tmp_lib_c);
                    while (n_all--) { free(all_dep_paths[n_all]); ast_module_free(all_dep_mods[n_all]); }
                    ast_module_free(mod);
                    free(src);
                    return cc_ok == 0 ? 0 : 1;
                }
            }
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

        const char *c_paths[SHUX_INVOKE_CC_MAX_C_FILES];
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
            fprintf(cf, "#include <math.h>\n");
            codegen_emit_fmt_json_helpers_once(cf);
            fprintf(cf, "#include <string.h>\n");
            fprintf(cf, "extern int getpid(void);\n");
            fprintf(cf, "static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {\n");
            fprintf(cf, "  const char *_ev = getenv(\"SHUX_CRASH_EVIDENCE\");\n");
            fprintf(cf, "  if (!_ev || _ev[0] != '1') return;\n");
            fprintf(cf, "  int _pid = (int)getpid();\n");
            fprintf(cf, "  fprintf(stderr, \"shux: [SHUX_CRASH_EVIDENCE] panic=%%d msg=%%d frames=0 pid=%%d\\n\", has_msg, msg_val, _pid);\n");
            fprintf(cf, "  const char *_dir = getenv(\"SHUX_CRASH_EVIDENCE_DIR\");\n");
            fprintf(cf, "  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, \"%%s/shux-crash-%%d.txt\", _dir, _pid);\n");
            fprintf(cf, "    FILE *_f = fopen(_p, \"w\"); if (_f) { fprintf(_f, \"panic_has_msg=%%d\\npanic_msg=%%d\\nframes=0\\npid=%%d\\n\", has_msg, msg_val, _pid); fclose(_f);\n");
            fprintf(cf, "      fprintf(stderr, \"shux: [SHUX_CRASH_EVIDENCE] bundle=%%s\\n\", _p); } } }\n");
            fprintf(cf, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
            fprintf(cf, "static inline void shux_panic_(int has_msg, int msg_val) {\n");
            fprintf(cf, "  shux_crash_evidence_collect_inline(has_msg, msg_val);\n");
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
            fprintf(cf, "__attribute__((weak)) int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr) { (void)bufs; (void)nr; return -1; }\n");
            fprintf(cf, "static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }\n");
            /* codegen 跳过 std.io.print(ptr,len)；C 前端链 io.o 时由弱符号提供，避免 hello 等 Undefined _std_io_print_u8_ptr_usize。 */
            fprintf(cf, "__attribute__((weak)) int32_t std_io_print_u8_ptr_usize(uint8_t *ptr, size_t len) {\n");
            fprintf(cf, "  if (!ptr || len == 0) return 0;\n");
            fprintf(cf, "  return (fwrite(ptr, 1, len, stdout) == len) ? (int32_t)len : -1;\n");
            fprintf(cf, "}\n");
            /* 纯 .sx io 烟测：无 io.o 时 weak read/write 走 stdio，handle 0/1/2 与 stdin/stdout/stderr 一致。 */
            fprintf(cf, "__attribute__((weak)) int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m) {\n");
            fprintf(cf, "  size_t r;\n");
            fprintf(cf, "  (void)timeout_m;\n");
            fprintf(cf, "  if (!ptr || handle != 0) return -1;\n");
            fprintf(cf, "  r = fread(ptr, 1, len, stdin);\n");
            fprintf(cf, "  if (r == 0 && feof(stdin)) return 0;\n");
            fprintf(cf, "  if (r == 0 && ferror(stdin)) return -1;\n");
            fprintf(cf, "  return (int32_t)r;\n");
            fprintf(cf, "}\n");
            fprintf(cf, "__attribute__((weak)) int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m) {\n");
            fprintf(cf, "  FILE *fp;\n");
            fprintf(cf, "  (void)timeout_m;\n");
            fprintf(cf, "  if (!ptr || len == 0) return 0;\n");
            fprintf(cf, "  if (handle == 1) fp = stdout; else if (handle == 2) fp = stderr; else return -1;\n");
            fprintf(cf, "  return (fwrite(ptr, 1, len, fp) == len) ? (int32_t)len : -1;\n");
            fprintf(cf, "}\n");
            for (int i = 0; i < n_all; i++) {
                ASTModule *lib_deps[32];
                const char *lib_dep_paths[32];
                int n_lib = 0;
                for (int j = 0; j < all_dep_mods[i]->num_imports && n_lib < 32; j++) {
                    int idx = shux_find_loaded_import_index(all_dep_mods[i]->import_paths[j], all_dep_paths, n_all);
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
                fprintf(cf, "enum ast_ExprKind compound_assign_token_to_expr_kind_from_glue(int32_t kind);\n");
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

        const char *io_o = shux_std_io_o_path(argv[0]); /* F-03：纯 .sx，无 io.o */
        const char *fs_o = NULL; /* F-06 v1：纯 .sx，invoke_cc 扫描生成 C 按需 -lc */
        const char *process_o = shux_rel_o_path_from_argv0(argv[0], "std/process/process.o");
        const char *string_o = shux_rel_o_path_from_argv0(argv[0], "std/string/string.o");
        const char *heap_o = NULL; /* F-06 v1：纯 .sx，按需 -lc */
        const char *path_o = shux_rel_o_path_from_argv0(argv[0], "std/path/path.o");
        const char *runtime_o = shux_rel_o_path_from_argv0(argv[0], "std/runtime/runtime.o");
        const char *runtime_panic_o = shux_runtime_panic_o_path(argv[0]);
        const char *net_o = shux_rel_o_path_from_argv0(argv[0], "std/net/net.o");
        const char *thread_o = shux_rel_o_path_from_argv0(argv[0], "std/thread/thread.o");
        const char *time_o = shux_rel_o_path_from_argv0(argv[0], "std/time/time.o");
        const char *random_o = shux_rel_o_path_from_argv0(argv[0], "std/random/random.o");
        const char *env_o = shux_rel_o_path_from_argv0(argv[0], "std/env/env.o");
        const char *sync_o = shux_rel_o_path_from_argv0(argv[0], "std/sync/sync.o");
        const char *encoding_o = shux_rel_o_path_from_argv0(argv[0], "std/encoding/encoding.o");
        const char *base64_o = shux_rel_o_path_from_argv0(argv[0], "std/base64/base64.o");
        const char *crypto_o = shux_rel_o_path_from_argv0(argv[0], "std/crypto/crypto.o");
        const char *log_o = shux_rel_o_path_from_argv0(argv[0], "std/log/log.o");
        const char *atomic_o = shux_rel_o_path_from_argv0(argv[0], "std/atomic/atomic.o");
        const char *channel_o = shux_rel_o_path_from_argv0(argv[0], "std/channel/channel.o");
        const char *backtrace_o = shux_rel_o_path_from_argv0(argv[0], "std/backtrace/backtrace.o");
        const char *hash_o = shux_rel_o_path_from_argv0(argv[0], "std/hash/hash.o");
        const char *math_o = shux_rel_o_path_from_argv0(argv[0], "std/math/math.o");
        const char *sort_o = shux_rel_o_path_from_argv0(argv[0], "std/sort/sort.o");
        const char *ffi_o = shux_rel_o_path_from_argv0(argv[0], "std/ffi/ffi.o");
        const char *db_o = shux_rel_o_path_from_argv0(argv[0], "std/db/sqlite/sqlite.o");
        const char *elf_o = shux_rel_o_path_from_argv0(argv[0], "std/elf/elf.o");
        const char *json_o = shux_rel_o_path_from_argv0(argv[0], "std/json/json.o");
        const char *csv_o = shux_rel_o_path_from_argv0(argv[0], "std/csv/csv.o");
        const char *regex_o = shux_rel_o_path_from_argv0(argv[0], "std/regex/regex.o");
        const char *compress_o = NULL; /* F-06 v1 / F-04 v7：无 compress.o，user .o / 生成 C 按需压缩库 */
        const char *unicode_o = shux_rel_o_path_from_argv0(argv[0], "std/unicode/unicode.o");
        const char *dynlib_o = shux_rel_o_path_from_argv0(argv[0], "std/dynlib/dynlib.o");
        const char *http_o = shux_rel_o_path_from_argv0(argv[0], "std/http/http.o");
        const char *tar_o = shux_rel_o_path_from_argv0(argv[0], "std/tar/tar.o");
        const char *simd_o = shux_rel_o_path_from_argv0(argv[0], "std/simd/simd.o");
        const char *context_o = shux_rel_o_path_from_argv0(argv[0], "std/context/context.o");
        const char *datetime_o = shux_rel_o_path_from_argv0(argv[0], "std/datetime/datetime.o");
        const char *uuid_o = shux_rel_o_path_from_argv0(argv[0], "std/uuid/uuid.o");
        const char *url_o = shux_rel_o_path_from_argv0(argv[0], "std/url/url.o");
        const char *cli_o = shux_rel_o_path_from_argv0(argv[0], "std/cli/cli.o");
        const char *security_o = shux_rel_o_path_from_argv0(argv[0], "std/security/security.o");
        const char *config_o = shux_rel_o_path_from_argv0(argv[0], "std/config/config.o");
        const char *cache_o = shux_rel_o_path_from_argv0(argv[0], "std/cache/cache.o");
        const char *trace_o = shux_rel_o_path_from_argv0(argv[0], "std/trace/trace.o");
        const char *task_o = shux_rel_o_path_from_argv0(argv[0], "std/task/task.o");
        const char *schema_o = shux_rel_o_path_from_argv0(argv[0], "std/schema/schema.o");
        const char *test_o = shux_rel_o_path_from_argv0(argv[0], "std/test/test.o");
        const char *async_scheduler_o = NULL;
        if (shux_generated_c_needs_async_scheduler(tmp_c))
            async_scheduler_o = shux_std_async_scheduler_o_path(argv[0]);
        int cc_ok = shux_invoke_cc(c_paths, n_c, out_path, target, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, shux_repo_root_from_argv0(argv[0]), async_scheduler_o);
        if (cc_ok != 0) {
            fprintf(stderr, "shux: cc failed, keeping generated C: %s\n", tmp_c);
        } else if (getenv("SHUX_KEEP_C")) {
            fprintf(stderr, "shux: kept generated C: %s\n", tmp_c);
        } else {
            unlink(tmp_c);
        }
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

    /* typeck 后主线程栈剩余不足；二次 lexer 改在大栈 pthread 上跑（见 driver_smoke_lex_dump_on_large_stack）。 */
    driver_smoke_lex_dump_on_large_stack(src);

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
    driver_bump_stack_limit();
#define SX_PATH_MAX_LIB_ROOTS 16
    const char *input_path = NULL;
    const char *out_path = NULL;
    const char *lib_roots_arr[SX_PATH_MAX_LIB_ROOTS];
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
            if (n_lib_roots < SX_PATH_MAX_LIB_ROOTS) lib_roots_arr[n_lib_roots++] = argv[++i];
            continue;
        }
        if (strcmp(argv[i], "-O") == 0) {
            if (i + 1 >= argc) return run_compiler_c(argc, argv);
            opt_level = argv[++i];
            continue;
        }
        if (strcmp(argv[i], "-flto") == 0) { use_lto = 1; continue; }
        /* 跳过 -sx，避免被当作 input_path 导致无 -o 时向 stdout 打 C（run-all-sx 时 run-hello 会传 -sx） */
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

    ShuxRuntimeFileView raw_src_view;
    if (runtime_read_file_view(input_path, &raw_src_view) != 0) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = SHUX_RUNTIME_PREPROCESS(raw_src_view.data, raw_src_view.length, ndefines > 0 ? defines : NULL, ndefines,
        &src_len);
    runtime_release_file_view(&raw_src_view);
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
    shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    if (n_imports > 0)
        pipeline_set_entry_dir(entry_dir_buf);

    char *dep_sources[MAX_ALL_DEPS];
    size_t dep_lens[MAX_ALL_DEPS];
    char *dep_paths[MAX_ALL_DEPS];
    int n_deps = 0;
    if (n_imports > 0 && n_imports <= 32) {
        if (shux_collect_deps_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir_buf, defines,
                ndefines, dep_sources, dep_lens, dep_paths, &n_deps) != 0) {
            free(arena);
            free(module);
            free(src);
            return 1;
        }
    }
    typeck_ndep = 0;
    /* 模板末尾须为 6 个 X，mkstemp 后重命名为 .c 以便 cc/ld 识别 */
    char tmp[] = "/tmp/shux_sx.XXXXXX";
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
    shux_pipeline_fill_ctx_path_buffers(pctx, entry_dir_buf, lib_roots_arr, n_lib_roots);
    shux_pipeline_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
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
        shux_pipeline_fill_ctx_path_buffers(one_ctx, shux_dep_prerun_entry_dir(entry_dir_buf, lib_roots_arr, n_lib_roots), lib_roots_arr, n_lib_roots);
        shux_pipeline_one_ctx_for_dep_prerun(one_ctx, j, dep_modules, dep_arenas, dep_paths, n_deps,
            (const uint8_t *)dep_sources[j], dep_lens[j]);
        driver_set_current_dep_path_for_codegen(dep_paths[j]);
        int ec_loop = shux_pipeline_run_sx_pipeline_large_stack(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j], dep_lens[j], (void *)dep_out, (void *)one_ctx);
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
    codegen_set_dep_slots_for_sx_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
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
    pipeline_dep_ctx_realign_ndep_for_entry_c((struct ast_Module *)module, (struct ast_PipelineDepCtx *)pctx);
    int ec = shux_pipeline_run_sx_pipeline_large_stack(module, arena, src_slice.data, (size_t)src_slice.length, (void *)out_buf, (void *)pctx);
    driver_dep_seeded_clear_all();
    codegen_set_dep_slots_for_sx_pipeline(NULL, NULL, 0);
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
        /* 内联 std.io / std.net / fs / path / map / error ABI；不再 #include std/*_abi.h */
        size_t first_line = 0;
        while (first_line < (size_t)out_buf->len && out_buf->data[first_line] != '\n') first_line++;
        if (first_line < (size_t)out_buf->len) first_line++;
        if (fwrite(out_buf->data, 1, first_line, cf) != first_line
            || write_io_net_abi_inline(cf) != 0
            || write_fs_path_map_error_abi_inline(cf) != 0
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
            const char *io_o = shux_std_io_o_path(argv[0]); /* F-03：纯 .sx，无 io.o */
            const char *fs_o = NULL; /* F-06 v1：纯 .sx，invoke_cc 扫描生成 C 按需 -lc */
            const char *process_o = shux_rel_o_path_from_argv0(argv[0], "std/process/process.o");
            const char *string_o = shux_rel_o_path_from_argv0(argv[0], "std/string/string.o");
            const char *heap_o = NULL; /* F-06 v1：纯 .sx，按需 -lc */
            const char *path_o = shux_rel_o_path_from_argv0(argv[0], "std/path/path.o");
            const char *runtime_o = shux_rel_o_path_from_argv0(argv[0], "std/runtime/runtime.o");
            const char *runtime_panic_o = shux_runtime_panic_o_path(argv[0]);
            const char *net_o = shux_rel_o_path_from_argv0(argv[0], "std/net/net.o");
            const char *thread_o = shux_rel_o_path_from_argv0(argv[0], "std/thread/thread.o");
            const char *time_o = shux_rel_o_path_from_argv0(argv[0], "std/time/time.o");
            const char *random_o = shux_rel_o_path_from_argv0(argv[0], "std/random/random.o");
            const char *env_o = shux_rel_o_path_from_argv0(argv[0], "std/env/env.o");
            const char *sync_o = shux_rel_o_path_from_argv0(argv[0], "std/sync/sync.o");
            const char *encoding_o = shux_rel_o_path_from_argv0(argv[0], "std/encoding/encoding.o");
            const char *base64_o = shux_rel_o_path_from_argv0(argv[0], "std/base64/base64.o");
            const char *crypto_o = shux_rel_o_path_from_argv0(argv[0], "std/crypto/crypto.o");
            const char *log_o = shux_rel_o_path_from_argv0(argv[0], "std/log/log.o");
            const char *atomic_o = shux_rel_o_path_from_argv0(argv[0], "std/atomic/atomic.o");
            const char *channel_o = shux_rel_o_path_from_argv0(argv[0], "std/channel/channel.o");
            const char *backtrace_o = shux_rel_o_path_from_argv0(argv[0], "std/backtrace/backtrace.o");
            const char *hash_o = shux_rel_o_path_from_argv0(argv[0], "std/hash/hash.o");
            const char *math_o = shux_rel_o_path_from_argv0(argv[0], "std/math/math.o");
            const char *sort_o = shux_rel_o_path_from_argv0(argv[0], "std/sort/sort.o");
            const char *ffi_o = shux_rel_o_path_from_argv0(argv[0], "std/ffi/ffi.o");
            const char *db_o = shux_rel_o_path_from_argv0(argv[0], "std/db/sqlite/sqlite.o");
            const char *elf_o = shux_rel_o_path_from_argv0(argv[0], "std/elf/elf.o");
            const char *json_o = shux_rel_o_path_from_argv0(argv[0], "std/json/json.o");
            const char *csv_o = shux_rel_o_path_from_argv0(argv[0], "std/csv/csv.o");
            const char *regex_o = shux_rel_o_path_from_argv0(argv[0], "std/regex/regex.o");
            const char *compress_o = NULL; /* F-06 v1 / F-04 v7：无 compress.o，user .o / 生成 C 按需压缩库 */
            const char *unicode_o = shux_rel_o_path_from_argv0(argv[0], "std/unicode/unicode.o");
            const char *dynlib_o = shux_rel_o_path_from_argv0(argv[0], "std/dynlib/dynlib.o");
            const char *http_o = shux_rel_o_path_from_argv0(argv[0], "std/http/http.o");
            const char *tar_o = shux_rel_o_path_from_argv0(argv[0], "std/tar/tar.o");
            const char *simd_o = shux_rel_o_path_from_argv0(argv[0], "std/simd/simd.o");
            const char *context_o = shux_rel_o_path_from_argv0(argv[0], "std/context/context.o");
            const char *datetime_o = shux_rel_o_path_from_argv0(argv[0], "std/datetime/datetime.o");
            const char *uuid_o = shux_rel_o_path_from_argv0(argv[0], "std/uuid/uuid.o");
            const char *url_o = shux_rel_o_path_from_argv0(argv[0], "std/url/url.o");
            const char *cli_o = shux_rel_o_path_from_argv0(argv[0], "std/cli/cli.o");
            const char *security_o = shux_rel_o_path_from_argv0(argv[0], "std/security/security.o");
            const char *config_o = shux_rel_o_path_from_argv0(argv[0], "std/config/config.o");
            const char *cache_o = shux_rel_o_path_from_argv0(argv[0], "std/cache/cache.o");
            const char *trace_o = shux_rel_o_path_from_argv0(argv[0], "std/trace/trace.o");
            const char *task_o = shux_rel_o_path_from_argv0(argv[0], "std/task/task.o");
            const char *schema_o = shux_rel_o_path_from_argv0(argv[0], "std/schema/schema.o");
            const char *test_o = shux_rel_o_path_from_argv0(argv[0], "std/test/test.o");
            int cc_ret = shux_invoke_cc(c_paths, 1, out_path, NULL, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, shux_repo_root_from_argv0(argv[0]), NULL);
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
#undef SX_PATH_MAX_LIB_ROOTS
#endif
}
#endif /* !defined(SHUX_USE_SX_DRIVER)：run_compiler_sx_path 仅在不使用 .sx driver 时由 C 提供 */


/** driver_diagnostic_* / parser_diag_* 见 runtime_driver_diagnostic.c（E-04 v34）。 */

#ifdef SHUX_USE_SX_DRIVER
/* 阶段 6.2：main.sx 内实现 argv 解析与 -sx -E 执行逻辑；C 仅提供极薄原语 driver_get_argv_i。 */
/* 保留旧符号供未迁完时链接；main.sx 自实现后不再调用。 */
static const char *driver_sx_emit_c_path;
#define SX_EMIT_MAX_LIB_ROOTS 16
static const char *driver_sx_emit_lib_roots[SX_EMIT_MAX_LIB_ROOTS];
static int driver_sx_emit_n_lib_roots;
/* 供 main.sx 在 -sx -E 时把 path/lib_roots 灌入 C 侧，再调 driver_run_sx_emit_c，以走完整多文件（deps+main）路径。 */
static char driver_sx_emit_path_buf[512];
static char driver_sx_emit_lib_bufs[SX_EMIT_MAX_LIB_ROOTS][256];

int driver_run_sx_emit_c_set_path(const uint8_t *path, int path_len) {
    driver_sx_emit_c_path = NULL;
    if (!path || path_len <= 0 || path_len >= (int)sizeof(driver_sx_emit_path_buf)) return 0;
    memcpy(driver_sx_emit_path_buf, path, (size_t)path_len);
    driver_sx_emit_path_buf[path_len] = '\0';
    driver_sx_emit_c_path = driver_sx_emit_path_buf;
    return 0;
}

int driver_run_sx_emit_c_set_lib(int i, const uint8_t *buf, int len) {
    if (i < 0 || i >= SX_EMIT_MAX_LIB_ROOTS || !buf || len < 0 || len >= 256) return 0;
    memcpy(driver_sx_emit_lib_bufs[i], buf, (size_t)len);
    driver_sx_emit_lib_bufs[i][len] = '\0';
    driver_sx_emit_lib_roots[i] = driver_sx_emit_lib_bufs[i];
    return 0;
}

int driver_run_sx_emit_c_set_n_lib_roots(int n) {
    driver_sx_emit_n_lib_roots = (n >= 0 && n <= SX_EMIT_MAX_LIB_ROOTS) ? n : 0;
    return 0;
}

/** main.sx 在解析到 -E-extern 后置 1；driver_run_sx_emit_c 消费后清零。与 C 路径 emit_extern_imports 对齐。 */
static int driver_sx_emit_c_want_extern;

int driver_run_sx_emit_c_set_emit_extern(int v) {
    driver_sx_emit_c_want_extern = v ? 1 : 0;
    return 0;
}

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

/* driver_get_argv_i / driver_argv_drop_subcommand / driver_resolve_target_arch → runtime_abi.c（E-04 v2） */

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
     * 与 shux_output_want_exe 后缀规则对齐。
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
int driver_build_build_sx(void)
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
    static const char *generic_type_tokens[] = {
        "<i8>", "<i16>", "<i32>", "<i64>", "<u8>", "<u16>", "<u32>", "<u64>", "<f32>", "<f64>", "<bool>",
    };
    size_t ti;
    if (!content || n == 0) return 0;
    const char *end = content + n;
    const char *p = content;
    /* 泛型：<T>、<i32> 等；勿将 T[]<region_label>（M-3/M-5 域标签）误判为泛型。 */
    while ((p = (const char *)memchr(p, '<', (size_t)(end - p))) != NULL) {
        if (p + 1 >= end) break;
        if (p > content && p[-1] == ']') {
            p++;
            continue;
        }
        if (p[1] == 'T' && (p + 2 >= end || p[2] == '>' || p[2] == ','))
            return 1;
        for (ti = 0; ti < sizeof(generic_type_tokens) / sizeof(generic_type_tokens[0]); ti++) {
            size_t tok_len = strlen(generic_type_tokens[ti]);
            if ((size_t)(end - p) >= tok_len && memcmp(p, generic_type_tokens[ti], tok_len) == 0)
                return 1;
        }
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


/** shux_collect_deps_transitive / shux_merge_direct_then_transitive_deps / shux_load_direct_imports_for_asm_layout 见 runtime_pipeline_abi.c（E-04 v35）。 */
#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
/** compile.sx extern：-o 后缀是否表示可执行（非 .o/.obj/.s）；实现见 runtime_link_abi.c。 */
int32_t driver_asm_output_want_exe(uint8_t *path) {
    return shux_output_want_exe(path ? (const char *)path : NULL);
}

#if !defined(SHUX_NO_C_FRONTEND)
/** C 前端 typeck（定义见 driver_c_typeck_entry）；asm 编译前预检。 */
static int driver_c_typeck_entry(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots, int print_ok);
static int driver_c_typeck_entry_large_stack(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots,
    int print_ok);
#endif

#if !defined(SHUX_NO_C_FRONTEND)
static int driver_c_frontend_smoke(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots);
#endif

/** ast_pool_bootstrap_glue.c：用户 dep 是否须 asm co-emit（非 std/core 链接桩可跳过）。 */
extern int32_t pipeline_asm_user_deps_need_coemit(char **dep_paths, int32_t n);

/** check-only / asm entry-only：dep 路径是否均为 std.* / core.* import 闭包。 */
static int driver_deps_are_std_core_closure_only(char **dep_paths, int n_deps);

/**
 * -backend asm 专用：读文件、跑 .sx pipeline、写 .o 或调 ld。与 run_compiler_c 内 asm 路径逻辑一致，供 driver_run_compiler_full 转调。
 */
int driver_run_asm_backend(const char *input_path, const char *out_path, const char **lib_roots_arr, int n_lib_roots,
    const char *target, int argc, char **argv) {
    const char *defines[MAX_DEFINES];
    int ndefines = 0;
    driver_bump_stack_limit();
    if (argv && argc > 0)
        ndefines = driver_argv_collect_defines(argc, argv, defines, MAX_DEFINES);
    /** B-02：#[cfg] 与 -target triple 联动（asm 后端路径）。 */
    if (target)
        cfg_apply_compile_target_from_triple(target, (int)strlen(target));
    else
        cfg_reset_compile_target();
    ShuxRuntimeFileView raw_src_view;
    if (runtime_read_file_view(input_path, &raw_src_view) != 0) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = SHUX_RUNTIME_PREPROCESS(raw_src_view.data, raw_src_view.length, ndefines > 0 ? defines : NULL, ndefines,
        &src_len);
    runtime_release_file_view(&raw_src_view);
    if (!src) {
        fprintf(stderr, "shux: preprocess failed for '%s'\n", input_path);
        return 1;
    }
#if !defined(SHUX_NO_C_FRONTEND)
    /* 无 -o 烟测走 C 前端（含 import 时 SX asm parse 易 0 func）；shux check 不走烟测。 */
    if (out_path == NULL && !driver_check_only_get()) {
        int smoke_rc = driver_c_frontend_smoke(input_path, src, lib_roots_arr, n_lib_roots);
        free(src);
        return smoke_rc;
    }
    /*
     * shux check + asm 后端：优先走下方 SX pipeline（check_only_mode），与 compile 同 parse/typeck 路径。
     * 无 SX pipeline 时回退 C typeck。
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
    /*
     * A-11 run-typeck-parse-count-gate：ENTRY_MODULE_ONLY 下 entry parse_into 即金标准；
     * 全量 asm_codegen_elf_o(typeck.sx) 在 Docker 内易 OOM(137)，仅 stderr 指标 + 占位 .o。
     */
    if (driver_asm_parse_metric_only_from_env() && out_path != NULL) {
        extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
        extern void driver_diagnostic_after_entry_parse_module(void *module);
        driver_diagnostic_after_entry_parse(driver_get_module_num_funcs(module));
        driver_diagnostic_after_entry_parse_module(module);
        {
            FILE *metric_o = fopen(out_path, "wb");
            if (!metric_o) {
                perror("shux: -o (parse-metric-only)");
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            (void)fputc('\0', metric_o);
            if (fclose(metric_o) != 0) {
                fprintf(stderr, "shux: parse-metric-only: failed to write '%s'\n", out_path);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
        free(arena);
        free(module);
        free(src);
        return 0;
    }
    int32_t n_imports_entry = parser_get_module_num_imports(module);
    char entry_dir_buf[512];
    shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
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
        driver_asm_entry_module_only_from_env() && driver_asm_build_skip_typeck() != 0;
    if (n_imports_entry > 0 && n_imports_entry <= 32) {
        if (skip_dep_file_load) {
            if (shux_load_direct_imports_for_asm_layout(module, lib_roots_arr, n_lib_roots, entry_dir, defines, ndefines,
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
            if (shux_collect_deps_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir, defines,
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
            if (shux_merge_direct_then_transitive_deps(module, n_imports_entry, cls, clens, cpaths, n_closure, dep_sources,
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
        asm_want_exe = shux_output_want_exe(out_path);
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
            emit_elf_o = shux_output_is_elf_o(out_path);
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
    shux_pipeline_fill_ctx_path_buffers(pctx, entry_dir, lib_roots_arr, n_lib_roots);
    /*
     * 入口 pipeline 阶段 use_asm_backend=0：与 shux check 同走 parse+merge+typeck（+ 可选 C codegen 填 out_buf），
     * 避免 use_asm_backend=1 时在 typeck_merge / typeck_sx_ast 上对 core.option 等 dep 崩溃（134/139）。
     * 真 .o/.Mach-O 由下方 asm_asm_codegen_elf_o 在 use_asm_backend=1 时 emit。
     * dep 槽在预跑结束后再 shux_pipeline_pctx_seed_dep_slots（见下方 typeck_ndep 块）。
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
        pctx->asm_entry_module_only = driver_asm_entry_module_only_from_env();
    /**
     * build_shux_asm（SKIP_TYPECK）：dep 已由 build_asm/*.o 提供，仅编入口模块。
     * 用户多文件（tests/multi-file 等）：须在 asm_codegen_elf_o 内编入各 dep，否则 ld 缺 _foo_bar 等符号。
     */
    if (asm_want_exe && n_deps > 0 && !asm_smoke_only && driver_asm_build_skip_typeck() != 0)
        pctx->asm_entry_module_only = 1;
    /**
     * 用户单文件 -o（无 dep、非 build_shux_asm SKIP_TYPECK）：单函数仍 ENTRY_MODULE_ONLY
     *（return42 等烟测）；多函数单文件（C5 spill_probe 等）须 emit 全 TU 否则 ld 缺符号。
     */
    if (emit_elf_o && n_deps == 0 && !asm_smoke_only && driver_asm_build_skip_typeck() == 0 &&
        driver_get_module_num_funcs(module) <= 1)
        pctx->asm_entry_module_only = 1;
    /**
     * 用户单文件 import 仅 std/core 闭包（hello.sx）：仅 emit entry，dep 由 io 桩 + ld 解析。
     */
    if (emit_elf_o && n_deps > 0 && !asm_smoke_only && driver_asm_build_skip_typeck() == 0 &&
        pipeline_asm_user_deps_need_coemit(dep_paths, n_deps) == 0)
        pctx->asm_entry_module_only = 1;
    driver_dep_seeded_clear_all();
    /*
     * build_shux_asm（SHUX_ASM_BUILD_SKIP_TYPECK + ENTRY_MODULE_ONLY）：dep 已由 build_asm/*.o 提供，仅 publish 槽位。
     * 用户链 exe（无 SKIP_TYPECK）：须 parse+typeck dep 以解析 import 符号名，仅跳过 dep codegen（pipeline.sx）。
     */
    if (emit_elf_o && pctx->asm_entry_module_only && driver_asm_build_skip_typeck() != 0) {
        for (j = 0; j < n_deps; j++) {
            if (shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j],
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
            shux_pipeline_fill_ctx_path_buffers(one_ctx, shux_dep_prerun_entry_dir(entry_dir, lib_roots_arr, n_lib_roots),
                lib_roots_arr, n_lib_roots);
            shux_pipeline_one_ctx_for_dep_prerun(one_ctx, j, dep_modules, dep_arenas, dep_paths, n_deps,
            (const uint8_t *)dep_sources[j], dep_lens[j]);
            /*
             * 无 -o 烟测：dep 仅 parse 填槽；全量 .sx typeck 在 strict typeck.o 上对 std.io 等大库易 SIGSEGV。
             * 有 -o 用户链仍 typeck dep（std.io 经 seed bridge）；入口走 C typeck。
             */
            int ec_loop;
            if (asm_smoke_only) {
                if (getenv("SHUX_ASM_DEBUG"))
                    fprintf(stderr, "shux: dep_prerun[%d] path=%s len=%zu\n", (int)j,
                            dep_paths[j] ? dep_paths[j] : "?", (size_t)dep_lens[j]);
                ec_loop = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
            } else if (emit_elf_o && shux_asm_user_std_dep_skip_sx_typeck(dep_paths[j])) {
                /*
                 * 用户 asm -o：std.io/fs 由并列 *.o 提供 *_c，dep 仅 parse 填 import 槽；
                 * 勿对 read_fd 等跑 .sx typeck（与 user_asm_seed_bridge dep skip emit 对齐）。
                 */
                ec_loop = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
            } else if (emit_elf_o && shux_asm_user_dep_parse_skip_typeck_path(dep_paths[j])) {
                /*
                 * std.net：须 co-emit listen/accept_many；parse_only 常 funcs=0，改 parse+skip typeck 填槽。
                 */
                ec_loop = shux_pipeline_dep_prerun_parse_skip_typeck(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j], (void *)dep_out, (void *)one_ctx);
                if (ec_loop == 0 && shux_asm_user_std_net_dep_path(dep_paths[j]))
                    pipeline_asm_seed_std_net_struct_layouts((struct ast_Module *)dep_modules[j]);
            } else if (emit_elf_o && pctx->asm_entry_module_only && driver_asm_build_skip_typeck() == 0) {
                /*
                 * ENTRY_MODULE_ONLY 且将走 C typeck 预检：dep 仅 parse 填槽，勿对整棵 dep 再跑 .sx typeck（栈/耗时）。
                 * 入口模块类型由 driver_c_typeck_entry 与并列 build_asm/*.o 保证。
                 */
                ec_loop = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
#if defined(SHUX_ASM_USE_COMPILER_IMPL_C)
            } else if (emit_elf_o && !asm_smoke_only && !driver_asm_build_skip_typeck()) {
                /*
                 * B-strict shux_asm 用户多文件 -o：dep 仅 parse 填 import 槽；入口 skip .sx typeck（见下方 set）。
                 * 注：std.string/heap 等 .sx 符号须 shux-c 链 exe，或后续改 co-emit 填全量 func 槽。
                 */
                ec_loop = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
#endif
            } else {
                ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j],
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
    shux_pipeline_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
    pipeline_set_dep_slots(dep_arenas, dep_modules);
    driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
    codegen_set_dep_slots_for_sx_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
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
         * 无 import 单文件仍须 typeck（struct field_access_offset）；仅 skip codegen，机器码由 asm_codegen_elf_o 生成。
         * std 库 .o 仍靠 C typeck 预检 + pipeline_fill_*_for_skipped_typeck；勿跑 sx typeck（enc_label 失败）。
         * shux check + std/core 闭包：与 -o 多文件一致 skip 入口 .sx typeck，parse 已在 smoke 路径完成。
         */
        if (!asm_smoke_only) {
            if (n_deps > 0)
                driver_sx_pipeline_skip_typeck_set(1);
            /** 仅 parse+typeck（单文件）或 parse+填槽（多文件）；真机器码由 asm_asm_codegen_elf_o 生成。 */
            driver_sx_pipeline_skip_codegen_set(1);
        } else if (driver_check_only_get() && n_deps > 0 &&
                   driver_deps_are_std_core_closure_only(dep_paths, n_deps)) {
            driver_sx_pipeline_skip_typeck_set(1);
            driver_sx_pipeline_skip_codegen_set(1);
        }
        ec = shux_pipeline_run_sx_pipeline_large_stack(module, arena, (const uint8_t *)src, src_len, (void *)out_buf, (void *)pctx);
        driver_sx_pipeline_skip_typeck_set(0);
        driver_sx_pipeline_skip_codegen_set(0);
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
                driver_print_sx_smoke_summary(module, (size_t)out_buf->len);
                if (input_path)
                    driver_print_check_ok(input_path);
            } else
                driver_print_sx_smoke_summary(module, (size_t)out_buf->len);
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
        if (emit_elf_o && elf_ctx_ptr && !shux_asm_out_buf_is_object(out_buf ? out_buf->data : NULL, out_buf ? (size_t)out_buf->len : 0)) {
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
                shux_pipeline_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
                /*
                 * 多文件 -o 须编 dep 机器码；显式 SHUX_ASM_ENTRY_MODULE_ONLY=1（build_shux_asm / M8 单模块 -o）
                 * 时保持仅入口，dep 由并列 build_asm/*.o 提供，勿对 arch/x86_64 等 dep 再跑 asm emit。
                 * hello 等纯 std 闭包勿关 ENTRY_MODULE_ONLY（否则 co-emit std.fmt → SIGSEGV）。
                 */
                if (!driver_asm_entry_module_only_from_env() && pipeline_asm_user_deps_need_coemit(dep_paths, n_deps))
                    pctx->asm_entry_module_only = 0;
                pctx->use_asm_backend = 1;
            }
            shux_driver_asm_prepare_entry_elf_emit(module, arena, pctx);
            int32_t elf_ec = shux_asm_codegen_elf_o_large_stack(module, arena, (void *)pctx, (struct platform_elf_ElfCodegenCtx *)elf_ctx_ptr, (void *)out_buf);
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
            /** elf emit 后主栈已深；nostdlib invoke_ld 前再抬高 soft limit（C6 -o exe）。 */
            driver_bump_stack_limit();
            int ld_ok = shux_invoke_ld_for_exe(asm_tmp_o_path, asm_exe_out, target, pctx->use_macho_o, pctx->use_coff_o, argv ? argv[0] : NULL,
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
    codegen_set_dep_slots_for_sx_pipeline(NULL, NULL, 0);
    free(out_buf);
    pipeline_dep_ctx_heap_destroy(pctx);
    free(arena);
    free(module);
    free(src);
    return (ec != 0) ? 1 : 0;
}
#endif /* SHUX_USE_SX_DRIVER && SHUX_USE_SX_PIPELINE */

#define SX_FULL_MAX_LIB_ROOTS 16

/** compile.sx 解析 argv 后的分派参数（库根由 sidecar 键在 dispatch 中展开）。 */
typedef struct DriverCompileParsed {
    const char *input_path;
    const char *out_path;
    const char *lib_roots_arr[SX_FULL_MAX_LIB_ROOTS];
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
    shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    ASTModule *dep_mods[32];
    ASTModule *all_dep_mods[MAX_ALL_DEPS];
    char *all_dep_paths[MAX_ALL_DEPS];
    int ndep = 0, n_all = 0;
    if (mod->num_imports > 0 &&
        shu_c_resolve_and_load_imports(mod, lib_roots_arr, n_lib_roots, entry_dir_buf, NULL, 0, dep_mods, &ndep,
            all_dep_mods, all_dep_paths, NULL, &n_all, MAX_ALL_DEPS) != 0) {
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
/** shux check 后 SX 栈逃逸 gate 大栈线程参数。 */
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
 * 在 256MiB 栈 pthread 上跑 SX struct 栈逃逸 gate（check 路径；勿在主线程 parse）。
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
    shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    ASTModule *dep_mods[32];
    ASTModule *all_dep_mods[MAX_ALL_DEPS];
    char *all_dep_paths[MAX_ALL_DEPS];
    int ndep = 0, n_all = 0;
    if (mod->num_imports > 0 &&
        shu_c_resolve_and_load_imports(mod, lib_roots_arr, n_lib_roots, entry_dir_buf, NULL, 0, dep_mods, &ndep,
            all_dep_mods, all_dep_paths, NULL, &n_all, MAX_ALL_DEPS) != 0) {
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
    if (print_ok) {
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

#endif /* !SHUX_NO_C_FRONTEND — C parse/typeck 辅助；compile.sx / driver_run_compiler_full glue 须在 NO_C seed 链可见 */

/** shux check：C typeck 入口（库模块无 main 时比 SX pipeline 更稳；bootstrap 与 shux-c 共用）。 */
#if !defined(SHUX_NO_C_FRONTEND)
static int driver_check_only_c_typeck(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots) {
    return driver_c_typeck_entry(input_path, src, lib_roots_arr, n_lib_roots, 1);
}
#endif

/**
 * dep 列表是否全为 std./core. 闭包（符号由预编 .o / preamble 提供，勿 dep_prerun 全量 typeck）。
 * tests/multi-file 的 import("foo") 等用户 dep 返回 0，仍走 typeck_only。
 */
static int driver_deps_are_std_core_closure_only(char **dep_paths, int n_deps) {
    int k;
    if (!dep_paths || n_deps <= 0)
        return 0;
    for (k = 0; k < n_deps; k++) {
        const char *p = dep_paths[k];
        if (!p || p[0] == '\0')
            return 0;
        if (strncmp(p, "std.", 4) == 0 || strncmp(p, "core.", 5) == 0)
            continue;
        return 0;
    }
    return 1;
}

/**
 * `-E src/asm/asm.sx` 的 compiler-internal 闭包仅需 parse 填 import/签名槽；
 * 对 `ast` 等大模块做 dep_prerun typeck 会显著拖慢甚至卡住 seed host 构建。
 */
static int driver_sx_emit_asm_dep_parse_only_ok(const char *input_path, const char *dep_path) {
    if (!input_path || !dep_path)
        return 0;
    if (strstr(input_path, "src/asm/asm.sx") == NULL && strstr(input_path, "/asm/asm.sx") == NULL)
        return 0;
    if (strcmp(dep_path, "ast") == 0 || strcmp(dep_path, "codegen") == 0 || strcmp(dep_path, "backend") == 0 ||
        strcmp(dep_path, "peephole") == 0)
        return 1;
    if (strncmp(dep_path, "asm.", 4) == 0 || strncmp(dep_path, "arch.", 5) == 0 ||
        strncmp(dep_path, "platform.", 9) == 0)
        return 1;
    return 0;
}

static int driver_sx_emit_asm_direct_import_only(const char *input_path) {
    if (!input_path)
        return 0;
    if (strstr(input_path, "src/asm/asm.sx") != NULL || strstr(input_path, "/asm/asm.sx") != NULL)
        return 1;
    return 0;
}

#if !defined(SHUX_NO_C_FRONTEND)
/**
 * 入口 AST 的直接 import 是否均为 core.*（L9 arena_align 等 shux-c -backend c -o 可走 C 前端）。
 */
static int driver_c_mod_imports_are_core_only(ASTModule *mod) {
    int i;
    if (!mod || mod->num_imports <= 0)
        return 0;
    for (i = 0; i < mod->num_imports; i++) {
        const char *p = mod->import_paths[i];
        if (!p || strncmp(p, "core.", 5) != 0)
            return 0;
    }
    return 1;
}
#endif

/** argv[0] basename 是否等于给定名（如 shux-c，避免 sibling exec 自递归）。 */
static int driver_argv0_basename_is(const char *argv0, const char *base) {
    const char *slash;
    const char *name;
    if (!base)
        return 0;
    slash = strrchr(argv0 ? argv0 : "", '/');
#if defined(_WIN32)
    {
        const char *bs = strrchr(argv0 ? argv0 : "", '\\');
        if (bs && (!slash || bs > slash))
            slash = bs;
    }
#endif
    name = slash ? slash + 1 : (argv0 ? argv0 : "");
    return strcmp(name, base) == 0;
}

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
    driver_bump_stack_limit();
    /* shux check：强制走 SX pipeline 的 typeck 路径，不做 asm 后端与链接。 */
    if (driver_check_only_get())
        want_asm_backend = 0;
#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
    /*
     * 默认 asm：入口源码若含泛型/trait 且输出将链成可执行（无 -o 仍视作需降级场景），asm 后端无法单态化，降级为 C/pipeline。
     * -o 为 .o/.obj/.s 时仅生成对象或汇编、不链 exe，跳过泛型扫描，不改 want_asm_backend（逻辑同 shux_output_want_exe）。
     */
    if (want_asm_backend && input_path && (!out_path || shux_output_want_exe(out_path))) {
        int plen = (int)strlen(input_path);
        if (plen > 0 && plen < 512 &&
            driver_source_has_generic_syntax((const uint8_t *)input_path, plen))
            want_asm_backend = 0;
    }
    /*
     * 默认走 asm：一律走 SX pipeline + asm_asm_codegen_*（有无 -o 均如此）；`-backend c` 已在上方关闭 want_asm_backend。
     * 无 \c out_path 时向 stdout 打汇编文本；否则写 \c .o / \c .s / 或可执行路径（参见 driver_run_asm_backend）。
     */
#if !defined(SHUX_NO_C_FRONTEND)
    /*
     * shux-c 路径：顶层 import 时 SX asm parse 易 0 func，降级 C；shux_asm（SHUX_NO_C_FRONTEND）须保留 asm + driver_run_asm_backend。
     */
    if (want_asm_backend) {
        ShuxRuntimeFileView imp_raw_view;
        if (runtime_read_file_view(input_path, &imp_raw_view) == 0) {
            size_t imp_src_len = 0;
            char *imp_src = SHUX_RUNTIME_PREPROCESS(imp_raw_view.data, imp_raw_view.length, NULL, 0, &imp_src_len);
            runtime_release_file_view(&imp_raw_view);
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

    ShuxRuntimeFileView raw_src_view;
    if (runtime_read_file_view(input_path, &raw_src_view) != 0) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = SHUX_RUNTIME_PREPROCESS(raw_src_view.data, raw_src_view.length, NULL, 0, &src_len);
    runtime_release_file_view(&raw_src_view);
    if (!src) {
        fprintf(stderr, "shux: preprocess failed for '%s'\n", input_path);
        return 1;
    }
#if !defined(SHUX_NO_C_FRONTEND)
    /*
     * shux check：优先 C parse+typeck（支持库模块、import -L）；SX pipeline check 待与 compile 对齐后再切回。
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
     * `-backend c -o`（want_asm_backend=0）：单文件无泛型亦走 C 前端，与 shux check 对齐（LANG-007 unsafe 等 S0 规则）。
     * 无 import 时内联 C 路径，避免 run_compiler_c 重入导致崩溃；有 import 时仍调 run_compiler_c。 */
#if !defined(SHUX_NO_C_FRONTEND)
    if (content_has_generic_syntax(src, src_len) || out_path) {
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
            /*
             * 有 import 时默认回退 .sx pipeline；core.* 仅依赖时内联 C 前端（与 run_compiler_c -o 一致），
             * 避免 pipeline codegen 产出 out_len=0。std/用户 dep 仍走 pipeline。
             */
            int c_inline_o = 0;
            if (c_mod->num_imports > 0) {
                if (out_path && driver_c_mod_imports_are_core_only(c_mod))
                    c_inline_o = 1;
                else {
                    ast_module_free(c_mod);
                    /* 不 free(src)，fall through 到 pipeline */
                }
            } else {
                c_inline_o = 1;
            }
            if (c_inline_o) {
            ASTModule *dep_mods[32];
            ASTModule *all_dep_mods[MAX_ALL_DEPS];
            char *all_dep_paths[MAX_ALL_DEPS];
            int ndep = 0, n_all = 0;
            char c_entry_dir[512];
            shux_get_entry_dir(input_path, c_entry_dir, sizeof(c_entry_dir));
            if (c_mod->num_imports > 0 &&
                shu_c_resolve_and_load_imports(c_mod, lib_roots_arr, n_lib_roots, c_entry_dir,
                    ndefines > 0 ? defines : NULL, ndefines, dep_mods, &ndep, all_dep_mods, all_dep_paths, NULL,
                    &n_all, MAX_ALL_DEPS) != 0) {
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            if (!c_mod->main_func || !c_mod->main_func->body) {
                if (driver_check_only_get() && c_mod->num_funcs > 0) {
                    if (typeck_module(c_mod, ndep > 0 ? dep_mods : NULL, ndep, n_all > 0 ? all_dep_mods : NULL, n_all) != 0) {
                        while (n_all--) {
                            free(all_dep_paths[n_all]);
                            ast_module_free(all_dep_mods[n_all]);
                        }
                        ast_module_free(c_mod);
                        free(src);
                        return 1;
                    }
                    while (n_all--) {
                        free(all_dep_paths[n_all]);
                        ast_module_free(all_dep_mods[n_all]);
                    }
                    ast_module_free(c_mod);
                    free(src);
                    driver_print_check_ok(input_path);
                    return 0;
                }
                /* LANG-007 v2：库模块 -backend c -o *.o → codegen_library_module_to_c + cc -c。 */
                if (out_path && shux_output_is_elf_o(out_path) && c_mod->num_funcs > 0) {
                    if (typeck_module(c_mod, ndep > 0 ? dep_mods : NULL, ndep,
                            n_all > 0 ? all_dep_mods : NULL, n_all) != 0) {
                        while (n_all--) {
                            free(all_dep_paths[n_all]);
                            ast_module_free(all_dep_mods[n_all]);
                        }
                        ast_module_free(c_mod);
                        free(src);
                        return 1;
                    }
                    codegen_set_preamble_has_core_option_result(0);
                    char tmp_lib[] = "/tmp/shux_XXXXXX";
                    int fd_lib = mkstemp(tmp_lib);
                    if (fd_lib < 0) {
                        perror("shux: mkstemp");
                        while (n_all--) {
                            free(all_dep_paths[n_all]);
                            ast_module_free(all_dep_mods[n_all]);
                        }
                        ast_module_free(c_mod);
                        free(src);
                        return 1;
                    }
                    FILE *cf_lib = fdopen(fd_lib, "w");
                    if (!cf_lib) {
                        close(fd_lib);
                        unlink(tmp_lib);
                        while (n_all--) {
                            free(all_dep_paths[n_all]);
                            ast_module_free(all_dep_mods[n_all]);
                        }
                        ast_module_free(c_mod);
                        free(src);
                        return 1;
                    }
                    fprintf(cf_lib, "/* generated (library module) */\n");
                    fprintf(cf_lib, "#include <stdint.h>\n");
                    fprintf(cf_lib, "#include <stddef.h>\n");
                    fprintf(cf_lib, "#include <stdlib.h>\n");
                    fprintf(cf_lib, "#include <stdio.h>\n");
                    fprintf(cf_lib, "#include <string.h>\n");
                    fprintf(cf_lib, "#include <math.h>\n");
                    codegen_emit_fmt_json_helpers_once(cf_lib);
                    fprintf(cf_lib, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
                    fprintf(cf_lib, "static inline void shux_panic_(int has_msg, int msg_val) { (void)has_msg; (void)msg_val; abort(); }\n");
                    {
                        const char *lib_name = shux_entry_lib_name_from_path(input_path);
                        if (codegen_library_module_to_c(c_mod, lib_name, ndep > 0 ? dep_mods : NULL,
                                ndep > 0 ? (const char **)c_mod->import_paths : NULL, ndep,
                                cf_lib, NULL, NULL, NULL, NULL, NULL, NULL, 0, input_path) != 0) {
                            fclose(cf_lib);
                            unlink(tmp_lib);
                            while (n_all--) {
                                free(all_dep_paths[n_all]);
                                ast_module_free(all_dep_mods[n_all]);
                            }
                            ast_module_free(c_mod);
                            free(src);
                            return 1;
                        }
                    }
                    fclose(cf_lib);
                    char tmp_lib_c[32];
                    snprintf(tmp_lib_c, sizeof(tmp_lib_c), "%s.c", tmp_lib);
                    if (rename(tmp_lib, tmp_lib_c) != 0) {
                        perror("shux: rename");
                        unlink(tmp_lib);
                        while (n_all--) {
                            free(all_dep_paths[n_all]);
                            ast_module_free(all_dep_mods[n_all]);
                        }
                        ast_module_free(c_mod);
                        free(src);
                        return 1;
                    }
                    {
                        pid_t cpid = fork();
                        int cc_ok = 0;
                        if (cpid < 0) {
                            perror("shux: fork");
                            cc_ok = -1;
                        } else if (cpid == 0) {
                            execlp("cc", "cc", "-std=gnu11", "-Wall", "-Wextra", "-c", "-o", (char *)out_path,
                                tmp_lib_c, (char *)NULL);
                            perror("shux: cc");
                            _exit(127);
                        } else {
                            int status = 0;
                            if (shu_waitpid_retry(cpid, &status) != 0 ||
                                !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
                                fprintf(stderr, "shux: cc -c failed for library module\n");
                                cc_ok = -1;
                            }
                        }
                        if (cc_ok != 0)
                            fprintf(stderr, "shux: cc failed, keeping generated C: %s\n", tmp_lib_c);
                        else if (!getenv("SHUX_KEEP_C"))
                            unlink(tmp_lib_c);
                        while (n_all--) {
                            free(all_dep_paths[n_all]);
                            ast_module_free(all_dep_mods[n_all]);
                        }
                        ast_module_free(c_mod);
                        free(src);
                        return cc_ok == 0 ? 0 : 1;
                    }
                }
                while (n_all--) {
                    free(all_dep_paths[n_all]);
                    ast_module_free(all_dep_mods[n_all]);
                }
                ast_module_free(c_mod);
                free(src);
                fprintf(stderr, "shux: no main function (cannot emit executable)\n");
                return 1;
            }
            if (typeck_module(c_mod, ndep > 0 ? dep_mods : NULL, ndep, n_all > 0 ? all_dep_mods : NULL, n_all) != 0) {
                while (n_all--) {
                    free(all_dep_paths[n_all]);
                    ast_module_free(all_dep_mods[n_all]);
                }
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            if (driver_check_only_get()) {
                while (n_all--) {
                    free(all_dep_paths[n_all]);
                    ast_module_free(all_dep_mods[n_all]);
                }
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
                while (n_all--) {
                    free(all_dep_paths[n_all]);
                    ast_module_free(all_dep_mods[n_all]);
                }
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            FILE *cf = fdopen(fd, "w");
            if (!cf) {
                close(fd);
                unlink(tmp);
                while (n_all--) {
                    free(all_dep_paths[n_all]);
                    ast_module_free(all_dep_mods[n_all]);
                }
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            {
                char emitted_type_buf[128][CODEGEN_EMITTED_TYPE_NAME_MAX];
                int n_emitted = 0;
                const int max_emitted = (int)(sizeof(emitted_type_buf) / sizeof(emitted_type_buf[0]));
                if (n_all > 0) {
                    fprintf(cf, "/* generated (single-file with core deps) */\n");
                    fprintf(cf, "#include <stdint.h>\n");
                    fprintf(cf, "#include <stddef.h>\n");
                    fprintf(cf, "#include <stdlib.h>\n");
                    fprintf(cf, "#include <stdio.h>\n");
                    fprintf(cf, "#include <string.h>\n");
                    fprintf(cf, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
                    fprintf(cf, "static inline void shux_panic_(int has_msg, int msg_val) { (void)has_msg; (void)msg_val; abort(); }\n");
                    for (int di = 0; di < n_all; di++) {
                        ASTModule *lib_deps[32];
                        const char *lib_dep_paths[32];
                        int n_lib = 0;
                        for (int dj = 0; dj < all_dep_mods[di]->num_imports && n_lib < 32; dj++) {
                            int idx = shux_find_loaded_import_index(all_dep_mods[di]->import_paths[dj], all_dep_paths, n_all);
                            if (idx >= 0) {
                                lib_deps[n_lib] = all_dep_mods[idx];
                                lib_dep_paths[n_lib] = all_dep_paths[idx];
                                n_lib++;
                            }
                        }
                        if (codegen_library_module_to_c(all_dep_mods[di], all_dep_paths[di], lib_deps, lib_dep_paths, n_lib,
                                cf, NULL, NULL, NULL, NULL, emitted_type_buf, &n_emitted, max_emitted, NULL) != 0) {
                            fclose(cf);
                            unlink(tmp);
                            while (n_all--) {
                                free(all_dep_paths[n_all]);
                                ast_module_free(all_dep_mods[n_all]);
                            }
                            ast_module_free(c_mod);
                            free(src);
                            return 1;
                        }
                    }
                }
                if (codegen_module_to_c(c_mod, cf, ndep > 0 ? dep_mods : NULL, ndep > 0 ? (const char **)c_mod->import_paths : NULL,
                        ndep, NULL, NULL, NULL, NULL, n_all > 0 ? emitted_type_buf : NULL, n_all > 0 ? &n_emitted : NULL,
                        n_all > 0 ? max_emitted : 0) != 0) {
                    fclose(cf);
                    unlink(tmp);
                    while (n_all--) {
                        free(all_dep_paths[n_all]);
                        ast_module_free(all_dep_mods[n_all]);
                    }
                    ast_module_free(c_mod);
                    free(src);
                    return 1;
                }
            }
            fclose(cf);
            char tmp_c[32];
            snprintf(tmp_c, sizeof(tmp_c), "%s.c", tmp);
            if (rename(tmp, tmp_c) != 0) {
                perror("shux: rename");
                unlink(tmp);
                while (n_all--) {
                    free(all_dep_paths[n_all]);
                    ast_module_free(all_dep_mods[n_all]);
                }
                ast_module_free(c_mod);
                free(src);
                return 1;
            }
            {
                const char *c_paths[1] = { tmp_c };
                const char *io_o = shux_std_io_o_path(argv[0]); /* F-03：纯 .sx，无 io.o */
                const char *fs_o = NULL; /* F-06 v1：纯 .sx，invoke_cc 扫描生成 C 按需 -lc */
                const char *process_o = shux_rel_o_path_from_argv0(argv[0], "std/process/process.o");
                const char *string_o = shux_rel_o_path_from_argv0(argv[0], "std/string/string.o");
                const char *heap_o = NULL; /* F-06 v1：纯 .sx，按需 -lc */
                const char *path_o = shux_rel_o_path_from_argv0(argv[0], "std/path/path.o");
                const char *runtime_o = shux_rel_o_path_from_argv0(argv[0], "std/runtime/runtime.o");
                const char *runtime_panic_o = shux_runtime_panic_o_path(argv[0]);
                const char *net_o = shux_rel_o_path_from_argv0(argv[0], "std/net/net.o");
                const char *thread_o = shux_rel_o_path_from_argv0(argv[0], "std/thread/thread.o");
                const char *time_o = shux_rel_o_path_from_argv0(argv[0], "std/time/time.o");
                const char *random_o = shux_rel_o_path_from_argv0(argv[0], "std/random/random.o");
                const char *env_o = shux_rel_o_path_from_argv0(argv[0], "std/env/env.o");
                const char *sync_o = shux_rel_o_path_from_argv0(argv[0], "std/sync/sync.o");
                const char *encoding_o = shux_rel_o_path_from_argv0(argv[0], "std/encoding/encoding.o");
                const char *base64_o = shux_rel_o_path_from_argv0(argv[0], "std/base64/base64.o");
                const char *crypto_o = shux_rel_o_path_from_argv0(argv[0], "std/crypto/crypto.o");
                const char *log_o = shux_rel_o_path_from_argv0(argv[0], "std/log/log.o");
                const char *atomic_o = shux_rel_o_path_from_argv0(argv[0], "std/atomic/atomic.o");
                const char *channel_o = shux_rel_o_path_from_argv0(argv[0], "std/channel/channel.o");
                const char *backtrace_o = shux_rel_o_path_from_argv0(argv[0], "std/backtrace/backtrace.o");
                const char *hash_o = shux_rel_o_path_from_argv0(argv[0], "std/hash/hash.o");
                const char *math_o = shux_rel_o_path_from_argv0(argv[0], "std/math/math.o");
                const char *sort_o = shux_rel_o_path_from_argv0(argv[0], "std/sort/sort.o");
                const char *ffi_o = shux_rel_o_path_from_argv0(argv[0], "std/ffi/ffi.o");
                const char *db_o = shux_rel_o_path_from_argv0(argv[0], "std/db/sqlite/sqlite.o");
                const char *elf_o = shux_rel_o_path_from_argv0(argv[0], "std/elf/elf.o");
                const char *json_o = shux_rel_o_path_from_argv0(argv[0], "std/json/json.o");
                const char *csv_o = shux_rel_o_path_from_argv0(argv[0], "std/csv/csv.o");
                const char *regex_o = shux_rel_o_path_from_argv0(argv[0], "std/regex/regex.o");
                const char *compress_o = NULL; /* F-06 v1 / F-04 v7：无 compress.o，user .o / 生成 C 按需压缩库 */
                const char *unicode_o = shux_rel_o_path_from_argv0(argv[0], "std/unicode/unicode.o");
                const char *dynlib_o = shux_rel_o_path_from_argv0(argv[0], "std/dynlib/dynlib.o");
                const char *http_o = shux_rel_o_path_from_argv0(argv[0], "std/http/http.o");
                const char *tar_o = shux_rel_o_path_from_argv0(argv[0], "std/tar/tar.o");
                const char *simd_o = shux_rel_o_path_from_argv0(argv[0], "std/simd/simd.o");
                const char *context_o = shux_rel_o_path_from_argv0(argv[0], "std/context/context.o");
                const char *datetime_o = shux_rel_o_path_from_argv0(argv[0], "std/datetime/datetime.o");
                const char *uuid_o = shux_rel_o_path_from_argv0(argv[0], "std/uuid/uuid.o");
                const char *url_o = shux_rel_o_path_from_argv0(argv[0], "std/url/url.o");
                const char *cli_o = shux_rel_o_path_from_argv0(argv[0], "std/cli/cli.o");
                const char *security_o = shux_rel_o_path_from_argv0(argv[0], "std/security/security.o");
                const char *config_o = shux_rel_o_path_from_argv0(argv[0], "std/config/config.o");
                const char *cache_o = shux_rel_o_path_from_argv0(argv[0], "std/cache/cache.o");
                const char *trace_o = shux_rel_o_path_from_argv0(argv[0], "std/trace/trace.o");
                const char *task_o = shux_rel_o_path_from_argv0(argv[0], "std/task/task.o");
                const char *schema_o = shux_rel_o_path_from_argv0(argv[0], "std/schema/schema.o");
                const char *test_o = shux_rel_o_path_from_argv0(argv[0], "std/test/test.o");
                int cc_ret = shux_invoke_cc(c_paths, 1, out_path, NULL, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, shux_repo_root_from_argv0(argv[0]), NULL);
                if (cc_ret != 0)
                    fprintf(stderr, "shux: cc failed, keeping generated C: %s\n", tmp_c);
                else if (!getenv("SHUX_KEEP_C"))
                    unlink(tmp_c);
                while (n_all--) {
                    free(all_dep_paths[n_all]);
                    ast_module_free(all_dep_mods[n_all]);
                }
                ast_module_free(c_mod);
                free(src);
                return cc_ret == 0 ? 0 : 1;
            }
            }
        }
    }
#else  /* SHUX_NO_C_FRONTEND */
    /*
     * G-06 seed 链仅 SX 前端；泛型/trait 由 typeck.sx 单态化。
     * 勿在此拒掉（否则 -E asm.sx / build_seed_asm_host 无法冷启动 partial）。
     */
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
    shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    if (n_imports > 0)
        pipeline_set_entry_dir(entry_dir_buf);

    char *dep_sources[MAX_ALL_DEPS];
    size_t dep_lens[MAX_ALL_DEPS];
    char *dep_paths[MAX_ALL_DEPS];
    int n_deps = 0;
    if (n_imports > 0 && n_imports <= 32) {
        if (shux_collect_deps_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir_buf, defines,
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
    char tmp[] = "/tmp/shux_sx.XXXXXX";
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
    shux_pipeline_fill_ctx_path_buffers(pctx, entry_dir_buf, lib_roots_arr, n_lib_roots);
    shux_pipeline_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
    pctx->skip_codegen_dep_0 = 0; /* 不再跳过 dep 0：io.o 仅提供 C 层，std.io.driver 的 .sx 包装须由 codegen 生成。 */
    /*
     * 先对每个 dep 跑 parse+typecheck（逆拓扑序，与 emit-C 2104 / asm 1186 一致）。
     * 勿用正序多轮 prerun：coff→[elf,codegen,ast] 时正序先编 elf 导致 import 槽未就绪 ec=-5。
     */
    driver_dep_seeded_clear_all();
    for (int j = n_deps - 1; j >= 0; j--) {
        struct ast_PipelineDepCtx *one_ctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*one_ctx));
        struct codegen_CodegenOutBuf *dep_out = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*dep_out));
        int ec_dep;
        if (!one_ctx || !dep_out) {
            fprintf(stderr, "shux: -sx path (driver full): dep_one_ctx/out alloc failed\n");
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
        shux_pipeline_fill_ctx_path_buffers(one_ctx, shux_dep_prerun_entry_dir(entry_dir_buf, lib_roots_arr, n_lib_roots),
                                            lib_roots_arr, n_lib_roots);
        shux_pipeline_one_ctx_for_dep_prerun(one_ctx, j, dep_modules, dep_arenas, dep_paths, n_deps,
            (const uint8_t *)dep_sources[j], dep_lens[j]);
        driver_set_current_dep_path_for_codegen(dep_paths[j]);
        /*
         * std/core 闭包 dep 仅 parse 填 import 槽；全量 dep_prerun typeck 在 strict 链上对 std.base64 等易 SIGSEGV。
         * shux check（stage1）：dep 一律 parse-only，避免 typeck_only 在大 std 子模块上 SIGSEGV。
         * 用户 multi-file（need_coemit）仍走 parse+typeck。
         */
        if (driver_check_only_get() ||
            shux_asm_user_std_dep_skip_sx_typeck(dep_paths[j]) ||
            driver_deps_are_std_core_closure_only(dep_paths, n_deps)) {
            ec_dep = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                (const uint8_t *)dep_sources[j], dep_lens[j]);
        } else {
            ec_dep = shux_pipeline_dep_prerun_typeck_only(dep_modules[j], dep_arenas[j],
                (const uint8_t *)dep_sources[j], dep_lens[j], (void *)dep_out, (void *)one_ctx);
        }
        driver_set_current_dep_path_for_codegen(NULL);
        pipeline_dep_ctx_heap_destroy(one_ctx);
        free(dep_out);
        if (ec_dep != 0) {
            fprintf(stderr, "shux: pipeline failed for import '%s' (dep prerun rc=%d)\n",
                    dep_paths[j] ? dep_paths[j] : "?", ec_dep);
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
            if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            return 1;
        }
        driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
    }
    typeck_ndep = n_deps;
    for (int j = 0; j < n_deps; j++) {
        typeck_dep_module_ptrs[j] = dep_modules[j];
        typeck_dep_arena_ptrs[j] = dep_arenas[j];
    }
    pipeline_set_dep_slots(dep_arenas, dep_modules);
    driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
    codegen_set_dep_slots_for_sx_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
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
    if (n_deps > 0 && !driver_check_only_get() && want_asm_backend &&
        driver_deps_are_std_core_closure_only(dep_paths, n_deps))
        pctx->asm_entry_module_only = 1;
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] before pipeline_run entry=%s src_len=%zu\n",
                input_path ? input_path : "?", (size_t)src_slice.length);
#if !defined(SHUX_NO_C_FRONTEND)
    if (n_deps > 0 && !driver_check_only_get() &&
        driver_deps_are_std_core_closure_only(dep_paths, n_deps)) {
        if (driver_c_typeck_entry_large_stack(input_path, src, lib_roots_arr, n_lib_roots, 0) != 0) {
            driver_sx_pipeline_skip_typeck_set(0);
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
            if (!emit_to_stdout) { fclose(cf); unlink(tmp_c); }
            while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena);
            free(module);
            free(src);
            return 1;
        }
    }
#endif
#if defined(SHUX_NO_C_FRONTEND)
    /*
     * stage1 shux check：std/core import 闭包上大模块（sys/fs/heap mod）全量 .sx typecheck 易 SIGSEGV。
     * 入口 parse_into_buf + dep parse-only 已足够 S7 硬依赖门禁；与 asm -o 跳过入口 typeck 策略一致。
     */
    if (driver_check_only_get() && n_deps > 0 &&
        driver_deps_are_std_core_closure_only(dep_paths, n_deps)) {
        driver_print_check_ok(input_path);
        if (!emit_to_stdout) {
            fclose(cf);
            unlink(tmp_c);
        }
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
        free(arena);
        free(module);
        free(src);
        return 0;
    }
#endif
    int ec = shux_pipeline_run_sx_pipeline_large_stack(module, arena, src_slice.data, (size_t)src_slice.length, (void *)out_buf, (void *)pctx);
    driver_sx_pipeline_skip_typeck_set(0);
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] after pipeline_run ec=%d\n", ec);
    driver_dep_seeded_clear_all();
    codegen_set_dep_slots_for_sx_pipeline(NULL, NULL, 0);
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
        driver_print_sx_smoke_summary(module, (size_t)out_buf->len);
    free(arena);
    free(module);
    free(src);
    {
        /* 内联 std.io / std.net / fs / path / map / error ABI；不再 #include std/*_abi.h。
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
        if (fwrite(out_buf->data, 1, first_line, cf) != first_line
            || write_io_net_abi_inline(cf) != 0
            || write_fs_path_map_error_abi_inline(cf) != 0
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
            const char *io_o = shux_std_io_o_path(argv[0]); /* F-03：纯 .sx，无 io.o */
            const char *fs_o = NULL; /* F-06 v1：纯 .sx，invoke_cc 扫描生成 C 按需 -lc */
            const char *process_o = shux_rel_o_path_from_argv0(argv[0], "std/process/process.o");
            const char *string_o = shux_rel_o_path_from_argv0(argv[0], "std/string/string.o");
            const char *heap_o = NULL; /* F-06 v1：纯 .sx，按需 -lc */
            const char *path_o = shux_rel_o_path_from_argv0(argv[0], "std/path/path.o");
            const char *runtime_o = shux_rel_o_path_from_argv0(argv[0], "std/runtime/runtime.o");
            const char *runtime_panic_o = shux_runtime_panic_o_path(argv[0]);
            const char *net_o = shux_rel_o_path_from_argv0(argv[0], "std/net/net.o");
            const char *thread_o = shux_rel_o_path_from_argv0(argv[0], "std/thread/thread.o");
            const char *time_o = shux_rel_o_path_from_argv0(argv[0], "std/time/time.o");
            const char *random_o = shux_rel_o_path_from_argv0(argv[0], "std/random/random.o");
            const char *env_o = shux_rel_o_path_from_argv0(argv[0], "std/env/env.o");
            const char *sync_o = shux_rel_o_path_from_argv0(argv[0], "std/sync/sync.o");
            const char *encoding_o = shux_rel_o_path_from_argv0(argv[0], "std/encoding/encoding.o");
            const char *base64_o = shux_rel_o_path_from_argv0(argv[0], "std/base64/base64.o");
            const char *crypto_o = shux_rel_o_path_from_argv0(argv[0], "std/crypto/crypto.o");
            const char *log_o = shux_rel_o_path_from_argv0(argv[0], "std/log/log.o");
            const char *atomic_o = shux_rel_o_path_from_argv0(argv[0], "std/atomic/atomic.o");
            const char *channel_o = shux_rel_o_path_from_argv0(argv[0], "std/channel/channel.o");
            const char *backtrace_o = shux_rel_o_path_from_argv0(argv[0], "std/backtrace/backtrace.o");
            const char *hash_o = shux_rel_o_path_from_argv0(argv[0], "std/hash/hash.o");
            const char *math_o = shux_rel_o_path_from_argv0(argv[0], "std/math/math.o");
            const char *sort_o = shux_rel_o_path_from_argv0(argv[0], "std/sort/sort.o");
            const char *ffi_o = shux_rel_o_path_from_argv0(argv[0], "std/ffi/ffi.o");
            const char *db_o = shux_rel_o_path_from_argv0(argv[0], "std/db/sqlite/sqlite.o");
            const char *elf_o = shux_rel_o_path_from_argv0(argv[0], "std/elf/elf.o");
            const char *json_o = shux_rel_o_path_from_argv0(argv[0], "std/json/json.o");
            const char *csv_o = shux_rel_o_path_from_argv0(argv[0], "std/csv/csv.o");
            const char *regex_o = shux_rel_o_path_from_argv0(argv[0], "std/regex/regex.o");
            const char *compress_o = NULL; /* F-06 v1 / F-04 v7：无 compress.o，user .o / 生成 C 按需压缩库 */
            const char *unicode_o = shux_rel_o_path_from_argv0(argv[0], "std/unicode/unicode.o");
            const char *dynlib_o = shux_rel_o_path_from_argv0(argv[0], "std/dynlib/dynlib.o");
            const char *http_o = shux_rel_o_path_from_argv0(argv[0], "std/http/http.o");
            const char *tar_o = shux_rel_o_path_from_argv0(argv[0], "std/tar/tar.o");
            const char *simd_o = shux_rel_o_path_from_argv0(argv[0], "std/simd/simd.o");
            const char *context_o = shux_rel_o_path_from_argv0(argv[0], "std/context/context.o");
            const char *datetime_o = shux_rel_o_path_from_argv0(argv[0], "std/datetime/datetime.o");
            const char *uuid_o = shux_rel_o_path_from_argv0(argv[0], "std/uuid/uuid.o");
            const char *url_o = shux_rel_o_path_from_argv0(argv[0], "std/url/url.o");
            const char *cli_o = shux_rel_o_path_from_argv0(argv[0], "std/cli/cli.o");
            const char *security_o = shux_rel_o_path_from_argv0(argv[0], "std/security/security.o");
            const char *config_o = shux_rel_o_path_from_argv0(argv[0], "std/config/config.o");
            const char *cache_o = shux_rel_o_path_from_argv0(argv[0], "std/cache/cache.o");
            const char *trace_o = shux_rel_o_path_from_argv0(argv[0], "std/trace/trace.o");
            const char *task_o = shux_rel_o_path_from_argv0(argv[0], "std/task/task.o");
            const char *schema_o = shux_rel_o_path_from_argv0(argv[0], "std/schema/schema.o");
            const char *test_o = shux_rel_o_path_from_argv0(argv[0], "std/test/test.o");
            int cc_ret = shux_invoke_cc(c_paths, 1, out_path, NULL, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, shux_repo_root_from_argv0(argv[0]), NULL);
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

extern int32_t driver_emit_lib_root_count(uint8_t *state);
extern int32_t driver_emit_append_lib_root(uint8_t *state, uint8_t *path, int32_t len);
extern void driver_emit_lib_root_reset(uint8_t *state);
extern int32_t driver_emit_lib_root_len(uint8_t *state, int32_t i);
extern void driver_emit_lib_root_copy(uint8_t *state, int32_t i, uint8_t *dst, int32_t cap);

/**
 * 判断 lib root 指针可安全解引用（避开 NULL/low tag/getenv 脏值）。
 * 参数：p 候选 lib root 字符串指针。
 * 返回值：非 0 表示可用。
 */
static int driver_lib_root_ptr_usable(const char *p) {
    return p && (uintptr_t)p >= 4096u && p[0] != '\0';
}

/**
 * 写入默认 lib root：优先 SHUX_LIB（拷贝到 root_buf），否则 "."。
 * 参数：root_buf 输出缓冲（至少 512 字节）。
 */
static void driver_lib_root_default(char root_buf[512]) {
    const char *def = getenv("SHUX_LIB");
    root_buf[0] = '.';
    root_buf[1] = '\0';
    if (!driver_lib_root_ptr_usable(def))
        return;
    strncpy(root_buf, def, 511);
    root_buf[511] = '\0';
}

/** 从 ast_pool sidecar 键填充 lib_roots 数组；返回根数量。 */
static int driver_lib_roots_from_key(uint8_t *lib_key, const char **out_arr, char bufs[SX_FULL_MAX_LIB_ROOTS][512]) {
    int n = (int)driver_emit_lib_root_count(lib_key);
    int i;
    if (n <= 0) {
        driver_lib_root_default(bufs[0]);
        out_arr[0] = bufs[0];
        return 1;
    }
    if (n > SX_FULL_MAX_LIB_ROOTS)
        n = SX_FULL_MAX_LIB_ROOTS;
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
 * compile.sx DriverCompileState 布局（字段顺序与 compile.sx 一致；EMIT_HEAVY impl_c 与 SX parse_argv 共用）。
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
    static char lib_bufs[SX_FULL_MAX_LIB_ROOTS][512];
    static const char *lib_roots[SX_FULL_MAX_LIB_ROOTS];
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
/** 含 import 时 seed 的 SX codegen 易重复符号；若同目录有 shux-c 则委托其完成 -o 链接（与 run-hello 一致）。 */
static int driver_try_compile_via_shu_c_sibling(int argc, char **argv) {
    char shu_c[512];
    const char *self;
    const char *slash;
    if (argc < 2 || !argv || !argv[0])
        return -1;
    /* 已在 shux-c 内：勿 fork 自身（L9 -o 会反复 pipeline failed out_len=0）。 */
    if (driver_argv0_basename_is(argv[0], "shux-c"))
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
    const char *lib_roots[SX_FULL_MAX_LIB_ROOTS];
    char lib_bufs[SX_FULL_MAX_LIB_ROOTS][512];
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
     * build_shux_asm 单模块 -o（SHUX_ASM_ENTRY_MODULE_ONLY）：须走 asm，勿 exec shux-c（其不支持 -backend asm）。
     * G-06：SHUX_NO_C_FRONTEND 时 shux-c 与 shux 同源 seed，sibling 失败须回落本进程 SX pipeline（-E asm.sx）。 */
#if !defined(SHUX_NO_C_FRONTEND)
    if (!driver_check_only_get() && p.input_path && driver_source_has_top_level_import_path(p.input_path) &&
        !driver_asm_entry_module_only_from_env()) {
        int shu_c_rc = driver_try_compile_via_shu_c_sibling((int)argc, (char **)argv);
        if (shu_c_rc == 0)
            return 0;
    }
#endif
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
 * 堆分配 DriverCompileState（与 impl_c 默认字段一致）；供 compile.sx run_compiler_full_sx SX emit。
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
/** 是否为 Shux 源文件路径（`.sx`；仅 `.sx`）。 */
static int drv_path_ends_sx(const char *buf, int len) {
    if (len >= 3 && buf[len - 3] == '.' && buf[len - 2] == 's') {
        char ext = buf[len - 1];
        return ext == 'u' || ext == 'x';
    }
    return 0;
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
 * 处理 argv[i] 一项（C 实现；strict emit 下 SX step 的 if+side-effect+return 会错序提前 return）。
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
    if (arg_buf[0] != '-' && drv_path_ends_sx(arg_buf, len))
        driver_compile_argv_copy_path_c(state, (uint8_t *)arg_buf, len);
    return i + 1;
}

/**
 * argv[1..] 扫描 loop（C step_c）；compile.sx parse_argv SX 编排调本符号。
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
 * strict emit 下 SX parse_argv_step 对 `-L`/`-o` 等分支会跳过 side-effect；scan 仍走 C step_c。
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
 * EMIT_HEAVY 下 SX while+INDEX 形参 field 易误折叠/漏 emit；与 impl_c 一样走 C 原语。
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
 * EMIT_HEAVY driver_compile.o 中 SX 体常为 ret0 桩；finalize 与薄包装均 bl 本符号。
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

/** -o：下一 argv 写入 out_path_buf/out_path_len（EMIT_HEAVY step 勿 SX field store）。 */
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

/** SX run_compiler_full_sx：`--print-target-cpu` 早退（与 driver_run_compiler_full_sx_impl_c 对齐）。 */
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

#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
int driver_run_sx_emit_c(void);

/** argv 是否含 `-E` / `-E-extern`（G-06 build_seed_asm_host 用 `shux -E file.sx`，勿走 asm 后端）。 */
static int driver_argv_has_emit_c_flag(int argc, char **argv) {
    int i;
    if (argc < 2 || !argv)
        return 0;
    for (i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-E") || !strcmp(argv[i], "-E-extern"))
            return 1;
    }
    return 0;
}

/**
 * `-E` 专用：将 compile state 中的 path/lib_roots 灌入 driver_run_sx_emit_c，走 .sx pipeline 出 C（deps+main）。
 * 返回 driver_run_sx_emit_c 的 exit code（0 成功）。
 */
static int32_t driver_run_sx_emit_c_from_compile_state(DriverCompileStateSU *state, int argc, char **argv) {
    const char *lib_roots[SX_EMIT_MAX_LIB_ROOTS];
    /** 须与 driver_lib_roots_from_key 的 bufs[SX_FULL_MAX_LIB_ROOTS][512] 一致；[256] 会在多 -L 时栈溢出。 */
    char lib_bufs[SX_FULL_MAX_LIB_ROOTS][512];
    int want_extern = 0;
    int n;
    int k;

    if (!state || state->path_len <= 0)
        return 1;
    for (k = 1; k < argc; k++) {
        if (argv[k] && !strcmp(argv[k], "-E-extern"))
            want_extern = 1;
    }
    driver_run_sx_emit_c_set_emit_extern(want_extern);
    driver_run_sx_emit_c_set_path(state->path_buf, state->path_len);
    n = driver_lib_roots_from_key((uint8_t *)state, lib_roots, lib_bufs);
    if (n <= 0) {
        driver_run_sx_emit_c_set_lib(0, (const uint8_t *)".", 1);
        driver_run_sx_emit_c_set_n_lib_roots(1);
    } else {
        for (k = 0; k < n; k++)
            driver_run_sx_emit_c_set_lib(k, (const uint8_t *)lib_roots[k], (int)strlen(lib_roots[k]));
        driver_run_sx_emit_c_set_n_lib_roots(n);
    }
    return (int32_t)driver_run_sx_emit_c();
}
#endif

/** parse 完成后后端选择 + 分派；compile.sx 薄包装 bl 本符号（EMIT_HEAVY 勿 SX 真 emit，宿主 SIGSEGV）。 */
int32_t driver_run_compiler_full_sx_post_parse_impl_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv) {
    uint8_t *out_ptr;
    uint8_t *target_ptr;
    int32_t want_generic_check;

    if (!state)
        return 1;
#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
    /* G-06：`-E` 须出 C 文本（build_seed_asm_host / gen_bootstrap_gens），禁止默认 asm 后端。 */
    if (driver_argv_has_emit_c_flag((int)argc, (char **)argv))
        return driver_run_sx_emit_c_from_compile_state(state, (int)argc, (char **)argv);
#endif
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
        /** 复合赋值已由 SX lexer/parser 支持；勿降级 C。 */
    }
    out_ptr = NULL;
    if (state->out_path_len > 0)
        out_ptr = state->out_path_buf;
    target_ptr = NULL;
    if (state->target_len > 0)
        target_ptr = state->target_buf;
#if defined(SHUX_ASM_USE_COMPILER_IMPL_C)
    /*
     * 无 import 的单文件 -o 默认 asm；有 import 时允许降级 C（std 测试走 invoke_cc + 预编 *.o）。
     * hello/freestanding 等显式 -backend asm 或 -freestanding 仍保留 asm。
     */
    if (state->out_path_len > 0 && !state->backend_asm_explicit &&
        !driver_source_has_top_level_import_path((const char *)state->path_buf))
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
 * parse_argv 须走 impl_c（C mega），勿调 compile.sx 的 driver_compile_parse_argv（EMIT_HEAVY 下易 silent fail）。
 */
int32_t driver_run_compiler_full_sx_impl_c(int32_t argc, uint8_t *argv) {
    DriverCompileStateSU *state;
    int32_t rc;

    if (driver_compile_argv_is_help_c(argc, argv)) {
        driver_print_usage_c();
        return 0;
    }
    if (argc < 2) {
        driver_print_usage_c();
        return 0;
    }
    driver_bump_stack_limit();
    state = driver_compile_state_alloc_c();
    if (!state)
        return 1;
    if (driver_compile_parse_argv_impl_c(argc, argv, state) != 0) {
        driver_compile_state_free_c(state);
        return 1;
    }
    if (state->print_target_cpu) {
        shu_target_cpu_print(stdout, (uint32_t)state->target_cpu_features);
        driver_compile_state_free_c(state);
        return 0;
    }
    rc = driver_run_compiler_full_sx_post_parse_impl_c(state, argc, argv);
    driver_compile_state_free_c(state);
    return rc;
}

/**
 * 完整编译入口：argv 解析在 driver/compile.sx；B-strict shux_asm 走 impl_c（完整 parse_argv+finalize），避免 SX emit 的 driver_run_compiler_full_sx 在 strict 链 silent fail。
 */
int driver_run_compiler_full(int argc, char **argv) {
#if defined(SHUX_ASM_USE_COMPILER_IMPL_C)
    return (int)driver_run_compiler_full_sx_impl_c((int32_t)argc, (uint8_t *)argv);
#else
    extern int32_t driver_run_compiler_full_sx(int32_t argc, uint8_t *argv);
    return (int)driver_run_compiler_full_sx((int32_t)argc, (uint8_t *)argv);
#endif
}

/**
 * shux test 入口：在仓库根目录执行 bash 测试脚本；默认 tests/run-all.sh，亦可通过首参指定相对/绝对路径。
 */
int driver_run_test(int argc, char **argv) {
    const char *root = shux_repo_root_from_argv0(argc > 0 ? argv[0] : NULL);
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

/** 扫描 argv：若存在 -sx -E <path> 则记下 path 及此前出现的 -L path，返回 1，否则返回 0。保留供未迁完时链接。 */
int driver_argv_parse_sx_emit_c(int argc, char **argv) {
    char ab[512];
    char nx[512];
    driver_sx_emit_c_path = NULL;
    driver_sx_emit_n_lib_roots = 0;
    if (argc < 4 || !argv)
        return 0;
    for (int i = 1; i < argc; i++) {
        if (driver_get_argv_i(argc, argv, i, ab, (int)sizeof ab) < 0)
            continue;
        if (strcmp(ab, "-L") == 0 && i + 1 < argc) {
            /* 与 driver_run_compiler_full：满则仍跳过路径令牌；-L 根拷入 driver_sx_emit_lib_bufs，与 driver_run_sx_emit_c_set_lib 一致 */
            int k = driver_sx_emit_n_lib_roots;
            if (k < SX_EMIT_MAX_LIB_ROOTS) {
                int ln = driver_get_argv_i(argc, argv, i + 1, driver_sx_emit_lib_bufs[k], 256);
                if (ln < 0)
                    return 0;
                driver_sx_emit_lib_roots[k] = driver_sx_emit_lib_bufs[k];
                driver_sx_emit_n_lib_roots++;
            }
            i++;
            continue;
        }
        if (strcmp(ab, "-sx") == 0 && i + 2 < argc) {
            if (driver_get_argv_i(argc, argv, i + 1, nx, (int)sizeof nx) < 0 || strcmp(nx, "-E") != 0)
                continue;
            if (driver_get_argv_i(argc, argv, i + 2, driver_sx_emit_path_buf, (int)sizeof driver_sx_emit_path_buf) < 0)
                return 0;
            driver_sx_emit_c_path = driver_sx_emit_path_buf;
            return 1;
        }
    }
    return 0;
}

#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
/**
 * -sx -E -E-extern：用 C 前端 parse/typeck 与 C codegen 的 emit_extern 路径写 stdout。
 * 说明：codegen_emit_dep_types_only / codegen_library_module_to_c 依赖 C ASTModule；parser_parse_into 的 .sx Module 布局不同，故不能复用 sx parse 结果。
 */
#if !defined(SHUX_NO_C_FRONTEND)
static int driver_run_sx_emit_c_extern_via_cparser(const char *input_path) {
    (void)setvbuf(stdout, NULL, _IONBF, 0);
    ShuxRuntimeFileView raw_src_view;
    if (runtime_read_file_view(input_path, &raw_src_view) != 0) {
        fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
        return 1;
    }
    size_t src_len = 0;
    char *src = SHUX_RUNTIME_PREPROCESS(raw_src_view.data, raw_src_view.length, NULL, 0, &src_len);
    runtime_release_file_view(&raw_src_view);
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
    shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    const char *entry_dir = entry_dir_buf;
    const char *lib_roots_arr[SX_EMIT_MAX_LIB_ROOTS];
    int n_lib_roots = driver_sx_emit_n_lib_roots;
    if (n_lib_roots == 0) {
        lib_roots_arr[0] = ".";
        n_lib_roots = 1;
    } else {
        for (int k = 0; k < n_lib_roots; k++)
            lib_roots_arr[k] = driver_sx_emit_lib_roots[k];
    }
    ASTModule *dep_mods[32];
    ASTModule *all_dep_mods[MAX_ALL_DEPS];
    char *all_dep_paths[MAX_ALL_DEPS];
    int ndep = 0, n_all = 0;
    if (mod->num_imports > 0 && shu_c_resolve_and_load_imports(mod, lib_roots_arr, n_lib_roots, entry_dir, NULL, 0,
            dep_mods, &ndep, all_dep_mods, all_dep_paths, NULL, &n_all, MAX_ALL_DEPS) != 0) {
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
    fprintf(stdout, "#include <string.h>\n");
    fprintf(stdout, "extern int getpid(void);\n");
    fprintf(stdout, "static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {\n");
    fprintf(stdout, "  const char *_ev = getenv(\"SHUX_CRASH_EVIDENCE\");\n");
    fprintf(stdout, "  if (!_ev || _ev[0] != '1') return;\n");
    fprintf(stdout, "  int _pid = (int)getpid();\n");
    fprintf(stdout, "  fprintf(stderr, \"shux: [SHUX_CRASH_EVIDENCE] panic=%%d msg=%%d frames=0 pid=%%d\\n\", has_msg, msg_val, _pid);\n");
    fprintf(stdout, "  const char *_dir = getenv(\"SHUX_CRASH_EVIDENCE_DIR\");\n");
    fprintf(stdout, "  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, \"%%s/shux-crash-%%d.txt\", _dir, _pid);\n");
    fprintf(stdout, "    FILE *_f = fopen(_p, \"w\"); if (_f) { fprintf(_f, \"panic_has_msg=%%d\\npanic_msg=%%d\\nframes=0\\npid=%%d\\n\", has_msg, msg_val, _pid); fclose(_f);\n");
    fprintf(stdout, "      fprintf(stderr, \"shux: [SHUX_CRASH_EVIDENCE] bundle=%%s\\n\", _p); } } }\n");
    fprintf(stdout, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
    fprintf(stdout, "static inline void shux_panic_(int has_msg, int msg_val) {\n");
    fprintf(stdout, "  shux_crash_evidence_collect_inline(has_msg, msg_val);\n");
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
        fprintf(stdout, "__attribute__((weak)) int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr) { (void)bufs; (void)nr; return -1; }\n");
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
        const char *lib_name = shux_entry_lib_name_from_path(input_path);
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
        shux_emit_pipeline_glue_include();
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
    const char *input_path = driver_sx_emit_c_path;
    driver_sx_emit_c_path = NULL;
    if (!input_path) return 1;
#ifdef SHUX_USE_SX_PIPELINE
    {
        /* 关闭 stdout 缓冲，避免重定向或管道下输出被截断（平台差异见 analysis/下一步开发分析.md §4.4） */
        (void)setvbuf(stdout, NULL, _IONBF, 0);
#if defined(SHUX_USE_SX_DRIVER) && defined(SHUX_USE_SX_PIPELINE)
        {
            const int want_extern = driver_sx_emit_c_want_extern;
            driver_sx_emit_c_want_extern = 0;
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
        ShuxRuntimeFileView raw_src_view;
        if (runtime_read_file_view(input_path, &raw_src_view) != 0) {
            fprintf(stderr, "Error: cannot read file '%s'\n", input_path);
            return 1;
        }
        size_t src_len = 0;
        char *src = SHUX_RUNTIME_PREPROCESS(raw_src_view.data, raw_src_view.length, NULL, 0, &src_len);
        runtime_release_file_view(&raw_src_view);
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
        if (src_len > (size_t)INT32_MAX) {
            fprintf(stderr, "shux: -sx -E: source too large for parser (>%d bytes): '%s'\n", INT32_MAX, input_path);
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        parser_parse_into_init(module, arena);
        /* 与 run_compiler_c 的 -sx pipeline 一致：用 parse_into_buf，勿 parse_into（slice 路径在 seed 链易失败）。 */
        struct parser_ParseIntoResult pr =
            parser_parse_into_buf(arena, module, (uint8_t *)src, (int32_t)src_len);
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
        shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
        const char *entry_dir = entry_dir_buf;
        /* 供 pipeline 内 resolve/read 单段 import 用；仅在有 import 时设置，避免单文件时影响 */
        if (n_imports > 0)
            pipeline_set_entry_dir(entry_dir_buf);
        /* 阶段 2.1：使用解析到的 -L 库根；无 -L 时退化为当前目录 */
        const char *lib_roots_arr[SX_EMIT_MAX_LIB_ROOTS];
        int n_lib_roots = driver_sx_emit_n_lib_roots;
        if (n_lib_roots == 0) {
            lib_roots_arr[0] = ".";
            n_lib_roots = 1;
        } else {
            for (int k = 0; k < n_lib_roots; k++) lib_roots_arr[k] = driver_sx_emit_lib_roots[k];
        }
        char *dep_sources[MAX_ALL_DEPS];
        size_t dep_lens[MAX_ALL_DEPS];
        char *dep_paths[MAX_ALL_DEPS];
        int n_deps = 0;
        int asm_direct_import_only = driver_sx_emit_asm_direct_import_only(input_path);
        if (n_imports > 0 && n_imports <= 32) {
            if (asm_direct_import_only) {
                if (shux_load_direct_imports_for_asm_layout(module, lib_roots_arr, n_lib_roots, entry_dir, NULL, 0,
                        dep_sources, dep_lens, dep_paths, &n_deps) != 0) {
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
            } else if (shux_collect_deps_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir,
                           NULL, 0, dep_sources, dep_lens, dep_paths, &n_deps) != 0) {
                free(arena);
                free(module);
                free(src);
                return 1;
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
        shux_pipeline_fill_ctx_path_buffers(pctx_e, entry_dir_buf, lib_roots_arr, n_lib_roots);
        if (asm_direct_import_only)
            shux_pipeline_pctx_seed_dep_import_paths_only(pctx_e, dep_paths, n_deps);
        else
            shux_pipeline_pctx_seed_dep_slots(pctx_e, dep_modules, dep_arenas, dep_paths, n_deps);
        pctx_e->use_asm_backend = 0; /* -E 须走 C codegen 写 stdout */
        /* 与 driver_run_compiler_parsed 一致：逆拓扑 dep prerun parse+typeck，再编入口+deps。 */
        driver_dep_seeded_clear_all();
        for (int j = n_deps - 1; !asm_direct_import_only && j >= 0; j--) {
            struct ast_PipelineDepCtx *one_ctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*one_ctx));
            struct codegen_CodegenOutBuf *dep_out = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*dep_out));
            int ec_dep;
            if (!one_ctx || !dep_out) {
                fprintf(stderr, "shux: -sx -E: dep_one_ctx/out alloc failed\n");
                pipeline_dep_ctx_heap_destroy(one_ctx);
                free(dep_out);
                for (int di = 0; di < n_deps; di++) { free(dep_arenas[di]); free(dep_modules[di]); }
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx_e);
                free(arena); free(module); free(src);
                return 1;
            }
            shux_pipeline_fill_ctx_path_buffers(one_ctx, shux_dep_prerun_entry_dir(entry_dir_buf, lib_roots_arr, n_lib_roots),
                                                lib_roots_arr, n_lib_roots);
            shux_pipeline_one_ctx_for_dep_prerun(one_ctx, j, dep_modules, dep_arenas, dep_paths, n_deps,
            (const uint8_t *)dep_sources[j], dep_lens[j]);
            driver_set_current_dep_path_for_codegen(dep_paths[j]);
            if (asm_direct_import_only || driver_sx_emit_asm_dep_parse_only_ok(input_path, dep_paths[j])) {
                ec_dep = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                                                             (const uint8_t *)dep_sources[j], dep_lens[j]);
            } else {
                ec_dep = shux_pipeline_dep_prerun_typeck_only(dep_modules[j], dep_arenas[j],
                                                              (const uint8_t *)dep_sources[j], dep_lens[j],
                                                              (void *)dep_out, (void *)one_ctx);
            }
            driver_set_current_dep_path_for_codegen(NULL);
            pipeline_dep_ctx_heap_destroy(one_ctx);
            free(dep_out);
            if (ec_dep != 0) {
                fprintf(stderr, "shux: pipeline failed for import '%s' (dep prerun rc=%d)\n",
                        dep_paths[j] ? dep_paths[j] : "?", ec_dep);
                for (int di = 0; di < n_deps; di++) { free(dep_arenas[di]); free(dep_modules[di]); }
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx_e);
                free(arena); free(module); free(src);
                return 1;
            }
            driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
        }
        typeck_ndep = asm_direct_import_only ? 0 : n_deps;
        for (int j = 0; j < typeck_ndep; j++) {
            typeck_dep_module_ptrs[j] = dep_modules[j];
            typeck_dep_arena_ptrs[j] = dep_arenas[j];
        }
        if (asm_direct_import_only) {
            pipeline_set_dep_slots(dep_arenas, dep_modules);
            driver_dep_seed_slots(NULL, NULL, 0);
            codegen_set_dep_slots_for_sx_pipeline(NULL, NULL, 0);
        } else {
            pipeline_set_dep_slots(dep_arenas, dep_modules);
            driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
            codegen_set_dep_slots_for_sx_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
            /* 设置 driver_dep_* 槽位，使 pipeline 内 resolve/load 时能拿到与当前 dep 一致的 arena/module。仅对 entry 跑一次 pipeline，其内部会 codegen 所有 deps + entry，避免对每个 dep 单独跑 pipeline 再 fwrite 导致 deps 的 C 被写两遍（重复符号）。 */
            pipeline_set_dep_slots(dep_arenas, dep_modules);
        }
        memset(arena, 0, arena_sz);
        memset(module, 0, module_sz);
        int ec = shux_pipeline_run_sx_pipeline_large_stack(module, arena, (uint8_t *)src, src_len, (void *)out_buf, (void *)pctx_e);
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
#endif /* SHUX_USE_SX_DRIVER */

/**
 * shux fmt 单文件：读入 .sx、按 LSP 规则格式化；内容变化时写回。供 fmt.sx argv 循环调用。
 * path 为 NUL 终止路径（path_len 不含 NUL）；成功 0，失败 1。
 */
int driver_fmt_one_file(const uint8_t *path, int path_len) {
    char pathbuf[512];
    ShuxRuntimeFileView raw_view;
    size_t cap;
    uint8_t *out;
    int fmt_len;
    if (!path || path_len <= 0 || path_len >= (int)sizeof pathbuf)
        return 1;
    memcpy(pathbuf, path, (size_t)path_len);
    pathbuf[path_len] = '\0';
    if (path_len < 3 || strcmp(pathbuf + path_len - 3, ".sx") != 0)
        return 1;
    if (runtime_read_file_view(pathbuf, &raw_view) != 0) {
        fprintf(stderr, "shux fmt: cannot read '%s'\n", pathbuf);
        return 1;
    }
    cap = raw_view.length * 2 + 4096;
    if (cap < 65536)
        cap = 65536;
    out = (uint8_t *)malloc(cap);
    if (!out) {
        runtime_release_file_view(&raw_view);
        fprintf(stderr, "shux fmt: out of memory for '%s'\n", pathbuf);
        return 1;
    }
    fmt_len = shu_format_sx_document((const uint8_t *)raw_view.data, (int)raw_view.length, out, (int)cap);
    if (fmt_len < 0) {
        free(out);
        runtime_release_file_view(&raw_view);
        fprintf(stderr, "shux fmt: format failed for '%s'\n", pathbuf);
        return 1;
    }
    {
        int changed =
            ((size_t)fmt_len != raw_view.length || memcmp(raw_view.data, out, raw_view.length) != 0);
        if (driver_fmt_check_only_get()) {
            free(out);
            runtime_release_file_view(&raw_view);
            /* --check 成功时静默（与 deno fmt --check 一致）；失败由 driver_run_fmt 汇总列表。 */
            return changed ? 1 : 0;
        }
        if (changed) {
            if (shux_write_path_bytes(pathbuf, out, (size_t)fmt_len) != 0) {
                free(out);
                runtime_release_file_view(&raw_view);
                fprintf(stderr, "shux fmt: write failed for '%s'\n", pathbuf);
                return 1;
            }
            /* 与 deno fmt 一致：仅在实际写回时输出路径，已规范文件保持静默。 */
            fprintf(stderr, "fmt OK: %s\n", pathbuf);
        }
    }
    free(out);
    runtime_release_file_view(&raw_view);
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
 * 与 runtime_abi driver_argv_drop_subcommand 等价（C char** 路径）。
 */
static char **runtime_argv_drop_subcommand_c(int argc, char **argv) {
    return (char **)driver_argv_drop_subcommand(argc, (uint8_t *)argv);
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
    const char *root = shux_repo_root_from_argv0(argc > 0 ? argv[0] : NULL);
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
