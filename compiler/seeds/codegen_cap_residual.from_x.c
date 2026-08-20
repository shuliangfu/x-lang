/* seeds/codegen_cap_residual.from_x.c — wave323 M4 7.4.2 companions
 * Cap residual not emitted by tip codegen.x -E (host-call BSS, slice-let
 * reent finish, pipeline scratch/loop glue). Appended by assemble_codegen_gen_from_x.py.
 * G.7: residual TU only; business emit lives in codegen.x.
 * PLATFORM: SHARED freestanding codegen cold assemble companion.
 */

/* PLATFORM: SHARED host-C — formal type for next emit_call_arg_slice_abi (wave395). */
static int32_t g_codegen_host_call_arg_param_ty_ref = 0;
void codegen_set_host_call_arg_param_ty(int32_t param_ty_ref) {
  g_codegen_host_call_arg_param_ty_ref = param_ty_ref;
}
int32_t codegen_get_host_call_arg_param_ty(void) {
  return g_codegen_host_call_arg_param_ty_ref;
}
/* PLATFORM: SHARED host-C — unique id for call-site TYPE_ARRAY deep-copy temps
 * (__xlang_caN). wave397: dual CALL/METHOD T[N] as TYPE_SLICE formals must not
 * both alias callee __xlang_ar (last-wins). Mirror codegen.x. */
static int32_t g_codegen_host_call_array_tmp_id = 0;
int32_t codegen_next_host_call_array_tmp_id(void) {
  int32_t id = g_codegen_host_call_array_tmp_id;
  g_codegen_host_call_array_tmp_id = id + 1;
  if (g_codegen_host_call_array_tmp_id < 0) {
    g_codegen_host_call_array_tmp_id = 0;
  }
  return id;
}

/**
 * wave409 Cap residual pure: host-C TYPE_SLICE let from CALL/METHOD — frame deep-copy.
 * Root: callee `return [n,…]` uses function-static `__xlang_al` (wave341 durable).
 * `let s = mk(n); recurse(); use(s)` → all frames share one static → last-wins (walk 18≠36).
 * G.7: after `Type name` is already written, finish as:
 *   ; E __xlang_ldN[1024]; { S __xlang_spN = call; copy min(len,1024) into ld; name = fat(ld); }
 * Stack payload (auto, not static) is reentrancy-safe across recursive frames of the same let site.
 * Host twin of freestanding glue_slice_let_reent_deep_copy_after_dual_gp_elf_c.
 * Soft: length > 1024 truncates copy (same cap as wave406 call-arg). PLATFORM: SHARED host-C.
 * @return 0 success; -1 emit fail. Caller must only invoke when init is CALL/METHOD + TYPE_SLICE.
 */
