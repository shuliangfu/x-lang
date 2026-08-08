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


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--tip", required=True, help="path to tip xlang -E output (.c)")
    ap.add_argument("--out", required=True, help="output typeck_gen.c path")
    ap.add_argument(
        "--compiler-root",
        default=None,
        help="compiler/ root (default: parent of scripts/)",
    )
    args = ap.parse_args(argv)

    script_dir = Path(__file__).resolve().parent
    root = Path(args.compiler_root) if args.compiler_root else script_dir.parent
    seeds = root / "seeds"
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
