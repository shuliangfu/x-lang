/**
 * tests/std-log/rotate_async_smoke_ok.c — STD-106 C 轮转+异步烟测入口
 */
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

extern int32_t log_rotate_async_smoke_c(const char *path);

int main(void) {
  char path[256];
  snprintf(path, sizeof(path), "/tmp/shux_std_log_rotate_%d.txt", (int)getpid());
  return log_rotate_async_smoke_c(path);
}
