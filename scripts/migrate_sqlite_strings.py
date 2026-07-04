#!/usr/bin/env python3
# 将 std/db/sqlite/sqlite.x 中裸 "..." 迁移为顶层 const + &SQL_LIT_*[0]（仅限该文件）。

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "std/db/sqlite/sqlite.x"
MARKER = '/** C 字符串常量（解析器不支持 "..." as *u8）。 */'
PREFIX = "SQL"


def lit_name(s: str) -> str:
    n = re.sub(r"[^a-zA-Z0-9]+", "_", s).strip("_").upper()
    if not n:
        n = "EMPTY"
    if n[0].isdigit():
        n = "N" + n
    return f"{PREFIX}_LIT_{n}"


def unescape(raw: str) -> str:
    return raw.encode("utf-8").decode("unicode_escape") if "\\" in raw else raw


def strip_line_comment(line: str) -> str:
    if "//" in line:
        return line.split("//", 1)[0]
    return line


def collect_strings(text: str) -> list[str]:
    code = "\n".join(strip_line_comment(l) for l in text.splitlines())
    found = re.findall(r'"((?:\\.|[^"\\])*)"', code)
    # 稳定顺序：先长后短，避免子串误替换
    uniq: dict[str, None] = {}
    for s in sorted(set(found), key=lambda x: (-len(x), x)):
        uniq[s] = None
    return list(uniq.keys())


def make_decl(name: str, s: str) -> str:
    bs = [ord(c) for c in s] + [0]
    arr = ", ".join(str(b) for b in bs)
    return f"const {name}: u8[{len(bs)}] = [{arr}];"


def main() -> None:
    text = PATH.read_text()
    if MARKER in text:
        # 已迁移过：只补缺失 const 与引用
        pass

    strings = collect_strings(text)
    mapping = {s: lit_name(s) for s in strings}

    decls = [make_decl(mapping[s], s) for s in sorted(strings, key=lambda x: mapping[x])]
    block = MARKER + "\n" + "\n".join(decls) + "\n\n"

    if MARKER not in text:
        anchor = "const DB_ERR_MSG_MAX: i32 = 160;\n\n"
        if anchor not in text:
            raise SystemExit("insertion anchor not found")
        text = text.replace(anchor, anchor + block, 1)

    # 仅替换源码中的 "..."，跳过注释行
    out_lines: list[str] = []
    for line in text.splitlines(keepends=True):
        if line.lstrip().startswith("//"):
            out_lines.append(line)
            continue
        code_part = line
        comment = ""
        if "//" in line:
            idx = line.index("//")
            code_part = line[:idx]
            comment = line[idx:]

        def repl(m: re.Match) -> str:
            raw = m.group(1)
            s = unescape(raw)
            if s not in mapping:
                mapping[s] = lit_name(s)
            return f"&{mapping[s]}[0]"

        code_part = re.sub(r'"((?:\\.|[^"\\])*)"', repl, code_part)
        out_lines.append(code_part + comment)

    PATH.write_text("".join(out_lines))
    print(f"migrated {len(mapping)} strings in {PATH}")


if __name__ == "__main__":
    main()
