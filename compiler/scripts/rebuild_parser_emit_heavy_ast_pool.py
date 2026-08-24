#!/usr/bin/env python3
"""
Honesty-retired: rebuild of deleted ast_pool.c parser EMIT_HEAVY infrastructure.

Historically rewrote k_asm_parser_thin_delegate / mega / force_stub / safe_helper
blocks inside compiler/ast_pool.c from parser_asm_thin_c.c + parser.x.

wave966: ast_pool.c left wave309; parser_asm_thin_c.c path also gone. Invoking
this script crashed with FileNotFoundError while the header still claimed to
rebuild a live C shell — dead archaeology writer (same debt layer as dead -nt /
audit fake authority).

Live authority (G.7; do NOT resurrect writing ast_pool.c / .base fossils):
  asm_parser_func_is_thin_delegate
  asm_parser_m8_tail_thin_delegate_c_name
  asm_skip_heavy_parser_* / emit-heavy helpers
in compiler/src/runtime_pipeline_abi.x (+ seed twin). Audit lengths with:
  python3 compiler/scripts/audit_parser_thin_delegate.py

Usage: python3 compiler/scripts/rebuild_parser_emit_heavy_ast_pool.py
Exit: always 1 (retired writer refuses to mutate deleted producers)
PLATFORM: SHARED — archaeology honesty only; dual-end L2.
"""
from __future__ import annotations

import argparse
import sys


def main() -> int:
    ap = argparse.ArgumentParser(
        description=(
            "RETIRED (wave966): refused to rewrite deleted compiler/ast_pool.c. "
            "Live thin-delegate / EMIT_HEAVY parser path = runtime_pipeline_abi.x."
        )
    )
    ap.add_argument(
        "--emit-tail",
        choices=("return0", "return1"),
        default="return1",
        help="Ignored (retired). Kept so old call sites still parse argv.",
    )
    ap.parse_args()

    print(
        "rebuild_parser_emit_heavy_ast_pool: RETIRED (wave966)",
        file=sys.stderr,
    )
    print(
        "  ast_pool.c left wave309; parser_asm_thin_c.c path also absent.",
        file=sys.stderr,
    )
    print(
        "  Live authority = compiler/src/runtime_pipeline_abi.x "
        "(asm_parser_func_is_thin_delegate / asm_parser_m8_tail_thin_delegate_c_name).",
        file=sys.stderr,
    )
    print(
        "  Audit: python3 compiler/scripts/audit_parser_thin_delegate.py",
        file=sys.stderr,
    )
    print(
        "  PLATFORM: SHARED — do not write ast_pool.c.base fossils (fake dual authority).",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
