#!/usr/bin/env python3
"""
sync_import_select.py — 同步解构 import 列表，补全文件中实际用到的导出符号（含 extern）。

将不完整的 `const { a } = import("mod")` 扩展为含全部 used 符号；
将裸调用 + `const bind = import("mod")` 转为解构（无 bind. 前缀时）。
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

FUNC_RE = re.compile(r"^function\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
EXTERN_FUNC_RE = re.compile(r"^extern\s+function\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
STRUCT_RE = re.compile(r"(?:^|\s)struct\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{")
BINDING_RE = re.compile(
    r"^(\s*)const\s+(\w+)\s*=\s*import\s*\(\s*\"([^\"]+)\"\s*\)\s*;\s*$"
)
SELECT_RE = re.compile(
    r"^(\s*)const\s+\{([^}]+)\}\s*=\s*import\s*\(\s*\"([^\"]+)\"\s*\)\s*;\s*$"
)


def resolve_module_file(import_path: str, su_file: Path, root: Path) -> Path | None:
    """解析逻辑模块名或相对 .x 路径到文件。"""
    if import_path.endswith(".x"):
        for c in [su_file.parent / import_path, root / import_path.lstrip("/")]:
            if c.is_file():
                return c
        return None
    parts = import_path.split(".")
    for c in [root / "/".join(parts) / "mod.x", root / f"{'/'.join(parts)}.x"]:
        if c.is_file():
            return c
    if len(parts) == 1:
        local = su_file.parent / f"{parts[0]}.x"
        if local.is_file():
            return local
    return None


def module_exports(mod_file: Path) -> set[str]:
    text = mod_file.read_text(encoding="utf-8")
    funcs = set(FUNC_RE.findall(text)) | set(EXTERN_FUNC_RE.findall(text))
    structs = {m.group(1) for m in STRUCT_RE.finditer(text)}
    return funcs | structs


def strip_noise(text: str) -> str:
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
                i += 2 if text[i] == "\\" else 1
            i += 1
            continue
        out.append(text[i])
        i += 1
    return "".join(out)


def symbols_used_from_module(text: str, bind: str | None, exports: set[str]) -> set[str]:
    """检测文件中对某模块导出符号的使用（裸名或 bind. 前缀）。"""
    t = strip_noise(text)
    used: set[str] = set()
    for sym in exports:
        if bind and re.search(rf"(?<![A-Za-z0-9_.]){re.escape(bind)}\.{re.escape(sym)}\b", t):
            used.add(sym)
        if re.search(rf"(?<![A-Za-z0-9_.]){re.escape(sym)}\s*(?=\()", t):
            used.add(sym)
        if re.search(rf":\s*{re.escape(sym)}\b", t):
            used.add(sym)
        if re.search(rf"\b{re.escape(sym)}\s*\{{", t):
            used.add(sym)
    return used


def parse_select_names(inner: str) -> set[str]:
    return {x.strip() for x in inner.split(",") if x.strip()}


def sync_file(path: Path, root: Path, write: bool) -> bool:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    changed = False
    imports: list[tuple[int, str, str, set[str] | None]] = []
    # (line_idx, indent, path, current_names or None for binding)

    for i, line in enumerate(lines):
        m = SELECT_RE.match(line.rstrip("\n\r"))
        if m:
            imports.append((i, m.group(1), m.group(3), parse_select_names(m.group(2))))
            continue
        m = BINDING_RE.match(line.rstrip("\n\r"))
        if m:
            imports.append((i, m.group(1), m.group(3), None))

    if not imports:
        return False

    for i, indent, import_path, current in imports:
        mod_file = resolve_module_file(import_path, path, root)
        if not mod_file:
            continue
        exports = module_exports(mod_file)
        bind = None
        if current is None:
            m = BINDING_RE.match(lines[i].rstrip("\n\r"))
            bind = m.group(2) if m else None
        used = symbols_used_from_module(text, bind, exports)
        if not used:
            continue
        if current is not None and used <= current:
            continue
        new_line = f'{indent}const {{ {", ".join(sorted(used))} }} = import("{import_path}");\n'
        if lines[i] != new_line:
            lines[i] = new_line
            changed = True
            print(f"{path}:{import_path} -> {len(used)} syms")

    if changed and write:
        path.write_text("".join(lines), encoding="utf-8")
    return changed


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="*", default=[str(ROOT)])
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()
    n = 0
    for p in args.paths:
        path = Path(p)
        files = sorted(path.rglob("*.x")) if path.is_dir() else [path]
        for f in files:
            if sync_file(f, ROOT, args.write):
                n += 1
    print(f"synced {n} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
