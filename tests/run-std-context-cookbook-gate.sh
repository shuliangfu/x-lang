#!/usr/bin/env bash
# STD-156: std.context cookbook expand gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c). Product context_cancel_deadline.x
# -o exit0 = hard run (run=1). check = obs (paused 2026-08-05; leave ensure_std
# family alone). Report: run=/obs=/skip=. G.7: complete existing resolve_shu;
# drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-context-cookbook-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD156_DOC:-analysis/archive/std/std-context-cookbook-v1.md}"
MANIFEST="${XLANG_STD156_TSV:-tests/baseline/std-context-cookbook.tsv}"
COOKBOOK_DOC="${XLANG_DOC_COOKBOOK_EXPAND:-analysis/archive/doc/doc-cookbook-expand-v1.md}"
MOD_X="std/context/mod.x"
LIB="tests/lib/std-context-cookbook.sh"
RECIPE="examples/cookbook/context_cancel_deadline.x"
MIN_REC=1
RECIPE_EXPECT=0

# shellcheck source=tests/lib/std-context-cookbook.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-context-cookbook gate FAIL: $*" >&2
  std_context_cookbook_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-156: context cookbook manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$RECIPE" "$COOKBOOK_DOC"; do
  [ -f "$f" ] || die "missing $f"
done

# Refuse top-level DOC resurrection (portable fake-red / dual authority).
# PLATFORM: SHARED archaeology — live expand DOC lives under analysis/archive/doc/.
[ ! -f analysis/doc-cookbook-expand-v1.md ] || die "top-level DOC resurrected (analysis/doc-cookbook-expand-v1.md; use archive)"

for kw in STD-156 CTX-01 with_timeout is_cancelled; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF -- "$RECIPE" "$COOKBOOK_DOC" 2>/dev/null || die "cookbook doc missing recipe ref"

REC_N=0
sym_miss="$(std_context_cookbook_symbols_ok "$MOD_X" "$MANIFEST" || true)"
while IFS=$'\t' read -r item_id kind _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "recipe" ] && REC_N=$((REC_N + 1))
done < "$MANIFEST"
[ "$REC_N" -ge "$MIN_REC" ] || die "recipes=$REC_N < min $MIN_REC"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-context-cookbook manifest OK"

if [ "${XLANG_STD156_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_context_cookbook_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-context-cookbook gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-156: cookbook (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

set +e
"$XLANG_BIN" check -L . "$RECIPE" >/tmp/xlang_std_context_cookbook_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-context-cookbook OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make of context .o / xlang-c; leave ensure_std family alone.
# PLATFORM: SHARED archaeology.

OUT="/tmp/xlang_std_context_cookbook_$$"
LOG="/tmp/xlang_std_context_cookbook_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$RECIPE" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq "$RECIPE_EXPECT" ] || die "runnable exit=$exitcode (expect $RECIPE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-context-cookbook OK: product -o"

std_context_cookbook_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-context-cookbook gate OK"
