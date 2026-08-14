#!/usr/bin/env python3
"""post_E_fixup.py — G.7 single authority post-processing hook for driver_leaf PREFER_X_O path.

Applies FIVE root-level fixes after xlang -E produces its C output, BEFORE the
host `cc -c` step in driver_leaf_build:

0. Colliding-definition dedup (ALL leaves, always on; wave338):
   Removes duplicate function definitions and extern declarations produced by
   codegen's module-prefix collision. When two source functions map to the
   same C symbol after prefixing (e.g. main.x `run_compiler_c` → `main_` +
   `run_compiler_c` collides with the existing `main_run_compiler_c`), the
   codegen emits two definitions with the same name. The duplicate from the
   colliding source function has a body that calls the colliding name —
   i.e. calls ITSELF (infinite recursion). This pass detects such
   self-calling duplicates and removes them, keeping the correct definition.
   Also deduplicates extern declarations (keeps first occurrence per name).

1. init_globals scrub (parser_x.o only → `--scrub-init-globals` flag):
   Removes cross-module BSS assignments that belong to lexer/token/typeck/...
   compilation units from parser.x's init_globals() body. Without this scrub
   parser_x.o fails with 17+ "use of undeclared identifier g_lexer_*" because
   those globals physically live in lexer_x.o, not parser_x.o. Mirror of
   assemble_parser_gen_from_x.py._scrub_init_globals — semantic parity required.

2. Forward-declaration injection (ALL leaves, always on):
   Scans the emitted C text for every extern declaration AND every function
   definition, then prepends all unique signatures as forward-declarations
   in a single block at the top of the file. This eliminates the class of
   errors: "call to undeclared function 'X'; ISO C99 and later do not support
   implicit function declarations" caused when a file-local/static helper or
   extern-declared function is *called* before its declaration/definition
   appears linearly in the C output. xlang-x -E-extern only injects externs
   for explicitly-declared export-extern symbols; file-local helpers never
   get them; and extern decls can be emitted AFTER call sites too.

   2a. Double-prefix alias injection (ALL leaves, always on; wave338):
   codegen's `ast_` special case in `codegen_c_prefix_redundant_with_name`
   (codegen.x L3568) forces the module prefix onto `export extern` names even
   when the name already starts with the module prefix, producing ghost
   declarations like `ast_ast_arena_block_get`. Call sites within the same
   module use the single-prefix name `ast_arena_block_get` (the actual C
   symbol defined in runtime_pipeline_abi.o). External modules (pipeline.x,
   runtime_driver_diagnostic_thin.x) correctly reference the double-prefix
   name. This sub-phase keeps the double-prefix declaration AND adds the
   single-prefix alias, so internal call sites resolve. Safe: unused extern
   aliases are link-time no-ops; used aliases resolve to the real symbol.

3. Missing-body append (typeck_x.o only → `--append-typeck-bodies` flag):
   Historical pinned gen.c (typeck_gen.*.c) contained FIVE function bodies
   that the current xlang typeck.x -E emitter does not produce, even though
   runtime_pipeline_abi.o and backend_inline dispatch reference them at ld
   time.  Appending their bodies verbatim (from seed archaeology, verified
   SHARED) makes pure-ld resolve the 5 UNDEF symbols without dual-authority
   .x source duplication.  See analysis/自举进度.md wave335 for original
   diagnostic: pure-ld 58-objs relink failed because typeck_x.o lost these
   public API symbols (seed had both `pipeline_*_c` wrappers AND unprefixed
   thin-forwarder bodies; .x regressed and only emits wrappers + unprefixed
   `export extern function DECL;` stubs with no body).

Usage:
  python3 post_E_fixup.py <input.c> <output.c> [--scrub-init-globals] [--append-typeck-bodies]

PLATFORM: SHARED — pure text manipulation; stdlib only (Python 3.6+).
"""
import argparse
import os
import re
import sys


# Cross-module BSS ownership patterns (mirror assemble_parser_gen_from_x.py
# and earlier probe results: g_<module>_* globals belong to the .o that
# defines them, which is NOT parser_x.o for anything outside parser module).
# Pattern match on prefix of the assignment target.
CROSS_MODULE_G_PREFIXES = (
    "g_lexer_",
    "g_token_",
    "g_typeck_",
    "g_ast_",
    "g_codegen_",
    "g_asm_",
    "g_preprocess_",
    "g_pipeline_",
    "g_driver_",
)


# === typeck_x.o missing-body append (wave335 pure-ld root-fix) ==================
#
# ROOT CAUSE: The historical pinned typeck_gen.*.c seed contained 5 public-API
# function bodies that are NOT produced by the current xlang typeck.x -E
# emitter.  runtime_pipeline_abi.o and backend_try_inline_dispatch.o reference
# these symbols.  Without them, pure-ld (ld, no cc -o / archive merge) fails
# with:
#
#   - UNDEF _typeck_check_expr_impl_mega           (dispatcher used by pipeline ABI)
#   - UNDEF _typeck_block_const_init_is_const      (const-init scanner used internally)
#   - UNDEF _typeck_const_init_not_constant        (lsp diag thin wrapper)
#   - UNDEF _typeck_overload_expected_ret_peek     (BSS accessor)
#   - UNDEF _typeck_get_field_offset_from_layout_deps  (layout + WPO dep scan)
#
# AUTHORITY: Each body is copied VERBATIM from seeds/typeck_gen.linux.x86_64.c,
# which is the authoritative last-known-good implementation used before Track L
# retirement.  All 5 bodies are SHARED-platform POSIX C (no Windows/Ubuntu-only
# branches, no #ifdefs, no direct syscalls).  They only call functions / access
# globals that typeck.x already emits (typeck internal dispatchers, pipeline
# arena helpers, lsp_diag_report_typeck, g_typeck_overload_expected_ret BSS).
#
# RECOVERY PROOF: If xlang -E later regains the ability to emit these 5 bodies
# directly from typeck.x source, the FIRST cc -c with this post_E_fixup active
# will LOUDLY fail with "redefinition of 'X'".  That is the intended signal:
# remove the now-redundant definition from TYPECK_APPEND_BLOCK_RAW below (and
# remove the entry from the driver flag), because the source has recovered.
# Silent corruption cannot happen (duplicate symbols are hard compile errors).

TYPECK_APPEND_PROLOGUE_EXTERNS = r"""
/* --- post_E_fixup typeck-bodies prologue: data-object decls (not covered by fwd-decls pass) --- */

/* BSS global used by typeck_overload_expected_ret_peek().  typeck.x declares
 * this BSS object internally (file scope or extern) so the data itself lives
 * in typeck_x.o.  This extern makes the object visible to our appended body.
 */
extern int32_t g_typeck_overload_expected_ret;
"""

