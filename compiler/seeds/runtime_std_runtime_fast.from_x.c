/* Generated from src/asm/runtime_std_runtime_fast.x (G-02f-23 true .x).
 * Regen: ./xlang-c -E -L .. src/asm/runtime_std_runtime_fast.x > seeds/runtime_std_runtime_fast.from_x.c
 */
#include <stdint.h>
#include <stddef.h>
extern void xlang_panic_(int32_t has_msg, int32_t msg_val);
extern void xlang_crash_evidence_collect_c(int32_t has_msg, int32_t msg_val);

#ifndef XLANG_RUNTIME_STD_RUNTIME_FAST_FROM_X
/* G-02f-20 thin+rest：完整模式下函数由 seed 提供；rest 模式下由 .x thin 提供 */
void std_runtime_crash_evidence_collect(int32_t has_msg, int32_t msg_val) {
  (void)(({   {
    (void)(xlang_crash_evidence_collect_c(has_msg, msg_val));
  }
 }));
}
void runtime_crash_evidence_collect_c(int32_t has_msg, int32_t msg_val) {
  (void)(std_runtime_crash_evidence_collect(has_msg, msg_val));
}
void std_runtime_runtime_panic(void) {
  (void)(({   {
    (void)(xlang_panic_(0, 0));
  }
 }));
}
void runtime_panic(void) {
  (void)(({   {
    (void)(xlang_panic_(0, 0));
  }
 }));
}
void std_runtime_runtime_abort(void) {
  (void)(({   {
    (void)(xlang_panic_(0, 0));
  }
 }));
}
void runtime_abort(void) {
  (void)(({   {
    (void)(xlang_panic_(0, 0));
  }
 }));
}
#endif /* XLANG_RUNTIME_STD_RUNTIME_FAST_FROM_X */
