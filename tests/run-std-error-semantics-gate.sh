#!/usr/bin/env bash
# STD-158: std.error cross-module semantics — leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c). Product error_semantics_smoke.x +
# cookbook error_semantic_class.x -o exit0 = hard run (run=2). check = obs
# (paused 2026-08-05; leave ensure_std alone). Report: run=/obs=/skip=.
# G.7: complete existing resolve_shu; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-error-semantics-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_ERROR_SEMANTICS_DOC:-analysis/archive/std/std-error-semantics-v1.md}"
MANIFEST="${XLANG_STD_ERROR_SEMANTICS_TSV:-tests/baseline/std-error-semantics.tsv}"
ERR_MOD="${XLANG_STD_ERROR_MOD:-std/error/mod.x}"
LIB="tests/lib/std-error-semantics.sh"
SMOKE="tests/std/error_semantics_smoke.x"
COOKBOOK="examples/cookbook/error_semantic_class.x"
MIN_SYM=6
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-error-semantics.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-error-semantics gate FAIL: $*" >&2
  std_error_semantics_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-158: error semantics manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$ERR_MOD" "$SMOKE" "$COOKBOOK"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-158 semantic_class is_timeout recommend_retry; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

SYM_N=0
while IFS=$'\t' read -r item_id kind _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "symbol" ] && SYM_N=$((SYM_N + 1))
done < "$MANIFEST"
[ "$SYM_N" -ge "$MIN_SYM" ] || die "symbols=$SYM_N < min $MIN_SYM"

sym_miss="$(std_error_semantics_symbols_ok "$ERR_MOD" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-error-semantics manifest OK"

if [ "${XLANG_STD_ERROR_SEMANTICS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_error_semantics_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-error-semantics gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-158: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_error_sem_check_smoke.log 2>&1
chk_s=$?
"$XLANG_BIN" check -L . "$COOKBOOK" >/tmp/xlang_std_error_sem_check_cb.log 2>&1
chk_c=$?
set -e
if [ "$chk_s" -ne 0 ] || [ "$chk_c" -ne 0 ]; then
  echo "std-error-semantics OBS check (paused / CHK residual smoke=$chk_s cookbook=$chk_c; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

for pair in "smoke:$SMOKE" "cookbook:$COOKBOOK"; do
  tag="${pair%%:*}"
  src="${pair#*:}"
  OUT="/tmp/xlang_std_error_sem_${tag}_$$"
  LOG="/tmp/xlang_std_error_sem_${tag}_build_$$.log"
  rm -f "$OUT" "$LOG"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$OUT" >"$LOG" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
    tail -n 20 "$LOG" 2>/dev/null || true
    rm -f "$OUT"
    die "product -o $src failed (ec=$o_ec; refuse soft SKIP→OK)"
  fi
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  [ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable $src exit=$exitcode (expect $SMOKE_EXPECT)"
  RUN_OK=$((RUN_OK + 1))
  echo "std-error-semantics OK: product -o $tag"
done

std_error_semantics_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-error-semantics gate OK"