# 5 function bodies, copy-paste verbatim from seeds/typeck_gen.linux.x86_64.c
# (lines 11944 / 15825 / 15850 / 15522 / 3440 regions respectively).
# Only formatting / comment blocks have been trimmed slightly.
TYPECK_APPEND_BODIES_RAW = r"""
/* --- post_E_fixup: 5 missing bodies appended for typeck_x.o (wave335 pure-ld UNDEF fix) --- */

/* --- post_E_fixup helpers: cross-function deps needed by the 5 bodies below.
   These are injected because the forward-decl analysis phase runs BEFORE
   --append-typeck-bodies, so signatures/helpers discovered only inside the
   appended bodies would otherwise be missed and trigger 2 hard errors:
     1) implicit-decl of typeck_get_field_offset_from_layout (PUBLIC extern,
        body provided by typeck.x proper — just needs forward signature).
     2) implicit-decl of typeck_is_const_expr_ref_impl (STATIC helper, 14
        branches, 13 call sites in the appended bodies — needs FULL definition
        in same TU because static = no external linkage).
   Source: seeds/typeck_gen.linux.x86_64.c L1701 + L15610-L15812 verbatim. */
/* (1) extern forward-decl for typeck_get_field_offset_from_layout (PUBLIC API) */
extern int32_t typeck_get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);

/* (1b) 3 extern forward-decls CALLED FROM WITHIN the static helper below.
   These 3 were NOT in the -E output's original forward-decls, so without them
   the 14-branch static helper triggers 3 implicit-function-decl errors plus a
   cascade int→ptr conversion error (= 4 total). Signatures verbatim from seed.
   Seed refs: glue_arena_expr_at_ref @ L15560 / try_mark_enum_field_access @ L15582
   / ast_pipeline_block_expr_stmt_ref @ L15608 */
extern struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t i);
extern struct ast_Module *pipeline_typeck_active_module_c(void);
extern int32_t pipeline_module_top_level_name_is_const(struct ast_Module *module, uint8_t *vname, int32_t vlen);

/* (2) STATIC HELPER typeck_is_const_expr_ref_impl (verbatim seed L15610-L15812) */
static int typeck_is_const_expr_ref_impl(struct ast_ASTArena *a, int32_t expr_ref, const char *const_names[], int n_const_names) {
  struct ast_Expr *e;
  int i, j, ne;
  enum ast_ExprKind kd;

  e = glue_arena_expr_at_ref(a, expr_ref);
  if (!e)
    return 0;
  kd = e->kind;
  if (kd == ast_ExprKind_EXPR_LIT || kd == ast_ExprKind_EXPR_FLOAT_LIT || kd == ast_ExprKind_EXPR_BOOL_LIT)
    return 1;
  if (kd == ast_ExprKind_EXPR_VAR) {
    for (i = 0; i < n_const_names; i++) {
      if (!const_names[i])
        continue;
      if (e->var_name_len > 0 && strcmp(const_names[i], e->var_name) == 0)
        return 1;
    }
    /* PLATFORM: SHARED — module top-level const VAR is a const-expr in the
     * block-const whitelist (const_names != NULL). Mirror residual.
     * C-static-init / pure-lit fold pass NULL and still reject VAR. */
    if (const_names != NULL && e->var_name_len > 0) {
      struct ast_Module *mod = pipeline_typeck_active_module_c();
      if (mod && pipeline_module_top_level_name_is_const(mod, (uint8_t *)e->var_name,
                                                        e->var_name_len) != 0)
        return 1;
    }
    return 0;
  }
  if (kd >= ast_ExprKind_EXPR_ADD && kd <= ast_ExprKind_EXPR_LOGOR)
    return typeck_is_const_expr_ref_impl(a, e->binop_left_ref, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, e->binop_right_ref, const_names, n_const_names);
  if (kd == ast_ExprKind_EXPR_NEG || kd == ast_ExprKind_EXPR_BITNOT || kd == ast_ExprKind_EXPR_LOGNOT)
    return typeck_is_const_expr_ref_impl(a, e->unary_operand_ref, const_names, n_const_names);
  if (kd == ast_ExprKind_EXPR_ARRAY_LIT) {
    ne = e->array_lit_num_elems;
    for (i = 0; i < ne; i++) {
      if (!typeck_is_const_expr_ref_impl(a, pipeline_expr_array_lit_elem_ref(a, expr_ref, i), const_names, n_const_names))
        return 0;
    }
    return 1;
  }
  if (kd == ast_ExprKind_EXPR_STRUCT_LIT) {
    ne = e->struct_lit_num_fields;
    for (i = 0; i < ne; i++) {
      int32_t init_ref = pipeline_expr_struct_lit_init_ref(a, expr_ref, i);
      if (init_ref <= 0)
        return 0;
      if (!typeck_is_const_expr_ref_impl(a, init_ref, const_names, n_const_names))
        return 0;
    }
    return 1;
  }
  if (kd == ast_ExprKind_EXPR_FIELD_ACCESS) {
    pipeline_expr_try_mark_enum_field_access(pipeline_typeck_active_module_c(), a, expr_ref);
    if (pipeline_expr_field_access_is_enum_variant(a, expr_ref) != 0)
      return 1;
    return 0;
  }
  if (kd == ast_ExprKind_EXPR_TERNARY || kd == ast_ExprKind_EXPR_IF) {
    int32_t cond_ref = pipeline_expr_if_cond_ref_at(a, expr_ref);
    int32_t then_ref = pipeline_expr_if_then_ref_at(a, expr_ref);
    int32_t else_ref = pipeline_expr_if_else_ref_at(a, expr_ref);
    if (cond_ref <= 0 || then_ref <= 0 || else_ref <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, cond_ref, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, then_ref, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, else_ref, const_names, n_const_names);
  }
  if (kd == ast_ExprKind_EXPR_BLOCK) {
    int32_t block_ref = pipeline_expr_block_ref_at(a, expr_ref);
    int32_t final_expr_ref;
    int32_t n_es;
    if (block_ref <= 0)
      return 0;
    if (ast_ast_block_num_consts(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_lets(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_loops(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_for_loops(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_if_stmts(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_regions(a, block_ref) > 0)
      return 0;
    n_es = ast_ast_block_num_expr_stmts(a, block_ref);
    final_expr_ref = ast_ast_block_final_expr_ref(a, block_ref);
    if (final_expr_ref <= 0) {
      if (n_es != 1)
        return 0;
      final_expr_ref = ast_pipeline_block_expr_stmt_ref(a, block_ref, 0);
    } else if (n_es != 0) {
      return 0;
    }
    if (final_expr_ref <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, final_expr_ref, const_names, n_const_names);
  }
  /* PLATFORM: SHARED — EXPR_AS is const iff the operand is (mirror
   * typeck_cap_residual.from_x.c). Recurse as_operand only. */
  if (kd == ast_ExprKind_EXPR_AS) {
    int32_t op = e->as_operand_ref;
    if (op <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, op, const_names, n_const_names);
  }
  /* PLATFORM: SHARED — EXPR_INDEX is const iff base and index are (mirror
   * typeck_cap_residual.from_x.c). Let-bound bases stay rejected. */
  if (kd == ast_ExprKind_EXPR_INDEX) {
    int32_t base = e->index_base_ref;
    int32_t idx = e->index_index_ref;
    if (base <= 0 || idx <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, base, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, idx, const_names, n_const_names);
  }
  return 0;
}

int32_t typeck_check_expr_impl_mega(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t ord_return = 41;
    int32_t ord_panic = 42;
    int32_t ord_match = 43;
    int32_t ord_field = 44;
    int32_t ord_struct_lit = 45;
    int32_t ord_array_lit = 46;
    int32_t ord_index = 47;
    int32_t ord_call = 48;
    int32_t ord_method_call = 49;
    int32_t ord_add = 4;
    int32_t ord_logor = 21;
    int32_t ord_neg = 22;
    int32_t ord_bitnot = 23;
    int32_t ord_lognot = 24;
    int32_t ord_addr_of = 51;
    int32_t ord_deref = 52;
    int32_t ord_var = 3;
    int32_t ord_as = 54;
    int32_t ord_try_propagate = 58;
    int32_t kind = 0;
    if ((((arena ==0) || (expr_ref <=0)) || (expr_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    (void)((kind = pipeline_expr_kind_ord_at(arena, expr_ref)));
    if (typeck_expr_is_any_assign_kind(kind)) {
      return pipeline_typeck_check_expr_impl_mega_c(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_return)) {
      return pipeline_typeck_check_expr_impl_mega_c(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_panic)) {
      return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_match)) {
      return typeck_check_expr_match(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_field)) {
      return typeck_check_expr_field_access(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_array_lit)) {
      return typeck_check_expr_array_lit(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_index)) {
      return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_call)) {
      return typeck_check_expr_call(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_method_call)) {
      return typeck_check_expr_method_call(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (((kind >=ord_add) && (kind <=ord_logor))) {
      return typeck_check_expr_binop(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((((kind ==ord_neg) || (kind ==ord_bitnot)) || (kind ==ord_lognot))) {
      return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_addr_of)) {
      return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_deref)) {
      return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_var)) {
      return typeck_check_expr_var(module, arena, expr_ref, ctx);
    }
    if ((kind ==ord_as)) {
      return typeck_check_expr_as(module, arena, expr_ref, ctx);
    }
    if ((kind ==ord_struct_lit)) {
      return typeck_check_expr_struct_lit(module, arena, expr_ref, return_type_ref, ctx);
    }
    if ((kind ==ord_try_propagate)) {
      return typeck_check_expr_try_propagate(module, arena, expr_ref, return_type_ref, ctx);
    }
    return 0;
  }
}

int32_t typeck_block_const_init_is_const(struct ast_ASTArena *arena, int32_t block_ref, int32_t const_idx) {
  const char *names[64];
  char name_bufs[64][128];
  int n = 0;
  int i;
  int32_t init_ref;

  if (!arena || const_idx < 0)
    return 0;
  for (i = 0; i < const_idx && n < 64; i++) {
    int32_t nlen = pipeline_block_const_name_len(arena, block_ref, i);
    if (nlen <= 0 || nlen >= 64)
      continue;
    pipeline_block_const_name_copy64(arena, block_ref, i, (uint8_t *)name_bufs[n]);
    name_bufs[n][nlen] = '\0';
    names[n] = name_bufs[n];
    n++;
  }
  init_ref = pipeline_block_const_init_ref(arena, block_ref, const_idx);
  if (init_ref <= 0)
    return 1;
  return typeck_is_const_expr_ref_impl(arena, init_ref, names, n) ? 1 : 0;
}

void typeck_const_init_not_constant(int32_t line, int32_t col) {
  static uint8_t msg[] = "const init must be constant expression";
  lsp_diag_report_typeck(line, col, msg);
}

int32_t typeck_overload_expected_ret_peek(void) {
  return g_typeck_overload_expected_ret;
}

int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module * module, struct ast_PipelineDepCtx * ctx, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len) {
  {
    int32_t r = typeck_get_field_offset_from_layout(module, type_name, type_name_len, field_name, field_name_len);
    if ((r >=0)) {
      return r;
    }
    if ((ctx ==0)) {
      return -1;
    }
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t di = 0;
    while ((di < nd)) {
      struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, di);
      if ((dm !=0)) {
        (void)((r = typeck_get_field_offset_from_layout(dm, type_name, type_name_len, field_name, field_name_len)));
        if ((r >=0)) {
          return r;
        }
      }
      (void)((di = (di + 1)));
    }
    return -1;
  }
}
/* --- end post_E_fixup typeck appended bodies --- */
"""


