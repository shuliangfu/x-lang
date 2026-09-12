#!/usr/bin/env python3
# sync_stretch_audit_harness.py — regenerate the B-minus equivalence harness
# twin set + dispatch table from the current migrated surface.
#
# Inputs (authorities):
#   src/asm/pthin_stretch_audit.x                          — migrated exports
#   seeds/parser_asm/parser_asm_emit_heavy_stretch_suite_slice.inc — gated twins
#   seeds/parser_asm_lex_step_bridge.from_x.c + suite skip helpers — link faces
#
# Outputs (fully regenerated each run):
#   scripts/pthin_stretch_audit_eq_twins.h — c_ref_* static twins (verbatim
#     gated C bodies, renamed) + helper authority copies
#   scripts/pthin_stretch_audit_eq_table.h — shims + k_cases[] for every
#     migrated 2-arg audit (3-arg flag audits get both polarities;
#     out-param audits get null + packed-slot polarities)
#
# PLATFORM: SHARED (host-side generator; output compiled on both ends).
import re
import sys

SUITE = "seeds/parser_asm/parser_asm_emit_heavy_stretch_suite_slice.inc"
XFILE = "src/asm/pthin_stretch_audit.x"
TWINS = "scripts/pthin_stretch_audit_eq_twins.h"
TABLE = "scripts/pthin_stretch_audit_eq_table.h"

