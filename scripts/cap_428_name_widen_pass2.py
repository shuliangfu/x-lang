#!/usr/bin/env python3
"""Cap 4.2.8 pass-2: leftover content caps, name locals, enum/scratch/LiveVar sizes."""
from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

EXACT: list[tuple[str, Path, str, str]] = []


def sub_file(path: Path, pairs: list[tuple[str, str]], apply: bool) -> int:
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    n = 0
    for a, b in pairs:
        if a in text:
            text = text.replace(a, b)
            n += 1
    # regex pairs marked with re: prefix in a via separate handling
    return _finish(path, text, n, apply)


def _finish(path: Path, text: str, n: int, apply: bool) -> int:
    orig = path.read_text(encoding="utf-8", errors="surrogateescape")
    if text != orig:
        if apply:
            path.write_text(text, encoding="utf-8", errors="surrogateescape")
        return max(n, 1)
    return 0


def patch_typeck_parser_missed_caps(apply: bool) -> list[str]:
    reports = []
    files = [
        ROOT / "compiler/src/typeck/typeck.x",
        ROOT / "compiler/src/parser/parser.x",
        ROOT / "compiler/src/runtime_pipeline_abi.x",
        ROOT / "compiler/src/lexer/lexer.x",
    ]
    # Short length idents missed by pass1
    cap_re = re.compile(
        r"\b(fl|fl2|bl|sl|el|n|cnml|plen_param|func_name_len_storage\[0\]|mln|elen2|"
        r"name_len|nlen|slen|flen|vlen)\b([^;\n]{0,40}?)(\b127\b)"
    )

    local_names = [
        "mangled", "hint_buf", "elem_nm", "fn_buf", "fb", "vbuf", "inner_nm_buf",
        "fjn", "lnm", "snm", "gnm", "bnm", "tpn", "layout_nm_buf", "cob_nm", "bn",
        "na", "nb", "layer_buf", "vname_buf", "base_bind_nm", "field_nm", "base_nm",
        "method_nm", "cv_nm", "base", "dname", "cur_nb", "tmp", "fname", "lname",
        "rname", "cname", "aname", "ename", "iname", "nbuf", "nm", "pb", "lbl",
        "dep_buf", "cname_buf", "lname_buf", "name_buf", "field_buf", "decl_buf",
        "exist_nm", "lit_nm", "layout_nm", "qnm", "rbuf", "dep_nm_buf", "nm2",
        "buf_a", "buf_b", "path_cnt_buf",
    ]

    for path in files:
        text = path.read_text(encoding="utf-8", errors="surrogateescape")
        orig = text
        n = 0

        def repl_cap(m: re.Match[str]) -> str:
            nonlocal n
            # skip imm8 / encoding / string-lit contexts on same line
            # (checked via surrounding — we only replace the 127 token)
            n += 1
            return m.group(1) + m.group(2) + "255"

        lines = text.splitlines(keepends=True)
        out = []
        for line in lines:
            low = line.lower()
            if any(
                s in low
                for s in (
                    "imm32",
                    "rel8",
                    "nbytes",
                    "string lit",
                    "string_lit",
                    "l011",
                    "path_buf",
                    "scan <=",
                    "modrm",
                    "disp",
                )
            ):
                out.append(line)
                continue
            new, c = cap_re.subn(repl_cap, line)
            # also func_name_len_storage and plen_param explicit
            if "func_name_len_storage[0] > 127" in new:
                new = new.replace("127", "255")
                c += 1
            if "plen_param > 127" in new:
                new = new.replace("127", "255")
                c += 1
            n += c
            out.append(new)
        text = "".join(out)

        # Widen name-ish locals u8[128] → [256]
        for nm in local_names:
            pat = re.compile(rf"\b(let\s+{re.escape(nm)}\s*:\s*u8)\[128\]")
            text, c = pat.subn(r"\1[256]", text)
            n += c
            patc = re.compile(rf"\b((?:uint8_t|char)\s+{re.escape(nm)})\[128\]")
            text, c = patc.subn(r"\1[256]", text)
            n += c

        # Comments
        text2 = text.replace(
            "alias names may be up to 127 (TypeAliasEntry.name[128])",
            "alias names may be up to 255 (TypeAliasEntry.name[256])",
        )
        text2 = text2.replace(
            "merge layout names ≤127 (scratch64 slots are 128 bytes)",
            "merge layout names ≤255 (scratch64 slots are 256 bytes)",
        )
        text2 = text2.replace(
            "span length > 127 — produce-point",
            "span length > 255 — produce-point",
        )
        text2 = text2.replace(
            "wave577 Cap track: G.7 mirror try_keyword — L012 when non-keyword span > 127.",
            "wave Cap 4.2.8: G.7 mirror try_keyword — L012 when non-keyword span > 255.",
        )
        text2 = text2.replace(
            "wave577 Cap track: AST name slots cap raised 63 -> 255 (u8[128] -> u8[128])",
            "wave Cap 4.2.8: AST name slots cap raised 127 -> 255 (u8[128] -> u8[256])",
        )
        text2 = text2.replace(
            "Expr.var_name[128] plus int_val overflow chunks",
            "Expr.var_name[256] plus int_val overflow chunks",
        )
        text2 = text2.replace(
            "caller caps typically <= 127",
            "caller caps typically <= 255",
        )
        if text2 != text:
            n += 1
            text = text2

        if text != orig:
            if apply:
                path.write_text(text, encoding="utf-8", errors="surrogateescape")
            reports.append(f"{path.relative_to(ROOT)}: ~{n}")
    return reports


