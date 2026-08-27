#!/usr/bin/env bash
# STD-171：docs/07 + Cookbook Phase 3 同步门禁（假权威诚实）。
#
# Honesty: prefer-c + soft SKIP typeck + hard-bind check retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die. Manifest hard; recipe product -o → run or obs
# (sqlite/compress tip residuals = obs, not soft silence). check = obs.
# DOC authority = archive/doc. Report: run=/obs=/skip=
# Usage: ./tests/run-doc-07-phase3-sync-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

if [ -f analysis/doc-07-phase3-sync-v1.md ]; then
  echo "doc-07-phase3-sync-gate gate FAIL: top-level DOC resurrected (live = archive/doc/)" >&2
  exit 1
fi
if [ -f analysis/doc-cookbook-expand-v1.md ]; then
  echo "run-doc-07-phase3-sync-gate.sh FAIL: companion top-level DOC resurrected (analysis/doc-cookbook-expand-v1.md)" >&2
  exit 1
fi

DOC="analysis/archive/doc/doc-07-phase3-sync-v1.md"
MANIFEST="tests/baseline/doc-07-phase3-sync.tsv"
DOC07="docs/07-内置与标准库.md"
COOKBOOK_DOC="analysis/archive/doc/doc-cookbook-expand-v1.md"
LIB="tests/lib/doc-07-phase3-sync.sh"

# shellcheck source=tests/lib/doc-07-phase3-sync.sh
. "$LIB"
# shellcheck source=tests/lib/doc-cookbook.sh
. tests/lib/doc-cookbook.sh

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "doc-07-phase3-sync gate FAIL: $*" >&2
  doc07_phase3_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-171: docs/07 Phase 3 sync manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$DOC07" "$COOKBOOK_DOC"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

for kw in STD-171 await_read_fd timezone_iana format_brotli row_col_blob_read; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

if ! grep -qF "## std Phase 3 增量" "$DOC07" 2>/dev/null; then
  die "docs/07 missing Phase 3 section"
fi

sym_miss="$(doc07_phase3_symbols_ok "$DOC07" "$COOKBOOK_DOC" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  die "manifest miss=${sym_miss}"
fi
echo "doc-07-phase3-sync registry OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== STD-171: recipe product -o (XLANG=$XLANG_BIN; residual＝obs) ==="
while IFS=$'\t' read -r item_id kind anchor _t _n; do
  [ "$kind" = "recipe" ] || continue
  if doc_cb_run_recipe "$XLANG_BIN" "$anchor"; then
    RUN_OK=$((RUN_OK + 1))
    echo "doc-07-phase3-sync run OK $anchor"
  else
    OBS=$((OBS + 1))
    echo "doc-07-phase3-sync OBS product -o $anchor (tip residual; not soft silence)" >&2
  fi
done < "$MANIFEST"

FIRST=""
while IFS=$'\t' read -r item_id kind anchor _t _n; do
  [ "$kind" = "recipe" ] || continue
  FIRST="$anchor"
  break
done < "$MANIFEST"
if [ -n "$FIRST" ]; then
  if doc_cb_check_recipe "$XLANG_BIN" "$FIRST"; then
    echo "doc-07-phase3-sync check OK $FIRST (obs path also green)"
  else
    OBS=$((OBS + 1))
    echo "doc-07-phase3-sync OBS check $FIRST (check paused / residual)" >&2
  fi
fi

doc07_phase3_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "doc-07-phase3-sync gate OK"