# helper authority copies (link faces used by twins; refresh with sources)
HELPERS = '''
/* ── helper authority copies (verbatim from their slices; refresh together) ── */
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
/* v5.36: skip stubs live after suite helpers; diag_after_imports calls these. */
struct parser_asm_lexer parser_asm_skip_one_struct_slice_c(struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source);
struct parser_asm_lexer parser_asm_skip_imports_slice_c(struct parser_asm_lexer lex,
                                                        struct parser_asm_slice_u8 *source);
void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r) {
  if (!out)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}
static int32_t parser_asm_stretch_is_type_start_kind_c(int32_t kind) {
  return kind == (int32_t)TOKEN_I32 || kind == (int32_t)TOKEN_I64 || kind == (int32_t)TOKEN_BOOL
      || kind == (int32_t)TOKEN_U8 || kind == (int32_t)TOKEN_U32 || kind == (int32_t)TOKEN_U64
      || kind == (int32_t)TOKEN_USIZE || kind == (int32_t)TOKEN_VOID || kind == (int32_t)TOKEN_IDENT;
}

static int32_t parser_asm_stretch_ident_byte_ok_c(uint8_t c, int32_t is_first) {
  int alpha = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
  if (is_first != 0)
    return alpha ? 1 : 0;
  return alpha || (c >= '0' && c <= '9') ? 1 : 0;
}
int32_t parser_asm_stretch_bind_name_validate_c(const uint8_t *name, int32_t len) {
  int32_t i;
  if (!name || len <= 0 || len > 63)
    return 0;
  if (parser_asm_stretch_ident_byte_ok_c(name[0], 1) == 0)
    return 0;
  for (i = 1; i < len; i++) {
    if (parser_asm_stretch_ident_byte_ok_c(name[i], 0) == 0)
      return 0;
  }
  return 1;
}
int32_t parser_asm_is_compound_assign_token_c(int32_t kind) {
  return kind == (int32_t)TOKEN_PLUS_EQ || kind == (int32_t)TOKEN_MINUS_EQ || kind == (int32_t)TOKEN_STAR_EQ
      || kind == (int32_t)TOKEN_SLASH_EQ || kind == (int32_t)TOKEN_PERCENT_EQ || kind == (int32_t)TOKEN_AMP_EQ
      || kind == (int32_t)TOKEN_PIPE_EQ || kind == (int32_t)TOKEN_CARET_EQ || kind == (int32_t)TOKEN_LSHIFT_EQ
      || kind == (int32_t)TOKEN_RSHIFT_EQ;
}
/* Top-level coarse classification codes (suite enum; needed by classify helper). */
enum {
  STRETCH_TOP_UNKNOWN = 0,
  STRETCH_TOP_IMPORT = 1,
  STRETCH_TOP_CONST_BIND = 2,
  STRETCH_TOP_FUNCTION = 3,
  STRETCH_TOP_STRUCT = 4,
  STRETCH_TOP_ENUM = 5,
  STRETCH_TOP_EXTERN = 6,
  STRETCH_TOP_LET = 7,
  STRETCH_TOP_TRAIT = 8,
  STRETCH_TOP_IMPL = 9
};
/* Stretch token aliases used by field-kind classifiers (≡ heavy_stretch_slice). */
enum {
  STRETCH_TOKEN_IDENT = 1,
  STRETCH_TOKEN_ALIGN = 33
};
/* v4.8: kind classifiers + thin bind audits (single authority = bind_name_validate). */
int32_t parser_asm_stretch_struct_field_name_kind_c(int32_t kind) {
  if (kind == STRETCH_TOKEN_IDENT)
    return 1;
  if (kind == 17) /* TOKEN_PACKED legacy */
    return 1;
  if (kind == 18) /* TOKEN_SOA legacy */
    return 1;
  if (kind == (int32_t)TOKEN_TYPE)
    return 1;
  if (kind == (int32_t)TOKEN_PACKED)
    return 1;
  if (kind == (int32_t)TOKEN_SOA)
    return 1;
  if (kind == STRETCH_TOKEN_ALIGN)
    return 1;
  return 0;
}
int32_t parser_asm_stretch_struct_field_continues_kind_c(int32_t kind) {
  return parser_asm_stretch_struct_field_name_kind_c(kind) != 0 || kind == STRETCH_TOKEN_ALIGN;
}
static int32_t parser_asm_stretch_struct_field_bind_audit_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                     int32_t name_len) {
  if (!source || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
}
static int32_t parser_asm_stretch_enum_variant_bind_audit_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                     int32_t name_len) {
  if (!source || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
}
static int32_t parser_asm_stretch_enum_discriminant_kind_audit_c(int32_t kind) {
  return kind == (int32_t)TOKEN_I32 || kind == (int32_t)TOKEN_I64 || kind == (int32_t)TOKEN_INT ? 1 : 0;
}
/* v4.9: function_name_audit is a thin wrap of bind_name_validate (G.7). */
static int32_t parser_asm_stretch_function_name_audit_c(const uint8_t *name, int32_t name_len) {
  return parser_asm_stretch_bind_name_validate_c(name, name_len);
}
/* v5.7: struct_layout_name_audit is the same thin wrap (G.7). */
static int32_t parser_asm_stretch_struct_layout_name_audit_c(const uint8_t *name, int32_t name_len) {
  return parser_asm_stretch_bind_name_validate_c(name, name_len);
}
/* v5.8: loop_stmt_body is a real flag3 .x port; c_ref twin comes from the
 * gated suite body via sync (no harness stub — stub returned 0 and would
 * diverge on score+= callers unlocked this wave). */
/* v5.9: import_select_list is a real flag3 inout .x port; c_ref twin comes
 * from the gated suite body via sync. item_bind stays suite-local thin wrap
 * of bind_name_validate (G.7). path_validate copy mirrors pthin_stretch.x
 * (product authority) so audit_x.o UNDEF resolves in this TU. */
/* v5.10: diag_lex_after_imports(+buf) are real .x ports (ABI-widened no-lex
 * roots); c_ref twins come from the gated suite bodies via sync. Fresh
 * lexer_init copy matches foundation authority (pos=0,line=1,col=1) so the
 * diag_lex c_ref twin can call it without pulling pthin_foundation.o. */
struct parser_asm_lexer parser_asm_lexer_init_c(void) {
  struct parser_asm_lexer lex;
  lex.pos = 0;
  lex.line = 1;
  lex.col = 1;
  return lex;
}
/* v5.32: diag_parse_one_mega(+full_deep chain) are real .x ports (ABI-widened
 * no-lex roots). Still-C (data,len) leaves they call are provided after c_ref
 * fwds as HARNESS_MEGA_STILL_C (product suite remains authority). */
static int32_t parser_asm_stretch_import_select_item_bind_audit_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                           int32_t name_len) {
  if (!source || name_len <= 0)
    return 0;
  return parser_asm_stretch_bind_name_validate_c(source->data + token_start, name_len);
}
int32_t parser_asm_stretch_import_path_validate_c(const uint8_t *path, int32_t path_len) {
  int32_t i;
  if (!path || path_len <= 0)
    return 0;
  if (path_len > 63)
    path_len = 63;
  for (i = 0; i < path_len; i++) {
    uint8_t c = path[i];
    if (c == 0)
      break;
    if (c == (uint8_t)'.')
      continue;
    if (parser_asm_stretch_ident_byte_ok_c(c, 0) == 0)
      return 0;
  }
  return 1;
}
'''


