#!/usr/bin/env bash
# STD-071: std.context gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# cancel_smoke.x -o exit0 = hard run (run=1). check / host-C archaeology = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-context-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_CONTEXT_DOC:-analysis/archive/std/std-context-v1.md}"
MANIFEST="${XLANG_STD_CONTEXT_MANIFEST:-tests/baseline/std-context-manifest.tsv}"
MOD_X="std/context/mod.x"
CTX_X="std/context/context.x"
LIB="tests/lib/std-context.sh"
SMOKE_X="tests/std-context/cancel_smoke.x"
SMOKE_C="tests/std-context/context_smoke_ok.c"
MIN_APIS=10
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-context.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-context gate FAIL: $*" >&2
  std_context_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-071: std.context manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CTX_X" "$SMOKE_X" "$SMOKE_C" std/context/README.md; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f std/context/context_node_glue.c ] || die "context_node_glue.c should be deleted (F-context v2)"

for kw in STD-071 background with_cancel is_cancelled remaining_ns; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_context_symbols_ok "$MOD_X" "$CTX_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-context manifest OK"

if [ "${XLANG_STD_CONTEXT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_context_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-context gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-071: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

# Host-C archaeology = obs only; refuse soft ensure_std rebuild.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if [ -f std/context/context.o ] && std_context_run_c_smoke "$CTX_X"; then
  echo "std-context c smoke OK (observational)"
else
  echo "std-context OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_context_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-context OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_context_$$"
LOG="/tmp/xlang_std_context_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
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
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-context OK: product -o"

std_context_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-context gate OK"
