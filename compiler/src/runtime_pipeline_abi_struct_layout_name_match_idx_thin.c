/* Host-gcc twins of parser_asm_struct_layout_first_name_match_idx_c
 * and parser_asm_struct_layout_placeholder_idx_c (pthin_fn_block.x).
 * Same typool-wrong as already-folded name_exists_arr_c: typool
 * first-wins W first_name_match 0x1404668f4 (writer 0x140466aa1) and
 * placeholder 0x140466bd0 (writer 0x140466d86) compile `slot[0] = nlen`
 * as a store to &slot, so lim stays 0 and the byte-compare loop never
 * runs. Equal-length names then compare equal. typool x_into always
 * calls placeholder, and calls first_name_match when name_exists is
 * true and the slot is not a placeholder; a true re-record of
 * Option_u64 (nlen=10) would SET_NAME the Option_i32 slot. Same typool
 * faces also compile `bytes[off]` as a scale-8 qword load through
 * &bytes; the host-gcc twins index *u8 directly.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

extern int32_t pipeline_module_num_struct_layouts_at(uint8_t *module);
extern int32_t pipeline_module_struct_layout_name_len(uint8_t *module, int32_t k);
extern int32_t pipeline_module_struct_layout_name_byte_at(uint8_t *module, int32_t k, int32_t ii);
extern int32_t pipeline_module_struct_layout_num_fields(uint8_t *module, int32_t k);
extern int32_t pipeline_module_struct_layout_field_name_len(uint8_t *module, int32_t k, int32_t j);
extern int32_t pipeline_module_struct_layout_field_type_ref(uint8_t *module, int32_t k, int32_t j);

static int32_t name_bytes_same(uint8_t *module, uint8_t *nm, int32_t nlen, int32_t k) {
  int32_t ii;
  if (pipeline_module_struct_layout_name_len(module, k) != nlen)
    return 0;
  ii = 0;
  while (ii < nlen) {
    if (ii >= 64)
      break;
    if ((uint8_t)pipeline_module_struct_layout_name_byte_at(module, k, ii) != nm[ii])
      return 0;
    ii = ii + 1;
  }
  return 1;
}

int32_t parser_asm_struct_layout_first_name_match_idx_c(uint8_t *module, uint8_t *nm, int32_t nlen) {
  int32_t k, nsl;
  if (module == 0 || nm == 0 || nlen <= 0)
    return -1;
  nsl = pipeline_module_num_struct_layouts_at(module);
  k = 0;
  while (k < nsl) {
    if (name_bytes_same(module, nm, nlen, k) != 0)
      return k;
    k = k + 1;
  }
  return -1;
}

int32_t parser_asm_struct_layout_placeholder_idx_c(uint8_t *module, uint8_t *nm, int32_t nlen) {
  int32_t k, nsl, nf;
  if (module == 0 || nm == 0 || nlen <= 0)
    return -1;
  nsl = pipeline_module_num_struct_layouts_at(module);
  k = 0;
  while (k < nsl) {
    if (name_bytes_same(module, nm, nlen, k) != 0) {
      nf = pipeline_module_struct_layout_num_fields(module, k);
      if (nf == 0)
        return k;
      if (nf == 1 && pipeline_module_struct_layout_field_name_len(module, k, 0) == 0)
        return k;
      if (nf == 1 && pipeline_module_struct_layout_field_type_ref(module, k, 0) == 0)
        return k;
    }
    k = k + 1;
  }
  return -1;
}