# v5.39: leftover helpers now defined by audit_x.o. suite_helper_defs must
# emit `static` copies so c_ref twins keep C authority without duplicate T.
HELPERS_PORTED_TO_X = {
    "parser_asm_stretch_vector_type_ident_audit_c",
    "parser_asm_stretch_builtin_vec_token_audit_c",
    # v5.40 leftover Route C flatten (kind / source+off); static copies keep
    # C authority for c_ref twins without duplicate T vs audit_x.o.
    "parser_asm_stretch_spawn_kw_audit_c",
    "parser_asm_stretch_match_subject_ident_audit_c",
}

SUITE_HELPER_SIGS = [
    "static int32_t parser_asm_stretch_expr_binop_kinds_probe_c(",
    "void parser_asm_skip_balanced_parens_into_slice_c(",
    "void parser_asm_skip_balanced_braces_into_slice_c(",
    "void parser_asm_stretch_skip_balanced_brackets_into_c(",
    "struct parser_asm_lexer parser_asm_stretch_skip_type_suffix_c(",
    "struct parser_asm_lexer parser_asm_stretch_skip_one_param_type_c(",
    # v4.6: kinds[] audit c_ref twins call these suite helpers by name
    "int32_t parser_asm_stretch_classify_toplevel_c(",
    "int32_t parser_asm_stretch_peek_kind_chain_c(",
    # v5.3: body_* c_ref twins still call static advance_to_* out-param helpers
    # (by-value C authority). .x ports expand them inplace; twins keep the C shape.
    # Only helpers whose callees are already migrated (c_ref-rewritable) belong
    # here. v5.7: if_stmt_body .x expands if_advance inplace; c_ref twin still
    # calls the static helper (by-value C authority).
    "static int32_t parser_asm_stretch_struct_advance_to_body_lex_c(",
    "static int32_t parser_asm_stretch_enum_advance_to_body_lex_c(",
    "static int32_t parser_asm_stretch_trait_advance_to_body_lex_c(",
    "static int32_t parser_asm_stretch_match_advance_to_arms_lex_c(",
    "static int32_t parser_asm_stretch_impl_advance_to_body_lex_c(",
    # v5.5: function_body_block_stmt c_ref twin still calls function_advance.
    "static int32_t parser_asm_stretch_function_advance_to_body_lex_c(",
    # v5.7: if_stmt_body c_ref twin still calls if_advance.
    "static int32_t parser_asm_stretch_if_advance_to_body_lex_c(",
    # v5.6: deep-scan / library_scan / match_subject helpers (small suite defs)
    "int32_t parser_asm_stretch_spawn_kw_audit_c(",
    "int32_t parser_asm_stretch_match_subject_ident_audit_c(",
    # v5.36: simd from_at leftover (lexer_result by-val; .x inlines). Callees
    # first so from_at can call them without a forward decl.
    "int32_t parser_asm_stretch_simd_builtin_audit_c(",
    "int32_t parser_asm_stretch_vector_type_ident_audit_c(",
    "int32_t parser_asm_stretch_builtin_vec_token_audit_c(",
    "int32_t parser_asm_stretch_simd_builtin_deep_from_at_audit_c(",
    # v5.36: diag_fail leftover — product helper returns lexer_result.
    "struct parser_asm_lexer_result parser_asm_diag_after_imports_then_structs_slice_c(",
]

