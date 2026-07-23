#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void xlang_panic_(int has_msg, int msg_val);
extern void copy_bytes(uint8_t * dest, uint8_t * src, size_t n);
extern int32_t lsp_diag_run_pipeline_on_buf(uint8_t * mut_buf, int32_t sl);
extern int32_t lsp_build_diagnostics_response(int32_t id_val, uint8_t * source, int32_t source_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_find_type_ref_at_pos(struct ast_ASTArena * arena, int32_t line_1, int32_t col_1);
extern int32_t lsp_diag_hover_at(uint8_t * source, int32_t source_len, int32_t line_0, int32_t col_0, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_collect_call_refs(struct ast_ASTArena * arena, int32_t func_index, int32_t * out_lines, int32_t * out_cols, int32_t max_refs);
extern int32_t lsp_diag_references_at(uint8_t * source, int32_t source_len, int32_t line_0, int32_t col_0, int32_t * out_lines, int32_t * out_cols, int32_t max_refs);
extern int32_t lsp_col_in_ident_span(int32_t line_1, int32_t col_1, int32_t span_line, int32_t span_col, int32_t span_len);
extern int32_t lsp_source_find_function_def(uint8_t * source, int32_t sl, uint8_t * name, int32_t name_len, int32_t * out_line, int32_t * out_col);
extern int32_t lsp_func_def_pos_in_source(uint8_t * source, int32_t sl, struct ast_Module * module, int32_t func_index, int32_t * out_line, int32_t * out_col);
extern int32_t lsp_diag_definition_at(uint8_t * source, int32_t source_len, int32_t line_0, int32_t col_0, int32_t * out_line, int32_t * out_col);
extern int32_t lsp_collect_semantic_tokens(struct ast_ASTArena * arena, int32_t * out_data, int32_t out_cap);
extern int32_t lsp_build_semantic_tokens_response(int32_t id_val, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * source_data, int32_t source_len, struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module * module, int32_t fi);
extern void pipeline_module_func_name_copy64(struct ast_Module * module, int32_t fi, uint8_t * dst);
extern int32_t pipeline_expr_line_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_col_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_type_name_len(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena * arena, int32_t type_ref, uint8_t * out);
extern void lsp_diag_prepare_pipeline_ctx(struct ast_PipelineDepCtx * ctx);
void copy_bytes(uint8_t * dest, uint8_t * src, size_t n) {
  size_t i = ((size_t)(0));
  while ((i < n)) {
    (void)(((dest)[i] = (src)[i]));
    (void)((i = (i + ((size_t)(1)))));
  }
  (void)(0);
  return;
}
extern uint8_t * std_heap_alloc(size_t size);
extern void std_heap_free(uint8_t * ptr);
extern void lsp_diag_invalidate_cache(void);
extern void lsp_diag_collect_begin(void);
extern void lsp_diag_collect_end(void);
extern void lsp_diag_x_reset_parse_buffers(void);
extern struct ast_ASTArena * lsp_diag_x_arena_ptr(void);
extern struct ast_Module * lsp_diag_x_module_ptr(void);
extern struct ast_PipelineDepCtx * lsp_diag_x_ctx_ptr(void);
extern int32_t lsp_diag_format_diagnostics_json(uint8_t * out, int32_t out_cap);
extern int32_t lsp_build_response_with_result(int32_t id_val, uint8_t * result_ptr, int32_t result_len, uint8_t * out_buf, int32_t out_cap);
int32_t lsp_diag_run_pipeline_on_buf(uint8_t * mut_buf, int32_t sl) {
  {
    struct ast_ASTArena * arena = lsp_diag_x_arena_ptr();
    struct ast_Module * module = lsp_diag_x_module_ptr();
    struct ast_PipelineDepCtx * ctx = lsp_diag_x_ctx_ptr();
    (void)(lsp_diag_x_reset_parse_buffers());
    (void)(lsp_diag_prepare_pipeline_ctx(ctx));
    return pipeline_lsp_diag_parse_typeck_buf(module, arena, mut_buf, sl, ctx);
  }
  return 0;
}
int32_t lsp_build_diagnostics_response(int32_t id_val, uint8_t * source, int32_t source_len, uint8_t * out_buf, int32_t out_cap) {
  {
    int32_t sl = source_len;
    size_t ncopy = ((size_t)(sl));
    size_t alloc_bytes = (ncopy + ((size_t)(1)));
    uint8_t * mut_buf = std_heap_alloc(alloc_bytes);
    int32_t rc = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
    int32_t diag_cap = (65536 + (rc * 0));
    uint8_t * diag_buf = std_heap_alloc(((size_t)(diag_cap)));
    int32_t dn = lsp_diag_format_diagnostics_json(diag_buf, diag_cap);
    int32_t result_len = dn;
    int32_t resp_len = lsp_build_response_with_result(id_val, diag_buf, result_len, out_buf, out_cap);
    if ((((source ==((uint8_t *)(0))) || (out_buf ==((uint8_t *)(0)))) || (out_cap <=0))) {
      return -(1);
    }
    if ((sl < 0)) {
      (void)((sl = 0));
    }
    (void)(lsp_diag_invalidate_cache());
    if ((alloc_bytes ==((size_t)(0)))) {
      (void)((alloc_bytes = ((size_t)(1))));
    }
    if ((mut_buf ==((uint8_t *)(0)))) {
      return -(1);
    }
    if ((sl > 0)) {
      (void)(copy_bytes(mut_buf, source, ncopy));
    }
    (void)(((mut_buf)[sl] = ((uint8_t)(0))));
    (void)(lsp_diag_collect_begin());
    (void)(lsp_diag_collect_end());
    (void)(std_heap_free(mut_buf));
    if ((diag_buf ==((uint8_t *)(0)))) {
      return -(1);
    }
    if ((result_len <=0)) {
      (void)(((diag_buf)[0] = ((uint8_t)(91))));
      (void)(((diag_buf)[1] = ((uint8_t)(93))));
      (void)((result_len = 2));
    }
    (void)(std_heap_free(diag_buf));
    return resp_len;
  }
  return 0;
}
int32_t lsp_find_type_ref_at_pos(struct ast_ASTArena * arena, int32_t line_1, int32_t col_1) {
  {
    int32_t ei = 1;
    if ((arena ==((struct ast_ASTArena *)(0)))) {
      return 0;
    }
    while ((ei <=(arena->num_exprs))) {
      int32_t el = pipeline_expr_line_at(arena, ei);
      int32_t ec = pipeline_expr_col_at(arena, ei);
      if (((el ==line_1) && (ec ==col_1))) {
        int32_t tr = pipeline_expr_resolved_type_ref(arena, ei);
        if ((tr !=0)) {
          return tr;
        }
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
  return 0;
}
int32_t lsp_diag_hover_at(uint8_t * source, int32_t source_len, int32_t line_0, int32_t col_0, uint8_t * out_buf, int32_t out_cap) {
  {
    int32_t sl = source_len;
    size_t ncopy = ((size_t)(sl));
    size_t ab = (ncopy + ((size_t)(1)));
    uint8_t * mut_buf = std_heap_alloc(ab);
    int32_t rc = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
    struct ast_ASTArena * arena = lsp_diag_x_arena_ptr();
    int32_t type_ref = lsp_find_type_ref_at_pos(arena, (line_0 + 1), (col_0 + 1));
    int32_t ko = pipeline_type_kind_ord_at(arena, type_ref);
    if (((((source ==((uint8_t *)(0))) || (out_buf ==((uint8_t *)(0)))) || (out_cap <=0)) || (source_len < 0))) {
      return 0;
    }
    if ((sl < 0)) {
      (void)((sl = 0));
    }
    if ((ab ==((size_t)(0)))) {
      (void)((ab = ((size_t)(1))));
    }
    if ((mut_buf ==((uint8_t *)(0)))) {
      return 0;
    }
    if ((sl > 0)) {
      (void)(copy_bytes(mut_buf, source, ncopy));
    }
    (void)(((mut_buf)[sl] = ((uint8_t)(0))));
    (void)(lsp_diag_invalidate_cache());
    (void)(lsp_diag_collect_begin());
    (void)(lsp_diag_collect_end());
    if ((rc !=0)) {
      (void)(std_heap_free(mut_buf));
      return 0;
    }
    (void)(std_heap_free(mut_buf));
    if ((type_ref ==0)) {
      return 0;
    }
    if (((type_ref <=0) || (type_ref > (arena->num_types)))) {
      return 0;
    }
    if (((ko ==0) && (out_cap >=4))) {
      (void)(((out_buf)[0] = 105));
      (void)(((out_buf)[1] = 51));
      (void)(((out_buf)[2] = 50));
      return 3;
    }
    if (((ko ==1) && (out_cap >=5))) {
      (void)(((out_buf)[0] = 98));
      (void)(((out_buf)[1] = 111));
      (void)(((out_buf)[2] = 111));
      (void)(((out_buf)[3] = 108));
      return 4;
    }
    if (((ko ==2) && (out_cap >=3))) {
      (void)(((out_buf)[0] = 117));
      (void)(((out_buf)[1] = 56));
      return 2;
    }
    if (((ko ==3) && (out_cap >=4))) {
      (void)(((out_buf)[0] = 117));
      (void)(((out_buf)[1] = 51));
      (void)(((out_buf)[2] = 50));
      return 3;
    }
    if (((ko ==4) && (out_cap >=4))) {
      (void)(((out_buf)[0] = 117));
      (void)(((out_buf)[1] = 54));
      (void)(((out_buf)[2] = 52));
      return 3;
    }
    if (((ko ==5) && (out_cap >=4))) {
      (void)(((out_buf)[0] = 105));
      (void)(((out_buf)[1] = 54));
      (void)(((out_buf)[2] = 52));
      return 3;
    }
    if (((ko ==6) && (out_cap >=6))) {
      (void)(((out_buf)[0] = 117));
      (void)(((out_buf)[1] = 115));
      (void)(((out_buf)[2] = 105));
      (void)(((out_buf)[3] = 122));
      (void)(((out_buf)[4] = 101));
      return 5;
    }
    if (((ko ==14) && (out_cap >=4))) {
      (void)(((out_buf)[0] = 102));
      (void)(((out_buf)[1] = 51));
      (void)(((out_buf)[2] = 50));
      return 3;
    }
    if (((ko ==15) && (out_cap >=4))) {
      (void)(((out_buf)[0] = 102));
      (void)(((out_buf)[1] = 54));
      (void)(((out_buf)[2] = 52));
      return 3;
    }
    if (((ko ==16) && (out_cap >=5))) {
      (void)(((out_buf)[0] = 118));
      (void)(((out_buf)[1] = 111));
      (void)(((out_buf)[2] = 105));
      (void)(((out_buf)[3] = 100));
      return 4;
    }
    if (((ko ==9) && (out_cap >=2))) {
      (void)(((out_buf)[0] = 42));
      return 1;
    }
    if (((ko ==8) && (out_cap > 0))) {
      uint8_t nm[64] = {};
      int32_t nlen = pipeline_type_named_name_into(arena, type_ref, &((nm)[0]));
      if ((((nlen > 0) && (nlen <=64)) && (out_cap > nlen))) {
        int32_t i = 0;
        while ((i < nlen)) {
          (void)(((out_buf)[i] = (nm)[i]));
          (void)((i = (i + 1)));
        }
        return nlen;
      }
    }
    if ((out_cap >=2)) {
      (void)(((out_buf)[0] = 63));
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t lsp_collect_call_refs(struct ast_ASTArena * arena, int32_t func_index, int32_t * out_lines, int32_t * out_cols, int32_t max_refs) {
  {
    int32_t ord_call = 48;
    int32_t count = 0;
    int32_t ei = 1;
    if (((((arena ==((struct ast_ASTArena *)(0))) || (out_lines ==((int32_t *)(0)))) || (out_cols ==((int32_t *)(0)))) || (max_refs <=0))) {
      return 0;
    }
    while (((ei <=(arena->num_exprs)) && (count < max_refs))) {
      int32_t ek = pipeline_expr_kind_ord_at(arena, ei);
      int32_t el = pipeline_expr_line_at(arena, ei);
      int32_t fri = pipeline_expr_call_resolved_func_index_at(arena, ei);
      if ((((ek ==ord_call) && (fri ==func_index)) && (el > 0))) {
        (void)(((out_lines)[count] = el));
        (void)(((out_cols)[count] = pipeline_expr_col_at(arena, ei)));
        (void)((count = (count + 1)));
      }
      (void)((ei = (ei + 1)));
    }
    return count;
  }
  return 0;
}
int32_t lsp_diag_references_at(uint8_t * source, int32_t source_len, int32_t line_0, int32_t col_0, int32_t * out_lines, int32_t * out_cols, int32_t max_refs) {
  {
    int32_t sl = source_len;
    size_t ncopy = ((size_t)(sl));
    size_t ab = (ncopy + ((size_t)(1)));
    uint8_t * mut_buf = std_heap_alloc(ab);
    int32_t rc = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
    struct ast_ASTArena * arena = lsp_diag_x_arena_ptr();
    int32_t line_1 = (line_0 + 1);
    int32_t col_1 = (col_0 + 1);
    int32_t ord_call = 48;
    int32_t func_index = -(1);
    int32_t ei = 1;
    int32_t tmp_lines[512] = {};
    int32_t tmp_cols[512] = {};
    int32_t n = lsp_collect_call_refs(arena, func_index, &((tmp_lines)[0]), &((tmp_cols)[0]), 512);
    int32_t out_n = n;
    int32_t oi = 0;
    if ((((((source ==((uint8_t *)(0))) || (out_lines ==((int32_t *)(0)))) || (out_cols ==((int32_t *)(0)))) || (max_refs <=0)) || (source_len < 0))) {
      return 0;
    }
    if ((sl < 0)) {
      (void)((sl = 0));
    }
    if ((ab ==((size_t)(0)))) {
      (void)((ab = ((size_t)(1))));
    }
    if ((mut_buf ==((uint8_t *)(0)))) {
      return 0;
    }
    if ((sl > 0)) {
      (void)(copy_bytes(mut_buf, source, ncopy));
    }
    (void)(((mut_buf)[sl] = ((uint8_t)(0))));
    (void)(lsp_diag_invalidate_cache());
    (void)(lsp_diag_collect_begin());
    (void)(lsp_diag_collect_end());
    if ((rc !=0)) {
      (void)(std_heap_free(mut_buf));
      return 0;
    }
    (void)(std_heap_free(mut_buf));
    while ((ei <=(arena->num_exprs))) {
      int32_t el = pipeline_expr_line_at(arena, ei);
      int32_t ec = pipeline_expr_col_at(arena, ei);
      int32_t ek = pipeline_expr_kind_ord_at(arena, ei);
      int32_t fri = pipeline_expr_call_resolved_func_index_at(arena, ei);
      if (((((el ==line_1) && (ec ==col_1)) && (ek ==ord_call)) && (fri >=0))) {
        (void)((func_index = fri));
        break;
      }
      (void)((ei = (ei + 1)));
    }
    if ((func_index < 0)) {
      return 0;
    }
    if ((out_n > max_refs)) {
      (void)((out_n = max_refs));
    }
    while ((oi < out_n)) {
      (void)(((out_lines)[oi] = ((tmp_lines)[oi] - 1)));
      (void)(((out_cols)[oi] = ((tmp_cols)[oi] - 1)));
      (void)((oi = (oi + 1)));
    }
    return out_n;
  }
  return 0;
}
int32_t lsp_col_in_ident_span(int32_t line_1, int32_t col_1, int32_t span_line, int32_t span_col, int32_t span_len) {
  if (((line_1 !=span_line) || (span_len <=0))) {
    return 0;
  }
  if (((col_1 >=span_col) && (col_1 < (span_col + span_len)))) {
    return 1;
  }
  return 0;
}
int32_t lsp_source_find_function_def(uint8_t * source, int32_t sl, uint8_t * name, int32_t name_len, int32_t * out_line, int32_t * out_col) {
  if (((((((source ==((uint8_t *)(0))) || (name ==((uint8_t *)(0)))) || (name_len <=0)) || (sl <=0)) || (out_line ==((int32_t *)(0)))) || (out_col ==((int32_t *)(0))))) {
    return 0;
  }
  uint8_t kw[9] = {102, 117, 110, 99, 116, 105, 111, 110, 32};
  int32_t line = 1;
  int32_t col = 1;
  int32_t i = 0;
  while ((i < sl)) {
    int32_t boundary = 0;
    if ((i ==0)) {
      (void)((boundary = 1));
    } else {
      uint8_t prev = (source)[(i - 1)];
      if ((((prev ==((uint8_t)(32))) || (prev ==((uint8_t)(9)))) || (prev ==((uint8_t)(10))))) {
        (void)((boundary = 1));
      }
    }
    if (((boundary !=0) && (((i + 9) + name_len) <=sl))) {
      int32_t ki = 0;
      int32_t kw_ok = 1;
      while ((ki < 9)) {
        if (((source)[(i + ki)] !=(kw)[ki])) {
          (void)((kw_ok = 0));
          break;
        }
        (void)((ki = (ki + 1)));
      }
      if ((kw_ok !=0)) {
        int32_t ni = 0;
        int32_t name_ok = 1;
        while ((ni < name_len)) {
          if (((source)[((i + 9) + ni)] !=(name)[ni])) {
            (void)((name_ok = 0));
            break;
          }
          (void)((ni = (ni + 1)));
        }
        if ((name_ok !=0)) {
          int32_t after = ((i + 9) + name_len);
          if ((after >=sl)) {
            (void)(((out_line)[0] = line));
            (void)(((out_col)[0] = (col + 9)));
            return 1;
          }
          uint8_t ac = (source)[after];
          if (((((ac ==((uint8_t)(32))) || (ac ==((uint8_t)(40)))) || (ac ==((uint8_t)(10)))) || (ac ==((uint8_t)(9))))) {
            (void)(((out_line)[0] = line));
            (void)(((out_col)[0] = (col + 9)));
            return 1;
          }
        }
      }
    }
    if (((source)[i] ==((uint8_t)(10)))) {
      (void)((line = (line + 1)));
      (void)((col = 1));
    } else {
      (void)((col = (col + 1)));
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_func_def_pos_in_source(uint8_t * source, int32_t sl, struct ast_Module * module, int32_t func_index, int32_t * out_line, int32_t * out_col) {
  {
    int32_t nl = pipeline_module_func_name_len_at(module, func_index);
    uint8_t nm[64] = {};
    if ((((module ==((struct ast_Module *)(0))) || (func_index < 0)) || (func_index >=(module->num_funcs)))) {
      return 0;
    }
    if (((nl <=0) || (nl > 64))) {
      return 0;
    }
    (void)(pipeline_module_func_name_copy64(module, func_index, &((nm)[0])));
    return lsp_source_find_function_def(source, sl, &((nm)[0]), nl, out_line, out_col);
  }
  return 0;
}
int32_t lsp_diag_definition_at(uint8_t * source, int32_t source_len, int32_t line_0, int32_t col_0, int32_t * out_line, int32_t * out_col) {
  {
    int32_t sl = source_len;
    size_t ncopy = ((size_t)(sl));
    size_t ab = (ncopy + ((size_t)(1)));
    uint8_t * mut_buf = std_heap_alloc(ab);
    int32_t rc = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
    struct ast_Module * module = lsp_diag_x_module_ptr();
    struct ast_ASTArena * arena = lsp_diag_x_arena_ptr();
    int32_t line_1 = (line_0 + 1);
    int32_t col_1 = (col_0 + 1);
    int32_t def_l1 = 0;
    int32_t def_c1 = 0;
    int32_t fi = 0;
    int32_t ord_call = 48;
    int32_t func_index = -(1);
    int32_t ei = 1;
    if (((((source ==((uint8_t *)(0))) || (out_line ==((int32_t *)(0)))) || (out_col ==((int32_t *)(0)))) || (source_len < 0))) {
      return 0;
    }
    if ((ab ==((size_t)(0)))) {
      (void)((ab = ((size_t)(1))));
    }
    if ((mut_buf ==((uint8_t *)(0)))) {
      return 0;
    }
    if ((sl > 0)) {
      (void)(copy_bytes(mut_buf, source, ncopy));
    }
    (void)(((mut_buf)[sl] = ((uint8_t)(0))));
    (void)(lsp_diag_invalidate_cache());
    (void)(lsp_diag_collect_begin());
    (void)(lsp_diag_collect_end());
    if ((rc !=0)) {
      (void)(std_heap_free(mut_buf));
      return 0;
    }
    while ((fi < (module->num_funcs))) {
      if ((lsp_func_def_pos_in_source(mut_buf, sl, module, fi, &(def_l1), &(def_c1)) !=0)) {
        int32_t nl2 = pipeline_module_func_name_len_at(module, fi);
        if ((lsp_col_in_ident_span(line_1, col_1, def_l1, def_c1, nl2) !=0)) {
          (void)(((out_line)[0] = (def_l1 - 1)));
          (void)(((out_col)[0] = (def_c1 - 1)));
          (void)(std_heap_free(mut_buf));
          return 1;
        }
      }
      (void)((fi = (fi + 1)));
    }
    while ((ei <=(arena->num_exprs))) {
      int32_t el = pipeline_expr_line_at(arena, ei);
      int32_t ec = pipeline_expr_col_at(arena, ei);
      int32_t ek = pipeline_expr_kind_ord_at(arena, ei);
      int32_t fri = pipeline_expr_call_resolved_func_index_at(arena, ei);
      if (((((el ==line_1) && (ec ==col_1)) && (ek ==ord_call)) && (fri >=0))) {
        (void)((func_index = fri));
        break;
      }
      (void)((ei = (ei + 1)));
    }
    if (((func_index >=0) && (lsp_func_def_pos_in_source(mut_buf, sl, module, func_index, &(def_l1), &(def_c1)) !=0))) {
      (void)(((out_line)[0] = (def_l1 - 1)));
      (void)(((out_col)[0] = (def_c1 - 1)));
      (void)(std_heap_free(mut_buf));
      return 1;
    }
    (void)(std_heap_free(mut_buf));
    return 0;
  }
  return 0;
}
int32_t lsp_collect_semantic_tokens(struct ast_ASTArena * arena, int32_t * out_data, int32_t out_cap) {
  {
    int32_t ord_lit = 0;
    int32_t ord_float = 1;
    int32_t ord_var = 3;
    int32_t ord_field = 44;
    int32_t ord_struct_lit = 45;
    int32_t ord_call = 48;
    int32_t ord_method = 49;
    int32_t ord_enum_var = 50;
    int32_t ord_as = 54;
    int32_t count = 0;
    int32_t prev_line = 0;
    int32_t prev_start = 0;
    int32_t ei = 1;
    if ((((arena ==((struct ast_ASTArena *)(0))) || (out_data ==((int32_t *)(0)))) || (out_cap < 5))) {
      return 0;
    }
    while (((ei <=(arena->num_exprs)) && ((count + 5) <=out_cap))) {
      int32_t el = pipeline_expr_line_at(arena, ei);
      int32_t ec = pipeline_expr_col_at(arena, ei);
      if (((el <=0) || (ec <=0))) {
        (void)((ei = (ei + 1)));
        continue;
      }
      int32_t line0 = (el - 1);
      int32_t start0 = (ec - 1);
      int32_t vlen = pipeline_expr_var_name_len(arena, ei);
      int32_t len = vlen;
      if ((len <=0)) {
        (void)((len = 1));
      }
      int32_t token_type = -(1);
      int32_t modifiers = 0;
      int32_t ek = pipeline_expr_kind_ord_at(arena, ei);
      if ((ek ==ord_var)) {
        (void)((token_type = 8));
        if ((pipeline_expr_resolved_type_ref(arena, ei) !=0)) {
          (void)((modifiers = 4));
        }
      }
      if (((ek ==ord_call) || (ek ==ord_method))) {
        (void)((token_type = 12));
        if ((vlen > 0)) {
          (void)((len = vlen));
        }
      }
      if ((ek ==ord_struct_lit)) {
        int32_t sn = pipeline_expr_struct_lit_type_name_len(arena, ei);
        (void)((token_type = 5));
        if ((sn > 0)) {
          (void)((len = sn));
        }
      }
      if ((ek ==ord_enum_var)) {
        (void)((token_type = 3));
        if ((vlen > 0)) {
          (void)((len = vlen));
        }
      }
      if ((ek ==ord_lit)) {
        (void)((token_type = 19));
        (void)((len = 1));
      }
      if ((ek ==ord_float)) {
        (void)((token_type = 19));
        (void)((len = 1));
      }
      if ((ek ==ord_field)) {
        int32_t flen = pipeline_expr_field_access_name_len(arena, ei);
        (void)((token_type = 9));
        if ((flen > 0)) {
          (void)((len = flen));
        }
      }
      if ((ek ==ord_as)) {
        (void)((token_type = 8));
      }
      if ((token_type >=0)) {
        int32_t delta_line = (line0 - prev_line);
        int32_t delta_start = 0;
        if ((delta_line ==0)) {
          (void)((delta_start = (start0 - prev_start)));
        } else {
          (void)((delta_start = start0));
        }
        (void)(((out_data)[count] = delta_line));
        (void)((count = (count + 1)));
        (void)(((out_data)[count] = delta_start));
        (void)((count = (count + 1)));
        (void)(((out_data)[count] = len));
        (void)((count = (count + 1)));
        (void)(((out_data)[count] = token_type));
        (void)((count = (count + 1)));
        (void)(((out_data)[count] = modifiers));
        (void)((count = (count + 1)));
        (void)((prev_line = line0));
        (void)((prev_start = start0));
      }
      (void)((ei = (ei + 1)));
    }
    return count;
  }
  return 0;
}
int32_t lsp_build_semantic_tokens_response(int32_t id_val, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap) {
  {
    int32_t sl = doc_len;
    size_t ncopy = ((size_t)(sl));
    size_t ab = (ncopy + ((size_t)(1)));
    uint8_t * mut_buf = std_heap_alloc(ab);
    int32_t rc = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
    struct ast_ASTArena * arena = lsp_diag_x_arena_ptr();
    int32_t token_cap = 4096;
    size_t token_bytes = ((size_t)((token_cap * 4)));
    uint8_t * token_data_raw = std_heap_alloc(token_bytes);
    int32_t * token_data = ((int32_t *)(token_data_raw));
    int32_t n_tokens = lsp_collect_semantic_tokens(arena, token_data, token_cap);
    int32_t json_cap = 262144;
    uint8_t * json_ptr = std_heap_alloc(((size_t)(json_cap)));
    uint8_t prefix[64] = {};
    int32_t pi = 0;
    uint8_t id_str[12] = {};
    int32_t id_len = 0;
    int32_t tmp = id_val;
    int32_t ji = 0;
    int32_t pj = 0;
    int32_t ti = 0;
    int32_t first = 1;
    int32_t resp_len = pj;
    int32_t ri = 0;
    if (((((doc_buf ==((uint8_t *)(0))) || (out_buf ==((uint8_t *)(0)))) || (out_cap <=0)) || (doc_len < 0))) {
      return -(1);
    }
    if ((ab ==((size_t)(0)))) {
      (void)((ab = ((size_t)(1))));
    }
    if ((mut_buf ==((uint8_t *)(0)))) {
      return -(1);
    }
    if ((sl > 0)) {
      (void)(copy_bytes(mut_buf, doc_buf, ncopy));
    }
    (void)(((mut_buf)[sl] = ((uint8_t)(0))));
    (void)(lsp_diag_invalidate_cache());
    (void)(lsp_diag_collect_begin());
    (void)(lsp_diag_collect_end());
    if ((rc !=0)) {
      (void)(std_heap_free(mut_buf));
      return -(1);
    }
    (void)(std_heap_free(mut_buf));
    if ((token_data ==((int32_t *)(0)))) {
      return -(1);
    }
    if ((json_ptr ==((uint8_t *)(0)))) {
      (void)(std_heap_free(((uint8_t *)(token_data))));
      return -(1);
    }
    (void)(((prefix)[0] = 123));
    (void)(((prefix)[1] = 34));
    (void)(((prefix)[2] = 106));
    (void)(((prefix)[3] = 115));
    (void)(((prefix)[4] = 111));
    (void)(((prefix)[5] = 110));
    (void)(((prefix)[6] = 114));
    (void)(((prefix)[7] = 112));
    (void)(((prefix)[8] = 99));
    (void)(((prefix)[9] = 34));
    (void)(((prefix)[10] = 58));
    (void)(((prefix)[11] = 34));
    (void)(((prefix)[12] = 50));
    (void)(((prefix)[13] = 46));
    (void)(((prefix)[14] = 48));
    (void)(((prefix)[15] = 34));
    (void)(((prefix)[16] = 44));
    (void)(((prefix)[17] = 34));
    (void)(((prefix)[18] = 105));
    (void)(((prefix)[19] = 100));
    (void)(((prefix)[20] = 34));
    (void)(((prefix)[21] = 58));
    (void)((pi = 22));
    if ((tmp ==0)) {
      (void)(((id_str)[0] = 48));
      (void)((id_len = 1));
    } else {
      int32_t ds[12] = {};
      int32_t dn = 0;
      while ((tmp > 0)) {
        (void)(((ds)[dn] = (tmp % 10)));
        (void)((tmp = (tmp / 10)));
        (void)((dn = (dn + 1)));
      }
      int32_t di = (dn - 1);
      while ((di >=0)) {
        (void)(((id_str)[id_len] = ((uint8_t)(((ds)[di] + 48)))));
        (void)((id_len = (id_len + 1)));
        (void)((di = (di - 1)));
      }
    }
    while (((ji < id_len) && (pi < 64))) {
      (void)(((prefix)[pi] = (id_str)[ji]));
      (void)((pi = (pi + 1)));
      (void)((ji = (ji + 1)));
    }
    (void)(((prefix)[pi] = 44));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 34));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 114));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 101));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 115));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 117));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 108));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 116));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 34));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 58));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 123));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 34));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 100));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 97));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 116));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 97));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 34));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 58));
    (void)((pi = (pi + 1)));
    (void)(((prefix)[pi] = 91));
    (void)((pi = (pi + 1)));
    while ((pj < pi)) {
      (void)(((json_ptr)[pj] = (prefix)[pj]));
      (void)((pj = (pj + 1)));
    }
    while ((ti < n_tokens)) {
      int32_t val = (token_data)[ti];
      if (((first ==0) && (pj < json_cap))) {
        (void)(((json_ptr)[pj] = 44));
        (void)((pj = (pj + 1)));
      }
      (void)((first = 0));
      if ((val < 0)) {
        if ((pj < json_cap)) {
          (void)(((json_ptr)[pj] = 45));
          (void)((pj = (pj + 1)));
          (void)((val = -(val)));
        }
      }
      int32_t digits[12] = {};
      int32_t dn = 0;
      if ((val ==0)) {
        (void)(((digits)[0] = 0));
        (void)((dn = 1));
      } else {
        int32_t v2 = val;
        while ((v2 > 0)) {
          (void)(((digits)[dn] = (v2 % 10)));
          (void)((v2 = (v2 / 10)));
          (void)((dn = (dn + 1)));
        }
      }
      int32_t di = (dn - 1);
      while (((di >=0) && (pj < json_cap))) {
        (void)(((json_ptr)[pj] = ((uint8_t)(((digits)[di] + 48)))));
        (void)((pj = (pj + 1)));
        (void)((di = (di - 1)));
      }
      (void)((ti = (ti + 1)));
    }
    if ((pj < json_cap)) {
      (void)(((json_ptr)[pj] = 93));
      (void)((pj = (pj + 1)));
    }
    if ((pj < json_cap)) {
      (void)(((json_ptr)[pj] = 125));
      (void)((pj = (pj + 1)));
    }
    if ((pj < json_cap)) {
      (void)(((json_ptr)[pj] = 125));
      (void)((pj = (pj + 1)));
    }
    while (((ri < resp_len) && (ri < out_cap))) {
      (void)(((out_buf)[ri] = (json_ptr)[ri]));
      (void)((ri = (ri + 1)));
    }
    (void)(std_heap_free(json_ptr));
    (void)(std_heap_free(((uint8_t *)(token_data))));
    return resp_len;
  }
  return 0;
}
