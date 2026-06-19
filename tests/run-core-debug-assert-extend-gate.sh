#!/usr/bin/env bash
# CORE-012：core.debug 断言类型扩展门禁
#
# 用法：./tests/run-core-debug-assert-extend-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_CORE_DEBUG_ASSERT_EXTEND_DOC:-analysis/core-debug-assert-extend-v1.md}"
MANIFEST="${SHUX_CORE_DEBUG_ASSERT_EXTEND_TSV:-tests/baseline/core-debug-assert-extend.tsv}"
DEBUG_SU="core/debug/mod.sx"
LIB="tests/lib/core-debug-assert-extend.sh"
SMOKE="tests/debug/assert_extend.sx"
REGRESS="tests/debug/main.sx"
MIN_SYMBOLS=6

# shellcheck source=tests/lib/core-debug-assert-extend.sh
. tests/lib/core-debug-assert-extend.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== CORE-012: debug assert extend manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$DEBUG_SU" "$SMOKE" "$REGRESS"; do
  if [ ! -f "$f" ]; then
    echo "core-debug-assert-extend gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_symbols) MIN_SYMBOLS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in assert_eq_u64 assert_eq_ptr assert_ne_bool panic; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-debug-assert-extend gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
SYM_N=0
while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "core-debug-assert-extend FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol) SYM_N=$((SYM_N + 1)) ;;
    smoke)
      if ! grep -qF "$anchor" "$SMOKE" 2>/dev/null; then
        echo "core-debug-assert-extend FAIL: smoke missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SYM_N" -lt "$MIN_SYMBOLS" ] || [ "$MISS" -gt 0 ]; then
  echo "core-debug-assert-extend gate FAIL: symbols=${SYM_N} miss=${MISS}" >&2
  exit 1
fi

sym_miss="$(core_debug_assert_extend_symbols_ok "$DEBUG_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_debug_assert_extend_emit_report "fail" 0 1
  exit 1
fi
echo "core-debug-assert-extend manifest OK (symbols=${SYM_N})"

SKIP=1
CHECK_OK=0
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
  make -C compiler -q 2>/dev/null || make -C compiler
  if "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
    SKIP=0
  else
    "$SHUX_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    core_debug_assert_extend_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "core-debug-assert-extend gate SKIP typeck (no native shux)" >&2
fi

core_debug_assert_extend_emit_report "ok" "$CHECK_OK" "$SKIP"
echo "core-debug-assert-extend gate OK"