int32_t codegen_emit_slice_let_reent_finish(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out,
                                             int32_t indent, uint8_t * name, int32_t name_len,
                                             int32_t let_type_ref, int32_t linit_ref,
                                             struct ast_PipelineDepCtx * ctx) {
  int32_t tid;
  int32_t elem_tr = 0;
  /* ";\n" — close uninit fat decl (Type name already emitted). */
  {
    uint8_t scnl[4] = {59, 10, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, scnl, 2) != 0)
      return -1;
  }
  tid = codegen_next_host_call_array_tmp_id();
  if (!(ast_ref_is_null(let_type_ref)) && let_type_ref > 0 && let_type_ref <= arena->num_types)
    elem_tr = pipeline_type_elem_ref_at(arena, let_type_ref);
  /* E __xlang_ldN[1024]; */
  if (codegen_emit_indent(out, indent) != 0)
    return -1;
  if (elem_tr <= 0 || codegen_emit_type(arena, out, elem_tr, ((uint8_t *)(0)), 0, ctx) != 0) {
    uint8_t fb_e[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0}; /* int32_t */
    if (codegen_emit_bytes_from_ptr(out, fb_e, 7) != 0)
      return -1;
  }
  {
    uint8_t ld_nm[14] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 108, 100, 0, 0, 0}; /*  __xlang_ld */
    if (codegen_emit_bytes_from_ptr(out, ld_nm, 11) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t ld_sz[12] = {91, 49, 48, 50, 52, 93, 59, 10, 0, 0, 0, 0}; /* [1024];\n */
    if (codegen_emit_bytes_from_ptr(out, ld_sz, 8) != 0)
      return -1;
  }
  /* { */
  if (codegen_emit_indent(out, indent) != 0)
    return -1;
  if (codegen_append_byte(out, 123) != 0) /* { */
    return -1;
  if (codegen_append_byte(out, 10) != 0)
    return -1;
  /* S __xlang_spN = <call>; */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  if (!(ast_ref_is_null(let_type_ref)) && let_type_ref > 0) {
    if (codegen_emit_type(arena, out, let_type_ref, ((uint8_t *)(0)), 0, ctx) != 0)
      return -1;
  } else {
    uint8_t fb[32] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105,
                      99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, fb, 26) != 0)
      return -1;
  }
  {
    uint8_t sp_nm[14] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0}; /*  __xlang_sp */
    if (codegen_emit_bytes_from_ptr(out, sp_nm, 11) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t eq[4] = {32, 61, 32, 0};
    if (codegen_emit_bytes_4(out, eq, 3) != 0)
      return -1;
  }
  if (codegen_emit_expr(arena, out, linit_ref, ctx) != 0)
    return -1;
  {
    uint8_t sc[4] = {59, 10, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, sc, 2) != 0)
      return -1;
  }
  /* size_t __xlang_snN = __xlang_spN.length; */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  {
    uint8_t sn_decl[28] = {115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115,
                           110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; /* size_t __xlang_sn */
    if (codegen_emit_bytes_from_ptr(out, sn_decl, 17) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t sn_eq[16] = {32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0}; /*  = __xlang_sp */
    if (codegen_emit_bytes_from_ptr(out, sn_eq, 13) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t sn_len[16] = {46, 108, 101, 110, 103, 116, 104, 59, 10, 0, 0, 0, 0, 0, 0, 0}; /* .length;\n */
    if (codegen_emit_bytes_from_ptr(out, sn_len, 9) != 0)
      return -1;
  }
  /* if (__xlang_snN > 1024) __xlang_snN = 1024; */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  {
    uint8_t if_h[20] = {105, 102, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0, 0, 0, 0}; /* if (__xlang_sn */
    if (codegen_emit_bytes_from_ptr(out, if_h, 14) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t if_m[28] = {32, 62, 32, 49, 48, 50, 52, 41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0, 0, 0, 0, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, if_m, 19) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t if_t[12] = {32, 61, 32, 49, 48, 50, 52, 59, 10, 0, 0, 0}; /*  = 1024;\n */
    if (codegen_emit_bytes_from_ptr(out, if_t, 9) != 0)
      return -1;
  }
  /* size_t __xlang_siN; for (__xlang_siN = 0; __xlang_siN < __xlang_snN; __xlang_siN++) */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  {
    uint8_t si_decl[28] = {115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115,
                           105, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; /* size_t __xlang_si */
    if (codegen_emit_bytes_from_ptr(out, si_decl, 17) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_h[12] = {59, 32, 102, 111, 114, 32, 40, 95, 95, 120, 108, 97}; /* ; for (__xla */
    uint8_t for_h2[8] = {110, 103, 95, 115, 105, 0, 0, 0}; /* ng_si */
    if (codegen_emit_bytes_from_ptr(out, for_h, 12) != 0)
      return -1;
    if (codegen_emit_bytes_from_ptr(out, for_h2, 5) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_m1[16] = {32, 61, 32, 48, 59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105}; /*  = 0; __xlang_si */
    if (codegen_emit_bytes_from_ptr(out, for_m1, 16) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_m2[16] = {32, 60, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0}; /*  < __xlang_sn */
    if (codegen_emit_bytes_from_ptr(out, for_m2, 13) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_m3[16] = {59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0}; /* ; __xlang_si */
    if (codegen_emit_bytes_from_ptr(out, for_m3, 12) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_body[20] = {43, 43, 41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 108, 100, 0, 0, 0, 0, 0, 0}; /* ++) __xlang_ld */
    if (codegen_emit_bytes_from_ptr(out, for_body, 14) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t idx_o[16] = {91, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0, 0}; /* [__xlang_si */
    if (codegen_emit_bytes_from_ptr(out, idx_o, 11) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t copy_m[20] = {93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0, 0, 0, 0}; /* ] = __xlang_sp */
    if (codegen_emit_bytes_from_ptr(out, copy_m, 14) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t data_i[24] = {46, 100, 97, 116, 97, 91, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0, 0, 0, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, data_i, 16) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t after[8] = {93, 59, 10, 0, 0, 0, 0, 0}; /* ];\n */
    if (codegen_emit_bytes_from_ptr(out, after, 3) != 0)
      return -1;
  }
  /* name = (S){ .data = __xlang_ldN, .length = __xlang_spN.length }; */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  if (name_len > 0 && name != ((uint8_t *)(0))) {
    if (codegen_emit_bytes_64(out, name, name_len) != 0)
      return -1;
  } else {
    uint8_t fb_nm[4] = {95, 108, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, fb_nm, 2) != 0)
      return -1;
  }
  {
    uint8_t eq[4] = {32, 61, 32, 0};
    if (codegen_emit_bytes_4(out, eq, 3) != 0)
      return -1;
  }
  if (codegen_append_byte(out, 40) != 0) /* ( */
    return -1;
  if (!(ast_ref_is_null(let_type_ref)) && let_type_ref > 0) {
    if (codegen_emit_type(arena, out, let_type_ref, ((uint8_t *)(0)), 0, ctx) != 0)
      return -1;
  } else {
    uint8_t fb[32] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105,
                      99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, fb, 26) != 0)
      return -1;
  }
  {
    uint8_t fat_mid[28] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97,
                           110, 103, 95, 108, 100, 0, 0, 0, 0, 0, 0, 0}; /* ){ .data = __xlang_ld */
    if (codegen_emit_bytes_from_ptr(out, fat_mid, 21) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t len_asg[28] = {44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 95, 95, 120, 108,
                           97, 110, 103, 95, 115, 110, 0, 0, 0, 0, 0, 0}; /* , .length = __xlang_sn */
    if (codegen_emit_bytes_from_ptr(out, len_asg, 22) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t end_fat[16] = {32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; /*  };\n */
    if (codegen_emit_bytes_from_ptr(out, end_fat, 4) != 0)
      return -1;
  }
  /* } */
  if (codegen_emit_indent(out, indent) != 0)
    return -1;
  if (codegen_append_byte(out, 125) != 0)
    return -1;
  if (codegen_append_byte(out, 10) != 0)
    return -1;
  return 0;
}

/* ============================================================================
 * 8.3.2 host-cc leave: pipeline_scratch_bufs.c retired from pipeline_x mega-TU.
 * Live path/prefix scratch buffer accessors live here in codegen_x.o.
 * Mangled thin faces (codegen_pipeline_scratch_buf64* / ast_pipeline_scratch_buf*)
 * remain in pipeline_x host-cc forwarders and call these symbols.
 * PLATFORM: SHARED — BSS only; no business logic; G.7 single authority pools.
 * ============================================================================ */

/** codegen path/prefix scratch (avoid `u8[N] = []` ExprKind=-1 under asm emit). */
static uint8_t g_pipeline_scratch64[4][128];
static uint8_t g_pipeline_scratch128[2][128];
static uint8_t g_pipeline_scratch256[2][256];

uint8_t *pipeline_scratch_buf64(void) {
  return g_pipeline_scratch64[0];
}

uint8_t *pipeline_scratch_buf64_slot(int32_t slot) {
  if (slot < 0 || slot >= 4)
    return g_pipeline_scratch64[0];
  return g_pipeline_scratch64[slot];
}

uint8_t *pipeline_scratch_buf128(void) {
  return g_pipeline_scratch128[0];
}

uint8_t *pipeline_scratch_buf128_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_pipeline_scratch128[0];
  return g_pipeline_scratch128[slot];
}

uint8_t *pipeline_scratch_buf96(void) {
  static uint8_t s[96];
  return s;
}

uint8_t *pipeline_scratch_buf256(void) {
  return g_pipeline_scratch256[0];
}

uint8_t *pipeline_scratch_buf256_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_pipeline_scratch256[0];
  return g_pipeline_scratch256[slot];
}

/* ============================================================================
 * 8.3.2 host-cc leave: pipeline_loop_glue.c retired from pipeline_x mega-TU.
 * Live bounded-loop predicates + one_dep prepare glue live here in codegen_x.o.
 * Callers (pipeline.x / pipeline_gen / runtime_pipeline_abi) already extern these
 * `*_c` faces; they U-resolve from pipeline_x / other TUs into codegen_x.
 * Callees (dep_ctx_ndep / lib_root_count / prepare_dep_codegen_path_c /
 * parser_get_module_num_imports) stay in pipeline_x / parser_x and link back.
 * PLATFORM: SHARED — thin glue only; G.7 single authority for these faces.
 * ============================================================================ */

extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern int32_t pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
extern int32_t pipeline_prepare_dep_codegen_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                                   uint8_t *dst);

/**
 * Bounded loop continue: return 1 while idx < ndep.
 * X while bare CALL predicate (do not emit CALL==0 compare).
 */
int32_t pipeline_loop_should_continue_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * Bounded import loop continue: return 1 while idx < num_imports.
 */
int32_t pipeline_loop_should_continue_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 0;
  return idx < parser_get_module_num_imports(module) ? 1 : 0;
}

/**
 * Bounded lib_root loop continue: return 1 while idx < lib_root_count.
 */
int32_t pipeline_loop_should_continue_lib_root_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_ctx_lib_root_count(ctx) ? 1 : 0;
}

/**
 * Bounded loop exit: return 1 when idx >= ndep (X if(CALL!=0)).
 */
int32_t pipeline_loop_index_at_or_beyond_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 1;
  return idx >= pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * Bounded import loop exit: return 1 when idx >= num_imports.
 */
int32_t pipeline_loop_index_at_or_beyond_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 1;
  return idx >= parser_get_module_num_imports(module) ? 1 : 0;
}

/** After import loop: write ndep from module import count (C glue; no dual CALL in X stmt). */
void pipeline_load_and_sync_set_ndep_from_module_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  if (module && ctx)
    pipeline_dep_ctx_set_ndep(ctx, parser_get_module_num_imports(module));
}

/**
 * one_dep codegen prepare path prefix (C glue; X side u8[64] stack array issue).
 * Zeros a 128-byte scratch then calls pipeline_prepare_dep_codegen_path_c.
 */
int32_t run_x_pipeline_codegen_one_dep_prepare_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  uint8_t dep_path_buf[128];
  int32_t i;

  if (!ctx || dep_j < 0)
    return -1;
  /* Avoid string.h memset macros in this seed (see codegen string.h clash notes). */
  for (i = 0; i < 128; i++)
    dep_path_buf[i] = 0;
  return pipeline_prepare_dep_codegen_path_c(ctx, dep_j, dep_path_buf);
}
