/*
 * Host-gcc twin of xlang_resolve_compiler_dir.
 *
 * DIG note (s191): ensure_* binds to the Cap residual definition inside
 * runtime_link_abi.o (same-TU / same-.o call), NOT this first-wins twin.
 * Authority fix lives in seeds/runtime_link_abi.from_x.c (Windows branch).
 * This twin mirrors the same prefer-relative-compiler contract for experiments
 * that exclude the seed .o from the link line.
 *
 * PLATFORM: WINDOWS DIG host-cc optional; SHARED resolve contract.
 */
#include <stdint.h>
#include <string.h>
#include <unistd.h>

#if defined(_WIN32) || defined(_WIN64)
extern char *_pgmptr;
#endif

static int resolve_readable(const char *path) {
  return path && path[0] && access(path, R_OK) == 0;
}

static int resolve_dir_has_compiler_marker(const char *dir) {
  char probe[4096];
  size_t n;
  size_t m;
  int i;
  static const char *marks[] = {
      "/seeds/runtime_panic.from_x.c",
      "/runtime_panic.o",
      "\\seeds\\runtime_panic.from_x.c",
      "\\runtime_panic.o",
      0};
  if (!dir || !dir[0]) {
    return 0;
  }
  n = strlen(dir);
  for (i = 0; marks[i] != 0; i++) {
    m = strlen(marks[i]);
    if (n + m + 1 >= sizeof(probe)) {
      continue;
    }
    memcpy(probe, dir, n);
    memcpy(probe + n, marks[i], m + 1);
    if (resolve_readable(probe)) {
      return 1;
    }
  }
  return 0;
}

static int resolve_copy_out(char *out_dir, size_t out_dir_sz, const char *src) {
  size_t n;
  if (!out_dir || out_dir_sz < 2 || !src) {
    return -1;
  }
  n = strlen(src);
  if (n >= out_dir_sz) {
    return -1;
  }
  memcpy(out_dir, src, n + 1);
  return 0;
}

static int resolve_strip_last_sep(char *buf) {
  char *slash = 0;
  char *p;
  if (!buf || !buf[0]) {
    return -1;
  }
  for (p = buf; *p; p++) {
    if (*p == '/' || *p == '\\') {
      slash = p;
    }
  }
  if (!slash) {
    return -1;
  }
  *slash = '\0';
  return 0;
}

int xlang_resolve_compiler_dir(const char *argv0, char *out_dir, size_t out_dir_sz) {
  char buf[4096];
  char cwd[4096];
  char cand[4096];
  size_t n;
  if (!out_dir || out_dir_sz < 2) {
    return -1;
  }

  /* 1) cwd-relative compiler/ — DIG aside soft verify uses cwd = repo root. */
  if (resolve_readable("compiler/runtime_panic.o") ||
      resolve_readable("compiler/seeds/runtime_panic.from_x.c")) {
    return resolve_copy_out(out_dir, out_dir_sz, "compiler");
  }

  /* 2) absolute cwd/compiler and cwd. */
  if (getcwd(cwd, sizeof(cwd) - 16) != 0) {
    n = strlen(cwd);
    if (n + 10 < sizeof(cand)) {
      memcpy(cand, cwd, n);
      memcpy(cand + n, "/compiler", 10);
      if (resolve_dir_has_compiler_marker(cand)) {
        return resolve_copy_out(out_dir, out_dir_sz, cand);
      }
    }
    if (resolve_dir_has_compiler_marker(cwd)) {
      return resolve_copy_out(out_dir, out_dir_sz, cwd);
    }
  }

  /* 3) exe-dir when it itself is a compiler tree. */
#if defined(_WIN32) || defined(_WIN64)
  {
    const char *exe_path = _pgmptr;
    if (exe_path && exe_path[0]) {
      n = strlen(exe_path);
      if (n >= sizeof(buf)) {
        n = sizeof(buf) - 1;
      }
      memcpy(buf, exe_path, n);
      buf[n] = '\0';
      if (resolve_strip_last_sep(buf) == 0 && resolve_dir_has_compiler_marker(buf)) {
        return resolve_copy_out(out_dir, out_dir_sz, buf);
      }
    }
  }
#endif
  if (argv0 && argv0[0]) {
    n = strlen(argv0);
    if (n >= sizeof(buf)) {
      n = sizeof(buf) - 1;
    }
    memcpy(buf, argv0, n);
    buf[n] = '\0';
    if (resolve_strip_last_sep(buf) == 0 && resolve_dir_has_compiler_marker(buf)) {
      return resolve_copy_out(out_dir, out_dir_sz, buf);
    }
  }

  /* 4) Historical: dirname(exe) even without marker (tip-in-compiler). */
#if defined(_WIN32) || defined(_WIN64)
  {
    const char *exe_path = _pgmptr;
    if (exe_path && exe_path[0]) {
      n = strlen(exe_path);
      if (n >= sizeof(buf)) {
        n = sizeof(buf) - 1;
      }
      memcpy(buf, exe_path, n);
      buf[n] = '\0';
      if (resolve_strip_last_sep(buf) == 0) {
        return resolve_copy_out(out_dir, out_dir_sz, buf);
      }
    }
  }
#endif
  if (argv0 && argv0[0]) {
    n = strlen(argv0);
    if (n >= sizeof(buf)) {
      n = sizeof(buf) - 1;
    }
    memcpy(buf, argv0, n);
    buf[n] = '\0';
    if (resolve_strip_last_sep(buf) == 0) {
      return resolve_copy_out(out_dir, out_dir_sz, buf);
    }
  }
  return -1;
}
