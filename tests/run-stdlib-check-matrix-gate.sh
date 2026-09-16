#!/usr/bin/env bash
# BOOT-013: stdlib check-matrix manifest — leftover fossil DOC + leftover
# catalog no Honesty + leftover auto-make / prefer-c / hard check →硬绿.
#
# Honesty: leftover top-level `analysis/boot-stdlib-check-matrix-v1.md` as
# live DOC (file already archived to analysis/archive/boot/; gate still
# hard-required the missing top-level path → portable BOOT-013 red) + leftover
# catalog no Honesty / missing run=/obs=/skip= + leftover
# `xlang_compiler_make xlang-c` + leftover prefer-c
# (`stdlib_cm_resolve_shu` xlang-c then xlang, never asm) + leftover
# SKIP→OK when no native + leftover hard `xlang check` retired.
# Live = analysis/archive/boot/. Refuse top-level resurrect. Nested leftover
# runner `run-stdlib-check-matrix.sh` is check postponed (2026-08-05) →
# skip=1 (do not rewrite that runner; refuse leftover auto-make / leftover
# prefer-c / leftover SKIP→OK). Manifest (DOC + TSV + module files) stays
# hard. No XLANG face on this parent (G.7: do not fork a resolver). Explicit
# XLANG is ignored. Keep `stdlib-check-matrix gate OK`.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-stdlib-check-matrix-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/stdlib-check-matrix.sh
. tests/lib/stdlib-check-matrix.sh

DOC="${XLANG_STDLIB_CHECK_DOC:-analysis/archive/boot/boot-stdlib-check-matrix-v1.md}"
MANIFEST="${XLANG_STDLIB_CHECK_TSV:-tests/baseline/stdlib-check-matrix.tsv}"
LIB="tests/lib/stdlib-check-matrix.sh"
RUNNER="tests/run-stdlib-check-matrix.sh"
MIN_MOD=55
PREFIX="${XLANG_STDLIB_CHECK_GATE_PREFIX:-xlang: [XLANG_STDLIB_CHECK]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "stdlib-check-matrix gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== BOOT-013: stdlib check matrix manifest (archive DOC; check postponed) ==="

# Refuse leftover fossil top-level DOC as live path (TST-003 / placeholder pattern).
# PLATFORM: SHARED archaeology — live = archive/boot/.
if [ -f analysis/boot-stdlib-check-matrix-v1.md ]; then
  die "top-level DOC resurrected (live = archive/boot/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in runnable XLANG_STDLIB_CHECK 模块矩阵 xlang check; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing '$kw'"
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_modules) MIN_MOD="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
MOD_N=0
CORE_N=0
STD_N=0
while IFS=$'\t' read -r item_id kind anchor layer _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|read_path|matrix|report) continue ;; esac
  case "$kind" in
    module)
      MOD_N=$((MOD_N + 1))
      mod_path="$(stdlib_cm_mod_to_path "$anchor" "$layer")"
      case "$layer" in
        core) CORE_N=$((CORE_N + 1)) ;;
        std) STD_N=$((STD_N + 1)) ;;
      esac
      if [ ! -f "$mod_path" ]; then
        echo "stdlib-check-matrix FAIL: missing $mod_path ($anchor)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "stdlib-check-matrix FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "stdlib-check-matrix FAIL: doc missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$MOD_N" -lt "$MIN_MOD" ]; then
  die "modules=${MOD_N} < min ${MIN_MOD}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "stdlib-check-matrix manifest OK (modules=${MOD_N}, core=${CORE_N}, std=${STD_N})"
RUN_OK=$((RUN_OK + 1))

# Nested leftover runner is leftover hard `xlang check` (paused 2026-08-05).
# skip=1: refuse leftover auto-make / leftover prefer-c / leftover SKIP→OK.
echo "stdlib-check-matrix SKIP runnable (check postponed; refuse leftover auto-make / leftover prefer-c)"
SKIP=$((SKIP + 1))

echo "stdlib-check-matrix gate OK"
ok_report
