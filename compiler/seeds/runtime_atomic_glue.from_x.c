/* seeds/runtime_atomic_glue.from_x.c — G-02f-19 product TU
 * G-02f-103 helper gates.
 * Product: runtime_atomic_glue.o; logic still C until full .x port.
 *
 * wave508 G-7: R2 full mode — thin (.x) provides all public #[no_mangle] APIs;
 * rest (this file) provides OS bridge _impl implementations.
 * PLATFORM: SHARED — atomic operations use compiler builtins (__atomic_*)
 * or C11 <stdatomic.h>; inline fallback for non-atomic platforms.
 */

#include <stdint.h>

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L && !defined(__STDC_NO_ATOMICS__)
#include <stdatomic.h>
#define USE_C11_ATOMICS 1
#else
#define USE_C11_ATOMICS 0
#endif

#if defined(__GNUC__) || defined(__clang__)
#define ATOMIC_LOAD32(p)   __atomic_load_n((p), __ATOMIC_SEQ_CST)
#define ATOMIC_STORE32(p,v) __atomic_store_n((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_LOAD64(p)   __atomic_load_n((p), __ATOMIC_SEQ_CST)
#define ATOMIC_STORE64(p,v) __atomic_store_n((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_CAS32(p,e,d) __atomic_compare_exchange_n((p), (e), (d), 0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)
#define ATOMIC_FADD32(p,v)  __atomic_fetch_add((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_FSUB32(p,v)  __atomic_fetch_sub((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_FAND32(p,v)  __atomic_fetch_and((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_FOR32(p,v)   __atomic_fetch_or((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_FXOR32(p,v)  __atomic_fetch_xor((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_FADD64(p,v)  __atomic_fetch_add((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_FSUB64(p,v)  __atomic_fetch_sub((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_LOAD16(p)    __atomic_load_n((p), __ATOMIC_SEQ_CST)
#define ATOMIC_STORE16(p,v) __atomic_store_n((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_CAS16(p,e,d) __atomic_compare_exchange_n((p), (e), (d), 0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)
#define ATOMIC_FADD16(p,v)  __atomic_fetch_add((p), (v), __ATOMIC_SEQ_CST)
#define ATOMIC_CAS64(p,e,d) __atomic_compare_exchange_n((p), (e), (d), 0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)
#endif

/* Forward declarations of thin public API functions (provided by .x in R2 mode).
 * Needed by smoke tests and any function that calls back into public API. */
int32_t atomic_load_i32_c(int32_t *ptr);
void atomic_store_i32_c(int32_t *ptr, int32_t val);
int32_t atomic_compare_exchange_i32_c(int32_t *ptr, int32_t *expected, int32_t desired);
int32_t atomic_fetch_add_i32_c(int32_t *ptr, int32_t delta);
int32_t atomic_fetch_sub_i32_c(int32_t *ptr, int32_t delta);
uint32_t atomic_load_u32_c(uint32_t *ptr);
void atomic_store_u32_c(uint32_t *ptr, uint32_t val);
int32_t atomic_compare_exchange_u32_c(uint32_t *ptr, uint32_t *expected, uint32_t desired);
uint32_t atomic_fetch_add_u32_c(uint32_t *ptr, uint32_t delta);
int64_t atomic_load_i64_c(int64_t *ptr);
void atomic_store_i64_c(int64_t *ptr, int64_t val);
int64_t atomic_fetch_add_i64_c(int64_t *ptr, int64_t delta);
int64_t atomic_fetch_sub_i64_c(int64_t *ptr, int64_t delta);
int32_t atomic_compare_exchange_i64_c(int64_t *ptr, int64_t *expected, int64_t desired);
uint64_t atomic_load_u64_c(uint64_t *ptr);
void atomic_store_u64_c(uint64_t *ptr, uint64_t val);
uint64_t atomic_fetch_add_u64_c(uint64_t *ptr, uint64_t delta);
uint64_t atomic_fetch_sub_u64_c(uint64_t *ptr, uint64_t delta);
int32_t atomic_compare_exchange_u64_c(uint64_t *ptr, uint64_t *expected, uint64_t desired);
void atomic_fence_seq_cst_c(void);
void atomic_fence_acquire_c(void);
void atomic_fence_release_c(void);
int16_t atomic_load_i16_c(int16_t *ptr);
void atomic_store_i16_c(int16_t *ptr, int16_t val);
int16_t atomic_fetch_add_i16_c(int16_t *ptr, int16_t delta);
int32_t atomic_compare_exchange_i16_c(int16_t *ptr, int16_t *expected, int16_t desired);
uint16_t atomic_load_u16_c(uint16_t *ptr);
void atomic_store_u16_c(uint16_t *ptr, uint16_t val);
uint16_t atomic_fetch_add_u16_c(uint16_t *ptr, uint16_t delta);
int32_t atomic_compare_exchange_u16_c(uint16_t *ptr, uint16_t *expected, uint16_t desired);

