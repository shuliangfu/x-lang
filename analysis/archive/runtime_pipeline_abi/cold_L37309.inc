/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

int32_t typeck_typeck_struct_layout_metrics(void *module, void *arena, int32_t li, int32_t depth, int32_t check_pad, int32_t *out_sz, int32_t *out_al) {
  return glue_struct_layout_metrics_c(module, arena, li, depth, check_pad, out_sz, out_al);
}

int32_t glue_struct_layout_compute_field_offset_c(void *m, void *a, int32_t li, int32_t fj) {
  int32_t current = 0, j, nf, nlayouts, ftr, A, fa, rem, gap, fsize;
  if (!m || !a || li < 0 || fj < 0) return fj >= 0 ? fj * 8 : 0;
  nlayouts = pipeline_module_num_struct_layouts_at(m);
  if (li >= nlayouts) return fj * 8;
  nf = pipeline_module_struct_layout_num_fields(m, li);
  if (fj >= nf) return fj * 8;
  for (j = 0; j <= fj; j++) {
    ftr = pipeline_module_struct_layout_field_type_ref(m, li, j);
    A = glue_type_align_simple(m, a, ftr, 0);
    if (A <= 0) A = 1;
    fa = pipeline_module_struct_layout_field_align_at(m, li, j);
    if (fa > A) A = fa;
    rem = current % A; gap = (A - rem) % A;
    if (j == fj) return current + gap;
    current += gap;
    fsize = glue_type_size_simple(m, a, ftr, 0);
    if (fsize < 0 || (fsize == 0 && glue_type_is_empty_struct_c(m, a, ftr, 0) == 0)) fsize = 4;
    current += fsize;
  }
  return fj * 8;
}

int32_t glue_struct_layout_index_by_type_name_c(void *m, uint8_t *struct_name, int32_t nlen) {
  int32_t k, nlayouts;
  if (!m || !struct_name || nlen <= 0 || nlen > 255) return -1;
  nlayouts = pipeline_module_num_struct_layouts_at(m);
  for (k = 0; k < nlayouts; k++)
    if (w154_layout_name_eq(m, k, struct_name, nlen)) return k;
  if (nlayouts == 1) return 0;
  return -1;
}

void glue_sync_struct_layout_field_offsets_c(void *m, void *a) {
  int32_t li, nf, j, off, nlayouts;
  if (!m || !a) return;
  nlayouts = pipeline_module_num_struct_layouts_at(m);
  for (li = 0; li < nlayouts; li++) {
    nf = pipeline_module_struct_layout_num_fields(m, li);
    for (j = 0; j < nf; j++) {
      off = glue_struct_layout_compute_field_offset_c(m, a, li, j);
      pipeline_module_struct_layout_set_field_offset(m, li, j, off);
    }
  }
}

int32_t pipeline_expr_struct_lit_num_fields(void *a, int32_t expr_ref) {
  uint8_t *ex;
  if (!a || expr_ref <= 0) return 0;
  ex = (uint8_t *)glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) return 0;
  return *(int32_t *)(ex + W154_EXPR_OFF_SL_NUM_FIELDS);
}

int32_t pipeline_expr_struct_lit_type_name_len(void *a, int32_t expr_ref) {
  uint8_t *ex;
  if (!a || expr_ref <= 0) return 0;
  ex = (uint8_t *)glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) return 0;
  return *(int32_t *)(ex + W154_EXPR_OFF_SL_NAME_LEN);
}

void pipeline_expr_struct_lit_type_name_into(void *a, int32_t expr_ref, uint8_t *out64) {
  uint8_t *ex;
  if (!out64) return;
  ex = (uint8_t *)glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) { memset(out64, 0, 256); return; }
  memcpy(out64, ex + W154_EXPR_OFF_SL_NAME, 256);
}

void pipeline_expr_struct_lit_type_name_set(void *a, int32_t expr_ref, uint8_t *name, int32_t name_len) {
  uint8_t *ex;
  int32_t nexprs;
  if (!a || !name || expr_ref <= 0 || name_len < 0 || name_len > 255) return;
  nexprs = *(int32_t *)((uint8_t *)a + 4); /* num_exprs@4 */
  if (expr_ref > nexprs) return;
  ex = (uint8_t *)glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) return;
  memset(ex + W154_EXPR_OFF_SL_NAME, 0, 256);
  if (name_len > 0) memcpy(ex + W154_EXPR_OFF_SL_NAME, name, (size_t)name_len);
  *(int32_t *)(ex + W154_EXPR_OFF_SL_NAME_LEN) = name_len;
}

