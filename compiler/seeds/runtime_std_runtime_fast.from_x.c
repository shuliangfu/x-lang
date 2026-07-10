/* Generated from src/asm/runtime_std_runtime_fast.x (G-02f-23 true .x).
 * Regen: ./shux-c -E -L .. src/asm/runtime_std_runtime_fast.x > seeds/runtime_std_runtime_fast.from_x.c
 */
#include <stdint.h>
#include <stddef.h>
extern void shux_panic_(int32_t has_msg, int32_t msg_val);
extern void shux_crash_evidence_collect_c(int32_t has_msg, int32_t msg_val);
void std_runtime_crash_evidence_collect(int32_t has_msg, int32_t msg_val) {
  (void)(({   {
    (void)(shux_crash_evidence_collect_c(has_msg, msg_val));
  }
 }));
}
void runtime_crash_evidence_collect_c(int32_t has_msg, int32_t msg_val) {
  (void)(std_runtime_crash_evidence_collect(has_msg, msg_val));
}
void std_runtime_runtime_panic(void) {
  (void)(({   {
    (void)(shux_panic_(0, 0));
  }
 }));
}
void runtime_panic(void) {
  (void)(({   {
    (void)(shux_panic_(0, 0));
  }
 }));
}
void std_runtime_runtime_abort(void) {
  (void)(({   {
    (void)(shux_panic_(0, 0));
  }
 }));
}
void runtime_abort(void) {
  (void)(({   {
    (void)(shux_panic_(0, 0));
  }
 }));
}
