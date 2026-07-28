/* seeds/runtime_env_os_surface.from_x.c
 * G-02f-123 runtime_env_os R2 thin+rest surface — isomorphic with src/asm/runtime_env_os.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + ld -r with rest (seeds/runtime_env_os.from_x.c)
 * Prove: full.x vs this surface → nm IDENTICAL (10 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest — .x provides 10 public API (1 DIRECT env_build_key + 9 thin+rest forwards);
 *   _impl bridges (getenv/setenv/unsetenv/temp_dir/iter OS calls) stay in rest seed
 * Cap residual: 9 _impl — env_getenv_c/ptr/z/exists + setenv + unsetenv + temp_dir + iter_count/at
 *   (POSIX getenv/setenv/unsetenv/environ + Windows GetEnvironmentVariableA/_putenv)
 * Note: doc_anchor runtime_env_os_x_doc_anchor (no ast_ prefix; env_ prefix doesn't trigger).
 * Logic: 10 functions = env_build_key (DIRECT, pure key copy + NUL) +
 *   9 env_*_c (thin+rest forwards to _impl extern C bridges).
 * Regen: ./xlang-c -E ... runtime_env_os.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t env_getenv_c_impl(uint8_t *key, int32_t key_len, uint8_t *out, int32_t out_cap);
extern uint8_t *env_getenv_ptr_c_impl(uint8_t *key, int32_t key_len, int32_t *out_len);
extern uint8_t *env_getenv_z_c_impl(uint8_t *key_z, int32_t *out_len);
extern int32_t env_getenv_exists_c_impl(uint8_t *key, int32_t key_len);
extern int32_t env_setenv_c_impl(uint8_t *name, uint8_t *value, int32_t overwrite);
extern int32_t env_unsetenv_c_impl(uint8_t *name);
extern int32_t env_temp_dir_c_impl(uint8_t *out, int32_t out_cap);
extern int32_t env_iter_count_c_impl(void);
extern int32_t env_iter_at_c_impl(int32_t index, uint8_t *key_out, int32_t key_cap,
                                  uint8_t *val_out, int32_t val_cap);

int32_t runtime_env_os_x_doc_anchor(void) {
  return 0;
}

int32_t env_build_key(uint8_t *key, int32_t key_len, uint8_t *key_buf) {
  if (key == 0) { return 0 - 1; }
  if (key_buf == 0) { return 0 - 1; }
  if (key_len <= 0) { return 0 - 1; }
  if (key_len >= 256) { return 0 - 1; }
  int32_t i = 0;
  while (i < key_len) {
    key_buf[i] = key[i];
    i = i + 1;
  }
  key_buf[key_len] = 0;
  return 0;
}

int32_t env_getenv_c(uint8_t *key, int32_t key_len, uint8_t *out, int32_t out_cap) {
  return env_getenv_c_impl(key, key_len, out, out_cap);
}

uint8_t *env_getenv_ptr_c(uint8_t *key, int32_t key_len, int32_t *out_len) {
  return env_getenv_ptr_c_impl(key, key_len, out_len);
}

uint8_t *env_getenv_z_c(uint8_t *key_z, int32_t *out_len) {
  return env_getenv_z_c_impl(key_z, out_len);
}

int32_t env_getenv_exists_c(uint8_t *key, int32_t key_len) {
  return env_getenv_exists_c_impl(key, key_len);
}

int32_t env_setenv_c(uint8_t *name, uint8_t *value, int32_t overwrite) {
  return env_setenv_c_impl(name, value, overwrite);
}

int32_t env_unsetenv_c(uint8_t *name) {
  return env_unsetenv_c_impl(name);
}

int32_t env_temp_dir_c(uint8_t *out, int32_t out_cap) {
  return env_temp_dir_c_impl(out, out_cap);
}

int32_t env_iter_count_c(void) {
  return env_iter_count_c_impl();
}

int32_t env_iter_at_c(int32_t index, uint8_t *key_out, int32_t key_cap,
                      uint8_t *val_out, int32_t val_cap) {
  return env_iter_at_c_impl(index, key_out, key_cap, val_out, val_cap);
}
