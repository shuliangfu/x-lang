#!/usr/bin/env bash
# TOOL-004: LSP diag perf manifest — leftover catalog no Honesty + leftover
# prefer-c / SKIP→OK / native_xlang →硬绿.
#
# Honesty: leftover catalog no Honesty / missing run=/obs=/skip= + leftover
# prefer-c (`xlang-c` then `xlang`, never asm) + leftover `native_xlang`
# (third resolver) + leftover SKIP→OK when no native `--lsp` still printed
# `tool-lsp-diag-perf gate OK` retired. Nested leftover
# `run-lsp-diag-perf.sh` auto-makes `bootstrap-driver-seed` (leave that
# runner; do not open pipeline_abi). Manifest stays hard. Nested leftover
# hook skip=1 (refuse leftover auto-make / leftover prefer-c). Explicit-bad
# XLANG hard-dies via `dod_native_exe` (refuse leftover ignore of
# explicit-bad). Unset XLANG: no product XLANG face (manifest only).
# Keep `tool-lsp-diag-perf gate OK`. G.7: complete existing native check
# on `dod_native_exe`; do not fork a third resolver.
# Report: run=/obs=/skip=
# wave honesty (2026-08-24 #8): DOC → analysis/archive/tool/;
# lsp_diag.c hard-retired — P1–P6 live in runtime_lsp_glue(.from_x.c / .x).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-tool-lsp-diag-perf-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tool-lsp-diag-perf.sh
. tests/lib/tool-lsp-diag-perf.sh

DOC="${XLANG_TOOL_LSP_DIAG_DOC:-analysis/archive/tool/tool-lsp-diag-perf-v1.md}"
MANIFEST="${XLANG_TOOL_LSP_DIAG_MANIFEST:-tests/baseline/tool-lsp-diag-perf.tsv}"
MIN_OPTS=6
MIN_CASES=2
MIN_LARGE_FUNCS=30
MAX_WALL_MS=15000
PREFIX="${XLANG_TOOL_LSP_DIAG_PREFIX:-xlang: [TOOL_LSP_DIAG_PERF]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "tool-lsp-diag-perf gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

abs_of() {
  case "$1" in
    /*) echo "$1" ;;
    *) echo "$(pwd)/$1" ;;
  esac
}

echo "=== TOOL-004: LSP diag perf manifest (archive DOC; refuse leftover prefer-c) ==="

if [ -f compiler/src/lsp/lsp_diag.c ]; then
  die "lsp_diag.c resurrected (live = runtime_lsp_glue)"
fi

for f in "$DOC" "$MANIFEST" compiler/src/lsp/lsp_diag.x compiler/seeds/runtime_lsp_glue.from_x.c; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_opts) MIN_OPTS="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
    min_large_funcs) MIN_LARGE_FUNCS="$c2" ;;
    max_wall_ms) MAX_WALL_MS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
OPT_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-lsp-diag-perf FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    opts)
      OPT_N=$((OPT_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-lsp-diag-perf FAIL: doc missing opt $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      if [ ! -f "$src" ]; then
        echo "tool-lsp-diag-perf FAIL: missing symbol file $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$src" 2>/dev/null; then
        echo "tool-lsp-diag-perf FAIL: symbol $anchor not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "tool-lsp-diag-perf FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "tool-lsp-diag-perf FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-lsp-diag-perf FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-lsp-diag-perf FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "tool-lsp-diag-perf FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-lsp-diag-perf FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

LARGE_FUNCS=$(tool_lsp_count_funcs tests/lsp/diag_large_ok.x)
if [ "$OPT_N" -lt "$MIN_OPTS" ]; then
  die "opts=${OPT_N} < min ${MIN_OPTS}"
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  die "cases=${CASE_N} < min ${MIN_CASES}"
fi
if [ "${LARGE_FUNCS:-0}" -lt "$MIN_LARGE_FUNCS" ]; then
  die "large funcs=${LARGE_FUNCS} < min ${MIN_LARGE_FUNCS}"
fi

for kw in diagnostic cache performance runnable report large; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done

if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "tool-lsp-diag-perf manifest OK (opts=${OPT_N} cases=${CASE_N} funcs=${LARGE_FUNCS} max_wall_ms=${MAX_WALL_MS})"
RUN_OK=$((RUN_OK + 1))

# Explicit XLANG that is missing/non-native hard-dies (refuse leftover
# SKIP→OK / leftover ignore of explicit-bad / leftover prefer-c).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  abs="$(abs_of "$XLANG")"
  if ! dod_native_exe "$abs"; then
    die "explicit XLANG not native (refuse leftover SKIP→OK / leftover ignore of explicit-bad / leftover prefer-c / leftover native_xlang)"
  fi
fi

# Nested leftover run-lsp-diag-perf.sh auto-makes bootstrap-driver-seed.
# skip=1: refuse leftover auto-make / leftover prefer-c. Do not open pipeline_abi.
echo "tool-lsp-diag-perf SKIP hooks (leftover nested auto-make leave; refuse leftover prefer-c)"
SKIP=$((SKIP + 1))

echo "tool-lsp-diag-perf gate OK"
ok_report
