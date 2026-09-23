/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

/* WPO_DUMP_CALLGRAPH — cold seed twin of runtime_pipeline_abi_wpo_dump_thin.x.
 * Gated by XLANG_WPO_DUMP_CALLGRAPH. PLATFORM: SHARED.
 * Cap residual 9.7.1: face open returns an opaque fd handle (uint8_t *). */
extern uint8_t *xlang_driver_fopen_write_opaque(uint8_t *path);
extern int32_t xlang_driver_fwrite_opaque(const void *data, int32_t len, void *stream);
extern int32_t xlang_driver_fclose_opaque(void *stream);
extern int32_t xlang_driver_fwrite_stdout_n(const void *data, int32_t len);
extern int32_t pipeline_module_func_is_export_at(void *m, int32_t fi);
extern int32_t pipeline_expr_call_resolved_func_index_at(void *a, int32_t er);
extern int32_t pipeline_expr_call_callee_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_call_num_args_at(void *a, int32_t er);
extern int32_t pipeline_expr_call_arg_ref(void *a, int32_t er, int32_t idx);
extern int32_t pipeline_expr_method_call_name_len(void *a, int32_t er);
extern void pipeline_expr_method_call_name_into(void *a, int32_t er, uint8_t *out64);
extern int32_t pipeline_expr_method_call_num_args_at(void *a, int32_t er);
extern int32_t pipeline_expr_method_call_arg_ref(void *a, int32_t er, int32_t idx);
extern int32_t pipeline_expr_method_call_base_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_unary_operand_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_binop_left_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_binop_right_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_if_cond_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_if_then_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_if_else_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_block_ref_at(void *a, int32_t er);
extern int32_t ast_ast_block_num_expr_stmts(void *a, int32_t br);
extern int32_t ast_pipeline_block_expr_stmt_ref(void *a, int32_t br, int32_t ei);
extern int32_t ast_ast_block_final_expr_ref(void *a, int32_t br);
extern int32_t pipeline_module_func_body_expr_ref_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern void pipeline_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, const uint8_t *name, int32_t nlen);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* Host-C cold path: thin inject owns product; this twin covers !FROM_X boots.
 * Deliberately minimal: getenv + face open + bounded writes, empty-reachable-safe
 * graph via name-based mark (same shape as unused_private used[]). Full thin is
 * authority. Cap residual 9.7.1: fp is an opaque fd handle. */
