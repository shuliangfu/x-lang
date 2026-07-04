#!/usr/bin/env bash
# VEC-V1：loop autovec f32 点积 — emit 含 shux_autovec_dot_f32，运行正确。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/vec/autovec_dot_loop.x"
OUT="/tmp/shux_autovec_dot_loop"
C_OUT="/tmp/shux_autovec_dot_loop.c"
rm -f "$OUT" "$C_OUT"
if ! "$SHUX" -E "$SRC" >"$C_OUT" 2>/tmp/shux_autovec_emit.log; then
  echo "autovec-loop-gate FAIL: emit failed" >&2
  tail -8 /tmp/shux_autovec_emit.log 2>/dev/null || true
  exit 1
fi
if ! grep -q 'shux_autovec_dot_f32' "$C_OUT"; then
  echo "autovec-loop-gate FAIL: missing shux_autovec_dot_f32 in generated C" >&2
  exit 1
fi
if grep -qE 'for \(.*ap\)\[i\].*\*.*\(bp\)\[i\]' "$C_OUT"; then
  echo "autovec-loop-gate FAIL: scalar dot loop still present" >&2
  exit 1
fi
if SHUX_NO_AUTovec=1 "$SHUX" -E "$SRC" >"${C_OUT}.scalar" 2>/dev/null; then
  if ! grep -qE 'for \(.*ap\)\[i\]|ap\)\[i\].*\*.*bp\)\[i\]' "${C_OUT}.scalar"; then
    echo "autovec-loop-gate WARN: SHUX_NO_AUTovec=1 did not preserve scalar loop" >&2
  fi
fi
SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" 2>/tmp/shux_autovec_run.log || {
  echo "autovec-loop-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/shux_autovec_run.log 2>/dev/null || true
  exit 1
}
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  echo "autovec-loop-gate FAIL: exit=$rc want 0" >&2
  exit 1
fi
echo "autovec-loop-gate OK (VEC-V1 f32 dot loop autovec)"
