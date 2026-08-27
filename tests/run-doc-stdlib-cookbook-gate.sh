#!/usr/bin/env bash
# DOC-001：标准库 Cookbook manifest 门禁（假权威诚实）。
#
# Honesty: prefer-c + soft SKIP typeck + hard-bind xlang check retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die. Manifest hard; product -o smoke hard; check = obs.
# DOC authority = archive/doc. Report: run=/obs=/skip=
# Usage: ./tests/run-doc-stdlib-cookbook-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/doc-cookbook.sh
. tests/lib/doc-cookbook.sh

DOC="${XLANG_DOC_COOKBOOK:-analysis/archive/doc/doc-stdlib-cookbook-v1.md}"
ROADMAP="${XLANG_LIVE_ROADMAP:-analysis/自举进度.md}"
MANIFEST="${XLANG_DOC_COOKBOOK_TSV:-tests/baseline/doc-stdlib-cookbook.tsv}"
MIN_SEC=6
MIN_REC=12
PREFIX="${XLANG_DOC_COOKBOOK_PREFIX:-xlang: [XLANG_DOC_STDLIB_COOKBOOK]}"
SMOKE="examples/cookbook/io_batch_rw.x"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "doc-stdlib-cookbook gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== DOC-001: stdlib cookbook manifest ==="

if [ -f analysis/doc-stdlib-cookbook-v1.md ]; then
  die "top-level DOC resurrected (analysis/doc-stdlib-cookbook-v1.md; use archive)"
fi
if [ -f NEXT.md ]; then
  die "NEXT.md resurrected (use analysis/自举进度.md)"
fi

for f in "$DOC" "$MANIFEST" "$ROADMAP"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_sections) MIN_SEC="$c2" ;;
    min_recipes) MIN_REC="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
SEC=0
REC=0
echo "=== DOC-001: sections, recipes, refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-stdlib-cookbook FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      else
        SEC=$((SEC + 1))
        echo "doc-stdlib-cookbook OK section $item_id"
      fi
      ;;
    recipe)
      REC=$((REC + 1))
      if [ ! -f "$anchor" ]; then
        echo "doc-stdlib-cookbook FAIL: missing recipe $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-stdlib-cookbook FAIL: doc missing recipe $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "doc-stdlib-cookbook OK recipe $anchor"
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "doc-stdlib-cookbook FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "doc-stdlib-cookbook FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "doc-stdlib-cookbook FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "doc-stdlib-cookbook FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$SEC" -ge "$MIN_SEC" ] || die "sections=${SEC} < min ${MIN_SEC}"
[ "$REC" -ge "$MIN_REC" ] || die "recipes=${REC} < min ${MIN_REC}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"

for kw in IO NET async cookbook recipe; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
echo "doc-stdlib-cookbook manifest OK (sections=${SEC} recipes=${REC})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== DOC-001: product -o smoke (XLANG=$XLANG_BIN) ==="
[ -f "$SMOKE" ] || die "missing smoke $SMOKE"
if doc_cb_run_recipe "$XLANG_BIN" "$SMOKE"; then
  RUN_OK=1
  echo "doc-stdlib-cookbook run OK $SMOKE"
else
  die "product -o smoke $SMOKE"
fi

if doc_cb_check_recipe "$XLANG_BIN" "$SMOKE"; then
  echo "doc-stdlib-cookbook check OK $SMOKE (obs path also green)"
else
  OBS=$((OBS + 1))
  echo "doc-stdlib-cookbook OBS check $SMOKE (check paused / residual)" >&2
fi

ok_report
echo "doc-stdlib-cookbook gate OK"
