#!/usr/bin/env python3
"""Patch typeck_gen.c so LANG-007 S0 boundaries always hit pipeline_glue paths.

typeck_gen.c is gitignored / host-local. Older seeds implement typeck_check_expr_call /
typeck_check_expr_deref inline and skip pipeline_typeck_check_*_c (which enforce
unsafe {}). This script rewrites those weak exports to delegate to the glue paths.

Idempotent. Exit 0 always when file missing or already patched; exit 2 on parse fail.
"""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
PATH = ROOT / "typeck_gen.c"

# LANG-007 + selfhost: -E seed regen sets allow_legacy so compiler sources can
# call pipeline_* externs without wrapping every site in unsafe { } yet.
# Default (allow=0) still enforces S0 via glue boundary.
ALLOW_LEGACY_HELPERS = """\
/* SHUX_ALLOW_LEGACY_EXTERN: typeck_set_allow_legacy_extern_calls (seed regen / -E). */
static int g_typeck_allow_legacy_extern_calls = 0;
int typeck_set_allow_legacy_extern_calls(int allow) {
  int old = g_typeck_allow_legacy_extern_calls;
  g_typeck_allow_legacy_extern_calls = allow ? 1 : 0;
  return old;
}
int typeck_get_allow_legacy_extern_calls(void) {
  return g_typeck_allow_legacy_extern_calls;
}
"""

CALL_BODY = """\
int32_t typeck_check_expr_call(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  /* LANG-007: glue path enforces S0 extern-in-unsafe; allow_legacy skips boundary for -E regen. */
  extern int32_t pipeline_typeck_check_expr_call_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  extern int32_t pipeline_typeck_resolve_call_callee_return_type_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t callee_ref, int32_t expr_ref, struct ast_PipelineDepCtx *ctx);
  if (g_typeck_allow_legacy_extern_calls) {
    int32_t rc;
    int32_t callee_ref;
    int32_t ret_ty;
    rc = typeck_check_expr_call_arg(module, arena, expr_ref, return_type_ref, ctx, 0,
                                    pipeline_expr_call_num_args_at(arena, expr_ref));
    if (rc != 0) return rc;
    rc = typeck_check_expr_call_resolve(module, arena, expr_ref, ctx);
    if (rc != 0) return rc;
    if (ast_ref_is_null(pipeline_expr_resolved_type_ref(arena, expr_ref))) {
      callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
      ret_ty = pipeline_typeck_resolve_call_callee_return_type_c(module, arena, callee_ref, expr_ref, ctx);
      if (ret_ty != 0)
        (void)pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty);
    }
    return 0;
  }
  return pipeline_typeck_check_expr_call_c(module, arena, expr_ref, return_type_ref, ctx);
}
"""

DEREF_BODY = """\
int32_t typeck_check_expr_deref(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  /* LANG-007: always use glue path (S0 deref requires unsafe). */
  extern int32_t pipeline_typeck_check_expr_deref_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  return pipeline_typeck_check_expr_deref_c(module, arena, expr_ref, return_type_ref, ctx);
}
"""

