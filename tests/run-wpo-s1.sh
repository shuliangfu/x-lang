#!/usr/bin/env bash
# WPO-S1 烟测：call graph JSON 导出 + wpo_dce 死代码统计（NEXT §4.1 WPO-S1）
#
# Honesty 2026-08-25: product path = xlang_asm check + XLANG_WPO_DUMP_CALLGRAPH
# (pipeline_typeck_wpo_dump_callgraph). Prefer asm; pin LINK. Hard-fail if graph
# missing (no soft SKIP). PLATFORM: SHARED.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

native_xlang() {
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

XLANG_BIN="${XLANG:-}"
if [ -z "$XLANG_BIN" ]; then
  for cand in ./compiler/xlang_asm ./compiler/xlang ./compiler/xlang-c; do
    if native_xlang "$cand"; then
      XLANG_BIN="$cand"
      break
    fi
  done
fi
if [ -n "$XLANG_BIN" ] && [ -z "${XLANG_LINK_XLANG:-}" ]; then
  export XLANG_LINK_XLANG="$XLANG_BIN"
fi
if [ -z "$XLANG_BIN" ] || ! native_xlang "$XLANG_BIN"; then
  echo "wpo-s1 FAIL: no native xlang" >&2
  exit 1
fi

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

GRAPH="/tmp/xlang_wpo_dead_fn.json"
rm -f "$GRAPH"

XLANG_WPO_DUMP_CALLGRAPH="$GRAPH" "$XLANG_BIN" check tests/wpo/dead_fn.x >/dev/null
[ -s "$GRAPH" ] || { echo "WPO graph not written ($GRAPH)"; exit 1; }

perl compiler/scripts/wpo_dce.pl "$GRAPH" --expect-dead dead_helper | tee /tmp/wpo_dce.log
grep -q 'wpo_dce OK' /tmp/wpo_dce.log

echo "wpo-s1 smoke OK"
