#!/usr/bin/env python3
"""Replace platform.elf.* with elf.* binding calls; fix ElfCodegenCtx type refs."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# (path, needs_elf_binding_import, needs_elfcodegenctx_destruct)
TARGETS: list[tuple[str, bool, bool]] = [
    ("compiler/src/asm/platform/macho.sx", True, False),
    ("compiler/src/asm/platform/coff.sx", True, False),
    ("compiler/src/asm/peephole.sx", True, True),
    ("compiler/src/asm/backend.sx", True, True),
    ("compiler/src/asm/asm.sx", True, False),
    ("compiler/src/asm/arch/x86_64_enc.sx", True, False),
    ("compiler/src/asm/arch/riscv64_enc.sx", True, False),
    ("compiler/src/asm/arch/arm64_enc.sx", True, False),
    ("compiler/src/asm/arch/arm64_enc_repro.sx", True, True),
    ("tests/parser/arm64_enc_repro.sx", True, True),
]


def ensure_import_line(text: str, import_line: str) -> str:
    if import_line in text:
        return text
    # Insert after last existing const ... = import("platform.elf") line
    m = re.search(r'^const elf = import\("platform\.elf"\);\n', text, re.M)
    if m:
        insert_at = m.end()
        return text[:insert_at] + import_line + "\n" + text[insert_at:]
    return text


def patch_file(rel: str, need_binding: bool, need_ctx: bool) -> bool:
    path = ROOT / rel
    if not path.is_file():
        print(f"skip missing {rel}", file=sys.stderr)
        return False
    text = path.read_text(encoding="utf-8")
    orig = text

    text = text.replace("*platform.elf.ElfCodegenCtx", "*ElfCodegenCtx")
    text = text.replace("platform.elf.", "elf.")

    if need_ctx and 'const { ElfCodegenCtx }' not in text and "struct ElfCodegenCtx" not in text:
        text = ensure_import_line(text, 'const { ElfCodegenCtx } = import("platform.elf");')

    if need_binding and 'const elf = import("platform.elf")' not in text:
        # tests/parser/arm64_enc_repro already has it
        if 'import("platform.elf")' not in text:
            print(f"warn: no elf import in {rel}", file=sys.stderr)

    if text != orig:
        path.write_text(text, encoding="utf-8")
        print(f"patched {rel}")
        return True
    print(f"unchanged {rel}")
    return False


def main() -> int:
    n = 0
    for rel, nb, nc in TARGETS:
        if patch_file(rel, nb, nc):
            n += 1
    print(f"done: {n} file(s) updated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
