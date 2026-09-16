#!/usr/bin/env bash
# LANG-008: lifetime diagnostic manifest — leftover dual-authority DOC →硬绿.
#
# Honesty: leftover top-level `analysis/type-region-v1-rfc.md` /
# `analysis/type-linear-v1-rfc.md` (archive/type is Gate authority;
# leftover "narrative mirror" / LANG-008 hard-require top-level = false
# dual authority) retired. Live type RFCs = analysis/archive/type/.
# Refuse top-level resurrect. LANG-008 DOC live remains archive/lang.
# Nested run-lang-lifetime-diag.sh already honesty-closed (leave lifetime
# substr product residual). G.7: complete existing nested resolve_shu;
# do not fork a third resolver. Report: run=/obs=/skip=.
# Keep `lang-lifetime-diag gate OK`.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-lang-lifetime-diag-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_LANG_LIFETIME_DIAG_DOC:-analysis/archive/lang/lang-lifetime-diag-v1.md}"
TYPE_REGION_DOC="${XLANG_TYPE_REGION_DOC:-analysis/archive/type/type-region-v1-rfc.md}"
TYPE_LINEAR_DOC="${XLANG_TYPE_LINEAR_DOC:-analysis/archive/type/type-linear-v1-rfc.md}"
MANIFEST="${XLANG_LANG_LIFETIME_DIAG_MANIFEST:-tests/baseline/lang-lifetime-diag.tsv}"
MATRIX="${XLANG_LANG_LIFETIME_DIAG_CASES:-tests/baseline/lang-lifetime-diag-cases.tsv}"
PREFIX="xlang: [XLANG_LANG_LIFETIME]"
MIN_LAYERS=6
MIN_CASES=4
RUN_OK=0
OBS=0
SKIP=0

# shellcheck source=tests/lib/lang-lifetime-diag.sh
. tests/lib/lang-lifetime-diag.sh

die() {
  echo "lang-lifetime-diag gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== LANG-008: lifetime diagnostic manifest (archive DOC; refuse leftover dual-authority) ==="
if [ -f analysis/type-region-v1-rfc.md ]; then
  die "dual-authority fossil analysis/type-region-v1-rfc.md (archive live)"
fi
if [ -f analysis/type-linear-v1-rfc.md ]; then
  die "dual-authority fossil analysis/type-linear-v1-rfc.md (archive live)"
fi
if [ -f compiler/src/lsp/lsp_diag.c ]; then
  die "lsp_diag.c resurrected (live = lsp_diag.h)"
fi
if [ -f compiler/src/typeck/typeck.c ]; then
  die "typeck.c resurrected (live = typeck.x)"
fi

for f in \
  "$DOC" \
  "$TYPE_REGION_DOC" \
  "$TYPE_LINEAR_DOC" \
  "$MANIFEST" \
  "$MATRIX" \
  compiler/src/lsp/lsp_diag.h \
  compiler/src/typeck/typeck.x \
  tests/typeck/slice_lifetime/region_assign_escape.x; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_layers) MIN_LAYERS="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-lifetime-diag FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "lang-lifetime-diag FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-lifetime-diag FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "lang-lifetime-diag FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

MATRIX_N=$(awk -F'\t' '$1 !~ /^#/ && NF>=2 { n++ } END { print n+0 }' "$MATRIX")
while IFS=$'\t' read -r case_id file substr want_line _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  if ! grep -qF "$case_id" "$DOC" 2>/dev/null; then
    echo "lang-lifetime-diag FAIL: doc missing matrix case $case_id" >&2
    MISS=$((MISS + 1))
  fi
done < "$MATRIX"

[ "$LAYER_N" -ge "$MIN_LAYERS" ] || die "layers=${LAYER_N} < min ${MIN_LAYERS}"
[ "$CASE_N" -ge "$MIN_CASES" ] || die "cases=${CASE_N} < min ${MIN_CASES}"
[ "$MATRIX_N" -ge "$MIN_CASES" ] || die "matrix=${MATRIX_N} < min ${MIN_CASES}"

for kw in lifetime diagnostic friendly source runnable report; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done

[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "lang-lifetime-diag manifest OK (layers=${LAYER_N} cases=${CASE_N} matrix=${MATRIX_N})"

echo "=== LANG-008: nested lifetime-diag smoke (refuse leftover dual-authority DOC) ==="
# Drop leftover hard-require of top-level type-region RFC. Nested gate
# already honesty-closes XLANG (prefer-asm / explicit-bad hard-die /
# missing native FAIL / check substr = obs). Do not copy resolve_shu.
chmod +x tests/run-lang-lifetime-diag.sh
./tests/run-lang-lifetime-diag.sh || die "nested lifetime-diag failed (refuse leftover dual-authority DOC)"
RUN_OK=$((RUN_OK + 1))

echo "lang-lifetime-diag gate OK"
ok_report
exit 0
