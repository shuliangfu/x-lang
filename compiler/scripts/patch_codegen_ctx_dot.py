#!/usr/bin/env python3
"""Patch codegen_gen.c: skip name-fallback -> when param type is known value."""
from pathlib import Path
import sys

def main() -> int:
    p = Path(sys.argv[1] if len(sys.argv) > 1 else "codegen_gen.c")
    t = p.read_text()

    proto = (
        "int32_t codegen_field_access_base_param_type_known("
        "struct ast_ASTArena * arena, int32_t base_ref, "
        "struct ast_Module * mod, int32_t func_index);\n"
    )
    if "codegen_field_access_base_param_type_known" not in t.split("XLANG_LIB_WEAK")[0]:
        anchor = (
            "int32_t codegen_field_access_base_is_slice_param_name("
            "struct ast_ASTArena * arena, int32_t base_ref);\n"
        )
        if anchor not in t:
            print("no slice_param prototype", file=sys.stderr)
            return 1
        t = t.replace(anchor, proto + anchor, 1)
        print("added prototype")

    new_fn = r'''XLANG_LIB_WEAK int32_t codegen_field_access_base_param_type_known(struct ast_ASTArena * arena, int32_t base_ref, struct ast_Module * mod, int32_t func_index) {
  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > (arena)->num_exprs) {
    return 0;
  }
  if (mod == ((struct ast_Module *)(0)) || func_index < 0 || func_index >= (mod)->num_funcs) {
    return 0;
  }
  struct ast_Expr base = ast_arena_expr_get(arena, base_ref);
  if ((base).kind != ast_ExprKind_EXPR_VAR || (base).var_name_len <= 0) {
    return 0;
  }
  int32_t np = pipeline_module_func_num_params_at(mod, func_index);
  int32_t pi = 0;
  while (pi < np) {
    int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, func_index, pi);
    if (p_name_len > 0 && p_name_len == (base).var_name_len) {
      uint8_t pname_buf[32] = { 0 };
      (void)(pipeline_module_func_param_name_copy32(mod, func_index, pi, (&((pname_buf)[0]))));
      int matched = 1;
      int32_t j = 0;
      while (j < p_name_len && j < 32) {
        if ((pname_buf)[j] != (base).var_name[j]) {
          (matched = (0));
          break;
        }
        ++j;
      }
      if (matched) {
        int32_t param_ty_ref = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
        if ((!ast_ref_is_null(param_ty_ref)) && param_ty_ref > 0 && param_ty_ref <= (arena)->num_types) {
          return 1;
        }
      }
    }
    ++pi;
  }
  return 0;
}
'''

    j = t.find("XLANG_LIB_WEAK int32_t codegen_field_access_base_is_slice_param_name")
    if j < 0:
        print("slice fn not found", file=sys.stderr)
        return 1
    if "XLANG_LIB_WEAK int32_t codegen_field_access_base_param_type_known" not in t:
        t = t[:j] + new_fn + t[j:]
        print("inserted param_type_known fn")
    else:
        print("fn already present")

    old = (
        "  { int32_t is_ptr_base = codegen_field_access_base_is_pointer_ref(arena, (e).field_access_base_ref);\n"
        "    if (is_ptr_base == 0 && (ctx) != ((struct ast_PipelineDepCtx *)(0)) && "
        "(ctx)->current_codegen_module != ((struct ast_Module *)(0)) && "
        "(ctx)->current_func_index >= 0) {\n"
        "      is_ptr_base = codegen_field_access_base_is_pointer_param("
        "arena, (e).field_access_base_ref, (ctx)->current_codegen_module, "
        "(ctx)->current_func_index);\n"
        "    }\n"
        "    if (is_ptr_base == 0 && codegen_field_access_base_type_resolved("
        "arena, (e).field_access_base_ref) == 0) {\n"
        "      if (codegen_field_access_base_is_slice_param_name("
        "arena, (e).field_access_base_ref) != 0) {\n"
        "        is_ptr_base = 1;\n"
        "      }\n"
        "    }"
    )
    new = (
        "  { int32_t is_ptr_base = codegen_field_access_base_is_pointer_ref(arena, (e).field_access_base_ref);\n"
        "    int32_t param_type_known = 0;\n"
        "    if ((ctx) != ((struct ast_PipelineDepCtx *)(0)) && "
        "(ctx)->current_codegen_module != ((struct ast_Module *)(0)) && "
        "(ctx)->current_func_index >= 0) {\n"
        "      if (is_ptr_base == 0) {\n"
        "        is_ptr_base = codegen_field_access_base_is_pointer_param("
        "arena, (e).field_access_base_ref, (ctx)->current_codegen_module, "
        "(ctx)->current_func_index);\n"
        "      }\n"
        "      param_type_known = codegen_field_access_base_param_type_known("
        "arena, (e).field_access_base_ref, (ctx)->current_codegen_module, "
        "(ctx)->current_func_index);\n"
        "    }\n"
        "    if (is_ptr_base == 0 && param_type_known == 0 && "
        "codegen_field_access_base_type_resolved(arena, (e).field_access_base_ref) == 0) {\n"
        "      if (codegen_field_access_base_is_slice_param_name("
        "arena, (e).field_access_base_ref) != 0) {\n"
        "        is_ptr_base = 1;\n"
        "      }\n"
        "    }"
    )
    if old not in t:
        if "param_type_known = codegen_field_access_base_param_type_known" in t:
            print("arrow logic already patched")
        else:
            print("arrow logic pattern not found", file=sys.stderr)
            return 1
    else:
        t = t.replace(old, new, 1)
        print("patched arrow logic")

    p.write_text(t)
    print("wrote", p, p.stat().st_size)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
