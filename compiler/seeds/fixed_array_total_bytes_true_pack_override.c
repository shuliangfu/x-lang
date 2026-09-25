/**
 * PLATFORM: SHARED tip — true-pack glue_fixed_array_total_bytes_c.
 *
 * w1022: Cap residual named i8→4 made [2]i8 row stride 8. Local nested
 * ARRAY_LIT stores pack dense (offsets 0..3) while INDEX used +8 → row1
 * reads zeros (sum=3). Module bake padded each row to 8 so INDEX matched
 * by accident. Tip: named i8/u8/bool→1, i16/u16→2; recurse nested arrays.
 * Authority twin of seeds/runtime_pipeline_abi.from_x.c; first-wins.
 */
#include <stdint.h>

extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ty_ref, uint8_t *out);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);

/**
 * Total bytes for TYPE_ARRAY [N]T with true-pack leaf widths.
 * @return 0 if not an array / invalid; else N * elem_stride.
 */
int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t ty_ref, int32_t depth) {
  int32_t n;
  int32_t elem;
  int32_t ek;
  int32_t esz;
  void *mod;
  uint8_t sn[64];
  int32_t sl;

  if (!arena || ty_ref <= 0 || depth > 8)
    return 0;
  ek = pipeline_type_kind_ord_at(arena, ty_ref);
  if (ek != 10)
    return 0;
  n = pipeline_type_array_size_at(arena, ty_ref);
  elem = pipeline_type_elem_ref_at(arena, ty_ref);
  if (n <= 0 || elem <= 0)
    return 0;
  ek = pipeline_type_kind_ord_at(arena, elem);
  if (ek == 10) {
    esz = glue_fixed_array_total_bytes_c(arena, elem, depth + 1);
    if (esz <= 0)
      return 0;
    return n * esz;
  }
  if (ek == 2 || ek == 1)
    esz = 1;
  else if (ek == 0 || ek == 3 || ek == 13 || ek == 14)
    esz = 4;
  else if (ek == 15 || ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 9 || ek == 18)
    esz = 8;
  else if (ek == 8) {
    /* True-pack named i8/i16/u16 (and byte-class u8/bool). PLATFORM: SHARED. */
    sl = pipeline_type_named_name_into(arena, elem, sn);
    if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8')
      esz = 1;
    else if (sl == 2 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'8')
      esz = 1;
    else if (sl == 4 && sn[0] == (uint8_t)'b' && sn[1] == (uint8_t)'o' &&
             sn[2] == (uint8_t)'o' && sn[3] == (uint8_t)'l')
      esz = 1;
    else if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      esz = 2;
    else if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      esz = 2;
    else {
      mod = pipeline_asm_emit_module_ref_c();
      if (mod) {
        esz = glue_type_size_simple(mod, arena, elem, 0);
        if (esz <= 0)
          esz = 8;
      } else {
        esz = 4;
      }
    }
  } else if (ek == 11) {
    esz = 16;
  } else {
    esz = 4;
  }
  return n * esz;
}
