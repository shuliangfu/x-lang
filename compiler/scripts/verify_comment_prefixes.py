#!/usr/bin/env python3
"""
检查 .sx 中「上一行是 // 注释、下一行却无 // 且像中文续行」的折断注释。
退出码 0 表示未发现；否则打印路径并返回 1。

用法（仓库根）：
  python3 compiler/scripts/verify_comment_prefixes.py [目录...]
"""

from __future__ import annotations

import os
import re
import sys

PAT_PREV = re.compile(r"^\s*//(?![/!])")
CODE_START = re.compile(
    r"^(import|function|struct|enum|let|const|extern|return|if|while|for|match|"
    r"defer|trait|impl|#|@|pub\s)"
)


def is_broken_continuation(line: str) -> bool:
    """当前行是否像缺少 // 的注释续行。"""
    s = line.lstrip()
    if not s or s.startswith("//") or s.startswith("/*") or s.startswith("#"):
        return False
    if CODE_START.match(s):
        return False
    # fmt 折断的「// … submit ———」续行（如 std/io/mod.sx）
    if re.search(r"———", s) and not s.startswith("*"):
        return True
    if re.match(r"^(submit|timeout_ms|毫秒)\b", s, re.I):
        return True
    if re.search(r"[\u4e00-\u9fff]", s):
        return True
    if re.search(r"[。）；，、：」』】）]$", s):
        return True
    if re.match(r"^[a-z_.][a-z0-9_./*-]*[.;)]?$", s, re.I):
        return True
    return False


def scan_file(path: str) -> list[tuple[int, str]]:
    """返回 (行号, 行内容) 列表。"""
    hits: list[tuple[int, str]] = []
    lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    for i in range(1, len(lines)):
        if PAT_PREV.match(lines[i - 1]) and is_broken_continuation(lines[i]):
            hits.append((i + 1, lines[i].strip()[:100]))
    return hits


def main() -> None:
    roots = sys.argv[1:] if len(sys.argv) > 1 else ["compiler", "core", "std", "tests", "examples", "build.sx"]
    skip = {".git", "build_asm", "node_modules", ".cursor", "build"}
    total = 0
    for root in roots:
        if os.path.isfile(root) and root.endswith(".sx"):
            paths = [root]
        elif os.path.isdir(root):
            paths = []
            for dp, dns, fns in os.walk(root):
                dns[:] = [d for d in dns if d not in skip]
                for fn in fns:
                    if fn.endswith(".sx"):
                        paths.append(os.path.join(dp, fn))
        else:
            continue
        for path in sorted(paths):
            h = scan_file(path)
            if h:
                print(f"{path}:")
                for ln, t in h:
                    print(f"  L{ln}: {t}")
                total += len(h)
    if total:
        print(f"\nFAIL: {total} broken // continuation line(s)")
        sys.exit(1)
    print("OK: no broken // comment continuations found")


if __name__ == "__main__":
    main()
