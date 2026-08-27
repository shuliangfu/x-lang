#!/usr/bin/env bash
# TOOL-005: debug symbols manifest gate.
#
# Honesty: soft SKIP→OK when no native xlang (bare "gate OK") + prefer
# xlang-c before xlang_asm retired. Prefer product xlang_asm. Explicit
# bad XLANG = hard die. Missing native = hard die. DOC authority =
# archive/tool. Report run=/hooks=/skip=.
#
# Usage: ./tests/run-tool-debug-symbols-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tool-debug-symbols.sh
. tests/lib/tool-debug-symbols.sh

DOC="${XLANG_TOOL_DEBUG_DOC:-analysis/archive/tool/tool-debug-symbols-v1.md}"
MANIFEST="${XLANG_TOOL_DEBUG_MANIFEST:-tests/baseline/tool-debug-symbols.tsv}"
MIN_RULES=6
MIN_CASES=2
STRIP_NDEBUG_SRC="${XLANG_TOOL_DEBUG_STRIP_SRC:-compiler/seeds/labi_invoke_cc_list.from_x.c}"
BT_SRC="${XLANG_TOOL_DEBUG_BT_SRC:-compiler/seeds/runtime_backtrace_platform.from_x.c}"
LSP_SRC="${XLANG_TOOL_DEBUG_LSP_SRC:-compiler/src/lsp/lsp_diag.h}"
PREFIX="xlang: [XLANG_TOOL_DEBUG_SYMBOLS]"
RUN_OK=0
HOOKS_OK=0
SKIP=0

die() {
  echo "tool-debug-symbols gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} hooks=${HOOKS_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} hooks=${HOOKS_OK} skip=${SKIP} host=$(ci_host_summary)"
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== TOOL-005: debug symbols manifest (monofile retired) ==="
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (strip/NDEBUG live = labi_invoke_cc_list)"
fi
if [ -f analysis/tool-debug-symbols-v1.md ]; then
  die "top-level DOC resurrected (live = archive/tool/)"
fi
for f in "$DOC" "$MANIFEST" "$STRIP_NDEBUG_SRC" "$BT_SRC" "$LSP_SRC"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

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

[ "$RULE_N" -ge "$MIN_RULES" ] || die "rules=${RULE_N} < min ${MIN_RULES}"
[ "$CASE_N" -ge "$MIN_CASES" ] || die "cases=${CASE_N} < min ${MIN_CASES}"
for kw in debug symbol breakpoint stack runnable report; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "tool-debug-symbols manifest OK (rules=${RULE_N} cases=${CASE_N})"
RUN_OK=1

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== TOOL-005: debug symbol hooks (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-debug-symbols.sh tests/run-backtrace.sh
# Root fix (2026-08-25): -O 0 skips Darwin -dead_strip / Linux --gc-sections
# (invoke_cc + bare ld via xlang_link_capture_opt_level_from_argv). Hooks hard.
# PLATFORM: SHARED / MACOS|DARWIN nsyms / LINUX not-stripped.
set +e
XLANG="$XLANG_BIN" ./tests/run-debug-symbols.sh
dbg_ec=$?
XLANG="$XLANG_BIN" ./tests/run-backtrace.sh
bt_ec=$?
set -e
if [ "$dbg_ec" -eq 0 ] && [ "$bt_ec" -eq 0 ]; then
  HOOKS_OK=1
  echo "tool-debug-symbols hooks OK"
else
  die "hooks failed (dbg=$dbg_ec bt=$bt_ec host=$(uname -s))"
fi

ok_report
echo "tool-debug-symbols gate OK"
