#!/usr/bin/env python3
"""
Audit import syntax migration completeness in .sx source (non-comment code lines).

Exit 0 if clean; prints violations and exits 1 otherwise.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# 旧语句 import path;
OLD_STMT = re.compile(r"^\s*import\s+[^{\"']")
# 无引号绑定：const x = import std.foo
OLD_BIND = re.compile(r"=\s*import\s+(std|core)\.")
# 源码中的 mod 前缀调用（非 import("...") 字符串内）
PLATFORM_ELF_CALL = re.compile(r"(?<![\"'])platform\.elf\.")
STD_IO_HEAP_CALL = re.compile(
    r"(?<![\"'/\.])std\.(io|heap)\.(?!core(?:\.|$)|driver(?:\.|$))[a-z_][a-z0-9_]*"
)
# mod.Type 限定（常见错误）
MOD_TYPE = re.compile(
    r"\b(driver|io|heap|elf|process|net|fs|async|token|fmt|codec)\.[A-Z][a-zA-Z0-9_]*"
)


def strip_line_comment(s: str) -> str:
    if "//" in s:
        return s[: s.index("//")]
    return s


def is_code_line(line: str) -> bool:
    s = line.strip()
    if not s:
        return False
    if s.startswith("//"):
        return False
    if s.startswith("*") or s.startswith("/**") or s.startswith("*/"):
        return False
    if s.startswith("/*") or s.endswith("*/"):
        return False
    return True


def audit_file(path: Path) -> list[str]:
    issues: list[str] = []
    for i, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not is_code_line(raw):
            continue
        line = strip_line_comment(raw)
        if OLD_STMT.search(line):
            issues.append(f"{path}:{i}: old import statement")
        if OLD_BIND.search(line):
            issues.append(f"{path}:{i}: unquoted bind import")
        if PLATFORM_ELF_CALL.search(line):
            issues.append(f"{path}:{i}: platform.elf.* call")
        if STD_IO_HEAP_CALL.search(line):
            issues.append(f"{path}:{i}: std.io/heap.* call (use binding)")
        m = MOD_TYPE.search(line)
        if m and "不支持" not in raw:
            issues.append(f"{path}:{i}: mod.Type pattern {m.group(0)}")
    return issues


def main() -> int:
    all_issues: list[str] = []
    for path in sorted(ROOT.rglob("*.sx")):
        if ".git" in path.parts:
            continue
        all_issues.extend(audit_file(path))
    if all_issues:
        print("import migration audit FAIL:")
        for x in all_issues:
            print(f"  {x}")
        return 1
    print(f"import migration audit OK ({len(list(ROOT.rglob('*.sx')))} .sx files scanned)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
