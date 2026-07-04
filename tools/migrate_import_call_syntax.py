#!/usr/bin/env python3
"""
migrate_import_call_syntax.py — 将旧 import 语法迁移为 import("path") 调用形式

  const x = import std.foo;     → const x = import("std.foo");
  const { a } = import std.foo; → const { a } = import("std.foo");
  import std.foo;               → const foo = import("std.foo");  （末段作绑定名）

已含 import("...") 的行跳过。
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

RE_BINDING = re.compile(
    r"^(\s*const\s+(\w+)\s*=\s*)import\s+([A-Za-z_][A-Za-z0-9_.]*)\s*;\s*$"
)
RE_SELECT = re.compile(
    r"^(\s*const\s+\{[^}]+\}\s*=\s*)import\s+([A-Za-z_][A-Za-z0-9_.]*)\s*;\s*$"
)
RE_WHOLE = re.compile(
    r"^(\s*)import\s+([A-Za-z_][A-Za-z0-9_.]*)\s*;\s*$"
)
RE_WHOLE_NO_SEMI = re.compile(
    r"^(\s*)import\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$"
)


def binding_name_from_path(path: str) -> str:
    """整模块 import 转绑定名。"""
    seg = path.split(".")[-1]
    if seg == "async":
        return "async_mod"
    if seg == "error":
        return "err"
    return seg


def migrate_line(line: str) -> tuple[str, bool]:
    """迁移单行；返回 (新行, 是否变化)。"""
    if 'import("' in line or "import('" in line:
        return line, False
    m = RE_BINDING.match(line.rstrip("\n\r"))
    if m:
        return f"{m.group(1)}import(\"{m.group(3)}\");\n", True
    m = RE_SELECT.match(line.rstrip("\n\r"))
    if m:
        return f"{m.group(1)}import(\"{m.group(2)}\");\n", True
    m = RE_WHOLE.match(line.rstrip("\n\r"))
    if m:
        bind = binding_name_from_path(m.group(2))
        return f"{m.group(1)}const {bind} = import(\"{m.group(2)}\");\n", True
    m = RE_WHOLE_NO_SEMI.match(line.rstrip("\n\r"))
    if m:
        bind = binding_name_from_path(m.group(2))
        return f"{m.group(1)}const {bind} = import(\"{m.group(2)}\");\n", True
    return line, False


def migrate_text(text: str) -> tuple[str, int]:
    """迁移整文件文本；返回 (新文本, 变化行数)。"""
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    n = 0
    for line in lines:
        new_line, changed = migrate_line(line)
        out.append(new_line)
        if changed:
            n += 1
    return "".join(out), n


def process_file(path: Path, write: bool) -> int:
    """处理单个 .x 文件。"""
    text = path.read_text(encoding="utf-8")
    new_text, n = migrate_text(text)
    if n == 0:
        return 0
    if write:
        path.write_text(new_text, encoding="utf-8")
        print(f"migrated {path} ({n} lines)")
    else:
        print(f"would migrate {path} ({n} lines)")
    return n


def main() -> int:
    ap = argparse.ArgumentParser(description="Migrate import to import(\"path\") syntax")
    ap.add_argument("paths", nargs="*", default=[str(ROOT)])
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()
    total = 0
    for p in args.paths:
        path = Path(p)
        if path.is_dir():
            for f in sorted(path.rglob("*.x")):
                total += process_file(f, args.write)
        elif path.is_file() and path.suffix == ".x":
            total += process_file(path, args.write)
    print(f"done: {total} lines changed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
