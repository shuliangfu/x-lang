#!/usr/bin/env python3
"""修复 shux 迁移中的级联误替换（/shu 命中 /shux、shuffle→shuffle 等）。"""
from __future__ import annotations

import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP = {".git", "node_modules", ".cursor", "__pycache__"}

FIXES: list[tuple[str, str]] = [
    ("shuffle", "shuffle"),
    ("shuffle", "shuffle"),
    ("compiler/shux-c", "compiler/shux-c"),
    ("compiler/shux-c", "compiler/shux-c"),
    ("compiler/shux-c", "compiler/shux-c"),
    ("./compiler/shux-c", "./compiler/shux-c"),
    ("./compiler/shux-c", "./compiler/shux-c"),
    ("./compiler/shux", "./compiler/shux"),
    ("./compiler/shux", "./compiler/shux"),
    ("./compiler/shux_asm", "./compiler/shux_asm"),
    ("./compiler/shux_asm", "./compiler/shux_asm"),
    ("./compiler/shux_asm", "./compiler/shux_asm"),
    ("compiler/shux_asm", "compiler/shux_asm"),
    ("compiler/shux_asm", "compiler/shux_asm"),
    ("compiler/shux", "compiler/shux"),
    ("compiler/shux", "compiler/shux"),
    ("./shux", "./shux"),
    ("./shux", "./shux"),
    ("SHUX_LINK_SHU", "SHUX_LINK_SHUX"),
    ("SHU=", "SHUX="),
    ("${SHU}", "${SHUX}"),
    ("${SHU:", "${SHUX:"),
    ("lsp_sx.", "lsp_sx."),
    ("lsp_sx.o", "lsp_sx.o"),
    ("lsp_io_su", "lsp_io_sx"),
    ("lsp_diag_su", "lsp_diag_sx"),
    ("shux_su", "shux_sx"),
    ("main_su.", "main_sx."),
    ("parser_su.", "parser_sx."),
    ("runtime_su.", "runtime_sx."),
    ("codegen.sx", "codegen.sx"),
    ("pipeline.sx", "pipeline.sx"),
    ("parser.sx", "parser.sx"),
    ("typeck.sx", "typeck.sx"),
    ("lexer.sx", "lexer.sx"),
    ("main.sx", "main.sx"),
    ("build.sx", "build.sx"),
    ("preprocess.sx", "preprocess.sx"),
    ("emit.sx", "emit.sx"),
    ("/mod.sx", "/mod.sx"),
    ("mod.sx", "mod.sx"),
    (".sx\"", ".sx\""),
    (".sx'", ".sx'"),
    (".sx)", ".sx)"),
    (".sx ", ".sx "),
    (".sx\n", ".sx\n"),
    (".sx\t", ".sx\t"),
    (".sx`", ".sx`"),
    (".sx/", ".sx/"),
    ("shux-sx", "shux-sx"),
    ("shux_asm", "shux_asm"),
    ("shufmt", "shuxfmt"),
    ("shutest", "shuxtest"),
    ("shuxc集成", "shux集成"),
    ("OPTION_SU", "OPTION_SX"),
    ("RESULT_SU", "RESULT_SX"),
    ("run-all-su", "run-all-sx"),
    ("test_su", "test_sx"),
    ("run_su_", "run_sx_"),
]

# shux{3,} 误替换归一：compiler/shux+c → compiler/shux
RE_SHUX_RUN = re.compile(r"shux{3,}(?=-c\b|-sx\b|_asm\b|$|\s|\"|'|/|\\)")


def norm_shux_runs(text: str) -> str:
    def repl(m: re.Match[str]) -> str:
        return "shux"

    return RE_SHUX_RUN.sub(repl, text)


def should_skip(path: str) -> bool:
    if any(p in path.split(os.sep) for p in SKIP):
        return True
    if path.endswith((".vsix", ".png", ".jpg", ".o", ".a")):
        return True
    if path.endswith("tools/shux_migrate_fixup.py"):
        return True
    return False


def main() -> None:
    n = 0
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP]
        for fn in filenames:
            path = os.path.join(dirpath, fn)
            rel = os.path.relpath(path, ROOT)
            if should_skip(rel):
                continue
            try:
                with open(path, "r", encoding="utf-8") as f:
                    orig = f.read()
            except (UnicodeDecodeError, OSError):
                continue
            new = orig
            for a, b in FIXES:
                new = new.replace(a, b)
            new = norm_shux_runs(new)
            if new != orig:
                with open(path, "w", encoding="utf-8", newline="") as f:
                    f.write(new)
                n += 1
                print(rel)
    print(f"fixed {n} files")


if __name__ == "__main__":
    main()
