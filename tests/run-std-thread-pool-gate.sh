#!/usr/bin/env bash
# STD-043：std.thread 线程池与命名线程门禁
#
# 用法：./tests/run-std-thread-pool-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_THREAD_POOL_DOC:-analysis/std-thread-pool-v1.md}"
MANIFEST="${SHUX_STD_THREAD_POOL_TSV:-tests/baseline/std-thread-pool.tsv}"
MOD_X="std/thread/mod.x"
THREAD_RUNTIME="${SHUX_STD_THREAD_IMPL:-compiler/src/asm/runtime_thread_glue.c}"
LIB="tests/lib/std-thread-pool.sh"
POOL_X="tests/thread/pool_roundtrip.x"
MAIN_X="tests/thread/main.x"
MIN_APIS=6

# shellcheck source=tests/lib/std-thread-pool.sh
. "$LIB"

echo "=== STD-043: thread pool manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$THREAD_RUNTIME" "$POOL_X" "$MAIN_X"; do
  if [ ! -f "$f" ]; then
    echo "std-thread-pool gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-043 thread_pool_start thread_set_name_self thread_pool_drain pool_roundtrip; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-thread-pool gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-thread-pool gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-thread-pool gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-thread-pool gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_thread_pool_symbols_ok "$MOD_X" "$THREAD_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_thread_pool_emit_report "fail" 0 0 0 0
  echo "std-thread-pool gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-thread-pool manifest OK"

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

POOL_OK=0
NAME_OK=0
MAIN_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-043: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/thread/thread.o
  if ! "$SHUX_BIN" check -L . "$POOL_X" >/dev/null 2>&1; then
    echo "std-thread-pool gate FAIL: typeck $POOL_X" >&2
    "$SHUX_BIN" check -L . "$POOL_X" 2>&1 | tail -10 >&2 || true
    std_thread_pool_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_thread_pool_run_smoke "$SHUX_BIN" "$POOL_X" "pool"; then
    POOL_OK=1
    NAME_OK=1
  else
    std_thread_pool_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_thread_pool_run_smoke "$SHUX_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
  else
    std_thread_pool_emit_report "fail" "$POOL_OK" "$NAME_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-thread-pool gate SKIP smoke (no native shux)" >&2
fi

std_thread_pool_emit_report "ok" "$POOL_OK" "$NAME_OK" "$MAIN_OK" "$SKIP"
echo "std-thread-pool gate OK"