# v5.36: slice mega_full_deep is a real .x port (c_ref from gated suite).
# Buf wrapper stays still-C and forwards to the C reference (parents that
# score+= mega_buf must not observe the .x slice). Must follow HARNESS_SKIP_STUBS.
HARNESS_MEGA_STILL_C = r'''
/* v5.36: mega_buf still-C wrapper → c_ref slice (pointer ABI). */
int32_t parser_asm_stretch_diag_fn_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len) {
  struct parser_asm_lexer lex;
  struct parser_asm_slice_u8 sl;
  if (!lex_inout || !data || len <= 0)
    return 0;
  lex = *(struct parser_asm_lexer *)lex_inout;
  sl.data = data;
  sl.length = (size_t)len;
  return c_ref_diag_fn_mega_full_deep_audit(&lex, &sl);
}
'''

# v5.6: harness-local skip stubs (real skip_one_struct_into is ~800 lines +
# generic-bound/cfg deps — too heavy for the eq TU). Stubs match the audit
# corpus shape: advance to '{' / skip balanced braces; skip_imports returns
# lex unchanged when no CONST-import prefix (eq synth rarely stresses cfg).
# Product g05 links the real suite authority via the bridge inplace wrappers.
HARNESS_SKIP_STUBS = r'''
/* v5.6 harness stub — G.7 product authority remains suite skip_one_struct_slice. */
struct parser_asm_lexer parser_asm_skip_one_struct_slice_c(struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer after;
  int32_t guard;
  if (!source)
    return lex;
  guard = 0;
  for (;;) {
    if (guard++ > 256)
      return lex;
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_LBRACE) {
      parser_asm_skip_balanced_braces_into_slice_c(&after, r.next_lex, source);
      return after;
    }
    if (r.tok.kind == (int32_t)TOKEN_EOF)
      return lex;
    lex = r.next_lex;
  }
}

/* v5.6 harness stub — G.7 product authority remains suite skip_imports_slice. */
struct parser_asm_lexer parser_asm_skip_imports_slice_c(struct parser_asm_lexer lex,
                                                        struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  int32_t guard;
  if (!source)
    return lex;
  guard = 0;
  for (;;) {
    if (guard++ > 64)
      return lex;
    lexer_next_into(&r, lex, source);
    if (r.tok.kind != (int32_t)TOKEN_CONST)
      return lex;
    /* Consume a coarse "const … ;" span (eq corpus import shapes). */
    lex = r.next_lex;
    {
      int32_t g2 = 0;
      for (;;) {
        if (g2++ > 128)
          return lex;
        lexer_next_into(&r, lex, source);
        if (r.tok.kind == (int32_t)TOKEN_SEMICOLON) {
          lex = r.next_lex;
          break;
        }
        if (r.tok.kind == (int32_t)TOKEN_EOF)
          return lex;
        lex = r.next_lex;
      }
    }
  }
}
'''


