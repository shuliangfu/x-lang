/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shux_panic_(int has_msg, int msg_val) {
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
extern ptrdiff_t io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ptrdiff_t io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ptrdiff_t io_read_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ptrdiff_t io_write_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern int32_t io_register_buffer(uint8_t * ptr, size_t len);
extern int32_t io_register_buffers_4(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern void io_unregister_buffers();
extern ptrdiff_t io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern ptrdiff_t io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
extern uint8_t * io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t io_read_ptr_len();
int32_t std_io_core_shux_io_register(uint8_t * ptr, size_t len, size_t handle);
int32_t std_io_core_shux_io_register_buffers(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
void std_io_core_shux_io_unregister_buffers();
int32_t std_io_core_shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
int32_t std_io_core_shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
int32_t std_io_core_shux_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
int32_t std_io_core_shux_io_submit_read(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
uint8_t * std_io_core_shux_io_read_ptr(size_t handle, uint32_t timeout_ms);
int32_t std_io_core_shux_io_read_ptr_len();
int32_t std_io_core_shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
int32_t std_io_core_shux_io_submit_read_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
int32_t std_io_core_shux_io_submit_write_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
int32_t std_io_core_shux_io_register(uint8_t * ptr, size_t len, size_t handle) {
  return io_register_buffer(ptr, len);
}
int32_t std_io_core_shux_io_register_buffers(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr) {
  return io_register_buffers_4(p0, l0, p1, l1, p2, l2, p3, l3, nr);
}
void std_io_core_shux_io_unregister_buffers() {
  (void)(io_unregister_buffers());
}
int32_t std_io_core_shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  int32_t fd = ((int32_t)(handle));
  ptrdiff_t r = io_read_fixed(fd, buf_index, offset, len, timeout_ms);
  (void)(({ int32_t __tmp = 0; if (r < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return ((int32_t)(r));
}
int32_t std_io_core_shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  int32_t fd = ((int32_t)(handle));
  ptrdiff_t r = io_write_fixed(fd, buf_index, offset, len, timeout_ms);
  (void)(({ int32_t __tmp = 0; if (r < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return ((int32_t)(r));
}
int32_t std_io_core_shux_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms) {
  return io_wait_readable(fds, n, timeout_ms);
}
int32_t std_io_core_shux_io_submit_read(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms) {
  int32_t fd = ((int32_t)(handle));
  (void)(({ int32_t __tmp = 0; if (handle == 0 || handle >= 2) {   ptrdiff_t r = io_read(fd, ptr, len, timeout_ms);
  (void)(({ int32_t __tmp = 0; if (r < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return ((int32_t)(r));
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
uint8_t * std_io_core_shux_io_read_ptr(size_t handle, uint32_t timeout_ms) {
  return io_read_ptr(handle, timeout_ms);
}
int32_t std_io_core_shux_io_read_ptr_len() {
  return io_read_ptr_len();
}
int32_t std_io_core_shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms) {
  int32_t fd = ((int32_t)(handle));
  (void)(({ int32_t __tmp = 0; if (handle >= 1) {   ptrdiff_t r = io_write(fd, ptr, len, timeout_ms);
  (void)(({ int32_t __tmp = 0; if (r < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return ((int32_t)(r));
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
int32_t std_io_core_shux_io_submit_read_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms) {
  int32_t fd = ((int32_t)(handle));
  (void)(({ int32_t __tmp = 0; if (handle == 0 || handle >= 2) {   ptrdiff_t r = io_read_batch(fd, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, n, timeout_ms);
  (void)(({ int32_t __tmp = 0; if (r < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return ((int32_t)(r));
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
int32_t std_io_core_shux_io_submit_write_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms) {
  int32_t fd = ((int32_t)(handle));
  (void)(({ int32_t __tmp = 0; if (handle >= 1) {   ptrdiff_t r = io_write_batch(fd, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, n, timeout_ms);
  (void)(({ int32_t __tmp = 0; if (r < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return ((int32_t)(r));
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
extern int32_t std_io_core_shux_io_register(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_core_shux_io_submit_read(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern uint8_t * std_io_core_shux_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_core_shux_io_read_ptr_len();
extern int32_t std_io_core_shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern int32_t std_io_core_shux_io_submit_read_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_core_shux_io_submit_write_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
enum std_io_driver_IO_Result { std_io_driver_IO_Result_Ok, std_io_driver_IO_Result_Err, std_io_driver_IO_Result_Timeout, std_io_driver_IO_Result_Cancelled };
struct std_io_driver_Buffer { uint8_t * ptr; size_t len; size_t handle; };
struct std_io_driver_Completion { int32_t tag; };
struct std_io_driver_AsyncContext { uint32_t flags; };
extern int32_t io_register_buffers_buf(struct std_io_driver_Buffer * bufs, int32_t nr);
int32_t std_io_driver_register(ptrdiff_t buf);
int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_driver_Buffer * bufs, uint32_t nr);
int32_t std_io_driver_submit_read(ptrdiff_t buf, uint32_t timeout_ms);
uint8_t * std_io_driver_driver_read_ptr(size_t handle, uint32_t timeout_ms);
int32_t std_io_driver_driver_read_ptr_len();
int32_t std_io_driver_submit_write(ptrdiff_t buf, uint32_t timeout_ms);
int32_t std_io_driver_submit_read_batch(struct std_io_driver_Buffer buffers[4], int32_t n, uint32_t timeout_ms);
int32_t std_io_driver_submit_write_batch(struct std_io_driver_Buffer buffers[4], int32_t n, uint32_t timeout_ms);
int32_t std_io_driver_register(ptrdiff_t buf) {
  return shux_io_register_buf(buf);
}
int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_driver_Buffer * bufs, uint32_t nr) {
  return io_register_buffers_buf_i32((intptr_t)(void *)bufs, (int)nr);
}
int32_t std_io_driver_submit_read(ptrdiff_t buf, uint32_t timeout_ms) {
  return shux_io_submit_read_buf(buf, timeout_ms);
}
int32_t std_io_driver_submit_write(ptrdiff_t buf, uint32_t timeout_ms) {
  return shux_io_submit_write_buf(buf, timeout_ms);
}
int32_t std_io_driver_submit_read_batch(struct std_io_driver_Buffer buffers[4], int32_t n, uint32_t timeout_ms) {
  size_t h = ((buffers)[0]).handle;
  return std_io_core_shux_io_submit_read_batch(((buffers)[0]).ptr, ((buffers)[0]).len, ((1 < 0 || (1) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[1])).ptr, ((1 < 0 || (1) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[1])).len, ((2 < 0 || (2) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[2])).ptr, ((2 < 0 || (2) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[2])).len, ((3 < 0 || (3) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[3])).ptr, ((3 < 0 || (3) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[3])).len, h, n, timeout_ms);
}
int32_t std_io_driver_submit_write_batch(struct std_io_driver_Buffer buffers[4], int32_t n, uint32_t timeout_ms) {
  size_t h = ((buffers)[0]).handle;
  return std_io_core_shux_io_submit_write_batch(((buffers)[0]).ptr, ((buffers)[0]).len, ((1 < 0 || (1) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[1])).ptr, ((1 < 0 || (1) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[1])).len, ((2 < 0 || (2) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[2])).ptr, ((2 < 0 || (2) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[2])).len, ((3 < 0 || (3) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[3])).ptr, ((3 < 0 || (3) >= 4 ? (shux_panic_(1, 0), (buffers)[0]) : (buffers)[3])).len, h, n, timeout_ms);
}
struct shux_slice_uint8_t { uint8_t *data; size_t length; };
extern int32_t std_io_driver_submit_read(ptrdiff_t buf, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_write(ptrdiff_t buf, uint32_t timeout_ms);
extern uint8_t * std_io_driver_driver_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_driver_driver_read_ptr_len();
extern int32_t std_io_driver_submit_read_batch(struct std_io_driver_Buffer buffers[4], int32_t n, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_write_batch(struct std_io_driver_Buffer buffers[4], int32_t n, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_core_shux_io_register_buffers(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_driver_Buffer * bufs, uint32_t nr);
extern int32_t std_io_core_shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_core_shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_core_shux_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
struct std_io_ReadOnlySlice { struct shux_slice_uint8_t data; };
struct std_io_WriteOnlySlice { struct shux_slice_uint8_t data; };
size_t std_io_handle_stdin();
size_t std_io_handle_stdout();
size_t std_io_handle_stderr();
size_t std_io_handle_from_fd(int32_t fd, int32_t _unused);
int32_t std_io_read(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms);
int32_t std_io_write(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms);
int32_t std_io_read_into(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms);
int32_t std_io_write_from(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms);
int32_t std_io_read_stdin(uint8_t * ptr, size_t len);
uint8_t * std_io_read_ptr(size_t handle, uint32_t timeout_ms);
int32_t std_io_read_ptr_len();
uint8_t * std_io_read_stdin_ptr();
int32_t std_io_write_stdout(uint8_t * ptr, size_t len);
int32_t std_io_write_stderr(uint8_t * ptr, size_t len);
int32_t std_io_read_with_timeout(uint8_t * ptr, size_t len, uint32_t timeout_ms);
int32_t std_io_write_with_timeout(uint8_t * ptr, size_t len, uint32_t timeout_ms);
int32_t std_io_write_stderr_with_timeout(uint8_t * ptr, size_t len, uint32_t timeout_ms);
int32_t std_io_read_fd(int32_t fd, uint8_t * ptr, size_t len);
int32_t std_io_write_fd(int32_t fd, uint8_t * ptr, size_t len);
int32_t std_io_read_batch_fd(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n);
int32_t std_io_write_batch_fd(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n);
int32_t std_io_read_batch_fd_buf(int32_t fd, struct std_io_driver_Buffer * buffers, int32_t n);
int32_t std_io_write_batch_fd_buf(int32_t fd, struct std_io_driver_Buffer * buffers, int32_t n);
int32_t std_io_print_str(uint8_t * ptr, size_t len);
int32_t std_io_register_fixed_buffers(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
int32_t std_io_register_fixed_buffers_buf(struct std_io_driver_Buffer * bufs, uint32_t nr);
int32_t std_io_read_fixed_fd(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
int32_t std_io_write_fixed_fd(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
int32_t std_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
int32_t std_io_read_into_slice(struct shux_slice_uint8_t * buf, uint32_t timeout_ms);
int32_t std_io_write_from_slice(struct shux_slice_uint8_t * buf, uint32_t timeout_ms);
int32_t std_io_print_i32(int32_t x);
int32_t std_io_print_u32(uint32_t x);
int32_t std_io_print_i64(int64_t x);
int32_t std_io_placeholder();
size_t std_io_handle_stdin() {
  return 0;
}
size_t std_io_handle_stdout() {
  return 1;
}
size_t std_io_handle_stderr() {
  return 2;
}
size_t std_io_handle_from_fd(int32_t fd, int32_t _unused) {
  return ((size_t)(fd));
}
int32_t std_io_read(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  struct std_io_driver_Buffer buf = (struct std_io_driver_Buffer){ .ptr = ptr, .len = len, .handle = handle };
  return std_io_driver_submit_read((ptrdiff_t)(uintptr_t)&(buf), timeout_ms);
}
int32_t std_io_write(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  struct std_io_driver_Buffer buf = (struct std_io_driver_Buffer){ .ptr = ptr, .len = len, .handle = handle };
  return std_io_driver_submit_write((ptrdiff_t)(uintptr_t)&(buf), timeout_ms);
}
int32_t std_io_read_into(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  return std_io_read(handle, ptr, len, timeout_ms);
}
int32_t std_io_write_from(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  return std_io_write(handle, ptr, len, timeout_ms);
}
int32_t std_io_read_stdin(uint8_t * ptr, size_t len) {
  return std_io_read(std_io_handle_stdin(), ptr, len, 0);
}
uint8_t * std_io_read_ptr(size_t handle, uint32_t timeout_ms) {
  return std_io_driver_driver_read_ptr(handle, timeout_ms);
}
int32_t std_io_read_ptr_len() {
  return std_io_driver_driver_read_ptr_len();
}
uint8_t * std_io_read_stdin_ptr() {
  return std_io_read_ptr(std_io_handle_stdin(), 0);
}
int32_t std_io_write_stdout(uint8_t * ptr, size_t len) {
  return std_io_write(std_io_handle_stdout(), ptr, len, 0);
}
int32_t std_io_write_stderr(uint8_t * ptr, size_t len) {
  return std_io_write(std_io_handle_stderr(), ptr, len, 0);
}
int32_t std_io_read_with_timeout(uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  return std_io_read(std_io_handle_stdin(), ptr, len, timeout_ms);
}
int32_t std_io_write_with_timeout(uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  return std_io_write(std_io_handle_stdout(), ptr, len, timeout_ms);
}
int32_t std_io_write_stderr_with_timeout(uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  return std_io_write(std_io_handle_stderr(), ptr, len, timeout_ms);
}
int32_t std_io_read_fd(int32_t fd, uint8_t * ptr, size_t len) {
  return std_io_read(std_io_handle_from_fd(fd, 0), ptr, len, 0);
}
int32_t std_io_write_fd(int32_t fd, uint8_t * ptr, size_t len) {
  return std_io_write(std_io_handle_from_fd(fd, 0), ptr, len, 0);
}
int32_t std_io_read_batch_fd(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n) {
  size_t h = std_io_handle_from_fd(fd, 0);
  struct std_io_driver_Buffer bufs[4] = { (struct std_io_driver_Buffer){ .ptr = p0, .len = l0, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p1, .len = l1, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p2, .len = l2, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p3, .len = l3, .handle = h } };
  return std_io_driver_submit_read_batch(bufs, n, 0);
}
int32_t std_io_write_batch_fd(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n) {
  size_t h = std_io_handle_from_fd(fd, 0);
  struct std_io_driver_Buffer bufs[4] = { (struct std_io_driver_Buffer){ .ptr = p0, .len = l0, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p1, .len = l1, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p2, .len = l2, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p3, .len = l3, .handle = h } };
  return std_io_driver_submit_write_batch(bufs, n, 0);
}
int32_t std_io_read_batch_fd_buf(int32_t fd, struct std_io_driver_Buffer * buffers, int32_t n) {
  size_t h = std_io_handle_from_fd(fd, 0);
  return std_io_driver_submit_read_batch_buf(h, buffers, n, 0);
}
int32_t std_io_write_batch_fd_buf(int32_t fd, struct std_io_driver_Buffer * buffers, int32_t n) {
  size_t h = std_io_handle_from_fd(fd, 0);
  return std_io_driver_submit_write_batch_buf(h, buffers, n, 0);
}
int32_t std_io_print_str(uint8_t * ptr, size_t len) {
  return std_io_write_stdout(ptr, len);
}
int32_t std_io_register_fixed_buffers(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr) {
  return std_io_core_shux_io_register_buffers(p0, l0, p1, l1, p2, l2, p3, l3, nr);
}
int32_t std_io_register_fixed_buffers_buf(struct std_io_driver_Buffer * bufs, uint32_t nr) {
  return std_io_driver_submit_register_fixed_buffers_buf(bufs, nr);
}
int32_t std_io_read_fixed_fd(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  return std_io_core_shux_io_read_fixed(std_io_handle_from_fd(fd, 0), buf_index, offset, len, timeout_ms);
}
int32_t std_io_write_fixed_fd(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  return std_io_core_shux_io_write_fixed(std_io_handle_from_fd(fd, 0), buf_index, offset, len, timeout_ms);
}
int32_t std_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms) {
  return std_io_core_shux_io_wait_readable(fds, n, timeout_ms);
}
int32_t std_io_read_into_slice(struct shux_slice_uint8_t * buf, uint32_t timeout_ms) {
  return std_io_read(std_io_handle_stdin(), (buf)->data, (buf)->length, timeout_ms);
}
int32_t std_io_write_from_slice(struct shux_slice_uint8_t * buf, uint32_t timeout_ms) {
  return std_io_write(std_io_handle_stdout(), (buf)->data, (buf)->length, timeout_ms);
}
int32_t std_io_print_i32(int32_t x) {
  (void)printf("%d\n", (int)x);
  return 0;
}
int32_t std_io_print_u32(uint32_t x) {
  (void)printf("%u\n", (unsigned int)x);
  return 0;
}
int32_t std_io_print_i64(int64_t x) {
  (void)printf("%lld\n", (long long)x);
  return 0;
}
int32_t std_io_placeholder() {
  return 0;
}
extern uint8_t * heap_alloc_c(size_t size);
extern void heap_free_c(uint8_t * ptr);
extern uint8_t * heap_realloc_c(uint8_t * ptr, size_t new_size);
extern uint8_t * heap_alloc_zeroed_c(size_t size);
extern int32_t * heap_alloc_i32_c(int32_t count);
extern int32_t * heap_realloc_i32_c(int32_t * ptr, int32_t new_count);
extern void heap_free_i32_c(int32_t * ptr);
extern uint8_t * heap_alloc_u8_c(int32_t count);
extern uint8_t * heap_realloc_u8_c(uint8_t * ptr, int32_t new_count);
extern void heap_free_u8_c(uint8_t * ptr);
extern void heap_copy_i32_at_c(int32_t * dst, int32_t dst_offset, int32_t * src, int32_t count);
extern void heap_copy_u8_at_c(uint8_t * dst, int32_t dst_offset, uint8_t * src, int32_t count);
extern void heap_mem_set_c(uint8_t * ptr, uint8_t byte, int32_t n);
extern int32_t heap_mem_compare_c(uint8_t * a, uint8_t * b, int32_t n);
extern int32_t map_i32_i32_find_c(int32_t * keys, uint8_t * occupied, int32_t cap, int32_t key);

/* C-04 -E-extern TU aliases (lsp_io via typeck_* from lsp_io_sx.o) */
/* embedded: equivalent to former lsp_gen_extern.h for -E-extern (lsp_gen.c) */
extern ptrdiff_t typeck_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf);
extern ptrdiff_t typeck_write_fd(int32_t fd, uint8_t *ptr, size_t count);
extern uint8_t *typeck_lsp_alloc(size_t size);
extern void typeck_lsp_free(uint8_t *ptr);
extern int32_t typeck_lsp_is_null(uint8_t *ptr);
extern int32_t typeck_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap);
static inline ptrdiff_t lsp_io_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf) {
  return typeck_read_message(fd, body_out, body_cap, state_buf);
}
static inline ptrdiff_t lsp_io_write_fd(int32_t fd, uint8_t *ptr, size_t count) {
  return typeck_write_fd(fd, ptr, count);
}
static inline uint8_t *lsp_io_lsp_alloc(size_t size) {
  return typeck_lsp_alloc(size);
}
static inline void lsp_io_lsp_free(uint8_t *ptr) {
  typeck_lsp_free(ptr);
}
static inline int32_t lsp_io_lsp_is_null(uint8_t *ptr) {
  return typeck_lsp_is_null(ptr);
}
static inline int32_t lsp_io_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap) {
  return typeck_extract_document_text(body, body_len, out_buf, out_cap);
}
static int32_t typeck_LSP_BODY_CAP = 67108864;
static int32_t typeck_LSP_STATE_SIZE = 4 + 8192 * 2;
static int32_t typeck_LSP_DIAG_RESP_CAP = 32768;
static int32_t typeck_LSP_REF_RESP_CAP = 8192;
static int32_t typeck_LSP_FORMAT_RESP_CAP = 262144;
extern void lsp_io_lsp_diag_invalidate_cache();
extern uint8_t * lsp_state_buf_ptr();
extern int32_t lsp_build_initialize_result(uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_diagnostics_response(int32_t id_val, uint8_t * source, int32_t source_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_definition_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_references_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_hover_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_formatting_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_completion_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_document_symbol_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_semantic_tokens_response(int32_t id_val, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_rename_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern void lsp_diag_invalidate_cache();
extern int32_t lsp_build_response_with_result(int32_t id_val, uint8_t * result_ptr, int32_t result_len, uint8_t * out_buf, int32_t out_cap);
extern void lsp_set_document_from_body(uint8_t * body, int32_t body_len);
extern uint8_t * lsp_get_document_ptr();
extern int32_t lsp_get_document_len();
int32_t typeck_lsp_body_contains_initialize(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_initialized(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_shutdown(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_did_open(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_did_change(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_did_save(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_diagnostic(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_completion(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_document_symbol(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_semantic_tokens(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_rename(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_did_close(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_cancel(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_did_change_config(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_definition(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_references(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_hover(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_formatting(uint8_t * body, int32_t len);
int32_t typeck_lsp_body_contains_exit(uint8_t * body, int32_t len);
int32_t typeck_lsp_parse_id(uint8_t * body, int32_t len, uint8_t * id_buf, int32_t id_buf_len);
int32_t typeck_lsp_send_response(int32_t fd, uint8_t * body, int32_t body_len);
int32_t typeck_lsp_main_impl();
int32_t typeck_lsp_body_contains_initialize(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 10 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 105 && (body)[i + 1] == 110 && (body)[i + 2] == 105 && (body)[i + 3] == 116 && (body)[i + 4] == 105 && (body)[i + 5] == 97 && (body)[i + 6] == 108 && (body)[i + 7] == 105 && (body)[i + 8] == 122 && (body)[i + 9] == 101) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_initialized(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 11 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 105 && (body)[i + 1] == 110 && (body)[i + 2] == 105 && (body)[i + 3] == 116 && (body)[i + 4] == 105 && (body)[i + 5] == 97 && (body)[i + 6] == 108 && (body)[i + 7] == 105 && (body)[i + 8] == 122 && (body)[i + 9] == 101 && (body)[i + 10] == 100) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_shutdown(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 8 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 115 && (body)[i + 1] == 104 && (body)[i + 2] == 117 && (body)[i + 3] == 116 && (body)[i + 4] == 100 && (body)[i + 5] == 111 && (body)[i + 6] == 119 && (body)[i + 7] == 110) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_did_open(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 19 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 100 && (body)[i + 14] == 105 && (body)[i + 15] == 100 && (body)[i + 16] == 79 && (body)[i + 17] == 112 && (body)[i + 18] == 101 && (body)[i + 19] == 110) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_did_change(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 21 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 100 && (body)[i + 14] == 105 && (body)[i + 15] == 100 && (body)[i + 16] == 67 && (body)[i + 17] == 104 && (body)[i + 18] == 97 && (body)[i + 19] == 110 && (body)[i + 20] == 103 && (body)[i + 21] == 101) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_did_save(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 19 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 100 && (body)[i + 14] == 105 && (body)[i + 15] == 100 && (body)[i + 16] == 83 && (body)[i + 17] == 97 && (body)[i + 18] == 118 && (body)[i + 19] == 101) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_diagnostic(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 23 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 100 && (body)[i + 14] == 105 && (body)[i + 15] == 97 && (body)[i + 16] == 103 && (body)[i + 17] == 110 && (body)[i + 18] == 111 && (body)[i + 19] == 115 && (body)[i + 20] == 116 && (body)[i + 21] == 105 && (body)[i + 22] == 99) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_completion(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 23 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 99 && (body)[i + 14] == 111 && (body)[i + 15] == 109 && (body)[i + 16] == 112 && (body)[i + 17] == 108 && (body)[i + 18] == 101 && (body)[i + 19] == 116 && (body)[i + 20] == 105 && (body)[i + 21] == 111 && (body)[i + 22] == 110) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_document_symbol(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 27 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 100 && (body)[i + 14] == 111 && (body)[i + 15] == 99 && (body)[i + 16] == 117 && (body)[i + 17] == 109 && (body)[i + 18] == 101 && (body)[i + 19] == 110 && (body)[i + 20] == 116 && (body)[i + 21] == 83 && (body)[i + 22] == 121 && (body)[i + 23] == 109 && (body)[i + 24] == 98 && (body)[i + 25] == 111 && (body)[i + 26] == 108) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_semantic_tokens(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 28 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 115 && (body)[i + 14] == 101 && (body)[i + 15] == 109 && (body)[i + 16] == 97 && (body)[i + 17] == 110 && (body)[i + 18] == 116 && (body)[i + 19] == 105 && (body)[i + 20] == 99 && (body)[i + 21] == 84 && (body)[i + 22] == 111 && (body)[i + 23] == 107 && (body)[i + 24] == 101 && (body)[i + 25] == 110 && (body)[i + 26] == 115) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_rename(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 20 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 114 && (body)[i + 14] == 101 && (body)[i + 15] == 110 && (body)[i + 16] == 97 && (body)[i + 17] == 109 && (body)[i + 18] == 101) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_did_close(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 20 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 100 && (body)[i + 14] == 105 && (body)[i + 15] == 100 && (body)[i + 16] == 67 && (body)[i + 17] == 108 && (body)[i + 18] == 111 && (body)[i + 19] == 115 && (body)[i + 20] == 101) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_cancel(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 14 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 36 && (body)[i + 1] == 47 && (body)[i + 2] == 99 && (body)[i + 3] == 97 && (body)[i + 4] == 110 && (body)[i + 5] == 99 && (body)[i + 6] == 101 && (body)[i + 7] == 108 && (body)[i + 8] == 82 && (body)[i + 9] == 101 && (body)[i + 10] == 113 && (body)[i + 11] == 117 && (body)[i + 12] == 101 && (body)[i + 13] == 115 && (body)[i + 14] == 116) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_did_change_config(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 35 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 119 && (body)[i + 1] == 111 && (body)[i + 2] == 114 && (body)[i + 3] == 107 && (body)[i + 4] == 115 && (body)[i + 5] == 112 && (body)[i + 6] == 97 && (body)[i + 7] == 99 && (body)[i + 8] == 101 && (body)[i + 9] == 47 && (body)[i + 10] == 100 && (body)[i + 11] == 105 && (body)[i + 12] == 100 && (body)[i + 13] == 67 && (body)[i + 14] == 104 && (body)[i + 15] == 97 && (body)[i + 16] == 110 && (body)[i + 17] == 103 && (body)[i + 18] == 101 && (body)[i + 19] == 67 && (body)[i + 20] == 111 && (body)[i + 21] == 110 && (body)[i + 22] == 102 && (body)[i + 23] == 105 && (body)[i + 24] == 103 && (body)[i + 25] == 117 && (body)[i + 26] == 114 && (body)[i + 27] == 97 && (body)[i + 28] == 116 && (body)[i + 29] == 105 && (body)[i + 30] == 111 && (body)[i + 31] == 110) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_definition(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 22 < len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 100 && (body)[i + 14] == 101 && (body)[i + 15] == 102 && (body)[i + 16] == 105 && (body)[i + 17] == 110 && (body)[i + 18] == 105 && (body)[i + 19] == 116 && (body)[i + 20] == 105 && (body)[i + 21] == 111 && (body)[i + 22] == 110) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_references(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 23 < len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 114 && (body)[i + 14] == 101 && (body)[i + 15] == 102 && (body)[i + 16] == 101 && (body)[i + 17] == 114 && (body)[i + 18] == 101 && (body)[i + 19] == 110 && (body)[i + 20] == 99 && (body)[i + 21] == 101 && (body)[i + 22] == 115 && (body)[i + 23] == 115) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_hover(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 17 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 104 && (body)[i + 14] == 111 && (body)[i + 15] == 118 && (body)[i + 16] == 101 && (body)[i + 17] == 114) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_formatting(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 23 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 116 && (body)[i + 1] == 101 && (body)[i + 2] == 120 && (body)[i + 3] == 116 && (body)[i + 4] == 68 && (body)[i + 5] == 111 && (body)[i + 6] == 99 && (body)[i + 7] == 117 && (body)[i + 8] == 109 && (body)[i + 9] == 101 && (body)[i + 10] == 110 && (body)[i + 11] == 116 && (body)[i + 12] == 47 && (body)[i + 13] == 102 && (body)[i + 14] == 111 && (body)[i + 15] == 114 && (body)[i + 16] == 109 && (body)[i + 17] == 97 && (body)[i + 18] == 116 && (body)[i + 19] == 116 && (body)[i + 20] == 105 && (body)[i + 21] == 110 && (body)[i + 22] == 103) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_body_contains_exit(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (i + 4 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 101 && (body)[i + 1] == 120 && (body)[i + 2] == 105 && (body)[i + 3] == 116) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return 0;
}
int32_t typeck_lsp_parse_id(uint8_t * body, int32_t len, uint8_t * id_buf, int32_t id_buf_len) {
  int32_t i = 0;
  while (i + 6 <= len) {
    (void)(({ int32_t __tmp = 0; if ((body)[i] == 34 && (body)[i + 1] == 105 && (body)[i + 2] == 100 && (body)[i + 3] == 34 && (body)[i + 4] == 58) {   (void)((i = i + 5));
  while (i < len && (body)[i] == 32 || (body)[i] == 9) {
    (void)((i = i + 1));
  }
  (void)(({ int32_t __tmp = 0; if (i >= len) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t val = 0;
  int32_t j = 0;
  while (i < len && j < id_buf_len - 1) {
    uint8_t c = (body)[i];
    (void)(({ int32_t __tmp = 0; if (c >= 48 && c <= 57) {   (void)((val = val * 10 + ((int32_t)(c)) - 48));
  (void)(((id_buf)[j] = c));
  (void)((j = j + 1));
  (void)((i = i + 1));
 } else {   break;
 } ; __tmp; }));
  }
  (void)(((id_buf)[j] = 0));
  return val;
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
  return (-1);
}
int32_t typeck_lsp_send_response(int32_t fd, uint8_t * body, int32_t body_len) {
  uint8_t header[64] = { 0 };
  (void)(((header)[0] = 67));
  (void)(((1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[1] = 111, 0))));
  (void)(((2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[2] = 110, 0))));
  (void)(((3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[3] = 116, 0))));
  (void)(((4 < 0 || (4) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[4] = 101, 0))));
  (void)(((5 < 0 || (5) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[5] = 110, 0))));
  (void)(((6 < 0 || (6) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[6] = 116, 0))));
  (void)(((7 < 0 || (7) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[7] = 45, 0))));
  (void)(((8 < 0 || (8) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[8] = 76, 0))));
  (void)(((9 < 0 || (9) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[9] = 101, 0))));
  (void)(((10 < 0 || (10) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[10] = 110, 0))));
  (void)(((11 < 0 || (11) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[11] = 103, 0))));
  (void)(((12 < 0 || (12) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[12] = 116, 0))));
  (void)(((13 < 0 || (13) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[13] = 104, 0))));
  (void)(((14 < 0 || (14) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[14] = 58, 0))));
  (void)(((15 < 0 || (15) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[15] = 32, 0))));
  int32_t n = body_len;
  int32_t k = 16;
  (void)(({ int32_t __tmp = 0; if (n == 0) {   (void)(((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[k] = 48, 0))));
  (void)((k = k + 1));
 } else {   int32_t digits[12] = { 0 };
  int32_t d = 0;
  int32_t n2 = n;
  while (n2 > 0) {
    (void)(((d < 0 || (d) >= 12 ? (shux_panic_(1, 0), 0) : ((digits)[d] = (10 == 0 ? (shux_panic_(1, 0), n2) : (n2 % 10)), 0))));
    (void)((n2 = (10 == 0 ? (shux_panic_(1, 0), n2) : (n2 / 10))));
    (void)((d = d + 1));
  }
  int32_t idx = d - 1;
  while (idx >= 0) {
    (void)(((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[k] = ((uint8_t)((idx < 0 || (idx) >= 12 ? (shux_panic_(1, 0), (digits)[0]) : (digits)[idx]) + 48)), 0))));
    (void)((k = k + 1));
    (void)((idx = idx - 1));
  }
 } ; __tmp; }));
  (void)(((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[k] = 13, 0))));
  (void)((k = k + 1));
  (void)(((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[k] = 10, 0))));
  (void)((k = k + 1));
  (void)(((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[k] = 13, 0))));
  (void)((k = k + 1));
  (void)(((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), 0) : ((header)[k] = 10, 0))));
  (void)((k = k + 1));
  ptrdiff_t w = lsp_io_write_fd(fd, header, ((size_t)(k)));
  (void)(({ int32_t __tmp = 0; if (w < 0 || ((int32_t)(w)) != k) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (body_len > 0) {   ptrdiff_t w2 = lsp_io_write_fd(fd, body, ((size_t)(body_len)));
  __tmp = ({ int32_t __tmp = 0; if (w2 < 0 || ((int32_t)(w2)) != body_len) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t typeck_lsp_main_impl() {
  int32_t stdin_fd = 0;
  int32_t stdout_fd = 1;
  uint8_t out_buf[4096] = { 0 };
  int32_t shutdown_requested = 0;
  uint8_t id_buf[32] = { 0 };
  uint8_t * state_ptr = lsp_state_buf_ptr();
  uint8_t * diag_ptr = lsp_io_lsp_alloc(((size_t)(typeck_LSP_DIAG_RESP_CAP)));
  uint8_t * ref_ptr = lsp_io_lsp_alloc(((size_t)(typeck_LSP_REF_RESP_CAP)));
  uint8_t * format_ptr = lsp_io_lsp_alloc(((size_t)(typeck_LSP_FORMAT_RESP_CAP)));
  (void)(({ int32_t __tmp = 0; if (lsp_io_lsp_is_null(state_ptr) != 0 || lsp_io_lsp_is_null(diag_ptr) != 0 || lsp_io_lsp_is_null(ref_ptr) != 0 || lsp_io_lsp_is_null(format_ptr) != 0) {   (void)(({ int32_t __tmp = 0; if (lsp_io_lsp_is_null(diag_ptr) == 0) {   (void)(lsp_io_lsp_free(diag_ptr));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lsp_io_lsp_is_null(ref_ptr) == 0) {   (void)(lsp_io_lsp_free(ref_ptr));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lsp_io_lsp_is_null(format_ptr) == 0) {   (void)(lsp_io_lsp_free(format_ptr));
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  while (1) {
    uint8_t * body_ptr = lsp_io_lsp_alloc(((size_t)(typeck_LSP_BODY_CAP)));
    (void)(({ int32_t __tmp = 0; if (lsp_io_lsp_is_null(body_ptr) != 0) {   continue;
 } else (__tmp = 0) ; __tmp; }));
    ptrdiff_t msg_len = lsp_io_read_message(stdin_fd, body_ptr, typeck_LSP_BODY_CAP, state_ptr);
    (void)(({ int32_t __tmp = 0; if (msg_len < 0) {   (void)(lsp_io_lsp_free(body_ptr));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (msg_len == 0) {   (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t content_len = ((int32_t)(msg_len));
    (void)(({ int32_t __tmp = 0; if (content_len > typeck_LSP_BODY_CAP) {   (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_did_open(body_ptr, content_len) != 0) {   (void)(lsp_set_document_from_body(body_ptr, content_len));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_did_change(body_ptr, content_len) != 0) {   (void)(lsp_set_document_from_body(body_ptr, content_len));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_did_save(body_ptr, content_len) != 0) {   (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_did_close(body_ptr, content_len) != 0) {   (void)(lsp_io_lsp_diag_invalidate_cache());
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_cancel(body_ptr, content_len) != 0) {   (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_did_change_config(body_ptr, content_len) != 0) {   (void)(lsp_io_lsp_diag_invalidate_cache());
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_exit(body_ptr, content_len) != 0 && shutdown_requested != 0) {   (void)(lsp_io_lsp_free(body_ptr));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_shutdown(body_ptr, content_len) != 0) {   (void)((shutdown_requested = 1));
  int32_t sid = typeck_lsp_parse_id(body_ptr, content_len, id_buf, 32);
  (void)(({ int32_t __tmp = 0; if (sid < 0) {   (void)((sid = 1));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t null_val[4] = { 110, 117, 108, 108 };
  int32_t resp_len = lsp_build_response_with_result(sid, null_val, 4, out_buf, 4096);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, resp_len));
 } else (__tmp = 0) ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_initialized(body_ptr, content_len) != 0) {   (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_initialize(body_ptr, content_len) != 0) {   int32_t out_len = lsp_build_initialize_result(out_buf, 4096);
  (void)(({ int32_t __tmp = 0; if (out_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, out_len));
 } else (__tmp = 0) ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t req_id = typeck_lsp_parse_id(body_ptr, content_len, id_buf, 32);
    uint8_t * doc_ptr = lsp_get_document_ptr();
    int32_t doc_len = lsp_get_document_len();
    (void)(({ int32_t __tmp = 0; if (req_id >= 0) {   uint8_t empty_arr[2] = { 91, 93 };
  uint8_t null_val[4] = { 110, 117, 108, 108 };
  (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_diagnostic(body_ptr, content_len) != 0) {   int32_t resp_len = lsp_build_diagnostics_response(req_id, doc_ptr, doc_len, diag_ptr, typeck_LSP_DIAG_RESP_CAP);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, diag_ptr, resp_len));
 } else {   int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
  __tmp = ({ int32_t __tmp = 0; if (fallback_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, fallback_len));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_definition(body_ptr, content_len) != 0) {   int32_t resp_len = lsp_build_definition_response(req_id, body_ptr, content_len, doc_ptr, doc_len, out_buf, 4096);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, resp_len));
 } else {   int32_t fallback_len = lsp_build_response_with_result(req_id, null_val, 4, out_buf, 4096);
  __tmp = ({ int32_t __tmp = 0; if (fallback_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, fallback_len));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_references(body_ptr, content_len) != 0) {   int32_t resp_len = lsp_build_references_response(req_id, body_ptr, content_len, doc_ptr, doc_len, ref_ptr, typeck_LSP_REF_RESP_CAP);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, ref_ptr, resp_len));
 } else {   int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
  __tmp = ({ int32_t __tmp = 0; if (fallback_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, fallback_len));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_hover(body_ptr, content_len) != 0) {   int32_t resp_len = lsp_build_hover_response(req_id, body_ptr, content_len, doc_ptr, doc_len, out_buf, 4096);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, resp_len));
 } else {   int32_t fallback_len = lsp_build_response_with_result(req_id, null_val, 4, out_buf, 4096);
  __tmp = ({ int32_t __tmp = 0; if (fallback_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, fallback_len));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_formatting(body_ptr, content_len) != 0) {   int32_t resp_len = lsp_build_formatting_response(req_id, body_ptr, content_len, doc_ptr, doc_len, format_ptr, typeck_LSP_FORMAT_RESP_CAP);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, format_ptr, resp_len));
 } else {   int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
  __tmp = ({ int32_t __tmp = 0; if (fallback_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, fallback_len));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_completion(body_ptr, content_len) != 0) {   int32_t resp_len = lsp_build_completion_response(req_id, body_ptr, content_len, doc_ptr, doc_len, format_ptr, typeck_LSP_FORMAT_RESP_CAP);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, format_ptr, resp_len));
 } else {   int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
  __tmp = ({ int32_t __tmp = 0; if (fallback_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, fallback_len));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_document_symbol(body_ptr, content_len) != 0) {   int32_t resp_len = lsp_build_document_symbol_response(req_id, body_ptr, content_len, doc_ptr, doc_len, format_ptr, typeck_LSP_FORMAT_RESP_CAP);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, format_ptr, resp_len));
 } else {   int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
  __tmp = ({ int32_t __tmp = 0; if (fallback_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, fallback_len));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (typeck_lsp_body_contains_semantic_tokens(body_ptr, content_len) != 0) {   int32_t resp_len = lsp_build_semantic_tokens_response(req_id, doc_ptr, doc_len, format_ptr, typeck_LSP_FORMAT_RESP_CAP);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, format_ptr, resp_len));
 } else {   int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
  __tmp = ({ int32_t __tmp = 0; if (fallback_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, fallback_len));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (typeck_lsp_body_contains_rename(body_ptr, content_len) != 0) {   int32_t resp_len = lsp_build_rename_response(req_id, body_ptr, content_len, doc_ptr, doc_len, format_ptr, typeck_LSP_FORMAT_RESP_CAP);
  (void)(({ int32_t __tmp = 0; if (resp_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, format_ptr, resp_len));
 } else {   int32_t fallback_len = lsp_build_response_with_result(req_id, null_val, 4, out_buf, 4096);
  __tmp = ({ int32_t __tmp = 0; if (fallback_len > 0) {   (void)(typeck_lsp_send_response(stdout_fd, out_buf, fallback_len));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(lsp_io_lsp_free(body_ptr));
  continue;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(lsp_io_lsp_free(body_ptr));
  }
  (void)(lsp_io_lsp_free(diag_ptr));
  (void)(lsp_io_lsp_free(ref_ptr));
  (void)(lsp_io_lsp_free(format_ptr));
  return 0;
}
