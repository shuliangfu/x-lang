#!/usr/bin/env python3
"""Cap 4.2.8 pass-3: fix leftover stack dests + ALWAYS ABI sizeof drift.

Root cause after pass1/2 (Darwin L2):
  - pipeline_module_func_name_copy64 memset(dst,0,256) into u8[128] locals
    → __stack_chk_fail in codegen_module_func_overload_count / parser_asm_write_extern_params
  - WAVE276/278/279/280 ALWAYS still TY=276 EX=712 FN=196 (pre-widen)
    → type_get_copy truncation / Func stride tear → Option_i32 XT001

PLATFORM: SHARED. Run from repo root. Dry-run default; --apply to write.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Name-ish local / C buffer identifiers that receive copy64 / *_name_into.
NAME_LOCALS = [
    "fn_name", "fn_local", "fname", "fname_buf", "fname_buf2", "raw_name", "raw",
    "name", "namew", "nm", "nm16", "nbuf", "nb", "na", "pb",
    "vname", "vbuf", "vname_buf", "cname", "cname_buf", "mname", "aname",
    "ename", "iname", "lname", "lname_buf", "rname", "dname", "cur_nb", "tmp",
    "mangled", "hint_buf", "elem_nm", "fn_buf", "fb", "inner_nm_buf",
    "fjn", "lnm", "snm", "gnm", "bnm", "tpn", "layout_nm_buf", "cob_nm", "bn",
    "layer_buf", "base_bind_nm", "field_nm", "base_nm", "method_nm", "cv_nm",
    "base", "lbl", "dep_buf", "name_buf", "field_buf", "decl_buf", "decl_nm",
    "exist_nm", "lit_nm", "layout_nm", "qnm", "rbuf", "dep_nm_buf", "nm2",
    "buf_a", "buf_b", "path_cnt_buf", "assoc_rnm", "ret_nm", "pi_nm", "pj_nm",
    "param_nm", "tp_nm", "tnm", "fnm", "anm", "jname", "pname_buf",
    "fb_nm", "ty_nm", "enm", "dep_nm", "cur_sl_nm", "g_sl_nm", "g_bt_nm",
    "mod_path", "mod_path2", "prefix_buf", "dep_prefix_buf", "dep_prefix_buf2",
    "dep_enum_prefix", "cur_pre", "cur_pre2", "cur_pre_sl", "import_path",
    "pre", "p0", "p1", "sa", "sb", "eb",  # eb/sb in typeck suffix paths
]

# Do NOT widen import-path rows that remain 128-byte ABI:
SKIP_EXACT = {"path_buf", "dep_path", "dep_path_buf", "prev_buf"}


def widen_locals(text: str) -> tuple[str, int]:
    n = 0
    for nm in NAME_LOCALS:
        if nm in SKIP_EXACT:
            continue
        # .x: let foo: u8[128]
        pat = re.compile(rf"\b(let\s+{re.escape(nm)}\s*:\s*u8)\[128\]")
        text, c = pat.subn(r"\1[256]", text)
        n += c
        # C: uint8_t foo[128] / char foo[128]
        patc = re.compile(rf"\b((?:uint8_t|char)\s+{re.escape(nm)})\[128\]")
        text, c = patc.subn(r"\1[256]", text)
        n += c
    return text, n


def patch_seed_abi_sizes(text: str) -> tuple[str, int]:
    """Raise ALWAYS/cold twin Type/Expr/Func sizeof constants 276/712/196 → 532/1224/324."""
    n = 0
    pairs = [
        # WAVE276 value-ABI ALWAYS
        ("enum { W276_TY = 276, W276_EX = 712, W276_BL = 92, W276_FN = 196 };",
         "enum { W276_TY = 532, W276_EX = 1224, W276_BL = 92, W276_FN = 324 };"),
        ("W276C_TY = 276, W276C_EX = 712, W276C_BL = 92, W276C_FN = 196,",
         "W276C_TY = 532, W276C_EX = 1224, W276C_BL = 92, W276C_FN = 324,"),
        # WAVE270 cold Type slot
        ("  W270_TY_SIZE_WIN = 276", "  W270_TY_SIZE_WIN = 532"),
        ("  W270_TY_SIZE = 276", "  W270_TY_SIZE = 532"),
        (" * Type LE matches pure: kind@0 name[128]@4 name_len@132 elem@136 array_size@140\n"
         " * region_label[128]@144 region_label_len@272 size 276.",
         " * Type LE matches pure: kind@0 name[256]@4 name_len@260 elem@264 array_size@268\n"
         " * region_label[256]@272 region_label_len@528 size 532."),
        # WAVE275 cold grow_vec elem sizes
        ("grow_vec_init((GrowVec *)(sc + 16), (size_t)276, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 16), (size_t)532, W275_GV_INIT_CAP)"),
        ("grow_vec_init((GrowVec *)(sc + 48), (size_t)712, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 48), (size_t)1224, W275_GV_INIT_CAP)"),
        ("grow_vec_init((GrowVec *)(sc + 112), (size_t)196, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 112), (size_t)324, W275_GV_INIT_CAP)"),
        # WAVE275 module sidecar funcs / TL / alias / layout (cold !FROM_X)
        ("grow_vec_init((GrowVec *)(sc + 16), (size_t)196, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 16), (size_t)324, W275_GV_INIT_CAP)"),
        ("grow_vec_init((GrowVec *)(sc + 144), (size_t)148, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 144), (size_t)276, W275_GV_INIT_CAP)"),
        ("grow_vec_init((GrowVec *)(sc + 176), (size_t)136, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 176), (size_t)264, W275_GV_INIT_CAP)"),
        ("grow_vec_init((GrowVec *)(sc + 112), (size_t)160, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 112), (size_t)288, W275_GV_INIT_CAP)"),
        # WAVE278 Expr ALWAYS comment + any sizeof=712 markers
        ("/* Product LE sizeof(ast_Expr)=712 — match pipeline_gen / pure Cap (var_name[128]). */",
         "/* Product LE sizeof(ast_Expr)=1224 — match pipeline_gen / pure Cap (var_name[256]). */"),
        # WAVE279 lifecycle
        (" * Block 92 / Func 196 / Arena header 16 / Module header num_funcs@0. */",
         " * Block 92 / Func 324 / Arena header 16 / Module header num_funcs@0. */"),
        ("/* Func LE 196: name[128]@0 … body_ref@148 body_expr_ref@152. */",
         "/* Func LE 324: name[256]@0 … body_ref@276 body_expr_ref@280. */"),
        ("  W279_FUNC_SZ = 196,", "  W279_FUNC_SZ = 324,"),
        # WAVE280 module func domain
        ("/* Product LE: Func 196 / FuncParam 136 / ModuleSidecar 432 / ArenaSidecar 816.",
         "/* Product LE: Func 324 / FuncParam 264 / ModuleSidecar 432 / ArenaSidecar 816."),
        (" * Func: name[128]@0 name_len@128 param_base@132 num_params@136",
         " * Func: name[256]@0 name_len@256 param_base@260 num_params@264"),
        # copy64 contract comments + clamp bug (nlen>255 → 127 was wrong)
        (" * Write func name bytes into Func.name[128] (Cap: ≤127 bytes + NUL pad).",
         " * Write func name bytes into Func.name[256] (Cap: ≤255 bytes + NUL pad)."),
        (" * Copy Func.name[128] into dst (128 bytes, NUL-padded).\n"
         " * Used by codegen to avoid .x nested array GEP typeck/asm failures.\n"
         " * Contract: null m/dst / OOB func_index → no-op; copies ≤127 bytes + zero-pad.",
         " * Copy Func.name[256] into dst (256 bytes, NUL-padded).\n"
         " * Used by codegen to avoid .x nested array GEP typeck/asm failures.\n"
         " * Contract: null m/dst / OOB func_index → no-op; copies ≤255 bytes + zero-pad."),
        ("  /* wave577 Cap: copy name_len bytes (≤127), zero-pad rest; aligns with\n"
         "   * AST name[128] to avoid truncation. */\n"
         "  nlen = f->name_len;\n"
         "  if (nlen < 0)\n"
         "    nlen = 0;\n"
         "  if (nlen > 255)\n"
         "    nlen = 127;\n"
         "  memset(dst, 0, 256);",
         "  /* Cap 4.2.8: copy name_len bytes (≤255), zero-pad rest; aligns with\n"
         "   * AST name[256] to avoid truncation. */\n"
         "  nlen = f->name_len;\n"
         "  if (nlen < 0)\n"
         "    nlen = 0;\n"
         "  if (nlen > 255)\n"
         "    nlen = 255;\n"
         "  memset(dst, 0, 256);"),
        # Chinese twin comment if present
        ("  /* wave577 Cap: 拷贝 name_len 字节（≤127），余下清零；与 AST name[128] 对齐避免截断。 */",
         "  /* Cap 4.2.8: copy name_len bytes (≤255), zero-pad; AST name[256]. */"),
        # LiveVar stride in W275 (140→268) if still present as name-bearing rows
        ("grow_vec_init((GrowVec *)(sc + 144), (size_t)140, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 144), (size_t)268, W275_GV_INIT_CAP)"),
        ("grow_vec_init((GrowVec *)(sc + 176), (size_t)140, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 176), (size_t)268, W275_GV_INIT_CAP)"),
        ("grow_vec_init((GrowVec *)(sc + 240), (size_t)140, W275_GV_INIT_CAP)",
         "grow_vec_init((GrowVec *)(sc + 240), (size_t)268, W275_GV_INIT_CAP)"),
        # TypeAlias / TL / layout comments still on 128
        (" * Layout ≡ C TypeAliasEntry: name[128]@0 | name_len@128 | target@132.",
         " * Layout ≡ C TypeAliasEntry: name[256]@0 | name_len@256 | target@260."),
        (" *   name[128]@0 | name_len@128 | type_ref@132 | init_ref@136 | is_const@140 | is_export@144",
         " *   name[256]@0 | name_len@256 | type_ref@260 | init_ref@264 | is_const@268 | is_export@272"),
        (" *   name[128]@0 | name_len@128 | field_base@132 | num_fields@136",
         " *   name[256]@0 | name_len@256 | field_base@260 | num_fields@264"),
        (" * Field 144B: name[128]|name_len|offset|type_ref|align",
         " * Field 268B: name[256]|name_len|offset|type_ref|align"),
        (" * TP 132B: name[128]|name_len",
         " * TP 260B: name[256]|name_len"),
        ("  /* Type LE (wave270): kind@0 name[128]@4 name_len@132. */",
         "  /* Type LE (Cap 4.2.8): kind@0 name[256]@4 name_len@260. */"),
        ("  /* wave581 Cap residual: ABI name *copy64; payload 128 (match LetDecl / AST name[128]). */",
         "  /* Cap 4.2.8: ABI name *copy64; payload 256 (match LetDecl / AST name[256]). */"),
    ]
    for a, b in pairs:
        if a in text:
            text = text.replace(a, b)
            n += 1
    # Generic clamp leftover in copy64-like blocks: if (nlen > 255) nlen = 127;
    text2, c = re.subn(
        r"if\s*\(\s*nlen\s*>\s*255\s*\)\s*\n\s*nlen\s*=\s*127\s*;",
        "if (nlen > 255)\n    nlen = 255;",
        text,
    )
    n += c
    text = text2
    return text, n


def patch_file(path: Path, apply: bool, seed_sizes: bool = False) -> str | None:
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    orig = text
    total = 0
    text, c = widen_locals(text)
    total += c
    if seed_sizes:
        text, c = patch_seed_abi_sizes(text)
        total += c
    # codegen.x comment about copy64 128
    if "copy64 APIs actually memset/write 128 bytes" in text:
        text = text.replace(
            "copy64 APIs actually memset/write 128 bytes (wave577 AST name[128]).",
            "copy64 APIs actually memset/write 256 bytes (Cap 4.2.8 AST name[256]).",
        )
        total += 1
    if "copy64 APIs write 128 bytes (AST name[128]); never a smaller local." in text:
        text = text.replace(
            "copy64 APIs write 128 bytes (AST name[128]); never a smaller local.",
            "copy64 APIs write 256 bytes (AST name[256]); never a smaller local.",
        )
        total += 1
    if text == orig:
        return None
    if apply:
        path.write_text(text, encoding="utf-8", errors="surrogateescape")
    return f"{path.relative_to(ROOT)}: ~{total}"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()
    reports: list[str] = []

    targets = [
        ROOT / "compiler/src/codegen/codegen.x",
        ROOT / "compiler/src/typeck/typeck.x",
        ROOT / "compiler/src/parser/parser.x",
        ROOT / "compiler/src/runtime_pipeline_abi.x",
        ROOT / "compiler/src/lsp/lsp_diag.x",
        ROOT / "compiler/src/asm/backend.x",
        ROOT / "compiler/src/seed_link_compat.x",
        ROOT / "compiler/seeds/codegen_gen.linux.x86_64.c",
        ROOT / "compiler/seeds/typeck_gen.linux.x86_64.c",
        ROOT / "compiler/seeds/parser_gen.linux.x86_64.c",
        ROOT / "compiler/seeds/parser_asm_thin_c.from_x.c",
        ROOT / "compiler/seeds/async_asm_pool.from_x.c",
        ROOT / "compiler/codegen_gen.c",
        ROOT / "compiler/typeck_gen.c",
        ROOT / "compiler/parser_gen.c",
    ]
    for p in targets:
        if p.exists():
            r = patch_file(p, args.apply, seed_sizes=False)
            if r:
                reports.append(r)

    seed_abi = ROOT / "compiler/seeds/runtime_pipeline_abi.from_x.c"
    if seed_abi.exists():
        r = patch_file(seed_abi, args.apply, seed_sizes=True)
        if r:
            reports.append(r)

    # Also widen remaining uint8_t fn[128] debug helpers in seed abi via locals pass already

    mode = "APPLY" if args.apply else "DRY"
    print(f"cap_428 pass3 {mode}: {len(reports)} files")
    for r in reports:
        print(" ", r)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
