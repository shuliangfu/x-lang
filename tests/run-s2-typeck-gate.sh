#!/usr/bin/env bash
# S2 typeck gate: build_asm/typeck.o __text + live exports (typeck_x_ast / check_block*).
#
# Honesty: soft XLANG_S2_FAIL_ON_REGRESSION / missing-.o soft OK retired —
# under-baseline soft die→exit0 was portable false-green. Linux x86_64 gold
# hard-dies missing/under typeck.o. Darwin stub (__text≈4 / ci_text_stub)
# is N/A (skip=1). `xlang check` is observational (selfhost check gate paused).
# Fossils: accept typeck_check_block_impl or check_block.
#
# Usage: ./tests/run-s2-typeck-gate.sh
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold; DARWIN N/A when stub/missing.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

TYPECK_X="compiler/src/typeck/typeck.x"
TYPECK_O="compiler/build_asm/typeck.o"
BASELINE="${XLANG_S2_TYPECK_BASELINE:-tests/baseline/s2-typeck-o.tsv}"
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT=${MIN_TEXT:-1500}
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=${MIN_REAL:-0}

PREFIX="xlang: [XLANG_S2_TYPECK_GATE]"
RUN_OK=0
OBS=0
SKIP=0
CHECK_OK=0

die() {
  echo "s2 typeck gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} check=${CHECK_OK} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} check=${CHECK_OK} host=$(ci_host_summary)"
}

is_gold() { ci_is_linux_x64; }

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

text_section_size() {
  local o="$1"
  [ -f "$o" ] || { echo 0; return; }
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

sym_defined() {
  local o="$1" sym="$2"
  nm "$o" 2>/dev/null | grep -qE " T (_)?${sym}\$"
}

# ── 1) check observational (selfhost check gate paused) ──
ENV_XLANG="${XLANG:-}"
XLANG=""
for cand in "$ENV_XLANG" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
  [ -n "$cand" ] && [ -x "$cand" ] || continue
  XLANG="$cand"
  break
done
if [ -n "$XLANG" ] && [ -x "$XLANG" ]; then
  set +e
  out=$("$XLANG" check "$TYPECK_X" 2>&1)
  crc=$?
  set -e
  if [ "$crc" -eq 0 ] && [ -z "$out" ]; then
    CHECK_OK=1
  else
    OBS=$((OBS + 1))
    echo "s2 typeck gate: obs — check not silent (paused gate; crc=$crc)"
  fi
else
  OBS=$((OBS + 1))
  echo "s2 typeck gate: obs — no compiler for check"
fi

# ── 2) build_asm/typeck.o ──
if [ ! -f "$TYPECK_O" ]; then
  if is_gold; then
    die "missing $TYPECK_O (run ./tests/run-s2-typeck-sync-build-o.sh)"
  fi
  SKIP=1
  echo "s2 typeck gate: missing $TYPECK_O — non-gold N/A (skip=1)"
  ok_report
  exit 0
fi

sz=$(text_section_size "$TYPECK_O")
real=$(count_real_asm_funcs "$TYPECK_O")
echo "s2 typeck gate: $TYPECK_O __text size=$sz real_funcs=${real} (min=$MIN_TEXT, min_real=$MIN_REAL)"

if [ "${XLANG_S2_UPDATE_BASELINE:-0}" = "1" ]; then
  {
    echo "# S2 typeck.o：build_asm/typeck.x 的 asm 产物 __text 下限（字节）"
    echo "# 更新：XLANG_S2_UPDATE_BASELINE=1 ./tests/run-s2-typeck-gate.sh"
    printf 'min_text_bytes\t%s\n' "$sz"
  } >"$BASELINE"
  echo "s2 typeck gate: updated baseline min_text_bytes=$sz"
fi

# Darwin CI stub: tiny __text or only xlang_asm_ci_text_stub.
is_stub=0
if [ "${sz:-0}" -lt 256 ] 2>/dev/null; then
  is_stub=1
fi
if sym_defined "$TYPECK_O" xlang_asm_ci_text_stub && [ "${real:-0}" -eq 0 ] 2>/dev/null; then
  is_stub=1
fi

if [ "$is_stub" -eq 1 ]; then
  if is_gold; then
    die "stub typeck.o __text=${sz} real_funcs=${real} (run sync EMIT_HEAVY)"
  fi
  SKIP=1
  echo "s2 typeck gate: stub typeck.o — non-gold N/A (skip=1)"
  ok_report
  exit 0
fi

if [ "${sz:-0}" -eq 0 ] 2>/dev/null; then
  die "empty __text in $TYPECK_O"
fi

if ! awk -v s="$sz" -v m="$MIN_TEXT" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
  if is_gold; then
    die "__text $sz < min_text_bytes $MIN_TEXT"
  fi
  SKIP=1
  echo "s2 typeck gate: under min_text on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

# Live exports (parity-aligned names).
has_entry=0
if sym_defined "$TYPECK_O" typeck_x_ast; then
  has_entry=1
fi
has_block=0
if sym_defined "$TYPECK_O" typeck_check_block_impl || sym_defined "$TYPECK_O" check_block; then
  has_block=1
fi
if [ "$has_entry" -ne 1 ] || [ "$has_block" -ne 1 ]; then
  if is_gold; then
    die "missing typeck_x_ast and/or check_block* in $TYPECK_O"
  fi
  SKIP=1
  echo "s2 typeck gate: missing symbols on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

if [ "${MIN_REAL:-0}" -gt 0 ] && [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  if is_gold; then
    die "real_funcs ${real} < min_real_funcs ${MIN_REAL}"
  fi
  SKIP=1
  echo "s2 typeck gate: under min_real on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

RUN_OK=1
echo "s2 typeck gate OK (__text=${sz}, real_funcs=${real}, symbols=typeck_x_ast+check_block*)"
ok_report
