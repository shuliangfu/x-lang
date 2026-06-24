#!/usr/bin/env python3
"""
从 typeck.sx 函数签名生成 typeck_asm_bare_link_alias.c：
build_asm/typeck.o 裸符号 → pipeline_glue 期望的 typeck_ 前缀名。
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SX = ROOT / "src/typeck/typeck.sx"
OUT = ROOT / "typeck_asm_bare_link_alias.c"

TYPE_MAP = {
    "i32": "int32_t",
    "bool": "int32_t",
    "void": "void",
    "TypeKind": "int32_t",
    "Module": "struct ast_Module",
    "ASTArena": "struct ast_ASTArena",
    "PipelineDepCtx": "struct ast_PipelineDepCtx",
    "*u8": "uint8_t *",
    "*Module": "struct ast_Module *",
    "*ASTArena": "struct ast_ASTArena *",
    "*PipelineDepCtx": "struct ast_PipelineDepCtx *",
}


def sx_to_c_type(t: str) -> str:
    t = t.strip()
    if t in TYPE_MAP:
        return TYPE_MAP[t]
    if t.startswith("*"):
        inner = sx_to_c_type(t[1:])
        if inner.endswith("*"):
            return inner
        return f"{inner} *"
    return t


def parse_func(sx_src: str, name: str):
    pat = re.compile(rf"function {re.escape(name)}\((.*?)\):\s*(\w+)\s*\{{", re.DOTALL)
    m = pat.search(sx_src)
    if not m:
        raise SystemExit(f"missing function {name} in typeck.sx")
    params_raw = re.sub(r"\s+", " ", m.group(1).strip())
    ret = sx_to_c_type(m.group(2))
    params = []
    if params_raw:
        for p in params_raw.split(","):
            pname, ptype = p.split(":", 1)
            params.append((sx_to_c_type(ptype), pname.strip()))
    return ret, params


def main() -> None:
    sx_src = SX.read_text()
    asm = set()
    sx = set()
    import subprocess

    def nm_syms(path, pred):
        out = subprocess.check_output(["nm", str(path)], text=True, stderr=subprocess.DEVNULL)
        for line in out.splitlines():
            m = re.match(r"[0-9a-f]+ T (_?\S+)$", line.strip())
            if m:
                s = m.group(1).lstrip("_")
                if pred(s):
                    yield s

    for s in nm_syms(ROOT / "build_asm/typeck.o", lambda _: True):
        asm.add(s)
    for s in nm_syms(ROOT / "typeck_sx.o", lambda x: x.startswith("typeck_")):
        sx.add(s)

    pairs = []
    for pref in sorted(sx):
        if pref in asm:
            continue
        bare = pref[7:] if pref.startswith("typeck_") else pref
        if bare in asm:
            pairs.append((pref, bare))

    lines = [
        "/**",
        " * typeck_asm_bare_link_alias.c — build_asm/typeck.o 裸符号 → pipeline_glue 的 typeck_ 前缀名",
        " *",
        " * 由 compiler/scripts/gen_typeck_asm_bare_link_alias.py 从 typeck.sx 签名生成。",
        " */",
        "#include <stdint.h>",
        "",
        "struct ast_Module;",
        "struct ast_ASTArena;",
        "struct ast_PipelineDepCtx;",
        "",
    ]
    for pref, bare in pairs:
        ret, params = parse_func(sx_src, bare)
        argdecl = ", ".join(f"{t} {n}" for t, n in params)
        lines.append(f"extern {ret} {bare}({argdecl});")
        lines.append("")
        lines.append(f"/** build_asm {bare} → glue {pref}。 */")
        lines.append(f"{ret} {pref}({argdecl}) {{")
        callargs = ", ".join(n for _, n in params)
        if ret == "void":
            lines.append(f"  {bare}({callargs});")
        else:
            lines.append(f"  return {bare}({callargs});")
        lines.append("}")
        lines.append("")

    OUT.write_text("\n".join(lines) + "\n")
    print(f"gen_typeck_asm_bare_link_alias: {len(pairs)} aliases -> {OUT}")


if __name__ == "__main__":
    main()
