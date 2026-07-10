/* runtime_panic_arm64.c — ARM64/macOS 用最小 panic 实现。提供 shux_panic_ 符号供链接。 */
#ifndef _WIN32
#include <unistd.h>
#endif
#include <stdlib.h>
#include <stdio.h>

/** 无 backtrace.o 时的最小证据包（SHUX_CRASH_EVIDENCE=1）。 */
static void shux_crash_evidence_minimal(int has_msg, int msg_val) {
  const char *en = getenv("SHUX_CRASH_EVIDENCE");
  if (!en || en[0] != '1') {
    return;
  }
  int pid = (int)getpid();
  fprintf(stderr, "note: crash evidence: panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val,
          pid);
  const char *dir = getenv("SHUX_CRASH_EVIDENCE_DIR");
  if (dir && dir[0]) {
    char path[1024];
    (void)snprintf(path, sizeof(path), "%s/shux-crash-%d.txt", dir, pid);
    FILE *f = fopen(path, "w");
    if (f) {
      fprintf(f, "panic_has_msg=%d\npanic_msg=%d\nframes=0\npid=%d\n", has_msg, msg_val, pid);
      fclose(f);
      fprintf(stderr, "note: crash evidence: bundle=%s\n", path);
    }
  }
}

__attribute__((weak)) void shux_crash_evidence_collect_c(int has_msg, int msg_val) {
  shux_crash_evidence_minimal(has_msg, msg_val);
}

__attribute__((noreturn)) void shux_panic_(int has_msg, int msg_val) {
  shux_crash_evidence_collect_c(has_msg, msg_val);
  _exit(1);
}
