#!/usr/bin/env bash
# TST-002: P0 boundary wave 2 (heap/vec/map/process) — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native xlang-c) + prefer-c only + soft auto-make
# + hard-bound `xlang check` (CHK002 under pause = portable false-red) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - manifest + ## Gate + case counts = hard.
#   - heap / vec / map / process product -o exit0 = hard run.
#   - check path = obs (paused 2026-08-05).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-tst-002-boundary-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tst-002-boundary.sh
. tests/lib/tst-002-boundary.sh

DOC="${XLANG_TST002_DOC:-analysis/archive/tst/tst-002-boundary-wave2-v1.md}"
MANIFEST="${XLANG_TST002_TSV:-tests/baseline/tst-002-boundary-wave2.tsv}"
LIB="tests/lib/tst-002-boundary.sh"
MIN_CASES=8

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "tst-002-boundary gate FAIL: $*" >&2
  tst002_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

run_one() {
  local x="$1"
  local tag="$2"
  local exe="/tmp/xlang_tst002_${tag}_$$"
  local o_ec run_ec
  rm -f "$exe" 2>/dev/null || true
  set +e
  "$XLANG_BIN" -L . "$x" -o "$exe" >/tmp/xlang_tst002_${tag}_o.log 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    tail -n 8 /tmp/xlang_tst002_${tag}_o.log 2>/dev/null || true
    rm -f "$exe"
    die "product -o failed for $x (ec=$o_ec; refuse soft SKIP→OK)"
  fi
  set +e
  "$exe" >/dev/null 2>&1
  run_ec=$?
  set -e
  rm -f "$exe"
  [ "$run_ec" -eq 0 ] || die "runnable $x exit=$run_ec (expected 0)"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== TST-002: boundary wave 2 manifest (archive DOC) ==="
if [ -f analysis/tst-002-boundary-wave2-v1.md ]; then
  die "top-level DOC resurrected (live = archive/tst/)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" \
  tests/heap/boundary.x tests/vec/boundary.x tests/map/boundary.x tests/process/boundary.x; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi
for kw in std.heap std.vec std.map std.process boundary case; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases_per_mod) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

miss="$(tst002_verify_manifest "$MANIFEST" || true)"
[ "${miss:-0}" -eq 0 ] || die "manifest_miss=${miss}"

BOUNDARY_N=0
while IFS=$'\t' read -r item_id kind path min_cases _mod _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|doc|gate) continue ;; esac
  case "$kind" in
    boundary)
      BOUNDARY_N=$((BOUNDARY_N + 1))
      want="${min_cases:-$MIN_CASES}"
      tst002_count_cases "$path" "$want" >/dev/null || die "case count $path"
      ;;
  esac
done < "$MANIFEST"
[ "$BOUNDARY_N" -ge 4 ] || die "modules=${BOUNDARY_N} want 4"
echo "tst-002-boundary manifest OK (modules=${BOUNDARY_N} min_cases=${MIN_CASES})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== TST-002: smoke (XLANG=$XLANG_BIN) ==="

for x in tests/heap/boundary.x tests/vec/boundary.x tests/map/boundary.x tests/process/boundary.x; do
  set +e
  "$XLANG_BIN" check -L . "$x" >/tmp/xlang_tst002_check.log 2>&1
  chk_ec=$?
  set -e
  if [ "$chk_ec" -ne 0 ]; then
    echo "tst-002-boundary OBS check $x (paused / CHK residual ec=$chk_ec)" >&2
    OBS=$((OBS + 1))
  fi
done

run_one tests/heap/boundary.x heap
run_one tests/vec/boundary.x vec
run_one tests/map/boundary.x map
run_one tests/process/boundary.x proc

echo "tst-002-boundary gate OK"
tst002_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
