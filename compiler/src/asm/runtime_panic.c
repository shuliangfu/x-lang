/* runtime_panic.c — 提供 shulang_panic_，链 libc 时调用 abort；供 -backend asm 链接用（Linux 可用 .s 不链 libc）。
 * Freestanding / 弱化 libc 路线见 compiler/docs/SELFHOST.md §6 与 src/asm/runtime_panic_x86_64.s（若存在）。
 * SAFE-007：弱符号证据收集，强符号由 std/backtrace/backtrace.o 提供。 */
#include <stdlib.h>

/** Linux ld：标记非可执行栈，消除 missing .note.GNU-stack 链接警告（macOS 勿用 %progbits 语法）。 */
#if defined(__GNUC__) && defined(__linux__)
__asm__(".section .note.GNU-stack,\"\",%progbits");
#endif

/** 弱默认：无 backtrace.o 时不收集证据。 */
__attribute__((weak)) void shulang_crash_evidence_collect_c(int has_msg, int msg_val) {
  (void)has_msg;
  (void)msg_val;
}

void shulang_panic_(int has_msg, int msg_val) {
  shulang_crash_evidence_collect_c(has_msg, msg_val);
  abort();
}
