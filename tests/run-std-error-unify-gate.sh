#!/usr/bin/env bash
# STD-011：标准库错误码统一 manifest 门禁
#
# 1) std-error-unify-v1.md + matrix
# 2) error_base_* / <mod>_err_* 符号；sidecar 存在
# 3) native shux：tests/std/error_unify_smoke.sx
#
# 用法：./tests/run-std-error-unify-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_ERROR_UNIFY_DOC:-analysis/std-error-unify-v1.md}"
MATRIX="${SHUX_STD_ERROR_UNIFY_TSV:-tests/baseline/std-error-unify.tsv}"
ERR_MOD="${SHUX_STD_ERROR_MOD:-std/error/mod.sx}"
MIN_MOD=6
SMOKE="tests/std/error_unify_smoke.sx"

native_shu() {
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

echo "=== STD-011: std error unify manifest ==="
for f in \
  "$DOC" \
  "$MATRIX" \
  "$ERR_MOD" \
  analysis/exc-error-code-layer-v1.md \
  analysis/exc-result-error-v1-rfc.md; do
  if [ ! -f "$f" ]; then
    echo "std-error-unify gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_modules) MIN_MOD="$c2" ;; esac
done < "$MATRIX"

MISS=0
MOD_N=0
echo "=== STD-011: module matrix ==="
while IFS=$'\t' read -r module_id exc_layer base_fn sidecar_fn src tier notes; do
  [ -z "${module_id:-}" ] && continue
  case "$module_id" in \#*|min_modules|global_codes|sidecar_*|symbol_*|smoke_case) continue ;; esac
  MOD_N=$((MOD_N + 1))
  if [ ! -f "$src" ]; then
    echo "std-error-unify FAIL: missing src $src ($module_id)" >&2
    MISS=$((MISS + 1))
    continue
  fi
  if [ -n "$base_fn" ] && [ "$base_fn" != "-" ]; then
    if ! grep -qE "function ${base_fn}\\(" "$ERR_MOD" 2>/dev/null; then
      echo "std-error-unify FAIL: missing ${base_fn} in $ERR_MOD ($module_id)" >&2
      MISS=$((MISS + 1))
    fi
  fi
  if [ -n "$sidecar_fn" ] && [ "$sidecar_fn" != "-" ]; then
    if ! grep -qE "function ${sidecar_fn}\\(" "$src" 2>/dev/null; then
      echo "std-error-unify FAIL: missing sidecar ${sidecar_fn} in $src" >&2
      MISS=$((MISS + 1))
    fi
  fi
  echo "std-error-unify OK module $module_id ($exc_layer)"
done < "$MATRIX"

# global + symbols
while IFS=$'\t' read -r module_id exc_layer base_fn sidecar_fn src tier notes; do
  [ -z "${module_id:-}" ] && continue
  case "$module_id" in
    global_codes)
      if ! grep -qE "function ${base_fn}\\(" "$ERR_MOD" 2>/dev/null; then
        echo "std-error-unify FAIL: missing global ${base_fn}" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    sidecar_fs)
      if [ ! -f "$src" ] || ! grep -qE "function last_error|fs_last_error" "$src" 2>/dev/null; then
        echo "std-error-unify FAIL: fs sidecar" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol_*)
      sym="$base_fn"
      if ! grep -qE "function ${sym}\\(" "$ERR_MOD" 2>/dev/null; then
        echo "std-error-unify FAIL: missing symbol ${sym}" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke_case)
      SMOKE="$src"
      ;;
  esac
done < "$MATRIX"

if [ "$MOD_N" -lt "$MIN_MOD" ]; then
  echo "std-error-unify gate FAIL: modules=${MOD_N} < min ${MIN_MOD}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "std-error-unify gate FAIL: missing=${MISS}" >&2
  exit 1
fi

if ! grep -qF 'STD-011' "$DOC" 2>/dev/null; then
  echo "std-error-unify gate FAIL: doc missing STD-011" >&2
  exit 1
fi
if ! grep -qF 'std-error-unify.tsv' "$DOC" 2>/dev/null; then
  echo "std-error-unify gate FAIL: doc missing matrix ref" >&2
  exit 1
fi
echo "std-error-unify manifest OK (modules=${MOD_N})"

make -C compiler -q 2>/dev/null || make -C compiler

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ]; then
  echo "std-error-unify gate SKIP smoke (no native shux)" >&2
  echo "std-error-unify gate OK"
  exit 0
fi

if [ ! -f "$SMOKE" ]; then
  echo "std-error-unify gate FAIL: missing $SMOKE" >&2
  exit 1
fi

OUT=/tmp/shux_std_error_unify
echo "=== STD-011: error unify smoke (SHUX=$SHUX_BIN) ==="
if ! "$SHUX_BIN" -L . "$SMOKE" -o "$OUT" >/tmp/shux_std_error_unify_compile.log 2>&1; then
  cat /tmp/shux_std_error_unify_compile.log >&2
  exit 1
fi
EC=0
"$OUT" >/dev/null 2>&1 || EC=$?
if [ "$EC" -ne 0 ]; then
  echo "std-error-unify gate FAIL: smoke exit=$EC" >&2
  exit 1
fi
echo "std-error-unify smoke OK"

echo "std-error-unify gate OK"
