#!/usr/bin/env python3
"""Root-fix codegen_emit_call_func_name: use defining module's arena for type_ref mangle."""
from pathlib import Path
import sys

NEW_FN = r'''int32_t codegen_emit_call_func_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t expr_ref, struct ast_Module * current_module, uint8_t * fallback_name, int32_t fallback_len) {
  if (ctx != 0 && arena != 0) {
    int32_t func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    int32_t dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    /* type_ref is arena-local: mangle/search for a dep module must use that dep's arena. */
    struct ast_ASTArena * mod_arena = arena;
    if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
      mod_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
    } else if (current_module != 0) {
      int32_t di;
      for (di = 0; di < pipeline_dep_ctx_ndep(ctx); di++) {
        if (pipeline_dep_ctx_module_at(ctx, di) == current_module) {
          mod_arena = pipeline_dep_ctx_arena_at(ctx, di);
          break;
        }
      }
    }
    if (func_ix >= 0) {
      if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
        struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
        if (dep_mod != 0 && func_ix < (dep_mod)->num_funcs) {
          return codegen_emit_func_link_name(out, mod_arena, dep_mod, func_ix);
        }
      } else {
        if (current_module != 0 && func_ix < (current_module)->num_funcs) {
          return codegen_emit_func_link_name(out, mod_arena, current_module, func_ix);
        }
      }
    }
    struct ast_Module * search_mod = 0;
    if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
      search_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
    } else {
      search_mod = current_module;
    }
    /* If search_mod is a dep but dep_ix was unset, re-bind mod_arena to search_mod. */
    if (search_mod != 0 && mod_arena == arena && search_mod != (ctx)->current_codegen_module) {
      int32_t di2;
      for (di2 = 0; di2 < pipeline_dep_ctx_ndep(ctx); di2++) {
        if (pipeline_dep_ctx_module_at(ctx, di2) == search_mod) {
          mod_arena = pipeline_dep_ctx_arena_at(ctx, di2);
          break;
        }
      }
    }
    if (search_mod != 0 && fallback_len > 0) {
      struct ast_Expr call_e = ast_arena_expr_get(arena, expr_ref);
      int32_t is_method = ((call_e).kind == ast_ExprKind_EXPR_METHOD_CALL);
      int32_t call_nargs = is_method ? (call_e).method_call_num_args : (call_e).call_num_args;
      int32_t found_fi = -1;
      int32_t found_count = 0;
      int32_t fi_s = 0;
      while (fi_s < (search_mod)->num_funcs) {
        int32_t fn_len = pipeline_module_func_name_len_at(search_mod, fi_s);
        if (fn_len == fallback_len && fn_len > 0) {
          uint8_t fn_name[64] = { 0 };
          pipeline_module_func_name_copy64(search_mod, fi_s, (&((fn_name)[0])));
          int32_t matched = 1;
          int32_t bi = 0;
          while (bi < fn_len) {
            if (fn_name[bi] != fallback_name[bi]) { matched = 0; bi = fn_len; } else { bi = bi + 1; }
          }
          if (matched != 0) {
            int32_t np = pipeline_module_func_num_params_at(search_mod, fi_s);
            if (np == call_nargs) {
              int32_t types_match = 1;
              int32_t pi = 0;
              while (pi < np && types_match != 0) {
                int32_t arg_ref = is_method ? pipeline_expr_method_call_arg_ref(arena, expr_ref, pi) : pipeline_expr_call_arg_ref(arena, expr_ref, pi);
                if (ast_ref_is_null(arg_ref)) { types_match = 0; } else {
                  int32_t arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
                  if (arg_ty <= 0 && pipeline_expr_kind_ord_at(arena, arg_ref) == 54) {
                    int32_t as_tgt = pipeline_expr_as_target_type_ref_at(arena, arg_ref);
                    if (as_tgt > 0) arg_ty = as_tgt;
                  }
                  int32_t param_ty = pipeline_module_func_param_type_ref_at(search_mod, fi_s, pi);
                  uint8_t sa[64] = { 0 };
                  uint8_t sb[64] = { 0 };
                  int32_t na = codegen_type_ref_to_suffix(arena, arg_ty, (&((sa)[0])), 64);
                  int32_t nb = codegen_type_ref_to_suffix(mod_arena, param_ty, (&((sb)[0])), 64);
                  if (na != nb || na <= 0) { types_match = 0; } else {
                    int32_t k = 0;
                    while (k < na) {
                      if (sa[k] != sb[k]) { types_match = 0; k = na; } else { k = k + 1; }
                    }
                  }
                }
                pi = pi + 1;
              }
              if (types_match != 0) {
                found_fi = fi_s;
                found_count = found_count + 1;
              }
            }
          }
        }
        fi_s = fi_s + 1;
      }
      if (found_count == 1 && found_fi >= 0) {
        return codegen_emit_func_link_name(out, mod_arena, search_mod, found_fi);
      }
      if (found_count != 1 && call_nargs >= 0) {
        int32_t arity_fi = -1;
        int32_t arity_count = 0;
        int32_t ext_fi = -1;
        int32_t ext_count = 0;
        fi_s = 0;
        while (fi_s < (search_mod)->num_funcs) {
          int32_t fn_len2 = pipeline_module_func_name_len_at(search_mod, fi_s);
          if (fn_len2 == fallback_len && fn_len2 > 0) {
            uint8_t fn_name2[64] = { 0 };
            int32_t matched2 = 1;
            int32_t bi2 = 0;
            pipeline_module_func_name_copy64(search_mod, fi_s, (&((fn_name2)[0])));
            while (bi2 < fn_len2) {
              if (fn_name2[bi2] != fallback_name[bi2]) { matched2 = 0; bi2 = fn_len2; }
              else { bi2 = bi2 + 1; }
            }
            if (matched2 != 0 && pipeline_module_func_num_params_at(search_mod, fi_s) == call_nargs) {
              arity_fi = fi_s;
              arity_count = arity_count + 1;
              if (pipeline_module_func_is_extern_at(search_mod, fi_s) != 0 ||
                  pipeline_module_func_is_no_mangle_at(search_mod, fi_s) != 0) {
                ext_fi = fi_s;
                ext_count = ext_count + 1;
              }
            }
          }
          fi_s = fi_s + 1;
        }
        if (ext_count == 1 && ext_fi >= 0) {
          return codegen_emit_func_link_name(out, mod_arena, search_mod, ext_fi);
        }
        if (arity_count == 1 && arity_fi >= 0) {
          return codegen_emit_func_link_name(out, mod_arena, search_mod, arity_fi);
        }
      }
    }
  }
  return codegen_emit_bytes_from_ptr(out, fallback_name, fallback_len);
}
'''

