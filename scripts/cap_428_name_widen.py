#!/usr/bin/env python3
"""Cap 4.2.8: AST name slots u8[128]/content≤127 → u8[256]/content≤255.

Surgical mechanical raise following wave577. Does NOT blindly replace every
128/127 — only known name-slot field spellings, allowlisted content-cap
patterns, and exact ABI offsetof/sizeof tables.

PLATFORM: SHARED. Run from repo root. Dry-run default; pass --apply to write.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Exact old→new for runtime_pipeline_abi.x offset/size authority helpers & comments.
ABI_EXACT: list[tuple[str, str]] = [
    # Type slot
    ("function pipe_ty_slot_size(): i32 { return 276; }",
     "function pipe_ty_slot_size(): i32 { return 532; }"),
    ("function pipe_ar_ty_sz(): i32 { return 276; }",
     "function pipe_ar_ty_sz(): i32 { return 532; }"),
    ("function pipe_ar_ty_name_len(): i32 { return 132; }",
     "function pipe_ar_ty_name_len(): i32 { return 260; }"),
    ("function pipe_ar_ty_elem(): i32 { return 136; }",
     "function pipe_ar_ty_elem(): i32 { return 264; }"),
    ("function pipe_ar_ty_arr(): i32 { return 140; }",
     "function pipe_ar_ty_arr(): i32 { return 268; }"),
    # Expr slot
    ("function pipe_ar_ex_sz(): i32 { return 712; }",
     "function pipe_ar_ex_sz(): i32 { return 1224; }"),
    ("function pipe_ar_ex_var_name_len(): i32 { return 160; }",
     "function pipe_ar_ex_var_name_len(): i32 { return 288; }"),
    ("function pipe_ar_ex_binop_l(): i32 { return 164; }",
     "function pipe_ar_ex_binop_l(): i32 { return 292; }"),
    ("function pipe_ar_ex_binop_r(): i32 { return 168; }",
     "function pipe_ar_ex_binop_r(): i32 { return 296; }"),
    ("function pipe_ar_ex_match_arm_base(): i32 { return 196; }",
     "function pipe_ar_ex_match_arm_base(): i32 { return 324; }"),
    ("function pipe_ar_ex_fa_base(): i32 { return 204; }",
     "function pipe_ar_ex_fa_base(): i32 { return 332; }"),
    ("function pipe_ar_ex_fa_name(): i32 { return 208; }",
     "function pipe_ar_ex_fa_name(): i32 { return 336; }"),
    ("function pipe_ar_ex_fa_len(): i32 { return 336; }",
     "function pipe_ar_ex_fa_len(): i32 { return 592; }"),
    ("function pipe_ar_ex_fa_is_enum(): i32 { return 340; }",
     "function pipe_ar_ex_fa_is_enum(): i32 { return 596; }"),
    ("function pipe_ar_ex_fa_off(): i32 { return 344; }",
     "function pipe_ar_ex_fa_off(): i32 { return 600; }"),
    ("function pipe_ar_ex_call_res_fi(): i32 { return 704; }",
     "function pipe_ar_ex_call_res_fi(): i32 { return 1216; }"),
    ("function pipe_ar_ex_call_res_di(): i32 { return 708; }",
     "function pipe_ar_ex_call_res_di(): i32 { return 1220; }"),
    ("function pipe_ar_ex_enum_tag(): i32 { return 692; }",
     "function pipe_ar_ex_enum_tag(): i32 { return 1204; }"),
    ("function pipe_expr_off_fa_is_enum(): i32 {\n  return 340;",
     "function pipe_expr_off_fa_is_enum(): i32 {\n  return 596;"),
    ("function pipe_expr_off_fa_offset(): i32 {\n  return 344;",
     "function pipe_expr_off_fa_offset(): i32 {\n  return 600;"),
    ("function pipe_expr_off_fa_soa_stride(): i32 {\n  return 348;",
     "function pipe_expr_off_fa_soa_stride(): i32 {\n  return 604;"),
    ("function pipe_expr_off_enum_variant_tag(): i32 {\n  return 692;",
     "function pipe_expr_off_enum_variant_tag(): i32 {\n  return 1204;"),
    ("function pipe_expr_off_struct_lit_name(): i32 {\n  return 536;",
     "function pipe_expr_off_struct_lit_name(): i32 {\n  return 920;"),
    ("function pipe_expr_off_struct_lit_name_len(): i32 {\n  return 664;",
     "function pipe_expr_off_struct_lit_name_len(): i32 {\n  return 1176;"),
    ("function pipe_expr_off_struct_lit_num_fields(): i32 {\n  return 672;",
     "function pipe_expr_off_struct_lit_num_fields(): i32 {\n  return 1184;"),
    # Func
    ("function pipe_ar_fn_sz(): i32 { return 196; }",
     "function pipe_ar_fn_sz(): i32 { return 324; }"),
    ("function pipe_ar_fn_name_len(): i32 { return 128; }",
     "function pipe_ar_fn_name_len(): i32 { return 256; }"),
    ("function pipe_ar_fn_param_base(): i32 { return 132; }",
     "function pipe_ar_fn_param_base(): i32 { return 260; }"),
    ("function pipe_ar_fn_num_params(): i32 { return 136; }",
     "function pipe_ar_fn_num_params(): i32 { return 264; }"),
    ("function pipe_ar_fn_ret(): i32 { return 144; }",
     "function pipe_ar_fn_ret(): i32 { return 272; }"),
    ("function pipe_ar_fn_body(): i32 { return 148; }",
     "function pipe_ar_fn_body(): i32 { return 276; }"),
    ("function pipe_ar_fn_body_expr(): i32 { return 152; }",
     "function pipe_ar_fn_body_expr(): i32 { return 280; }"),
    ("function pipe_ar_fn_is_extern(): i32 { return 156; }",
     "function pipe_ar_fn_is_extern(): i32 { return 284; }"),
    ("function pipe_ar_fn_is_async(): i32 { return 160; }",
     "function pipe_ar_fn_is_async(): i32 { return 288; }"),
    # TypeAliasEntry
    ("function pipe_ta_entry_size(): i32 {\n  return 136;",
     "function pipe_ta_entry_size(): i32 {\n  return 264;"),
    ("function pipe_ta_off_name_len(): i32 {\n  return 128;",
     "function pipe_ta_off_name_len(): i32 {\n  return 256;"),
    ("function pipe_ta_off_target(): i32 {\n  return 132;",
     "function pipe_ta_off_target(): i32 {\n  return 260;"),
    # ModuleEnumEntry
    ("function pipe_en_entry_size(): i32 {\n  return 33932;",
     "function pipe_en_entry_size(): i32 {\n  return 66828;"),
    ("function pipe_en_off_name_len(): i32 {\n  return 128;",
     "function pipe_en_off_name_len(): i32 {\n  return 256;"),
    ("function pipe_en_off_num_variants(): i32 {\n  return 132;",
     "function pipe_en_off_num_variants(): i32 {\n  return 260;"),
    ("function pipe_en_off_variant_name0(): i32 {\n  return 136;",
     "function pipe_en_off_variant_name0(): i32 {\n  return 264;"),
    ("function pipe_en_off_variant_name_len0(): i32 {\n  return 32904;",
     "function pipe_en_off_variant_name_len0(): i32 {\n  return 65800;"),
    ("function pipe_en_off_is_export(): i32 {\n  return 33928;",
     "function pipe_en_off_is_export(): i32 {\n  return 66824;"),
    # TopLevelLetEntry
    ("function pipe_tl_entry_size(): i32 {\n  return 148;",
     "function pipe_tl_entry_size(): i32 {\n  return 276;"),
    ("function pipe_tl_off_name_len(): i32 {\n  return 128;",
     "function pipe_tl_off_name_len(): i32 {\n  return 256;"),
    ("function pipe_tl_off_type_ref(): i32 {\n  return 132;",
     "function pipe_tl_off_type_ref(): i32 {\n  return 260;"),
    ("function pipe_tl_off_init_ref(): i32 {\n  return 136;",
     "function pipe_tl_off_init_ref(): i32 {\n  return 264;"),
    ("function pipe_tl_off_is_const(): i32 {\n  return 140;",
     "function pipe_tl_off_is_const(): i32 {\n  return 268;"),
    ("function pipe_tl_off_is_export(): i32 {\n  return 144;",
     "function pipe_tl_off_is_export(): i32 {\n  return 272;"),
    # StructLayout / field / type-param
    ("function pipe_sl_layout_size(): i32 {\n  return 168;",
     "function pipe_sl_layout_size(): i32 {\n  return 296;"),
    ("function pipe_sl_field_size(): i32 {\n  return 144;",
     "function pipe_sl_field_size(): i32 {\n  return 272;"),
    ("function pipe_sl_tp_size(): i32 {\n  return 132;",
     "function pipe_sl_tp_size(): i32 {\n  return 260;"),
    ("function pipe_sl_off_name_len(): i32 { return 128; }",
     "function pipe_sl_off_name_len(): i32 { return 256; }"),
    ("function pipe_sl_off_field_base(): i32 { return 132; }",
     "function pipe_sl_off_field_base(): i32 { return 260; }"),
    ("function pipe_sl_off_num_fields(): i32 { return 136; }",
     "function pipe_sl_off_num_fields(): i32 { return 264; }"),
    ("function pipe_sl_off_allow_padding(): i32 { return 140; }",
     "function pipe_sl_off_allow_padding(): i32 { return 268; }"),
    ("function pipe_sl_off_soa(): i32 { return 144; }",
     "function pipe_sl_off_soa(): i32 { return 272; }"),
    ("function pipe_sl_off_packed(): i32 { return 148; }",
     "function pipe_sl_off_packed(): i32 { return 276; }"),
    ("function pipe_sl_off_repr_compatible(): i32 { return 152; }",
     "function pipe_sl_off_repr_compatible(): i32 { return 280; }"),
    ("function pipe_sl_off_is_export(): i32 { return 156; }",
     "function pipe_sl_off_is_export(): i32 { return 284; }"),
    ("function pipe_sl_off_tp_base(): i32 { return 160; }",
     "function pipe_sl_off_tp_base(): i32 { return 288; }"),
    ("function pipe_sl_off_tp_count(): i32 { return 164; }",
     "function pipe_sl_off_tp_count(): i32 { return 292; }"),
    ("function pipe_sl_foff_name_len(): i32 { return 128; }",
     "function pipe_sl_foff_name_len(): i32 { return 256; }"),
    ("function pipe_sl_foff_offset(): i32 { return 132; }",
     "function pipe_sl_foff_offset(): i32 { return 260; }"),
    ("function pipe_sl_foff_type_ref(): i32 { return 136; }",
     "function pipe_sl_foff_type_ref(): i32 { return 264; }"),
    ("function pipe_sl_foff_align(): i32 { return 140; }",
     "function pipe_sl_foff_align(): i32 { return 268; }"),
    ("function pipe_al_off_name_len(): i32 { return 128; }",
     "function pipe_al_off_name_len(): i32 { return 256; }"),
    ("function pipe_al_off_offset(): i32 { return 132; }",
     "function pipe_al_off_offset(): i32 { return 260; }"),
]

# Comment / doc layout strings (subset; more via FIELD_PATTERNS).
ABI_COMMENT_EXACT: list[tuple[str, str]] = [
    ("Type LE: kind@0 name[128]@4 name_len@132 elem@136 array_size@140\n"
     "//   region_label[128]@144 region_label_len@272 (size 276).",
     "Type LE: kind@0 name[256]@4 name_len@260 elem@264 array_size@268\n"
     "//   region_label[256]@272 region_label_len@528 (size 532)."),
    ("Type LE: kind@0 name[128]@4 name_len@132 elem@136 array_size@140\n"
     "//   region_label[128]@144 region_label_len@272 size=276",
     "Type LE: kind@0 name[256]@4 name_len@260 elem@264 array_size@268\n"
     "//   region_label[256]@272 region_label_len@528 size=532"),
    ("Type 276 · Expr 712 · Block 92 · Func 196",
     "Type 532 · Expr 1224 · Block 92 · Func 324"),
    ("LP64 Expr peels: struct_lit_struct_name@536 name_len@664 num_fields@672",
     "LP64 Expr peels: struct_lit_struct_name@920 name_len@1176 num_fields@1184"),
    ("Entry size 33932 LE (name[128]+lens+256×var[128]+lens+export).",
     "Entry size 66828 LE (name[256]+lens+256×var[256]+lens+export)."),
    ("Layout of one ModuleEnumEntry (33932 bytes LE, ≡ C typedef ModuleEnumEntry):\n"
     "//   name[128] @0 | name_len i32 @128 | num_variants i32 @132\n"
     "//   | variant_name[256][128] @136 | variant_name_len[256] i32 @32904\n"
     "//   | is_export i32 @33928",
     "Layout of one ModuleEnumEntry (66828 bytes LE, ≡ C typedef ModuleEnumEntry):\n"
     "//   name[256] @0 | name_len i32 @256 | num_variants i32 @260\n"
     "//   | variant_name[256][256] @264 | variant_name_len[256] i32 @65800\n"
     "//   | is_export i32 @66824"),
    (" * @return i32 - 33932", " * @return i32 - 66828"),
    (" * @return i32 - 276", " * @return i32 - 532"),
    (" * Zero one Type slot (276 bytes).", " * Zero one Type slot (532 bytes)."),
    ("LiveVar = 140 (name[128]@0 name_len@128 size@132 frame_data_off@136)",
     "LiveVar = 268 (name[256]@0 name_len@256 size@260 frame_data_off@264)"),
    ("AsyncAsmPoolLiveVar: name[128]@0 name_len@128 size_bytes@132 frame_data_off@136; stride 140",
     "AsyncAsmPoolLiveVar: name[256]@0 name_len@256 size_bytes@260 frame_data_off@264; stride 268"),
    ("live[64]@12 stride 140 (name[128], name_len@+128, size_bytes@+132, frame_data_off@+136)",
     "live[64]@12 stride 268 (name[256], name_len@+256, size_bytes@+260, frame_data_off@+264)"),
    ("LabelEntry size: name[128]+name_len+offset = 136.",
     "LabelEntry size: name[256]+name_len+offset = 264."),
    ("PatchEntry size: rel32+name[128]+name_len+patch_imm = 140.",
     "PatchEntry size: rel32+name[256]+name_len+patch_imm = 268."),
    ("name[128] @0 | name_len i32 @128 | target_type_ref i32 @132",
     "name[256] @0 | name_len i32 @256 | target_type_ref i32 @260"),
    ("name[128] @0 | name_len i32 @128 | type_ref i32 @132 | init_ref i32 @136\n"
     "//   | is_const i32 @140 | is_export i32 @144",
     "name[256] @0 | name_len i32 @256 | type_ref i32 @260 | init_ref i32 @264\n"
     "//   | is_const i32 @268 | is_export i32 @272"),
    ("name[128]@0 | name_len@128 | field_base@132 | num_fields@136\n"
     "//   | allow_padding@140 | soa@144 | packed@148 | repr_compatible@152",
     "name[256]@0 | name_len@256 | field_base@260 | num_fields@264\n"
     "//   | allow_padding@268 | soa@272 | packed@276 | repr_compatible@280"),
    ("name[128]@0 | name_len@128 | field_offset@132 | type_ref@136 | field_align@140",
     "name[256]@0 | name_len@256 | field_offset@260 | type_ref@264 | field_align@268"),
    ("name[128]@0 | name_len@128",
     "name[256]@0 | name_len@256"),
    ("name[128]@0 | name_len@128 | offset@132",
     "name[256]@0 | name_len@256 | offset@260"),
    ("path[256] @0 | path_len i32 @256 | kind i32 @260 | binding_name[128] @264",
     "path[256] @0 | path_len i32 @256 | kind i32 @260 | binding_name[256] @264"),
    (" * @return i32 - 148", " * @return i32 - 276"),
    (" * @return i32 - 168", " * @return i32 - 296"),
    (" * @return i32 - 144", " * @return i32 - 272"),
    (" * @return i32 - 136", " * @return i32 - 264"),
    (" * @return i32 - 132", " * @return i32 - 260"),
    ("Cap is 127 bytes (name[128] slots; primary_slice / name64 copies use content max 127).",
     "Cap is 255 bytes (name[256] slots; primary_slice / name64 copies use content max 255)."),
    ("are fixed `name[128]` with content cap 127 (primary_slice and name64 copies).",
     "are fixed `name[256]` with content cap 255 (primary_slice and name64 copies)."),
    ("wave577 Cap track: AST name slots cap raised 63 -> 127 (u8[128] -> u8[128]); long idents hard-fail L012 (not silent clamp / XP003).",
     "wave Cap 4.2.8: AST name slots cap raised 127 -> 255 (u8[128] -> u8[256]); long idents hard-fail L012 (not silent clamp / XP003)."),
    ("wave577 Cap track: G.7 mirror try_keyword — L012 when non-keyword span > 127.",
     "wave Cap 4.2.8: G.7 mirror try_keyword — L012 when non-keyword span > 255."),
]

# Field spellings: [128] → [256] (x and C).
FIELD_NAMES = [
    "name",
    "var_name",
    "binding_name",
    "field_access_field_name",
    "method_call_name",
    "struct_lit_struct_name",
    "region_label",
    "goto_target",
    "label",
    "call_callee_name",
    "return_var_name",
    "param_name",
    "param_type_name",
    "field_name",
    "variant_name",
    "select_name",
    "fname",
    "lname",
    "rname",
    "cname",
    "vname",
    "mname",
    "aname",
    "ename",
    "iname",
    "nbuf",
    "nm",
    "fn_nm",
    "pb",
    "pname_row",
    "type_name",
    "decl_name",
    "alias_name",
    "base_name",
    "backfill_name",
    "raw_name",
    "note_m",
    "sym",
    "ok_lbl",
    "false_lbl",
    "true_lbl",
    "else_lbl",
    "end_lbl",
    "done_lbl",
    "fnptr_vname",
]

# Locals / stack buffers that commonly receive copy64 (widen with field pass).
LOCAL_BUF_NAMES = FIELD_NAMES + [
    "name0",
    "namew",
    "scratch",
    "lbl",
    "dep_buf",
    "cname_buf",
    "lname_buf",
]

CONTENT_CAP_FILES = [
    "compiler/src/ast/ast.x",
    "compiler/src/lexer/lexer.x",
    "compiler/src/parser/parser.x",
    "compiler/src/typeck/typeck.x",
    "compiler/src/codegen/codegen.x",
    "compiler/src/runtime_pipeline_abi.x",
    "compiler/src/runtime_pipeline_abi.h",
    "compiler/src/asm/async_asm_pool.x",
    "compiler/include/async_asm_pool.h",
    "compiler/src/asm/pipeline_glue_strict_minimal.x",
    "compiler/src/asm/backend_call_dispatch.x",
    "compiler/src/asm/backend_enc_dispatch.x",
    "compiler/src/asm/backend_try_inline_dispatch.x",
    "compiler/src/seed_link_compat.x",
    "compiler/src/runtime/rt_pipeline_elf_diag.x",
    "compiler/src/lsp/lsp_diag.x",
]

# Seed / gen mirrors: field arrays + content caps (same commit).
SEED_GLOBS = [
    "compiler/seeds/**/*.c",
    "compiler/seeds/**/*.inc",
    "compiler/parser_gen.c",
    "compiler/pipeline_gen.c",
    "compiler/typeck_gen.c",
    "compiler/codegen_gen.c",
    "compiler/driver_gen.c",
    "compiler/driver_compile_gen.c",
    "compiler/lsp_diag_gen.c",
    "compiler/lexer_gen.c",
]


def widen_field_arrays(text: str) -> tuple[str, int]:
    n = 0
    for fn in FIELD_NAMES + LOCAL_BUF_NAMES:
        # x: name: u8[128]  / let name: u8[128]
        pat_x = re.compile(rf"\b{re.escape(fn)}\s*:\s*u8\[128\]")
        text2, c = pat_x.subn(f"{fn}: u8[256]", text)
        n += c
        text = text2
        # C: uint8_t name[128] / char name[128]
        pat_c = re.compile(rf"\b((?:uint8_t|char)\s+{re.escape(fn)})\[128\]")
        text2, c = pat_c.subn(r"\1[256]", text)
        n += c
        text = text2
        # C multi-dim: variant_name[256][128]
        pat_md = re.compile(rf"\b{re.escape(fn)}\[(\d+)\]\[128\]")
        text2, c = pat_md.subn(rf"{fn}[\1][256]", text)
        n += c
        text = text2
    return text, n


def widen_content_caps(text: str, path: str) -> tuple[str, int]:
    """Raise name-slot content caps 127→255 / row loops 128→256 with denylist."""
    n = 0
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    for line in lines:
        raw = line
        # Denylist: string-lit L011 chain, rel8, defines count, module tables, paths
        low = line.lower()
        if any(
            s in low
            for s in (
                "string_lit",
                "string lit",
                "l011",
                "rel8",
                "preprocess_max_defines",
                "stem_buf",
                "path_buf",
                "sync_path",
                "dep_path",
                "entry_dir",
                "ehdr",
                "modrm",
                "g_pipe_imp_n",
                "g_pipe_en_n",
                "g_pipe_ta_n",
                "g_pipe_tl_n",
                "module slot",
                "max_modules",
                "wi>=127",
                "wi > 127",
                "wi>= 127",
                "overflow chunk",
                "int_val overflow",
            )
        ):
            out.append(line)
            continue

        # Content comparisons on name-ish lengths
        def repl_gt(m: re.Match[str]) -> str:
            return m.group(0).replace("127", "255")

        new = line
        # Common patterns: > 127 / <= 127 / >127 / <=127 on length-ish idents
        if re.search(
            r"(nlen|name_len|flen|vlen|blen|plen|slen|llen|gnl|nl|pl|falen|vnlen|"
            r"alias_name_len|decl_name_len|field_name_len|base_name_len|bind_len|"
            r"elem_nlen|let_nlen|clen|alen|fname_len|label_len|len)\s*(?:<=?|>=?)\s*127\b",
            new,
        ) or re.search(
            r"(?:<=?|>=?)\s*127\b.*(nlen|name_len|flen|vlen|name|ident)",
            new,
        ):
            new2, c = re.subn(r"\b127\b", "255", new)
            n += c
            new = new2

        # Lexer produce point
        if "nlen > 127" in new or "nlen>127" in new:
            new2 = new.replace("127", "255")
            if new2 != new:
                n += 1
                new = new2

        # Row clear/copy loops tied to name slots (not module maps)
        if re.search(
            r"(memset|memcpy)\([^;]*\b128\b",
            new,
        ) and any(k in new for k in ("name", "label", "binding", "variant", "fname", "vname", "dst", "out64", "into")):
            new2, c = re.subn(r"\b128\b", "256", new)
            # avoid turning name[128] comments already handled; ok
            n += c
            new = new2

        if re.search(r"while\s*\(\s*i\s*<\s*128\s*\)", new) and any(
            k in new for k in ("name", "dst", "buf", "row", "memcpy", "copy")
        ):
            new2 = re.sub(r"i\s*<\s*128", "i < 256", new)
            if new2 != new:
                n += 1
                new = new2

        # Comments about content ≤127 / name[128] capacity
        if "content" in low and "127" in new and ("name" in low or "ident" in low or "cap" in low):
            new2 = new.replace("127", "255").replace("name[128]", "name[256]")
            if new2 != new:
                n += new.count("127")  # rough
                new = new2

        out.append(new if new != raw else line)
        if new != raw and new == line:
            pass
    return "".join(out), n


def patch_region_label_len_hardcodes(text: str) -> tuple[str, int]:
    """Type.region_label_len moved 272 → 528."""
    n = 0
    # pipe_load_i32_le(t, 272) on Type slots — only in type pool section patterns
    text2, c = re.subn(
        r"pipe_load_i32_le\(t,\s*272\)",
        "pipe_load_i32_le(t, 528)",
        text,
    )
    n += c
    text = text2
    text2, c = re.subn(
        r"pipe_store_i32_le\(t,\s*272,",
        "pipe_store_i32_le(t, 528,",
        text,
    )
    n += c
    return text2, n


def patch_onefunc_growvec_elem(text: str) -> tuple[str, int]:
    """OneFunc name-row GrowVec elem_sz 128 → 256 at known sidecar offsets."""
    n = 0
    for off in (112, 240, 272, 720):
        pat = re.compile(
            rf"(grow_vec_init\(sc2\s*\+\s*\({off}\s*as\s*usize\),\s*)128(\s*,)"
        )
        text, c = pat.subn(rf"\g<1>256\2", text)
        n += c
    # dep path rows
    text2, c = re.subn(
        r"(grow_vec_init\(pipe_dep_sc_gv\(sc2,\s*pipe_dep_sc_off_dep_path_rows\(\)\),\s*)128(\s*,)",
        r"\g<1>256\2",
        text,
    )
    n += c
    return text2, n


def patch_enum_variant_stride(text: str) -> tuple[str, int]:
    """variant_name[vi*128] → vi*256 in enum entry walks."""
    n = 0
    text2, c = re.subn(r"vi\s*\*\s*128", "vi * 256", text)
    n += c
    text2, c = re.subn(r"variant_idx\s*\*\s*128", "variant_idx * 256", text2)
    n += c
    # seed: e[136 + vi * 128 + j]
    text2, c = re.subn(
        r"e\[136\s*\+\s*vi\s*\*\s*128",
        "e[264 + vi * 256",
        text2,
    )
    n += c
    return text2, n


def process_file(path: Path, apply: bool) -> dict:
    rel = str(path.relative_to(ROOT))
    original = path.read_text(encoding="utf-8", errors="surrogateescape")
    text = original
    changes = 0

    if rel == "compiler/src/runtime_pipeline_abi.x":
        for a, b in ABI_EXACT + ABI_COMMENT_EXACT:
            if a in text:
                text = text.replace(a, b)
                changes += 1
        text, c = patch_region_label_len_hardcodes(text)
        changes += c
        text, c = patch_onefunc_growvec_elem(text)
        changes += c
        text, c = patch_enum_variant_stride(text)
        changes += c
        # Hardcoded Func.body_ref peels (should be pipe_ar_fn_body(); Cap raise 148→276)
        text2, c = re.subn(
            r"body_ref\s*=\s*pipe_load_i32_le\(f,\s*148\)",
            "body_ref = pipe_load_i32_le(f, 276)",
            text,
        )
        changes += c
        text = text2

    if rel.endswith((".x", ".c", ".h", ".inc")):
        text, c = widen_field_arrays(text)
        changes += c

    if rel in CONTENT_CAP_FILES or rel.startswith("compiler/seeds/") or rel.endswith(
        ("_gen.c", "_gen.linux.x86_64.c", ".from_x.c", ".inc")
    ):
        text, c = widen_content_caps(text, rel)
        changes += c
        if rel != "compiler/src/runtime_pipeline_abi.x":
            text, c = patch_enum_variant_stride(text)
            changes += c

    # Param.name u8[32] → u8[256] in ast.x (kill dual-authority with sidecar)
    if rel == "compiler/src/ast/ast.x":
        text2, c = re.subn(
            r"(export struct Param \{\n  name: )u8\[32\]",
            r"\1u8[256]",
            text,
        )
        changes += c
        text = text2

    # async header LiveVar
    if rel == "compiler/include/async_asm_pool.h":
        text2 = text.replace("uint8_t name[128];", "uint8_t name[256];")
        if text2 != text:
            changes += 1
            text = text2

    if text != original:
        if apply:
            path.write_text(text, encoding="utf-8", errors="surrogateescape")
        return {"path": rel, "changed": True, "edits": changes}
    return {"path": rel, "changed": False, "edits": 0}


def iter_targets() -> list[Path]:
    files: set[Path] = set()
    for rel in CONTENT_CAP_FILES:
        p = ROOT / rel
        if p.exists():
            files.add(p)
    for pattern in SEED_GLOBS:
        for p in ROOT.glob(pattern):
            if p.is_file():
                files.add(p)
    # Extra high-touch from blast map
    for rel in [
        "compiler/src/runtime_driver_abi_thin.x",
        "compiler/src/runtime_pipeline_abi_wpo_dump_thin.x",
        "compiler/src/runtime_pipeline_abi_unused_hints_thin.x",
        "compiler/seeds/user_asm_seed_bridge.from_x.c",
        "compiler/seeds/x_seed_bridge.from_x.c",
    ]:
        p = ROOT / rel
        if p.exists():
            files.add(p)
    return sorted(files)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()
    results = []
    for path in iter_targets():
        results.append(process_file(path, args.apply))
    changed = [r for r in results if r["changed"]]
    mode = "APPLIED" if args.apply else "DRY-RUN"
    print(f"[{mode}] files touched: {len(changed)} / {len(results)}")
    for r in changed:
        print(f"  {r['path']}: ~{r['edits']} ops")
    return 0


if __name__ == "__main__":
    sys.exit(main())
