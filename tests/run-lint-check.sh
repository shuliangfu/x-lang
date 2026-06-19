#!/usr/bin/env bash
# TOOL-002：linter 分层烟测（error / warn / info 通过 check + 环境开关表达）。
#
# 用法：./tests/run-lint-check.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/tool-lint.sh
. tests/lib/tool-lint.sh

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

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ] || ! native_shu "$SHUX_BIN"; then
  echo "lint-check SKIP (no native shux)" >&2
  echo "lint-check OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

CLEAN=tests/lint/lint_clean_ok.sx
ERR=tests/lint/lint_error_assign.sx
PAD=tests/lint/lint_warn_pad.sx
REORDER=tests/lint/lint_warn_reorder.sx
UNUSED=tests/lint/lint_unused_hint.sx

tool_lint_expect_check_silent "$SHUX_BIN" "$CLEAN"
echo "lint-check OK: clean silent"

tool_lint_expect_check_error "$SHUX_BIN" "$ERR"
echo "lint-check OK: error tier"

tool_lint_expect_warn_pad "$SHUX_BIN" "$PAD"
echo "lint-check OK: warn pad-fields"

tool_lint_expect_warn_reorder "$SHUX_BIN" "$REORDER"
echo "lint-check OK: warn hot-reorder"

tool_lint_expect_info_unused "$SHUX_BIN" "$UNUSED"
echo "lint-check OK: info unused-hint"

echo "lint-check OK"
