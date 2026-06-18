#!/usr/bin/env python3
"""
migrate_select_to_binding.py — 将解构 import 统一改为绑定 import

  const { a, b } = import("std.heap");
  → const heap = import("std.heap");
  → heap.a(...) / heap.b(...)

类型名（struct/enum）保持裸名（: Buffer、Buffer {），与编译器约定一致；
仅对模块导出的函数调用加 bind. 前缀。

用法：
  python3 tools/migrate_select_to_binding.py --write std/ core/ examples/ tests/ compiler/
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# 复用 migrate_import_to_select 的模块解析
import importlib.util

_spec = importlib.util.spec_from_file_location(
    "migrate_import_to_select", ROOT / "tools" / "migrate_import_to_select.py"
)
_m = importlib.util.module_from_spec(_spec)
assert _spec.loader is not None
_spec.loader.exec_module(_m)

binding_name = _m.binding_name
strip_comments_and_strings = _m.strip_comments_and_strings
module_export_symbols = _m.module_export_symbols
resolve_module_file = _m.resolve_module_file
IMPORT_BINDING_LINE = _m.IMPORT_BINDING_LINE

SELECT_IMPORT_LINE = re.compile(
    r'^(\s*)const\s+\{\s*([^}]+)\s*\}\s*=\s*import\s*\(\s*"([^"]+)"\s*\)\s*;\s*$'
)

# 刻意保留解构语法的测试（语言仍支持，但仓库默认绑定）
SKIP_FILES = {
    ROOT / "tests/import/const_select.su",
    ROOT / "tests/import/select_type_smoke.su",
}

# typeck 暂不支持 std.error 的绑定 import，保留解构
SKIP_IMPORT_PATHS = {"std.error"}


def parse_select_syms(raw: str) -> list[str]:
    """解析解构列表中的符号名。"""
    return [s.strip() for s in raw.split(",") if s.strip()]


def collect_imports(lines: list[str]) -> tuple[dict[str, str], dict[str, set[str]], list[int]]:
    """
    扫描 import 行。
    返回 (path→bind, path→select符号集, 待删解构行号列表)。
    """
    path_bind: dict[str, str] = {}
    path_syms: dict[str, set[str]] = {}
    select_line_idxs: list[int] = []

    for i, line in enumerate(lines):
        bm = IMPORT_BINDING_LINE.match(line.rstrip("\n\r"))
        if bm:
            bind, path = bm.group(1), bm.group(2)
            path_bind[path] = bind
            path_syms.setdefault(path, set())
            continue
        sm = SELECT_IMPORT_LINE.match(line.rstrip("\n\r"))
        if sm:
            path = sm.group(3)
            if path in SKIP_IMPORT_PATHS:
                continue
            syms = parse_select_syms(sm.group(2))
            path_syms.setdefault(path, set()).update(syms)
            if path not in path_bind:
                path_bind[path] = binding_name(path)
            select_line_idxs.append(i)

    return path_bind, path_syms, select_line_idxs


def prefix_function_calls(text: str, bind: str, func_names: set[str]) -> str:
    """为绑定模块的函数裸调用加 bind. 前缀（跳过 function/extern function 定义行）。"""
    for sym in sorted(func_names, key=len, reverse=True):
        text = re.sub(
            rf"(?<![A-Za-z0-9_.])(?<!function )(?<!extern function ){re.escape(sym)}\s*(?=\()",
            f"{bind}.{sym}",
            text,
        )
    return text


def migrate_file_text(text: str, root: Path) -> tuple[str, bool, list[str]]:
    """迁移单文件；返回 (新文本, 是否变化, 日志)。"""
    lines = text.splitlines(keepends=True)
    path_bind, path_syms, select_idxs = collect_imports(lines)
    if not select_idxs:
        return text, False, []

    logs: list[str] = []
    out = text

    for path, bind in path_bind.items():
        syms = path_syms.get(path, set())
        if not syms:
            continue
        mod_file = resolve_module_file(path, root)
        if mod_file is None:
            logs.append(f"skip: module not found {path}")
            continue
        funcs, structs, enums = module_export_symbols(mod_file)
        type_names = structs | enums
        func_only = (syms & funcs) - type_names
        if func_only:
            out = prefix_function_calls(out, bind, func_only)
            logs.append(f"{path}: prefix {len(func_only)} funcs as {bind}.*")

    new_lines = out.splitlines(keepends=True)

    # 已有绑定 import 的路径
    existing_bind_paths: set[str] = set()
    for line in new_lines:
        bm = IMPORT_BINDING_LINE.match(line.rstrip("\n\r"))
        if bm:
            existing_bind_paths.add(bm.group(2))

    # 每个 path 首次解构行 → 若无绑定则替换为绑定行，否则删除
    first_select_for_path: dict[str, int] = {}
    for i in select_idxs:
        sm = SELECT_IMPORT_LINE.match(new_lines[i].rstrip("\n\r"))
        if not sm:
            continue
        path = sm.group(3)
        if path not in first_select_for_path:
            first_select_for_path[path] = i

    replaced_paths: set[str] = set()
    for i in sorted(select_idxs, reverse=True):
        sm = SELECT_IMPORT_LINE.match(new_lines[i].rstrip("\n\r"))
        if not sm:
            del new_lines[i]
            continue
        path = sm.group(3)
        bind = path_bind[path]
        if path not in existing_bind_paths and path not in replaced_paths:
            new_lines[i] = f'const {bind} = import("{path}");\n'
            replaced_paths.add(path)
            logs.append(f"replace select with: const {bind} = import(\"{path}\")")
        else:
            del new_lines[i]
            if path in existing_bind_paths:
                logs.append(f"drop duplicate select for {path}")

    new_text = "".join(new_lines)
    return new_text, new_text != text, logs


def process_file(path: Path, root: Path, write: bool) -> int:
    """处理单个 .su 文件。"""
    if path in SKIP_FILES:
        return 0
    text = path.read_text(encoding="utf-8")
    new_text, changed, logs = migrate_file_text(text, root)
    if not changed:
        return 0
    for msg in logs:
        print(f"{path}: {msg}")
    if write:
        path.write_text(new_text, encoding="utf-8")
        print(f"migrated {path}")
    return 1


def main() -> int:
    ap = argparse.ArgumentParser(description="Convert select import to binding import")
    ap.add_argument("paths", nargs="+", help="files or directories")
    ap.add_argument("--root", default=str(ROOT))
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()
    root = Path(args.root)

    files: list[Path] = []
    for p in args.paths:
        path = Path(p)
        if path.is_dir():
            files.extend(sorted(path.rglob("*.su")))
        elif path.is_file():
            files.append(path)

    n = 0
    for f in files:
        if ".git" in f.parts:
            continue
        n += process_file(f, root, args.write)
    print(f"done: {n} files changed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
