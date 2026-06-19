#!/usr/bin/env bash
# TOOL-005：调试符号 manifest 门禁
#
# 用法：./tests/run-tool-debug-symbols-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_TOOL_DEBUG_DOC:-analysis/tool-debug-symbols-v1.md}"
MANIFEST="${SHUX_TOOL_DEBUG_MANIFEST:-tests/baseline/tool-debug-symbols.tsv}"
MIN_RULES=6
MIN_CASES=2

# shellcheck source=tests/lib/tool-debug-symbols.sh
. tests/lib/tool-debug-symbols.sh

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

echo "=== TOOL-005: debug symbols manifest ==="
for f in "$DOC" "$MANIFEST" compiler/src/runtime.c std/backtrace/backtrace.c compiler/src/lsp/lsp_diag.c; do
  if [ ! -f "$f" ]; then
    echo "tool-debug-symbols gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_rules) MIN_RULES="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
RULE_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-debug-symbols FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    rules)
      RULE_N=$((RULE_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-debug-symbols FAIL: doc missing rule $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      if [ ! -f "$src" ]; then
        echo "tool-debug-symbols FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF -- "$anchor" "$src" 2>/dev/null; then
        echo "tool-debug-symbols FAIL: anchor $anchor not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "tool-debug-symbols FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "tool-debug-symbols FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-debug-symbols FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-debug-symbols FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "tool-debug-symbols FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-debug-symbols FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$RULE_N" -lt "$MIN_RULES" ]; then
  echo "tool-debug-symbols gate FAIL: rules=${RULE_N} < min ${MIN_RULES}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "tool-debug-symbols gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in debug symbol breakpoint stack runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "tool-debug-symbols gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "tool-debug-symbols gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "tool-debug-symbols manifest OK (rules=${RULE_N} cases=${CASE_N})"

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHUX_BIN" ] && native_shu "$SHUX_BIN"; then
  echo "=== TOOL-005: debug symbol hooks (SHUX=$SHUX_BIN) ==="
  chmod +x tests/run-debug-symbols.sh tests/run-backtrace.sh
  SHUX="$SHUX_BIN" ./tests/run-debug-symbols.sh
  SHUX="$SHUX_BIN" ./tests/run-backtrace.sh
  echo "tool-debug-symbols hooks OK"
else
  echo "tool-debug-symbols gate SKIP hooks (no native shux)" >&2
fi

echo "tool-debug-symbols gate OK"
