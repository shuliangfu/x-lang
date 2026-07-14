#!/usr/bin/env python3
"""Rewrite std/fmt format() overloads: fmt.fmt_scalar_to_buf -> typed fmt_*_to_buf."""
from pathlib import Path
import re

p = Path(__file__).resolve().parents[2] / "std" / "fmt" / "mod.x"
t = p.read_text()
m = {
    "i32": "fmt_i32_to_buf",
    "u32": "fmt_u32_to_buf",
    "i64": "fmt_i64_to_buf",
    "u64": "fmt_u64_to_buf",
    "usize": "fmt_usize_to_buf",
    "isize": "fmt_isize_to_buf",
}


def repl_func(match: re.Match) -> str:
    sig = match.group(1)
    body = match.group(2)
    params = re.findall(r"(\w+)\s*:\s*(\*?\w+)", sig)
    type_of = {name: ty for name, ty in params}

    def one(m2: re.Match) -> str:
        args = m2.group(0)
        mm = re.match(
            r"fmt\.fmt_scalar_to_buf\(([^,]+),\s*([^,]+),\s*(\w+)\)", args
        )
        if not mm:
            return args
        buf, cap, var = mm.group(1), mm.group(2), mm.group(3)
        ty = type_of.get(var, "i32")
        fn = m.get(ty, "fmt_i32_to_buf")
        return f"fmt.{fn}({buf}, {cap}, {var})"

    body2 = re.sub(r"fmt\.fmt_scalar_to_buf\([^)]+\)", one, body)
    return "export function format" + sig + body2


t2 = re.sub(
    r"export function format(\(buf: \*u8, cap: i32,.*?\))(\s*\{.*?\n\})",
    lambda mo: repl_func(mo) if "fmt_scalar_to_buf" in mo.group(0) else mo.group(0),
    t,
    flags=re.S,
)
print("remaining scalar", t2.count("fmt_scalar_to_buf"))
print("i32_to_buf uses", t2.count("fmt.fmt_i32_to_buf"))
p.write_text(t2)
print("OK", p)
