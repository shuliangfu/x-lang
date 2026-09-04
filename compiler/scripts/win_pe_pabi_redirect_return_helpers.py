#!/usr/bin/env python3
# PLATFORM: WINDOWS leftover-PE hybrid only.
#
# After rest-first + pipeline_glue_standalone thin ld -r, thin mega / thin
# emit_block keep relative calls to thin (high-VA) helpers. PE first-wins does
# not rewrite those.
#
# Redirects thin→lower-VA rest:
#   Mega helpers: nso_at / get_return_at / body_ref_at
#   Wrapper: mega_body_c (WAVE290 void-main mov-imm-0 lives in leftover rest)
#   Emit-block AST faces: stmt_order kind/idx/count, if_cond/then/else, …
#
# Usage: win_pe_pabi_redirect_return_helpers.py <pe-or-coff-path>

from __future__ import annotations

import re
import struct
import subprocess
import sys

# Thin mega → rest WIN_LEFTOVER helpers.
MEGA_REDIRECT_SYMS = (
    "pipeline_asm_block_num_stmt_order_at",
    "pipeline_asm_get_return_expr_ref_at",
    "pipeline_asm_module_func_body_ref_at",
)

# Thin emit_block / emit_if / emit_while → rest W277 ast_* faces
# (high twin mis-reads kind / SAT Block.num_expr_stmts=0 skips `x=4`).
# PLATFORM: WINDOWS leftover-PE hybrid — G.7 complete of this redirect table.
EMIT_REDIRECT_SYMS = (
    "ast_ast_block_stmt_order_kind",
    "ast_ast_block_stmt_order_idx",
    "ast_ast_block_num_stmt_order",
    "ast_ast_block_num_if_stmts",
    "ast_ast_block_num_lets",
    "ast_ast_block_num_consts",
    "ast_ast_block_num_expr_stmts",
    "ast_ast_block_num_loops",
    "ast_ast_block_num_for_loops",
    "ast_ast_block_final_expr_ref",
    "ast_ast_block_expr_stmt_ref",
    "ast_pipeline_block_expr_stmt_ref",
    "pipeline_block_expr_stmt_ref",
    "ast_ast_block_while_cond_ref",
    "ast_ast_block_while_body_ref",
    "pipeline_block_while_cond_ref",
    "pipeline_block_while_body_ref",
    "ast_ast_block_for_init_ref",
    "ast_ast_block_for_cond_ref",
    "ast_ast_block_for_step_ref",
    "ast_ast_block_for_body_ref",
    "ast_pipeline_block_if_cond_ref",
    "ast_pipeline_block_if_then_body_ref",
    "ast_pipeline_block_if_else_body_ref",
    "ast_pipeline_block_let_init_ref",
    "ast_pipeline_block_const_init_ref",
    "pipeline_block_stmt_order_kind",
    "pipeline_block_stmt_order_idx",
    "glue_emit_block_final_expr_elf",
)

# Functions whose call sites we rewrite (thin text → rest callees).
EMIT_SCAN_FUNCS = (
    ("pipeline_asm_emit_block_body_sync_elf", 0x6000),
    ("pipeline_asm_emit_block_if_stmt_elf", 0x1000),
    ("glue_emit_block_final_expr_elf", 0x400),
    ("glue_block_stmt_order_has_return", 0x400),
    ("backend_emit_while_loop_elf_sync", 0x2000),
    ("backend_emit_for_loop_elf_sync", 0x2000),
    ("backend_emit_loop_body_content_elf_sync", 0x800),
)

# Thin wrapper intra-calls thin mega_body (PE first-wins does not rewrite).
# Leftover rest WAVE290 ALWAYS has the Zig-like void-main `mov imm 0` gate
# (rkind==16 && i==main_func_index); thin mega_body does not.
# PLATFORM: WINDOWS leftover-PE hybrid / POSIX -E unchanged.
WRAPPER_REDIRECT_SYMS = (
    "pipeline_backend_asm_codegen_ast_to_elf_mega_body_c",
)
WRAPPER_SCAN_FUNCS = (
    ("pipeline_backend_asm_codegen_ast_to_elf_c", 0x400),
)


