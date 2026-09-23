/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

int32_t typeck_struct_layouts_same_shape_c(void *m, void *a, int32_t la, int32_t lb) {
  int32_t nfa, nfb, j;
  if (!m || !a || la < 0 || lb < 0) return 0;
  nfa = pipeline_module_struct_layout_num_fields(m, la);
  nfb = pipeline_module_struct_layout_num_fields(m, lb);
  if (nfa != nfb || nfa <= 0) return 0;
  for (j = 0; j < nfa; j++) {
    if (pipeline_module_struct_layout_field_offset_at(m, la, j) !=
        pipeline_module_struct_layout_field_offset_at(m, lb, j))
      return 0;
    if (!pipeline_typeck_type_refs_equal_c(a,
          pipeline_module_struct_layout_field_type_ref(m, la, j),
          pipeline_module_struct_layout_field_type_ref(m, lb, j)))
      return 0;
  }
  return 1;
}

static int w154_pad_enabled(void) {
  const char *e = link_abi_getenv("XLANG_PAD_FIELDS");
  return e && e[0] == '1' && e[1] == '\0';
}
static int w154_hot_enabled(void) {
  const char *e = link_abi_getenv("XLANG_HOT_REORDER");
  return e && e[0] == '1' && e[1] == '\0';
}
static int w154_atomic(void *m, void *a, int32_t ftr) {
  int32_t sz;
  if (!m || !a || ftr <= 0) return 0;
  sz = glue_type_size_simple(m, a, ftr, 0);
  return sz == 4 || sz == 8;
}

void pipeline_typeck_pad_fields_warn_layout(void *module, void *arena, int32_t li) {
  int32_t nf, j, layout_nlen;
  uint8_t layout_nm[256];
  if (!w154_pad_enabled() || !module || !arena || li < 0) return;
  nf = pipeline_module_struct_layout_num_fields(module, li);
  if (nf < 2) return;
  layout_nlen = pipeline_module_struct_layout_name_len(module, li);
  pipeline_module_struct_layout_name_into(module, li, layout_nm);
  for (j = 0; j + 1 < nf; j++) {
    int32_t off0 = pipeline_module_struct_layout_field_offset_at(module, li, j);
    int32_t off1 = pipeline_module_struct_layout_field_offset_at(module, li, j + 1);
    int32_t ftr0 = pipeline_module_struct_layout_field_type_ref(module, li, j);
    int32_t ftr1 = pipeline_module_struct_layout_field_type_ref(module, li, j + 1);
    int32_t al0 = pipeline_module_struct_layout_field_align_at(module, li, j);
    int32_t al1 = pipeline_module_struct_layout_field_align_at(module, li, j + 1);
    uint8_t fn0[256], fn1[256];
    int32_t fl0, fl1;
    if (al0 >= 64 || al1 >= 64) continue;
    if (off0 / 64 != off1 / 64) continue;
    if (!w154_atomic(module, arena, ftr0) && !w154_atomic(module, arena, ftr1)) continue;
    pipeline_module_struct_layout_field_name_into(module, li, j, fn0);
    pipeline_module_struct_layout_field_name_into(module, li, j + 1, fn1);
    fl0 = pipeline_module_struct_layout_field_name_len(module, li, j);
    fl1 = pipeline_module_struct_layout_field_name_len(module, li, j + 1);
    driver_diagnostic_warn_pad_fields_same_cache_line(layout_nm, layout_nlen, fn0, fl0, fn1, fl1);
  }
}

void pipeline_typeck_hot_reorder_warn_layout(void *module, void *arena, int32_t li) {
  int32_t nf, j, i, layout_nlen;
  uint8_t layout_nm[256];
  if (!w154_hot_enabled() || !module || !arena || li < 0) return;
  nf = pipeline_module_struct_layout_num_fields(module, li);
  if (nf < 2) return;
  layout_nlen = pipeline_module_struct_layout_name_len(module, li);
  pipeline_module_struct_layout_name_into(module, li, layout_nm);
  for (j = 1; j < nf; j++) {
    int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
    int32_t sz = glue_type_size_simple(module, arena, ftr, 0);
    if (sz <= 0 || sz > 4) continue;
    for (i = 0; i < j; i++) {
      int32_t ftr_c = pipeline_module_struct_layout_field_type_ref(module, li, i);
      int32_t sz_c = glue_type_size_simple(module, arena, ftr_c, 0);
      if (sz_c >= 8) {
        uint8_t hot_nm[256], cold_nm[256];
        int32_t hot_len, cold_len;
        pipeline_module_struct_layout_field_name_into(module, li, j, hot_nm);
        pipeline_module_struct_layout_field_name_into(module, li, i, cold_nm);
        hot_len = pipeline_module_struct_layout_field_name_len(module, li, j);
        cold_len = pipeline_module_struct_layout_field_name_len(module, li, i);
        driver_diagnostic_warn_hot_reorder_field(layout_nm, layout_nlen, hot_nm, hot_len, cold_nm, cold_len);
        break;
      }
    }
  }
}


