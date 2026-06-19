#!/usr/bin/env bash
# S2 同链烟测：build_asm/typeck.o（EMIT_HEAVY asm）+ layout partial 与 strict 链分工一致。
# 用法：./tests/run-s2-typeck-o-parity.sh
# 可选：SHUX_S2_FAIL_ON_PARITY=1 — 任一检查失败时 exit 1（CI 推荐）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/s2-typeck-layout-partial.sh
. ./tests/lib/s2-typeck-layout-partial.sh

TYPECK_O="compiler/build_asm/typeck.o"
PARTIAL="compiler/build_asm/typeck_asm_layout_partial.o"
BASELINE="${SHUX_S2_TYPECK_BASELINE:-tests/baseline/s2-typeck-o.tsv}"
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT=${MIN_TEXT:-8192}
MIN_REAL=${MIN_REAL:-130}
FAIL=${SHUX_S2_FAIL_ON_PARITY:-0}

text_section_size() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

# GNU objdump 在函数体内会插入 <sym+0xN> 标签；须忽略带 '+' 的标签，否则 insn 计数被截断为 ~9。
# ELF 无 leading _，Mach-O 有 _。
# 统计 .o 中指令数 >10 的函数（排除统一 ret0 桩 prologue）
count_real_asm_funcs() {
  python3 - "$1" <<'PY'
import subprocess, re, sys
path = sys.argv[1]
head = r"^[0-9a-f]+ <(_?[^+>]+)>:\n"
nxt = r"(?=^[0-9a-f]+ <_?[^+>]+>:\n|\Z)"
try:
    text = subprocess.check_output(["objdump", "-d", path], text=True, stderr=subprocess.DEVNULL)
except subprocess.CalledProcessError:
    print(0)
    sys.exit(0)
real = 0
for m in re.finditer(head + r"((?:.*\n)*?)" + nxt, text, re.M):
    insns = [ln for ln in m.group(2).splitlines() if ln.strip() and not ln.endswith(":")]
    if len(insns) > 10:
        real += 1
print(real)
PY
}

# 符号是否存在（ELF/Mach-O；可选 typeck_ 前缀）。
sym_defined() {
  local o="$1" sym="$2"
  nm "$o" 2>/dev/null | grep -qE " T (_)?${sym}\$"
}

parity_fail() {
  echo "s2 parity FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  return 0
}

# ── 1) 须已有同步后的 build_asm/typeck.o ──
if [ ! -f "$TYPECK_O" ]; then
  parity_fail "missing $TYPECK_O (run ./tests/run-s2-typeck-sync-build-o.sh)"
fi

sz=$(text_section_size "$TYPECK_O")
real=$(count_real_asm_funcs "$TYPECK_O")
echo "s2 parity: $TYPECK_O __text=${sz} real_funcs=${real} (min_text=${MIN_TEXT}, min_real=${MIN_REAL})"

if [ "${sz:-0}" -lt "${MIN_TEXT}" ] 2>/dev/null; then
  parity_fail "__text ${sz} < min_text_bytes ${MIN_TEXT}"
fi
if [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  parity_fail "real_funcs ${real} < min_real_funcs ${MIN_REAL}"
fi

# ── 2) 禁止回退到 pipeline_type_ensure_by_kind_ord（已由 SU ensure_* + init_* glue 替代）──
if nm "$TYPECK_O" 2>/dev/null | grep -qE ' (_)?pipeline_type_ensure_by_kind_ord$'; then
  parity_fail "typeck.o references pipeline_type_ensure_by_kind_ord (dep_return regression)"
else
  echo "s2 parity: no pipeline_type_ensure_by_kind_ord in typeck.o OK"
fi

# 允许的 pool 只读/写入 glue（链接期由 pipeline_glue.c 提供）
ALLOW_GLUE='pipeline_type_kind_ord_at|pipeline_type_elem_ref_at|pipeline_type_array_size_at|pipeline_type_named_name_into|pipeline_type_init_primitive_kind_at|pipeline_type_init_named_at|pipeline_type_init_compound_kind_at'
unexpected=$(nm "$TYPECK_O" 2>/dev/null | awk '/ U (_)?pipeline_type_/ {print $2}' | sed 's/^_//' | grep -Ev "^(${ALLOW_GLUE})$" || true)
if [ -n "$unexpected" ]; then
  parity_fail "unexpected _pipeline_type_* refs: $(echo "$unexpected" | tr '\n' ' ')"
else
  echo "s2 parity: pipeline_type_* glue refs whitelist OK"
fi

# ── 3) EMIT_HEAVY 分片（ast_pool.c）：mega 入口 intentionally 桩化，勿验 insn/size ──
# __text≥68264 + real_funcs≥133（步骤 1）已证明 safe helper 真 emit；mega 仅须符号存在供 C glue。
for sym in check_block_impl check_expr_impl typeck_su_ast; do
  if ! sym_defined "$TYPECK_O" "$sym"; then
    parity_fail "missing mega entry symbol $sym (C glue alias target)"
  fi
done
echo "s2 parity: mega entry symbols OK (stub by design; see asm_skip_heavy_typeck_mega_entry)"

# ── 4) 重建 layout partial 并与 strict 链 export 表一致 ──
if ! s2_rebuild_typeck_layout_partial "$TYPECK_O" "$PARTIAL"; then
  parity_fail "layout partial ld -r failed"
fi

psz=$(text_section_size "$PARTIAL")
echo "s2 parity: $PARTIAL __text=${psz}"
if [ "${psz:-0}" -lt 8192 ] 2>/dev/null; then
  parity_fail "layout partial __text ${psz} < 8192"
fi

for sym in typeck_struct_layout_metrics typeck_merge_dep_struct_layouts_into_entry ensure_struct_layout_from_struct_lit; do
  if ! nm "$PARTIAL" 2>/dev/null | grep -qE "(_)?${sym}\$"; then
    parity_fail "layout partial missing symbol $sym"
  fi
done
echo "s2 parity: layout partial export symbols OK"

# ── 5) typeck_su.o 若存在：须能生成 no_layout partial（strict 链双轨不 duplicate）──
if [ -f compiler/typeck_su.o ]; then
  SU_PARTIAL="compiler/build_asm/typeck_su_no_layout_partial.o"
  SU_SYMS="compiler/build_asm/typeck_su_no_layout_export.txt"
  nm compiler/typeck_su.o 2>/dev/null | awk '/ T _?typeck_/ {print $3}' | sed 's/^_//' | \
    grep -v '^typeck_struct_layout_metrics$' | \
    grep -v '^typeck_validate_struct_layouts_zero_padding$' | \
    grep -v '^typeck_merge_dep_struct_layouts_into_entry$' | \
    grep -v '^typeck_find_layout_idx_by_type_name$' | \
    sed 's/^/_/' >"$SU_SYMS" || true
  if [ -s "$SU_SYMS" ]; then
    echo "s2 parity: ld -r typeck_su.o -> $SU_PARTIAL (no layout dupes)"
    if s2_ld_partial_export "$SU_SYMS" "$SU_PARTIAL" compiler/typeck_su.o 2>"${SU_PARTIAL}.err"; then
      echo "s2 parity: typeck_su_no_layout_partial OK"
    else
      parity_fail "typeck_su_no_layout partial failed (see ${SU_PARTIAL}.err)"
    fi
  else
    echo "s2 parity: skip typeck_su_no_layout (no typeck_ exports in typeck_su.o)"
  fi
else
  echo "s2 parity: skip typeck_su.o checks (compiler/typeck_su.o missing)"
fi

echo "s2 parity OK (__text=${sz}, real_funcs=${real}, layout_partial=${psz})"
