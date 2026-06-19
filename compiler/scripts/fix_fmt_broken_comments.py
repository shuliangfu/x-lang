#!/usr/bin/env python3
"""
修复 shux fmt 折行时丢失 // 或块注释 * 前缀导致的「伪代码行」。

用法（仓库根目录）：
  python3 compiler/scripts/fix_fmt_broken_comments.py [目录...]
默认处理 compiler core std tests examples。
"""

from __future__ import annotations

import os
import re
import sys

CODE_START = re.compile(
    r"^(import|function|struct|enum|let|const|extern|return|if|while|for|match|"
    r"defer|trait|impl|#|@|pub\s)"
)


def line_has_block_end(s: str) -> bool:
    """行内是否含块注释结束符。"""
    return "*/" in s


def is_block_comment_line(stripped: str, in_block: bool) -> bool:
    """是否为块注释语法行。"""
    if stripped.startswith("/**") or stripped.startswith("*/"):
        return True
    if in_block and stripped.startswith("*"):
        return True
    return False


def looks_like_comment_text(stripped: str) -> bool:
    """启发式：该行更像被折断的注释正文，而非合法语句。"""
    if not stripped or stripped.startswith("//"):
        return False
    if CODE_START.match(stripped):
        return False
    if stripped in ("{", "}", "};", ")", ");"):
        return False
    if re.search(r"[\u4e00-\u9fff]", stripped):
        return True
    if re.search(r"[。）；，、：」』】）]$", stripped):
        return True
    if re.search(r"^(runtime|scripts/|\.\./|asm_|pipeline_|build_|mod\.sx)", stripped):
        return True
    if re.search(r"^[a-z_.][a-z0-9_./*-]*[.;)]?$", stripped, re.I):
        return True
    return False


# fmt 误把 enum/struct 成员当成块注释续行：「  * EXPR_AS」「  * field: i32;」
FALSE_STAR_ENUM = re.compile(r"^(\s+)\* ([A-Z][A-Z0-9_]+)\s*$")
FALSE_STAR_FIELD = re.compile(r"^(\s+)\* ([a-zA-Z_][a-zA-Z0-9_]*)\s*:")
FALSE_STAR_CALL = re.compile(r"^(\s+)\* ([a-zA-Z_][a-zA-Z0-9_]*)\s*\(")


def _prev_allows_strip_star(prev_stripped: str) -> bool:
    """上一行是否为 enum/struct 成员前的合法上下文（非多行块注释开头）。"""
    if prev_stripped.endswith(",") or prev_stripped.endswith(";"):
        return True
    return prev_stripped.startswith("/**") and "*/" in prev_stripped


def fix_false_star_block(lines: list[str]) -> tuple[list[str], int]:
    """「* /* … */」→「/* … */」。"""
    out: list[str] = []
    changed = 0
    for line in lines:
        stripped = line.lstrip()
        if stripped.startswith("* /*"):
            indent = line[: len(line) - len(stripped)]
            out.append(indent + stripped[2:].lstrip())
            changed += 1
            continue
        out.append(line)
    return out, changed


def fix_false_star_on_decl(lines: list[str]) -> tuple[list[str], int]:
    """去掉 enum/struct 成员前误加的「* 」。"""
    out: list[str] = []
    changed = 0
    for line in lines:
        m = (
            FALSE_STAR_ENUM.match(line)
            or FALSE_STAR_FIELD.match(line)
            or FALSE_STAR_CALL.match(line)
        )
        if m and out:
            ps = out[-1].lstrip()
            if _prev_allows_strip_star(ps):
                stripped = line.lstrip()
                indent = line[: len(line) - len(stripped)]
                out.append(indent + stripped[2:])
                changed += 1
                continue
        out.append(line)
    return out, changed


def fix_block_comment_tail(lines: list[str]) -> tuple[list[str], int]:
    """块注释末行丢失「 * 」前缀（如「cap）。 */」）时补全。"""
    out: list[str] = []
    changed = 0
    in_block = False
    for line in lines:
        stripped = line.lstrip()
        indent = line[: len(line) - len(stripped)]
        if in_block:
            if stripped.startswith("*") or stripped.startswith("*/"):
                out.append(line)
                if "*/" in stripped:
                    in_block = False
            elif "*/" in stripped and not stripped.startswith("//"):
                out.append(f"{indent}* {stripped}")
                changed += 1
                in_block = False
            else:
                out.append(line)
            continue
        if stripped.startswith("/**"):
            out.append(line)
            in_block = "*/" not in stripped
            continue
        out.append(line)
    return out, changed


def fix_lines(lines: list[str]) -> tuple[list[str], int]:
    """修复单文件行列表，返回新行与修改行数。"""
    out: list[str] = []
    in_block = False
    changed = 0
    for line in lines:
        stripped = line.lstrip()
        indent = line[: len(line) - len(stripped)]
        if in_block:
            if is_block_comment_line(stripped, True):
                out.append(line)
                if line_has_block_end(stripped):
                    in_block = False
            elif looks_like_comment_text(stripped):
                out.append(f"{indent}* {stripped}")
                changed += 1
                if line_has_block_end(stripped):
                    in_block = False
            else:
                out.append(line)
                in_block = False
            continue
        if stripped.startswith("//") and not stripped.startswith("///"):
            out.append(line)
            continue
        if stripped.startswith("/**"):
            out.append(line)
            in_block = "*/" not in stripped
            continue
        if out and looks_like_comment_text(stripped):
            prev = out[-1]
            ps = prev.lstrip()
            pi = prev[: len(prev) - len(ps)]
            if ps.startswith("//") and not ps.startswith("///"):
                out.append(f"{pi}// {stripped}")
                changed += 1
                continue
            if ps.startswith("*") or ps.startswith("/**"):
                out.append(f"{pi}* {stripped}")
                changed += 1
                continue
            if re.match(r"^———\s*$", stripped) or re.match(r"^submit\s+———", stripped):
                out.append(f"{pi}// {stripped}")
                changed += 1
                continue
            if re.search(r"———", stripped) and not stripped.startswith("function"):
                out.append(f"{pi}// {stripped}")
                changed += 1
                continue
        out.append(line)
    return out, changed


def fix_file_lines(lines: list[str]) -> tuple[list[str], int]:
    """对行列表依次应用所有修复 pass。"""
    total = 0
    lines, c = fix_false_star_block(lines)
    total += c
    lines, c = fix_false_star_on_decl(lines)
    total += c
    lines, c = fix_block_comment_tail(lines)
    total += c
    lines, c = fix_lines(lines)
    total += c
    return lines, total


def main() -> None:
    """遍历目录并写回有改动的 .sx 文件。"""
    roots = sys.argv[1:] or ["compiler", "core", "std", "tests", "examples"]
    total = 0
    files = 0
    skip_dirs = {".git", "build_asm", "node_modules", ".cursor"}
    for root in roots:
        if not os.path.isdir(root):
            continue
        for dp, dns, fns in os.walk(root):
            dns[:] = [d for d in dns if d not in skip_dirs]
            for fn in fns:
                if not fn.endswith(".sx"):
                    continue
                path = os.path.join(dp, fn)
                with open(path, encoding="utf-8", errors="replace") as f:
                    lines = f.read().splitlines()
                new, ch = fix_file_lines(lines)
                if ch:
                    with open(path, "w", encoding="utf-8", newline="\n") as f:
                        f.write("\n".join(new) + "\n")
                    print(f"fixed {path}: {ch} lines")
                    total += ch
                    files += 1
    print(f"done: {files} files, {total} lines")


if __name__ == "__main__":
    main()
