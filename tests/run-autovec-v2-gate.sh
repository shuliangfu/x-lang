#!/usr/bin/env bash
# VEC-V2：while + f32 reduction autovec — emit 含 shux_autovec_sum_f32，运行正确。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/vec/autovec_sum_while.sx"
OUT="/tmp/shux_autovec_sum_while"
C_OUT="/tmp/shux_autovec_sum_while.c"
rm -f "$OUT" "$C_OUT"
if ! "$SHUX" -E "$SRC" >"$C_OUT" 2>/tmp/shux_autovec_v2_emit.log; then
  echo "autovec-v2-gate FAIL: emit failed" >&2
  tail -8 /tmp/shux_autovec_v2_emit.log 2>/dev/null || true
  exit 1
fi
if ! grep -q 'shux_autovec_sum_f32' "$C_OUT"; then
  echo "autovec-v2-gate FAIL: missing shux_autovec_sum_f32 in generated C" >&2
  exit 1
fi
if grep -qE 'while \(.*<.*\) \{[^}]*s = s \+ .*ap\)\[i\]' "$C_OUT"; then
  echo "autovec-v2-gate FAIL: scalar while sum loop still present" >&2
  exit 1
fi
if SHUX_NO_AUTovec=1 "$SHUX" -E "$SRC" >"${C_OUT}.scalar" 2>/dev/null; then
  if ! grep -qE 'while \(.*<.*\)' "${C_OUT}.scalar"; then
    echo "autovec-v2-gate WARN: SHUX_NO_AUTovec=1 did not preserve scalar while loop" >&2
  fi
fi
SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" 2>/tmp/shux_autovec_v2_run.log || {
  echo "autovec-v2-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/shux_autovec_v2_run.log 2>/dev/null || true
  exit 1
}
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "autovec-v2-gate FAIL: exit=$rc want 0" >&2
  exit 1
fi
echo "autovec-v2-gate OK (VEC-V2 f32 sum while autovec)"
