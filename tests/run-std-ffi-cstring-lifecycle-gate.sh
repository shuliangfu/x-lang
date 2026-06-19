#!/usr/bin/env bash
# STD-055：std.ffi CString 生命周期与错误码门禁
#
# 用法：./tests/run-std-ffi-cstring-lifecycle-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_FFI_CSTRING_DOC:-analysis/std-ffi-cstring-lifecycle-v1.md}"
MANIFEST="${SHUX_STD_FFI_CSTRING_TSV:-tests/baseline/std-ffi-cstring-lifecycle.tsv}"
VECTORS="${SHUX_STD_FFI_CSTRING_VECTORS:-tests/baseline/std-ffi-cstring-lifecycle-vectors.tsv}"
MOD_SU="std/ffi/mod.sx"
FFI_C="std/ffi/ffi.c"
LIB="tests/lib/std-ffi-cstring-lifecycle.sh"
SMOKE_SU="tests/std-ffi/cstring_try_new.sx"
SMOKE_C="tests/std-ffi/cstring_lifecycle_ok.c"
SAFE_HOOK="tests/run-safe-ffi-contract-gate.sh"
MIN_APIS=4

# shellcheck source=tests/lib/std-ffi-cstring-lifecycle.sh
. "$LIB"

echo "=== STD-055: ffi cstring lifecycle manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$FFI_C" "$SMOKE_SU" "$SMOKE_C" "$SAFE_HOOK"; do
  if [ ! -f "$f" ]; then
    echo "std-ffi-cstring gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-055 FFI_ERR_OOM cstring_try_new TYPE-004; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-ffi-cstring gate FAIL: doc missing '$kw'" >&2
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
        echo "std-ffi-cstring gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-ffi-cstring gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-ffi-cstring gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_ffi_cstring_symbols_ok "$MOD_SU" "$FFI_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_ffi_cstring_emit_report "fail" 0 0 0 0
  echo "std-ffi-cstring gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-ffi-cstring manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/ffi/ffi.o

C_OK=0
if std_ffi_cstring_run_c_smoke "$FFI_C"; then
  C_OK=1
else
  std_ffi_cstring_emit_report "fail" 0 0 0 0
  exit 1
fi

SU_OK=0
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
  echo "=== STD-055: .sx smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-ffi-cstring gate FAIL: typeck $SMOKE_SU" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_ffi_cstring_emit_report "fail" "$C_OK" 0 0 0
    exit 1
  fi
  if std_ffi_cstring_run_smoke "$SHUX_BIN" "$SMOKE_SU" "try"; then
    SU_OK=1
  else
    std_ffi_cstring_emit_report "fail" "$C_OK" 0 0 0
    exit 1
  fi
else
  echo "std-ffi-cstring gate SKIP .sx smoke (no native shux)" >&2
  SKIP=1
fi

SAFE_OK=0
echo "=== STD-055: SAFE-004 regression ==="
if chmod +x "$SAFE_HOOK" && "$SAFE_HOOK" >/tmp/std_ffi_safe004_regress.log 2>&1; then
  if grep -q 'safe-ffi-contract gate OK' /tmp/std_ffi_safe004_regress.log; then
    SAFE_OK=1
  fi
fi
if [ "$SAFE_OK" -ne 1 ]; then
  tail -15 /tmp/std_ffi_safe004_regress.log >&2 || true
  std_ffi_cstring_emit_report "fail" "$C_OK" "$SU_OK" 0 "$SKIP"
  echo "std-ffi-cstring gate FAIL: SAFE-004 regression" >&2
  exit 1
fi

std_ffi_cstring_emit_report "ok" "$C_OK" "$SU_OK" "$SAFE_OK" "$SKIP"
echo "std-ffi-cstring gate OK"