def append_typeck_missing_bodies(src: str) -> str:
    """Append prologue data-externs + 5 missing function bodies to src.

    Returns the concatenated text.  Append happens AFTER inject_forward_decls
    so that the forward-decls block covers both original text AND the appended
    bodies (function signatures of appended bodies are not extracted by the
    forward-decls pass — but they're definitions, so they self-declare).

    G.7 有则补全 (wave336): if any of the 5 public API bodies is already
    emitted by xlang -E (newer binaries emit them; older ones regressed),
    skip the entire append block to avoid redefinition errors. Also checks
    each helper/extern individually so partial emitters (e.g. body present
    but static helper missing) still get the needed fragments.
    """
    # --- Detection: which fragments are already in src? ---
    # A body is "present" if the function name appears with a `{` body opener
    # (not just a forward-decl `);`). A static helper is "present" if its
    # `static ... name(` signature line exists. An extern is "present" if
    # `extern ... name(` already declares it.
    def _has_body(name: str) -> bool:
        # Match `<name>(...)\s*{` allowing newlines/whitespace, NOT just `);`.
        pat = re.compile(r"\b" + re.escape(name) + r"\s*\([^)]*\)\s*\{", re.S)
        return bool(pat.search(src))

    def _has_static(name: str) -> bool:
        pat = re.compile(r"\bstatic\s+\w[\w\s\*]*\s+" + re.escape(name) + r"\s*\(")
        return bool(pat.search(src))

    def _has_extern(name: str) -> bool:
        pat = re.compile(r"\bextern\s+\w[\w\s\*]*\s+" + re.escape(name) + r"\s*\(")
        return bool(pat.search(src))

    # 5 public API bodies — if all present, the .x -E emitted them and the
    # entire append block (bodies + helper + externs) is unnecessary.
    api_bodies = [
        "typeck_check_expr_impl_mega",
        "typeck_block_const_init_is_const",
        "typeck_const_init_not_constant",
        "typeck_overload_expected_ret_peek",
        "typeck_get_field_offset_from_layout_deps",
    ]
    if all(_has_body(n) for n in api_bodies):
        # All 5 bodies already emitted — pure no-op. Also confirms the helper
        # and transitive externs are already present (since the bodies
        # reference them and the -E output would have emitted them too).
        return src

    # --- Conditional fragment assembly ---
    # Build the append block piece-by-piece, skipping fragments already present.
    parts: list[str] = []

    # (1) Public extern for typeck_get_field_offset_from_layout (called by
    #     typeck_get_field_offset_from_layout_deps body). Skip if src already
    #     declares it.
    if not _has_extern("typeck_get_field_offset_from_layout"):
        parts.append(
            "/* post_E_fixup: extern forward-decl for typeck_get_field_offset_from_layout (PUBLIC API) */\n"
            "extern int32_t typeck_get_field_offset_from_layout(struct ast_Module * module, uint8_t * type_name, int32_t type_name_len, uint8_t * field_name, int32_t field_name_len);\n"
        )

    # (1b) 3 transitive externs called from inside the static helper below.
    #      Skip each individually if src already declares it.
    _transitive_externs = [
        ("glue_arena_expr_at_ref",
         "extern struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref);"),
        ("pipeline_expr_try_mark_enum_field_access",
         "extern void pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a, int32_t expr_ref);"),
        ("ast_pipeline_block_expr_stmt_ref",
         "extern int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t i);"),
        ("pipeline_typeck_active_module_c",
         "extern struct ast_Module *pipeline_typeck_active_module_c(void);"),
        ("pipeline_module_top_level_name_is_const",
         "extern int32_t pipeline_module_top_level_name_is_const(struct ast_Module *module, uint8_t *vname, int32_t vlen);"),
    ]
    _tx_parts = []
    for _name, _decl in _transitive_externs:
        if not _has_extern(_name):
            _tx_parts.append(_decl)
    if _tx_parts:
        parts.append(
            "/* post_E_fixup: transitive externs called from the static helper below */\n"
            + "\n".join(_tx_parts) + "\n"
        )

    # (2) Static helper typeck_is_const_expr_ref_impl — only if not already
    #     defined in src (older -E outputs may emit it; newer ones don't).
    if not _has_static("typeck_is_const_expr_ref_impl"):
        parts.append(_TYPECK_STATIC_HELPER_RAW)

    # (3) Public API bodies — only append the ones missing from src.
    #     Walk TYPECK_APPEND_BODIES_RAW and split it by `*/\n` markers to
    #     isolate each body, then check presence.
    _missing_bodies = []
    for _name in api_bodies:
        if not _has_body(_name):
            # Extract just this function's body from the raw block.
            _body = _extract_function_body_from_raw(_name)
            if _body:
                _missing_bodies.append(_body)
    if _missing_bodies:
        parts.append(
            "/* post_E_fixup: missing public API bodies (wave335 pure-ld UNDEF fix; "
            "conditional append wave336 — only bodies absent from -E output) */\n"
            + "\n".join(_missing_bodies) + "\n"
        )

    if not parts:
        # Nothing to append — all fragments already present.
        return src

    return src + "\n" + TYPECK_APPEND_PROLOGUE_EXTERNS + "\n".join(parts) + "\n"