def nm_t_addrs(path: str, sym: str) -> list[int]:
    out = subprocess.check_output(["nm", path], text=True, errors="replace")
    addrs: list[int] = []
    for line in out.splitlines():
        p = line.split()
        if len(p) >= 3 and p[1] in ("T", "t") and p[2] == sym:
            addrs.append(int(p[0], 16))
    return sorted(addrs)


def pe_sections(data: bytearray) -> tuple[int, list[tuple[int, int, int, int]]]:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    num_sections = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    opt_off = e_lfanew + 24
    magic = struct.unpack_from("<H", data, opt_off)[0]
    if magic == 0x20B:
        image_base = struct.unpack_from("<Q", data, opt_off + 24)[0]
    else:
        image_base = struct.unpack_from("<I", data, opt_off + 28)[0]
    sec_off = opt_off + opt_size
    sections: list[tuple[int, int, int, int]] = []
    for i in range(num_sections):
        off = sec_off + i * 40
        vsize, va, rawsize, rawptr = struct.unpack_from("<IIII", data, off + 8)
        sections.append((va, rawptr, rawsize, vsize))
    return image_base, sections


def coff_sections(data: bytearray) -> tuple[int, list[tuple[int, int, int, int]]]:
    num_sections = struct.unpack_from("<H", data, 2)[0]
    opt_size = struct.unpack_from("<H", data, 16)[0]
    sec_off = 20 + opt_size
    sections: list[tuple[int, int, int, int]] = []
    for i in range(num_sections):
        off = sec_off + i * 40
        vsize, va, rawsize, rawptr = struct.unpack_from("<IIII", data, off + 8)
        sections.append((va, rawptr, rawsize, vsize))
    return 0, sections


def va_to_off(
    image_base: int,
    sections: list[tuple[int, int, int, int]],
    va: int,
) -> int:
    for sec_va, rawptr, rawsize, vsize in sections:
        base_va = sec_va if sec_va >= image_base else image_base + sec_va
        if base_va <= va < base_va + max(rawsize, vsize):
            return rawptr + (va - base_va)
    raise SystemExit(f"VA 0x{va:x} not mapped in {sys.argv[1]}")


def objdump_range(path: str, start: int, size: int) -> str:
    return subprocess.check_output(
        [
            "objdump",
            "-d",
            f"--start-address=0x{start:x}",
            f"--stop-address=0x{start + size:x}",
            path,
        ],
        text=True,
        errors="replace",
    )


def collect_rest_thin(path: str, syms: tuple[str, ...]) -> dict[str, tuple[int, int]]:
    """Map sym → (rest_low_va, thin_high_va) when ≥2 T defs exist."""
    out: dict[str, tuple[int, int]] = {}
    for sym in syms:
        addrs = nm_t_addrs(path, sym)
        if len(addrs) < 2:
            continue
        out[sym] = (addrs[0], addrs[-1])
    return out


