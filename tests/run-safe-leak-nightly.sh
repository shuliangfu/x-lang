#!/usr/bin/env bash
# SAFE-005：泄漏检测夜跑（Linux ASAN/LSAN）
#
# 用法：./tests/run-safe-leak-nightly.sh
# 环境：
#   SHUX_LEAK_PROBE=1 — 额外运行 leak_probe.c 校验探测器
#   SHUX_LEAK_FAIL_ON_LEAK=1 — 任一用例泄漏则 exit 1（CI 默认）
set -e
cd "$(dirname "$0")/.."

MANIFEST="${SHUX_LEAK_MANIFEST:-tests/baseline/safe-leak-nightly.tsv}"
# shellcheck source=tests/lib/safe-leak.sh
. tests/lib/safe-leak.sh

[ "${SHUX_LEAK_FAIL_ON_LEAK:-1}" = "1" ] && FAIL_ON_LEAK=1 || FAIL_ON_LEAK=0
[ "${SHUX_LEAK_PROBE:-0}" = "1" ] && RUN_PROBE=1 || RUN_PROBE=0

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
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

echo "=== SAFE-005: leak nightly (ASAN) ==="

if [ "$(uname -s)" != "Linux" ]; then
  echo "safe-leak-nightly SKIP: non-Linux host"
  safe_leak_emit_report skip 0 0 0
  exit 0
fi

if ! safe_leak_asan_ok; then
  echo "safe-leak-nightly SKIP: cc missing -fsanitize=address" >&2
  safe_leak_emit_report skip 0 0 0
  exit 0
fi

if [ -z "$SHUX_BIN" ] || ! native_shu "$SHUX_BIN"; then
  echo "safe-leak-nightly SKIP: no native shux" >&2
  safe_leak_emit_report skip 0 0 0
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
# F-03 v2：heap 已纯 .sx，不再 ensure heap.o
ensure_std_c_o ../std/ffi/ffi.o

OK=0
FAIL=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    case_*)
      if safe_leak_run_sx "$SHUX_BIN" "$src" "$item_id"; then
        echo "safe-leak-nightly OK $item_id"
        OK=$((OK + 1))
      else
        FAIL=$((FAIL + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$RUN_PROBE" -eq 1 ]; then
  safe_leak_run_probe || FAIL=$((FAIL + 1))
fi

if [ "$FAIL" -gt 0 ]; then
  safe_leak_emit_report fail "$OK" "$FAIL" "$FAIL"
  if [ "$FAIL_ON_LEAK" -eq 1 ]; then
    exit 1
  fi
else
  safe_leak_emit_report ok "$OK" 0 0
fi

echo "safe-leak-nightly OK"