# --- Conditional-fragment raw blocks (wave336 G.7 有则补全) ---

# Static helper body (verbatim from seed L15610-L15812). Lifted out of
# TYPECK_APPEND_BODIES_RAW so it can be appended independently when the
# public bodies are already present but this static helper is missing.
_TYPECK_STATIC_HELPER_RAW = r"""
/* post_E_fixup: STATIC HELPER typeck_is_const_expr_ref_impl (verbatim seed L15610-L15812) */
static int typeck_is_const_expr_ref_impl(struct ast_ASTArena *a, int32_t expr_ref, const char *const_names[], int n_const_names) {
  struct ast_Expr *e;
  int i, j, ne;
  enum ast_ExprKind kd;

  e = glue_arena_expr_at_ref(a, expr_ref);
  if (!e)
    return 0;
  kd = e->kind;
  if (kd == ast_ExprKind_EXPR_LIT || kd == ast_ExprKind_EXPR_FLOAT_LIT || kd == ast_ExprKind_EXPR_BOOL_LIT)
    return 1;
  if (kd == ast_ExprKind_EXPR_VAR) {
    for (i = 0; i < n_const_names; i++) {
      if (!const_names[i])
        continue;
      if (e->var_name_len > 0 && strcmp(const_names[i], e->var_name) == 0)
        return 1;
    }
    /* PLATFORM: SHARED — module top-level const VAR is a const-expr in the
     * block-const whitelist (const_names != NULL). Mirror residual.
     * C-static-init / pure-lit fold pass NULL and still reject VAR. */
    if (const_names != NULL && e->var_name_len > 0) {
      struct ast_Module *mod = pipeline_typeck_active_module_c();
      if (mod && pipeline_module_top_level_name_is_const(mod, (uint8_t *)e->var_name,
                                                        e->var_name_len) != 0)
        return 1;
    }
    return 0;
  }
  if (kd >= ast_ExprKind_EXPR_ADD && kd <= ast_ExprKind_EXPR_LOGOR)
    return typeck_is_const_expr_ref_impl(a, e->binop_left_ref, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, e->binop_right_ref, const_names, n_const_names);
  if (kd == ast_ExprKind_EXPR_NEG || kd == ast_ExprKind_EXPR_BITNOT || kd == ast_ExprKind_EXPR_LOGNOT)
    return typeck_is_const_expr_ref_impl(a, e->unary_operand_ref, const_names, n_const_names);
  if (kd == ast_ExprKind_EXPR_ARRAY_LIT) {
    ne = e->array_lit_num_elems;
    for (i = 0; i < ne; i++) {
      if (!typeck_is_const_expr_ref_impl(a, pipeline_expr_array_lit_elem_ref(a, expr_ref, i), const_names, n_const_names))
        return 0;
    }
    return 1;
  }
  if (kd == ast_ExprKind_EXPR_STRUCT_LIT) {
    ne = e->struct_lit_num_fields;
    for (i = 0; i < ne; i++) {
      int32_t init_ref = pipeline_expr_struct_lit_init_ref(a, expr_ref, i);
      if (init_ref <= 0)
        return 0;
      if (!typeck_is_const_expr_ref_impl(a, init_ref, const_names, n_const_names))
        return 0;
    }
    return 1;
  }
  if (kd == ast_ExprKind_EXPR_FIELD_ACCESS) {
    pipeline_expr_try_mark_enum_field_access(pipeline_typeck_active_module_c(), a, expr_ref);
    if (pipeline_expr_field_access_is_enum_variant(a, expr_ref) != 0)
      return 1;
    return 0;
  }
  if (kd == ast_ExprKind_EXPR_TERNARY || kd == ast_ExprKind_EXPR_IF) {
    int32_t cond_ref = pipeline_expr_if_cond_ref_at(a, expr_ref);
    int32_t then_ref = pipeline_expr_if_then_ref_at(a, expr_ref);
    int32_t else_ref = pipeline_expr_if_else_ref_at(a, expr_ref);
    if (cond_ref <= 0 || then_ref <= 0 || else_ref <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, cond_ref, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, then_ref, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, else_ref, const_names, n_const_names);
  }
  if (kd == ast_ExprKind_EXPR_BLOCK) {
    int32_t block_ref = pipeline_expr_block_ref_at(a, expr_ref);
    int32_t final_expr_ref;
    int32_t n_es;
    if (block_ref <= 0)
      return 0;
    if (ast_ast_block_num_consts(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_lets(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_loops(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_for_loops(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_if_stmts(a, block_ref) > 0)
      return 0;
    if (ast_ast_block_num_regions(a, block_ref) > 0)
      return 0;
    n_es = ast_ast_block_num_expr_stmts(a, block_ref);
    final_expr_ref = ast_ast_block_final_expr_ref(a, block_ref);
    if (final_expr_ref <= 0) {
      if (n_es != 1)
        return 0;
      final_expr_ref = ast_pipeline_block_expr_stmt_ref(a, block_ref, 0);
    } else if (n_es != 0) {
      return 0;
    }
    if (final_expr_ref <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, final_expr_ref, const_names, n_const_names);
  }
  /* PLATFORM: SHARED — EXPR_AS is const iff the operand is (mirror
   * typeck_cap_residual.from_x.c). Recurse as_operand only. */
  if (kd == ast_ExprKind_EXPR_AS) {
    int32_t op = e->as_operand_ref;
    if (op <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, op, const_names, n_const_names);
  }
  /* PLATFORM: SHARED — EXPR_INDEX is const iff base and index are (mirror
   * typeck_cap_residual.from_x.c). Let-bound bases stay rejected. */
  if (kd == ast_ExprKind_EXPR_INDEX) {
    int32_t base = e->index_base_ref;
    int32_t idx = e->index_index_ref;
    if (base <= 0 || idx <= 0)
      return 0;
    return typeck_is_const_expr_ref_impl(a, base, const_names, n_const_names) &&
           typeck_is_const_expr_ref_impl(a, idx, const_names, n_const_names);
  }
  return 0;
}
"""


