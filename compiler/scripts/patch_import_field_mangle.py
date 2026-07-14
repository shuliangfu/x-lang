#!/usr/bin/env python3
"""Root-fix: binding field as callee must mangle overloads (heap.alloc -> alloc_usize)."""
from pathlib import Path
import sys

def main() -> int:
    p = Path(sys.argv[1] if len(sys.argv) > 1 else "codegen_gen.c")
    t = p.read_text()

    # 1) Add static parent call ref near top after includes / first SHUX_LIB_WEAK block
    if "g_codegen_parent_call_expr_ref" not in t:
        # after first function or after globals
        marker = "#define SHUX_LIB_WEAK __attribute__((weak))\n#endif\n"
        if marker not in t:
            marker = "#endif\n#ifndef SHUX_BUILTIN_INLINE_DECLS_GUARD\n"
        # put after SHUX_LIB_WEAK define
        idx = t.find("SHUX_LIB_WEAK")
        # find end of that #else/#endif block
        ins_at = t.find("\n", t.find("#endif", idx)) + 1
        t = (
            t[:ins_at]
            + "\n/* parent CALL expr when emitting callee FIELD_ACCESS (overload mangle). */\n"
            + "static int32_t g_codegen_parent_call_expr_ref = 0;\n"
            + t[ins_at:]
        )
        print("added parent call static")

    # 2) Set parent call ref in CALL fallback before emit_expr_as_callee
    old_call = (
        "  int32_t saved_callee_flag = 0;\n"
        "  if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   "
        "(saved_callee_flag = ((ctx)->emit_expr_as_callee));\n"
        "  ((ctx)->emit_expr_as_callee = (1));\n"
        " }\n"
        "  if ((!ast_ref_is_null((e).call_callee_ref)) && "
        "codegen_emit_expr(arena, out, (e).call_callee_ref, ctx) != 0) {   "
        "if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   "
        "((ctx)->emit_expr_as_callee = (saved_callee_flag));\n"
        " }\n"
        "  return (-1);\n"
        " }\n"
        "  if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   "
        "((ctx)->emit_expr_as_callee = (saved_callee_flag));\n"
        " }"
    )
    new_call = (
        "  int32_t saved_callee_flag = 0;\n"
        "  int32_t saved_parent_call = g_codegen_parent_call_expr_ref;\n"
        "  if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   "
        "(saved_callee_flag = ((ctx)->emit_expr_as_callee));\n"
        "  ((ctx)->emit_expr_as_callee = (1));\n"
        " }\n"
        "  g_codegen_parent_call_expr_ref = expr_ref;\n"
        "  if ((!ast_ref_is_null((e).call_callee_ref)) && "
        "codegen_emit_expr(arena, out, (e).call_callee_ref, ctx) != 0) {   "
        "if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   "
        "((ctx)->emit_expr_as_callee = (saved_callee_flag));\n"
        " }\n"
        "  g_codegen_parent_call_expr_ref = saved_parent_call;\n"
        "  return (-1);\n"
        " }\n"
        "  if (ctx != ((struct ast_PipelineDepCtx *)(0))) {   "
        "((ctx)->emit_expr_as_callee = (saved_callee_flag));\n"
        " }\n"
        "  g_codegen_parent_call_expr_ref = saved_parent_call;"
    )
    if old_call not in t:
        print("WARN: CALL fallback pattern not found", file=sys.stderr)
    else:
        t = t.replace(old_call, new_call, 1)
        print("patched CALL parent ref")

    # 3) Fix emit_import_module_field_symbol to mangle when parent call known
    old_sym = (
        "  if (plen > 0 && codegen_c_prefix_redundant_with_name((&((pre)[0])), plen, "
        "(&(((e).field_access_field_name)[0])), (e).field_access_field_len) == 0 && "
        "codegen_emit_bytes_from_ptr(out, (&((pre)[0])), plen) != 0) {   return (-1);\n"
        " }\n"
        "  if ((e).field_access_field_len > 0 && codegen_emit_bytes_from_ptr(out, "
        "(&(((e).field_access_field_name)[0])), (e).field_access_field_len) != 0) {   return (-1);\n"
        " }\n"
        "  return 0;\n"
        "}\n"
        "SHUX_LIB_WEAK int32_t codegen_emit_import_module_const_field"
    )
    new_sym = (
        "  if (plen > 0 && codegen_c_prefix_redundant_with_name((&((pre)[0])), plen, "
        "(&(((e).field_access_field_name)[0])), (e).field_access_field_len) == 0 && "
        "codegen_emit_bytes_from_ptr(out, (&((pre)[0])), plen) != 0) {   return (-1);\n"
        " }\n"
        "  /* callee of CALL: mangle overloads (heap.alloc -> alloc_usize). */\n"
        "  if (g_codegen_parent_call_expr_ref > 0 && (e).field_access_field_len > 0) {\n"
        "    int32_t dep_ix = codegen_find_dep_index_by_path(ctx, (&((dep_path)[0])), dep_path_len);\n"
        "    struct ast_Module * dep_mod = (ctx)->current_codegen_module;\n"
        "    if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {\n"
        "      dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);\n"
        "    }\n"
        "    if (codegen_emit_call_func_name(out, arena, ctx, g_codegen_parent_call_expr_ref, "
        "dep_mod, (&(((e).field_access_field_name)[0])), (e).field_access_field_len) != 0) {\n"
        "      return (-1);\n"
        "    }\n"
        "    return 0;\n"
        "  }\n"
        "  if ((e).field_access_field_len > 0 && codegen_emit_bytes_from_ptr(out, "
        "(&(((e).field_access_field_name)[0])), (e).field_access_field_len) != 0) {   return (-1);\n"
        " }\n"
        "  return 0;\n"
        "}\n"
        "SHUX_LIB_WEAK int32_t codegen_emit_import_module_const_field"
    )
    if old_sym not in t:
        print("WARN: import field symbol pattern not found", file=sys.stderr)
        # try partial
        if "callee of CALL: mangle overloads" in t:
            print("already mangled")
        else:
            return 1
    else:
        t = t.replace(old_sym, new_sym, 1)
        print("patched import field symbol mangle")

    p.write_text(t)
    print("wrote", p.stat().st_size)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
