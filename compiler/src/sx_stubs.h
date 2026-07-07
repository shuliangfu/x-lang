/**
 * sx_stubs.h — build-obj 用运行时符号前向声明
 *
 * 生成的 .x → C 代码引用 std 运行时符号（io_read, io_write 等）。
 * 编译 .o 文件时需此头文件避免 -Wimplicit，链接时由 std .o 提供实际实现。
 */
#ifndef SX_STUBS_H
#define SX_STUBS_H
#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ---- preprocess（preprocess_sx.o 提供实现） ---- */
extern int32_t preprocess_sx_buf(uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf, int32_t out_cap);

/* ---- io ---- */
extern ptrdiff_t io_read(int32_t fd, uint8_t *buf, size_t count, uint32_t timeout_ms);
extern ptrdiff_t io_write(int32_t fd, uint8_t *buf, size_t count, uint32_t timeout_ms);
extern int32_t io_register_buffer(uint8_t *ptr, size_t len);
extern void io_unregister_buffers(void);
extern uint8_t *io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t io_read_ptr_len(void);

/* ---- shux io core wrappers ---- */
int32_t std_io_core_shux_io_register(uint8_t *ptr, size_t len, size_t handle);
int32_t std_io_core_shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_ms);
int32_t std_io_core_shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_ms);
void std_io_core_shux_io_unregister_buffers(void);

/* ---- fs ----
 * 与 .x extern isize 经 -E 生成的 ptrdiff_t 声明一致；链接时 std/fs/fs.c 的 int64_t 在 LP64 等价。 */
extern ptrdiff_t fs_posix_read_c(int32_t fd, uint8_t *buf, size_t count);
extern ptrdiff_t fs_posix_write_c(int32_t fd, uint8_t *buf, size_t count);
extern int32_t fs_posix_close_c(int32_t fd);

#ifdef __cplusplus
}
#endif
#endif
