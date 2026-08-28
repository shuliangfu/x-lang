#!/usr/bin/env bash
# WPO-S1 烟测：call graph JSON 导出 + wpo_dce 死代码统计（NEXT §4.1 WPO-S1）
#
# Honesty 2026-08-25: product path = xlang_asm check + XLANG_WPO_DUMP_CALLGRAPH
# (pipeline_typeck_wpo_dump_callgraph). Prefer asm; pin LINK. Hard-fail if graph
# missing (no soft SKIP).
# Honesty 2026-08-29: leftover auto-make (`xlang_compiler_make -q ||
# xlang_compiler_make`) retired — that path kicked g05 and hid CHK002 cwd
# failures. Prefer product xlang_asm; explicit bad XLANG / missing native =
# hard die. PLATFORM: SHARED.
set -e
cd "$(dirname "$0")/.."

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
  echo "wpo-s1 FAIL: no native xlang (refuse leftover auto-make)" >&2
  exit 1
fi
# Refuse leftover auto-make of missing compiler; resolved native must already exist.

GRAPH="/tmp/xlang_wpo_dead_fn.json"
rm -f "$GRAPH"

# check gate paused 2026-08-05. Dump is still the live WPO_DUMP_CALLGRAPH
# hook; CHK002 / missing graph is a check residual, not leftover auto-make.
# PLATFORM: SHARED — parent COMP-004 counts s1 fail as obs.
set +e
XLANG_WPO_DUMP_CALLGRAPH="$GRAPH" "$XLANG_BIN" check tests/wpo/dead_fn.x >/tmp/xlang_wpo_s1_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ] || [ ! -s "$GRAPH" ]; then
  echo "wpo-s1 FAIL: check dump (paused / CHK residual ec=$chk graph=$( [ -s "$GRAPH" ] && echo yes || echo no ); refuse leftover auto-make)" >&2
  exit 1
fi

perl compiler/scripts/wpo_dce.pl "$GRAPH" --expect-dead dead_helper | tee /tmp/wpo_dce.log
grep -q 'wpo_dce OK' /tmp/wpo_dce.log

echo "wpo-s1 smoke OK"
