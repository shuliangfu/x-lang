#!/usr/bin/env python3
"""
Sweep .sx comments for outdated import syntax / mod-prefix examples.

- import std.xxx / import core.xxx  -> import("std.xxx") / import("core.xxx")
- platform.elf.* in comments          -> elf.* (binding import)
- std.io.driver.Buffer              -> Buffer (destruct import, bare type name)
- parser 旧 `import path;` 说明       -> import("path") 绑定/解构说明

Does NOT alter import("...") strings or dep 逻辑路径名（如 std.io.core）。
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

IMPORT_PATH_RE = re.compile(
    r"(?<![\"'])import\s+(std|core)\.([a-z][a-z0-9_.]*)"
)
# 旧绑定/解构：`const x = import std.foo`（无引号）
BIND_IMPORT_RE = re.compile(
    r"=\s*import\s+(std|core)\.([a-z][a-z0-9_.]*)"
)
PLATFORM_ELF_RE = re.compile(r"platform\.elf\.")
DRIVER_BUFFER_RE = re.compile(r"std\.io\.driver\.Buffer")
OLD_IMPORT_STMT_RE = re.compile(
    r"import path;（path 为 ident 或 ident\.ident）"
)

# 明确为 std.io 门面函数调用示例（非子模块路径 std.io.core / std.io.driver）
STD_IO_FN_NAMES = (
    "wait_readable",
    "handle_from_fd",
    "read_fd",
    "write_fd",
    "register_fixed_buffers",
    "register_provided_buffers",
    "provided_buffer_ptr",
    "print_i32",
    "print_u64",
    "print_str",
    "read",
    "write",
)
STD_IO_FN_RE = re.compile(
    r"std\.io\.(" + "|".join(STD_IO_FN_NAMES) + r")"
)
STD_HEAP_FN_RE = re.compile(r"std\.heap\.(alloc|free|realloc)")


def is_comment_line(line: str) -> bool:
    s = line.lstrip()
    return s.startswith("//") or s.startswith("*") or s.startswith("/**")


def patch_line(line: str) -> str:
    if not is_comment_line(line):
        return line
    out = IMPORT_PATH_RE.sub(r'import("\1.\2")', line)
    out = BIND_IMPORT_RE.sub(r'= import("\1.\2")', out)
    out = OLD_IMPORT_STMT_RE.sub(
        'import("path") 绑定 `const m = import("path");` 或解构 `const { sym } = import("path");`',
        out,
    )
    out = PLATFORM_ELF_RE.sub("elf.", out)
    out = DRIVER_BUFFER_RE.sub("Buffer", out)
    out = STD_IO_FN_RE.sub(r"io.\1", out)
    out = STD_HEAP_FN_RE.sub(r"heap.\1", out)
    return out


def patch_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    new_lines = [patch_line(ln) for ln in lines]
    new_text = "".join(new_lines)
    if new_text != text:
        path.write_text(new_text, encoding="utf-8")
        return True
    return False


def patch_markdown_line(line: str) -> str:
    """Markdown 行：替换文档中的旧 import 示例（不限于 // 注释）。"""
    out = IMPORT_PATH_RE.sub(r'import("\1.\2")', line)
    out = BIND_IMPORT_RE.sub(r'= import("\1.\2")', out)
    out = OLD_IMPORT_STMT_RE.sub(
        'import("path") 绑定 `const m = import("path");` 或解构 `const { sym } = import("path");`',
        out,
    )
    out = PLATFORM_ELF_RE.sub("elf.", out)
    out = DRIVER_BUFFER_RE.sub("Buffer", out)
    out = STD_IO_FN_RE.sub(r"io.\1", out)
    out = STD_HEAP_FN_RE.sub(r"heap.\1", out)
    return out


def main() -> int:
    n = 0
    for ext in ("*.sx", "*.md"):
        for path in sorted(ROOT.rglob(ext)):
            if ".git" in path.parts:
                continue
            if path.name == "05-函数与模块.md":
                continue
            text = path.read_text(encoding="utf-8")
            if ext == "*.md":
                lines = text.splitlines(keepends=True)
                new_lines = [patch_markdown_line(ln) for ln in lines]
            else:
                lines = text.splitlines(keepends=True)
                new_lines = [patch_line(ln) for ln in lines]
            new_text = "".join(new_lines)
            if new_text != text:
                path.write_text(new_text, encoding="utf-8")
                print(f"patched {path.relative_to(ROOT)}")
                n += 1
    print(f"done: {n} file(s) updated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
