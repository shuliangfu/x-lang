/* seeds/runtime_thread_glue_surface.from_x.c
 * G-02f-18 runtime_thread_glue R2 thin+rest surface - isomorphic with src/asm/runtime_thread_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_thread_glue.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (24 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest - 16 thin forwards to _impl + 8 DIRECT std_thread_ star forwards to thread_ star _c
 * Cap residual: 16 _impl OS bridges (pthread_ star / CreateThread / SetThreadAffinityMask / qos_class)
 * doc_anchor runtime_thread_glue_x_doc_anchor (no ast_; no module prefix on doc_anchor).
 * Note: thread_/std_thread_/xlang_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 24 functions = 16 thin+rest (2 xlang_cpu_ star + 14 thread_ star) + 8 DIRECT std_thread_ star.
 * Regen: ./xlang-c -E ... runtime_thread_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern void xlang_cpu_zero_impl(uint8_t *set);
extern void xlang_cpu_set_impl(uint32_t cpu, uint8_t *set);
extern int64_t thread_self_impl(void);
extern int64_t thread_create_impl(uint8_t *entry, uint8_t *arg);
extern int64_t thread_create_with_stack_impl(uint8_t *entry, uint8_t *arg, uint64_t stack_size);
extern int32_t thread_join_impl(int64_t thread_id);
extern int32_t thread_set_affinity_self_impl(int32_t cpu_index);
extern int32_t thread_set_affinity_impl(int64_t thread_id, int32_t cpu_index);
extern int32_t thread_set_qos_class_self_impl(int32_t qos_class);
extern int32_t thread_set_name_self_impl(uint8_t *name, int32_t len);
extern uint64_t thread_dummy_entry_ptr_impl(void);
extern int32_t thread_pool_start_impl(int32_t workers);
extern int32_t thread_pool_submit_impl(uint64_t entry, uint64_t arg);
extern int32_t thread_pool_drain_impl(void);
extern int32_t thread_pool_stop_impl(void);
extern int32_t thread_pool_pending_impl(void);

int32_t runtime_thread_glue_x_doc_anchor(void) { return 0; }

/* === 16 thin+rest forwards === */

void xlang_cpu_zero(uint8_t *set) { xlang_cpu_zero_impl(set); }
void xlang_cpu_set(uint32_t cpu, uint8_t *set) { xlang_cpu_set_impl(cpu, set); }

int64_t thread_self_c(void) { return thread_self_impl(); }
int64_t thread_create_c(uint8_t *entry, uint8_t *arg) { return thread_create_impl(entry, arg); }
int64_t thread_create_with_stack_c(uint8_t *entry, uint8_t *arg, uint64_t stack_size) {
  return thread_create_with_stack_impl(entry, arg, stack_size);
}
int32_t thread_join_c(int64_t thread_id) { return thread_join_impl(thread_id); }
int32_t thread_set_affinity_self_c(int32_t cpu_index) { return thread_set_affinity_self_impl(cpu_index); }
int32_t thread_set_affinity_c(int64_t thread_id, int32_t cpu_index) {
  return thread_set_affinity_impl(thread_id, cpu_index);
}
int32_t thread_set_qos_class_self_c(int32_t qos_class) { return thread_set_qos_class_self_impl(qos_class); }
int32_t thread_set_name_self_c(uint8_t *name, int32_t len) { return thread_set_name_self_impl(name, len); }
uint64_t thread_dummy_entry_ptr_c(void) { return thread_dummy_entry_ptr_impl(); }
int32_t thread_pool_start_c(int32_t workers) { return thread_pool_start_impl(workers); }
int32_t thread_pool_submit_c(uint64_t entry, uint64_t arg) { return thread_pool_submit_impl(entry, arg); }
int32_t thread_pool_drain_c(void) { return thread_pool_drain_impl(); }
int32_t thread_pool_stop_c(void) { return thread_pool_stop_impl(); }
int32_t thread_pool_pending_c(void) { return thread_pool_pending_impl(); }

/* === 8 DIRECT std_thread_ star forwards to thread_ star _c === */

int64_t std_thread_thread_self_c(void) { return thread_self_c(); }
int64_t std_thread_thread_create_c(uint8_t *entry, uint8_t *arg) { return thread_create_c(entry, arg); }
int64_t std_thread_thread_create_with_stack_c(uint8_t *entry, uint8_t *arg, uint64_t stack_size) {
  return thread_create_with_stack_c(entry, arg, stack_size);
}
int32_t std_thread_thread_join_c(int64_t thread_id) { return thread_join_c(thread_id); }
int32_t std_thread_thread_set_affinity_self_c(int32_t cpu_index) {
  return thread_set_affinity_self_c(cpu_index);
}
int32_t std_thread_thread_set_affinity_c(int64_t thread_id, int32_t cpu_index) {
  return thread_set_affinity_c(thread_id, cpu_index);
}
int32_t std_thread_thread_set_qos_class_self_c(int32_t qos_class) {
  return thread_set_qos_class_self_c(qos_class);
}
uint64_t std_thread_thread_dummy_entry_ptr_c(void) { return thread_dummy_entry_ptr_c(); }
