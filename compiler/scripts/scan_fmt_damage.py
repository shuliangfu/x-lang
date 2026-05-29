#!/usr/bin/env python3
"""
扫描 shu fmt 折行造成的损坏：
  A) // 续行缺少 //
  B) 块注释续行缺少 *
  C) 代码行被拦腰切断（行首 refix[/fix[/ 等）
  D) 行首 * 后紧跟标识符但非块注释（*u8 / *Driver 等需结合上一行判断）

用法（仓库根）：python3 compiler/scripts/scan_fmt_damage.py
退出码 0=无问题，1=有问题（并打印列表）。
"""

from __future__ import annotations

import os
import re
import sys

SKIP_DIRS = {".git", "build_asm", "node_modules", ".cursor", "build"}
CODE_START = re.compile(
    r"^(import|function|struct|enum|let|const|extern|return|if|while|for|match|"
    r"defer|trait|impl|#|@|pub\s|}\s*$|\{\s*$)"
)
PAT_PREV_SLASH = re.compile(r"^\s*//(?![/!])")
# fmt 在 prefix[n]= 等处硬切后行首丢失 pr 前缀（唯一可靠信号）
SPLIT_IDENT = re.compile(r"^(refix|fix)\[")
# enum/struct 成员被误写成块注释续行
FALSE_STAR_ENUM = re.compile(r"^\* ([A-Z][A-Z0-9_]+)\s*$")
FALSE_STAR_FIELD = re.compile(r"^\* ([a-zA-Z_][a-zA-Z0-9_]*)\s*:")
FALSE_STAR_CALL = re.compile(r"^\* ([a-zA-Z_][a-zA-Z0-9_]*)\s*\(")
# 误将「/*」行写成「* /*」（如 codegen CodegenOutBuf 前）
FALSE_STAR_BLOCK = re.compile(r"^\* /\*")


def broken_slash_continuation(lines: list[str]) -> list[tuple[int, str]]:
    out: list[tuple[int, str]] = []
    for i in range(1, len(lines)):
        prev, cur = lines[i - 1], lines[i]
        if not cur.strip():
            continue
        if not PAT_PREV_SLASH.match(prev):
            continue
        s = cur.lstrip()
        if s.startswith(("//", "/*", "#")):
            continue
        if CODE_START.match(s):
            continue
        if re.search(r"[\u4e00-\u9fff]", s) or re.search(r"[。）；，、：」』】）]$", s):
            out.append((i + 1, s[:90]))
        elif re.match(r"^[a-z_.][a-z0-9_./*-]*[.;)]?$", s, re.I):
            out.append((i + 1, s[:90]))
    return out


def false_star_block_damage(lines: list[str]) -> list[tuple[int, str]]:
    out: list[tuple[int, str]] = []
    for i, line in enumerate(lines, 1):
        if FALSE_STAR_BLOCK.match(line.lstrip()):
            out.append((i, line.strip()[:90]))
    return out


def false_star_decl_damage(lines: list[str]) -> list[tuple[int, str]]:
    out: list[tuple[int, str]] = []
    for i, line in enumerate(lines, 1):
        s = line.lstrip()
        if not (
            FALSE_STAR_ENUM.match(s)
            or FALSE_STAR_FIELD.match(s)
            or FALSE_STAR_CALL.match(s)
        ):
            continue
        if i < 2:
            continue
        ps = lines[i - 2].lstrip()
        if ps.endswith(",") or ps.endswith(";") or (ps.startswith("/**") and "*/" in ps):
            out.append((i, s[:90]))
    return out


def split_code_line_damage(lines: list[str]) -> list[tuple[int, str]]:
    out: list[tuple[int, str]] = []
    for i, line in enumerate(lines, 1):
        s = line.lstrip()
        if SPLIT_IDENT.match(s):
            out.append((i, s[:90]))
    return out


def scan_file(path: str) -> dict[str, list[tuple[int, str]]]:
    lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    r: dict[str, list[tuple[int, str]]] = {}
    a = broken_slash_continuation(lines)
    if a:
        r["slash"] = a
    b = split_code_line_damage(lines)
    if b:
        r["split"] = b
    c = false_star_decl_damage(lines)
    if c:
        r["star_decl"] = c
    d = false_star_block_damage(lines)
    if d:
        r["star_block"] = d
    return r


def main() -> None:
    roots = sys.argv[1:] if len(sys.argv) > 1 else ["."]
    total = 0
    files = 0
    for root in roots:
        if os.path.isfile(root) and root.endswith(".su"):
            paths = [root]
        elif os.path.isdir(root):
            paths = []
            for dp, dns, fns in os.walk(root):
                dns[:] = [d for d in dns if d not in SKIP_DIRS]
                for fn in fns:
                    if fn.endswith(".su"):
                        paths.append(os.path.join(dp, fn))
        else:
            continue
        for path in sorted(paths):
            issues = scan_file(path)
            if not issues:
                continue
            files += 1
            print(path)
            for kind, items in issues.items():
                for ln, t in items:
                    print(f"  [{kind}] L{ln}: {t}")
                    total += 1
    if total:
        print(f"\nFAIL: {files} files, {total} issue(s)")
        sys.exit(1)
    print("OK: no fmt wrap damage detected")


if __name__ == "__main__":
    main()