def _extract_function_body_from_raw(name: str) -> str:
    """Extract a single function body from TYPECK_APPEND_BODIES_RAW by name.

    Returns the body text (signature + body + closing brace) or empty string
    if not found. Used by append_typeck_missing_bodies to assemble only the
    missing public API bodies (wave336 conditional append).
    """
    # Match `<rettype> <name>(<params>) {` then capture up to the matching
    # closing `}` at column 0 (top-level function body end).
    pat = re.compile(
        r"\n[\w\s\*]+" + re.escape(name) + r"\([^)]*\)\s*\{",
        re.S,
    )
    m = pat.search(TYPECK_APPEND_BODIES_RAW)
    if not m:
        return ""
    start = m.start() + 1  # skip leading \n
    # Find matching closing brace at column 0.
    end_pat = re.compile(r"\n\}\n")
    e = end_pat.search(TYPECK_APPEND_BODIES_RAW, m.end())
    if not e:
        return ""
    return TYPECK_APPEND_BODIES_RAW[start:e.end()]


def scrub_init_globals(src: str) -> str:
    """Rewrite init_globals body to drop cross-module BSS assignments.

    Matches `static void init_globals(void) { ... }` block and strips any
    line whose statement-side (pre-`;` pre-`=`) starts with one of the
    CROSS_MODULE_G_PREFIXES patterns above. Preserves blank lines / comments
    and parser-owned statements such as g_lparen_ctrl_* sticky zeroization.
    Safety: when all lines are stripped, restores the canonical parser-
    owned pair (g_lparen_ctrl_last_pos / g_lparen_ctrl_hits zero init) so
    the function body is never empty.
    """
    pat = re.compile(r"static void init_globals\(void\)\s*\{(.*?)\n\}", re.S)
    m = pat.search(src)
    if not m:
        return src
    body = m.group(1)
    kept_lines = []
    for ln in body.split("\n"):
        sl = ln.strip()
        # Blank / comment / directive → keep verbatim
        if not sl or sl.startswith("/*") or sl.startswith("//") or sl.startswith("#"):
            kept_lines.append(ln)
            continue
        # Drop statements that assign to a cross-module global (first token
        # before `=` / `[` matches a cross-module prefix). The statement may
        # span multiple lines but we've split to lines so this is the
        # "syntactically starting with" check, which matches 100% of the
        # assignments in the probe because xlang -E emits every BSS
        # zeroization on its own single line.
        first_tok = sl.split()[0] if sl.split() else ""
        cross = False
        for pref in CROSS_MODULE_G_PREFIXES:
            if first_tok.startswith(pref):
                cross = True
                break
        if not cross:
            kept_lines.append(ln)
    # Safety net: restore parser-owned default sticky zeroization when the
    # result is empty.
    non_empty = [k for k in kept_lines if k.strip()]
    if not non_empty:
        kept_lines = [
            "  /* post_E_fixup: leaf-owned zeroization restored (cross-module refs removed) */",
            "  g_lparen_ctrl_last_pos[0] = ((size_t)(0));",
            "  g_lparen_ctrl_hits[0] = 0;",
        ]
    new_body = "\n".join(kept_lines)
    repl = f"static void init_globals(void) {{\n{new_body}\n}}"
    return pat.sub(repl, src, count=1)


