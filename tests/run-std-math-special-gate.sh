#!/usr/bin/env bash
# STD-115：std.math 特殊函数门禁
#
# 用法：./tests/run-std-math-special-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD115_DOC:-analysis/std-math-special-v1.md}"
MANIFEST="${SHUX_STD115_TSV:-tests/baseline/std-math-special.tsv}"
VECTORS="${SHUX_STD115_VECTORS:-tests/baseline/std-math-special-vectors.tsv}"
MOD_X="std/math/mod.x"
MATH_RUNTIME="${SHUX_STD_MATH_IMPL:-compiler/src/asm/runtime_math_libm.inc}"
MATH_X="std/math/math.x"
LIB="tests/lib/std-math-special.sh"
SMOKE_X="tests/std-math/special_funcs.x"
SMOKE_C="tests/std-math/special_smoke_ok.c"
MIN_APIS=5

# shellcheck source=tests/lib/std-math-special.sh
. "$LIB"

echo "=== STD-115: math special manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$MATH_RUNTIME" "$MATH_X" "$SMOKE_X" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-math-special gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-115 erf log1p expm1 0.8427007929497149; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-math-special gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '0.8427007929497149' "$VECTORS" 2>/dev/null; then
  echo "std-math-special gate FAIL: vectors missing erf(1) gold" >&2
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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-math-special FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-math-special gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_math_special_symbols_ok "$MOD_X" "$MATH_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_math_special_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-math-special manifest OK"

C_OK=0
X_OK=0
SKIP=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/math/math.o
  ensure_runtime_math_libm_o 2>/dev/null || true
  MATH_O="$(cd compiler && pwd)/../std/math/math.o"
  if std_math_special_run_c_smoke "$MATH_O"; then
    C_OK=1
  else
    std_math_special_emit_report "fail" 0 0 0
    exit 1
  fi
else
  echo "std-math-special gate SKIP c smoke (no shux-c; manifest OK)" >&2
  SKIP=1
fi

if [ -x ./compiler/shux-c ]; then
  echo "=== STD-115: .x smoke (SHUX=./compiler/shux-c) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-math-special gate FAIL: typeck $SMOKE_X" >&2
    std_math_special_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_math_special_run_x_smoke ./compiler/shux-c "$SMOKE_X"; then
    X_OK=1
  else
    std_math_special_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_math_special_emit_report "ok" "$C_OK" "$X_OK" "$SKIP"
echo "std-math-special gate OK"