def patch_calls_in_range(
    path: str,
    start: int,
    size: int,
    rest_of: dict[str, int],
    sym_alt: str,
    patches: list[tuple[int, int, str]],
) -> None:
    dis = objdump_range(path, start, size)
    for line in dis.splitlines():
        m = re.search(
            rf"^\s*([0-9a-f]+):.*\bcall\s+([0-9a-f]+)\s+<({sym_alt})>",
            line,
        )
        if not m:
            continue
        call_va = int(m.group(1), 16)
        cur = int(m.group(2), 16)
        name = m.group(3)
        if name not in rest_of:
            continue
        if cur != rest_of[name]:
            patches.append((call_va, rest_of[name], name))


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: win_pe_pabi_redirect_return_helpers.py <path>", file=sys.stderr)
        return 2
    path = sys.argv[1]

    megas = nm_t_addrs(path, "pipeline_backend_asm_codegen_ast_to_elf_mega_body_c")
    get_ret = nm_t_addrs(path, "pipeline_backend_get_return_expr_ref")
    get_at = nm_t_addrs(path, "pipeline_backend_get_return_expr_ref_at")

    mega_map = collect_rest_thin(path, MEGA_REDIRECT_SYMS)
    emit_map = collect_rest_thin(path, EMIT_REDIRECT_SYMS)
    wrap_map = collect_rest_thin(path, WRAPPER_REDIRECT_SYMS)

    rest_of: dict[str, int] = {s: pair[0] for s, pair in mega_map.items()}
    rest_of.update({s: pair[0] for s, pair in emit_map.items()})
    rest_of.update({s: pair[0] for s, pair in wrap_map.items()})

    if not rest_of:
        print("win_pe_pabi_redirect: no twin symbols to redirect")
        return 0

    patches: list[tuple[int, int, str]] = []

    # 0) Thin wrapper → rest mega_body (void-main mov-imm-0)
    if wrap_map:
        rest_wrap = {s: pair[0] for s, pair in wrap_map.items()}
        wrap_alt = "|".join(re.escape(s) for s in wrap_map)
        for fname, span in WRAPPER_SCAN_FUNCS:
            addrs = nm_t_addrs(path, fname)
            for start in addrs:
                patch_calls_in_range(path, start, span, rest_wrap, wrap_alt, patches)

    # 1) Thin mega → rest helpers
    if len(megas) >= 2 and mega_map:
        thin_mega = megas[-1]
        sym_alt = "|".join(re.escape(s) for s in mega_map)
        patch_calls_in_range(path, thin_mega, 0x2000, rest_of, sym_alt, patches)

    # Thin get_return_at wrapper → rest get_return
    if len(get_ret) >= 2 and len(get_at) >= 2:
        our_ret = get_ret[0]
        thin_at = get_at[-1]
        dis2 = objdump_range(path, thin_at, 0xA0)
        for line in dis2.splitlines():
            m = re.search(
                r"^\s*([0-9a-f]+):.*\bcall\s+([0-9a-f]+)\s+<pipeline_backend_get_return_expr_ref>",
                line,
            )
            if m and int(m.group(2), 16) != our_ret:
                patches.append((int(m.group(1), 16), our_ret, "get_return"))

    # 2) Thin emit_block / emit_if → rest ast_* faces
    if emit_map:
        sym_alt = "|".join(re.escape(s) for s in emit_map)
        for fname, span in EMIT_SCAN_FUNCS:
            addrs = nm_t_addrs(path, fname)
            if not addrs:
                continue
            # Prefer the definition that still calls thin (usually highest / only).
            for start in addrs:
                patch_calls_in_range(path, start, span, rest_of, sym_alt, patches)

    # Dedup identical call sites
    seen: set[int] = set()
    uniq: list[tuple[int, int, str]] = []
    for call_va, tgt, name in patches:
        if call_va in seen:
            continue
        seen.add(call_va)
        uniq.append((call_va, tgt, name))
    patches = uniq

    if not patches:
        print("win_pe_pabi_redirect: no thin→rest call sites (already redirected?)")
        return 0

    with open(path, "rb") as f:
        data = bytearray(f.read())

    if data[:2] == b"MZ":
        image_base, sections = pe_sections(data)
    else:
        image_base, sections = coff_sections(data)

    for call_va, tgt, name in patches:
        off = va_to_off(image_base, sections, call_va)
        if data[off] != 0xE8:
            print(f"win_pe_pabi_redirect: expected call at 0x{call_va:x} ({name})", file=sys.stderr)
            return 1
        struct.pack_into("<i", data, off + 1, tgt - (call_va + 5))

    with open(path, "wb") as f:
        f.write(data)

    print(f"win_pe_pabi_redirect: patched {len(patches)} calls in {path}")
    for call_va, tgt, name in patches:
        print(f"  0x{call_va:x} -> 0x{tgt:x} ({name})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
