/**
 * leak_probe.c — SAFE-005 探测器：故意泄漏 64B，仅 SHUX_LEAK_PROBE=1 时运行以校验 ASAN。
 */
#include <stdlib.h>

int main(void) {
  (void)malloc(64);
  return 0;
}
