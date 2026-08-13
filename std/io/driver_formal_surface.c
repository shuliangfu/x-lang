/* PLATFORM: SHARED — pure-asm formal vehicle for std.io.driver (class-batch 2).
 *
 * Why C face: driver.x monofile co-emits std.io.core/backend with prefix drift
 * (std_io_core_* vs std_io_backend_*) and host-cc fails. Product monofile stays
 * driver.x for C path. This vehicle exports std_io_driver_* no-op success (0).
 *
 * Buffer ABI: 24 bytes { ptr, length, handle } — match tests/io-driver + product.
 * G.7: single formal vehicle for pure-asm product link (std/io/driver.o).
 * formal_mod kind=c_face.
 */
#include <stdint.h>
#include <stddef.h>

typedef struct std_io_driver_Buffer {
  uint8_t *ptr;
  size_t length;
  size_t handle;
} std_io_driver_Buffer;

int32_t std_io_driver_register(std_io_driver_Buffer buf) {
  (void)buf;
  return 0;
}

int32_t std_io_driver_submit_read(std_io_driver_Buffer buf, uint32_t timeout_ms) {
  (void)buf;
  (void)timeout_ms;
  return 0;
}

int32_t std_io_driver_submit_write(std_io_driver_Buffer buf, uint32_t timeout_ms) {
  (void)buf;
  (void)timeout_ms;
  return 0;
}

int32_t std_io_driver_submit_register_fixed_buffers_buf(std_io_driver_Buffer *bufs, uint32_t nr) {
  (void)bufs;
  (void)nr;
  return 0;
}

int32_t std_io_driver_submit_write_batch(std_io_driver_Buffer buffers[4], int32_t n, uint32_t timeout_ms) {
  (void)buffers;
  (void)n;
  (void)timeout_ms;
  return 0;
}

int32_t std_io_driver_submit_read_batch_buf(size_t handle, std_io_driver_Buffer *bufs, int32_t nr, uint32_t timeout_ms) {
  (void)handle;
  (void)bufs;
  (void)nr;
  (void)timeout_ms;
  return 0;
}

int32_t std_io_driver_submit_write_batch_buf(size_t handle, std_io_driver_Buffer *bufs, int32_t nr, uint32_t timeout_ms) {
  (void)handle;
  (void)bufs;
  (void)nr;
  (void)timeout_ms;
  return 0;
}
