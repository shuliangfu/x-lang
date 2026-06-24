#!/usr/bin/env bash
# S3 driver 同链烟测：build_asm/driver_compile_link.o 须导出 driver_run_compiler_full_sx 且含 SX parse_argv。
# 用法：./tests/run-s3-driver-o-parity.sh
# 前置：./tests/run-s3-driver-sync-build-o.sh
# 可选：SHUX_S3_FAIL_ON_PARITY=1 — 任一检查失败时 exit 1
set -e
cd "$(dirname "$0")/.."
DRIVER_ASM_O="compiler/build_asm/driver_compile.o"
DRIVER_LINK_O="compiler/build_asm/driver_compile_link.o"
BASELINE="${SHUX_S3_DRIVER_EMIT_BASELINE:-tests/baseline/s3-driver-o.tsv}"
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT=${MIN_TEXT:-256}
MIN_REAL=${MIN_REAL:-0}
FAIL=${SHUX_S3_FAIL_ON_PARITY:-0}

text_section_size() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

count_real_asm_funcs() {
  python3 - "$1" <<'PY'
import subprocess, re, sys
path = sys.argv[1]
try:
    text = subprocess.check_output(["objdump", "-d", path], text=True, stderr=subprocess.DEVNULL)
except subprocess.CalledProcessError:
    print(0)
    sys.exit(0)
real = 0
for m in re.finditer(r"^[0-9a-f]+ <(_[^>]+)>:\n((?:.*\n)*?)(?=\n[0-9a-f]+ <_|\Z)", text, re.M):
    insns = [ln for ln in m.group(2).splitlines() if ln.strip() and not ln.endswith(":")]
    if len(insns) > 10:
        real += 1
print(real)
PY
}

parity_fail() {
  echo "s3 driver parity FAIL: $*" >&2
  if [ "$FAIL" = "1" ]; then
    exit 1
  fi
}

if [ ! -f "$DRIVER_ASM_O" ]; then
  parity_fail "missing $DRIVER_ASM_O (run ./tests/run-s3-driver-sync-build-o.sh)"
  echo "s3 driver parity SKIP (no asm object)"
  exit 0
fi

if [ ! -f "$DRIVER_LINK_O" ]; then
  parity_fail "missing $DRIVER_LINK_O (sync should build driver_compile_link.o)"
  echo "s3 driver parity SKIP (no link object)"
  exit 0
fi

asm_sz=$(text_section_size "$DRIVER_ASM_O")
asm_real=$(count_real_asm_funcs "$DRIVER_ASM_O")
echo "s3 driver parity: $DRIVER_ASM_O __text=${asm_sz} real_funcs=${asm_real} (min_text=${MIN_TEXT}, min_real=${MIN_REAL})"

if [ "${asm_sz:-0}" -lt "${MIN_TEXT}" ] 2>/dev/null; then
  parity_fail "__text ${asm_sz} < min_text_bytes ${MIN_TEXT}"
fi
if [ "${MIN_REAL:-0}" -gt 0 ] && [ "${asm_real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  parity_fail "real_funcs ${asm_real} < min_real_funcs ${MIN_REAL}"
fi

for sym in driver_run_compiler_full_sx driver_compile_dispatch_asm_backend driver_compile_dispatch_emit_c_path; do
  if ! nm "$DRIVER_LINK_O" 2>/dev/null | grep -q " T _${sym}$"; then
    parity_fail "$DRIVER_LINK_O missing symbol $sym"
  fi
done
echo "s3 driver parity: link.o exports driver_run_compiler_full_sx + dispatch_*"

if ! nm "$DRIVER_LINK_O" 2>/dev/null | grep -q ' T _driver_compile_parse_argv$'; then
  parity_fail "$DRIVER_LINK_O missing driver_compile_parse_argv (asm argv chain)"
fi
echo "s3 driver parity: driver_compile_parse_argv present in link.o"

echo "s3 driver parity OK (__text=${asm_sz}, real_funcs=${asm_real})"
