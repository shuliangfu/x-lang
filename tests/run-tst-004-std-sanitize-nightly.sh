#!/usr/bin/env bash
# TST-004：std 模块 sanitizer 夜跑（ASAN heap/channel）
#
# 用法：./tests/run-tst-004-std-sanitize-nightly.sh
# 环境：
#   SHU_TST004_FAIL_ON_ERROR=1 — 任一案失败则 exit 1（默认）
set -e
cd "$(dirname "$0")/.."

MANIFEST="${SHU_TST004_TSV:-tests/baseline/tst-004-std-sanitize.tsv}"
LIB="tests/lib/tst-004-std-sanitize.sh"
# shellcheck source=tests/lib/tst-004-std-sanitize.sh
. "$LIB"

[ "${SHU_TST004_FAIL_ON_ERROR:-1}" = "1" ] && FAIL_ON_ERR=1 || FAIL_ON_ERR=0

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

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

echo "=== TST-004: std sanitizer nightly (ASAN) ==="

if ! safe_leak_asan_ok; then
  echo "tst-004-sanitize-nightly SKIP: cc missing -fsanitize=address" >&2
  tst004_sanitize_emit_report skip 0 0 1
  exit 0
fi

if [ -z "$SHU_BIN" ] || ! native_shu "$SHU_BIN"; then
  echo "tst-004-sanitize-nightly SKIP: no native shu" >&2
  tst004_sanitize_emit_report skip 0 0 1
  exit 0
fi

if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
  export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi

make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true

OK=0
FAIL=0
while IFS=$'\t' read -r item_id kind _anchor src needs_o _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    case_*)
      tst004_sanitize_ensure_o "${needs_o:--}"
      if tst004_sanitize_run_case "$SHU_BIN" "$src" "$item_id"; then
        echo "tst-004-sanitize-nightly OK $item_id"
        OK=$((OK + 1))
      else
        FAIL=$((FAIL + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$FAIL" -gt 0 ]; then
  tst004_sanitize_emit_report fail "$OK" "$FAIL" 0
  if [ "$FAIL_ON_ERR" -eq 1 ]; then
    exit 1
  fi
else
  tst004_sanitize_emit_report ok "$OK" 0 0
fi

echo "tst-004-std-sanitize-nightly OK"
