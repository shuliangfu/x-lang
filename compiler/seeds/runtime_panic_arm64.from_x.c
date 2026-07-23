/* seeds/runtime_panic_arm64.from_x.c — G-02f-22 product TU
 * G-02f-107 helper gates.
 * Logic still C until full .x port.
 */
/* runtime_panic_arm64.c — ARM64/macOS 用最小 panic 实现。提供 xlang_panic_ 符号供链接。 */
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            macOS/Linux delegate to system <unistd.h> via #include_next.
 *            Historical #ifndef _WIN32 guard removed — shim is a no-op
 *            on POSIX and provides needed declarations on Windows. */
#include <xlang_weak.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

/** 无 backtrace.o 时的最小证据包（XLANG_CRASH_EVIDENCE=1）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-22 thin+rest：_impl 实现；thin（src/asm/runtime_panic_arm64.x）提供 public wrapper */
void xlang_crash_evidence_minimal_impl(int has_msg, int msg_val) {
  const char *en = getenv("XLANG_CRASH_EVIDENCE");
  if (!en || en[0] != '1') {
    return;
  }
  int pid = (int)getpid();
  fprintf(stderr, "note: crash evidence: panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val,
          pid);
  const char *dir = getenv("XLANG_CRASH_EVIDENCE_DIR");
  if (dir && dir[0]) {
    char path[1024];
    (void)snprintf(path, sizeof(path), "%s/xlang-crash-%d.txt", dir, pid);
    FILE *f = fopen(path, "w");
    if (f) {
      fprintf(f, "panic_has_msg=%d\npanic_msg=%d\nframes=0\npid=%d\n", has_msg, msg_val, pid);
      fclose(f);
      fprintf(stderr, "note: crash evidence: bundle=%s\n", path);
    }
  }
}

#ifndef XLANG_RUNTIME_PANIC_ARM64_FROM_X
/* 完整模式（未定义 thin 宏）：public wrapper 由 seed 提供 */
void xlang_crash_evidence_minimal(int has_msg, int msg_val) {
  xlang_crash_evidence_minimal_impl(has_msg, msg_val);
}
#endif




XLANG_WEAK void xlang_crash_evidence_collect_c(int has_msg, int msg_val) {
  xlang_crash_evidence_minimal_impl(has_msg, msg_val);
}

__attribute__((noreturn)) void xlang_panic_(int has_msg, int msg_val) {
  xlang_crash_evidence_collect_c(has_msg, msg_val);
  _exit(1);
}
