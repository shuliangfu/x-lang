/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/* WAVE276_ARENA_DOMAIN_COLD already 1; remaining arena cold twins continue. */

int implicit_tail_expr_disallowed_by_glue(void *a, int32_t expr_ref) {
  uint8_t *ex;
  int32_t ne, k;
  if (!a || expr_ref <= 0)
    return 1;
  ne = w276_load_i32((uint8_t *)a, 4);
  if (expr_ref > ne)
    return 1;
  ex = (uint8_t *)pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return 1;
  k = w276_load_i32(ex, 0);
  if (k == 39 || k == 40 || k == 41 || k == 42)
    return 1;
  return 0;
}
void pipeline_module_fill_u8_64_from_src_c(uint8_t *dst, const uint8_t *src, int32_t n, int32_t src_cap) {
  int32_t i;
  if (!dst)
    return;
  if (n < 0)
    n = 0;
  if (src_cap < 0)
    src_cap = 0;
  for (i = 0; i < 64; i++) {
    if (src && i < n && i < src_cap)
      dst[i] = src[i];
    else
      dst[i] = 0;
  }
}

/* Parser library init cold (mirror pure) */
void pipeline_parser_library_init_bool_type_c(void *arena, int32_t type_ref) {
  uint8_t *t;
  if (!arena || type_ref <= 0)
    return;
  t = (uint8_t *)pipeline_arena_type_ptr(arena, type_ref);
  if (!t)
    return;
  w276_store_i32(t, 0, 1);
  w276_store_i32(t, 132, 0);
  w276_store_i32(t, 136, 0);
  w276_store_i32(t, 140, 0);
}
void pipeline_parser_library_init_named_type_c(void *arena, int32_t type_ref, const uint8_t *name, int32_t name_len) {
  uint8_t *t;
  if (!arena || type_ref <= 0)
    return;
  t = (uint8_t *)pipeline_arena_type_ptr(arena, type_ref);
  if (!t)
    return;
  w276_store_i32(t, 0, 8);
  w276_store_i32(t, 132, name_len);
  pipeline_module_fill_u8_64_from_src_c(t + 4, name, name_len, 64);
  w276_store_i32(t, 136, 0);
  w276_store_i32(t, 140, 0);
}
void pipeline_parser_library_init_var_expr_c(void *arena, int32_t expr_ref, int32_t type_ref, const uint8_t *param_name, int32_t param_name_len) {
  uint8_t *ve;
  if (!arena || expr_ref <= 0)
    return;
  ve = (uint8_t *)pipeline_arena_expr_ptr(arena, expr_ref);
  if (!ve)
    return;
  w276_store_i32(ve, 0, 3);
  w276_store_i32(ve, 4, type_ref);
  w276_store_i32(ve, 8, 0);
  w276_store_i32(ve, 12, 0);
  w276_store_i32(ve, 160, param_name_len);
  pipeline_module_fill_u8_64_from_src_c(ve + 32, param_name, param_name_len, 32);
  w276_store_i32(ve, 196, 0);
  w276_store_i32(ve, 692, 0);
  w276_store_i32(ve, 204, 0);
  w276_store_i32(ve, 336, 0);
  w276_store_i32(ve, 340, 0);
  w276_store_i32(ve, 344, 0);
}
void pipeline_parser_library_init_field_access_expr_c(void *arena, int32_t expr_ref, int32_t base_ref, const uint8_t *field_name, int32_t field_len) {
  uint8_t *fe;
  if (!arena || expr_ref <= 0)
    return;
  fe = (uint8_t *)pipeline_arena_expr_ptr(arena, expr_ref);
  if (!fe)
    return;
  w276_store_i32(fe, 0, 44);
  w276_store_i32(fe, 4, 0);
  w276_store_i32(fe, 8, 0);
  w276_store_i32(fe, 12, 0);
  w276_store_i32(fe, 204, base_ref);
  w276_store_i32(fe, 336, field_len);
  pipeline_module_fill_u8_64_from_src_c(fe + 208, field_name, field_len, 64);
  w276_store_i32(fe, 340, 0);
  w276_store_i32(fe, 344, 0);
  w276_store_i32(fe, 196, 0);
  w276_store_i32(fe, 692, 0);
  w276_store_i32(fe, 164, 0);
  w276_store_i32(fe, 168, 0);
}
void pipeline_parser_library_init_enum_variant_expr_c(void *arena, int32_t expr_ref) {
  uint8_t *ene;
  if (!arena || expr_ref <= 0)
    return;
  ene = (uint8_t *)pipeline_arena_expr_ptr(arena, expr_ref);
  if (!ene)
    return;
  w276_store_i32(ene, 0, 50);
  w276_store_i32(ene, 4, 0);
  w276_store_i32(ene, 8, 0);
  w276_store_i32(ene, 12, 0);
  w276_store_i32(ene, 692, 0);
  w276_store_i32(ene, 196, 0);
  w276_store_i32(ene, 204, 0);
  w276_store_i32(ene, 336, 0);
}
void pipeline_parser_library_init_eq_expr_c(void *arena, int32_t expr_ref, int32_t bool_type_ref, int32_t left_ref, int32_t right_ref) {
  uint8_t *eqe;
  if (!arena || expr_ref <= 0)
    return;
  eqe = (uint8_t *)pipeline_arena_expr_ptr(arena, expr_ref);
  if (!eqe)
    return;
  w276_store_i32(eqe, 0, 14);
  w276_store_i32(eqe, 4, bool_type_ref);
  w276_store_i32(eqe, 8, 0);
  w276_store_i32(eqe, 12, 0);
  w276_store_i32(eqe, 164, left_ref);
  w276_store_i32(eqe, 168, right_ref);
  w276_store_i32(eqe, 196, 0);
  w276_store_i32(eqe, 692, 0);
  w276_store_i32(eqe, 204, 0);
  w276_store_i32(eqe, 336, 0);
}
int32_t pipeline_parser_library_init_labeled_block_c(void *arena, int32_t block_ref, int32_t eq_ref) {
  uint8_t *b;
  if (!arena || block_ref <= 0)
    return -1;
  b = (uint8_t *)pipeline_arena_block_ptr(arena, block_ref);
  if (!b)
    return -1;
  w276_store_i32(b, 4, 0);
  w276_store_i32(b, 12, 0);
  w276_store_i32(b, 16, 0);
  w276_store_i32(b, 24, 0);
  w276_store_i32(b, 32, 0);
  w276_store_i32(b, 40, 0);
  w276_store_i32(b, 56, 0);
  if (ast_pipeline_block_append_labeled(arena, block_ref, 0, 0, 0, eq_ref) < 0)
    return -1;
  b = (uint8_t *)pipeline_arena_block_ptr(arena, block_ref);
  if (!b)
    return -1;
  w276_store_i32(b, 72, 0);
  w276_store_i32(b, 76, 0);
  w276_store_i32(b, 84, 0);
  return 0;
}
int32_t pipeline_parser_extern_init_arena_func_and_register_c(void *arena, void *module, int32_t func_ref,
                                                             const uint8_t *name, int32_t name_len,
                                                             int32_t num_params, int32_t return_ty_ref) {
  uint8_t *fp;
  int32_t fi;
  if (!arena || !module || func_ref <= 0)
    return -1;
  if (name_len < 0 || name_len > 255)
    return -1;
  fp = (uint8_t *)pipeline_arena_func_ptr(arena, func_ref);
  if (!fp)
    return -1;
  pipeline_module_fill_u8_64_from_src_c(fp, name, name_len, 64);
  w276_store_i32(fp, 128, name_len);
  w276_store_i32(fp, 136, num_params);
  w276_store_i32(fp, 144, return_ty_ref);
  w276_store_i32(fp, 148, 0);
  w276_store_i32(fp, 152, 0);
  w276_store_i32(fp, 156, 1);
  w276_store_i32(fp, 160, 0);
  fi = pipeline_module_func_alloc_slot(module);
  if (fi < 0)
    return -1;
  pipeline_module_func_name_write(module, fi, (uint8_t *)name, name_len);
  pipeline_module_func_set_num_params(module, fi, num_params);
  pipeline_module_func_set_return_type(module, fi, return_ty_ref);
  pipeline_module_func_set_body_ref(module, fi, 0);
  pipeline_module_func_set_body_expr_ref(module, fi, 0);
  pipeline_module_func_set_is_extern(module, fi, 1);
  pipeline_module_func_set_is_async(module, fi, 0);
  pipeline_module_func_ref_set(module, fi, func_ref);
  return fi;
}