# === Colliding-definition dedup (wave338) ====================================
#
# ROOT CAUSE: codegen's module-prefix logic in codegen_emit_func_link_name
# (codegen.x ~L15505) adds the module name as a C-link prefix onto every
# `export function` name, with a skip-if-redundant check via
# codegen_c_prefix_redundant_with_name (codegen.x L3560).  When two source
# functions in the SAME module map to the same C symbol after prefixing,
# the codegen emits TWO definitions with the identical name.
#
# Concrete instance (driver_x.o / src/main.x):
#   export function run_compiler_c(...)      → prefixed → main_run_compiler_c
#   export function main_run_compiler_c(...) → skip     → main_run_compiler_c  (collision!)
#
# The second definition (from the source `main_run_compiler_c`) originally
# called `run_compiler_c(...)`; after prefixing that call also becomes
# `main_run_compiler_c(...)` — i.e. the function calls ITSELF, creating
# infinite recursion AND a duplicate-definition linker error.
#
# This pass detects:
#   (A) duplicate extern declarations of the same name → keep first, drop rest
#   (B) duplicate function definitions of the same name → drop any whose body
#       calls the function's own name (self-calling = the colliding duplicate);
#       keep the remaining definition (which calls a DIFFERENT symbol = correct)
#
# Safety: only acts when ≥2 definitions share a name. A lone self-recursive
# function (legitimate recursion) is never touched. Brace matching is
# depth-counted; -E output is machine-generated C without brace-in-string
# edge cases, so depth counting is exact for this input class.
# PLATFORM: SHARED — pure text manipulation, stdlib only.

_EXTERN_NAME_RE = re.compile(
    r"^\s*extern\s+.+\s+([A-Za-z_][A-Za-z0-9_]*)\s*\([^)]*\)\s*;\s*$"
)

# Function definition: [storage] <rettype-chain> <name>(<params>) {
# Opening brace must be on the same line (INVARIANT 2a of -E output).
_FUNC_DEF_RE = re.compile(
    r"^(?:static\s+|inline\s+|static\s+inline\s+)?"
    r"(\w[\w\s\*]*?)\s+"  # return-type chain (non-greedy)
    r"([A-Za-z_][A-Za-z0-9_]*)\s*"  # function name
    r"\(([^)]*)\)\s*\{"  # params + opening brace
)


def _find_func_def_ranges(lines):
    """Return list of (name, start_idx, end_idx) for each top-level function
    definition, where end_idx is the line of the matching closing brace.
    Uses depth-counted brace matching (exact for -E output class).
    """
    results = []
    i = 0
    N = len(lines)
    while i < N:
        m = _FUNC_DEF_RE.match(lines[i])
        if not m:
            i += 1
            continue
        name = m.group(2)
        depth = 0
        end = i
        for j in range(i, N):
            for ch in lines[j]:
                if ch == "{":
                    depth += 1
                elif ch == "}":
                    depth -= 1
                    if depth == 0:
                        end = j
                        break
            if depth == 0:
                break
        results.append((name, i, end))
        i = end + 1
    return results


def dedup_colliding_definitions(src: str) -> str:
    """Remove duplicate function definitions + extern declarations caused by
    codegen module-prefix collisions (wave338).

    See module docstring §0 for the full root-cause analysis. This function is
    always-on (ALL leaves) because the collision is a codegen-level defect that
    can affect any module where a source function name collides with another
    after prefixing; it is NOT leaf-specific.

    Returns src unchanged if no collisions are found.
    """
    lines = src.split("\n")
    remove = set()  # line indices to drop

    # --- (B) duplicate function definitions: drop self-calling copies -------
    ranges = _find_func_def_ranges(lines)
    from collections import defaultdict
    by_name = defaultdict(list)
    for name, start, end in ranges:
        by_name[name].append((start, end))

    for name, defs in by_name.items():
        if len(defs) < 2:
            continue
        # A definition "calls itself" if the function name appears as a call
        # (name + "(") MORE THAN ONCE in the full definition text — once in
        # the signature, plus ≥1 in the body. Counting avoids needing to
        # separate signature from body.
        for start, end in defs:
            full = "\n".join(lines[start : end + 1])
            call_count = len(re.findall(r"\b" + re.escape(name) + r"\s*\(", full))
            if call_count >= 2:
                for k in range(start, end + 1):
                    remove.add(k)

    # --- (A) duplicate extern declarations: keep first per name -------------
    seen_extern = set()
    for i, ln in enumerate(lines):
        m = _EXTERN_NAME_RE.match(ln)
        if not m:
            continue
        ename = m.group(1)
        if ename in seen_extern:
            remove.add(i)
        else:
            seen_extern.add(ename)

    if not remove:
        return src

    new_lines = [ln for i, ln in enumerate(lines) if i not in remove]
    # Trailing newline preservation: split("\n") drops the final newline;
    # rejoin and re-add if original ended with one.
    result = "\n".join(new_lines)
    if src.endswith("\n") and not result.endswith("\n"):
        result += "\n"
    return result


# === Forward-declaration generator ==========================================
#
# xlang -E emitter style invariants (G.7 — single authority = no dual style):
#
#   INVARIANT 1: pure extern declarations occupy their own line, starting at
#               column 0:
#
#                   extern <return-type-chain> <name>(<params>);
#
#   INVARIANT 2: function definitions start on their own line, column 0,
#               with optional `static` storage prefix, and the opening `{` is
#               either on the SAME line after the closing `)` or on the VERY
#               NEXT line column-0 by itself:
#
#                   [static] <return-type-chain> <name>(<params>) { ... }
#
#                   [static] <return-type-chain> <name>(<params>)
#                   {
#                       ...
#                   }
#
# Exploiting these two invariants guarantees zero false-positive extraction
# without needing a full C parser (which caused the "function definition is
# not allowed here" cascade failure in earlier attempts, because a fuzzy
# parser accidentally treated deeply-nested call expressions / macro bodies
# as if they were top-level function definitions).

_EXTERN_DECL_RE = re.compile(
    r"^\s*extern\s+"                                   # column-0 extern keyword
    r"(.+?)\s+"                                        # return-type chain (group 1)
    r"([A-Za-z_][A-Za-z0-9_]*)\s*"                    # function name       (group 2)
    r"\(([^)]*)\)\s*;\s*$"                             # parameter list + trailing `;` (group 3)
)

# Return type fragment used by definition regexes
_RET = (
    r"(?:(?:unsigned|signed|struct|enum|union)\s+)?"
    r"[A-Za-z_][A-Za-z0-9_]*\b"
    r"(?:\s+(?:const|restrict|volatile|unsigned|signed|struct|enum|union)\s*[A-Za-z_][A-Za-z0-9_]*)*"
    r"(?:\s*\**)?"
)

