#!/usr/bin/env python3
"""
批量将 parser.x 中已有 C glue 的函数改为薄包装：
  extern function parser_xxx_glue(...): Ret;
  function xxx(...): Ret { return parser_xxx_glue(...); }

仅替换函数体，保留原有 /** 文档注释；已薄包装者跳过。
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PARSER_X = ROOT / "compiler/src/parser/parser.x"
THIN_C = ROOT / "compiler/src/asm/parser_asm_thin_c.c"

GLUE_RE = re.compile(r"\b((?:parser_\w+|compound_assign_token_to_expr_kind_from)_glue)\s*\(")


def glue_to_x(glue: str) -> str:
    """C glue 名映射到 parser.x 函数名。"""
    if glue == "compound_assign_token_to_expr_kind_from_glue":
        return "compound_assign_token_to_expr_kind_from"
    assert glue.startswith("parser_") and glue.endswith("_glue")
    return glue[len("parser_") : -len("_glue")]


def find_matching_brace(text: str, open_idx: int) -> int:
    """自 text[open_idx]=='{' 起找配对 '}' 下标（含嵌套）。"""
    depth = 0
    i = open_idx
    while i < len(text):
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def find_doc_start(text: str, fn_start: int) -> int:
    """若 function 前有 /** ... */ 文档块，返回文档起始下标。"""
    i = fn_start - 1
    while i >= 0 and text[i] in " \t\n\r":
        i -= 1
    if i < 0 or text[i] != "/":
        return fn_start
    j = i
    while j >= 0:
        if text[j : j + 3] == "/**":
            return j
        if text[j : j + 2] == "/*" and text[j : j + 3] != "/**":
            break
        j -= 1
    return fn_start


def find_func_region(name: str, text: str) -> tuple[int, int, str] | None:
    """定位 function name 的 [doc_start, end) 区域及块文本。

    优先 brace matching 闭合函数体；若至下一顶层 function 仍 depth>0
    （如 parse_primary_into 括号不平衡），则回退到下一 function 前边界。
    """
    pat = rf"(?m)^function {re.escape(name)}\s*\("
    m = re.search(pat, text)
    if not m:
        return None
    fn_start = m.start()
    doc_start = find_doc_start(text, fn_start)
    sig_tail = re.search(r"\)\s*:\s*[^{]+\{", text[m.start() :])
    if not sig_tail:
        return None
    body_open = m.start() + sig_tail.end() - 1
    next_m = re.search(r"(?m)^function ", text[m.end() :])
    next_fn_start = m.end() + next_m.start() if next_m else len(text)

    depth = 0
    end = -1
    for i in range(body_open, next_fn_start):
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end = i + 1
                break

    if end > 0:
        block = text[doc_start:end]
        if not block.endswith("\n"):
            block += "\n"
        return doc_start, end, block

    # 括号不平衡：截到下一 function 前的 doc/声明区之前
    chunk_end = find_doc_start(text, next_fn_start) if next_m else len(text)
    block = text[doc_start:chunk_end].rstrip() + "\n"
    return doc_start, doc_start + len(block), block


def is_thin_wrapper(block: str, x_name: str, glue: str) -> bool:
    """判断是否已是 extern+单行 glue 薄包装。"""
    if f"function {x_name}" not in block:
        return False
    if f"{glue}(" not in block:
        return False
    m = re.search(rf"function\s+{re.escape(x_name)}\s*\(.*?\)\s*:\s*[^{{]+\{{\s*(.*?)\s*\}}", block, re.S)
    if not m:
        return False
    body = m.group(1).strip()
    lines = [ln.strip() for ln in body.split("\n") if ln.strip() and not ln.strip().startswith("//")]
    if len(lines) > 2:
        return False
    return any(glue in ln for ln in lines)


def parse_signature(block: str) -> tuple[str, list[str], str] | None:
    """从 function 块解析 (name, param_names, ret_type)。"""
    m = re.search(r"^function\s+(\w+)\s*\((.*?)\)\s*:\s*([^{]+)\s*\{", block, re.S | re.M)
    if not m:
        return None
    fname, params_raw, ret = m.group(1), m.group(2), m.group(3).strip()
    params: list[str] = []
    cur = ""
    depth = 0
    for ch in params_raw:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == "," and depth == 0:
            if cur.strip():
                params.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        params.append(cur.strip())
    names = [p.split(":")[0].strip() for p in params if p.strip()]
    return fname, names, ret


def extract_user_doc(block: str) -> str:
    """提取 function 前的 /** 文档（若有）。"""
    dm = re.match(r"(/\*\*.*?\*/\s*)", block, re.S)
    return dm.group(1) if dm else ""


def make_wrapper(glue: str, block: str, x_name: str) -> str | None:
    """生成 extern 声明 + function 薄包装。"""
    sig = parse_signature(block)
    if not sig:
        return None
    fname, names, ret = sig
    if fname != x_name:
        return None
    call_args = ", ".join(names)
    sig_m = re.search(r"^function\s+\w+\s*\(.*?\)\s*:\s*[^{]+\s*\{", block, re.S | re.M)
    if not sig_m:
        return None
    sig_line = sig_m.group(0)[:-1].strip()  # 去掉 {
    func_decl = sig_line  # function xxx(...): Ret
    extern_decl = sig_line.replace(f"function {fname}", f"extern function {glue}", 1) + ";"
    if ret == "void":
        body_line = f"  {glue}({call_args});"
    else:
        body_line = f"  return {glue}({call_args});"
    user_doc = extract_user_doc(block)
    glue_doc = f"/** 单行 extern bl→{glue}（EMIT_HEAVY 深循环/兼容包装勿 X emit）。 */\n"
    if user_doc and "extern bl→" in user_doc:
        header = user_doc.rstrip() + "\n"
    elif user_doc:
        header = user_doc.rstrip() + "\n" + glue_doc
    else:
        header = glue_doc
    return header + extern_decl + "\n" + func_decl + " {\n" + body_line + "\n}\n"


def main() -> int:
    src = PARSER_X.read_text()
    thin_c = THIN_C.read_text()
    glue_names = sorted(set(GLUE_RE.findall(thin_c)))

    converted: list[str] = []
    skipped: list[str] = []
    missing: list[str] = []

    for glue in glue_names:
        x = glue_to_x(glue)
        region = find_func_region(x, src)
        if region is None:
            missing.append(x)
            continue
        doc_start, end, block = region
        if is_thin_wrapper(block, x, glue):
            skipped.append(x)
            continue
        new_block = make_wrapper(glue, block, x)
        if not new_block:
            skipped.append(f"{x} (parse fail)")
            continue
        src = src[:doc_start] + new_block + src[end:]
        converted.append(x)

    if "--dry-run" in sys.argv:
        print(f"Would convert {len(converted)}, skip {len(skipped)}, missing {len(missing)}")
        for c in converted:
            print(f"  + {c}")
        return 0

    PARSER_X.write_text(src)
    print(f"Converted: {len(converted)}")
    for c in converted:
        print(f"  + {c}")
    print(f"Skipped (already thin): {len(skipped)}")
    print(f"Missing in parser.x: {len(missing)}")
    for m in missing:
        print(f"  ? {m}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
