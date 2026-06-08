#!/usr/bin/env bash
# S2 typeck SU 门禁（NEXT §2.2 S2 / P3）：typeck.su check + build_asm/typeck.o 非空 __text + 关键导出符号。
# 用法：./tests/run-s2-typeck-gate.sh
# 可选：SHU_S2_REQUIRE_TYPECK_O=1 — 无 typeck.o 时失败（CI 在 build_shu_asm 之后设置）
# 可选：SHU_S2_FAIL_ON_REGRESSION=1 — __text 低于 baseline min_text_bytes 时失败
# 可选：SHU_S2_UPDATE_BASELINE=1 — 将当前 __text 写入 tests/baseline/s2-typeck-o.tsv
set -e
cd "$(dirname "$0")/.."
make -C compiler shu-c -q 2>/dev/null || make -C compiler shu-c

SHU=${SHU:-./compiler/shu-c}
TYPECK_SU="compiler/src/typeck/typeck.su"
TYPECK_O="compiler/build_asm/typeck.o"
BASELINE="${SHU_S2_TYPECK_BASELINE:-tests/baseline/s2-typeck-o.tsv}"
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT=${MIN_TEXT:-1500}
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=${MIN_REAL:-0}

# 统计 .o 中指令数 >10 的函数（排除统一 ret0 桩 prologue）
# 统计 .o 中指令数 >10 的函数；忽略 objdump <sym+0xN> 内联标签（GNU ELF 否则截断 ~9 insn）
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
    body = m.group(2)
    insns = [ln for ln in body.splitlines() if ln.strip() and not ln.endswith(":")]
    if len(insns) > 10:
        real += 1
print(real)
PY
}

# ── 1) typeck.su 须能通过 C 前端 check（与 run-check-compiler 子集一致）──
out=$("$SHU" check "$TYPECK_SU" 2>&1) || {
  echo "$out"
  echo "s2 typeck gate: check failed on $TYPECK_SU"
  exit 1
}
if [ -n "$out" ]; then
  echo "s2 typeck gate: expected silent check on $TYPECK_SU, got: $out"
  exit 1
fi

# ── 2) build_asm/typeck.o：__text 非空 + 导出 typeck_su_ast / check_block ──
text_section_size() {
  local o="$1"
  [ -f "$o" ] || {
    echo 0
    return
  }
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && {
    echo 0
    return
  }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

if [ ! -f "$TYPECK_O" ]; then
  if [ "${SHU_S2_REQUIRE_TYPECK_O:-0}" = "1" ]; then
    echo "s2 typeck gate: missing $TYPECK_O (run: cd compiler && SHU=./shu ./scripts/build_shu_asm.sh)" >&2
    exit 1
  fi
  echo "s2 typeck gate OK (check only; $TYPECK_O missing — skip __text/symbol checks)"
  exit 0
fi

sz=$(text_section_size "$TYPECK_O")
echo "s2 typeck gate: $TYPECK_O __text size=$sz (min=$MIN_TEXT)"

if [ "${SHU_S2_UPDATE_BASELINE:-0}" = "1" ]; then
  {
    echo "# S2 typeck.o：build_asm/typeck.su 的 asm 产物 __text 下限（字节）"
    echo "# 更新：SHU_S2_UPDATE_BASELINE=1 ./tests/run-s2-typeck-gate.sh"
    printf 'min_text_bytes\t%s\n' "$sz"
  } >"$BASELINE"
  echo "s2 typeck gate: updated baseline min_text_bytes=$sz"
fi

if [ "${sz:-0}" -eq 0 ] 2>/dev/null; then
  echo "s2 typeck gate FAIL: empty __text in $TYPECK_O" >&2
  exit 1
fi

if [ "${SHU_S2_FAIL_ON_REGRESSION:-0}" = "1" ] || [ "${SHU_S2_REQUIRE_TYPECK_O:-0}" = "1" ]; then
  if ! awk -v s="$sz" -v m="$MIN_TEXT" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
    echo "s2 typeck gate FAIL: __text $sz < min_text_bytes $MIN_TEXT" >&2
    exit 1
  fi
fi

# 关键 SU typeck 入口须在 .o 中可见（非仅 C glue 桩）；ELF 无 leading _，Mach-O 有 _。
for sym in typeck_su_ast check_block; do
  if ! nm "$TYPECK_O" 2>/dev/null | grep -qE "(_)?${sym}\$"; then
    echo "s2 typeck gate FAIL: missing symbol $sym in $TYPECK_O" >&2
    exit 1
  fi
done

real=$(count_real_asm_funcs "$TYPECK_O")
echo "s2 typeck gate: real_funcs=${real} (min_real_funcs=${MIN_REAL}, ret0-stub if 0)"

if [ "${real:-0}" -eq 0 ] 2>/dev/null; then
  echo "s2 typeck gate: note — typeck.o 仍为 SKIP 桩；运行 ./tests/run-s2-typeck-sync-build-o.sh 写入 EMIT_HEAVY 产物"
elif [ "${sz:-0}" -ge 8192 ] 2>/dev/null; then
  echo "s2 typeck gate: typeck.o EMIT_HEAVY selfhosted (__text>=8192, real_funcs=${real})"
fi

if [ "${SHU_S2_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "${MIN_REAL:-0}" -gt 0 ] 2>/dev/null; then
  if [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
    echo "s2 typeck gate FAIL: real_funcs ${real} < min_real_funcs ${MIN_REAL}" >&2
    exit 1
  fi
fi

echo "s2 typeck gate OK (__text=${sz}, real_funcs=${real}, symbols=typeck_su_ast+check_block)"
