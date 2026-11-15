/* Host-gcc twin of parser_asm_struct_layout_name_exists_arr_c
 * (pthin_fn_block.x). typool first-wins W 0x1404664a0 compiles
 * `slot[0] = nlen` as a store to &slot (the pointer local), so lim
 * stays 0 and the byte-compare loop never runs. Equal-length names
 * then compare equal. typool-rebuild of core/option/mod.x therefore
 * treats export struct Option_u64 (nlen=10) as a duplicate of
 * already-registered Option_i32 (nlen=10); SET_NAME overwrites that
 * slot and none_i32 typeck T001 named_no_layout on *Option_i32.
 * Writer RIP typool 0x1404667cb (loop head then sees lim=0, slot=10).
 * Same typool face also compiles `bytes[off]` as a scale-8 qword
 * load through &bytes; the host-gcc twin indexes *u8 directly.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

extern int32_t pipeline_module_num_struct_layouts_at(uint8_t *module);
extern int32_t pipeline_module_struct_layout_name_len(uint8_t *module, int32_t k);
extern int32_t pipeline_module_struct_layout_name_byte_at(uint8_t *module, int32_t k, int32_t ii);

int32_t parser_asm_struct_layout_name_exists_arr_c(uint8_t *module, uint8_t *nm, int32_t nlen) {
  int32_t k, nsl, ii, same;
  if (module == 0 || nm == 0 || nlen <= 0)
    return 0;
  nsl = pipeline_module_num_struct_layouts_at(module);
  k = 0;
  while (k < nsl) {
    if (pipeline_module_struct_layout_name_len(module, k) == nlen) {
      same = 1;
      ii = 0;
      while (ii < nlen) {
        if (ii >= 64)
          break;
        if ((uint8_t)pipeline_module_struct_layout_name_byte_at(module, k, ii) != nm[ii]) {
          same = 0;
          break;
        }
        ii = ii + 1;
      }
      if (same != 0)
        return 1;
    }
    k = k + 1;
  }
  return 0;
}
