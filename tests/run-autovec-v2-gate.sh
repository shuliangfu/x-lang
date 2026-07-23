#!/usr/bin/env bash
# VEC-V2：while + f32 reduction autovec — emit 含 xlang_autovec_sum_f32，运行正确。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
XLANG="${XLANG:-./compiler/xlang-c}"
SRC="tests/vec/autovec_sum_while.x"
OUT="/tmp/xlang_autovec_sum_while"
C_OUT="/tmp/xlang_autovec_sum_while.c"
rm -f "$OUT" "$C_OUT"
if ! "$XLANG" build -E "$SRC" >"$C_OUT" 2>/tmp/xlang_autovec_v2_emit.log; then
  echo "autovec-v2-gate FAIL: emit failed" >&2
  tail -8 /tmp/xlang_autovec_v2_emit.log 2>/dev/null || true
  exit 1
fi
if ! grep -q 'xlang_autovec_sum_f32' "$C_OUT"; then
  echo "autovec-v2-gate FAIL: missing xlang_autovec_sum_f32 in generated C" >&2
  exit 1
fi
if grep -qE 'while \(.*<.*\) \{[^}]*s = s \+ .*ap\)\[i\]' "$C_OUT"; then
  echo "autovec-v2-gate FAIL: scalar while sum loop still present" >&2
  exit 1
fi
if XLANG_NO_AUTovec=1 "$XLANG" build -E "$SRC" >"${C_OUT}.scalar" 2>/dev/null; then
  if ! grep -qE 'while \(.*<.*\)' "${C_OUT}.scalar"; then
    echo "autovec-v2-gate WARN: XLANG_NO_AUTovec=1 did not preserve scalar while loop" >&2
  fi
fi
XLANG_KEEP_C=1 "$XLANG" "$SRC" -o "$OUT" 2>/tmp/xlang_autovec_v2_run.log || {
  echo "autovec-v2-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/xlang_autovec_v2_run.log 2>/dev/null || true
  exit 1
}
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "autovec-v2-gate FAIL: exit=$rc want 0" >&2
  exit 1
fi
echo "autovec-v2-gate OK (VEC-V2 f32 sum while autovec)"
