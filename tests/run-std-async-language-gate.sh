#!/usr/bin/env bash
# STD-041：std.async 与 language async/await 对接门禁
#
# manifest + typeck + run/mod 烟测 + 1M task 委托
# 用法：./tests/run-std-async-language-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_ALANG_DOC:-analysis/std-async-language-v1.md}"
MANIFEST="${SHUX_STD_ALANG_TSV:-tests/baseline/std-async-language.tsv}"
MOD_SU="std/async/mod.sx"
SCHED_C="std/async/scheduler.c"
LIB="tests/lib/std-async-language.sh"
RUN_SU="tests/async/await_scheduler_run.sx"
MOD_TEST_SU="tests/async/await_scheduler_mod.sx"

# shellcheck source=tests/lib/std-async-language.sh
. tests/lib/std-async-language.sh

echo "=== STD-041: async language bridge manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SCHED_C" "$RUN_SU" "$MOD_TEST_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-async-language gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in scheduler_reset drain_until_idle await_scheduler_run async_1m_coop extern 重声明; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-async-language gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "shux_async_run_i32" "$SCHED_C" 2>/dev/null; then
  echo "std-async-language gate FAIL: scheduler.c missing shux_async_run_i32" >&2
  exit 1
fi

sym_miss="$(std_alang_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_alang_emit_report "fail" 0 0 1
  echo "std-async-language gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-async-language manifest OK"

stdlib_cm_native_shu() {
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

RUN_OK=0
MOD_OK=0
SKIP_1M=1
resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-041: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q ../std/async/scheduler.o 2>/dev/null || make -C compiler ../std/async/scheduler.o 2>/dev/null || true
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  for su in "$RUN_SU" "$MOD_TEST_SU"; do
    if ! "$SHUX_BIN" check -L . "$su" >/dev/null 2>&1; then
      echo "std-async-language gate FAIL: typeck $su" >&2
      "$SHUX_BIN" check -L . "$su" 2>&1 | tail -10 >&2 || true
      std_alang_emit_report "fail" "$RUN_OK" "$MOD_OK" 1
      exit 1
    fi
  done
  if std_alang_run_smoke "$SHUX_BIN" "$RUN_SU" "/tmp/shux_async_alang_run"; then
    RUN_OK=1
  else
    std_alang_emit_report "fail" 0 0 1
    exit 1
  fi
  if std_alang_run_smoke "$SHUX_BIN" "$MOD_TEST_SU" "/tmp/shux_async_alang_mod"; then
    MOD_OK=1
  else
    std_alang_emit_report "fail" "$RUN_OK" 0 1
    exit 1
  fi
  SKIP_1M=0
  echo "=== STD-041: delegate 1M task stress ==="
  chmod +x tests/run-std-async-1m-gate.sh
  if ! SHUX="$SHUX_BIN" ./tests/run-std-async-1m-gate.sh; then
    std_alang_emit_report "fail" "$RUN_OK" "$MOD_OK" 0
    exit 1
  fi
else
  echo "std-async-language gate SKIP smoke/1m (no native shux-c)" >&2
fi

std_alang_emit_report "ok" "$RUN_OK" "$MOD_OK" "$SKIP_1M"
echo "std-async-language gate OK"
