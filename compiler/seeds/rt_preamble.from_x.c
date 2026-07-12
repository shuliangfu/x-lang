/* seeds/rt_preamble.from_x.c — G-02f-265 P2 R3 preamble ABI 内联
 * Logic source: src/runtime/rt_preamble.x（数据表以本 seed 为准）
 * Hybrid: SHUX_RT_PREAMBLE_FROM_X + ld -r into runtime_driver_no_c.o
 */
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>

#ifndef CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS
#define CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS    1u
#define CODEGEN_PREAMBLE_SKIP_STD_IO_DRIVER_HANDLE  2u
#define CODEGEN_PREAMBLE_SKIP_STD_IO_UNDEF_REDEFINE 4u
#define CODEGEN_PREAMBLE_SKIP_WEAK_IO_BATCH         8u
#endif

extern unsigned codegen_get_preamble_skip_mask(void);

/** 向生成 C 写入 std.io / std.net 内联 ABI（原 io_abi.h、net_abi.h 内容），不再依赖该二头文件。成功返回 0。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int write_io_net_abi_inline(FILE *cf) {
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
        "/* 撤销宏：X codegen 会生成同名函数定义(shux_io_register/submit_read/submit_write)，宏与多参签名冲突，在函数体前必须 undef。 */\n",
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
        "/* X codegen 在 std_io_driver_read/write 体内用短名 submit_read/submit_write(Buffer)；须转调 preamble 的 ptrdiff_t _buf 包装。 */\n",
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
        "/* X 生成代码可能调用 std_io_* / std_net_* 带前缀名且首参为 stream/listener 结构体；以下宏统一转为 .fd 再调 _impl。C 路径下 std.io 仍定义 std_io_read_fixed_fd，故仅 X 需宏。 */\n",
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
        "/* X 内联 std.io 会生成函数定义；撤销与定义/extern 冲突的宏，并补齐 batch 注册符号映射。 */\n",
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
        "/* X 内联 std.io 时若 driver/mod 部分包装未 codegen，由弱符号补齐以免链接失败（handle_from_fd 由 mod codegen 定义，此处不再 weak）。 */\n",
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
        "extern void shux_panic_(int, int);\n",
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
        /* #undef / 重绑 std_io_core_*（209–222）：X 内联 std.io.core 且 codegen 已 emit 时由 codegen 侧承担。 */
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
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int write_fs_path_map_error_abi_inline(FILE *cf) {
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
