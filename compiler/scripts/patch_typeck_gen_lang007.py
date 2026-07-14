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
  /* LANG-007: delegate to C glue for import binding call resolve + unsafe boundary. */
  extern int32_t pipeline_typeck_check_expr_method_call_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
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
                if "pipeline_typeck_check_expr_method_call_c" in old and name == "typeck_check_expr_method_call":
                    return src, False
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
    """Add region (unsafe block) handling to typeck_func_body_tail_expr_ref_for_implicit_rule.

    Seed lacks handling for stmt_order kind 5/6 (region) as last statement.
    When a function body ends with unsafe { return ... }, the seed doesn't
    find the return and reports false "implicit tail return" error.
    Fix: add region check after the expr_stmt (kind 2) check.
    Idempotent: skip if 'region_c_parser' already present.
    """
    marker = "(uint8_t)(5)"
    fn_sig = "int32_t typeck_func_body_tail_expr_ref_for_implicit_rule(struct ast_ASTArena * arena, int32_t body_ref) {"
    pos = src.find(fn_sig)
    if pos < 0:
        return src, False
    # Check if already patched
    fn_end = src.find("\n}\n", pos)
    if fn_end < 0:
        return src, False
    fn_body = src[pos:fn_end]
    if marker in fn_body:
        return src, False  # already patched

    # Insert region handling after the expr_stmt (kind 2) check
    # The pattern: after the kind==2 block closes, before "return 0;"
    insert_point = ' } else (__tmp = 0) ; __tmp; }));\n  return 0;\n } else (__tmp = 0) ; __tmp; }));'

    region_code = """ } else (__tmp = 0) ; __tmp; }));
  /* G-02f-477: region (unsafe block) as last stmt — check inner block for explicit return */
  extern int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *a, int32_t br, int32_t ri);
  extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
  (void)(({ int __tmp = 0; if (last_k == ((uint8_t)(5)) || last_k == ((uint8_t)(6))) {   int32_t ridx = ast_block_stmt_order_idx(arena, body_ref, nso - 1);
  int32_t nreg = ast_block_num_regions(arena, body_ref);
  __tmp = ({ int __tmp = 0; if (ridx >= 0 && ridx < nreg) {   int32_t unsafe_region = pipeline_block_region_is_unsafe(arena, body_ref, ridx);
  __tmp = ({ int __tmp = 0; if (unsafe_region != 0) {   int32_t inner_ref = pipeline_block_region_body_ref(arena, body_ref, ridx);
  __tmp = ({ int __tmp = 0; if ((!ast_ref_is_null(inner_ref))) {   return typeck_func_body_tail_expr_ref_for_implicit_rule(arena, inner_ref);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));"""

    if insert_point in src[pos:fn_end+4]:
        new_src = src[:pos] + src[pos:fn_end+4].replace(insert_point, region_code, 1) + src[fn_end+4:]
        return new_src, True
    return src, False



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


def patch_string_lit_dispatch(src: str) -> tuple[str, bool]:
    """Add EXPR_STRING_LIT (kind 59) handling to typeck_check_expr_impl.

    Seed lacks string_lit dispatch; assign/let of \"\" then leave resolved_type_ref=0
    (found ?). Align with typeck.x + glue: prefer expected return_type_ref, else u8[].
    Idempotent via marker typeck_check_expr_string_lit.
    """
    marker = "typeck_check_expr_string_lit"
    if marker in src and "ord_string_lit" in src:
        return src, False

    # Insert helper before typeck_check_expr_impl definition if missing.
    if marker not in src:
        helper = (
            "int32_t typeck_check_expr_string_lit(struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref) {\n"
            "  int32_t u8r = 0;\n"
            "  int32_t slice_u8 = 0;\n"
            "  (void)(({ int32_t __tmp = 0; if (arena == ((struct ast_ASTArena *)(0)) || expr_ref <= 0 || expr_ref > (arena)->num_exprs) {   return 0;\n"
            " } else (__tmp = 0) ; __tmp; }));\n"
            "  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(return_type_ref)) && return_type_ref > 0 && return_type_ref <= (arena)->num_types) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref));\n"
            "  return 0;\n"
            " } else (__tmp = 0) ; __tmp; }));\n"
            "  (u8r = (typeck_ensure_u8_type_ref(arena)));\n"
            "  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(u8r)) {   return (-1);\n"
            " } else (__tmp = 0) ; __tmp; }));\n"
            "  (slice_u8 = (typeck_find_or_alloc_slice_type_ref(arena, u8r)));\n"
            "  (void)(({ int32_t __tmp = 0; if ((!ast_ref_is_null(slice_u8))) {   (void)(pipeline_expr_set_resolved_type_ref(arena, expr_ref, slice_u8));\n"
            " } else (__tmp = 0) ; __tmp; }));\n"
            "  return 0;\n"
            "}\n"
        )
        anchor = "int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {"
        apos = src.find(anchor)
        if apos < 0:
            return src, False
        src = src[:apos] + helper + src[apos:]

    # Inject ord + dispatch into typeck_check_expr_impl body.
    impl_sig = "int32_t typeck_check_expr_impl(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {"
    pos = src.find(impl_sig)
    if pos < 0:
        return src, False
    if "ord_string_lit" in src[pos:pos + 1200]:
        return src, True if marker in src else False

    # Add local after ord_bool
    old_locals = "  int32_t ord_bool = 2;\n  int32_t ord_if = 25;"
    new_locals = "  int32_t ord_bool = 2;\n  int32_t ord_string_lit = 59;\n  int32_t ord_if = 25;"
    if old_locals not in src[pos:pos + 800]:
        return src, False
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
        return src, False
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
        print("patch_typeck_gen_lang007: patched string_lit (kind 59) dispatch")
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
