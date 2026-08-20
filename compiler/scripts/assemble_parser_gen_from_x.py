#!/usr/bin/env python3
"""Assemble product parser_gen.c from tip parser.x -E + product renames.

wave324 / M4 7.2.2 — cold chain authority is parser.x, not the pinned twin.

Layers (G.7 single assemble body; do not blind-overwrite with bare tip -E):
  0. tip base = caller-provided -E output of src/parser/parser.x
  1. module-prefix rename: bare export faces → parser_*
  2. product surface renames for already-prefixed helpers
     (lexer_copy_* / pipeline_module_reset_* → parser_lexer_* / parser_pipeline_*)
  3. X-mangle demangle: name_Type_ptr_… → short product face (defs + call sites)
  4. init_globals scrub: tip freestanding zeros monofile lexer BSS that live
     only in lexer_x.o (static); keep parser-owned g_lparen_ctrl_* only
  5. stdlib headers for residual companions

PLATFORM: SHARED freestanding parser cold assemble.
Pin seeds/parser_gen.linux.x86_64.c is archaeology / true-cold egg only.

Usage (cwd = compiler/):
  python3 scripts/assemble_parser_gen_from_x.py \\
      --tip /tmp/parser_tip_e.c --out parser_gen.c
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

_KEEP_PREFIXES = (
    "parser_",
    "pipeline_",
    "ast_",
    "glue_",
    "driver_",
    "xlang_",
    "std_",
    "io_",
    "ctx_",
    "process_",
    "args_",
    "lexer_",
    "typeck_",
    "codegen_",
    "asm_",
    "init_",
    "fs_",
    "token_",
)

# Product pin surface names for helpers that tip -E emits without parser_ prefix
# because their .x names already start with lexer_/pipeline_ (KEEP list).
# PLATFORM: SHARED — pure-ld / pipeline_x call the parser_* faces.
_PRODUCT_SURFACE_RENAMES = (
    ("lexer_copy_from_parse_expr_result_into", "parser_lexer_copy_from_parse_expr_result_into"),
    ("lexer_copy_into", "parser_lexer_copy_into"),
    ("lexer_pos_before_run", "parser_lexer_pos_before_run"),
    ("lexer_token_run_len", "parser_lexer_token_run_len"),
    ("pipeline_module_reset_parse_counters", "parser_pipeline_module_reset_parse_counters"),
    ("compound_assign_token_to_expr_kind", "parser_compound_assign_token_to_expr_kind"),
)

# Tip freestanding -E emits bare result structs; product pin / pipeline seeds use
# parser_* type tags (ABI face names + G.7 single surface). Longer first.
# PLATFORM: SHARED freestanding parser cold assemble.
_PRODUCT_STRUCT_RENAMES = (
    ("LibraryParseScanResult", "parser_LibraryParseScanResult"),
    ("LibraryParseResult", "parser_LibraryParseResult"),
    ("CollectImportsResult", "parser_CollectImportsResult"),
    ("ExternParseResult", "parser_ExternParseResult"),
    ("TopLevelLetResult", "parser_TopLevelLetResult"),
    ("TypeAliasResult", "parser_TypeAliasResult"),
    ("TrySkipAllowResult", "parser_TrySkipAllowResult"),
    ("ParseBlockResult", "parser_ParseBlockResult"),
    ("ParseExprResult", "parser_ParseExprResult"),
    ("ParseIntoResult", "parser_ParseIntoResult"),
    ("OneFuncResult", "parser_OneFuncResult"),
    ("ParseResult", "parser_ParseResult"),
)

# Include struct-by-value returns (ParseIntoResult, OneFuncResult, …) — tip -E
# emits those for product parse faces; pointer-only pattern missed them and left
# bare parse_into_buf / onefunc_scratch_empty (wave324 pure-ld UNDEF root).
_TOP_DEF_RE = re.compile(
    r"^(?:int32_t|void|uint8_t\s*\*|int64_t|float|double|int|size_t|ptrdiff_t|"
    r"uint32_t|uint64_t|struct\s+\w+\s*\*|struct\s+\w+)\s+(\w+)\s*\(",
    re.M,
)

# Only freestanding Cap/X-mangle suffixes that tip -E actually emits on parser.x
# exports. Do NOT use bare Lexer/Type/Module — those match struct tags like
# lexer_Lexer and collapse slice layouts (wave324 host-cc redef root).
# PLATFORM: SHARED freestanding parser cold assemble.
_MANGLE_CUT_RE = re.compile(
    r"_(?:OneFuncResult|ParseExprResult|CollectImportsResult|"
    r"LibraryParseResult|TrySkipAllowResult|TopLevelLetResult|"
    r"TypeAliasResult|ExternParseResult|ParseIntoResult|"
    r"ASTArena|PipelineDepCtx)_"
)

_BANNER = """/* wave324 parser M4 cold assemble from .x (7.2.2):
 *   base = tip xlang -E src/parser/parser.x
 *   module-prefix rename: bare export faces → parser_*
 *   product surface renames: lexer_* / pipeline_module_* → parser_* faces
 *   X-mangle demangle: *_Type_ptr_* → short product faces
 *   init_globals scrub: drop monofile lexer BSS zeros (live in lexer_x.o)
 * G.7: product authority = parser.x + assemble; pin seed archaeology only.
 * PLATFORM: SHARED freestanding parser cold assemble.
 */
