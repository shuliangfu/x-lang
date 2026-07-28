/* seeds/runtime_atomic_glue_surface.from_x.c
 * G-02f-144 runtime_atomic_glue R2 thin surface — isomorphic with src/asm/runtime_atomic_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_ATOMIC_GLUE_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (30 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest — .x provides 30 thin wrappers; seed provides 30 _impl functions
 * Cap residual: 30 _impl bridges in runtime_atomic_glue.from_x.c (atomic load/store/cas/fetch_add/
 *   fetch_sub/fence for i16/u16/i32/u32/i64/u64 — C11 stdatomic or GCC __atomic intrinsics)
 * Note: doc_anchor has no ast_ prefix — atomic_ #[no_mangle] does not trigger ast_ prefix
 *   (only net_ prefix triggers, per wave545-547 discovery)
 * Regen: ./xlang-c -E ... runtime_atomic_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern int32_t atomic_load_i32_impl(int32_t *ptr);
extern void atomic_store_i32_impl(int32_t *ptr, int32_t val);
extern int32_t atomic_compare_exchange_i32_impl(int32_t *ptr, int32_t *expected, int32_t desired);
extern int32_t atomic_fetch_add_i32_impl(int32_t *ptr, int32_t delta);
extern int32_t atomic_fetch_sub_i32_impl(int32_t *ptr, int32_t delta);

extern uint32_t atomic_load_u32_impl(uint32_t *ptr);
extern void atomic_store_u32_impl(uint32_t *ptr, uint32_t val);
extern int32_t atomic_compare_exchange_u32_impl(uint32_t *ptr, uint32_t *expected, uint32_t desired);
extern uint32_t atomic_fetch_add_u32_impl(uint32_t *ptr, uint32_t delta);

extern int64_t atomic_load_i64_impl(int64_t *ptr);
extern void atomic_store_i64_impl(int64_t *ptr, int64_t val);
extern int64_t atomic_fetch_add_i64_impl(int64_t *ptr, int64_t delta);
extern int64_t atomic_fetch_sub_i64_impl(int64_t *ptr, int64_t delta);
extern int32_t atomic_compare_exchange_i64_impl(int64_t *ptr, int64_t *expected, int64_t desired);

extern uint64_t atomic_load_u64_impl(uint64_t *ptr);
extern void atomic_store_u64_impl(uint64_t *ptr, uint64_t val);
extern uint64_t atomic_fetch_add_u64_impl(uint64_t *ptr, uint64_t delta);
extern uint64_t atomic_fetch_sub_u64_impl(uint64_t *ptr, uint64_t delta);
extern int32_t atomic_compare_exchange_u64_impl(uint64_t *ptr, uint64_t *expected, uint64_t desired);

extern void atomic_fence_seq_cst_impl(void);
extern void atomic_fence_acquire_impl(void);
extern void atomic_fence_release_impl(void);

extern int16_t atomic_load_i16_impl(int16_t *ptr);
extern void atomic_store_i16_impl(int16_t *ptr, int16_t val);
extern int16_t atomic_fetch_add_i16_impl(int16_t *ptr, int16_t delta);
extern int32_t atomic_compare_exchange_i16_impl(int16_t *ptr, int16_t *expected, int16_t desired);

extern uint16_t atomic_load_u16_impl(uint16_t *ptr);
extern void atomic_store_u16_impl(uint16_t *ptr, uint16_t val);
extern uint16_t atomic_fetch_add_u16_impl(uint16_t *ptr, uint16_t delta);
extern int32_t atomic_compare_exchange_u16_impl(uint16_t *ptr, uint16_t *expected, uint16_t desired);

int32_t runtime_atomic_glue_x_doc_anchor(void) { return 0; }

int32_t atomic_load_i32_c(int32_t *ptr) { return atomic_load_i32_impl(ptr); }
void atomic_store_i32_c(int32_t *ptr, int32_t val) { atomic_store_i32_impl(ptr, val); }
int32_t atomic_compare_exchange_i32_c(int32_t *ptr, int32_t *expected, int32_t desired) { return atomic_compare_exchange_i32_impl(ptr, expected, desired); }
int32_t atomic_fetch_add_i32_c(int32_t *ptr, int32_t delta) { return atomic_fetch_add_i32_impl(ptr, delta); }
int32_t atomic_fetch_sub_i32_c(int32_t *ptr, int32_t delta) { return atomic_fetch_sub_i32_impl(ptr, delta); }

uint32_t atomic_load_u32_c(uint32_t *ptr) { return atomic_load_u32_impl(ptr); }
void atomic_store_u32_c(uint32_t *ptr, uint32_t val) { atomic_store_u32_impl(ptr, val); }
int32_t atomic_compare_exchange_u32_c(uint32_t *ptr, uint32_t *expected, uint32_t desired) { return atomic_compare_exchange_u32_impl(ptr, expected, desired); }
uint32_t atomic_fetch_add_u32_c(uint32_t *ptr, uint32_t delta) { return atomic_fetch_add_u32_impl(ptr, delta); }

int64_t atomic_load_i64_c(int64_t *ptr) { return atomic_load_i64_impl(ptr); }
void atomic_store_i64_c(int64_t *ptr, int64_t val) { atomic_store_i64_impl(ptr, val); }
int64_t atomic_fetch_add_i64_c(int64_t *ptr, int64_t delta) { return atomic_fetch_add_i64_impl(ptr, delta); }
int64_t atomic_fetch_sub_i64_c(int64_t *ptr, int64_t delta) { return atomic_fetch_sub_i64_impl(ptr, delta); }
int32_t atomic_compare_exchange_i64_c(int64_t *ptr, int64_t *expected, int64_t desired) { return atomic_compare_exchange_i64_impl(ptr, expected, desired); }

uint64_t atomic_load_u64_c(uint64_t *ptr) { return atomic_load_u64_impl(ptr); }
void atomic_store_u64_c(uint64_t *ptr, uint64_t val) { atomic_store_u64_impl(ptr, val); }
uint64_t atomic_fetch_add_u64_c(uint64_t *ptr, uint64_t delta) { return atomic_fetch_add_u64_impl(ptr, delta); }
uint64_t atomic_fetch_sub_u64_c(uint64_t *ptr, uint64_t delta) { return atomic_fetch_sub_u64_impl(ptr, delta); }
int32_t atomic_compare_exchange_u64_c(uint64_t *ptr, uint64_t *expected, uint64_t desired) { return atomic_compare_exchange_u64_impl(ptr, expected, desired); }

void atomic_fence_seq_cst_c(void) { atomic_fence_seq_cst_impl(); }
void atomic_fence_acquire_c(void) { atomic_fence_acquire_impl(); }
void atomic_fence_release_c(void) { atomic_fence_release_impl(); }

int16_t atomic_load_i16_c(int16_t *ptr) { return atomic_load_i16_impl(ptr); }
void atomic_store_i16_c(int16_t *ptr, int16_t val) { atomic_store_i16_impl(ptr, val); }
int16_t atomic_fetch_add_i16_c(int16_t *ptr, int16_t delta) { return atomic_fetch_add_i16_impl(ptr, delta); }
int32_t atomic_compare_exchange_i16_c(int16_t *ptr, int16_t *expected, int16_t desired) { return atomic_compare_exchange_i16_impl(ptr, expected, desired); }

uint16_t atomic_load_u16_c(uint16_t *ptr) { return atomic_load_u16_impl(ptr); }
void atomic_store_u16_c(uint16_t *ptr, uint16_t val) { atomic_store_u16_impl(ptr, val); }
uint16_t atomic_fetch_add_u16_c(uint16_t *ptr, uint16_t delta) { return atomic_fetch_add_u16_impl(ptr, delta); }
int32_t atomic_compare_exchange_u16_c(uint16_t *ptr, uint16_t *expected, uint16_t desired) { return atomic_compare_exchange_u16_impl(ptr, expected, desired); }
