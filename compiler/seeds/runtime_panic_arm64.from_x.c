/* seeds/runtime_panic_arm64.from_x.c — G-02f-22 product TU
 * G-02f-107 helper gates.
 * Logic still C until full .x port.
 *
 * wave251 G.7: user-product face strategy for STD_AND_PANIC bag —
 * CRASH_EVIDENCE env via public pure thin link_abi_getenv (wave222 → _impl
 * host getenv); not raw libc getenv. This TU is user-linkable (runtime_panic.o
 * on product -o lines), NOT part of the g05 xlang/xlang_asm host link.
 * Product host authority remains labi_diag_pure.x + mega link_abi_getenv_impl.
 * User-domain cold twin of the same face ABI (≡ wave222 pure thin + host getenv).
 * Never dual-def with product host g05. PLATFORM: MACOS|ARM64 primary product
 * panic TU on Darwin; SHARED face contract with runtime_panic.from_x.c.
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

/* wave251: user-domain cold twin of product link_abi_getenv face (≡ pure thin + _impl).
 * PLATFORM: SHARED — user/STD_AND_PANIC only; never dual-def with g05 labi. */

/**
 * Cap residual host getenv for user-linked runtime_panic.o (≡ product _impl).
 * @param name NUL-terminated environment key; may be null
 * @return value pointer from process env block, or NULL
 */
const char *link_abi_getenv_impl(const char *name) {
  if (!name || !name[0])
    return NULL;
  return getenv(name);
}

/**
 * Public face twin: null/empty gate then host residual (≡ product pure thin).
 * @param name NUL-terminated environment key
 * @return NULL on null/empty; else link_abi_getenv_impl value
 */
const char *link_abi_getenv(const char *name) {
  if (!name || !name[0])
    return NULL;
  return link_abi_getenv_impl(name);
}

/** 无 backtrace.o 时的最小证据包（XLANG_CRASH_EVIDENCE=1）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-22 thin+rest：_impl 实现；thin（src/asm/runtime_panic_arm64.x）提供 public wrapper */
/* wave251 G.7: env via public face link_abi_getenv (not raw libc getenv). */
void xlang_crash_evidence_minimal_impl(int has_msg, int msg_val) {
  const char *en = link_abi_getenv("XLANG_CRASH_EVIDENCE");
  if (!en || en[0] != '1') {
    return;
  }
  int pid = (int)getpid();
  fprintf(stderr, "note: crash evidence: panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val,
          pid);
  const char *dir = link_abi_getenv("XLANG_CRASH_EVIDENCE_DIR");
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
