/* Generated from src/asm/runtime_std_runtime_fast.x (G-02f-23 true .x).
 * Regen: ./xlang-c -E -L .. src/asm/runtime_std_runtime_fast.x > seeds/runtime_std_runtime_fast.from_x.c
 * w1099: Darwin arm64 product body is src/asm/runtime_std_runtime_fast.x
 * (pure asm). Linux, Windows, and the pure-asm-fault backup stay this seed.
 * PLATFORM: SHARED seed; MACOS|DARWIN arm64 prefers the .x.
 */
#include <stdint.h>
#include <stddef.h>
/* wave386: pointer-width second arg (int payload or cstr). */
extern void xlang_panic_(int32_t has_msg, intptr_t msg_val);
extern void xlang_crash_evidence_collect_c(int32_t has_msg, int32_t msg_val);

#ifndef XLANG_RUNTIME_STD_RUNTIME_FAST_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RUNTIME_STD_RUNTIME_FAST_FROM_X removed */
#endif /* XLANG_RUNTIME_STD_RUNTIME_FAST_FROM_X */
