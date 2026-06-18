#!/usr/bin/env python3
"""
fix_bare_import_calls.py — 修复整模块 import 迁为绑定后仍裸调用的问题

将 `const foo = import("mod");` + 裸 `bar()` 改为 `const { bar } = import("mod");`
或将裸调用改为 `foo.bar()`（含类型时不加前缀，改解构）。
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

KEYWORDS = {
    "function", "let", "const", "if", "else", "while", "return", "import", "struct",
    "enum", "true", "false", "break", "continue", "for", "loop", "match", "defer",
    "extern", "allow", "as", "sizeof", "alignof", "unsafe", "async", "await", "spawn",
    "run", "bool", "i32", "i64", "u32", "u64", "u8", "i8", "f32", "f64", "usize",
    "isize", "void", "padding", "main",
}

BINDING_IMPORT = re.compile(
    r'^(\s*)const\s+(\w+)\s*=\s*import\s*\(\s*"([^"]+)"\s*\)\s*;\s*$'
)
FUNC_RE = re.compile(r"^function\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
STRUCT_RE = re.compile(r"(?:^|\s)struct\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{")


def resolve_module_file(import_path: str, root: Path) -> Path | None:
    parts = import_path.split(".")
    for c in [root / "/".join(parts) / "mod.su", root / f"{'/'.join(parts)}.su"]:
        if c.is_file():
            return c
    if len(parts) == 1:
        for c in [root / parts[0] / "mod.su", root / f"{parts[0]}/{parts[0]}.su"]:
            if c.is_file():
                return c
        # 同目录单文件（tests/multi-file/foo.su）
        return None
    return None


def resolve_module_near(file_path: Path, import_path: str, root: Path) -> Path | None:
    """解析模块文件：逻辑路径 + 入口同目录。"""
    mf = resolve_module_file(import_path, root)
    if mf:
        return mf
    if "/" not in import_path and "." not in import_path:
        local = file_path.parent / f"{import_path}.su"
        if local.is_file():
            return local
    if import_path.endswith(".su"):
        local = file_path.parent / import_path
        if local.is_file():
            return local
        local = (root / import_path).resolve()
        if local.is_file():
            return local
    return None


def module_exports(mod_file: Path) -> tuple[set[str], set[str]]:
    text = mod_file.read_text(encoding="utf-8")
    funcs = set(FUNC_RE.findall(text))
    structs = {m.group(1) for m in STRUCT_RE.finditer(text)}
    return funcs, structs


def strip_comments_strings(text: str) -> str:
    out: list[str] = []
    i, n = 0, len(text)
    while i < n:
        if text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
            continue
        if text.startswith("/*", i):
            j = text.find("*/", i + 2)
            i = n if j < 0 else j + 2
            continue
        if text[i] == '"':
            i += 1
            while i < n and text[i] != '"':
                if text[i] == "\\":
                    i += 2
                else:
                    i += 1
            i += 1
            continue
        out.append(text[i])
        i += 1
    return "".join(out)


def bare_and_prefixed_usage(text: str, bind: str, exports: set[str]) -> tuple[set[str], set[str]]:
    """返回 (裸调用/使用的符号, bind. 前缀使用的符号)。"""
    t = strip_comments_strings(text)
    bare: set[str] = set()
    prefixed: set[str] = set()
    for sym in exports:
        if re.search(rf"(?<![A-Za-z0-9_.]){re.escape(bind)}\.{re.escape(sym)}\b", t):
            prefixed.add(sym)
        if re.search(rf"(?<![A-Za-z0-9_.]){re.escape(sym)}\s*(?=\()", t):
            bare.add(sym)
        if re.search(rf":\s*{re.escape(sym)}\b", t):
            bare.add(sym)
        if re.search(rf"\b{re.escape(sym)}\s*\{{", t):
            bare.add(sym)
    return bare, prefixed


def fix_file(path: Path, root: Path, write: bool) -> int:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    changed = False
    for i, line in enumerate(lines):
        m = BINDING_IMPORT.match(line.rstrip("\n\r"))
        if not m:
            continue
        bind, import_path = m.group(2), m.group(3)
        mod_file = resolve_module_near(path, import_path, root)
        if not mod_file:
            continue
        funcs, structs = module_exports(mod_file)
        exports = funcs | structs
        bare, prefixed = bare_and_prefixed_usage(text, bind, exports)
        bare_funcs = bare & funcs
        bare_types = bare & structs
        if not bare_funcs and not bare_types:
            continue
        if prefixed:
            continue  # 已混用前缀，手动处理
        if bare_types:
            picked = sorted(bare)
            lines[i] = f'{m.group(1)}const {{ {", ".join(picked)} }} = import("{import_path}");\n'
        else:
            picked = sorted(bare_funcs)
            lines[i] = f'{m.group(1)}const {{ {", ".join(picked)} }} = import("{import_path}");\n'
        changed = True
        print(f"{path}: {import_path} -> select {picked}")
    if changed and write:
        path.write_text("".join(lines), encoding="utf-8")
    return 1 if changed else 0


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
            n += fix_file(f, ROOT, args.write)
    print(f"fixed {n} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
