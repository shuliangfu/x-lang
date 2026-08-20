#!/usr/bin/env python3
"""Assemble product codegen_gen.c from tip codegen.x -E + Cap residual.

wave323 / M4 7.4.2 — cold chain authority is codegen.x, not the pinned twin.

Layers (G.7 single assemble body; do not blind-overwrite with bare tip -E):
  0. tip base = caller-provided -E output of src/codegen/codegen.x
  1. product ABI struct rename: CodegenOutBuf → codegen_CodegenOutBuf
  2. module-prefix rename: bare export faces → codegen_*
  3. X-mangle demangle: name_Type_ptr_…_reti32 → short product face
  4. Cap residual append (seeds/codegen_cap_residual.from_x.c)
  5. stdlib headers for residual companions

PLATFORM: SHARED freestanding codegen cold assemble.
Pin seeds/codegen_gen.linux.x86_64.c is archaeology / true-cold egg only.

Usage (cwd = compiler/):
  python3 scripts/assemble_codegen_gen_from_x.py \\
      --tip /tmp/codegen_tip_e.c --out codegen_gen.c
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

_KEEP_PREFIXES = (
    "codegen_",
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
    "typeck_",
    "asm_",
    "init_",
    "fs_",
    "run_x_",
)

_TOP_DEF_RE = re.compile(
    r"^(?:int32_t|void|uint8_t\s*\*|int64_t|float|double|int|size_t|ptrdiff_t|"
    r"uint32_t|uint64_t|struct\s+\w+\s*\*)\s+(\w+)\s*\(",
    re.M,
)

# X mangle type tags used in freestanding tip -E (order longest-first for strip).
_MANGLE_TAGS = (
    "CodegenOutBuf",
    "ASTArena",
    "PipelineDepCtx",
    "Module",
    "Expr",
    "Type",
    "u8",
    "i32",
    "i64",
    "size_t",
    "ptr",
    "reti32",
    "retvoid",
    "retu8",
)

_BANNER = """/* wave323 codegen M4 cold assemble from .x (7.4.2):
 *   base = tip xlang -E src/codegen/codegen.x
 *   product struct rename: CodegenOutBuf → codegen_CodegenOutBuf
 *   module-prefix rename: bare export faces → codegen_*
 *   X-mangle demangle: *_Type_ptr_*_reti32 → short product faces
 *   Cap residual append = seeds/codegen_cap_residual.from_x.c
 * G.7: product authority = codegen.x + companions; pin seed archaeology only.
 * PLATFORM: SHARED freestanding codegen cold assemble.
 */
"""


def _bare_export_names(src: str) -> list[str]:
    names: set[str] = set()
    for m in _TOP_DEF_RE.finditer(src):
        name = m.group(1)
        if any(name.startswith(p) for p in _KEEP_PREFIXES):
            continue
        names.add(name)
    return sorted(names, key=len, reverse=True)


def _apply_module_prefix(src: str, bare_names: list[str]) -> str:
    for bare in bare_names:
        pref = "codegen_" + bare
        src = re.sub(rf"\b{re.escape(bare)}\b", pref, src)
    return src


def _short_of_mangle(name: str) -> str | None:
    """Strip X freestanding type mangle suffix; return short face or None."""
    if name.endswith("_reti32") or name.endswith("_retvoid") or "_ptr_" in name:
        # Find earliest mangle tag occurrence after a meaningful base.
        best = None
        for tag in _MANGLE_TAGS:
            # _Tag_ or _Tag at end patterns
            for pat in (f"_{tag}_", f"_{tag}"):
                i = name.find(pat)
                if i > 0 and (best is None or i < best):
                    # require tag-like boundary (not mid-word)
                    best = i
        if best is not None and best >= 3:
            return name[:best]
    return None


def _demangle_product_faces(src: str) -> tuple[str, int]:
    """Rename X-mangled identifiers (defs + call sites + externs) to short faces.

    Tip freestanding -E mangles both local defs and callees
    (e.g. pipeline_module_func_param_type_ref_at_Module_ptr_i32_i32_reti32).
    Product pipeline_x / pure-ld export short faces only — demangle all word
    occurrences, not only top-level defs (wave323 pure-ld UNDEF root).
    """
    # Collect every C identifier that looks X-mangled (has type-tag suffix).
    idents = set(re.findall(r"\b([A-Za-z_][A-Za-z0-9_]{8,})\b", src))
    pairs: list[tuple[str, str]] = []
    for n in idents:
        short = _short_of_mangle(n)
        if short and short != n:
            pairs.append((n, short))
    # Longer mangled first so nested renames do not partial-clobber.
    pairs.sort(key=lambda p: len(p[0]), reverse=True)
    for mangled, short in pairs:
        src = re.sub(rf"\b{re.escape(mangled)}\b", short, src)
    return src, len(pairs)


def assemble(tip_text: str, cap: str) -> str:
    # Product pipeline / pure-ld expect codegen_CodegenOutBuf.
    body = tip_text.replace("struct CodegenOutBuf", "struct codegen_CodegenOutBuf")
    bare = _bare_export_names(body)
    body = _apply_module_prefix(body, bare)
    body, n_demangle = _demangle_product_faces(body)
    hdr = (
        "#include <stdint.h>\n"
        "#include <stddef.h>\n"
        "#include <stdlib.h>\n"
        "#include <string.h>\n"
    )
    body = (
        body
        + "\n/* wave323 Cap residual (seeds/codegen_cap_residual.from_x.c) */\n"
        + cap
    )
    # Banner note includes demangle count for operator logs.
    banner = _BANNER.replace(
        "X-mangle demangle:",
        f"X-mangle demangle ({n_demangle}):",
    )
    return banner + hdr + body


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--tip", required=True, help="path to tip xlang -E output (.c)")
    ap.add_argument("--out", required=True, help="output codegen_gen.c path")
    ap.add_argument(
        "--compiler-root",
        default=None,
        help="compiler/ root (default: parent of scripts/)",
    )
    args = ap.parse_args(argv)

    script_dir = Path(__file__).resolve().parent
    root = Path(args.compiler_root) if args.compiler_root else script_dir.parent
    seeds = root / "seeds"
    cap_p = seeds / "codegen_cap_residual.from_x.c"
    if not cap_p.is_file():
        print(f"assemble_codegen_gen: missing companion {cap_p}", file=sys.stderr)
        return 1

    tip_path = Path(args.tip)
    if not tip_path.is_file() or tip_path.stat().st_size < 1024:
        print(f"assemble_codegen_gen: tip too small or missing: {tip_path}", file=sys.stderr)
        return 1

    tip_text = tip_path.read_text(encoding="utf-8", errors="replace")
    bare = _bare_export_names(tip_text)
    out_text = assemble(
        tip_text,
        cap_p.read_text(encoding="utf-8", errors="replace"),
    )
    out_path = Path(args.out)
    out_path.write_text(out_text, encoding="utf-8")
    print(
        f"assemble_codegen_gen: OK out={out_path} bytes={out_path.stat().st_size} "
        f"bare_renamed={len(bare)}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
