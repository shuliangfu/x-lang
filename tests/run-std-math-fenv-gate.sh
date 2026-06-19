#!/usr/bin/env bash
# STD-059：std.math 浮点环境异常标志门禁
#
# 用法：./tests/run-std-math-fenv-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_MATH_FENV_DOC:-analysis/std-math-fenv-v1.md}"
MANIFEST="${SHUX_STD_MATH_FENV_TSV:-tests/baseline/std-math-fenv.tsv}"
VECTORS="${SHUX_STD_MATH_FENV_VECTORS:-tests/baseline/std-math-fenv-vectors.tsv}"
MOD_SU="std/math/mod.sx"
MATH_C="std/math/math.c"
LIB="tests/lib/std-math-fenv.sh"
SMOKE_SU="tests/std-math/fenv_clear.sx"
SMOKE_C="tests/std-math/fenv_smoke_ok.c"
MIN_APIS=3

# shellcheck source=tests/lib/std-math-fenv.sh
. "$LIB"

echo "=== STD-059: math fenv manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$MATH_C" "$SMOKE_SU" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-math-fenv gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-059 fetestexcept FENV_INVALID feclearexcept; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-math-fenv gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'FE_INVALID' "$VECTORS" 2>/dev/null; then
  echo "std-math-fenv gate FAIL: vectors missing invalid_op" >&2
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
        echo "std-math-fenv gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-math-fenv gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-math-fenv gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_math_fenv_symbols_ok "$MOD_SU" "$MATH_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_math_fenv_emit_report "fail" 0 0 0
  echo "std-math-fenv gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-math-fenv manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/math/math.o

C_OK=0
SKIP=0
if std_math_fenv_run_c_smoke "$MATH_C"; then
  C_OK=1
else
  if grep -q 'SHUX_MATH_HAVE_FENV' "$MATH_C" 2>/dev/null; then
    std_math_fenv_emit_report "fail" 0 0 0
    exit 1
  fi
  echo "std-math-fenv gate SKIP c smoke (no fenv)" >&2
  SKIP=1
fi

SU_OK=0
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
  echo "=== STD-059: .sx smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-math-fenv gate FAIL: typeck $SMOKE_SU" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_math_fenv_emit_report "fail" "$C_OK" 0 "$SKIP"
    exit 1
  fi
  if std_math_fenv_run_smoke "$SHUX_BIN" "$SMOKE_SU" "clear"; then
    SU_OK=1
  else
    std_math_fenv_emit_report "fail" "$C_OK" 0 "$SKIP"
    exit 1
  fi
else
  echo "std-math-fenv gate SKIP .sx smoke (no native shux)" >&2
  SKIP=1
fi

std_math_fenv_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-math-fenv gate OK"
