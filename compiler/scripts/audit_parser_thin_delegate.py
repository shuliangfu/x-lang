#!/usr/bin/env python3
"""
Audit parser thin-delegate length honesty vs live authority.

Checks that every x_name / c_name length literal in the pure-X thin-delegate
tables matches the string length, and that each x_name exists in parser.x.

wave966: retarget off deleted compiler/ast_pool.c (wave309 leave). Grepping a
missing file crashed with FileNotFoundError (no honesty message) while the
script header still claimed to audit k_asm_parser_thin_delegate in that C
shell — dead archaeology authority (same debt layer as audit_static_limits /
dead -nt).

Live authority (G.7):
  asm_parser_func_is_thin_delegate
  asm_parser_m8_tail_thin_delegate_c_name
in compiler/src/runtime_pipeline_abi.x (k_asm_parser_thin_delegate C table
retired with ast_pool).

Usage: python3 compiler/scripts/audit_parser_thin_delegate.py
Exit: 0=pass; 1=bad lengths / missing funcs / set drift / authority unresolved
PLATFORM: SHARED — structural honesty only (no product compile); dual-end L2.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ABI_X = ROOT / "compiler/src/runtime_pipeline_abi.x"
PARSER_X = ROOT / "compiler/src/parser/parser.x"

# Live pure-X providers (after parser_emit_heavy / ast_pool leave).
IS_THIN_FN = "asm_parser_func_is_thin_delegate"
M8_TAIL_FN = "asm_parser_m8_tail_thin_delegate_c_name"

_EQ_AT = re.compile(
    r'pipeline_module_func_name_equal_at\(\s*m,\s*func_index,\s*"(\w+)",\s*(\d+)\s*\)'
)
_EMIT = re.compile(
    r'asm_thin_delegate_emit\(\s*out,\s*out_cap,\s*out_len,\s*"(\w+)",\s*(\d+)\s*\)'
)


def _export_fn_body(text: str, name: str) -> str | None:
    """Return the body of `export function name(...) { ... }` (outermost braces)."""
    m = re.search(
        rf"(?m)^(?:#\[no_mangle\]\s*\n)?export function {re.escape(name)}\s*\(",
        text,
    )
    if not m:
        return None
    brace = text.find("{", m.end())
    if brace < 0:
        return None
    depth = 0
    for i in range(brace, len(text)):
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return text[brace : i + 1]
    return None


def main() -> int:
    # PLATFORM: SHARED — fail hard if live authority file missing (no silent skip).
    if not ABI_X.is_file():
        print(
            f"audit_parser_thin_delegate: FAIL: live authority missing: {ABI_X}",
            file=sys.stderr,
        )
        print(
            "  (ast_pool.c retired wave309; do not read deleted k_asm_parser_thin_delegate)",
            file=sys.stderr,
        )
        return 1
    if not PARSER_X.is_file():
        print(
            f"audit_parser_thin_delegate: FAIL: parser.x missing: {PARSER_X}",
            file=sys.stderr,
        )
        return 1

    abi = ABI_X.read_text(errors="ignore")
    parser = PARSER_X.read_text(errors="ignore")

    is_thin = _export_fn_body(abi, IS_THIN_FN)
    m8_tail = _export_fn_body(abi, M8_TAIL_FN)
    if is_thin is None or m8_tail is None:
        print(
            "audit_parser_thin_delegate: FAIL: cannot resolve live thin-delegate "
            f"exports ({IS_THIN_FN} / {M8_TAIL_FN}) in {ABI_X}",
            file=sys.stderr,
        )
        print(
            "  (ast_pool.c retired wave309; do not silent-default — fake authority)",
            file=sys.stderr,
        )
        return 1

    is_thin_xs = _EQ_AT.findall(is_thin)
    m8_xs = _EQ_AT.findall(m8_tail)
    m8_cs = _EMIT.findall(m8_tail)

    if not is_thin_xs or not m8_xs or not m8_cs:
        print(
            "audit_parser_thin_delegate: FAIL: empty thin-delegate name set "
            f"(is_thin={len(is_thin_xs)} m8_x={len(m8_xs)} m8_c={len(m8_cs)})",
            file=sys.stderr,
        )
        return 1

    # parser.x uses both `function` and `export function` (wave post-selfhost).
    funcs = set(
        re.findall(r"(?m)^(?:export\s+)?(?:extern\s+)?function\s+(\w+)\s*\(", parser)
    )
    bad = 0

    def check_lens(label: str, rows: list[tuple[str, str]]) -> None:
        nonlocal bad
        for name, lit in rows:
            n = int(lit)
            if n != len(name):
                print(f"BAD {label}_len: {name} table={n} actual={len(name)}")
                bad += 1

    check_lens("is_thin.x", is_thin_xs)
    check_lens("m8.x", m8_xs)
    check_lens("m8.c", m8_cs)

    set_is = {n for n, _ in is_thin_xs}
    set_m8 = {n for n, _ in m8_xs}
    if set_is != set_m8:
        only_is = sorted(set_is - set_m8)
        only_m8 = sorted(set_m8 - set_is)
        print(
            f"SET_DRIFT: is_thin-only={only_is[:8]}{'…' if len(only_is) > 8 else ''} "
            f"m8-only={only_m8[:8]}{'…' if len(only_m8) > 8 else ''}"
        )
        bad += 1

    if len(m8_xs) != len(m8_cs):
        print(f"PAIR_DRIFT: m8 x_rows={len(m8_xs)} c_rows={len(m8_cs)}")
        bad += 1

    for x, _ in m8_xs:
        if x not in funcs:
            print(f"MISSING func: {x}")
            bad += 1

    print(
        f"authority={ABI_X.relative_to(ROOT)} "
        f"is_thin={len(is_thin_xs)} m8_x={len(m8_xs)} m8_c={len(m8_cs)} bad={bad}"
    )
    print(
        "PLATFORM: SHARED — live = runtime_pipeline_abi.x; "
        "ast_pool.c k_asm_parser_thin_delegate retired wave309."
    )
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
