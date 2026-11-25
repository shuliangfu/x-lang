/*
 * Host-gcc first-wins twin of driver_asm_mkstemp_fdopen.
 *
 * DIG s197 soft (Windows): want-exe mkstemp fills g_driver_asm_tmp_path_slot,
 * coff_write succeeds, but by invoke_ld the same BSS slot is empty → ld argv
 * user .o is "" → U WinMain (no T main on the link line).
 *
 * Keep a durable copy of the mkstemp path that work_reset / BSS smash must not
 * share with the mutable template slot. invoke_ld (win_ld) prefers the kept
 * path when o_path is empty.
 *
 * PLATFORM: WINDOWS DIG host-cc first-wins; SHARED mkstemp contract.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

#if defined(_WIN32) || defined(_WIN64)
#include <io.h>
/* MinGW provides mkstemp; declare if headers omit it under dig ccflags. */
int mkstemp(char *tmpl);
#define dig_close _close
#else
#include <unistd.h>
int mkstemp(char *tmpl);
#define dig_close close
#endif

extern const char *xlang_driver_tmp_prefix(void);
extern void *xlang_driver_fdopen_wb_opaque(int fd);

static char g_driver_asm_tmp_path_kept[128];

/**
 * Durable mkstemp path for want-exe ld (survives slot clear).
 * @return pointer to kept NUL-terminated path; may be empty if mkstemp never ran
 */
char *driver_asm_tmp_path_kept(void) {
  return g_driver_asm_tmp_path_kept;
}

/**
 * Fill path_out64 via mkstemp and fdopen "wb"; also copy path into kept[].
 * @param path_out64 caller template buffer (capacity >= 64)
 * @return opaque FILE pointer or handle, or NULL on failure
 */
void *driver_asm_mkstemp_fdopen(unsigned char *path_out64) {
  const char *prefix;
  int fd;
  void *fp;
  size_t n;
  if (!path_out64) {
    return 0;
  }
  g_driver_asm_tmp_path_kept[0] = '\0';
  prefix = xlang_driver_tmp_prefix();
  if (!prefix) {
    prefix = "";
  }
  /* Match thin.x: prefix + "xlang_asm_XXXXXX" into 64-byte caller slot. */
  snprintf((char *)path_out64, 64, "%sxlang_asm_XXXXXX", prefix);
  fd = mkstemp((char *)path_out64);
  if (fd < 0) {
    return 0;
  }
  n = strlen((char *)path_out64);
  if (n >= sizeof(g_driver_asm_tmp_path_kept)) {
    n = sizeof(g_driver_asm_tmp_path_kept) - 1;
  }
  memcpy(g_driver_asm_tmp_path_kept, path_out64, n);
  g_driver_asm_tmp_path_kept[n] = '\0';
  fp = xlang_driver_fdopen_wb_opaque(fd);
  if (!fp) {
    /* Fallback: libc fdopen "wb" (opaque FILE*). */
    fp = (void *)fdopen(fd, "wb");
  }
  if (!fp) {
    dig_close(fd);
    unlink((char *)path_out64);
    path_out64[0] = 0;
    g_driver_asm_tmp_path_kept[0] = '\0';
    return 0;
  }
  {
    FILE *log = fopen("C:/xlang_tmp/dig_l2_rc1_verify_2026-11-11/_mkstemp_kept.txt", "w");
    if (log) {
      fprintf(log, "path=[%s]\nkept=[%s]\n", (char *)path_out64, g_driver_asm_tmp_path_kept);
      fclose(log);
    }
  }
  return fp;
}
