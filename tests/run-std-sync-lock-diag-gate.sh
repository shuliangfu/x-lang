#!/usr/bin/env bash
# STD-111：std.sync 调试锁诊断门禁
#
# 用法：./tests/run-std-sync-lock-diag-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD111_DOC:-analysis/std-sync-lock-diag-v1.md}"
MANIFEST="${SHU_STD111_TSV:-tests/baseline/std-sync-lock-diag.tsv}"
MOD_SU="std/sync/mod.su"
SYNC_C="std/sync/sync.c"
LIB="tests/lib/std-sync-lock-diag.sh"
SMOKE_SU="tests/sync/lock_diag.su"
SMOKE_C="tests/sync/lock_diag_smoke_ok.c"
MIN_APIS=8

# shellcheck source=tests/lib/std-sync-lock-diag.sh
. "$LIB"

echo "=== STD-111: sync lock diag manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SYNC_C" "$SMOKE_SU" "$SMOKE_C"; do
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

sym_miss="$(std_sync_lock_diag_symbols_ok "$MOD_SU" "$SYNC_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sync_lock_diag_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sync-lock-diag manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/sync/sync.o

C_OK=0
if std_sync_lock_diag_run_c_smoke "$SYNC_C"; then
  C_OK=1
else
  std_sync_lock_diag_emit_report "fail" 0 0 0
  exit 1
fi

SU_OK=0
SKIP=0
SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-111: .su smoke (SHU=$SHU_BIN) ==="
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-sync-lock-diag gate FAIL: typeck $SMOKE_SU" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_sync_lock_diag_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_sync_lock_diag_run_su_smoke "$SHU_BIN" "$SMOKE_SU" "diag"; then
    SU_OK=1
  else
    std_sync_lock_diag_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_sync_lock_diag_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-sync-lock-diag gate OK"