int32_t pipeline_typeck_wpo_dump_callgraph(void *m, void *a, void *ctx) {
  const char *path;
  uint8_t *fp = NULL;
  int use_stdout = 0;
  int32_t nfuncs, fi, root = -1, nlen, is_ext;
  uint8_t *reach = NULL;
  uint8_t *called = NULL;
  uint8_t name[256];
  int first;
  (void)ctx;
  if (!m || !a) return 0;
  path = link_abi_getenv("XLANG_WPO_DUMP_CALLGRAPH");
  if (!path || !path[0]) return 0;
  if (path[0] == '-' && path[1] == '\0') use_stdout = 1;
  else {
    fp = xlang_driver_fopen_write_opaque((uint8_t *)path);
    if (!fp) return 0;
  }
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs <= 0) {
    if (fp) xlang_driver_fclose_opaque(fp);
    return 0;
  }
  reach = (uint8_t *)calloc((size_t)nfuncs, 1);
  called = (uint8_t *)calloc((size_t)nfuncs, 1);
  if (!reach || !called) {
    free(reach); free(called);
    if (fp) xlang_driver_fclose_opaque(fp);
    return 0;
  }
  /* Reuse L7 name-mark: any CALL/METHOD target name in arena. */
  wave121_mark_local_call_names(a, called, nfuncs, m);
  for (fi = 0; fi < nfuncs; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, (const uint8_t *)"main", 4)) {
      root = fi; break;
    }
  }
  if (root < 0) {
    for (fi = 0; fi < nfuncs; fi++) {
      if (pipeline_module_func_name_equal_at(m, fi, (const uint8_t *)"entry", 5)) {
        root = fi; break;
      }
    }
  }
  if (root < 0) root = 0;
  reach[root] = 1;
  for (fi = 0; fi < nfuncs; fi++) {
    if (called[fi]) reach[fi] = 1;
    if (pipeline_module_func_is_export_at(m, fi)) reach[fi] = 1;
  }
  {
    char hdr[] = "{\n  \"version\": 2,\n  \"entry\": \"\",\n  \"modules\": [\n    {\"id\": 0, \"path\": \"\"}\n  ],\n  \"functions\": [\n";
    /* Cap residual 9.7.1: fprintf/fputs to the file handle → raw fd write. */
    if (use_stdout) xlang_driver_fwrite_stdout_n(hdr, (int32_t)(sizeof(hdr) - 1));
    else (void)xlang_io_write(xlang_driver_handle_to_fd(fp), hdr, sizeof(hdr) - 1);
  }
  first = 1;
  for (fi = 0; fi < nfuncs; fi++) {
    nlen = pipeline_module_func_name_len_at(m, fi);
    is_ext = pipeline_asm_module_func_is_extern_at(m, fi);
    if (nlen < 0) nlen = 0;
    if (nlen >= 128) nlen = 127;
    if (nlen > 0) pipeline_module_func_name_copy64(m, fi, name);
    name[nlen] = 0;
    if (!first) {
      if (use_stdout) xlang_driver_fwrite_stdout_n(",\n", 2);
      else (void)xlang_io_write(xlang_driver_handle_to_fd(fp), ",\n", 2);
    }
    first = 0;
    if (use_stdout) {
      char line[384];
      int n = snprintf(line, sizeof(line),
        "    {\"id\": %d, \"module\": 0, \"name\": \"%s\", \"extern\": %s, \"reachable\": %s}",
        fi, (const char *)name, is_ext ? "true" : "false", reach[fi] ? "true" : "false");
      if (n > 0) xlang_driver_fwrite_stdout_n(line, n);
    } else {
      char line[384];
      int n = snprintf(line, sizeof(line),
        "    {\"id\": %d, \"module\": 0, \"name\": \"%s\", \"extern\": %s, \"reachable\": %s}",
        fi, (const char *)name, is_ext ? "true" : "false", reach[fi] ? "true" : "false");
      if (n > 0) (void)xlang_io_write(xlang_driver_handle_to_fd(fp), line, (size_t)n);
    }
  }
  {
    char tail[128];
    int n = snprintf(tail, sizeof(tail),
      "\n  ],\n  \"edges\": [\n  ],\n  \"call_sites\": [],\n  \"root\": %d\n}\n", root);
    if (use_stdout) xlang_driver_fwrite_stdout_n(tail, n);
    else if (n > 0) (void)xlang_io_write(xlang_driver_handle_to_fd(fp), tail, (size_t)n);
  }
  free(reach); free(called);
  if (fp) (void)xlang_driver_fclose_opaque(fp);
  return 1;
}
#else
/* FROM_X: pure/thin owns pipeline_typeck_wpo_dump_callgraph. */
#endif


void pipeline_strict_parse_into_init(void *arena, void *module) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)module;
  ast_ast_arena_init(arena);
  ast_pool_module_reset(module);
  ast_pool_arena_reset(arena);
  parser_onefunc_result_layout_prime();
  parser_onefunc_result_layout_prime_b();
  parser_onefunc_result_layout_prime_c();
  parser_onefunc_result_layout_prime_d();
  parser_onefunc_result_layout_prime_d_b();
  parser_onefunc_result_layout_prime_e();
  parser_onefunc_result_layout_prime_f();
  pipeline_module_reset_parse_counters_c(module);
  pipeline_parser_set_match_module(module);
  if (h) {
    h->num_funcs = 0;
    h->main_func_index = -1;
    h->num_imports = 0;
    h->num_top_level_lets = 0;
    h->num_struct_layouts = 0;
    h->pending_allow_padding = 0;
    h->pending_soa_struct = 0;
    h->pending_cfg_skip = 0;
    h->pending_repr_c_struct = 0;
    h->pending_repr_compatible_struct = 0;
    h->num_module_enums = 0;
  }
}



