#!/usr/bin/env python3
"""
重建 ast_pool.c 中 parser EMIT_HEAVY 第二遍基础设施：
  k_asm_parser_thin_delegate、mega/force_stub/safe_helper、typeck 误判修复、emit 路径。

用法：python3 compiler/scripts/rebuild_parser_emit_heavy_ast_pool.py [--emit-tail return0|return1]
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AST_POOL = ROOT / "compiler/ast_pool.c"
THIN_C = ROOT / "compiler/src/asm/parser_asm_thin_c.c"
PARSER_SU = ROOT / "compiler/src/parser/parser.su"

# glue 名 → parser.su 函数名（自动生成 su 名与 module 表不一致时手工覆盖）
GLUE_SU_OVERRIDE: dict[str, str] = {
    "parser_lex_copy_from_import_into_glue": "copy_lex_from_import_into",
    "parser_token_is_label_start_glue": "parser_token_is_label_start",
    "parser_struct_field_name_tok_kind_i32_glue": "struct_field_name_tok_kind",
    "parser_struct_field_continues_tok_kind_i32_glue": "struct_field_continues_tok_kind",
    "parser_struct_field_continues_align_kind_i32_glue": "struct_field_continues_align_kind",
    "parser_try_skip_allow_padding_struct_value_glue": "try_skip_allow_padding_struct",
    "parser_try_skip_allow_padding_struct_buf_value_glue": "try_skip_allow_padding_struct_buf",
}

# 移出 delegate → SU 真 emit（小体 compat；2026-06-14 稳定试点）
SU_EMIT_OUT = {
    "parse_into_set_main_index",
    "pipeline_module_reset_parse_counters",
    "collect_imports_buf",
    "lex_from_next_into",
    "parse_one_function_library_buf",
    "copy_lex_from_import_into",
    "expr_set_common_zeros",
}

HELPER_BLOCK = r'''
/** parser EMIT_HEAVY 第二遍：槽位 fallback 上限（>8 易 Segfault；2026-06-13bj）。 */
#define ASM_EMIT_HEAVY_PARSER_SLOT_MAX 8

/**
 * parser.su EMIT_HEAVY 第二遍：巨型 parse_into/expr 入口 ret0 桩（strict 链由 parser.o / C alias 提供）。
 */
static int32_t asm_skip_heavy_parser_mega_entry(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_selfhost(m))
    return 0;
#define PARSER_MEGA_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
#define PARSER_MEGA_PFX(pfx, plen)                                                                                     \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  PARSER_MEGA_EQ("parse_into_buf", 14);
  PARSER_MEGA_EQ("parse_into", 10);
  PARSER_MEGA_EQ("parse", 5);
  PARSER_MEGA_EQ("parse_one_function_impl", 23);
  PARSER_MEGA_EQ("parse_expr_into", 15);
  PARSER_MEGA_EQ("parse_block_into", 16);
  PARSER_MEGA_EQ("parse_body_lets_into", 20);
  PARSER_MEGA_EQ("parse_if_stmt_into", 18);
  PARSER_MEGA_EQ("parse_if_expr_into", 18);
  PARSER_MEGA_EQ("parse_match_into", 16);
  PARSER_MEGA_EQ("parse_match_subject_into", 24);
  PARSER_MEGA_EQ("parse_at_simd_builtin_into", 26);
  PARSER_MEGA_EQ("finish_struct_lit_from_type_ident_into", 38);
  PARSER_MEGA_PFX("parse_primary", 13);
  PARSER_MEGA_PFX("parse_unary", 11);
  PARSER_MEGA_PFX("parse_as_suffix", 15);
  PARSER_MEGA_PFX("parse_cast", 10);
  PARSER_MEGA_PFX("parse_term", 10);
  PARSER_MEGA_PFX("parse_addsub", 12);
  PARSER_MEGA_PFX("parse_shift", 11);
  PARSER_MEGA_PFX("parse_relcompare", 16);
  PARSER_MEGA_PFX("parse_compare", 13);
  PARSER_MEGA_PFX("parse_bitand", 12);
  PARSER_MEGA_PFX("parse_bitxor", 12);
  PARSER_MEGA_PFX("parse_bitor", 11);
  PARSER_MEGA_PFX("parse_logand", 12);
  PARSER_MEGA_PFX("parse_logor", 11);
  PARSER_MEGA_PFX("parse_ternary", 13);
  PARSER_MEGA_PFX("parse_assign", 12);
#undef PARSER_MEGA_EQ
#undef PARSER_MEGA_PFX
  return 0;
}

/**
 * parser EMIT_HEAVY 第二遍：须 ret0 桩（SU 真 emit Segfault / code_len 爆炸）；勿 safe_helper 白名单。
 */
static int32_t asm_parser_emit_heavy_force_stub(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_selfhost(m))
    return 0;
#define PARSER_STUB_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
#define PARSER_STUB_PFX(pfx, plen)                                                                                     \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  PARSER_STUB_PFX("copy_onefunc_", 13);
  PARSER_STUB_PFX("copy_lex_from_import", 20);
  PARSER_STUB_EQ("wrap_block_ref_as_expr", 22);
  PARSER_STUB_EQ("parser_alloc_true_bool_lit", 26);
  PARSER_STUB_EQ("parser_expr_wrap_in_return", 26);
  PARSER_STUB_EQ("parse_peek_function_name_buf", 28);
  PARSER_STUB_EQ("try_skip_allow_padding_struct", 29);
  PARSER_STUB_EQ("try_skip_allow_padding_struct_buf", 33);
#undef PARSER_STUB_EQ
#undef PARSER_STUB_PFX
  return 0;
}

/**
 * parser EMIT_HEAVY 第二遍：按名判定可安全 SU 真 emit 的小 helper（扩 __text；名长须与 module 表一致）。
 */
static int32_t asm_parser_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_selfhost(m))
    return 0;
#define PARSER_SAFE_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
  PARSER_SAFE_EQ("lexer_token_run_len_kind", 24);
  PARSER_SAFE_EQ("lexer_token_run_len", 19);
  PARSER_SAFE_EQ("lexer_token_run_len_async_i32", 29);
  PARSER_SAFE_EQ("struct_field_name_soa_kind", 26);
  PARSER_SAFE_EQ("struct_field_continues_soa_kind", 31);
  PARSER_SAFE_EQ("struct_field_continues_align_kind", 33);
  PARSER_SAFE_EQ("struct_field_name_from_tok", 26);
  PARSER_SAFE_EQ("struct_field_name_tok_kind", 26);
  PARSER_SAFE_EQ("struct_field_continues_tok_kind", 31);
  PARSER_SAFE_EQ("lex_at_token_from_result", 24);
  PARSER_SAFE_EQ("parser_rewind_lex_for_following_stmt", 36);
  PARSER_SAFE_EQ("extern_parse_set_fail", 21);
  PARSER_SAFE_EQ("extern_parse_pool_ptr", 21);
  PARSER_SAFE_EQ("is_compound_assign_token", 24);
#undef PARSER_SAFE_EQ
  return 0;
}

/** 槽位 fallback：小体 SU 真 emit（>ASM_EMIT_HEAVY_PARSER_SLOT_MAX 仍桩化）。 */
static int32_t asm_parser_emit_heavy_slot_fallback_ok(struct ast_ASTArena *arena, int32_t body_ref, int32_t slots) {
  (void)arena;
  if (body_ref <= 0)
    return 0;
  return slots <= ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
}

/** 查 func 是否在 k_asm_parser_thin_delegate 表（EMIT_HEAVY bl→C glue）。 */
static int32_t asm_parser_func_is_thin_delegate(struct ast_Module *m, int32_t func_index) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !asm_module_is_parser_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_parser_thin_delegate) / sizeof(k_asm_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_parser_thin_delegate[i].su_name,
                                           k_asm_parser_thin_delegate[i].su_len))
      return 1;
  }
  return 0;
}

'''


def build_delegate_rows() -> list[tuple[str, int, str, int]]:
    """从 parser_asm_thin_c.c 生成 delegate 表行。"""
    thin_c = THIN_C.read_text()
    parser_funcs = set(re.findall(r"(?m)^(?:extern\s+)?function\s+(\w+)\s*\(", PARSER_SU.read_text()))
    pat = re.compile(r"^(?:void|int32_t|struct parser_asm_\w+)\s+(parser_[a-zA-Z0-9_]+_glue)\s*\(", re.M)
    thin_names = set(pat.findall(thin_c))
    rows: list[tuple[str, int, str, int]] = []
    for c in sorted(thin_names):
        su = GLUE_SU_OVERRIDE.get(c, c[len("parser_") : -len("_glue")])
        if su not in parser_funcs:
            print(f"WARN: skip glue {c} (no function {su} in parser.su)", file=sys.stderr)
            continue
        rows.append((su, len(su), c, len(c)))
    for extra in (
        ("pipeline_module_reset_parse_counters", 36, "pipeline_module_reset_parse_counters_c", 38),
        ("parse_into_set_main_index", 25, "pipeline_module_set_main_func_index", 35),
    ):
        if extra[0] not in {r[0] for r in rows}:
            rows.insert(0, extra)
    return [r for r in rows if r[0] not in SU_EMIT_OUT]


def emit_parser_block(tail: str) -> str:
    """生成 asm_skip_heavy 中 parser 分支。"""
    tail_line = "return 0;" if tail == "return0" else "return 1;"
    return f'''    /**
     * parser.su EMIT_HEAVY 第二遍：mega/force_stub ret0 桩；thin delegate bl→C glue；
     * 其余 {tail_line.replace("return ", "").replace(";", "（扩 __text）。")}
     */
    if (asm_module_is_parser_selfhost(m)) {{
      if (asm_skip_heavy_parser_mega_entry(m, func_index) != 0)
        return 1;
      if (asm_parser_emit_heavy_force_stub(m, func_index) != 0)
        return 1;
      if (asm_parser_func_is_thin_delegate(m, func_index) != 0)
        return 1;
      {tail_line}
    }}'''


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--emit-tail", choices=("return0", "return1"), default="return1")
    args = ap.parse_args()

    rows = build_delegate_rows()
    delegate_lines = ["static const AsmBackendThinDelegateRow k_asm_parser_thin_delegate[] = {"]
    for su, sl, c, cl in rows:
        delegate_lines.append(f'    {{"{su}", {sl}, "{c}", {cl}}},')
    delegate_lines.append("};")

    text = AST_POOL.read_text()

    text = text.replace(
        "  if (!m || m->num_funcs < 150 || m->num_funcs > 320)\n    return 0;",
        "  if (!m || m->num_funcs < 150 || m->num_funcs > 1450)\n    return 0;",
        1,
    )

    old_typeck = '''static int32_t asm_module_is_typeck_selfhost(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 40)
    return 0;
  if (pipeline_module_func_name_equal_at(m, 0, (uint8_t *)"type_kind_ordinal", 17))
    return 1;'''
    new_typeck = '''static int32_t asm_module_is_typeck_selfhost(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 40)
    return 0;
  /** parser.su ndef≈130–200 勿落入下方 75–155 启发式（误判则走 typeck EMIT 路径）。 */
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_init", 15))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"skip_one_struct_into_buf", 24))
      return 0;
  }
  if (pipeline_module_func_name_equal_at(m, 0, (uint8_t *)"type_kind_ordinal", 17))
    return 1;'''
    if old_typeck not in text:
        print("ERROR: typeck block not found (already patched?)", file=sys.stderr)
        return 1
    text = text.replace(old_typeck, new_typeck, 1)

    # 替换 delegate 块（兼容已 patch / bisect 注释）
    m = re.search(
        r"/\*\* M8-tail：parser\.su.*?\nstatic const AsmBackendThinDelegateRow k_asm_parser_thin_delegate\[\] = \{.*?\n\};\n",
        text,
        re.S,
    )
    if not m:
        print("ERROR: k_asm_parser_thin_delegate block not found", file=sys.stderr)
        return 1
    new_delegate = (
        "/** M8-tail：parser.su 薄包装 SU 名 → parser_asm_thin_c.c *_glue（EMIT_HEAVY 第二遍 bl 扩 __text）。\n"
        " * SU 真 emit（不在表内）：parse_into_set_main_index / pipeline_module_reset_parse_counters /\n"
        " * collect_imports_buf / lex_from_next_into / parse_one_function_library_buf / copy_lex_from_import_into /\n"
        " * expr_set_common_zeros */\n"
        + "\n".join(delegate_lines)
        + "\n\n"
        + HELPER_BLOCK
    )
    text = text[: m.start()] + new_delegate + text[m.end() :]

    AST_POOL.write_text(text)
    print(f"OK: {len(rows)} delegate rows, emit_tail={args.emit_tail}")
    return 0
    parser_pat = re.compile(
        r"    /\*\*\n     \* parser\.su.*?\n     \*/\n    if \(asm_module_is_parser_selfhost\(m\)\) \{.*?\n    \}",
        re.S,
    )
    if not parser_pat.search(text):
        old_simple = '''    /**
     * parser.su：parse_into_* mega 全桩；reset/set_main 等小 helper 经 k_asm_parser_thin_delegate bl→C。
     */
    if (asm_module_is_parser_selfhost(m))
      return 1;'''
        if old_simple not in text:
            print("ERROR: parser EMIT_HEAVY block not found", file=sys.stderr)
            return 1
        text = text.replace(old_simple, emit_parser_block(args.emit_tail), 1)
    else:
        text = parser_pat.sub(emit_parser_block(args.emit_tail), text, count=1)

    AST_POOL.write_text(text)
    print(f"OK: {len(rows)} delegate rows, emit_tail={args.emit_tail}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
