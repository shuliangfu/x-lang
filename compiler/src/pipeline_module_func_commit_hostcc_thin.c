/*
 * Host-gcc Soft Cap twins for tip parse_into post-alloc commit faces (DIG s272).
 *
 * Map (s268–s272): Soft Cap one_fn dig ok; tip fill rc=1; tip alloc_slot rc=0;
 * native typed let still P001 while gdb coff=163. UNIQUE = after alloc_slot
 * (name_write / set_body / set_return …) Heisenbug with sidecar lets.
 *
 * Soft Cap EXIT owns small host-cc bodies matching seed C W280_Func layout
 * (name[256]@0, name_len@256, … return_type_ref@272, body_ref@276). Soft Cap
 * memset only name[] — never the whole Func head (thin .x memset(f,256) risk).
 *
 * PLATFORM: WINDOWS Soft Cap; SHARED layout ≡ runtime_pipeline_abi.from_x.c.
 */
#include <stdint.h>
#include <string.h>

/*
 * PLATFORM: SHARED — seed W280_Func product LE layout (Func 324).
 * name[256]@0 name_len@256 param_base@260 num_params@264
 * num_generic_params@268 return_type_ref@272 body_ref@276 …
 */
typedef struct {
  uint8_t name[256];
  int32_t name_len;
  int32_t param_base;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t return_type_ref;
  int32_t body_ref;
} SoftcapFuncCommitHead;

extern void *pipeline_module_func_ptr(void *m, int32_t func_index);

/**
 * Soft Cap: write Func.name[256] (content ≤255) without zeroing sibling fields.
 *
 * @param m Module*
 * @param func_index slot from alloc_slot
 * @param name_bytes name bytes; null only when name_len==0
 * @param name_len byte count in [0,255]
 * PLATFORM: WINDOWS Soft Cap ≡ seed C pipeline_module_func_name_write.
 */
void pipeline_module_func_name_write(void *m, int32_t func_index, uint8_t *name_bytes,
                                    int32_t name_len) {
  SoftcapFuncCommitHead *f;
  if (m == 0 || func_index < 0) {
    return;
  }
  if (name_len < 0 || name_len > 255) {
    return;
  }
  if (name_len > 0 && name_bytes == 0) {
    return;
  }
  f = (SoftcapFuncCommitHead *)pipeline_module_func_ptr(m, func_index);
  if (f == 0) {
    return;
  }
  f->name_len = name_len;
  memset(f->name, 0, sizeof(f->name));
  if (name_len > 0) {
    memcpy(f->name, name_bytes, (size_t)name_len);
  }
}

/**
 * Soft Cap: set Func.return_type_ref.
 *
 * @param m Module*
 * @param fi func index
 * @param type_ref type arena ref
 * PLATFORM: WINDOWS Soft Cap ≡ seed C.
 */
void pipeline_module_func_set_return_type(void *m, int32_t fi, int32_t type_ref) {
  SoftcapFuncCommitHead *f;
  if (m == 0 || fi < 0) {
    return;
  }
  f = (SoftcapFuncCommitHead *)pipeline_module_func_ptr(m, fi);
  if (f == 0) {
    return;
  }
  f->return_type_ref = type_ref;
}

/**
 * Soft Cap: set Func.body_ref.
 *
 * @param m Module*
 * @param fi func index
 * @param body_ref block ref
 * PLATFORM: WINDOWS Soft Cap ≡ seed C.
 */
void pipeline_module_func_set_body_ref(void *m, int32_t fi, int32_t body_ref) {
  SoftcapFuncCommitHead *f;
  if (m == 0 || fi < 0) {
    return;
  }
  f = (SoftcapFuncCommitHead *)pipeline_module_func_ptr(m, fi);
  if (f == 0) {
    return;
  }
  f->body_ref = body_ref;
}
