#!/usr/bin/env bash
# STD-045：std.sync RwLock/Condvar 门禁
#
# 用法：./tests/run-std-sync-rwlock-condvar-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_SYNC_RWLOCK_CONDVAR_DOC:-analysis/std-sync-rwlock-condvar-v1.md}"
MANIFEST="${SHUX_STD_SYNC_RWLOCK_CONDVAR_TSV:-tests/baseline/std-sync-rwlock-condvar.tsv}"
MOD_X="std/sync/mod.x"
SYNC_OS_RUNTIME="${SHUX_STD_SYNC_OS_IMPL:-compiler/src/asm/runtime_sync_os.inc}"
SYNC_X="std/sync/sync.x"
SYNC_TLS_RUNTIME="${SHUX_STD_SYNC_TLS_IMPL:-compiler/src/asm/runtime_sync_lock_diag_tls.inc}"
LIB="tests/lib/std-sync-rwlock-condvar.sh"
SMOKE_X="tests/sync/rwlock_condvar.x"
MAIN_X="tests/sync/main.x"
TSAN_C="tests/sync/sync_tsan_ok.c"
MIN_APIS=12

# shellcheck source=tests/lib/std-sync-rwlock-condvar.sh
. "$LIB"

echo "=== STD-045: sync RwLock/Condvar manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SYNC_X" "$SYNC_OS_RUNTIME" "$SYNC_TLS_RUNTIME" "$SMOKE_X" "$MAIN_X" "$TSAN_C"; do
  if [ ! -f "$f" ]; then
    echo "std-sync-rwlock-condvar gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-045 rwlock_new condvar_wait sync_tsan_ok rwlock_contention_smoke; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sync-rwlock-condvar gate FAIL: doc missing '$kw'" >&2
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
        echo "std-sync-rwlock-condvar gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sync-rwlock-condvar gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-sync-rwlock-condvar gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_sync_rc_symbols_ok "$MOD_X" "$SYNC_OS_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sync_rc_emit_report "fail" 0 0 0 0 0
  echo "std-sync-rwlock-condvar gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-sync-rwlock-condvar manifest OK"

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

RW_OK=0
CV_OK=0
MAIN_OK=0
TSAN_R="skip"
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-045: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/sync/sync.o
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-sync-rwlock-condvar gate FAIL: typeck $SMOKE_X" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_sync_rc_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if std_sync_rc_run_smoke "$SHUX_BIN" "$SMOKE_X" "rwlock_cv"; then
    RW_OK=1
    CV_OK=1
  else
    std_sync_rc_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if std_sync_rc_run_smoke "$SHUX_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
  else
    std_sync_rc_emit_report "fail" "$RW_OK" "$CV_OK" 0 0 0
    exit 1
  fi
  TSAN_R="$(std_sync_rc_try_tsan "$SYNC_OS_RUNTIME" || echo fail)"
  if [ "$TSAN_R" = "fail" ]; then
    std_sync_rc_emit_report "fail" "$RW_OK" "$CV_OK" "$MAIN_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-sync-rwlock-condvar gate SKIP smoke (no native shux)" >&2
fi

TSAN_OK=0
if [ "$TSAN_R" = "ok" ]; then
  TSAN_OK=1
fi
std_sync_rc_emit_report "ok" "$RW_OK" "$CV_OK" "$MAIN_OK" "$TSAN_OK" "$SKIP"
echo "std-sync-rwlock-condvar gate OK"