def patch_abi_name_n_caps(apply: bool) -> list[str]:
    path = ROOT / "compiler/src/runtime_pipeline_abi.x"
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    orig = text
    n = 0
    # Safe: name_len clamps `let n: i32 = ...; if (n > 127)`
    # Avoid imm8 lines already filtered if we only replace in specific function regions
    # Use line-wise: if line has `if (n > 127)` and nearby assign from name_len/len/nlen/slen
    lines = text.splitlines(keepends=True)
    out = []
    for i, line in enumerate(lines):
        if "if (n > 127)" in line or "if (n >127)" in line:
            window = "".join(lines[max(0, i - 6) : i + 1])
            if any(
                k in window
                for k in (
                    "name_len",
                    "nlen",
                    "slen",
                    "let n: i32 = len",
                    "pipe_al_off_name_len",
                    "pipe_ar_ex_sz",
                    "binding",
                    "select_name",
                    "label",
                )
            ) and "imm32" not in window and "nbytes" not in window:
                line = line.replace("127", "255")
                n += 1
        if "if (elen2 > 127)" in line or "if (fl <= 127)" in line or "if (mln > 0 && mln <= 127)" in line:
            line = line.replace("127", "255")
            n += 1
        out.append(line)
    text = "".join(out)
    if text != orig and apply:
        path.write_text(text, encoding="utf-8", errors="surrogateescape")
    return [f"runtime_pipeline_abi.x name n-caps: ~{n}"] if n or text != orig else []


def patch_ast_depctx(apply: bool) -> list[str]:
    path = ROOT / "compiler/src/ast/ast.x"
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    orig = text
    for fld in (
        "current_codegen_prefix_mirror",
        "entry_module_import_path_mirror",
        "typeck_scope_region_label",
    ):
        text = text.replace(f"{fld}: u8[128]", f"{fld}: u8[256]")
    if text != orig and apply:
        path.write_text(text, encoding="utf-8", errors="surrogateescape")
    return ["ast.x DepCtx mirrors →[256]"] if text != orig else []


def patch_scratch_and_enum_seed(apply: bool) -> list[str]:
    reports = []
    # scratch64
    for rel in (
        "compiler/seeds/typeck_cap_residual.from_x.c",
    ):
        path = ROOT / rel
        text = path.read_text(encoding="utf-8", errors="surrogateescape")
        orig = text
        text = text.replace("g_typeck_scratch64[16][128]", "g_typeck_scratch64[16][256]")
        if text != orig:
            if apply:
                path.write_text(text, encoding="utf-8", errors="surrogateescape")
            reports.append(f"{rel}: scratch64 128→256")

    # enum entry size in seed
    path = ROOT / "compiler/seeds/runtime_pipeline_abi.from_x.c"
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    orig = text
    pairs = [
        ("#define WAVE264_EN_ENTRY_SZ 33932", "#define WAVE264_EN_ENTRY_SZ 66828"),
        ("33932B ModuleEnumEntry", "66828B ModuleEnumEntry"),
        (
            "name[128]@0 | name_len@128 | num_variants@132 | variant_name[256][256]@136",
            "name[256]@0 | name_len@256 | num_variants@260 | variant_name[256][256]@264",
        ),
        (
            "if (!grow_vec_init((GrowVec *)(sc + 208), (size_t)33932, W275_GV_INIT_CAP))",
            "if (!grow_vec_init((GrowVec *)(sc + 208), (size_t)66828, W275_GV_INIT_CAP))",
        ),
    ]
    n = 0
    for a, b in pairs:
        if a in text:
            text = text.replace(a, b)
            n += 1
    # variant stride / base offsets still at 136+vi*128 if any left
    text2, c = re.subn(r"e\[136\s*\+\s*vi\s*\*\s*128", "e[264 + vi * 256", text)
    n += c
    text = text2
    text2, c = re.subn(r"\b33932\b", "66828", text)
    # careful: only if still present in enum contexts — may over-replace; check count
    # Limit: already replaced define; remaining 33932 likely enum-only
    n += c
    text = text2
    if text != orig:
        if apply:
            path.write_text(text, encoding="utf-8", errors="surrogateescape")
        reports.append(f"runtime_pipeline_abi.from_x.c enum: ~{n}")

    # pure side grow_vec 33932
    path = ROOT / "compiler/src/runtime_pipeline_abi.x"
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    orig = text
    text2, c = re.subn(
        r"grow_vec_init\(sc2 \+ \(208 as usize\), 33932, ic\)",
        "grow_vec_init(sc2 + (208 as usize), 66828, ic)",
        text,
    )
    if text2 != text and apply:
        path.write_text(text2, encoding="utf-8", errors="surrogateescape")
    if c:
        reports.append(f"runtime_pipeline_abi.x grow_vec enum elem: {c}")

    return reports