def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "codegen_gen.c")
    t = path.read_text()
    start = t.find(
        "int32_t codegen_emit_call_func_name(struct codegen_CodegenOutBuf * out, "
        "struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t expr_ref, "
        "struct ast_Module * current_module, uint8_t * fallback_name, int32_t fallback_len) {"
    )
    if start < 0:
        print("func start not found", file=sys.stderr)
        return 1
    end = t.find("SHUX_LIB_WEAK void codegen_copy_param_name32_from_module", start)
    if end < 0:
        print("func end not found", file=sys.stderr)
        return 1
    t = t[:start] + NEW_FN + t[end:]

    old_fast = (
        "  if (dep_ix_fast >= 0 && dep_ix_fast < pipeline_dep_ctx_ndep(ctx) && "
        "(callee_fast).kind == ast_ExprKind_EXPR_FIELD_ACCESS && "
        "(callee_fast).field_access_field_len > 0) {   uint8_t dep_path_fast[64] = { 0 };\n"
        "  (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix_fast, (&((dep_path_fast)[0]))));\n"
        "  uint8_t pre_fast[128] = { 0 };\n"
        "  (void)(codegen_import_path_to_c_prefix_into((&((dep_path_fast)[0])), (&((pre_fast)[0])), 128));\n"
        "  int32_t pre_fast_len = 0;\n"
        "  while (pre_fast_len < 128 && (pre_fast_len < 0 || (pre_fast_len) >= 128 ? "
        "(shux_panic_(1, 0), (pre_fast)[0]) : (pre_fast)[pre_fast_len]) != 0) {\n"
        "    ++pre_fast_len;\n"
        "  }\n"
        "  if (pre_fast_len > 0 && codegen_c_prefix_redundant_with_name((&((pre_fast)[0])), "
        "pre_fast_len, (&(((callee_fast).field_access_field_name)[0])), "
        "(callee_fast).field_access_field_len) == 0 && "
        "codegen_emit_bytes_from_ptr(out, (&((pre_fast)[0])), pre_fast_len) != 0) {   return (-1);\n"
        " }\n"
        "  if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, "
        "(ctx)->current_codegen_module, (&(((callee_fast).field_access_field_name)[0])), "
        "(callee_fast).field_access_field_len) != 0) {   return (-1);\n"
        " }"
    )
    new_fast = (
        "  if (dep_ix_fast >= 0 && dep_ix_fast < pipeline_dep_ctx_ndep(ctx) && "
        "(callee_fast).kind == ast_ExprKind_EXPR_FIELD_ACCESS && "
        "(callee_fast).field_access_field_len > 0) {   uint8_t dep_path_fast[64] = { 0 };\n"
        "  (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix_fast, (&((dep_path_fast)[0]))));\n"
        "  uint8_t pre_fast[128] = { 0 };\n"
        "  (void)(codegen_import_path_to_c_prefix_into((&((dep_path_fast)[0])), (&((pre_fast)[0])), 128));\n"
        "  int32_t pre_fast_len = 0;\n"
        "  while (pre_fast_len < 128 && (pre_fast_len < 0 || (pre_fast_len) >= 128 ? "
        "(shux_panic_(1, 0), (pre_fast)[0]) : (pre_fast)[pre_fast_len]) != 0) {\n"
        "    ++pre_fast_len;\n"
        "  }\n"
        "  if (pre_fast_len > 0 && codegen_c_prefix_redundant_with_name((&((pre_fast)[0])), "
        "pre_fast_len, (&(((callee_fast).field_access_field_name)[0])), "
        "(callee_fast).field_access_field_len) == 0 && "
        "codegen_emit_bytes_from_ptr(out, (&((pre_fast)[0])), pre_fast_len) != 0) {   return (-1);\n"
        " }\n"
        "  {\n"
        "    struct ast_Module * fast_dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);\n"
        "    if (fast_dep_mod == ((struct ast_Module *)(0))) "
        "fast_dep_mod = (ctx)->current_codegen_module;\n"
        "    if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, fast_dep_mod, "
        "(&(((callee_fast).field_access_field_name)[0])), "
        "(callee_fast).field_access_field_len) != 0) {   return (-1);\n"
        " }\n"
        "  }"
    )
    if old_fast in t:
        t = t.replace(old_fast, new_fast, 1)
        print("patched dep_ix_fast path")
    else:
        print("WARN: dep_ix_fast path not found")

    path.write_text(t)
    print("wrote", path, path.stat().st_size)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