METHOD_CALL_BODY = """\
int32_t typeck_check_expr_method_call(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  /* W-heap-overload: glue method_call then re-dispatch binding overload by arg types. */
  extern int32_t pipeline_typeck_check_expr_method_call_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  extern int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
  extern int32_t pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref);
  extern void pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
  extern int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
  extern int32_t pipeline_typeck_import_binding_name_equal_strict_minimal(struct ast_Module *m, int32_t ii, uint8_t *nm, int32_t nlen);
  extern int32_t pipeline_typeck_find_func_return_type_in_module_by_name_call_strict_minimal(
      struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len,
      int32_t from_dep_index, int32_t want_arity, int32_t call_expr_ref, int32_t is_method,
      struct ast_PipelineDepCtx *ctx, int32_t *func_index_out);
  int32_t rc;
  int32_t base_ref;
  int32_t base_kind;
  int32_t base_nlen;
  int32_t method_nlen;
  int32_t num_args;
  int32_t ii;
  int32_t import_kind;
  int32_t import_ret_ty;
  int32_t func_ix;
  int32_t dep_ix;
  uint8_t method_nm[64];
  uint8_t base_nm[64];
  struct ast_Module *dm;
  rc = pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
  if (rc != 0 || !module || !arena || !ctx || expr_ref <= 0)
    return rc;
  base_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
  if (base_ref <= 0)
    return rc;
  base_kind = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_kind != 3)
    return rc;
  method_nlen = pipeline_expr_method_call_name_len(arena, expr_ref);
  if (method_nlen <= 0 || method_nlen > 63)
    return rc;
  pipeline_expr_method_call_name_into(arena, expr_ref, method_nm);
  num_args = pipeline_expr_method_call_num_args_at(arena, expr_ref);
  base_nlen = pipeline_expr_var_name_len(arena, base_ref);
  if (base_nlen <= 0 || base_nlen > 63)
    return rc;
  pipeline_expr_var_name_into(arena, base_ref, base_nm);
  for (ii = 0; ii < module->num_imports; ii++) {
    import_kind = pipeline_module_import_kind_at(module, ii);
    if (import_kind != 1)
      continue;
    if (!pipeline_typeck_import_binding_name_equal_strict_minimal(module, ii, base_nm, base_nlen))
      continue;
    dm = pipeline_dep_ctx_module_at(ctx, ii);
    if (!dm)
      break;
    func_ix = -1;
    import_ret_ty = pipeline_typeck_find_func_return_type_in_module_by_name_call_strict_minimal(
        dm, arena, method_nm, method_nlen, ii, num_args, expr_ref, 1, ctx, &func_ix);
    if (import_ret_ty > 0) {
      dep_ix = ii;
      (void)ast_expr_apply_call_resolve(arena, expr_ref, dep_ix, func_ix);
      (void)pipeline_expr_set_resolved_type_ref(arena, expr_ref, import_ret_ty);
    }
    break;
  }
  return 0;
}
"""

EXPR_BLOCK_BODY = """\
int32_t typeck_check_expr_block(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  int32_t ord_assign = 28;
  int32_t block_ref = pipeline_expr_block_ref_at(arena, expr_ref);
  int32_t fin_blk = 0;
  int32_t ty_fin = 0;
  int32_t nes = 0;
  int32_t fst_es = 0;
  int32_t st_kind = 0;
  int32_t rhs_ref = 0;
  int32_t ty_rhs = 0;
  int32_t saved_ud = 0;
  int32_t blk_rc = 0;
  extern int32_t pipeline_typeck_unsafe_depth_push_c(struct ast_PipelineDepCtx *ctx);
  extern void pipeline_typeck_unsafe_depth_pop_c(struct ast_PipelineDepCtx *ctx, int32_t saved);
  saved_ud = pipeline_typeck_unsafe_depth_push_c(ctx);
  blk_rc = typeck_check_block(module, arena, block_ref, return_type_ref, ctx);
  pipeline_typeck_unsafe_depth_pop_c(ctx, saved_ud);
  if (blk_rc != 0) { return (-1); }
  if (ast_ref_is_null(block_ref) || block_ref <= 0) { return 0; }
  fin_blk = pipeline_asm_block_final_expr_ref_at(arena, block_ref);
  if (!ast_ref_is_null(fin_blk)) {
    ty_fin = typeck_expr_type_ref(arena, fin_blk);
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, ty_fin);
    return 0;
  }
  nes = ast_block_num_expr_stmts(arena, block_ref);
  if (nes != 1) { return 0; }
  fst_es = pipeline_block_expr_stmt_ref(arena, block_ref, 0);
  if (fst_es <= 0) { return 0; }
  st_kind = pipeline_expr_kind_ord_at(arena, fst_es);
  if (st_kind != ord_assign && st_kind < 29 || st_kind > 39) { return 0; }
  rhs_ref = pipeline_expr_binop_right_ref_at(arena, fst_es);
  if (ast_ref_is_null(rhs_ref)) { return 0; }
  ty_rhs = typeck_expr_type_ref(arena, rhs_ref);
  pipeline_expr_set_resolved_type_ref(arena, expr_ref, ty_rhs);
  return 0;
}
"""