_DEF_SAME_LINE_RE = re.compile(
    r"^\s*(static\s+|extern\s+|inline\s+|static\s+inline\s+)?"    # optional storage-class (group 1)
    r"(" + _RET + r")\s+"                                          # return-type chain (group 2)
    r"([A-Za-z_][A-Za-z0-9_]*)\s*"                                # name               (group 3)
    r"\(([^)]*)\)\s*\{\s*$"                                        # params + `{` same line (group 4)
)

_DEF_HEAD_ONLY_RE = re.compile(
    r"^\s*(static\s+|extern\s+|inline\s+|static\s+inline\s+)?"
    r"(" + _RET + r")\s+"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*"
    r"\(([^)]*)\)\s*$"                                             # no `{` on this line
)

# Match `struct <name>`, `union <name>`, `enum <name>` in type position.
# Used to collect all aggregate/enum tags referenced by function signatures
# so we can emit `struct X;` forward-decls BEFORE the function prototypes.
# Without this, C treats a tag first seen inside `f(struct X *p)` as a
# prototype-scope local type (ISO C 6.2.1 §4), causing "conflicting types"
# / -Wvisibility when the same tag is later declared properly in the file
# body (different linkage). G.7 root fix: own the tag-declaration order.
_TAG_RE = re.compile(r"\b(struct|union|enum)\s+([A-Za-z_][A-Za-z0-9_]*)")


def _collect_aggregate_tags_from_decl(decl_text: str):
    """Yield (tag_kind, tag_name) for every struct/union/enum reference."""
    for m in _TAG_RE.finditer(decl_text):
        yield m.group(1), m.group(2)


def _extract_all_function_signatures(src: str):
    """Return list of (storage_class, declaration_line, name).

    storage_class ∈ { "static", "extern", "inline", "static inline" };
    declaration_line is a single C statement ready for concatenation as a
    forward declaration (ends with `;`).
    """
    results = []
    seen_names = set()

    def _add(name, decl, storage="extern"):
        # Skip invalid / reserved names
        if not name or not decl:
            return
        if len(name) < 2:
            return
        if name in ("if", "else", "for", "while", "switch", "do", "return",
                    "sizeof", "typeof", "case", "struct", "union", "enum",
                    "auto", "register", "typedef"):
            return
        if name in seen_names:
            return
        seen_names.add(name)
        # Ensure trailing `;`
        decl_clean = decl.rstrip().rstrip(";").rstrip()
        if not decl_clean:
            return
        results.append((storage, decl_clean + ";", name))

    lines = src.split("\n")
    N = len(lines)

    # ---- Invariant 1 pass: extern declarations ---------------------------
    for ln in lines:
        m = _EXTERN_DECL_RE.match(ln)
        if not m:
            continue
        ret_chain = m.group(1).strip()
        name = m.group(2)
        params = m.group(3).strip()
        # Rebuild canonical extern form (drop attributes)
        core = f"extern {ret_chain} {name}({params})"
        core = re.sub(r"__attribute__\s*\(\([^)]*\)\)", "", core).strip()
        _add(name, core, "extern")

    # ---- Invariant 2 pass: function definitions -------------------------
    for i in range(N):
        ln = lines[i]
        # Case (a): `{` on same line
        m_same = _DEF_SAME_LINE_RE.match(ln)
        if m_same:
            storage = (m_same.group(1) or "").strip() or "extern"
            rettype = m_same.group(2).strip()
            name = m_same.group(3)
            params = m_same.group(4).strip()
            prefix = (m_same.group(1) or "").rstrip()
            core = f"{prefix} {rettype} {name}({params})".strip()
            core = re.sub(r"__attribute__\s*\(\([^)]*\)\)", "", core).strip()
            _add(name, core, storage)
            continue
        # Case (b): header on this line, `{` alone on next line column 0
        m_head = _DEF_HEAD_ONLY_RE.match(ln)
        if m_head and i + 1 < N:
            nxt = lines[i + 1].strip()
            if nxt == "{":
                storage = (m_head.group(1) or "").strip() or "extern"
                rettype = m_head.group(2).strip()
                name = m_head.group(3)
                params = m_head.group(4).strip()
                prefix = (m_head.group(1) or "").rstrip()
                core = f"{prefix} {rettype} {name}({params})".strip()
                core = re.sub(r"__attribute__\s*\(\([^)]*\)\)", "", core).strip()
                _add(name, core, storage)

    return results


