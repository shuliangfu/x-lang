/* runtime_panic.c — ARM64/macOS 用最小 panic 实现。提供 shulang_panic_ 符号供链接。 */
#include <unistd.h>
#include <stdlib.h>

__attribute__((weak)) void shulang_crash_evidence_collect_c(int has_msg, int msg_val) {
  (void)has_msg;
  (void)msg_val;
}

__attribute__((noreturn)) void shulang_panic_(int has_msg, int msg_val) {
  shulang_crash_evidence_collect_c(has_msg, msg_val);
  _exit(1);
}
