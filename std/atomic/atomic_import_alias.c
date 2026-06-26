/**
 * atomic_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const atomic = import("std.atomic")` 生成 std_atomic_* 符号；
 * atomic.o 仅含 atomic.sx 锚点，mod.sx 门面未 co-emit。本 TU 提供 std_atomic_* 转发至
 * runtime_atomic_glue.c 中的 atomic_*_c。
 */
#include <stdint.h>

extern int32_t atomic_load_i32_c(const int32_t *ptr);
extern void atomic_store_i32_c(int32_t *ptr, int32_t val);
extern int32_t atomic_compare_exchange_i32_c(int32_t *ptr, int32_t *expected, int32_t desired);
extern int32_t atomic_fetch_add_i32_c(int32_t *ptr, int32_t delta);
extern int32_t atomic_fetch_sub_i32_c(int32_t *ptr, int32_t delta);
extern uint32_t atomic_load_u32_c(const uint32_t *ptr);
extern void atomic_store_u32_c(uint32_t *ptr, uint32_t val);
extern int32_t atomic_compare_exchange_u32_c(uint32_t *ptr, uint32_t *expected, uint32_t desired);
extern uint32_t atomic_fetch_add_u32_c(uint32_t *ptr, uint32_t delta);
extern int64_t atomic_load_i64_c(const int64_t *ptr);
extern void atomic_store_i64_c(int64_t *ptr, int64_t val);
extern uint64_t atomic_load_u64_c(const uint64_t *ptr);
extern void atomic_store_u64_c(uint64_t *ptr, uint64_t val);
extern int64_t atomic_fetch_add_i64_c(int64_t *ptr, int64_t delta);
extern int64_t atomic_fetch_sub_i64_c(int64_t *ptr, int64_t delta);
extern uint64_t atomic_fetch_add_u64_c(uint64_t *ptr, uint64_t delta);
extern uint64_t atomic_fetch_sub_u64_c(uint64_t *ptr, uint64_t delta);
extern int32_t atomic_compare_exchange_i64_c(int64_t *ptr, int64_t *expected, int64_t desired);
extern int32_t atomic_compare_exchange_u64_c(uint64_t *ptr, uint64_t *expected, uint64_t desired);
extern int16_t atomic_load_i16_c(const int16_t *ptr);
extern void atomic_store_i16_c(int16_t *ptr, int16_t val);
extern int16_t atomic_fetch_add_i16_c(int16_t *ptr, int16_t delta);
extern int32_t atomic_compare_exchange_i16_c(int16_t *ptr, int16_t *expected, int16_t desired);
extern uint16_t atomic_load_u16_c(const uint16_t *ptr);
extern void atomic_store_u16_c(uint16_t *ptr, uint16_t val);
extern uint16_t atomic_fetch_add_u16_c(uint16_t *ptr, uint16_t delta);
extern int32_t atomic_compare_exchange_u16_c(uint16_t *ptr, uint16_t *expected, uint16_t desired);
extern void atomic_fence_seq_cst_c(void);
extern void atomic_fence_acquire_c(void);
extern void atomic_fence_release_c(void);

/** load i32；转发 atomic_load_i32_c。 */
int32_t std_atomic_load_i32(int32_t *ptr) { return atomic_load_i32_c(ptr); }

/** store i32；转发 atomic_store_i32_c。 */
void std_atomic_store_i32(int32_t *ptr, int32_t val) { atomic_store_i32_c(ptr, val); }

/** compare_exchange i32；转发 atomic_compare_exchange_i32_c。 */
int32_t std_atomic_compare_exchange_i32(int32_t *ptr, int32_t *expected, int32_t desired) {
  return atomic_compare_exchange_i32_c(ptr, expected, desired);
}

/** fetch_add i32；转发 atomic_fetch_add_i32_c。 */
int32_t std_atomic_fetch_add_i32(int32_t *ptr, int32_t delta) {
  return atomic_fetch_add_i32_c(ptr, delta);
}

/** fetch_sub i32；转发 atomic_fetch_sub_i32_c。 */
int32_t std_atomic_fetch_sub_i32(int32_t *ptr, int32_t delta) {
  return atomic_fetch_sub_i32_c(ptr, delta);
}

/** load u32；转发 atomic_load_u32_c。 */
uint32_t std_atomic_load_u32(uint32_t *ptr) { return atomic_load_u32_c(ptr); }

/** store u32；转发 atomic_store_u32_c。 */
void std_atomic_store_u32(uint32_t *ptr, uint32_t val) { atomic_store_u32_c(ptr, val); }

/** compare_exchange u32；转发 atomic_compare_exchange_u32_c。 */
int32_t std_atomic_compare_exchange_u32(uint32_t *ptr, uint32_t *expected, uint32_t desired) {
  return atomic_compare_exchange_u32_c(ptr, expected, desired);
}

