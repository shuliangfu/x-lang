#!/usr/bin/env bash
# STD-054：std.test bench / fuzz 占位门禁
#
# 用法：./tests/run-std-test-bench-fuzz-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_TEST_BENCH_FUZZ_DOC:-analysis/std-test-bench-fuzz-v1.md}"
MANIFEST="${SHUX_STD_TEST_BENCH_FUZZ_TSV:-tests/baseline/std-test-bench-fuzz.tsv}"
VECTORS="${SHUX_STD_TEST_BENCH_FUZZ_VECTORS:-tests/baseline/std-test-bench-fuzz-vectors.tsv}"
MOD_SU="std/test/mod.sx"
TEST_C="std/test/test.c"
LIB="tests/lib/std-test-bench-fuzz.sh"
SMOKE_BENCH="tests/std-test/bench_smoke.sx"
SMOKE_FUZZ="tests/std-test/fuzz_smoke.sx"
SMOKE_REGRESS="tests/stdtest/main.sx"
SMOKE_C="tests/std-test/bench_fuzz_ok.c"
MIN_APIS=5

# shellcheck source=tests/lib/std-test-bench-fuzz.sh
. "$LIB"

echo "=== STD-054: test bench/fuzz manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$TEST_C" \
  "$SMOKE_BENCH" "$SMOKE_FUZZ" "$SMOKE_REGRESS" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-test-bench-fuzz gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-054 bench_run fuzz_seed SHUX_FUZZ_SEED; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-test-bench-fuzz gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'shux: [SHUX_BENCH]' "$VECTORS" 2>/dev/null; then
  echo "std-test-bench-fuzz gate FAIL: vectors missing bench line" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
        echo "std-test-bench-fuzz gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-test-bench-fuzz gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-test-bench-fuzz gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_test_bench_fuzz_symbols_ok "$MOD_SU" "$TEST_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_test_bench_fuzz_emit_report "fail" 0 0 0 0
  echo "std-test-bench-fuzz gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-test-bench-fuzz manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/test/test.o

C_OK=0
if std_test_bench_fuzz_run_c_smoke "$TEST_C"; then
  C_OK=1
else
  std_test_bench_fuzz_emit_report "fail" 0 0 0 0
  exit 1
fi

BENCH_OK=0
FUZZ_OK=0
SKIP=0
SHUX_BIN=""
stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-054: .sx smoke (SHUX=$SHUX_BIN) ==="
  for smoke in "$SMOKE_BENCH" "$SMOKE_FUZZ" "$SMOKE_REGRESS"; do
    if ! "$SHUX_BIN" check -L . "$smoke" >/dev/null 2>&1; then
      echo "std-test-bench-fuzz gate FAIL: typeck $smoke" >&2
      "$SHUX_BIN" check -L . "$smoke" 2>&1 | tail -10 >&2 || true
      std_test_bench_fuzz_emit_report "fail" "$C_OK" 0 0 0
      exit 1
    fi
  done
  if std_test_bench_fuzz_run_smoke "$SHUX_BIN" "$SMOKE_BENCH" "bench"; then
    BENCH_OK=1
  else
    std_test_bench_fuzz_emit_report "fail" "$C_OK" 0 0 0
    exit 1
  fi
  if std_test_bench_fuzz_run_smoke "$SHUX_BIN" "$SMOKE_FUZZ" "fuzz"; then
    FUZZ_OK=1
  else
    std_test_bench_fuzz_emit_report "fail" "$C_OK" "$BENCH_OK" 0 0
    exit 1
  fi
  if ! std_test_bench_fuzz_run_smoke "$SHUX_BIN" "$SMOKE_REGRESS" "regress"; then
    std_test_bench_fuzz_emit_report "fail" "$C_OK" "$BENCH_OK" "$FUZZ_OK" 0
    exit 1
  fi
else
  echo "std-test-bench-fuzz gate SKIP .sx smoke (no native shux)" >&2
  SKIP=1
fi

std_test_bench_fuzz_emit_report "ok" "$C_OK" "$BENCH_OK" "$FUZZ_OK" "$SKIP"
echo "std-test-bench-fuzz gate OK"
