#!/usr/bin/env bash
# audit_static_limits.sh — 静态上限 vs 源侧规模（只读）
#
# 对照 MODULE_ENUM_MAX_VARIANTS / AST_ENUM_MAX_VARIANTS 与 .x 枚举变体数；
# 防止再出现「静默截断 → typeck found ?」类故障。
#
# 用法：bash compiler/scripts/audit_static_limits.sh
# 退出：0=通过；1=发现 enum 变体接近/超过 MODULE 硬顶（余量 <16）

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 1

MODULE_ENUM_MAX="$(
  rg -o 'MODULE_ENUM_MAX_VARIANTS[[:space:]]+[0-9]+' compiler/ast_pool.c \
    | head -1 | awk '{print $NF}'
)"
AST_ENUM_MAX="$(
  rg -o 'AST_ENUM_MAX_VARIANTS[[:space:]]+[0-9]+' compiler/include/ast.h \
    | head -1 | awk '{print $NF}'
)"
: "${MODULE_ENUM_MAX:=256}"
: "${AST_ENUM_MAX:=32}"

echo "=== 硬顶宏（热路径）==="
echo "MODULE_ENUM_MAX_VARIANTS=$MODULE_ENUM_MAX  (ast_pool ModuleEnumEntry, X 路径)"
echo "AST_ENUM_MAX_VARIANTS=$AST_ENUM_MAX  (ast.h 文档/legacy；无定长数组引用)"
echo ""

export MODULE_ENUM_MAX AST_ENUM_MAX
python3 - <<'PY'
from pathlib import Path
import re, sys, os, subprocess

mod_max = int(os.environ["MODULE_ENUM_MAX"])
ast_max = int(os.environ["AST_ENUM_MAX"])
root = Path("compiler/src")
rows = []
for p in sorted(root.rglob("*.x")):
    text = p.read_text(errors="ignore")
    for m in re.finditer(r"(?:export\s+)?enum\s+(\w+)\s*\{([^}]*)\}", text, re.S):
        name, body = m.group(1), m.group(2)
        vars_ = re.findall(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*(?:,|//|\n|$)", body, re.M)
        vars_ = [v for v in vars_ if v not in ("if", "else", "return", "while", "for")]
        if len(vars_) >= 8:
            rows.append((len(vars_), name, str(p)))
rows.sort(reverse=True)

print("=== compiler/src 大型 enum 变体数 ===")
print(f"{'n':>4}  {'enum':28s}  {'file':42s}  MODULE  AST_legacy")
fail = 0
for n, name, path in rows[:40]:
    if n >= mod_max:
        m_st = "OVER"
        fail = 1
    elif n >= mod_max - 16:
        m_st = "NEAR"
        fail = 1
    else:
        m_st = "OK"
    a_st = "OK" if n <= ast_max else "OVER_LEGACY"
    print(f"{n:4d}  {name:28s}  {path:42s}  {m_st:6s}  {a_st}")
if not rows:
    print("(no enums with >=8 variants found)")

print("")
print("=== 哨兵类（0 兼合法下标）— ast_pool.c 赋值条件 ===")
for pat, label in [
    (r"param_base\s*==\s*0", "param_base==0"),
    (r"field_base\s*==\s*0", "field_base==0"),
    (r"struct_lit_field_base\s*==\s*0", "struct_lit_field_base==0"),
]:
    r = subprocess.run(["rg", "-n", pat, "compiler/ast_pool.c"], capture_output=True, text=True)
    hits = [
        ln
        for ln in (r.stdout or "").splitlines()
        if ln.strip() and "禁止" not in ln and "兼作" not in ln
    ]
    print(f"{label}: {len(hits)} code hits")
    for h in hits[:6]:
        print(" ", h)

print("")
print("=== A 类硬顶（摘要）===")
print("  MODULE_ENUM_MAX_VARIANTS — 列表个数，静默失败已改诊断")
print("  AST_ENUM_MAX_VARIANTS=32 — legacy 文档常量，X 路径不读")
print("  SHUX_DRIVER_DEP_SLOT_MAX=32 — dep 图槽；撞顶再抬")
print("  name[64]/param[32] — 语义长度，不抬")
print("  详表：analysis/X侧车grow池与动态上限清单.md § 静默硬顶对表")
print("")

if fail:
    print(f"FAIL: enum NEAR/OVER MODULE_ENUM_MAX_VARIANTS={mod_max} (need headroom ≥16)")
    sys.exit(1)
print(f"OK: all scanned enums have ≥16 headroom under MODULE_ENUM_MAX_VARIANTS={mod_max}")
sys.exit(0)
PY
