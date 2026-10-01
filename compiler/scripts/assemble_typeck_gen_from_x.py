#!/usr/bin/env python3
"""Assemble product typeck_gen.c from tip typeck.x -E + wave317 companions.

wave322 / M4 7.4.1 — cold chain authority is typeck.x, not the pinned twin.

Layers (G.7 single assemble body; do not blind-overwrite with bare tip -E):
  0. tip base = caller-provided -E output of src/typeck/typeck.x
  1. module-prefix rename: bare export faces → typeck_* (product link contract)
  2. layer-3 short-face #defines (seeds/typeck_short_face_alias.from_x.c) inject early
  3. layer-1 Cap residual append (seeds/typeck_cap_residual.from_x.c)
  4. layer-2 mangle alias append (seeds/typeck_mangle_link_alias.from_x.c)
  5. stdlib headers for residual companions (string.h / stdlib)

PLATFORM: SHARED freestanding typeck cold assemble.
Pin seeds/typeck_gen.linux.x86_64.c is archaeology / true-cold egg only.

Usage (cwd = compiler/):
  python3 scripts/assemble_typeck_gen_from_x.py \\
      --tip /tmp/typeck_tip_e.c --out typeck_gen.c
  python3 scripts/assemble_typeck_gen_from_x.py \\
      --write-expr-layout typeck_gen.c \\
      --layout-out build_asm/selfhost_pabi/typeck_expr_layout.h
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# Top-level C function defs emitted by tip -E that already carry a product prefix
# stay as-is. Bare module-local exports (export function check_block …) must be
# renamed to typeck_* for phase1/pure-ld link faces.
_KEEP_PREFIXES = (
    "typeck_",
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
    "parser_",
    "codegen_",
    "asm_",
    "init_",
    "fs_",
)

_TOP_DEF_RE = re.compile(
    r"^(?:int32_t|void|uint8_t\s*\*|int64_t|float|double|int|size_t|ptrdiff_t)\s+(\w+)\s*\(",
    re.M,
)

_BANNER = """/* wave322 typeck M4 cold assemble from .x (7.4.1):
 *   base = tip xlang -E src/typeck/typeck.x
 *   module-prefix rename: bare export faces → typeck_*
 *   layer-3 short-face #defines = seeds/typeck_short_face_alias.from_x.c (inject early)
 *   layer-1 Cap residual append = seeds/typeck_cap_residual.from_x.c
 *   layer-2 mangle alias append = seeds/typeck_mangle_link_alias.from_x.c
 * G.7: product authority = typeck.x + companions; pin seed archaeology only.
 * PLATFORM: SHARED freestanding typeck cold assemble.
 */
