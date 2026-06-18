#!/usr/bin/env bash
# TOOL-004：LSP 诊断性能 manifest 门禁
#
# 用法：./tests/run-tool-lsp-diag-perf-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_TOOL_LSP_DIAG_DOC:-analysis/tool-lsp-diag-perf-v1.md}"
MANIFEST="${SHU_TOOL_LSP_DIAG_MANIFEST:-tests/baseline/tool-lsp-diag-perf.tsv}"
MIN_OPTS=6
MIN_CASES=2
MIN_LARGE_FUNCS=30
MAX_WALL_MS=15000

# shellcheck source=tests/lib/tool-lsp-diag-perf.sh
. tests/lib/tool-lsp-diag-perf.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*) return 0 ;;
    *) return 0 ;;
  esac
}

echo "=== TOOL-004: LSP diag perf manifest ==="
for f in "$DOC" "$MANIFEST" compiler/src/lsp/lsp_diag.c compiler/src/lsp/lsp_diag.su; do
  if [ ! -f "$f" ]; then
    echo "tool-lsp-diag-perf gate FAIL: missing $f" >&2
    exit 1
  fi
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

LARGE_FUNCS=$(tool_lsp_count_funcs tests/lsp/diag_large_ok.su)
if [ "$OPT_N" -lt "$MIN_OPTS" ]; then
  echo "tool-lsp-diag-perf gate FAIL: opts=${OPT_N} < min ${MIN_OPTS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "tool-lsp-diag-perf gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "${LARGE_FUNCS:-0}" -lt "$MIN_LARGE_FUNCS" ]; then
  echo "tool-lsp-diag-perf gate FAIL: large funcs=${LARGE_FUNCS} < min ${MIN_LARGE_FUNCS}" >&2
  exit 1
fi

for kw in diagnostic cache performance runnable report large; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "tool-lsp-diag-perf gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "tool-lsp-diag-perf gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "tool-lsp-diag-perf manifest OK (opts=${OPT_N} cases=${CASE_N} funcs=${LARGE_FUNCS} max_wall_ms=${MAX_WALL_MS})"

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHU_BIN" ] && native_shu "$SHU_BIN" && "$SHU_BIN" --help 2>/dev/null | grep -q '\-\-lsp'; then
  echo "=== TOOL-004: LSP diag perf hooks (SHU=$SHU_BIN) ==="
  chmod +x tests/run-lsp-diag-perf.sh
  SHU_LSP_DIAG_MAX_WALL_MS="$MAX_WALL_MS" SHU_LSP_DIAG_MIN_FUNCS="$MIN_LARGE_FUNCS" SHU="$SHU_BIN" ./tests/run-lsp-diag-perf.sh
  echo "tool-lsp-diag-perf hooks OK"
else
  echo "tool-lsp-diag-perf gate SKIP hooks (no native shu --lsp)" >&2
fi

echo "tool-lsp-diag-perf gate OK"