/* ---------- i32 ---------- */
int32_t atomic_load_i32_impl(int32_t *ptr) {
#if defined(ATOMIC_LOAD32)
  return (int32_t)ATOMIC_LOAD32(ptr);
#elif USE_C11_ATOMICS
  return atomic_load_explicit((_Atomic int32_t *)ptr, memory_order_seq_cst);
#else
  return *ptr;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int32_t atomic_load_i32_c(int32_t *ptr) {
  return atomic_load_i32_impl(ptr);
}
#endif

void atomic_store_i32_impl(int32_t *ptr, int32_t val) {
#if defined(ATOMIC_STORE32)
  ATOMIC_STORE32(ptr, val);
#elif USE_C11_ATOMICS
  atomic_store_explicit((_Atomic int32_t *)ptr, val, memory_order_seq_cst);
#else
  *ptr = val;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
void atomic_store_i32_c(int32_t *ptr, int32_t val) {
  atomic_store_i32_impl(ptr, val);
}
#endif

int32_t atomic_compare_exchange_i32_impl(int32_t *ptr, int32_t *expected, int32_t desired) {
#if defined(ATOMIC_CAS32)
  int32_t e = *expected;
  if (ATOMIC_CAS32(ptr, &e, desired)) return 1;
  *expected = e;
  return 0;
#elif USE_C11_ATOMICS
  int32_t e = *expected;
  if (atomic_compare_exchange_strong_explicit((_Atomic int32_t *)ptr, &e, desired, memory_order_seq_cst, memory_order_seq_cst)) return 1;
  *expected = e;
  return 0;
#else
  if (*ptr == *expected) { *ptr = desired; return 1; }
  *expected = *ptr;
  return 0;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int32_t atomic_compare_exchange_i32_c(int32_t *ptr, int32_t *expected, int32_t desired) {
  return atomic_compare_exchange_i32_impl(ptr, expected, desired);
}
#endif

int32_t atomic_fetch_add_i32_impl(int32_t *ptr, int32_t delta) {
#if defined(ATOMIC_FADD32)
  return (int32_t)ATOMIC_FADD32(ptr, delta);
#elif USE_C11_ATOMICS
  return atomic_fetch_add_explicit((_Atomic int32_t *)ptr, delta, memory_order_seq_cst);
#else
  int32_t old = *ptr;
  *ptr = old + delta;
  return old;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int32_t atomic_fetch_add_i32_c(int32_t *ptr, int32_t delta) {
  return atomic_fetch_add_i32_impl(ptr, delta);
}
#endif

int32_t atomic_fetch_sub_i32_impl(int32_t *ptr, int32_t delta) {
#if defined(ATOMIC_FSUB32)
  return (int32_t)ATOMIC_FSUB32(ptr, delta);
#else
  return atomic_fetch_add_i32_impl(ptr, -delta);
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int32_t atomic_fetch_sub_i32_c(int32_t *ptr, int32_t delta) {
  return atomic_fetch_sub_i32_impl(ptr, delta);
}
#endif

/* ---------- u32 ---------- */
uint32_t atomic_load_u32_impl(uint32_t *ptr) {
#if defined(ATOMIC_LOAD32)
  return (uint32_t)ATOMIC_LOAD32(ptr);
#else
  return *ptr;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
uint32_t atomic_load_u32_c(uint32_t *ptr) {
  return atomic_load_u32_impl(ptr);
}
#endif

void atomic_store_u32_impl(uint32_t *ptr, uint32_t val) {
#if defined(ATOMIC_STORE32)
  ATOMIC_STORE32(ptr, val);
#else
  *ptr = val;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
void atomic_store_u32_c(uint32_t *ptr, uint32_t val) {
  atomic_store_u32_impl(ptr, val);
}
#endif

int32_t atomic_compare_exchange_u32_impl(uint32_t *ptr, uint32_t *expected, uint32_t desired) {
#if defined(__GNUC__) || defined(__clang__)
  uint32_t e = *expected;
  if (__atomic_compare_exchange_n(ptr, &e, desired, 0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)) return 1;
  *expected = e;
  return 0;
#elif USE_C11_ATOMICS
  uint32_t e = *expected;
  if (atomic_compare_exchange_strong_explicit((_Atomic uint32_t *)ptr, &e, desired, memory_order_seq_cst, memory_order_seq_cst)) return 1;
  *expected = e;
  return 0;
#else
  if (*ptr == *expected) { *ptr = desired; return 1; }
  *expected = *ptr;
  return 0;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int32_t atomic_compare_exchange_u32_c(uint32_t *ptr, uint32_t *expected, uint32_t desired) {
  return atomic_compare_exchange_u32_impl(ptr, expected, desired);
}
#endif

uint32_t atomic_fetch_add_u32_impl(uint32_t *ptr, uint32_t delta) {
#if defined(ATOMIC_FADD32)
  return (uint32_t)ATOMIC_FADD32(ptr, delta);
#else
  uint32_t old = *ptr;
  *ptr = old + delta;
  return old;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
uint32_t atomic_fetch_add_u32_c(uint32_t *ptr, uint32_t delta) {
  return atomic_fetch_add_u32_impl(ptr, delta);
}
#endif

/* ---------- i64 / u64 ---------- */
int64_t atomic_load_i64_impl(int64_t *ptr) {
#if defined(ATOMIC_LOAD64)
  return (int64_t)ATOMIC_LOAD64(ptr);
#else
  return *ptr;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int64_t atomic_load_i64_c(int64_t *ptr) {
  return atomic_load_i64_impl(ptr);
}
#endif

void atomic_store_i64_impl(int64_t *ptr, int64_t val) {
#if defined(ATOMIC_STORE64)
  ATOMIC_STORE64(ptr, val);
#else
  *ptr = val;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
void atomic_store_i64_c(int64_t *ptr, int64_t val) {
  atomic_store_i64_impl(ptr, val);
}
#endif

uint64_t atomic_load_u64_impl(uint64_t *ptr) {
#if defined(ATOMIC_LOAD64)
  return (uint64_t)ATOMIC_LOAD64(ptr);
#else
  return *ptr;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
uint64_t atomic_load_u64_c(uint64_t *ptr) {
  return atomic_load_u64_impl(ptr);
}
#endif

void atomic_store_u64_impl(uint64_t *ptr, uint64_t val) {
#if defined(ATOMIC_STORE64)
  ATOMIC_STORE64(ptr, val);
#else
  *ptr = val;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
void atomic_store_u64_c(uint64_t *ptr, uint64_t val) {
  atomic_store_u64_impl(ptr, val);
}
#endif

int64_t atomic_fetch_add_i64_impl(int64_t *ptr, int64_t delta) {
#if defined(ATOMIC_FADD64)
  return (int64_t)ATOMIC_FADD64(ptr, delta);
#else
  int64_t old = *ptr;
  *ptr = old + delta;
  return old;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int64_t atomic_fetch_add_i64_c(int64_t *ptr, int64_t delta) {
  return atomic_fetch_add_i64_impl(ptr, delta);
}
#endif

/* --- STD-046: memory fences --- */

void atomic_fence_seq_cst_impl(void) {
#if defined(__GNUC__) || defined(__clang__)
  __atomic_thread_fence(__ATOMIC_SEQ_CST);
#elif USE_C11_ATOMICS
  atomic_thread_fence(memory_order_seq_cst);
#else
  /* no-op */
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
void atomic_fence_seq_cst_c(void) {
  atomic_fence_seq_cst_impl();
}
#endif

void atomic_fence_acquire_impl(void) {
#if defined(__GNUC__) || defined(__clang__)
  __atomic_thread_fence(__ATOMIC_ACQUIRE);
#elif USE_C11_ATOMICS
  atomic_thread_fence(memory_order_acquire);
#else
  /* no-op */
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
void atomic_fence_acquire_c(void) {
  atomic_fence_acquire_impl();
}
#endif

void atomic_fence_release_impl(void) {
#if defined(__GNUC__) || defined(__clang__)
  __atomic_thread_fence(__ATOMIC_RELEASE);
#elif USE_C11_ATOMICS
  atomic_thread_fence(memory_order_release);
#else
  /* no-op */
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
void atomic_fence_release_c(void) {
  atomic_fence_release_impl();
}
#endif

/* --- STD-146: i16/u16 and i64/u64 extensions --- */

int16_t atomic_load_i16_impl(int16_t *ptr) {
#if defined(ATOMIC_LOAD16)
  return (int16_t)ATOMIC_LOAD16(ptr);
#else
  return *ptr;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int16_t atomic_load_i16_c(int16_t *ptr) {
  return atomic_load_i16_impl(ptr);
}
#endif

void atomic_store_i16_impl(int16_t *ptr, int16_t val) {
#if defined(ATOMIC_STORE16)
  ATOMIC_STORE16(ptr, val);
#else
  *ptr = val;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
void atomic_store_i16_c(int16_t *ptr, int16_t val) {
  atomic_store_i16_impl(ptr, val);
}
#endif

int16_t atomic_fetch_add_i16_impl(int16_t *ptr, int16_t delta) {
#if defined(ATOMIC_FADD16)
  return (int16_t)ATOMIC_FADD16(ptr, delta);
#else
  int16_t old = *ptr;
  *ptr = (int16_t)(old + delta);
  return old;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int16_t atomic_fetch_add_i16_c(int16_t *ptr, int16_t delta) {
  return atomic_fetch_add_i16_impl(ptr, delta);
}
#endif

int32_t atomic_compare_exchange_i16_impl(int16_t *ptr, int16_t *expected, int16_t desired) {
#if defined(ATOMIC_CAS16)
  int16_t e = *expected;
  if (ATOMIC_CAS16(ptr, &e, desired)) return 1;
  *expected = e;
  return 0;
#else
  if (*ptr == *expected) { *ptr = desired; return 1; }
  *expected = *ptr;
  return 0;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int32_t atomic_compare_exchange_i16_c(int16_t *ptr, int16_t *expected, int16_t desired) {
  return atomic_compare_exchange_i16_impl(ptr, expected, desired);
}
#endif

uint16_t atomic_load_u16_impl(uint16_t *ptr) {
#if defined(ATOMIC_LOAD16)
  return (uint16_t)ATOMIC_LOAD16(ptr);
#else
  return *ptr;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
uint16_t atomic_load_u16_c(uint16_t *ptr) {
  return atomic_load_u16_impl(ptr);
}
#endif

void atomic_store_u16_impl(uint16_t *ptr, uint16_t val) {
#if defined(ATOMIC_STORE16)
  ATOMIC_STORE16(ptr, val);
#else
  *ptr = val;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
void atomic_store_u16_c(uint16_t *ptr, uint16_t val) {
  atomic_store_u16_impl(ptr, val);
}
#endif

uint16_t atomic_fetch_add_u16_impl(uint16_t *ptr, uint16_t delta) {
#if defined(ATOMIC_FADD16)
  return (uint16_t)ATOMIC_FADD16(ptr, delta);
#else
  uint16_t old = *ptr;
  *ptr = (uint16_t)(old + delta);
  return old;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
uint16_t atomic_fetch_add_u16_c(uint16_t *ptr, uint16_t delta) {
  return atomic_fetch_add_u16_impl(ptr, delta);
}
#endif

int32_t atomic_compare_exchange_u16_impl(uint16_t *ptr, uint16_t *expected, uint16_t desired) {
#if defined(__GNUC__) || defined(__clang__)
  uint16_t e = *expected;
  if (__atomic_compare_exchange_n(ptr, &e, desired, 0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST)) return 1;
  *expected = e;
  return 0;
#else
  if (*ptr == *expected) { *ptr = desired; return 1; }
  *expected = *ptr;
  return 0;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int32_t atomic_compare_exchange_u16_c(uint16_t *ptr, uint16_t *expected, uint16_t desired) {
  return atomic_compare_exchange_u16_impl(ptr, expected, desired);
}
#endif

int32_t atomic_compare_exchange_i64_impl(int64_t *ptr, int64_t *expected, int64_t desired) {
#if defined(ATOMIC_CAS64)
  int64_t e = *expected;
  if (ATOMIC_CAS64(ptr, &e, desired)) return 1;
  *expected = e;
  return 0;
#elif USE_C11_ATOMICS
  int64_t e = *expected;
  if (atomic_compare_exchange_strong_explicit((_Atomic int64_t *)ptr, &e, desired, memory_order_seq_cst, memory_order_seq_cst)) return 1;
  *expected = e;
  return 0;
#else
  if (*ptr == *expected) { *ptr = desired; return 1; }
  *expected = *ptr;
  return 0;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int32_t atomic_compare_exchange_i64_c(int64_t *ptr, int64_t *expected, int64_t desired) {
  return atomic_compare_exchange_i64_impl(ptr, expected, desired);
}
#endif

int64_t atomic_fetch_sub_i64_impl(int64_t *ptr, int64_t delta) {
#if defined(ATOMIC_FSUB64)
  return (int64_t)ATOMIC_FSUB64(ptr, delta);
#else
  return atomic_fetch_add_i64_impl(ptr, -delta);
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int64_t atomic_fetch_sub_i64_c(int64_t *ptr, int64_t delta) {
  return atomic_fetch_sub_i64_impl(ptr, delta);
}
#endif

uint64_t atomic_fetch_add_u64_impl(uint64_t *ptr, uint64_t delta) {
#if defined(ATOMIC_FADD64)
  return (uint64_t)ATOMIC_FADD64(ptr, delta);
#else
  uint64_t old = *ptr;
  *ptr = old + delta;
  return old;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
uint64_t atomic_fetch_add_u64_c(uint64_t *ptr, uint64_t delta) {
  return atomic_fetch_add_u64_impl(ptr, delta);
}
#endif

uint64_t atomic_fetch_sub_u64_impl(uint64_t *ptr, uint64_t delta) {
#if defined(ATOMIC_FSUB64)
  return (uint64_t)ATOMIC_FSUB64(ptr, delta);
#else
  return atomic_fetch_add_u64_impl(ptr, (uint64_t)(0 - delta));
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
uint64_t atomic_fetch_sub_u64_c(uint64_t *ptr, uint64_t delta) {
  return atomic_fetch_sub_u64_impl(ptr, delta);
}
#endif

int32_t atomic_compare_exchange_u64_impl(uint64_t *ptr, uint64_t *expected, uint64_t desired) {
#if defined(ATOMIC_CAS64)
  uint64_t e = *expected;
  if (ATOMIC_CAS64(ptr, &e, desired)) return 1;
  *expected = e;
  return 0;
#elif USE_C11_ATOMICS
  uint64_t e = *expected;
  if (atomic_compare_exchange_strong_explicit((_Atomic uint64_t *)ptr, &e, desired, memory_order_seq_cst, memory_order_seq_cst)) return 1;
  *expected = e;
  return 0;
#else
  if (*ptr == *expected) { *ptr = desired; return 1; }
  *expected = *ptr;
  return 0;
#endif
}

#ifndef XLANG_RUNTIME_ATOMIC_GLUE_FROM_X
int32_t atomic_compare_exchange_u64_c(uint64_t *ptr, uint64_t *expected, uint64_t desired) {
  return atomic_compare_exchange_u64_impl(ptr, expected, desired);
}
#endif
