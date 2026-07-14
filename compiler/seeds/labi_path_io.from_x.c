/* seeds/labi_path_io.from_x.c — G-02f-270/L P2 link_abi L3 path IO thin shells
 * Logic source: src/runtime/labi_path_io.x（真迁 null-check；stat/realpath 在 mega rest）
 * Hybrid: SHUX_LABI_PATH_IO_FROM_X + ld -r into runtime_link_abi.o
 * 产品 PREFER_X_O：g05_try_x_to_o(labi_path_io.x)；本 seed 冷启动 / fallback
 * prove：nm IDENTICAL（3 公共 gate + labi_path_io_count + U _impl）
 *
 * Thin null-check shells that forward to *_impl in mega rest.
 * 🔒 stat body: shux_path_is_nonempty_regular_file_impl (always in rest)
 * 🔒 realpath body: shux_runtime_o_realpath_if_exists_impl (always in rest)
 */
#include <stddef.h>

/* OS bodies provided by runtime_link_abi.from_x.c rest (always). */
int shux_path_is_nonempty_regular_file_impl(const char *path);
const char *shux_runtime_o_realpath_if_exists_impl(const char *path, char *resolved);

int shux_path_is_nonempty_regular_file(const char *path) {
  if (path == NULL)
    return 0;
  if (path[0] == 0)
    return 0;
  return shux_path_is_nonempty_regular_file_impl(path);
}

const char *asm_link_obj_skip_missing(const char *path) {
  if (path == NULL)
    return NULL;
  if (path[0] == 0)
    return NULL;
  if (shux_path_is_nonempty_regular_file(path) == 0)
    return NULL;
  return path;
}

const char *shux_runtime_o_realpath_if_exists(const char *path, char *resolved) {
  if (path == NULL)
    return NULL;
  if (path[0] == 0)
    return NULL;
  if (resolved == NULL)
    return NULL;
  return shux_runtime_o_realpath_if_exists_impl(path, resolved);
}

/* Pure audit: number of L3 thin path-IO gates in this slice. */
int labi_path_io_count(void) {
  return 3;
}
