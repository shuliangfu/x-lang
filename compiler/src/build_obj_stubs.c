/**
 * build_obj_stubs.c — 为 build-obj 生成的 .o 提供最小运行时符号桩
 * 链接时与 .o 一起链入即可消除 undefined symbol 错误
 */
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle) { return 0; }
int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m) { return 0; }
int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m) { return 0; }
int shux_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle) { (void)ptr; (void)len; (void)handle; return -1; }
int32_t shux_io_complete_read_async(void) { return -1; }
int32_t shux_io_complete_read_async_slot(int slot) { (void)slot; return -1; }
int shux_io_submit_write_async(const uint8_t *ptr, size_t len, size_t handle) { (void)ptr; (void)len; (void)handle; return -1; }
int32_t shux_io_complete_write_async(void) { return -1; }
int32_t shux_io_complete_write_async_slot(int slot) { (void)slot; return -1; }
int io_register_buffers_buf_c(const void *bufs, int nr) { return 0; }
int32_t shux_panic_(int has_msg, int msg_val) { if (has_msg) fprintf(stderr, "panic: %d\n", msg_val); abort(); }
void *std_io_driver_driver_read_ptr(void) { return NULL; }
int std_io_driver_driver_read_ptr_len(void) { return 0; }
