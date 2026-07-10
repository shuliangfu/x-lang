/* seeds/labi_path_pure.from_x.c — G-02f-267 P2 link_abi L0 path pure
 * Logic source: src/runtime/labi_path_pure.x
 * Hybrid: SHUX_LABI_PATH_PURE_FROM_X + ld -r into runtime_link_abi.o
 */
#include <stddef.h>
#include <string.h>

char *shux_path_last_sep(const char *s) {
  char *p = s ? strrchr(s, '/') : NULL;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
  if (s) {
    char *bs = strrchr(s, '\\');
    if (bs && (!p || bs > p))
      p = bs;
  }
#endif
  return p;
}

int shux_path_has_sep(const char *s) {
  if (!s)
    return 0;
  if (strchr(s, '/'))
    return 1;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
  if (strchr(s, '\\'))
    return 1;
#endif
  return 0;
}

int link_abi_ld_argv_entry_is_obj(const char *s) {
  size_t n;
  if (s == NULL)
    return 0;
  if (s[0] == 0)
    return 0;
  n = 0;
  while (s[n] != 0)
    n = n + 1;
  if (n >= 2) {
    if (s[n - 2] == '.') {
      if (s[n - 1] == 'o')
        return 1;
    }
  }
  if (n >= 4) {
    if (s[n - 4] == '.') {
      if (s[n - 3] == 'o') {
        if (s[n - 2] == 'b') {
          if (s[n - 1] == 'j')
            return 1;
        }
      }
    }
  }
  return 0;
}

int shux_output_is_elf_o(const char *path) {
  size_t n;
  if (path == NULL)
    return 0;
  n = 0;
  while (path[n] != 0)
    n = n + 1;
  if (n >= 2) {
    if (path[n - 2] == '.') {
      if (path[n - 1] == 'o')
        return 1;
      if (path[n - 1] == 'O')
        return 1;
    }
  }
  if (n >= 4) {
    if (path[n - 4] == '.') {
      if (path[n - 3] == 'o') {
        if (path[n - 2] == 'b') {
          if (path[n - 1] == 'j')
            return 1;
        }
      }
    }
  }
  return 0;
}
