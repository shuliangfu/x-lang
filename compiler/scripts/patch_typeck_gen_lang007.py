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

CALL_BODY = """\
SHUX_LIB_WEAK int32_t typeck_check_expr_call(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  /* LANG-007: always use glue path (S0 extern requires unsafe). */
  extern int32_t pipeline_typeck_check_expr_call_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  return pipeline_typeck_check_expr_call_c(module, arena, expr_ref, return_type_ref, ctx);
}
"""

DEREF_BODY = """\
SHUX_LIB_WEAK int32_t typeck_check_expr_deref(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx) {
  /* LANG-007: always use glue path (S0 deref requires unsafe). */
  extern int32_t pipeline_typeck_check_expr_deref_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  return pipeline_typeck_check_expr_deref_c(module, arena, expr_ref, return_type_ref, ctx);
}
"""

BLOCK_BODY = """\
SHUX_LIB_WEAK int32_t typeck_check_block_one_region(struct ast_Module * module, struct ast_ASTArena * arena, int32_t block_ref, int32_t return_type_ref, struct ast_PipelineDepCtx * ctx, int32_t idx) {
  /* LANG-007: push unsafe depth for unsafe { } regions before seed/glue region check. */
  extern int32_t pipeline_typeck_unsafe_depth_push_c(struct ast_PipelineDepCtx *ctx);
  extern void pipeline_typeck_unsafe_depth_pop_c(struct ast_PipelineDepCtx *ctx, int32_t saved_unsafe_depth);
  extern int32_t pipeline_typeck_check_block_one_region_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref, int32_t region_idx, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  extern int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *arena, int32_t block_ref, int32_t region_idx);
  int32_t saved_ud = 0;
  int32_t rc;
  if (pipeline_block_region_is_unsafe(arena, block_ref, idx)) {
    saved_ud = pipeline_typeck_unsafe_depth_push_c(ctx);
  }
  rc = pipeline_typeck_check_block_one_region_c(module, arena, block_ref, idx, return_type_ref, ctx);
  if (pipeline_block_region_is_unsafe(arena, block_ref, idx)) {
    pipeline_typeck_unsafe_depth_pop_c(ctx, saved_ud);
  }
  return rc;
}
"""


def replace_weak_fn(src: str, name: str, new_body: str) -> tuple[str, bool]:
    """Replace SHUX_LIB_WEAK int32_t <name>(...) { ... } balanced braces."""
    pat = re.compile(
        rf"(SHUX_LIB_WEAK\s+int32_t\s+{re.escape(name)}\s*\([^;]*?\)\s*\{{)",
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
                if "pipeline_typeck_check_expr_call_c" in old and name == "typeck_check_expr_call":
                    return src, False  # already delegated
                if "pipeline_typeck_check_expr_deref_c" in old and name == "typeck_check_expr_deref":
                    return src, False
                if "pipeline_typeck_unsafe_depth_push_c" in old and name == "typeck_check_block_one_region":
                    return src, False
                return src[:start] + new_body.rstrip() + "\n" + src[end:], True
        i += 1
    raise RuntimeError(f"unbalanced braces for {name}")


def main() -> int:
    if not PATH.is_file():
        print(f"patch_typeck_gen_lang007: skip (missing {PATH.name})")
        return 0
    src = PATH.read_text(encoding="utf-8", errors="replace")
    changed = False
    for name, body in (
        ("typeck_check_expr_call", CALL_BODY),
        ("typeck_check_expr_deref", DEREF_BODY),
        ("typeck_check_block_one_region", BLOCK_BODY),
    ):
        src, did = replace_weak_fn(src, name, body)
        if did:
            print(f"patch_typeck_gen_lang007: rewrote {name}")
            changed = True
        else:
            print(f"patch_typeck_gen_lang007: {name} already ok or missing")
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
