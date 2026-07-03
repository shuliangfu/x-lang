/* runtime_panic.c — 提供 shux_panic_，链 libc 时调用 abort；供 -backend asm 链接用（Linux 可用 .s 不链 libc）。
 * Freestanding / 弱化 libc 路线见 compiler/docs/SELFHOST.md §6 与 src/asm/runtime_panic_x86_64.s（若存在）。
 * SAFE-007：弱符号证据收集，强符号由 runtime_backtrace_platform.o 提供。 */
#include <stdlib.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#endif

/** Linux ld：标记非可执行栈，消除 missing .note.GNU-stack 链接警告（macOS 勿用 %progbits 语法）。 */
#if defined(__GNUC__) && defined(__linux__)
__asm__(".section .note.GNU-stack,\"\",%progbits");
#endif

/** 无 backtrace 平台 runtime 时的最小证据包（SHUX_CRASH_EVIDENCE=1）；强符号链接 runtime_backtrace_platform.o 时覆盖。 */
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

/**
 * 弱默认：无 runtime_backtrace_platform.o 时输出最小证据；有平台 runtime 时强符号覆盖。
 * PE/COFF（Windows/Cygwin）弱符号不可靠，须强符号默认实现以满足 std/runtime/runtime.o 链接。
 */
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
void shux_crash_evidence_collect_c(int has_msg, int msg_val) {
  shux_crash_evidence_minimal(has_msg, msg_val);
}
#else
__attribute__((weak)) void shux_crash_evidence_collect_c(int has_msg, int msg_val) {
  shux_crash_evidence_minimal(has_msg, msg_val);
}
#endif

__attribute__((weak)) int io_register_buffers_buf_c(const void *bufs, int nr) {
  (void)bufs;
  (void)nr;
  return -1;
}

void shux_panic_(int has_msg, int msg_val) {
  shux_crash_evidence_collect_c(has_msg, msg_val);
  abort();
}
