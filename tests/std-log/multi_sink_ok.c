/**
 * tests/std-log/multi_sink_ok.c — STD-053 C 多 sink 烟测入口
 */
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

extern int32_t log_multi_sink_smoke_c(const char *path);

int main(void) {
  char path[256];
  snprintf(path, sizeof(path), "/tmp/shu_std_log_sink_%d.txt", (int)getpid());
  return log_multi_sink_smoke_c(path);
}