def patch_async_livevar(apply: bool) -> list[str]:
    reports = []
    path = ROOT / "compiler/src/asm/async_asm_pool.x"
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    orig = text
    pairs = [
        (
            "AsyncAsmPoolLiveVar: name[128]@0 name_len@128 size_bytes@132 frame_data_off@136; stride 140",
            "AsyncAsmPoolLiveVar: name[256]@0 name_len@256 size_bytes@260 frame_data_off@264; stride 268",
        ),
        (
            "live[64]@12 stride 140 (name[128], name_len@+128, size_bytes@+132, frame_data_off@+136)",
            "live[64]@12 stride 268 (name[256], name_len@+256, size_bytes@+260, frame_data_off@+264)",
        ),
        (
            "wave577 Cap: name[64]→[128]",
            "Cap 4.2.8: name[128]→[256]",
        ),
    ]
    for a, b in pairs:
        text = text.replace(a, b)
    # locals
    for nm in ("vbuf", "dname", "cur_nb"):
        text = re.sub(rf"\blet {nm}: u8\[128\]", f"let {nm}: u8[256]", text)
    # Layout sizeof comment 8976 — live[64]*140 + header. New: 64*268=17152 + header.
    # Header was 8976 - 64*140 = 8976 - 8960 = 16. New = 16 + 17152 = 17168.
    text = text.replace("sizeof AsyncAsmPoolLayout == 8976", "sizeof AsyncAsmPoolLayout == 17168")
    text = text.replace("await_stmt_idx@8972 i32; total 8976 bytes.", "await_stmt_idx@17164 i32; total 17168 bytes.")
    text = text.replace("must be at least 8976 bytes", "must be at least 17168 bytes")
    text = text.replace("while (zi < 8976)", "while (zi < 17168)")
    # LiveVar field peels if hardcoded
    text = re.sub(
        r"(live_base\s*\+\s*)128\b|name_len@\+128",
        lambda m: m.group(0).replace("128", "256") if False else m.group(0),
        text,
    )
    if text != orig and apply:
        path.write_text(text, encoding="utf-8", errors="surrogateescape")
    if text != orig:
        reports.append("async_asm_pool.x LiveVar comments/locals")

    path = ROOT / "compiler/include/async_asm_pool.h"
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    orig = text
    text = text.replace(
        "wave577 Cap: name[64]→[128] 与 AST name slot 128 对齐（避免 nlen∈(63,127] 时栈溢出）。",
        "Cap 4.2.8: name[128]→[256] aligned with AST name slots (content ≤255).",
    )
    # If layout size #define exists
    text = text.replace("8976", "17168")
    if text != orig and apply:
        path.write_text(text, encoding="utf-8", errors="surrogateescape")
    if text != orig:
        reports.append("async_asm_pool.h comments/size")
    return reports


def patch_typeck_more_locals(apply: bool) -> list[str]:
    """Bulk-widen remaining name-ish u8[128] locals in typeck.x."""
    path = ROOT / "compiler/src/typeck/typeck.x"
    text = path.read_text(encoding="utf-8", errors="surrogateescape")
    orig = text
    # Any let <ident>: u8[128] where ident contains name/nm/buf/field/layout/bind/label
    def repl(m: re.Match[str]) -> str:
        ident = m.group(1)
        if any(
            k in ident
            for k in (
                "name", "nm", "buf", "field", "layout", "bind", "label", "mangled",
                "hint", "elem", "fn_", "base", "method", "path_cnt", "cob", "layer",
                "decl", "exist", "lit", "dep", "alias", "type", "var", "goto",
            )
        ) and not any(k in ident for k in ("path_buf", "sync_path", "stem")):
            return f"let {ident}: u8[256]"
        return m.group(0)

    text2, c = re.subn(r"let ([A-Za-z_][A-Za-z0-9_]*)\s*:\s*u8\[128\]", repl, text)
    if text2 != orig and apply:
        path.write_text(text2, encoding="utf-8", errors="surrogateescape")
    return [f"typeck.x local widen ops~{c}"] if c else []


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()
    all_r: list[str] = []
    all_r += patch_typeck_parser_missed_caps(args.apply)
    all_r += patch_abi_name_n_caps(args.apply)
    all_r += patch_ast_depctx(args.apply)
    all_r += patch_scratch_and_enum_seed(args.apply)
    all_r += patch_async_livevar(args.apply)
    all_r += patch_typeck_more_locals(args.apply)
    mode = "APPLIED" if args.apply else "DRY-RUN"
    print(f"[{mode}]")
    for r in all_r:
        print(" ", r)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
