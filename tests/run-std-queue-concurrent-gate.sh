#!/usr/bin/env bash
# STD-048：std.queue 并发安全可选封装门禁
#
# 用法：./tests/run-std-queue-concurrent-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_QUEUE_CONCURRENT_DOC:-analysis/std-queue-concurrent-v1.md}"
MANIFEST="${SHU_STD_QUEUE_CONCURRENT_TSV:-tests/baseline/std-queue-concurrent.tsv}"
MOD_SU="std/queue/mod.su"
QUEUE_C="std/queue/queue.c"
CONTENTION_C="tests/queue/sync_queue_contention_ok.c"
LIB="tests/lib/std-queue-concurrent.sh"
SMOKE_SU="tests/queue/sync_queue_roundtrip.su"
MAIN_SU="tests/queue/main.su"
MIN_APIS=6

# shellcheck source=tests/lib/std-queue-concurrent.sh
. "$LIB"

echo "=== STD-048: queue concurrent manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$QUEUE_C" "$SMOKE_SU" "$MAIN_SU" "$CONTENTION_C"; do
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
      if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
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

sym_miss="$(std_queue_conc_symbols_ok "$MOD_SU" "$QUEUE_C" "$MANIFEST" || true)"
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
if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
else
  SHU_BIN=""
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-048: typeck + smoke (SHU=$SHU_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/queue/queue.o
  ensure_std_c_o ../std/sync/sync.o
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-queue-concurrent gate FAIL: typeck $SMOKE_SU" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_queue_conc_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if ! std_queue_conc_run_c_smoke "$QUEUE_C"; then
    std_queue_conc_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_queue_conc_run_smoke "$SHU_BIN" "$SMOKE_SU" "sync_rt"; then
    SYNC_OK=1
  else
    std_queue_conc_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_queue_conc_run_smoke "$SHU_BIN" "$MAIN_SU" "main"; then
    MAIN_OK=1
  else
    std_queue_conc_emit_report "fail" "$SYNC_OK" 0 0 0
    exit 1
  fi
  SMOKE_OK=1
  SKIP=0
else
  echo "std-queue-concurrent gate SKIP smoke (no native shu)" >&2
fi

std_queue_conc_emit_report "ok" "$SYNC_OK" "$MAIN_OK" "$SMOKE_OK" "$SKIP"
echo "std-queue-concurrent gate OK"