"""


def _bare_export_names(src: str) -> list[str]:
    names: set[str] = set()
    for m in _TOP_DEF_RE.finditer(src):
        name = m.group(1)
        if any(name.startswith(p) for p in _KEEP_PREFIXES):
            continue
        names.add(name)
    # Longer names first so partial token collisions cannot reorder incorrectly
    # when applying successive rewrites (each bare is unique).
    return sorted(names, key=len, reverse=True)


def _apply_module_prefix(src: str, bare_names: list[str]) -> str:
    for bare in bare_names:
        pref = "typeck_" + bare
        src = re.sub(rf"\b{re.escape(bare)}\b", pref, src)
    return src


def _inject_after_slice_layouts(src: str, inject: str) -> str:
    lines = src.splitlines(True)
    inject_idx = 0
    for i, line in enumerate(lines):
        if "XLANG_SLICE_LAYOUTS" in line and "endif" in line:
            inject_idx = i + 1
            break
    else:
        # Fallback: after leading includes / guards / slice struct typedefs.
        for i, line in enumerate(lines):
            s = line.strip()
            if (
                line.startswith("#include")
                or line.startswith("#ifndef")
                or line.startswith("#define")
                or line.startswith("#if")
                or line.startswith("#endif")
                or line.startswith("#else")
                or line.startswith("#error")
                or line.startswith("struct xlang_slice")
                or s == ""
                or s.startswith("/*")
                or s.startswith("*")
                or s.startswith("*/")
                or s.startswith("typedef")
            ):
                inject_idx = i + 1
            else:
                break
    return "".join(lines[:inject_idx]) + "\n" + inject + "\n" + "".join(lines[inject_idx:])


def assemble(tip_text: str, short: str, cap: str, malias: str) -> str:
    bare = _bare_export_names(tip_text)
    body = _apply_module_prefix(tip_text, bare)
    body = _inject_after_slice_layouts(body, short)
    # Residual companions may call strcmp/malloc; tip -E freestanding often omits
    # string.h/stdlib.h. Prepend after banner (host-cc product path has them).
    hdr = (
        "#include <stdint.h>\n"
        "#include <stddef.h>\n"
        "#include <stdlib.h>\n"
        "#include <string.h>\n"
    )
    body = (
        body
        + "\n/* wave322 layer-1 Cap residual (seeds/typeck_cap_residual.from_x.c) */\n"
        + cap
        + "\n/* wave322 layer-2 mangle aliases (seeds/typeck_mangle_link_alias.from_x.c) */\n"
        + malias
    )
    return _BANNER + hdr + body


_CAP_MARK = "/* wave322 layer-1 Cap residual (seeds/typeck_cap_residual.from_x.c) */\n"
_MALIAS_MARK = "\n/* wave322 layer-2 mangle aliases (seeds/typeck_mangle_link_alias.from_x.c) */\n"


def splice_cap_residual(gen_path: Path, cap_path: Path) -> int:
    """w1504: re-splice layer-1 Cap residual into an existing typeck_gen.c.

    PLATFORM: SHARED — when tip -E of typeck.x is unavailable, the host-local
    typeck_gen.c is reused as-is and edits to seeds/typeck_cap_residual.from_x.c
    never reach typeck_x.o (the CTFE CALL fold kept truncating i64 results).
    The Cap residual sits between two fixed markers written by assemble(), so
    the seed text is authoritative for that span. Returns 0 unchanged,
    2 spliced, 1 error (markers missing: caller keeps the gen untouched).
    """
    if not gen_path.is_file() or not cap_path.is_file():
        return 1
    g = gen_path.read_text(encoding="utf-8", errors="replace")
    a = g.find(_CAP_MARK)
    b = g.find(_MALIAS_MARK)
    if a < 0 or b < 0 or b < a:
        print(f"assemble_typeck_gen: splice skip, markers missing in {gen_path}", file=sys.stderr)
        return 1
    a += len(_CAP_MARK)
    cap = cap_path.read_text(encoding="utf-8", errors="replace")
    if g[a:b] == cap:
        return 0
    gen_path.write_text(g[:a] + cap + g[b:], encoding="utf-8")
    print(f"assemble_typeck_gen: spliced Cap residual into {gen_path}", file=sys.stderr)
    return 2


_EXPR_LAYOUT_START = "enum ast_TypeKind {"
_EXPR_LAYOUT_END = "struct xlang_slice_ast_Expr {"


def write_expr_layout(gen_path: Path, out_path: Path | None) -> int:
    """Slice TypeKind, ExprKind, and struct ast_Expr out of typeck_gen.c.

    The bytes are the host-cc paste's own layout, not a second struct.
    The end marker is excluded. Fail closed when a marker is missing,
    struct ast_Expr is absent, or the slice runs into the CTFE paste.
    PLATFORM: SHARED — same text the host-cc typeck_gen.c compiles.
    """
    if not gen_path.is_file():
        print(f"assemble_typeck_gen: layout source missing: {gen_path}", file=sys.stderr)
        return 1
    if out_path is None:
        print("assemble_typeck_gen: --layout-out is required", file=sys.stderr)
        return 1
    text = gen_path.read_text(encoding="utf-8", errors="replace")
    start = text.find(_EXPR_LAYOUT_START)
    if start < 0:
        print(f"assemble_typeck_gen: layout start missing in {gen_path}", file=sys.stderr)
        return 1
    end = text.find(_EXPR_LAYOUT_END, start)
    if end <= start:
        print(f"assemble_typeck_gen: layout end missing in {gen_path}", file=sys.stderr)
        return 1
    body = text[start:end]
    if "struct ast_Expr {" not in body:
        print("assemble_typeck_gen: layout slice has no struct ast_Expr", file=sys.stderr)
        return 1
    if "typeck_fold_expr" in body or "TYPECK_CAP_RESIDUAL" in body:
        print("assemble_typeck_gen: layout slice ran into the CTFE paste", file=sys.stderr)
        return 1
    # The w1621 probe compiled a slice of this same span (about 56KB).
    if len(body) < 1024 or len(body) > 200000:
        print(
            f"assemble_typeck_gen: layout slice size {len(body)} out of range",
            file=sys.stderr,
        )
        return 1
    out_path.parent.mkdir(parents=True, exist_ok=True)
    note = (
        "/* Sliced from typeck_gen.c by assemble_typeck_gen_from_x.py.\n"
        " * Not a second layout authority. Do not edit.\n"
        " * PLATFORM: SHARED — same bytes the host-cc paste compiles.\n"
        " */\n"
    )
    out_path.write_text(note + body, encoding="utf-8")
    print(
        f"assemble_typeck_gen: expr layout {out_path} bytes={len(body)}",
        file=sys.stderr,
    )
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--tip", default=None, help="path to tip xlang -E output (.c)")
    ap.add_argument("--out", default=None, help="output typeck_gen.c path")
    ap.add_argument(
        "--splice-cap",
        default=None,
        help="existing typeck_gen.c: re-splice seeds Cap residual only (exit 0 same / 2 spliced)",
    )
    ap.add_argument(
        "--compiler-root",
        default=None,
        help="compiler/ root (default: parent of scripts/)",
    )
    ap.add_argument(
        "--write-expr-layout",
        default=None,
        help="slice TypeKind/Expr layout from this typeck_gen.c (no second struct)",
    )
    ap.add_argument(
        "--layout-out",
        default=None,
        help="header path for --write-expr-layout",
    )
    args = ap.parse_args(argv)

    if args.write_expr_layout:
        out = Path(args.layout_out) if args.layout_out else None
        return write_expr_layout(Path(args.write_expr_layout), out)

    script_dir = Path(__file__).resolve().parent
    root = Path(args.compiler_root) if args.compiler_root else script_dir.parent
    seeds = root / "seeds"
    if args.splice_cap:
        return splice_cap_residual(Path(args.splice_cap), seeds / "typeck_cap_residual.from_x.c")
    if not args.tip or not args.out:
        print("assemble_typeck_gen: --tip and --out are required", file=sys.stderr)
        return 1
    short_p = seeds / "typeck_short_face_alias.from_x.c"
    cap_p = seeds / "typeck_cap_residual.from_x.c"
    malias_p = seeds / "typeck_mangle_link_alias.from_x.c"
    for p in (short_p, cap_p, malias_p):
        if not p.is_file():
            print(f"assemble_typeck_gen: missing companion {p}", file=sys.stderr)
            return 1

    tip_path = Path(args.tip)
    if not tip_path.is_file() or tip_path.stat().st_size < 1024:
        print(f"assemble_typeck_gen: tip too small or missing: {tip_path}", file=sys.stderr)
        return 1

    tip_text = tip_path.read_text(encoding="utf-8", errors="replace")
    bare = _bare_export_names(tip_text)
    out_text = assemble(
        tip_text,
        short_p.read_text(encoding="utf-8", errors="replace"),
        cap_p.read_text(encoding="utf-8", errors="replace"),
        malias_p.read_text(encoding="utf-8", errors="replace"),
    )
    out_path = Path(args.out)
    out_path.write_text(out_text, encoding="utf-8")
    print(
        f"assemble_typeck_gen: OK out={out_path} bytes={out_path.stat().st_size} "
        f"bare_renamed={len(bare)}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
