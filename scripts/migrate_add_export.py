#!/usr/bin/env python3
"""
migrate_add_export.py — 给顶层声明补 `export`（模块导出迁移第 2 步）

用法:
  python3 scripts/migrate_add_export.py path/to/dir_or_file.x [...]
  python3 scripts/migrate_add_export.py --dry-run std

规则（v1 保守）:
  - 仅处理顶层（大括号深度 0）的:
      function / async function / struct / enum / const / trait
  - 已有 `export` 前缀的不重复
  - `extern` 声明：写成 `export extern ...`（若尚未 export）
  - 属性行 `#[...]` 保持在 export 之上（export 紧贴声明关键字）
  - 不处理 impl 内方法（v1 后置字段/方法细粒度可再扫）

注意:
  - 这是「宽标记」迁移：把库表面先全部标成 export，便于切 strict；
    之后再人工把真正内部 helper 去掉 export。
  - 与 `#[export_name]` 无关。
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

DECL_RE = re.compile(
    r"^(?P<indent>[ \t]*)"
    r"(?P<head>"
    r"(?:async[ \t]+)?function\b"
    r"|struct\b"
    r"|enum\b"
    r"|const\b"
    r"|trait\b"
    r"|extern\b"
    r")"
)


def process_text(src: str) -> tuple[str, int]:
    lines = src.splitlines(keepends=True)
    out: list[str] = []
    depth = 0
    changed = 0
    i = 0
    while i < len(lines):
        line = lines[i]
        # strip line comments for brace depth of structural tokens only approximately
        code = line
        if "//" in code:
            # crude: ignore // outside strings — good enough for top-level migrate
            q = code.find("//")
            # if odd number of quotes before //, keep
            if code[:q].count('"') % 2 == 0:
                code = code[:q]

        # track braces for depth (ignore those in strings crudely)
        for ch in code:
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth = max(0, depth - 1)

        if depth == 0 or (depth == 0):
            pass

        # Only rewrite when current line is at depth 0 *before* this line's opening brace
        # Recompute depth_before
        depth_before = depth
        # undo this line's braces to get before
        for ch in code:
            if ch == "{":
                depth_before -= 1
            elif ch == "}":
                depth_before += 1
        # fix: better compute from previous depth
        # Actually we already updated depth. Reconstruct:
        # depth_after = depth; compute delta
        delta_open = code.count("{")
        delta_close = code.count("}")
        depth_before = depth - delta_open + delta_close

        if depth_before == 0:
            m = DECL_RE.match(line)
            if m:
                # skip if already export on this line
                if re.match(r"^[ \t]*export\b", line):
                    out.append(line)
                    i += 1
                    continue
                # skip import const (const x = import(...))
                if m.group("head").startswith("const") and "import" in line:
                    out.append(line)
                    i += 1
                    continue
                # skip let
                indent = m.group("indent")
                rest = line[len(indent) :]
                new_line = f"{indent}export {rest}"
                out.append(new_line if line.endswith("\n") or not line.endswith("\n") else new_line)
                # preserve newline style
                if line.endswith("\n") and not new_line.endswith("\n"):
                    out[-1] = new_line + "\n"
                elif not line.endswith("\n"):
                    out[-1] = new_line.rstrip("\n")
                changed += 1
                i += 1
                continue

        out.append(line)
        i += 1

    return "".join(out), changed


def process_file(path: Path, dry_run: bool) -> int:
    text = path.read_text(encoding="utf-8")
    new, n = process_text(text)
    if n == 0:
        return 0
    if dry_run:
        print(f"DRY {path}: +{n} export")
        return n
    path.write_text(new, encoding="utf-8")
    print(f"OK  {path}: +{n} export")
    return n


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="+", help=".x files or directories")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    total = 0
    files: list[Path] = []
    for p in args.paths:
        path = Path(p)
        if path.is_dir():
            files.extend(sorted(path.rglob("*.x")))
        elif path.is_file():
            files.append(path)
        else:
            print(f"skip missing {path}", file=sys.stderr)
    for f in files:
        total += process_file(f, args.dry_run)
    print(f"total export annotations: {total}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