def suite_helper_defs(suite, exports=None):
    """Pull suite helper defs into twins.h.

    When `exports` is set (migrated audit names), rewrite calls inside the
    helper bodies onto `c_ref_*` twins. advance_to_* helpers take lexer
    by value and call `&lex` or bare `lex`; c_ref twins are pointer-ABI, so
    bare `lex` becomes `&lex` at the rewrite site.
    PLATFORM: SHARED — host-side harness generator.
    """
    out = []
    exports = exports or []
    for sig in SUITE_HELPER_SIGS:
        m = re.search(r"^" + re.escape(sig) + r"[^\n]*$(.*?)^}$", suite, re.S | re.M)
        if not m:
            # try lex_skip / diag_late for helpers that do not live in the suite.
            extra_src = ""
            for extra_fp in (
                "seeds/parser_asm/parser_asm_lex_skip_slice.inc",
                "seeds/parser_asm/parser_asm_diag_late_slice.inc",
            ):
                try:
                    extra_src += open(extra_fp).read() + "\n"
                except FileNotFoundError:
                    pass
            m = re.search(r"^" + re.escape(sig) + r"[^\n]*$(.*?)^}$", extra_src, re.S | re.M)
        if not m:
            raise SystemExit(f"helper def not found: {sig}")
        body = m.group(0)
        for n in HELPERS_PORTED_TO_X:
            if body.startswith("int32_t " + n) or body.startswith("static int32_t " + n):
                if not body.startswith("static "):
                    body = "static " + body
                break
        # strip audit-gate macros (daily no-op semantics) and their inner calls
        body = re.sub(r"PARSER_ASM_STRETCH_AUDIT_CALL\([^;]*\);", "(void)0;", body)
        for other in exports:
            base = other[len("parser_asm_stretch_"):-2]
            cref = f"c_ref_{base}"
            # Pointer-ABI c_ref twins always take void* — normalize both
            # `CALLEE(&lex, …)` and by-value `CALLEE(lex, …)` onto `c_ref_(&lex, …)`.
            body = body.replace(f"{other}(&", f"{cref}(&")
            body = re.sub(
                rf"{re.escape(other)}\(([a-zA-Z_])",
                rf"{cref}(&\1",
                body,
            )
        out.append(body + "\n")
    return "\n".join(out)


