/* seeds/rt_util.from_x.c — G-02f-262 P2 R0 util 切片
 * Logic source: src/runtime/rt_util.x
 * Hybrid: XLANG_RT_UTIL_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2（2026-07-14）：driver_unlink_failed_output + driver_argv0_basename_is
 * 均由 .x 提供；FROM_X 下本文件仅前向声明（产品 rest 业务符号 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>

#ifndef XLANG_RT_UTIL_FROM_X
/** 编译/链接失败时删除 -o 目标，避免遗留半写入产物。 */
void driver_unlink_failed_output(const char *out_path) {
  if (!out_path || !out_path[0])
    return;
  (void)unlink(out_path);
}

/** argv0 末段是否等于 base（支持 / 与 Windows \\）。 */
int driver_argv0_basename_is(const char *argv0, const char *base) {
  const char *slash;
  const char *name;
  if (!base)
    return 0;
  slash = strrchr(argv0 ? argv0 : "", '/');
#if defined(_WIN32)
  {
    const char *bs = strrchr(argv0 ? argv0 : "", '\\');
    if (bs && (!slash || bs > slash))
      slash = bs;
  }
#endif
  name = slash ? slash + 1 : (argv0 ? argv0 : "");
  return strcmp(name, base) == 0;
}
#else
void driver_unlink_failed_output(const char *out_path);
int driver_argv0_basename_is(const char *argv0, const char *base);
#endif
