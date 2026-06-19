#!/usr/bin/env python3
"""
migrate-import-to-binding.py — **已废弃**，请用 migrate_import_to_select.py

旧脚本会把类型也加 `mod.` 前缀导致 parse 失败。统一工具按规则自动选方式 2/3。
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# 复用 select 迁移器的模块解析与符号扫描
import importlib.util

_ROOT = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    "migrate_import_to_select", _ROOT / "migrate_import_to_select.py"
)
_m = importlib.util.module_from_spec(_spec)
assert _spec.loader is not None
_spec.loader.exec_module(_m)

IMPORT_WHOLE_RE = _m.IMPORT_WHOLE_RE
binding_name = _m.binding_name
file_identifiers = _m.file_identifiers
module_export_symbols = _m.module_export_symbols
resolve_module_file = _m.resolve_module_file

ROOT = Path(__file__).resolve().parents[1]

# 匹配裸调用：identifier( 或 identifier { 且非 name. 前缀
CALL_RE = re.compile(r"(?<![A-Za-z0-9_.])([A-Za-z_][A-Za-z0-9_]*)\s*(?=\()")
TYPE_USE_RE = re.compile(r":\s*([A-Za-z_][A-Za-z0-9_]*)")
STRUCT_LIT_RE = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*\{")


def migrate_binding(text: str, root: Path) -> tuple[str, bool, list[str]]:
    """整模块 import → 绑定 import，并为使用的导出符号加前缀。"""
    warnings: list[str] = []
    lines = text.splitlines(keepends=True)
    imports: list[tuple[int, str, str, set[str]]] = []

    for i, line in enumerate(lines):
        m = IMPORT_WHOLE_RE.match(line.rstrip("\n\r"))
        if not m:
            continue
        import_path = m.group(1)
        mod_file = resolve_module_file(import_path, root)
        if mod_file is None:
            warnings.append(f"skip: no module for {import_path}")
            continue
        bind = binding_name(import_path)
        syms = module_export_symbols(mod_file)
        imports.append((i, import_path, bind, syms))

    if not imports:
        return text, False, warnings

    body = "".join(lines)
    ids = file_identifiers(body)

    # 符号 → 绑定名（若多模块导出同名，保留第一个并警告）
    sym_to_bind: dict[str, str] = {}
    for _i, _path, bind, syms in imports:
        used = ids & syms
        for s in used:
            if s in sym_to_bind and sym_to_bind[s] != bind:
                warnings.append(f"symbol collision: {s} from {sym_to_bind[s]} and {bind}")
            else:
                sym_to_bind[s] = bind

    new_body = body
    # 按符号名长度降序，避免短名误替换
    for sym in sorted(sym_to_bind.keys(), key=len, reverse=True):
        bind = sym_to_bind[sym]
        # 函数调用 foo( → bind.foo(
        new_body = re.sub(
            rf"(?<![A-Za-z0-9_.]){re.escape(sym)}\s*(?=\()",
            f"{bind}.{sym}",
            new_body,
        )
        # 类型 : Foo → : bind.Foo（简单场景）
        new_body = re.sub(
            rf":\s*{re.escape(sym)}\b",
            f": {bind}.{sym}",
            new_body,
        )
        # 结构体字面量 Foo { → bind.Foo {
        new_body = re.sub(
            rf"\b{re.escape(sym)}\s*(?=\{{)",
            f"{bind}.{sym}",
            new_body,
        )

    new_lines = new_body.splitlines(keepends=True)
    for i, import_path, bind, _syms in reversed(imports):
        new_lines[i] = f"const {bind} = import {import_path};\n"

    return "".join(new_lines), True, warnings


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="+")
    ap.add_argument("--root", default=str(ROOT))
    ap.add_argument("--write", action="store_true")
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    root = Path(args.root)
    write = args.write and not args.check

    for p in args.paths:
        path = Path(p)
        paths = sorted(path.rglob("*.sx")) if path.is_dir() else [path]
        for f in paths:
            text = f.read_text(encoding="utf-8")
            new_text, changed, warnings = migrate_binding(text, root)
            for w in warnings:
                print(f"{f}: {w}", file=sys.stderr)
            if not changed:
                continue
            if write:
                f.write_text(new_text, encoding="utf-8")
                print(f"migrated {f}")
            else:
                print(f"--- {f} ---\n{new_text}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
