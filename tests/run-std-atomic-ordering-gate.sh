#!/usr/bin/env bash
# STD-046：std.atomic 序语义与 fence 门禁
#
# 用法：./tests/run-std-atomic-ordering-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_ATOMIC_ORDERING_DOC:-analysis/std-atomic-ordering-v1.md}"
MANIFEST="${SHU_STD_ATOMIC_ORDERING_TSV:-tests/baseline/std-atomic-ordering.tsv}"
MOD_SU="std/atomic/mod.su"
ATOMIC_C="std/atomic/atomic.c"
LIB="tests/lib/std-atomic-ordering.sh"
SMOKE_SU="tests/atomic/ordering_fence.su"
MAIN_SU="tests/atomic/main.su"
MIN_APIS=3

# shellcheck source=tests/lib/std-atomic-ordering.sh
. "$LIB"

echo "=== STD-046: atomic ordering / fence manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$ATOMIC_C" "$SMOKE_SU" "$MAIN_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-atomic-ordering gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-046 ORDER_SEQ_CST fence_seq_cst memory_order_seq_cst LANG; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-atomic-ordering gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

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
        echo "std-atomic-ordering gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-atomic-ordering gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-atomic-ordering gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_atomic_ord_symbols_ok "$MOD_SU" "$ATOMIC_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_atomic_ord_emit_report "fail" 0 0 0
  echo "std-atomic-ordering gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-atomic-ordering manifest OK"

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

FENCE_OK=0
MAIN_OK=0
SKIP=1
if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
else
  SHU_BIN=""
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-046: typeck + smoke (SHU=$SHU_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/atomic/atomic.o
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-atomic-ordering gate FAIL: typeck $SMOKE_SU" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_atomic_ord_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_atomic_ord_run_smoke "$SHU_BIN" "$SMOKE_SU" "ordering"; then
    FENCE_OK=1
  else
    std_atomic_ord_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_atomic_ord_run_smoke "$SHU_BIN" "$MAIN_SU" "main"; then
    MAIN_OK=1
  else
    std_atomic_ord_emit_report "fail" "$FENCE_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-atomic-ordering gate SKIP smoke (no native shu)" >&2
fi

std_atomic_ord_emit_report "ok" "$FENCE_OK" "$MAIN_OK" "$SKIP"
echo "std-atomic-ordering gate OK"
