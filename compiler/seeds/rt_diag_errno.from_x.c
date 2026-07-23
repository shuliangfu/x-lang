/* seeds/rt_diag_errno.from_x.c — G-02f-302 P2 runtime rest (diag errno pure)
 * Logic source: src/runtime/rt_diag_errno.x
 * Hybrid: XLANG_RT_DIAG_ERRNO_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full：code_for_kind + errno{,_path,_path_pair} + cli_usage_note 由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 */
#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "runtime_diag_codes.h"

extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);

#ifndef XLANG_RT_DIAG_ERRNO_FROM_X

const char *runtime_diag_code_for_kind(const char *kind) {
  if (!kind)
    return XLANG_DIAG_CODE_BUILD_BLD001;
  if (strcmp(kind, "io error") == 0)
    return XLANG_DIAG_CODE_IO_IO001;
  if (strcmp(kind, "process error") == 0)
    return XLANG_DIAG_CODE_PROCESS_PRC001;
  if (strcmp(kind, "build error") == 0)
    return XLANG_DIAG_CODE_BUILD_BLD001;
  return NULL;
}

void runtime_diag_errno(const char *file, const char *kind, const char *op) {
  int saved_errno = errno;
  const char *err = strerror(saved_errno);
  const char *resolved_kind = kind ? kind : "build error";
  const char *code = runtime_diag_code_for_kind(resolved_kind);
  if (code) {
    diag_reportf_with_code(file, 0, 0, resolved_kind, code, NULL, "%s failed: %s", op ? op : "system call",
                           err ? err : "unknown error");
  } else {
    diag_reportf(file, 0, 0, resolved_kind, NULL, "%s failed: %s", op ? op : "system call",
                 err ? err : "unknown error");
  }
}

void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path) {
  int saved_errno = errno;
  const char *err = strerror(saved_errno);
  const char *resolved_kind = kind ? kind : "build error";
  const char *code = runtime_diag_code_for_kind(resolved_kind);
  if (path && path[0] != '\0') {
    if (code) {
      diag_reportf_with_code(file, 0, 0, resolved_kind, code, NULL, "%s failed for '%s': %s",
                             op ? op : "system call", path, err ? err : "unknown error");
    } else {
      diag_reportf(file, 0, 0, resolved_kind, NULL, "%s failed for '%s': %s", op ? op : "system call", path,
                   err ? err : "unknown error");
    }
    return;
  }
  runtime_diag_errno(file, resolved_kind, op);
}

void runtime_diag_errno_path_pair(const char *file, const char *kind, const char *op, const char *from_path,
                                  const char *to_path) {
  int saved_errno = errno;
  const char *err = strerror(saved_errno);
  const char *resolved_kind = kind ? kind : "build error";
  const char *code = runtime_diag_code_for_kind(resolved_kind);
  if (code) {
    diag_reportf_with_code(file, 0, 0, resolved_kind, code, NULL, "%s failed for '%s' -> '%s': %s",
                           op ? op : "system call", from_path ? from_path : "?", to_path ? to_path : "?",
                           err ? err : "unknown error");
  } else {
    diag_reportf(file, 0, 0, resolved_kind, NULL, "%s failed for '%s' -> '%s': %s", op ? op : "system call",
                 from_path ? from_path : "?", to_path ? to_path : "?", err ? err : "unknown error");
  }
}

#if defined(__GNUC__) || defined(__clang__)
__attribute__((unused))
#endif
void runtime_diag_cli_usage_note(const char *argv0) {
  diag_reportf(NULL, 0, 0, "note", NULL,
               "usage: %s [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] [ -O 0|1|2|3|s ] [ -flto ] <file.x> [ -o <out> ]",
               argv0 ? argv0 : "xlang");
}

#else
const char *runtime_diag_code_for_kind(const char *kind);
void runtime_diag_errno(const char *file, const char *kind, const char *op);
void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
void runtime_diag_errno_path_pair(const char *file, const char *kind, const char *op, const char *from_path,
                                  const char *to_path);
void runtime_diag_cli_usage_note(const char *argv0);
#endif

int labi_rt_diag_errno_slice_marker(void) {
  return 1;
}
