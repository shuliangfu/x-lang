/* seeds/runtime_std_runtime_fast.from_x.c — G-02f-21 product TU
 * Logic still C until full .x port.
 */
#include <stdint.h>

extern void shux_panic_(int has_msg, int msg_val);
extern void shux_crash_evidence_collect_c(int has_msg, int msg_val);

void std_runtime_crash_evidence_collect(int32_t has_msg, int32_t msg_val) {
    shux_crash_evidence_collect_c((int)has_msg, (int)msg_val);
}

void runtime_crash_evidence_collect_c(int32_t has_msg, int32_t msg_val) {
    std_runtime_crash_evidence_collect(has_msg, msg_val);
}

void std_runtime_runtime_panic(void) { shux_panic_(0, 0); }

void runtime_panic(void) { shux_panic_(0, 0); }

void std_runtime_runtime_abort(void) { shux_panic_(0, 0); }

void runtime_abort(void) { shux_panic_(0, 0); }
