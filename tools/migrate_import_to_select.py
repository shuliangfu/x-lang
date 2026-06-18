#!/usr/bin/env python3
"""
migrate_import_to_select.py — 将 `import path;` 转为方式 2（绑定）或方式 3（解构）

规则（项目默认）：
  - 用到模块内 **大部分 / 全部** 符号，且 **无 struct/enum 类型注解** → 方式 2：`const name = import path;` + 函数调用加前缀
  - 只用到 **部分** 符号，或文件内出现该模块的 **类型名** → 方式 3：`const { a, b } = import path;`

用法：
  python3 tools/migrate_import_to_select.py --write examples/cookbook/
  python3 tools/migrate_import_to_select.py --check std/io/mod.su
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

IMPORT_BINDING_LINE = re.compile(
    r'^const\s+(\w+)\s*=\s*import\s*\(\s*"([^"]+)"\s*\)\s*;\s*$'
)
STRUCT_RE = re.compile(r"(?:^|\s)struct\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{")
FUNC_RE = re.compile(r"^function\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
EXTERN_FUNC_RE = re.compile(r"^extern\s+function\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
ENUM_RE = re.compile(r"(?:^|\s)enum\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{")

# 方式 2：used/export 比例 ≥ 阈值视为「全量」
FULL_MODULE_RATIO = 0.75


def resolve_module_file(import_path: str, root: Path) -> Path | None:
    """按 STBL-004 规则解析 import 路径到 .su 文件。"""
    parts = import_path.split(".")
    candidates: list[Path] = [
        root / "/".join(parts) / "mod.su",
        root / f"{'/'.join(parts)}.su",
    ]
    if len(parts) == 1:
        candidates.append(root / parts[0] / f"{parts[0]}.su")
    for c in candidates:
        if c.is_file():
            return c
    return None


def module_export_symbols(mod_file: Path) -> tuple[set[str], set[str], set[str]]:
    """返回 (全部符号, struct 名, enum 名)。"""
    text = mod_file.read_text(encoding="utf-8")
    funcs = set(FUNC_RE.findall(text)) | set(EXTERN_FUNC_RE.findall(text))
    structs = {m.group(1) for m in STRUCT_RE.finditer(text)}
    enums = {m.group(1) for m in ENUM_RE.finditer(text)}
    all_syms = funcs | structs | enums
    return all_syms, structs, enums


def strip_comments_and_strings(text: str) -> str:
    """去掉注释与字符串字面量。"""
    out: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        if text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
            continue
        if text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = n if end < 0 else end + 2
            continue
        if text[i] == '"':
            i += 1
            while i < n and text[i] != '"':
                if text[i] == "\\" and i + 1 < n:
                    i += 2
                else:
                    i += 1
            i += 1
            continue
        out.append(text[i])
        i += 1
    return "".join(out)


def file_identifiers(text: str) -> set[str]:
    """提取文件中出现的标识符（粗略）。"""
    t = strip_comments_and_strings(text)
    ids = set(re.findall(r"\b([A-Za-z_][A-Za-z0-9_]*)\b", t))
    return ids - KEYWORDS


def binding_name(import_path: str) -> str:
    """绑定名：路径末段；async 关键字避冲突。"""
    seg = import_path.split(".")[-1]
    if seg == "async":
        return "async_mod"
    if seg == "error":
        return "err"
    return seg


def uses_type_from_module(text: str, type_names: set[str]) -> set[str]:
    """检测文件中作为类型使用的符号（: T、T {、T,、T ) 等）。"""
    if not type_names:
        return set()
    t = strip_comments_and_strings(text)
    used: set[str] = set()
    for name in type_names:
        if re.search(rf":\s*{re.escape(name)}\b", t):
            used.add(name)
        if re.search(rf"\b{re.escape(name)}\s*\{{", t):
            used.add(name)
        if re.search(rf"\b{re.escape(name)}\s*,", t):
            used.add(name)
        if re.search(rf"\(\s*{re.escape(name)}\s*\)", t):
            used.add(name)
    return used


def prefix_function_calls(text: str, bind: str, func_names: set[str]) -> str:
    """仅为绑定 import 的函数调用加 `bind.` 前缀（不改类型名）。"""
    for sym in sorted(func_names, key=len, reverse=True):
        text = re.sub(
            rf"(?<![A-Za-z0-9_.]){re.escape(sym)}\s*(?=\()",
            f"{bind}.{sym}",
            text,
        )
    return text


def choose_import_style(
    used: set[str],
    all_syms: set[str],
    structs: set[str],
    enums: set[str],
    type_used: set[str],
) -> str:
    """
    返回 'binding' 或 'select'。
    全量且无跨模块类型 → binding；否则 select。
    """
    if not used:
        return "binding"
    if type_used:
        return "select"
    export_n = max(len(all_syms), 1)
    ratio = len(used) / export_n
    if ratio >= FULL_MODULE_RATIO and len(all_syms - used) <= max(3, export_n * 0.1):
        return "binding"
    return "select"


def migrate_text(text: str, root: Path) -> tuple[str, bool, list[str]]:
    """迁移整文件 import；返回 (新文本, 是否变化, 日志)。"""
    lines = text.splitlines(keepends=True)
    logs: list[str] = []
    plan: list[tuple[int, str, str, str, list[str]]] = []
    # plan 项：(行号, import_path, style, bind, select_syms)

    ids = file_identifiers(text)

    for i, line in enumerate(lines):
        m = IMPORT_BINDING_LINE.match(line.rstrip("\n\r"))
        if not m:
            continue
        bind = m.group(1)
        import_path = m.group(2)
        mod_file = resolve_module_file(import_path, root)
        if mod_file is None:
            logs.append(f"skip: module not found {import_path}")
            continue
        all_syms, structs, enums = module_export_symbols(mod_file)
        used = ids & all_syms
        type_names = structs | enums
        type_used = uses_type_from_module(text, type_names) & used
        bind = binding_name(import_path)
        style = choose_import_style(used, all_syms, structs, enums, type_used)

        if style == "binding":
            if bind == m.group(1):
                continue  # 已是正确绑定名
            plan.append((i, import_path, "binding", bind, []))
            logs.append(f"{import_path}: binding as {bind} ({len(used)}/{len(all_syms)} syms)")
        else:
            picked = sorted(used) if used else sorted(all_syms)[:1]
            plan.append((i, import_path, "select", bind, picked))
            logs.append(f"{import_path}: select {len(picked)} syms ({len(used)}/{len(all_syms)})")

    if not plan:
        return text, False, logs

    out = text
    for i, import_path, style, bind, picked in plan:
        if style != "binding":
            continue
        mod_file = resolve_module_file(import_path, root)
        if mod_file is None:
            continue
        all_syms, structs, enums = module_export_symbols(mod_file)
        type_names = structs | enums
        used = ids & all_syms
        funcs = (used - type_names) & all_syms
        out = prefix_function_calls(out, bind, funcs)

    out_lines = out.splitlines(keepends=True)
    for i, import_path, style, bind, picked in reversed(plan):
        if style == "binding":
            out_lines[i] = f'const {bind} = import("{import_path}");\n'
        else:
            out_lines[i] = f'const {{ {", ".join(picked)} }} = import("{import_path}");\n'

    return "".join(out_lines), True, logs


def process_file(path: Path, root: Path, write: bool) -> int:
    """处理单个文件。"""
    text = path.read_text(encoding="utf-8")
    new_text, changed, logs = migrate_text(text, root)
    for msg in logs:
        print(f"{path}: {msg}")
    if not changed:
        return 0
    if write:
        path.write_text(new_text, encoding="utf-8")
        print(f"migrated {path}")
    else:
        print(f"--- {path} ---\n{new_text}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description="Smart import migration (binding vs select)")
    ap.add_argument("paths", nargs="+")
    ap.add_argument("--root", default=str(ROOT))
    ap.add_argument("--write", action="store_true")
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    root = Path(args.root)
    write = args.write and not args.check

    files: list[Path] = []
    for p in args.paths:
        path = Path(p)
        if path.is_dir():
            files.extend(sorted(path.rglob("*.su")))
        elif path.is_file():
            files.append(path)

    for f in files:
        process_file(f, root, write)
    return 0


if __name__ == "__main__":
    sys.exit(main())
