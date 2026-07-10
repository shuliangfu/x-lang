/* seeds/rt_fmt_one.from_x.c — G-02f-311 P2 runtime rest (fmt one file)
 * Logic source: src/runtime/rt_fmt_one.x
 * Hybrid: SHUX_RT_FMT_ONE_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: driver_fmt_one_file（读 .x → shu_format_x_document → 可选写回）。
 * 🔒 read/write/format 经 IO/LSP seeds。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "runtime_diag_codes.h"
#include "runtime_io_abi.h"

extern int shu_format_x_document(const uint8_t *doc, int doc_len, uint8_t *out_buf, int out_cap);
extern int32_t driver_fmt_check_only_get(void);
extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);

/**
 * shux fmt 单文件：读入 .x、按 LSP 规则格式化；内容变化时写回。
 * path 为字节路径（path_len 不含 NUL）；成功 0，失败 1。
 */
int driver_fmt_one_file(const uint8_t *path, int path_len) {
  char pathbuf[512];
  ShuxRuntimeFileView raw_view;
  size_t cap;
  uint8_t *out;
  int fmt_len;
  if (!path || path_len <= 0 || path_len >= (int)sizeof pathbuf)
    return 1;
  memcpy(pathbuf, path, (size_t)path_len);
  pathbuf[path_len] = '\0';
  if (path_len < 2 || strcmp(pathbuf + path_len - 2, ".x") != 0)
    return 1;
  if (runtime_read_file_view(pathbuf, &raw_view) != 0) {
    diag_reportf_with_code(pathbuf, 0, 0, "fmt error", SHUX_DIAG_CODE_FMT_FMT001, NULL, "cannot read '%s'", pathbuf);
    return 1;
  }
  cap = raw_view.length * 2 + 4096;
  if (cap < 65536)
    cap = 65536;
  out = (uint8_t *)malloc(cap);
  if (!out) {
    runtime_release_file_view(&raw_view);
    diag_reportf_with_code(pathbuf, 0, 0, "fmt error", SHUX_DIAG_CODE_FMT_FMT001, NULL,
                           "out of memory while formatting '%s'", pathbuf);
    return 1;
  }
  fmt_len = shu_format_x_document((const uint8_t *)raw_view.data, (int)raw_view.length, out, (int)cap);
  if (fmt_len < 0) {
    free(out);
    runtime_release_file_view(&raw_view);
    diag_reportf_with_code(pathbuf, 0, 0, "fmt error", SHUX_DIAG_CODE_FMT_FMT001, NULL, "format failed for '%s'",
                           pathbuf);
    return 1;
  }
  {
    int changed = ((size_t)fmt_len != raw_view.length || memcmp(raw_view.data, out, raw_view.length) != 0);
    if (driver_fmt_check_only_get()) {
      free(out);
      runtime_release_file_view(&raw_view);
      /* --check 成功时静默（与 deno fmt --check 一致）；失败由 driver_run_fmt 汇总列表。 */
      return changed ? 1 : 0;
    }
    if (changed) {
      if (shux_write_path_bytes(pathbuf, out, (size_t)fmt_len) != 0) {
        free(out);
        runtime_release_file_view(&raw_view);
        diag_reportf_with_code(pathbuf, 0, 0, "fmt error", SHUX_DIAG_CODE_FMT_FMT001, NULL, "write failed for '%s'",
                               pathbuf);
        return 1;
      }
      /* 与 deno fmt 一致：仅在实际写回时输出路径，已规范文件保持静默。 */
      diag_reportf(NULL, 0, 0, "info", NULL, "fmt OK: %s", pathbuf);
    }
  }
  free(out);
  runtime_release_file_view(&raw_view);
  return 0;
}

int labi_rt_fmt_one_slice_marker(void) {
  return 1;
}
