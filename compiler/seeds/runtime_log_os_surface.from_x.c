/* seeds/runtime_log_os_surface.from_x.c
 * G-02f-21 runtime_log_os R2 mixed (thin+rest + DIRECT) surface - isomorphic with src/asm/runtime_log_os.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_log_os.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (17 #[no_mangle] + 1 doc_anchor)
 * Mode: mixed - 7 thin+rest forwards (log_apply_env_once/do_rotate/write_file_sync/write_sync/
 *   async_enqueue/emit_bytes/write_fd -> _impl) + 10 mixed (_c convenience bridges that call
 *   .x public functions or _impl with validation)
 * Cap residual: 14 _impl - log_apply_env_once/do_rotate/write_file_sync/write_sync/async_enqueue/
 *   emit_bytes/write_fd (7) + get_min_level/set_min_level/set_sink_mask/set_file_sink/
 *   close_file_sink/set_rotate/set_async_enabled/async_flush (7)
 * Note: doc_anchor runtime_log_os_x_doc_anchor (no ast_; log_ prefix not trigger).
 * Logic: 17 functions = 7 thin+rest + log_apply_env_once_c (calls log_apply_env_once) +
 *   log_get_min_level_c (calls log_apply_env_once + _impl) +
 *   7 _c thin+rest forwards.
 * Note: log_emit_bytes_c in .x uses `null or` syntax which xlang_asm silently drops during
 *   -E emission; surface mirrors .x actual output (16 #[no_mangle] defined, log_emit_bytes_c
 *   absent from both). To be revisited when compiler fixes null/or parsing.
 * Regen: ./xlang-c -E ... runtime_log_os.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern void log_apply_env_once_impl(void);
extern int32_t log_do_rotate_impl(void);
extern int32_t log_write_file_sync_impl(uint8_t *buf, size_t len);
extern int32_t log_write_sync_impl(uint8_t *buf, size_t len);
extern int32_t log_async_enqueue_impl(uint8_t *buf, size_t len);
extern int32_t log_emit_bytes_impl(uint8_t *buf, size_t len);
extern int32_t log_write_fd_impl(int32_t fd, uint8_t *buf, int32_t len);

extern int32_t log_get_min_level_impl(void);
extern void log_set_min_level_impl(int32_t level);
extern void log_set_sink_mask_impl(int32_t mask);
extern int32_t log_set_file_sink_impl(uint8_t *path, int32_t len);
extern void log_close_file_sink_impl(void);
extern int32_t log_set_rotate_impl(int32_t max_bytes, int32_t max_backups);
extern int32_t log_set_async_enabled_impl(int32_t enabled);
extern int32_t log_async_flush_impl(void);

int32_t runtime_log_os_x_doc_anchor(void) {
  return 0;
}

void log_apply_env_once(void) {
  log_apply_env_once_impl();
}

int32_t log_do_rotate(void) {
  return log_do_rotate_impl();
}

int32_t log_write_file_sync(uint8_t *buf, size_t len) {
  return log_write_file_sync_impl(buf, len);
}

int32_t log_write_sync(uint8_t *buf, size_t len) {
  return log_write_sync_impl(buf, len);
}

int32_t log_async_enqueue(uint8_t *buf, size_t len) {
  return log_async_enqueue_impl(buf, len);
}

int32_t log_emit_bytes(uint8_t *buf, size_t len) {
  return log_emit_bytes_impl(buf, len);
}

int32_t log_write_fd(int32_t fd, uint8_t *buf, int32_t len) {
  return log_write_fd_impl(fd, buf, len);
}

void log_apply_env_once_c(void) {
  log_apply_env_once();
}

int32_t log_get_min_level_c(void) {
  log_apply_env_once();
  return log_get_min_level_impl();
}

void log_set_min_level_c(int32_t level) {
  log_set_min_level_impl(level);
}

void log_set_sink_mask_c(int32_t mask) {
  log_set_sink_mask_impl(mask);
}

int32_t log_set_file_sink_c(uint8_t *path, int32_t len) {
  return log_set_file_sink_impl(path, len);
}

void log_close_file_sink_c(void) {
  log_close_file_sink_impl();
}

int32_t log_set_rotate_c(int32_t max_bytes, int32_t max_backups) {
  return log_set_rotate_impl(max_bytes, max_backups);
}

int32_t log_set_async_enabled_c(int32_t enabled) {
  return log_set_async_enabled_impl(enabled);
}

int32_t log_async_flush_c(void) {
  return log_async_flush_impl();
}
