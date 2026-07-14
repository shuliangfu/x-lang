/* seeds/runtime_io_abi_surface.from_x.c
 * G-02f runtime_io_abi R2 full surface — isomorphic with src/runtime_io_abi.x
 * Product PREFER_X_O: g05_try_x_to_o(.x) + seed-rest (-DSHUX_L2_RIO_THIN_FROM_X -DSHUX_RUNTIME_IO_ABI_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (19 public + 5 _impl in .x)
 * Cap residual: 4 platform _impl (mmap/fstat/O_* flags) in seeds/runtime_io_abi.from_x.c rest
 * Regen: ./shux-c -E ... runtime_io_abi.x | filter DBG + polish prologue
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
struct ShuxRuntimeFileView {
  uint8_t * data;
  size_t length;
  int32_t needs_free;
  int32_t needs_munmap;
};

extern int32_t std_fs_fs_open_read(uint8_t * path);
extern int32_t shux_fs_open_write_flags(void);
extern int32_t shux_fs_open_write_mode(void);
extern int32_t std_fs_fs_open_write(uint8_t * path);
extern int32_t std_fs_fs_close(int32_t fd);
extern int32_t std_fs_fs_invalid_handle(void);
extern ssize_t std_fs_fs_read(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t std_fs_fs_write(int32_t fd, uint8_t * buf, size_t count);
extern int32_t fs_posix_close_c(int32_t fd);
extern ssize_t fs_posix_read_c(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t fs_posix_write_c(int32_t fd, uint8_t * buf, size_t count);
extern int32_t shux_read_file_into_path(uint8_t * path, uint8_t * buf, int64_t cap);
extern int32_t shux_write_path_bytes(uint8_t * path, uint8_t * data, int64_t len);
extern void runtime_release_file_view(uint8_t * view);
extern int32_t runtime_read_file_view(uint8_t * path, uint8_t * out);
extern uint8_t * runtime_read_file_malloc(uint8_t * path, uint8_t * out_len);
extern int32_t std_sys_os_read_file_into(uint8_t * path, uint8_t * buf, int32_t cap);
extern int32_t shux_read_fd_into_buf(int32_t fd, uint8_t * buf, int64_t cap);
extern int32_t shux_runtime_file_view_read_malloc(int32_t fd, int64_t size, uint8_t * out);
extern int32_t shux_read_fd_into_buf_impl(int32_t fd, uint8_t * buf, int64_t cap);
extern int32_t shux_runtime_file_view_read_malloc_impl(int32_t fd, int64_t size, uint8_t * out);
extern uint8_t * runtime_read_file_malloc_impl(uint8_t * path, uint8_t * out_len);
extern int32_t shux_read_file_into_path_impl(uint8_t * path, uint8_t * buf, int64_t cap);
extern int32_t std_sys_os_read_file_into_impl(uint8_t * path, uint8_t * buf, int32_t cap);
extern int32_t shux_fs_open_write_flags_impl(void);
extern int32_t shux_write_path_bytes_impl(uint8_t * path, uint8_t * data, int64_t len);
extern void runtime_release_file_view_impl(uint8_t * view);
extern int32_t runtime_read_file_view_impl(uint8_t * path, uint8_t * out);
int32_t std_fs_fs_open_read(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  {
    int32_t r = open(path, 0, 0);
    return r;
  }
  return (0 - 1);
}
int32_t shux_fs_open_write_flags(void) {
  {
    return shux_fs_open_write_flags_impl();
  }
  return 0;
}
int32_t shux_fs_open_write_mode(void) {
  return 420;
}
int32_t std_fs_fs_open_write(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  {
    int32_t fl = shux_fs_open_write_flags();
    int32_t md = shux_fs_open_write_mode();
    int32_t r = open(path, fl, md);
    return r;
  }
  return (0 - 1);
}
int32_t std_fs_fs_close(int32_t fd) {
  {
    int32_t r = close(fd);
    return r;
  }
  return (0 - 1);
}
int32_t std_fs_fs_invalid_handle(void) {
  return (0 - 1);
}
ssize_t std_fs_fs_read(int32_t fd, uint8_t * buf, size_t count) {
  if ((buf ==((uint8_t *)(0)))) {
    ssize_t neg = ((ssize_t)((0 - 1)));
    return neg;
  }
  {
    ssize_t n = read(fd, buf, count);
    return n;
  }
  ssize_t neg2 = ((ssize_t)((0 - 1)));
  return neg2;
}
ssize_t std_fs_fs_write(int32_t fd, uint8_t * buf, size_t count) {
  if ((buf ==((uint8_t *)(0)))) {
    ssize_t neg = ((ssize_t)((0 - 1)));
    return neg;
  }
  {
    ssize_t n = write(fd, buf, count);
    return n;
  }
  ssize_t neg2 = ((ssize_t)((0 - 1)));
  return neg2;
}
int32_t fs_posix_close_c(int32_t fd) {
  return std_fs_fs_close(fd);
}
ssize_t fs_posix_read_c(int32_t fd, uint8_t * buf, size_t count) {
  return std_fs_fs_read(fd, buf, count);
}
ssize_t fs_posix_write_c(int32_t fd, uint8_t * buf, size_t count) {
  return std_fs_fs_write(fd, buf, count);
}
int32_t shux_read_file_into_path(uint8_t * path, uint8_t * buf, int64_t cap) {
  if ((path ==((uint8_t *)(0)))) {
    return -(1);
  }
  if ((buf ==((uint8_t *)(0)))) {
    return -(1);
  }
  if ((cap ==0)) {
    return -(1);
  }
  {
    return shux_read_file_into_path_impl(path, buf, cap);
  }
  return -(1);
}
int32_t shux_write_path_bytes(uint8_t * path, uint8_t * data, int64_t len) {
  if ((path ==((uint8_t *)(0)))) {
    return -(1);
  }
  if ((data ==((uint8_t *)(0)))) {
    return -(1);
  }
  {
    return shux_write_path_bytes_impl(path, data, len);
  }
  return -(1);
}
void runtime_release_file_view(uint8_t * view) {
  if ((view ==((uint8_t *)(0)))) {
    return;
  }
  {
    (void)(runtime_release_file_view_impl(view));
  }
  (void)(0);
  return;
}
int32_t runtime_read_file_view(uint8_t * path, uint8_t * out) {
  if ((path ==((uint8_t *)(0)))) {
    return -(1);
  }
  if ((out ==((uint8_t *)(0)))) {
    return -(1);
  }
  {
    return runtime_read_file_view_impl(path, out);
  }
  return -(1);
}
uint8_t * runtime_read_file_malloc(uint8_t * path, uint8_t * out_len) {
  if ((path ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  {
    return runtime_read_file_malloc_impl(path, out_len);
  }
  return ((uint8_t *)(0));
}
int32_t std_sys_os_read_file_into(uint8_t * path, uint8_t * buf, int32_t cap) {
  if ((path ==((uint8_t *)(0)))) {
    return -(1);
  }
  if ((buf ==((uint8_t *)(0)))) {
    return -(1);
  }
  if ((cap <=0)) {
    return -(1);
  }
  {
    return std_sys_os_read_file_into_impl(path, buf, cap);
  }
  return -(1);
}
int32_t shux_read_fd_into_buf(int32_t fd, uint8_t * buf, int64_t cap) {
  {
    return shux_read_fd_into_buf_impl(fd, buf, cap);
  }
  return (0 - 1);
}
int32_t shux_runtime_file_view_read_malloc(int32_t fd, int64_t size, uint8_t * out) {
  {
    return shux_runtime_file_view_read_malloc_impl(fd, size, out);
  }
  return (0 - 1);
}
int32_t shux_read_fd_into_buf_impl(int32_t fd, uint8_t * buf, int64_t cap) {
  if ((fd < 0)) {
    return -(1);
  }
  if ((buf ==((uint8_t *)(0)))) {
    return -(1);
  }
  if ((cap ==0)) {
    return -(1);
  }
  if ((cap > 2147483647)) {
    return -(1);
  }
  size_t off = ((size_t)(0));
  size_t cap_u = ((size_t)(cap));
  while ((off < cap_u)) {
    {
      ssize_t n = read(fd, (buf + off), (cap_u - off));
      if ((n < 0)) {
        return -(1);
      }
      if ((n ==0)) {
        break;
      }
      (void)((off = (off + ((size_t)(n)))));
    }
  }
  return ((int32_t)(off));
}
int32_t shux_runtime_file_view_read_malloc_impl(int32_t fd, int64_t size, uint8_t * out) {
  size_t size_u = ((size_t)(size));
  uint8_t * buf = ((uint8_t *)(0));
  {
    (void)((buf = malloc((size_u + 1))));
  }
  if ((buf ==((uint8_t *)(0)))) {
    {
      (void)(close(fd));
    }
    return -(1);
  }
  size_t off = ((size_t)(0));
  while ((off < size_u)) {
    {
      ssize_t n = read(fd, (buf + off), (size_u - off));
      if ((n < 0)) {
        (void)(free(buf));
        (void)(close(fd));
        return -(1);
      }
      if ((n ==0)) {
        break;
      }
      (void)((off = (off + ((size_t)(n)))));
    }
  }
  {
    (void)(close(fd));
  }
  if ((off !=size_u)) {
    {
      (void)(free(buf));
    }
    return -(1);
  }
  uint8_t * zero_ptr = (buf + size_u);
  (void)(((zero_ptr)[0] = 0));
  struct ShuxRuntimeFileView * out_view = ((struct ShuxRuntimeFileView *)(out));
  (void)(((out_view->data) = buf));
  (void)(((out_view->length) = size_u));
  (void)(((out_view->needs_free) = 1));
  (void)(((out_view->needs_munmap) = 0));
  return 0;
}
uint8_t * runtime_read_file_malloc_impl(uint8_t * path, uint8_t * out_len) {
  struct ShuxRuntimeFileView view = (struct ShuxRuntimeFileView){ .data = ((uint8_t *)(0)), .length = 0, .needs_free = 0, .needs_munmap = 0 };
  int32_t view_rc = runtime_read_file_view(path, ((uint8_t *)(&(view))));
  if ((view_rc !=0)) {
    return ((uint8_t *)(0));
  }
  uint8_t * buf = ((uint8_t *)(0));
  {
    (void)((buf = malloc(((view.length) + 1))));
  }
  if ((buf ==((uint8_t *)(0)))) {
    (void)(runtime_release_file_view(((uint8_t *)(&(view)))));
    return ((uint8_t *)(0));
  }
  if (((view.length) > 0)) {
    {
      (void)(memcpy(buf, (view.data), (view.length)));
    }
  }
  uint8_t * zero_ptr = (buf + (view.length));
  (void)(((zero_ptr)[0] = 0));
  if ((out_len !=((uint8_t *)(0)))) {
    size_t * out_len_ptr = ((size_t *)(out_len));
    (void)(((out_len_ptr)[0] = (view.length)));
  }
  (void)(runtime_release_file_view(((uint8_t *)(&(view)))));
  return buf;
}
int32_t shux_read_file_into_path_impl(uint8_t * path, uint8_t * buf, int64_t cap) {
  if ((cap > 2147483647)) {
    return -(1);
  }
  int32_t fd = 0;
  {
    (void)((fd = open(path, 0, 0)));
  }
  if ((fd < 0)) {
    return -(1);
  }
  int32_t n = shux_read_fd_into_buf_impl(fd, buf, cap);
  {
    (void)(close(fd));
  }
  return n;
}
int32_t std_sys_os_read_file_into_impl(uint8_t * path, uint8_t * buf, int32_t cap) {
  if ((path ==((uint8_t *)(0)))) {
    return -(1);
  }
  if ((buf ==((uint8_t *)(0)))) {
    return -(1);
  }
  if ((cap <=0)) {
    return -(1);
  }
  int32_t fd = 0;
  {
    (void)((fd = open(path, 0, 0)));
  }
  if ((fd < 0)) {
    return -(1);
  }
  int32_t total = 0;
  while ((total < cap)) {
    int32_t chunk = (cap - total);
    {
      ssize_t r = read(fd, (buf + ((size_t)(total))), ((size_t)(chunk)));
      if ((r < 0)) {
        (void)(close(fd));
        return -(1);
      }
      if ((r ==0)) {
        break;
      }
      (void)((total = (total + ((int32_t)(r)))));
    }
  }
  {
    (void)(close(fd));
  }
  return total;
}