/*
 * wave155 cold twins: fold_count_up_while pure-owned leave.
 * Public faces: try_fold + while/for/body sync + thin wrappers + skip_heavy +
 * ctx push/pop loop labels. Cold stubs freestanding-safe (no fold / emit fail).
 * Hybrid product links pure .o (FROM_X set). PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

int32_t backend_try_fold_count_up_while_elf(void *arena, void *elf_ctx, int32_t block_ref, int32_t loop_idx,
                                            void *ctx, int32_t ta) {
  (void)arena; (void)elf_ctx; (void)block_ref; (void)loop_idx; (void)ctx; (void)ta;
  return 0; /* no fold in pure-less cold */
}

int32_t backend_emit_loop_body_content_elf_sync(void *arena, void *elf_ctx, int32_t body_ref, void *ctx, int32_t ta) {
  (void)arena; (void)elf_ctx; (void)body_ref; (void)ctx; (void)ta;
  return -1;
}

int32_t backend_emit_while_loop_elf_sync(void *arena, void *elf_ctx, int32_t block_ref, int32_t loop_idx, void *ctx,
                                        int32_t ta) {
  (void)arena; (void)elf_ctx; (void)block_ref; (void)loop_idx; (void)ctx; (void)ta;
  return -1;
}

int32_t backend_emit_for_loop_elf_sync(void *arena, void *elf_ctx, int32_t block_ref, int32_t for_idx, void *ctx,
                                      int32_t ta) {
  (void)arena; (void)elf_ctx; (void)block_ref; (void)for_idx; (void)ctx; (void)ta;
  return -1;
}

int32_t pipeline_asm_emit_while_loop_elf_c(void *arena, void *elf_ctx, int32_t block_ref, int32_t loop_idx, void *ctx,
                                          int32_t ta) {
  return backend_emit_while_loop_elf_sync(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
}

int32_t pipeline_asm_emit_for_loop_elf_c(void *arena, void *elf_ctx, int32_t block_ref, int32_t for_idx, void *ctx,
                                        int32_t ta) {
  return backend_emit_for_loop_elf_sync(arena, elf_ctx, block_ref, for_idx, ctx, ta);
}

int32_t pipeline_asm_emit_loop_body_content_elf_c(void *arena, void *elf_ctx, int32_t body_ref, void *ctx, int32_t ta) {
  return backend_emit_loop_body_content_elf_sync(arena, elf_ctx, body_ref, ctx, ta);
}

int32_t pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(void *elf_ctx, int32_t ta, void *mod, int32_t func_index) {
  (void)elf_ctx; (void)ta; (void)mod; (void)func_index;
  return -1;
}

int32_t backend_ctx_push_loop_labels(void *ctx, uint8_t *exit_buf, int32_t exit_len, uint8_t *loop_buf,
                                    int32_t loop_len) {
  (void)ctx; (void)exit_buf; (void)exit_len; (void)loop_buf; (void)loop_len;
  return -1;
}

void backend_ctx_pop_loop_labels(void *ctx) {
  (void)ctx;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/*
 * wave156 cold twins: spill pure-owned cohesive slices (INDEX assign cache +
 * bulk_mem + finish/load/hit/try + enc_swap + assign_like + kill_lhs).
 * Freestanding-safe stubs. Hybrid product links pure. PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

void glue_index_assign_addr_cache_clear(void) {}

int32_t glue_index_assign_addr_cache_hit(void *arena, void *ctx, int32_t base_ref, int32_t idx_ref, int32_t esz) {
  (void)arena; (void)ctx; (void)base_ref; (void)idx_ref; (void)esz;
  return 0;
}

int32_t glue_emit_bulk_mem_copy_spills_elf_c(void *elf_ctx, int32_t src_spill, int32_t dst_spill, int32_t esz, int32_t ta) {
  (void)elf_ctx; (void)src_spill; (void)dst_spill; (void)esz; (void)ta;
  return -1;
}

int32_t glue_index_assign_finish_store_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t base_ref, int32_t idx_ref,
                                            int32_t esz, int32_t ta) {
  (void)arena; (void)elf_ctx; (void)ctx; (void)base_ref; (void)idx_ref; (void)esz; (void)ta;
  return -1;
}

int32_t glue_index_load_from_cached_assign_addr_elf_c(void *elf_ctx, int32_t esz, int32_t ta) {
  (void)elf_ctx; (void)esz; (void)ta;
  return -1;
}

int32_t glue_try_block_let_index_init_from_assign_cache_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t init_ref,
                                                             int32_t ta) {
  (void)arena; (void)elf_ctx; (void)ctx; (void)init_ref; (void)ta;
  return 0;
}

int32_t glue_enc_swap_rax_rbx_arm64_elf_c(void *elf_ctx, int32_t ta) {
  (void)elf_ctx; (void)ta;
  return 0;
}

#endif /* close wave156 FROM_X for leftover-PE assign_like unique */