/** fetch_add u32；转发 atomic_fetch_add_u32_c。 */
uint32_t std_atomic_fetch_add_u32(uint32_t *ptr, uint32_t delta) {
  return atomic_fetch_add_u32_c(ptr, delta);
}

/** load i64；转发 atomic_load_i64_c。 */
int64_t std_atomic_load_i64(int64_t *ptr) { return atomic_load_i64_c(ptr); }

/** store i64；转发 atomic_store_i64_c。 */
void std_atomic_store_i64(int64_t *ptr, int64_t val) { atomic_store_i64_c(ptr, val); }

/** load u64；转发 atomic_load_u64_c。 */
uint64_t std_atomic_load_u64(uint64_t *ptr) { return atomic_load_u64_c(ptr); }

/** store u64；转发 atomic_store_u64_c。 */
void std_atomic_store_u64(uint64_t *ptr, uint64_t val) { atomic_store_u64_c(ptr, val); }

/** fetch_add i64；转发 atomic_fetch_add_i64_c。 */
int64_t std_atomic_fetch_add_i64(int64_t *ptr, int64_t delta) {
  return atomic_fetch_add_i64_c(ptr, delta);
}

/** fetch_sub i64；转发 atomic_fetch_sub_i64_c。 */
int64_t std_atomic_fetch_sub_i64(int64_t *ptr, int64_t delta) {
  return atomic_fetch_sub_i64_c(ptr, delta);
}

/** fetch_add u64；转发 atomic_fetch_add_u64_c。 */
uint64_t std_atomic_fetch_add_u64(uint64_t *ptr, uint64_t delta) {
  return atomic_fetch_add_u64_c(ptr, delta);
}

/** fetch_sub u64；转发 atomic_fetch_sub_u64_c。 */
uint64_t std_atomic_fetch_sub_u64(uint64_t *ptr, uint64_t delta) {
  return atomic_fetch_sub_u64_c(ptr, delta);
}

/** compare_exchange i64；转发 atomic_compare_exchange_i64_c。 */
int32_t std_atomic_compare_exchange_i64(int64_t *ptr, int64_t *expected, int64_t desired) {
  return atomic_compare_exchange_i64_c(ptr, expected, desired);
}

/** compare_exchange u64；转发 atomic_compare_exchange_u64_c。 */
int32_t std_atomic_compare_exchange_u64(uint64_t *ptr, uint64_t *expected, uint64_t desired) {
  return atomic_compare_exchange_u64_c(ptr, expected, desired);
}

/** load i16；转发 atomic_load_i16_c。 */
int16_t std_atomic_load_i16(int16_t *ptr) { return atomic_load_i16_c(ptr); }

/** store i16；转发 atomic_store_i16_c。 */
void std_atomic_store_i16(int16_t *ptr, int16_t val) { atomic_store_i16_c(ptr, val); }

/** fetch_add i16；转发 atomic_fetch_add_i16_c。 */
int16_t std_atomic_fetch_add_i16(int16_t *ptr, int16_t delta) {
  return atomic_fetch_add_i16_c(ptr, delta);
}

/** compare_exchange i16；转发 atomic_compare_exchange_i16_c。 */
int32_t std_atomic_compare_exchange_i16(int16_t *ptr, int16_t *expected, int16_t desired) {
  return atomic_compare_exchange_i16_c(ptr, expected, desired);
}

/** load u16；转发 atomic_load_u16_c。 */
uint16_t std_atomic_load_u16(uint16_t *ptr) { return atomic_load_u16_c(ptr); }

/** store u16；转发 atomic_store_u16_c。 */
void std_atomic_store_u16(uint16_t *ptr, uint16_t val) { atomic_store_u16_c(ptr, val); }

/** fetch_add u16；转发 atomic_fetch_add_u16_c。 */
uint16_t std_atomic_fetch_add_u16(uint16_t *ptr, uint16_t delta) {
  return atomic_fetch_add_u16_c(ptr, delta);
}

/** compare_exchange u16；转发 atomic_compare_exchange_u16_c。 */
int32_t std_atomic_compare_exchange_u16(uint16_t *ptr, uint16_t *expected, uint16_t desired) {
  return atomic_compare_exchange_u16_c(ptr, expected, desired);
}

/** 全序 fence；转发 atomic_fence_seq_cst_c。 */
void std_atomic_fence_seq_cst(void) { atomic_fence_seq_cst_c(); }

/** acquire fence；转发 atomic_fence_acquire_c。 */
void std_atomic_fence_acquire(void) { atomic_fence_acquire_c(); }

/** release fence；转发 atomic_fence_release_c。 */
void std_atomic_fence_release(void) { atomic_fence_release_c(); }
