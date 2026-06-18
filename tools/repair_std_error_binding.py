#!/usr/bin/env python3
"""
repair_std_error_binding.py — std.error 的绑定 import 在 typeck 中不可用，改回解构 + 裸名调用。

  const err = import("std.error");
  err.error_ok()
  →
  const { error_ok } = import("std.error");
  error_ok()
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

BIND = re.compile(r'^(\s*)const\s+(\w+)\s*=\s*import\s*\(\s*"std\.error"\s*\)\s*;\s*$')
USE = re.compile(r"\b(\w+)\.([A-Za-z_][A-Za-z0-9_]*)\b")


def repair_file(path: Path, write: bool) -> bool:
    text = path.read_text(encoding="utf-8")
    bind_name: str | None = None
    for line in text.splitlines():
        m = BIND.match(line)
        if m:
            bind_name = m.group(2)
            break
    if not bind_name:
        return False

    syms: set[str] = set()
    for m in USE.finditer(text):
        if m.group(1) == bind_name:
            syms.add(m.group(2))
    if not syms:
        # 无使用则保留绑定或删行
        return False

    new_text = text
    for sym in sorted(syms, key=len, reverse=True):
        new_text = re.sub(rf"\b{re.escape(bind_name)}\.{re.escape(sym)}\b", sym, new_text)

    new_text = BIND.sub(
        lambda m: f'{m.group(1)}const {{ {", ".join(sorted(syms))} }} = import("std.error");\n',
        new_text,
        count=1,
    )
    if new_text == text:
        return False
    if write:
        path.write_text(new_text, encoding="utf-8")
    print(f"{path}: std.error select {sorted(syms)}")
    return True


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="*", default=[str(ROOT)])
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()
    n = 0
    for p in args.paths:
        path = Path(p)
        files = sorted(path.rglob("*.su")) if path.is_dir() else [path]
        for f in files:
            if ".git" in f.parts:
                continue
            if repair_file(f, args.write):
                n += 1
    print(f"done: {n} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
