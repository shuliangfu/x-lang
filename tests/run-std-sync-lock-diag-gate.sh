#!/usr/bin/env bash
# STD-111：std.sync 调试锁诊断门禁（F-sync-lock-diag v2：逻辑在 sync.x，TLS 在 tls glue）
#
# 用法：./tests/run-std-sync-lock-diag-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD111_DOC:-analysis/std-sync-lock-diag-v1.md}"
MANIFEST="${SHUX_STD111_TSV:-tests/baseline/std-sync-lock-diag.tsv}"
MOD_X="std/sync/mod.x"
SYNC_DIAG_X="std/sync/sync.x"
SYNC_TLS_RUNTIME="${SHUX_STD_SYNC_TLS_IMPL:-compiler/src/asm/runtime_sync_lock_diag_tls.c}"
SYNC_OS_RUNTIME="${SHUX_STD_SYNC_OS_IMPL:-compiler/src/asm/runtime_sync_os.c}"
SYNC_X="std/sync/sync.x"
LIB="tests/lib/std-sync-lock-diag.sh"
SMOKE_X="tests/sync/lock_diag.x"
SMOKE_C="tests/sync/lock_diag_smoke_ok.c"
MIN_APIS=8

# shellcheck source=tests/lib/std-sync-lock-diag.sh
. "$LIB"

echo "=== STD-111: sync lock diag manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SYNC_X" "$SYNC_OS_RUNTIME" "$SYNC_DIAG_X" "$SYNC_TLS_RUNTIME" "$SMOKE_X" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-sync-lock-diag gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-111 lock_diag_set_enabled lock_diag_err_order sync_lock_diag_smoke_c; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sync-lock-diag gate FAIL: doc missing '$kw'" >&2
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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-sync-lock-diag FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-sync-lock-diag gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_sync_lock_diag_symbols_ok "$MOD_X" "$SYNC_DIAG_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sync_lock_diag_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sync-lock-diag manifest OK"

C_OK=0
X_OK=0
SKIP=0

echo "=== STD-111: sync lock diag c smoke ==="
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  if ensure_std_c_o ../std/sync/sync.o 2>/dev/null && std_sync_lock_diag_run_c_smoke "$SYNC_TLS_RUNTIME"; then
    C_OK=1
  else
    echo "std-sync-lock-diag gate SKIP c smoke (no full sync.o)" >&2
  fi
else
  echo "std-sync-lock-diag gate SKIP c smoke (no shux-c)" >&2
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-111: .x smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-sync-lock-diag gate FAIL: typeck $SMOKE_X" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_sync_lock_diag_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_sync_lock_diag_run_x_smoke "$SHUX_BIN" "$SMOKE_X" "diag"; then
    X_OK=1
  else
    std_sync_lock_diag_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_sync_lock_diag_emit_report "ok" "$C_OK" "$X_OK" "$SKIP"
echo "std-sync-lock-diag gate OK"
