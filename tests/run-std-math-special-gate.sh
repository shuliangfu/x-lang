#!/usr/bin/env bash
# STD-115：std.math 特殊函数门禁
#
# 用法：./tests/run-std-math-special-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD115_DOC:-analysis/std-math-special-v1.md}"
MANIFEST="${SHU_STD115_TSV:-tests/baseline/std-math-special.tsv}"
VECTORS="${SHU_STD115_VECTORS:-tests/baseline/std-math-special-vectors.tsv}"
MOD_SU="std/math/mod.su"
MATH_C="std/math/math.c"
LIB="tests/lib/std-math-special.sh"
SMOKE_SU="tests/std-math/special_funcs.su"
SMOKE_C="tests/std-math/special_smoke_ok.c"
MIN_APIS=5

# shellcheck source=tests/lib/std-math-special.sh
. "$LIB"

echo "=== STD-115: math special manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$MATH_C" "$SMOKE_SU" "$SMOKE_C"; do
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

sym_miss="$(std_math_special_symbols_ok "$MOD_SU" "$MATH_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_math_special_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-math-special manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/math/math.o
MATH_O="$(cd compiler && pwd)/../std/math/math.o"

C_OK=0
if std_math_special_run_c_smoke "$MATH_O"; then
  C_OK=1
else
  std_math_special_emit_report "fail" 0 0 0
  exit 1
fi

SU_OK=0
SKIP=0
if [ -x ./compiler/shu-c ]; then
  echo "=== STD-115: .su smoke (SHU=./compiler/shu-c) ==="
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if ! ./compiler/shu-c check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-math-special gate FAIL: typeck $SMOKE_SU" >&2
    std_math_special_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_math_special_run_su_smoke ./compiler/shu-c "$SMOKE_SU"; then
    SU_OK=1
  else
    std_math_special_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_math_special_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-math-special gate OK"
