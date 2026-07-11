/* seeds/rt_util.from_x.c — G-02f-262 P2 R0 util 切片
 * Logic source: src/runtime/rt_util.x
 * Hybrid: SHUX_RT_UTIL_FROM_X + ld -r into runtime_driver_no_c.o
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>

/** 编译/链接失败时删除 -o 目标，避免遗留半写入产物。 */
#ifndef SHUX_RT_UTIL_FROM_X
void driver_unlink_failed_output(const char *out_path) {
  if (!out_path || !out_path[0])
    return;
  (void)unlink(out_path);
}
#else
void driver_unlink_failed_output(const char *out_path);
#endif

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