def main():
    suite = open(SUITE).read()
    xsrc = open(XFILE).read()

    # 1) migrated exports (2-arg audits; flag/out/buf detected by params)
    exports = re.findall(r"export function (parser_asm_stretch_\w+_c)\(", xsrc)
    flag3 = set()
    buf3 = set()
    buf4 = set()  # v5.37: (lex, data, len, is_const)
    out3 = {}  # name -> out param ident
    # v5.39: leftover Route C helpers (kind / name,len / source+off) are
    # exported from the same .x but are NOT (lex, source) eq audits.
    leftover_helpers = set()
    for m in re.finditer(r"export function (parser_asm_stretch_\w+_c)\(([^)]*)\): i32 \{", xsrc):
        params = m.group(2)
        p0 = params.strip()
        if not (p0.startswith("lex:") or p0.startswith("lex_inout:")):
            leftover_helpers.add(m.group(1))
            continue
        ncomma = params.count(",")
        if ncomma == 3 and "data: *u8" in params and "len: i32" in params:
            buf4.add(m.group(1))
        elif ncomma == 2:
            if "data: *u8" in params and "len: i32" in params:
                buf3.add(m.group(1))
            else:
                mo = re.search(r"(out_\w+): \*i32", params)
                if mo:
                    out3[m.group(1)] = mo.group(1)
                else:
                    flag3.add(m.group(1))
    audit_exports = [n for n in exports if n not in leftover_helpers]

    # 2) twins from the suite (gated pointer-ABI bodies)
    twins = []
    fwds = []
    have = set()
    # v5.33: require the FROM_X gate immediately above the twin. Ungated
    # void*-ABI still-C roots (e.g. diag_fn_mega_buf widened for .x callers
    # but not yet migrated) previously matched this regex and swallowed the
    # next function's #endif, dropping that twin (block_stmt_mega non-buf).
    for m in re.finditer(
        r"^#ifndef XLANG_PTHIN_STRETCH_AUDIT_FROM_X\n"
        r"int32_t (parser_asm_stretch_\w+_c)\(void \*lex_inout([^\n]*)\) \{$(.*?)^\}$\n#endif",
        suite, re.S | re.M,
    ):
        name, extra, body = m.group(1), m.group(2), m.group(3)
        if name not in audit_exports or name in have:
            continue
        have.add(name)
        base = name[len("parser_asm_stretch_"):-2]  # strip prefix and _c
        fm = re.search(name + r"\(void \*lex_inout, void \*source, int32_t (\w+)\)", suite)
        flagname = fm.group(1) if fm else "flag"
        om = re.search(name + r"\(void \*lex_inout, void \*source, int32_t \*(out_\w+)\)", suite)
        if name in buf4:
            twin_extra = ", uint8_t *data, int32_t len, int32_t is_const"
        elif name in buf3:
            twin_extra = ", uint8_t *data, int32_t len"
        elif name in out3:
            twin_extra = f", int32_t *{out3[name]}"
        elif name in flag3:
            twin_extra = f", int32_t {flagname}"
        else:
            twin_extra = ""
        body = body.replace(f"{name}(", f"c_ref_{base}(", 0)  # no self-calls
        # internal calls to other migrated audits → c_ref_ forms
        for other in audit_exports:
            if other != name:
                body = body.replace(f"{other}(", f"c_ref_{other[len('parser_asm_stretch_'):-2]}(")
        # v5.6: .x elides void validate_toplevel_token_c(r,…) — keep c_ref in sync
        # (validate pulls token_run_len/verify_kw tables too heavy for this TU).
        body = re.sub(
            r"\(void\)parser_asm_stretch_validate_toplevel_token_c\([^;]*\);",
            "/* elide void validate_toplevel (v5.6; matches .x) */",
            body,
        )
        if name in buf4:
            sig_line = f"static int32_t c_ref_{base}(void *lex_inout, uint8_t *data, int32_t len, int32_t is_const) {{\n"
        elif name in buf3:
            sig_line = f"static int32_t c_ref_{base}(void *lex_inout, uint8_t *data, int32_t len) {{\n"
        else:
            sig_line = f"static int32_t c_ref_{base}(void *lex_inout, void *source{twin_extra}) {{\n"
        fwds.append(sig_line.rstrip(" {\n") + ";")
        twins.append(
            f"/* Reference twin — verbatim copy of the gated C authority for {name}. */\n"
            + sig_line
            + f"{body}\n}}\n"
        )
    missing = [n for n in audit_exports if n not in have]
    if missing:
        print("WARN: no gated twin found for:", ", ".join(missing))
    if leftover_helpers:
        print(f"leftover helpers (not eq-table): {len(leftover_helpers)}")

    open(TWINS, "w").write(
        "/* AUTO-GENERATED by sync_stretch_audit_harness.py — do not edit.\n"
        " * Reference twins for every migrated audit; refreshed each wave. */\n"
        + HELPERS
        + "\n/* Forward decls so twins / advance_to helpers may call each other. */\n"
        + "\n".join(fwds) + "\n\n"
        # advance_to helpers after fwds so they can call c_ref_* (v5.3)
        + suite_helper_defs(suite, audit_exports)
        + HARNESS_SKIP_STUBS
        # v5.32: still-C leaves for mega/full_deep after skip stubs + c_ref fwds
        + HARNESS_MEGA_STILL_C
        + "\n".join(twins)
    )

    # 3) table: shims + rows
    rows = []
    for name in sorted(audit_exports):
        base = name[len("parser_asm_stretch_"):-2]
        if name in buf4:
            rows.append(f'    {{"{base}/1", r_{base}, x_{base}, 1, 0}},')
            rows.append(f'    {{"{base}/0", r_{base}, x_{base}, 0, 0}},')
        elif name in buf3:
            rows.append(f'    {{"{base}", r_{base}, x_{base}, 0, 0}},')
        elif name in out3:
            # flag=0 → NULL out (return only); flag=1 → pack out into high 16 bits
            rows.append(f'    {{"{base}/null", r_{base}, x_{base}, 0, 0}},')
            rows.append(f'    {{"{base}/slot", r_{base}, x_{base}, 1, 0}},')
        elif name in flag3:
            # v5.9: flag3 may also be inout (import_select_list max_names).
            inout = 1 if name in INOUT_SET else 0
            rows.append(f'    {{"{base}/1", c_ref_{base}, x_{base}, 1, {inout}}},')
            rows.append(f'    {{"{base}/0", c_ref_{base}, x_{base}, 0, {inout}}},')
        else:
            inout = 1 if name in INOUT_SET else 0
            rows.append(f'    {{"{base}", r_{base}, x_{base}, 0, {inout}}},')
    shims = []
    for name in sorted(audit_exports):
        base = name[len("parser_asm_stretch_"):-2]
        if name in buf4:
            shims.append(
                f"static int32_t x_{base}(void *l, void *s, int32_t f) {{ struct parser_asm_slice_u8 *sl_ = (struct parser_asm_slice_u8 *)s; if (!sl_) return 0; return {name}(l, sl_->data, (int32_t)sl_->length, f); }}")
            shims.append(
                f"static int32_t r_{base}(void *l, void *s, int32_t f) {{ struct parser_asm_slice_u8 *sl_ = (struct parser_asm_slice_u8 *)s; if (!sl_) return 0; return c_ref_{base}(l, sl_->data, (int32_t)sl_->length, f); }}")
        elif name in buf3:
            shims.append(
                f"static int32_t x_{base}(void *l, void *s, int32_t f) {{ (void)f; struct parser_asm_slice_u8 *sl_ = (struct parser_asm_slice_u8 *)s; if (!sl_) return 0; return {name}(l, sl_->data, (int32_t)sl_->length); }}")
            shims.append(
                f"static int32_t r_{base}(void *l, void *s, int32_t f) {{ (void)f; struct parser_asm_slice_u8 *sl_ = (struct parser_asm_slice_u8 *)s; if (!sl_) return 0; return c_ref_{base}(l, sl_->data, (int32_t)sl_->length); }}")
        elif name in out3:
            # Pack out into high 16 when f!=0 so check_one compares return+out.
            shims.append(
                f"static int32_t x_{base}(void *l, void *s, int32_t f) {{ int32_t slot = 0; int32_t rc = {name}(l, s, f ? &slot : 0); return f ? ((rc & 0xffff) | (slot << 16)) : rc; }}")
            shims.append(
                f"static int32_t r_{base}(void *l, void *s, int32_t f) {{ int32_t slot = 0; int32_t rc = c_ref_{base}(l, s, f ? &slot : 0); return f ? ((rc & 0xffff) | (slot << 16)) : rc; }}")
        elif name in flag3:
            shims.append(
                f"static int32_t x_{base}(void *l, void *s, int32_t f) {{ return {name}(l, s, f); }}")
        else:
            shims.append(
                f"static int32_t x_{base}(void *l, void *s, int32_t f) {{ (void)f; return {name}(l, s); }}")
            shims.append(
                f"static int32_t r_{base}(void *l, void *s, int32_t f) {{ (void)f; return c_ref_{base}(l, s); }}")
    externs = []
    for name in sorted(audit_exports):
        if name in buf4:
            externs.append(f"extern int32_t {name}(void *lex_inout, uint8_t *data, int32_t len, int32_t is_const);")
        elif name in buf3:
            externs.append(f"extern int32_t {name}(void *lex_inout, uint8_t *data, int32_t len);")
        elif name in out3:
            externs.append(f"extern int32_t {name}(void *lex_inout, void *source, int32_t *{out3[name]});")
        elif name in flag3:
            externs.append(f"extern int32_t {name}(void *lex_inout, void *source, int32_t flag);")
        else:
            externs.append(f"extern int32_t {name}(void *lex_inout, void *source);")
    open(TABLE, "w").write(
        "/* AUTO-GENERATED by sync_stretch_audit_harness.py — do not edit. */\n"
        + "\n".join(externs) + "\n\n"
        + "\n".join(shims)
        + "\n\nstatic const audit_case k_cases[] = {\n"
        + "\n".join(rows)
        + "\n};\n"
    )
    print(f"twins: {len(twins)}, table rows: {len(rows)} (exports {len(audit_exports)} leftover_helpers {len(leftover_helpers)})")
    return 0


# inout-contract audits (compare post-call end states, not immobility)
INOUT_SET = {
    "parser_asm_stretch_fn_param_list_audit_c",
    "parser_asm_stretch_skip_return_type_audit_c",
    # v5.9: import select-list advances past `}` (and mid-fail past last IDENT)
    "parser_asm_stretch_import_select_list_audit_c",
    # v5.39: leftover inout helper — skip allow(...) groups in front of struct
    "parser_asm_stretch_skip_allow_modifiers_c",
}


if __name__ == "__main__":
    sys.exit(main())
