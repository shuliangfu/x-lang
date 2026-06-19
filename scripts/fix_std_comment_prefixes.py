#!/usr/bin/env python3
"""
修复 fmt 折行后丢失的注释前缀：块注释续行补 '*'，文件头 '//' 续行补 '//'。
仅处理 std/**/*.sx；不改动已合法的代码行。
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

CODE_START = re.compile(
    r"^(import |extern |function |struct |enum |trait |allow\(|/\*\*|//|\*|}\s*$|{\s*$)"
)

# 明显是代码而非折行注释残片
CODE_LIKE = re.compile(
    r"^(import |extern |function |struct |enum |trait |allow\(|let |return |if |while |for )"
)


def is_block_comment_continuation(stripped: str) -> bool:
    if stripped.startswith("*") or stripped.startswith("//"):
        return False
    if CODE_LIKE.match(stripped):
        return False
    if stripped.endswith("*/"):
        return True
    # 中文说明 / 对标行 / 以字母开头的说明句
    if re.search(r"[\u4e00-\uffff]", stripped):
        return True
    if re.match(r"^[A-Za-z_][\w：、。；，（）\.\s]*[。；]?\s*$", stripped):
        return True
    return False


def is_header_comment_continuation(stripped: str, prev: str) -> bool:
    if stripped.startswith("//") or stripped.startswith("/*"):
        return False
    if CODE_LIKE.match(stripped):
        return False
    if not prev.lstrip().startswith("//"):
        return False
    if re.search(r"[\u4e00-\uffff]", stripped) or re.match(r"^[A-Z][a-zA-Z_]", stripped):
        return True
    return False


def fix_lines(lines: list[str]) -> list[str]:
    out: list[str] = []
    in_block = False
    for i, raw in enumerate(lines):
        line = raw.rstrip("\n\r")
        end = raw[len(line) :]
        stripped = line.lstrip()
        indent = line[: len(line) - len(stripped)]

        if stripped.startswith("/**"):
            in_block = "*/" not in stripped
            out.append(line + end)
            continue

        if in_block:
            if stripped.startswith("*/"):
                in_block = False
                out.append(line + end)
                continue
            if is_block_comment_continuation(stripped):
                line = indent + "* " + stripped
            if "*/" in stripped:
                in_block = False
            out.append(line + end)
            continue

        prev = out[-1] if out else ""
        if is_header_comment_continuation(stripped, prev):
            line = indent + "// " + stripped
        out.append(line + end)

    return out


def main() -> int:
    root = Path(__file__).resolve().parents[1] / "std"
    changed = 0
    for path in sorted(root.rglob("*.sx")):
        text = path.read_text(encoding="utf-8", errors="replace")
        # 去掉孤立的替换字符行（fmt 损坏）
        lines = text.splitlines(keepends=True)
        cleaned = [ln for ln in lines if ln.strip() not in ("\ufffd", "")]
        fixed = fix_lines(cleaned)
        new_text = "".join(fixed)
        if new_text != text:
            path.write_text(new_text, encoding="utf-8")
            print(f"fixed: {path.relative_to(root.parents[0])}")
            changed += 1
    print(f"done, {changed} file(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