"""


def _bare_export_names(src: str) -> list[str]:
    names: set[str] = set()
    for m in _TOP_DEF_RE.finditer(src):
        name = m.group(1)
        if name == "main":
            continue
        if any(name.startswith(p) for p in _KEEP_PREFIXES):
            continue
        names.add(name)
    return sorted(names, key=len, reverse=True)


def _apply_module_prefix(src: str, bare_names: list[str]) -> str:
    for bare in bare_names:
        pref = "parser_" + bare
        src = re.sub(rf"\b{re.escape(bare)}\b", pref, src)
    return src


def _apply_product_surface_renames(src: str) -> str:
    # Longer first so lexer_copy_from_parse_expr_result_into wins over lexer_copy_into.
    pairs = sorted(_PRODUCT_SURFACE_RENAMES, key=lambda p: len(p[0]), reverse=True)
    for old, new in pairs:
        src = re.sub(rf"\b{re.escape(old)}\b", new, src)
    return src


def _apply_product_struct_renames(src: str) -> str:
    pairs = sorted(_PRODUCT_STRUCT_RENAMES, key=lambda p: len(p[0]), reverse=True)
    for old, new in pairs:
        # Avoid double-prefix if already parser_Old.
        src = re.sub(rf"\b(?<!parser_){re.escape(old)}\b", new, src)
    return src


def _short_of_mangle(name: str) -> str | None:
    """Strip X freestanding type mangle suffix; return short face or None.

    Only cut at known Cap/X result/arena tags (OneFuncResult, ASTArena, …).
    Bare `_ptr_into` product faces and struct tags (lexer_Lexer) are left alone.
    """
    m = _MANGLE_CUT_RE.search(name)
    if m and m.start() >= 3:
        return name[: m.start()]
    return None


def _demangle_product_faces(src: str) -> tuple[str, int]:
    # Prefer top-level defs only, then rewrite all word occurrences of those names
    # (call sites + externs). Scanning every identifier over-demangles type tags.
    pairs: list[tuple[str, str]] = []
    seen: set[str] = set()
    for m in _TOP_DEF_RE.finditer(src):
        n = m.group(1)
        if n in seen:
            continue
        short = _short_of_mangle(n)
        if short and short != n:
            pairs.append((n, short))
            seen.add(n)
    pairs.sort(key=lambda p: len(p[0]), reverse=True)
    for mangled, short in pairs:
        src = re.sub(rf"\b{re.escape(mangled)}\b", short, src)
    return src, len(pairs)


def _scrub_init_globals(src: str) -> str:
    """Rewrite init_globals to only zero parser-owned BSS.

    Tip freestanding -E emits monofile init that zeros g_lexer_* living as
    statics in lexer_x.o — undeclared in parser TU and must not dual-define.
    PLATFORM: SHARED freestanding cold assemble.
    """
    # Replace entire static void init_globals(void) { ... } body.
    pat = re.compile(
        r"static void init_globals\(void\)\s*\{.*?\n\}",
        re.S,
    )
    repl = (
        "static void init_globals(void) {\n"
        "  /* wave324: parser-owned BSS only; lexer sticky state lives in lexer_x.o */\n"
        "  g_lparen_ctrl_last_pos[0] = ((size_t)(0));\n"
        "  g_lparen_ctrl_hits[0] = 0;\n"
        "}"
    )
    new_src, n = pat.subn(repl, src, count=1)
    if n == 0:
        # Fallback: strip any bare g_lexer_* assignment lines.
        lines = []
        for line in src.splitlines(True):
            if re.match(r"\s*g_lexer_\w+\s*=", line):
                continue
            lines.append(line)
        return "".join(lines)
    return new_src


def _strip_freestanding_main(src: str) -> str:
    """Drop tip freestanding main() — pulls std_fs_* UNDEF into product pure-ld."""
    return re.sub(
        r"^int32_t main\(void\)\s*\{.*?\n\}\n?",
        "/* wave324: freestanding main() stripped (product library TU) */\n",
        src,
        count=1,
        flags=re.M | re.S,
    )


def assemble(tip_text: str) -> str:
    bare = _bare_export_names(tip_text)
    body = _apply_module_prefix(tip_text, bare)
    body = _apply_product_surface_renames(body)
    body = _apply_product_struct_renames(body)
    body, n_demangle = _demangle_product_faces(body)
    body = _scrub_init_globals(body)
    body = _strip_freestanding_main(body)
    # Forward decl: tip -E may call xlang_trait_reg_reset_c before its later extern
    # (host-cc ISO C99 implicit-decl error). Pin uses local void* extern at call site.
    # PLATFORM: SHARED freestanding assemble hoist.
    hdr = (
        "#include <stdint.h>\n"
        "#include <stddef.h>\n"
        "#include <stdlib.h>\n"
        "#include <string.h>\n"
        "#include <unistd.h>\n"
        "#include <sys/types.h>\n"
        "struct ast_ASTArena;\n"
        "extern void xlang_trait_reg_reset_c(struct ast_ASTArena * arena);\n"
    )
    banner = _BANNER.replace(
        "X-mangle demangle:",
        f"X-mangle demangle ({n_demangle}):",
    )
    return banner + hdr + body


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--tip", required=True, help="path to tip xlang -E output (.c)")
    ap.add_argument("--out", required=True, help="output parser_gen.c path")
    ap.add_argument(
        "--compiler-root",
        default=None,
        help="compiler/ root (default: parent of scripts/)",
    )
    args = ap.parse_args(argv)

    tip_path = Path(args.tip)
    if not tip_path.is_file() or tip_path.stat().st_size < 1024:
        print(f"assemble_parser_gen: tip too small or missing: {tip_path}", file=sys.stderr)
        return 1

    tip_text = tip_path.read_text(encoding="utf-8", errors="replace")
    bare = _bare_export_names(tip_text)
    out_text = assemble(tip_text)
    out_path = Path(args.out)
    out_path.write_text(out_text, encoding="utf-8")
    print(
        f"assemble_parser_gen: OK out={out_path} bytes={out_path.stat().st_size} "
        f"bare_renamed={len(bare)}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
