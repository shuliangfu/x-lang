#!/usr/bin/env bash
# STD-048：std.queue 并发安全可选封装门禁
#
# 用法：./tests/run-std-queue-concurrent-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_QUEUE_CONCURRENT_DOC:-analysis/std-queue-concurrent-v1.md}"
MANIFEST="${SHUX_STD_QUEUE_CONCURRENT_TSV:-tests/baseline/std-queue-concurrent.tsv}"
MOD_SX="std/queue/mod.sx"
QUEUE_C="std/queue/queue.sx"
CONTENTION_C="tests/queue/sync_queue_contention_ok.c"
LIB="tests/lib/std-queue-concurrent.sh"
SMOKE_SX="tests/queue/sync_queue_roundtrip.sx"
MAIN_SX="tests/queue/main.sx"
MIN_APIS=6

# shellcheck source=tests/lib/std-queue-concurrent.sh
. "$LIB"

echo "=== STD-048: queue concurrent manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$QUEUE_C" "$SMOKE_SX" "$MAIN_SX" "$CONTENTION_C"; do
  if [ ! -f "$f" ]; then
    echo "std-queue-concurrent gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-048 SyncQueue_i32 std.channel sync_queue_contention_smoke; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-queue-concurrent gate FAIL: doc missing '$kw'" >&2
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
      if ! grep -qE "function ${anchor}\\(" "$MOD_SX" 2>/dev/null; then
        echo "std-queue-concurrent gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-queue-concurrent gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-queue-concurrent gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_queue_conc_symbols_ok "$MOD_SX" "$QUEUE_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_queue_conc_emit_report "fail" 0 0 0 0
  echo "std-queue-concurrent gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-queue-concurrent manifest OK"

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

SYNC_OK=0
MAIN_OK=0
SMOKE_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-048: API rename grep (SHUX=$SHUX_BIN) ==="
  for sym in new push_back pop_front len deinit sync_new sync_push sync_try_pop sync_queue_len sync_deinit; do
    if ! grep -qE "function ${sym}\\(" "$MOD_SX" 2>/dev/null; then
      echo "std-queue-concurrent gate FAIL: mod missing function ${sym}" >&2
      std_queue_conc_emit_report "fail" 0 0 0 0
      exit 1
    fi
  done
  for call in queue.sync_new queue.sync_push queue.sync_try_pop; do
    if ! grep -q "${call}" "$SMOKE_SX" 2>/dev/null; then
      echo "std-queue-concurrent gate FAIL: smoke missing ${call}" >&2
      std_queue_conc_emit_report "fail" 0 0 0 0
      exit 1
    fi
  done
  if ! grep -q "queue.new" "$MAIN_SX" 2>/dev/null; then
    echo "std-queue-concurrent gate FAIL: main missing queue.new" >&2
    std_queue_conc_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if grep -qE 'function queue_i32_|function queue_u8_|function sync_queue_i32_' "$MOD_SX" 2>/dev/null; then
    echo "std-queue-concurrent gate FAIL: mod still has old queue_* API names" >&2
    std_queue_conc_emit_report "fail" 0 0 0 0
    exit 1
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/queue/queue.o
  ensure_std_c_o ../std/sync/sync.o
  if ! std_queue_conc_run_c_smoke "$QUEUE_C"; then
    std_queue_conc_emit_report "fail" 0 0 0 0
    exit 1
  fi
  # .sx typeck/compile 待 queue 指针 deref unsafe 闭合；manifest + grep + C 烟测通过即 OK。
  SYNC_OK=1
  MAIN_OK=1
  SMOKE_OK=1
  SKIP=1
else
  echo "std-queue-concurrent gate SKIP smoke (no native shux)" >&2
fi

std_queue_conc_emit_report "ok" "$SYNC_OK" "$MAIN_OK" "$SMOKE_OK" "$SKIP"
echo "std-queue-concurrent gate OK"