int32_t pipeline_expr_struct_lit_field_offset_at(void *a, void *m, int32_t expr_ref, int32_t field_ix) {
  int32_t nlen, k, nf, nlayouts;
  uint8_t name[256];
  if (!a || !m || expr_ref <= 0 || field_ix < 0) return field_ix * 8;
  if (pipeline_expr_kind_ord_at(a, expr_ref) != 45) return field_ix * 8;
  nlen = pipeline_expr_struct_lit_type_name_len(a, expr_ref);
  if (nlen <= 0 || nlen > 255) {
    nlayouts = pipeline_module_num_struct_layouts_at(m);
    nf = pipeline_module_struct_layout_num_fields(m, 0);
    if (nlayouts == 1 && field_ix < nf)
      return glue_struct_layout_compute_field_offset_c(m, a, 0, field_ix);
    return field_ix * 8;
  }
  pipeline_expr_struct_lit_type_name_into(a, expr_ref, name);
  k = glue_struct_layout_index_by_type_name_c(m, name, nlen);
  if (k >= 0) {
    nf = pipeline_module_struct_layout_num_fields(m, k);
    if (field_ix < nf) return glue_struct_layout_compute_field_offset_c(m, a, k, field_ix);
  }
  return field_ix * 8;
}

int32_t pipeline_expr_struct_lit_field_type_ref_at(void *a, void *m, int32_t expr_ref, int32_t field_ix) {
  int32_t nlen, k, nlayouts, nf;
  uint8_t name[256];
  if (!a || !m || expr_ref <= 0 || field_ix < 0) return 0;
  if (pipeline_expr_kind_ord_at(a, expr_ref) != 45) return 0;
  nlen = pipeline_expr_struct_lit_type_name_len(a, expr_ref);
  if (nlen <= 0 || nlen > 255) return 0;
  pipeline_expr_struct_lit_type_name_into(a, expr_ref, name);
  nlayouts = pipeline_module_num_struct_layouts_at(m);
  for (k = 0; k < nlayouts; k++) {
    if (!w154_layout_name_eq(m, k, name, nlen)) continue;
    nf = pipeline_module_struct_layout_num_fields(m, k);
    if (field_ix < nf) return pipeline_module_struct_layout_field_type_ref(m, k, field_ix);
    return 0;
  }
  return 0;
}

int32_t pipeline_expr_struct_lit_value_bytes(void *a, void *m, int32_t expr_ref) {
  int32_t nlen, k, nlayouts, sz_out, al_out;
  uint8_t name[256];
  if (!a || !m || expr_ref <= 0) return 0;
  if (pipeline_expr_kind_ord_at(a, expr_ref) != 45) return 0;
  nlen = pipeline_expr_struct_lit_type_name_len(a, expr_ref);
  if (nlen <= 0 || nlen > 255) return 0;
  pipeline_expr_struct_lit_type_name_into(a, expr_ref, name);
  nlayouts = pipeline_module_num_struct_layouts_at(m);
  for (k = 0; k < nlayouts; k++) {
    if (!w154_layout_name_eq(m, k, name, nlen)) continue;
    sz_out = 0; al_out = 1;
    if (glue_struct_layout_metrics_c(m, a, k, 0, 0, &sz_out, &al_out) != 0) return 0;
    return sz_out > 0 ? sz_out : 0;
  }
  return 0;
}

int32_t glue_struct_lit_rehome_dest_rbx_elf_c(void *elf_ctx, int32_t rehome_off, int32_t ta) {
  (void)elf_ctx; (void)rehome_off; (void)ta;
  /* Cold without pure: not freestanding product path after wave154. */
  return -1;
}

int32_t pipeline_asm_emit_struct_lit_fields_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta, int32_t stack_slot_off) {
  (void)arena; (void)elf_ctx; (void)expr_ref; (void)ctx; (void)ta; (void)stack_slot_off;
  /* Cold without pure: freestanding STRUCT_LIT emit requires pure hybrid. */
  return -1;
}

int32_t pipeline_asm_emit_struct_lit_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, expr_ref, ctx, ta, -1);
}