def inject_forward_decls(src: str) -> str:
    """Prepend tag forward-decls + function forward-decls as a single block.

    Order matters (ISO C 6.2.1 §4 — prototype-scope tag rules):
      1. `struct X;` / `union Y;` / `enum Z;` — incomplete-type tag decls
         for every tag referenced by any function signature in the file.
         Without these, the first occurrence of `f(struct X *p)` would create
         a prototype-scope-local `struct X` that then "conflicts types" with
         the real `struct X` appearing later in the file body (-Wvisibility).
      2. Function forward-decls (extern + static), grouped by storage class.
    Block is placed before the first non-comment, non-CPP, non-DBG- line.
    """
    sigs = _extract_all_function_signatures(src)
    if not sigs:
        return src

    # ---- Phase 0: hoist top-level typedefs USED IN FUNCTION SIGNATURES ----
    # Why: function forward-decls (Phase 2) may reference typedef'd names like
    # `fs_iovec_buf_t` that are defined LATER in the original -E output (e.g.
    # line 532 in pipeline.x -E). Without hoisting, the forward-decl at line
    # 178 triggers "unknown type name 'fs_iovec_buf_t'" because the typedef
    # isn't visible yet.
    # Targeted hoisting (wave337): only hoist typedefs whose names actually
    # appear in function signatures AND whose definition is a simple
    # `typedef struct Tag name;` (incomplete-struct typedef — safe to hoist).
    # Skip struct-body typedefs (`typedef struct { ... } name;`) to avoid
    # system-header redefinition conflicts (e.g. SIMD `f32x4_t` is a vector
    # type in <immintrin.h> but a struct in -E output).
    # C11 §6.7p3 allows re-typedef of compatible types, so copying (not
    # moving) is safe. PLATFORM: SHARED — C11 supported by clang ≥3.1,
    # gcc ≥4.7, MSVC. The -E output already demands C11.
    _needed_typedef_names: set[str] = set()
    for _s, d, _n in sigs:
        for m in re.finditer(r"\b([a-z_][a-z0-9_]*_t)\b", d):
            _needed_typedef_names.add(m.group(1))
    typedef_lines = []
    for ln in src.split("\n"):
        if not ln.startswith("typedef ") or not ln.rstrip().endswith(";"):
            continue
        m = re.search(r"\b([a-z_][a-z0-9_]*_t)\s*;\s*$", ln)
        if not m:
            continue
        _td_name = m.group(1)
        if _td_name not in _needed_typedef_names:
            continue
        if not re.match(r"^typedef\s+(struct|union)\s+\w+\s+\*?" + re.escape(_td_name) + r"\s*;", ln):
            continue
        typedef_lines.append(ln)

    # ---- Phase 1: collect all struct/union/enum tags from signatures ----
    tag_seen = set()
    tag_lines_struct = []
    tag_lines_union = []
    tag_lines_enum = []
    for _s, d, _n in sigs:
        for kind, tname in _collect_aggregate_tags_from_decl(d):
            key = (kind, tname)
            if key in tag_seen:
                continue
            tag_seen.add(key)
            if kind == "struct":
                tag_lines_struct.append(f"struct {tname};")
            elif kind == "union":
                tag_lines_union.append(f"union {tname};")
            else:
                tag_lines_enum.append(f"enum {tname};")

    # ---- Phase 2: group function forward-decls ----
    extern_decls = [d for s, d, _ in sigs if s != "static"]
    static_decls = [d for s, d, _ in sigs if s == "static"]

    # ---- Phase 2.5: double-prefix alias injection (wave338) ----------------
    # codegen's `ast_` special case (codegen_c_prefix_redundant_with_name,
    # codegen.x L3568) forces the module prefix onto `export extern` names
    # even when the name already starts with that prefix. This produces ghost
    # declarations like `ast_ast_arena_block_get` while internal call sites
    # use the single-prefix `ast_arena_block_get` (the real C symbol defined
    # in runtime_pipeline_abi.o). External modules (pipeline.x,
    # runtime_driver_diagnostic_thin.x) correctly reference the double-prefix
    # name, so we KEEP the double-prefix decl AND add a single-prefix alias
    # for internal call sites. Safe: unused extern aliases are link-time
    # no-ops; used aliases resolve to the real symbol.
    declared_names = {n for _, _, n in sigs}
    alias_decls = []
    alias_seen = set()
    for _s, d, name in sigs:
        # Detect <mod>_<mod>_<rest> double-prefix pattern (e.g. ast_ast_X)
        m = re.match(r"^([a-z][a-z0-9]*)_([a-z][a-z0-9]*)_(.+)$", name)
        if not m:
            continue
        mod, mod2, rest = m.group(1), m.group(2), m.group(3)
        if mod != mod2:
            continue  # not a double prefix (e.g. main_run_compiler_c)
        single_name = f"{mod}_{rest}"
        if single_name in declared_names or single_name in alias_seen:
            continue  # single-prefix already declared — no alias needed
        # Only add alias if the single-prefix name is actually CALLED in
        # this file (avoid cluttering with unused aliases).
        if not re.search(r"\b" + re.escape(single_name) + r"\s*\(", src):
            continue
        # Build alias by replacing the first occurrence of the double-prefix
        # name with the single-prefix name in the canonical decl string.
        alias_decl = d.replace(name, single_name, 1)
        alias_seen.add(single_name)
        alias_decls.append(alias_decl)
    if alias_decls:
        extern_decls.extend(alias_decls)

    # ---- Phase 3: build combined block ----
    block_lines = [""]
    _alias_cnt = len(alias_decls)
    header_note = (
        f"/* driver_leaf post_E_fixup: "
        f"{len(typedef_lines)} typedefs + {len(tag_seen)} tags + {len(sigs)} function forward-decls"
        + (f" + {_alias_cnt} double-prefix aliases" if _alias_cnt else "")
        + " */"
    )
    block_lines.append(header_note)
    if typedef_lines:
        block_lines.append("/* hoisted top-level typedefs (forward-decls reference these) */")
        block_lines.extend(typedef_lines)
    if tag_seen:
        block_lines.append("/* incomplete-type tag decls (avoid prototype-scope local tags) */")
        if tag_lines_struct:
            block_lines.extend(sorted(tag_lines_struct))
        if tag_lines_union:
            block_lines.extend(sorted(tag_lines_union))
        if tag_lines_enum:
            block_lines.extend(sorted(tag_lines_enum))
    if extern_decls:
        block_lines.append("/* extern / no-storage function decls */")
        block_lines.extend(extern_decls)
    if static_decls:
        block_lines.append("/* static (file-local) function decls */")
        block_lines.extend(static_decls)
    block_lines.append("/* --- end post_E_fixup forward-decls --- */")
    block_lines.append("")
    block = "\n".join(block_lines)

    # ---- Phase 4: insert block at first real-content line ----
    lines = src.split("\n")
    insert_at = 0
    for i, ln in enumerate(lines):
        s = ln.strip()
        if not s:
            continue
        if s.startswith("DBG-"):
            continue
        if s.startswith("#"):
            continue
        if s.startswith("/*") or s.endswith("*/") or s.startswith("*"):
            continue
        if s.startswith("//"):
            continue
        insert_at = i
        break
    new_lines = lines[:insert_at] + [block.rstrip("\n")] + lines[insert_at:]
    return "\n".join(new_lines)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("input", help="raw -E emitted C file path")
    ap.add_argument("output", help="post-processed C file path")
    ap.add_argument(
        "--scrub-init-globals",
        action="store_true",
        help="remove cross-module BSS assignments from init_globals() body "
        "(parser_x.o only; parity with assemble_parser_gen_from_x.py)",
    )
    ap.add_argument(
        "--append-typeck-bodies",
        action="store_true",
        help="append 5 SHARED POSIX C body definitions (typeck_check_expr_impl_mega, "
        "typeck_block_const_init_is_const, typeck_const_init_not_constant, "
        "typeck_overload_expected_ret_peek, typeck_get_field_offset_from_layout_deps) "
        "that the current typeck.x emitter regressed (typeck_x.o pure-ld UNDEF fix).",
    )
    args = ap.parse_args(argv[1:])

    with open(args.input, "r", encoding="utf-8", errors="replace") as f:
        src = f.read()

    # Order matters: dedup FIRST (removes colliding duplicate definitions +
    # externs from the body), THEN scrub init_globals, THEN inject
    # forward-decls (which also adds double-prefix aliases), THEN append
    # typeck bodies. dedup before inject ensures inject_forward_decls does
    # not pick up self-calling duplicate signatures as forward-decls.
    src = dedup_colliding_definitions(src)
    if args.scrub_init_globals:
        src = scrub_init_globals(src)
    src = inject_forward_decls(src)
    if args.append_typeck_bodies:
        src = append_typeck_missing_bodies(src)

    # Atomic write via temp + os.replace
    tmp_out = args.output + ".tmp"
    with open(tmp_out, "w", encoding="utf-8") as f:
        f.write(src)
    os.replace(tmp_out, args.output)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
