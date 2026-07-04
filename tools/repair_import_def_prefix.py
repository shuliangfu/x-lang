#!/usr/bin/env python3
"""
repair_import_def_prefix.py — 修复 migrate_select_to_binding 误加在 function 定义上的 bind. 前缀。

  function heap.alloc_u8(...)  → function alloc_u8(...)
  extern function async_mod.foo(...) → extern function foo(...)
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

DEF_FIX = re.compile(
    r"^(?P<indent>\s*)(?P<kind>extern\s+)?function\s+(?P<bind>[A-Za-z_][A-Za-z0-9_]*)\.(?P<sym>[A-Za-z_][A-Za-z0-9_]*)\s*(?=\()",
    re.M,
)


def repair_text(text: str) -> tuple[str, int]:
    """修复 function 定义行上的 mod.sym 前缀；返回 (新文本, 修复次数)。"""
    n = 0

    def repl(m: re.Match[str]) -> str:
        nonlocal n
        n += 1
        kind = m.group("kind") or ""
        return f"{m.group('indent')}{kind}function {m.group('sym')}"

    new_text = DEF_FIX.sub(repl, text)
    return new_text, n


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="*", default=[str(ROOT)])
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()

    total = 0
    files = 0
    for p in args.paths:
        path = Path(p)
        todo = sorted(path.rglob("*.x")) if path.is_dir() else [path]
        for f in todo:
            if ".git" in f.parts:
                continue
            text = f.read_text(encoding="utf-8")
            new_text, n = repair_text(text)
            if n == 0:
                continue
            total += n
            files += 1
            print(f"{f}: fixed {n} definition(s)")
            if args.write:
                f.write_text(new_text, encoding="utf-8")
    print(f"done: {files} files, {total} fixes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
