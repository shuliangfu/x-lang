/* seeds/labi_path_io.from_x.c — G-02f-270/L P2 link_abi L3 path IO → R2 full
 * Logic source: src/runtime/labi_path_io.x
 * Hybrid: SHUX_LABI_PATH_IO_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14）：公共业务符号由 full .x 提供：
 *   shux_path_is_nonempty_regular_file + asm_link_obj_skip_missing
 *   + shux_runtime_o_realpath_if_exists + labi_path_io_count
 * Cap residual（mega rest 常驻）：
 *   shux_path_is_nonempty_regular_file_impl（struct stat / S_ISREG）
 *   shux_runtime_o_realpath_if_exists_impl（libc realpath + skip）
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C thin 体（可与 mega _impl 并存）。
 *
 * Prove：seeds/labi_path_io_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>

/* OS bodies provided by runtime_link_abi.from_x.c rest (always). */
int shux_path_is_nonempty_regular_file_impl(const char *path);
const char *shux_runtime_o_realpath_if_exists_impl(const char *path, char *resolved);

#ifndef SHUX_LABI_PATH_IO_FROM_X

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

#else
int shux_path_is_nonempty_regular_file(const char *path);
const char *asm_link_obj_skip_missing(const char *path);
const char *shux_runtime_o_realpath_if_exists(const char *path, char *resolved);
int labi_path_io_count(void);
#endif

int labi_path_io_slice_marker(void) {
  return 1;
}
