/* seeds/labi_path_io.from_x.c — G-02f-270 P2 link_abi L3 path IO
 * Logic source: src/runtime/labi_path_io.x
 * Hybrid: SHUX_LABI_PATH_IO_FROM_X + ld -r into runtime_link_abi.o
 * 🔒 stat / realpath (OS filesystem probe).
 */
#include <stddef.h>
#include <stdlib.h>
#include <sys/stat.h>

int shux_path_is_nonempty_regular_file_impl(const char *path) {
  struct stat st;
  if (!path || !path[0])
    return 0;
  if (stat(path, &st) != 0 || !S_ISREG(st.st_mode))
    return 0;
  if (st.st_size <= 0)
    return 0;
  return 1;
}

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
  if (!path || !path[0] || !resolved || realpath(path, resolved) == NULL)
    return NULL;
  return asm_link_obj_skip_missing(resolved);
}