BLOCK_BODY = """\
int32_t typeck_check_block_one_region(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx) {
  /* LANG-007: C 委托 pipeline_typeck_check_block_one_region_c 内部已做 unsafe depth push/pop，
   *           直接委托即可，禁止 double push（会导致 g_typeck_unsafe_depth 多增 1）。 */
  extern int32_t pipeline_typeck_check_block_one_region_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref, int32_t region_idx, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  return pipeline_typeck_check_block_one_region_c(module, arena, block_ref, idx, return_type_ref, ctx);
}
"""


def replace_weak_fn(src: str, name: str, new_body: str) -> tuple[str, bool]:
    """Replace (SHUX_LIB_WEAK)? int32_t <name>(...) { ... } balanced braces.

    【Why 根源】-E-extern 生成的 typeck_gen.c 用普通 int32_t（无 SHUX_LIB_WEAK 前缀），
    旧正则只匹配 int32_t 导致补丁从未生效。LANG-007 S0 守卫缺失。
    """
    pat = re.compile(
        rf"((?:SHUX_LIB_WEAK\s+)?int32_t\s+{re.escape(name)}\s*\([^;]*?\)\s*\{{)",
        re.M | re.S,
    )
    m = pat.search(src)
    if not m:
        return src, False
    start = m.start()
    brace_at = m.end() - 1  # points at '{'
    i = brace_at
    depth = 0
    while i < len(src):
        c = src[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                end = i + 1
                old = src[start:end]
                if name == "typeck_check_expr_call":
                    if "g_typeck_allow_legacy_extern_calls" in old:
                        return src, False  # already allow_legacy + glue path
                    # else replace (old glue-only or inline body)
                elif "pipeline_typeck_check_expr_deref_c" in old and name == "typeck_check_expr_deref":
                    return src, False
                if "pipeline_typeck_check_block_one_region_c" in old and name == "typeck_check_block_one_region":
                    return src, False
                if "pipeline_typeck_unsafe_depth_push_c" in old and name == "typeck_check_expr_block":
                    return src, False
                if name == "typeck_check_expr_method_call":
                    # W-heap-overload body contains the call_strict_minimal symbol; old body only
                    # delegated to pipeline_typeck_check_expr_method_call_c.
                    if "by_name_call_strict_minimal" in old or "W-heap-overload" in old:
                        return src, False
                    # else rewrite short LANG-007 delegate → arg-type dispatch
                return src[:start] + new_body.rstrip() + "\n" + src[end:], True
        i += 1
    raise RuntimeError(f"unbalanced braces for {name}")


def insert_block_final_skip(src: str) -> tuple[str, bool]:
    """在 typeck_check_block_final 的 fin_k_tail 赋值后插入 != 41 skip 守卫。

    【Why 根源】S0_region 修复：只有 return 表达式（kind 41）才做尾类型比较，
    其余 kind（39/40/assign/其他）一律跳过。旧 seed 三分支 if 漏掉非 39/40/assign 的
    非 41 kind（如字面量、var 等），导致误报 return type mismatch。
    【Invariant】幂等：若 body 已含 'fin_k_tail != 41' 则跳过。
    """
    sig_pat = re.compile(
        r"(int32_t\s+typeck_check_block_final\s*\([^;]*?\)\s*\{)",
        re.M | re.S,
    )
    m = sig_pat.search(src)
    if not m:
        return src, False
    start = m.start()
    brace_at = m.end() - 1
    i = brace_at
    depth = 0
    end = -1
    while i < len(src):
        c = src[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                end = i + 1
                break
        i += 1
    if end < 0:
        raise RuntimeError("unbalanced braces for typeck_check_block_final")
    body = src[start:end]
    if "fin_k_tail != 41" in body:
        return src, False  # already patched
    assign_pat = re.compile(
        r"(\(fin_k_tail = \(pipeline_expr_kind_ord_at\(arena, fin0\)\)\);)",
        re.M,
    )
    am = assign_pat.search(body)
    if not am:
        return src, False  # 结构不符，跳过
    insert_pos = am.end()
    guard = (
        "\n  /* LANG-007 S0_region: 只有 return 表达式（kind 41）才做尾类型比较；"
        "\n   * 其余 kind 一律 skip，避免字面量/var 等误报 return type mismatch。 */"
        "\n  if (fin_k_tail != 41) { skip_tail_ty_cmp = 1; }"
    )
    new_body = body[:insert_pos] + guard + body[insert_pos:]
    return src[:start] + new_body + src[end:], True



def swap_var_param_order(src: str) -> tuple[str, bool]:
    """Swap top_level_let check and func_param check in typeck_check_expr_var.

    Parser bug may put function-local lets into module.num_top_level_lets,
    causing cross-function variable name leakage. Moving func_param check
    before top_level_let check ensures function parameters are found first.
    Idempotent.
    """
    # The original order in seed: top_level_lets block, then func_param block
    # Target order: func_param block first, then top_level_lets block
    tl_block = (
        "  (void)(({ int32_t __tmp = 0; if ((module)->num_top_level_lets > 0) {"
        "   __tmp = ({ int32_t __tmp = 0; if (typeck_check_expr_var_top_level"
        "(module, arena, expr_ref, vbuf, vnlen, 0) != 0) { return 0;\n"
        " } else (__tmp = 0) ; __tmp; });\n"
        " } else (__tmp = 0) ; __tmp; }));\n"
    )
    fp_block = (
        "  (func_ix = (pipeline_dep_ctx_current_func_index(ctx)));\n"
        "  (void)(({ int32_t __tmp = 0; if (func_ix >= 0 && func_ix < (module)->num_funcs) {"
        "   (pr = (pipeline_module_func_param_type_ref_for_name(module, func_ix, vbuf, vnlen)));\n"
        "  __tmp = ({ int32_t __tmp = 0; if (pr != 0) {"
        "   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, pr));\n"
        "  (void)(({ int32_t __tmp = 0; if (pipeline_typeck_linear_use_var_c"
        "(arena, pr, expr_ref, vbuf, vnlen) != 0) {   return (-1);\n"
        " } else (__tmp = 0) ; __tmp; }));\n"
        "  return 0;\n"
        " } else (__tmp = 0) ; __tmp; });\n"
        " } else (__tmp = 0) ; __tmp; }));\n"
    )
    # Check if already swapped: fp_block before tl_block
    fp_pos = src.find(fp_block)
    tl_pos = src.find(tl_block)
    if fp_pos < 0 or tl_pos < 0:
        return src, False
    if fp_pos < tl_pos:
        return src, False  # already swapped
    # Swap: replace tl_block + fp_block with fp_block + tl_block
    combined = tl_block + fp_block
    swapped = fp_block + tl_block
    new_src = src.replace(combined, swapped, 1)
    if new_src == src:
        return src, False
    return new_src, True



def patch_implicit_tail_region(src: str) -> tuple[str, bool]:
    """Ensure W-tail ordered tail finder (terminal final, else region peel).

    Replace the whole function when missing marker "W-tail order:".
    """
    marker = "W-tail order:"
    fn_sig = "int32_t typeck_func_body_tail_expr_ref_for_implicit_rule(struct ast_ASTArena * arena, int32_t body_ref) {"
    pos = src.find(fn_sig)
    if pos < 0:
        return src, False
    # Find end of this function: next top-level fn after matching braces is fragile;
    # use known successor symbol from typeck_gen.
    nxt = src.find("\nint typeck_func_body_has_implicit_return_tail(", pos)
    if nxt < 0:
        return src, False
    if marker in src[pos:nxt]:
        return src, False

    new_fn = """int32_t typeck_func_body_tail_expr_ref_for_implicit_rule(struct ast_ASTArena * arena, int32_t body_ref) {
  /* W-tail order:
   * 1) final RETURN/PANIC/BREAK/CONTINUE wins (return after unsafe assign).
   * 2) else peel trailing unsafe region (sole unsafe{return} may leave stale EXPR_LIT final).
   * 3) else final / expr_stmt / last expr_stmt. */
  extern int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *a, int32_t br, int32_t ri);
  extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
  int32_t nso = ast_block_num_stmt_order(arena, body_ref);
  int32_t fin_ref = ast_block_final_expr_ref(arena, body_ref);
  if (!ast_ref_is_null(fin_ref)) {
    int32_t fin_kind = pipeline_expr_kind_ord_at(arena, fin_ref);
    if (fin_kind == 41 || fin_kind == 42 || fin_kind == 39 || fin_kind == 40)
      return fin_ref;
  }
  if (nso > 0) {
    uint8_t last_k = ast_block_stmt_order_kind(arena, body_ref, nso - 1);
    if (last_k == ((uint8_t)(5)) || last_k == ((uint8_t)(6))) {
      int32_t ridx = ast_block_stmt_order_idx(arena, body_ref, nso - 1);
      int32_t nreg = ast_block_num_regions(arena, body_ref);
      if (ridx >= 0 && ridx < nreg) {
        int32_t unsafe_region = pipeline_block_region_is_unsafe(arena, body_ref, ridx);
        if (unsafe_region != 0) {
          int32_t inner_ref = pipeline_block_region_body_ref(arena, body_ref, ridx);
          if (!ast_ref_is_null(inner_ref))
            return typeck_func_body_tail_expr_ref_for_implicit_rule(arena, inner_ref);
        }
      }
    }
  }
  if (!ast_ref_is_null(fin_ref))
    return fin_ref;
  if (nso > 0) {
    uint8_t last_k2 = ast_block_stmt_order_kind(arena, body_ref, nso - 1);
    if (last_k2 == ((uint8_t)(2))) {
      int32_t idx = ast_block_stmt_order_idx(arena, body_ref, nso - 1);
      int32_t nes = ast_block_num_expr_stmts(arena, body_ref);
      if (idx >= 0 && idx < nes)
        return ast_block_expr_stmt_ref(arena, body_ref, idx);
    }
    return 0;
  }
  {
    int32_t nes2 = ast_block_num_expr_stmts(arena, body_ref);
    if (nes2 > 0)
      return ast_block_expr_stmt_ref(arena, body_ref, nes2 - 1);
  }
  return 0;
}
"""
    new_src = src[:pos] + new_fn + src[nxt + 1 :]
    return new_src, True



def patch_tail_debug_print(src: str) -> tuple[str, bool]:
    """Add debug print to typeck_func_body_has_implicit_return_tail (SHUX_DEBUG_TAIL).
    Idempotent.
    """
    marker = "SHUX_DEBUG_TAIL"
    fn_sig = "int typeck_func_body_has_implicit_return_tail(struct ast_ASTArena * arena, int32_t body_ref) {"
    pos = src.find(fn_sig)
    if pos < 0:
        return src, False
    # Check if already patched
    fn_end = src.find("\n}\n", pos)
    if fn_end < 0:
        return src, False
    if marker in src[pos:fn_end]:
        return src, False
    # Insert debug print after tail_ref assignment
    target = "  int32_t tail_ref = typeck_func_body_tail_expr_ref_for_implicit_rule(arena, body_ref);\n"
    if target not in src[pos:fn_end]:
        return src, False
    debug_line = '  if (getenv("SHUX_DEBUG_TAIL")) { int32_t _tk = (tail_ref > 0 && tail_ref <= (arena)->num_exprs) ? pipeline_expr_kind_ord_at(arena, tail_ref) : -1; int32_t _ib = (_tk == 26 && tail_ref > 0) ? pipeline_expr_block_ref_at(arena, tail_ref) : 0; fprintf(stderr, "DBG-TAIL body=%d tail=%d kind=%d inner=%d\\n", (int)body_ref, (int)tail_ref, (int)_tk, (int)_ib); }\n'
    new_src = src[:pos] + src[pos:fn_end].replace(target, target + debug_line, 1) + src[fn_end:]
    return new_src, True



def patch_var_debug_print(src: str) -> tuple[str, bool]:
    """Add SHUX_DEBUG_VAR trace to typeck_check_expr_var func_param lookup."""
    marker = "SHUX_DEBUG_VAR"
    fn_sig = "int32_t typeck_check_expr_var(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {"
    pos = src.find(fn_sig)
    if pos < 0:
        return src, False
    # First occurrence is the definition (forward declaration has ; not {)
    # Find function end by counting braces
    brace_at = src.find("{", pos)
    if brace_at < 0:
        return src, False
    depth = 0
    i = brace_at
    fn_end = -1
    while i < len(src):
        if src[i] == "{":
            depth += 1
        elif src[i] == "}":
            depth -= 1
            if depth == 0:
                fn_end = i + 1
                break
        i += 1
    if fn_end < 0:
        return src, False
    if marker in src[pos:fn_end]:
        return src, False
    target = "(func_ix = (pipeline_dep_ctx_current_func_index(ctx)));"
    tpos = src.find(target, pos)
    if tpos < 0 or tpos > fn_end:
        return src, False
    debug = '\n  if (getenv("SHUX_DEBUG_VAR")) { int32_t _pr = (func_ix >= 0 && func_ix < (module)->num_funcs) ? pipeline_module_func_param_type_ref_for_name(module, func_ix, vbuf, vnlen) : -99; fprintf(stderr, "DBG-VAR fix=%d vnlen=%d nfuncs=%d pr=%d\\n", (int)func_ix, (int)vnlen, (int)(module)->num_funcs, (int)_pr); }'
    new_src = src[:tpos] + src[tpos:tpos+len(target)] + debug + src[tpos+len(target):]
    return new_src, True


# Canonical STRING_LIT checker (align typeck.x + pipeline_glue):
# - adopt expected type only when PTR/ARRAY/SLICE
# - default *u8 (not u8[]), so m = "" / call(*u8) do not become TYPE_SLICE
STRING_LIT_HELPER_BODY = (
    "int32_t typeck_check_expr_string_lit(struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref) {\n"
    "  int32_t u8r = 0;\n"
    "  int32_t slice_u8 = 0;\n"
    "  int32_t exp_kind = 0;\n"
    "  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;\n"
    " } else (__tmp = 0) ; __tmp; }));\n"
    "  /* Only adopt expected type when it is pointer/slice/array (string target); never void/i64/func return. */\n"
    "  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref)) && return_type_ref > 0 && return_type_ref <= (arena)->num_types) {\n"
    "    exp_kind = pipeline_type_kind_ord_at(arena, return_type_ref);\n"
    "    /* TYPE_PTR=9 TYPE_ARRAY=10 TYPE_SLICE=11 */\n"
    "    if (exp_kind == 9 || exp_kind == 10 || exp_kind == 11) {\n"
    "      (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref));\n"
    "      return 0;\n"
    "    }\n"
    " } else (__tmp = 0) ; __tmp; }));\n"
    "  (u8r = (typeck_ensure_u8_type_ref(arena)));\n"
    "  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(u8r)) {   return (-1);\n"
    " } else (__tmp = 0) ; __tmp; }));\n"
    "  /* Default *u8 (not u8[]): call-arg typeck still passes func return type as expected, so\n"
    "   * string args to *u8 must not become TYPE_SLICE (codegen would emit shulang_slice compound). */\n"
    "  (slice_u8 = (typeck_find_or_alloc_ptr_type_ref(arena, u8r)));\n"
    "  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(slice_u8))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, slice_u8));\n"
    " } else (__tmp = 0) ; __tmp; }));\n"
    "  return 0;\n"
    "}\n"
)


def patch_string_lit_body(src: str) -> tuple[str, bool]:
    """Rewrite existing typeck_check_expr_string_lit to *u8 default + PTR/ARRAY/SLICE only.

    Old body (stale Ubuntu gen): adopt any return_type_ref + default u8[] →
    m = \"\" reports found ? / wrong slice. Idempotent via marker comment.
    """
    good = "Only adopt expected type when it is pointer/slice/array"
    if good in src:
        return src, False
    sig = "int32_t typeck_check_expr_string_lit(struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref) {"
    pos = src.find(sig)
    if pos < 0:
        return src, False
    # end of function: next top-level int32_t typeck_ after this body
    end = src.find("\nint32_t typeck_", pos + len(sig))
    if end < 0:
        end = src.find("\nint32_t ", pos + len(sig))
    if end < 0:
        return src, False
    return src[:pos] + STRING_LIT_HELPER_BODY + src[end + 1 :], True


def patch_string_lit_dispatch(src: str) -> tuple[str, bool]:
    """Add EXPR_STRING_LIT (kind 59) handling to typeck_check_expr_impl.

    Seed lacks string_lit dispatch; assign/let of \"\" then leave resolved_type_ref=0
    (found ?). Align with typeck.x + glue: expected PTR/ARRAY/SLICE else *u8.
    Idempotent via marker typeck_check_expr_string_lit / ord_string_lit.
    """
    changed = False
    marker = "typeck_check_expr_string_lit"

    # Always upgrade body if present but stale (before early-return on dispatch).
    src, body_did = patch_string_lit_body(src)
    if body_did:
        changed = True

    if marker in src and "ord_string_lit" in src:
        return src, changed

    # Insert helper before typeck_check_expr_impl definition if missing.
    if marker not in src:
        helper = STRING_LIT_HELPER_BODY
        anchor = "int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {"
        apos = src.find(anchor)
        if apos < 0:
            return src, changed
        src = src[:apos] + helper + src[apos:]
        changed = True

    # Inject ord + dispatch into typeck_check_expr_impl body.
    impl_sig = "int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {"
    pos = src.find(impl_sig)
    if pos < 0:
        return src, changed
    if "ord_string_lit" in src[pos:pos + 1200]:
        return src, changed

    # Add local after ord_bool
    old_locals = "  int32_t ord_bool = 2;\n  int32_t ord_if = 25;"
    new_locals = "  int32_t ord_bool = 2;\n  int32_t ord_string_lit = 59;\n  int32_t ord_if = 25;"
    if old_locals not in src[pos:pos + 800]:
        return src, changed
    src = src[:pos] + src[pos:pos + 800].replace(old_locals, new_locals, 1) + src[pos + 800:]

    # After bool_lit check, dispatch string_lit
    old_bool = (
        "  (void)(({ int32_t __tmp = 0; if (kind == ord_bool) {   return typeck_check_expr_bool_lit(arena, expr_ref);\n"
        " } else (__tmp = 0) ; __tmp; }));\n"
        "  (void)(({ int32_t __tmp = 0; if (kind == ord_break || kind == ord_continue) {"
    )
    new_bool = (
        "  (void)(({ int32_t __tmp = 0; if (kind == ord_bool) {   return typeck_check_expr_bool_lit(arena, expr_ref);\n"
        " } else (__tmp = 0) ; __tmp; }));\n"
        "  (void)(({ int32_t __tmp = 0; if (kind == ord_string_lit) {   return typeck_check_expr_string_lit(arena, expr_ref, return_type_ref);\n"
        " } else (__tmp = 0) ; __tmp; }));\n"
        "  (void)(({ int32_t __tmp = 0; if (kind == ord_break || kind == ord_continue) {"
    )
    if old_bool not in src:
        return src, changed
    src = src.replace(old_bool, new_bool, 1)
    return src, True


def insert_allow_legacy_helpers(src: str) -> tuple[str, bool]:
    """Insert typeck_set/get_allow_legacy_extern_calls once (strong symbols for -E)."""
    if "SHUX_ALLOW_LEGACY_EXTERN" in src:
        return src, False
    # Place after first includes block / before first function if possible
    marker = "/* SHUX_ALLOW_LEGACY_EXTERN"
    # Prefer after last #include
    last_inc = -1
    for m in re.finditer(r"^#include[^\n]*\n", src, re.M):
        last_inc = m.end()
    if last_inc > 0:
        return src[:last_inc] + "\n" + ALLOW_LEGACY_HELPERS + "\n" + src[last_inc:], True
    return ALLOW_LEGACY_HELPERS + "\n" + src, True


def main() -> int:
    if not PATH.is_file():
        print(f"patch_typeck_gen_lang007: skip (missing {PATH.name})")
        return 0
    src = PATH.read_text(encoding="utf-8", errors="replace")
    changed = False
    src, did = insert_allow_legacy_helpers(src)
    if did:
        print("patch_typeck_gen_lang007: inserted allow_legacy_extern helpers")
        changed = True
    else:
        print("patch_typeck_gen_lang007: allow_legacy_extern helpers already ok")
    for name, body in (
        ("typeck_check_expr_call", CALL_BODY),
        ("typeck_check_expr_deref", DEREF_BODY),
        ("typeck_check_block_one_region", BLOCK_BODY),
        ("typeck_check_expr_block", EXPR_BLOCK_BODY),
        ("typeck_check_expr_method_call", METHOD_CALL_BODY),
    ):
        src, did = replace_weak_fn(src, name, body)
        if did:
            print(f"patch_typeck_gen_lang007: rewrote {name}")
            changed = True
        else:
            print(f"patch_typeck_gen_lang007: {name} already ok or missing")
    src, did = insert_block_final_skip(src)
    if did:
        print("patch_typeck_gen_lang007: inserted block_final skip guard")
        changed = True
    else:
        print("patch_typeck_gen_lang007: block_final skip guard already ok or missing")
    src, did = swap_var_param_order(src)
    if did:
        print("patch_typeck_gen_lang007: swapped var param order (func_param before top_level_let)")
        changed = True
    else:
        print("patch_typeck_gen_lang007: var param order already ok or missing")
    src, did = patch_implicit_tail_region(src)
    if did:
        print("patch_typeck_gen_lang007: patched implicit_tail_region handling")
        changed = True
    else:
        print("patch_typeck_gen_lang007: implicit_tail_region already ok or missing")
    src, did = patch_tail_debug_print(src)
    if did:
        print("patch_typeck_gen_lang007: added tail debug print")
        changed = True
    else:
        print("patch_typeck_gen_lang007: tail debug print already ok or missing")
    src, did = patch_var_debug_print(src)
    if did:
        print("patch_typeck_gen_lang007: added var debug print")
        changed = True
    else:
        print("patch_typeck_gen_lang007: var debug print already ok or missing")
    src, did = patch_string_lit_dispatch(src)
    if did:
        print("patch_typeck_gen_lang007: patched string_lit body/dispatch (*u8 default)")
        changed = True
    else:
        print("patch_typeck_gen_lang007: string_lit dispatch already ok or missing")
    if changed:
        PATH.write_text(src, encoding="utf-8")
        print(f"patch_typeck_gen_lang007: wrote {PATH}")
    else:
        print("patch_typeck_gen_lang007: no changes")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        print(f"patch_typeck_gen_lang007 FAIL: {e}", file=sys.stderr)
        sys.exit(2)
