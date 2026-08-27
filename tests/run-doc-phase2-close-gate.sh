#!/usr/bin/env bash
# DOC-008：Phase 2 收尾文档同步门禁（假权威诚实）。
#
# Honesty: prefer-c + soft SKIP typeck + top-level DOC fake-anchor retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die. Cookbook HTTP-02 product -o hard green; check = obs.
# DOC authority = archive/doc. Report: run=/obs=/skip=
# Usage: ./tests/run-doc-phase2-close-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/doc-phase2-close.sh
. tests/lib/doc-phase2-close.sh
# shellcheck source=tests/lib/doc-cookbook.sh
. tests/lib/doc-cookbook.sh

DOC="${XLANG_DOC08_DOC:-analysis/archive/doc/doc-phase2-close-v1.md}"
MANIFEST="${XLANG_DOC08_TSV:-tests/baseline/doc-phase2-close.tsv}"
COOKBOOK="examples/cookbook/http_chunked_decode.x"
ROADMAP="${XLANG_LIVE_ROADMAP:-analysis/自举进度.md}"
MIN_ANCHORS=6

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "doc-phase2-close gate FAIL: $*" >&2
  doc_phase2_close_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== DOC-008: Phase 2 close doc sync manifest ==="

# Refuse top-level DOC resurrection (portable fake-red / dual authority).
if [ -f analysis/doc-phase2-close-v1.md ]; then
  die "top-level DOC resurrected (analysis/doc-phase2-close-v1.md; use archive)"
fi
if [ -f NEXT.md ]; then
  die "NEXT.md resurrected (use analysis/自举进度.md)"
fi

for f in "$DOC" "$MANIFEST" "$COOKBOOK" "$ROADMAP" std/http/README.md std/README.md docs/07-内置与标准库.md; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_anchors) MIN_ANCHORS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in STD-033 decode_chunked_body HTTP-02 Phase 2; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(doc_phase2_close_check "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  die "manifest miss=${sym_miss}"
fi
echo "doc-phase2-close manifest OK (min_anchors=${MIN_ANCHORS})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== DOC-008: cookbook HTTP-02 product -o (XLANG=$XLANG_BIN) ==="

if doc_cb_run_recipe "$XLANG_BIN" "$COOKBOOK"; then
  RUN_OK=1
  echo "doc-phase2-close run OK $COOKBOOK"
else
  die "cookbook product -o $COOKBOOK"
fi

# Observational check path (paused 2026-08-05 / CHK002).
if doc_cb_check_recipe "$XLANG_BIN" "$COOKBOOK"; then
  echo "doc-phase2-close check OK $COOKBOOK (obs path also green)"
else
  OBS=$((OBS + 1))
  echo "doc-phase2-close OBS check $COOKBOOK (check paused / residual)" >&2
fi

doc_phase2_close_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "doc-phase2-close gate OK"
