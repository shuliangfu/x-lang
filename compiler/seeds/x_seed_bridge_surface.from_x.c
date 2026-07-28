/* seeds/x_seed_bridge_surface.from_x.c
 * G-02f-92 x_seed_bridge R2 mixed surface - isomorphic with src/x_seed_bridge.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/x_seed_bridge.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (14 #[no_mangle])
 * Mode: mixed - 5 thin+rest forwards + 9 DIRECT (8 stubs + 1 forward chain)
 * Cap residual: 4 extern bridges (preprocess_x_buf + typeck_std_heap_alloc + calloc + free)
 * No doc_anchor (x_seed_bridge.x has none).
 * Note: typeck_/std_heap_/io_/xlang_io_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 14 functions = 5 thin+rest + 9 DIRECT.
 * Regen: ./xlang-c -E ... x_seed_bridge.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t preprocess_x_buf(uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap);
extern uint8_t *typeck_std_heap_alloc(size_t size);
extern void *calloc(size_t n, size_t size);
extern void free(void *ptr);

/* === 5 thin+rest forwards === */

int32_t typeck_preprocess_x_buf(uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap) {
  int32_t r = preprocess_x_buf(src, src_len, out_buf, out_cap);
  return r;
}

uint8_t *std_heap_alloc_zeroed(size_t size) {
  uint8_t *r = (uint8_t *)calloc(1, size);
  return r;
}

uint8_t *std_heap_alloc_zero(size_t size) {
  return std_heap_alloc_zeroed(size);
}

void std_heap_free(uint8_t *ptr) {
  free(ptr);
}

uint8_t *std_heap_alloc(size_t size) {
  uint8_t *r = typeck_std_heap_alloc(size);
  return r;
}

/* === 9 DIRECT (8 stubs + 1 forward chain) === */

uint8_t *io_read_ptr(uint32_t handle, uint32_t timeout_ms) {
  return (uint8_t *)0;
}

int32_t io_read_ptr_len(void) {
  return 0;
}

int32_t io_register_buffer(uint8_t *ptr, size_t len) {
  return 0;
}

void io_unregister_buffers(void) {
}

int32_t io_wait_readable(int32_t *fds, int32_t n, uint32_t timeout_ms) {
  return 0;
}

int32_t io_register_buffers_4(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2,
                              uint8_t *p3, size_t l3, uint32_t nr) {
  return 0;
}

int32_t io_register_buffers_buf(uint8_t *bufs, int32_t nr) {
  return 0;
}

int32_t io_register_buffers_buf_i32(ptrdiff_t bufs, int32_t nr) {
  return io_register_buffers_buf((uint8_t *)0, nr);
}

int32_t xlang_io_register(uint8_t *ptr, size_t len, size_t handle) {
  return io_register_buffer(ptr, len);
}
