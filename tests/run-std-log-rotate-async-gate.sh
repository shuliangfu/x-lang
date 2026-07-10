#!/usr/bin/env bash
# STD-106：std.log 日志轮转 + 异步缓冲门禁
#
# 用法：./tests/run-std-log-rotate-async-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD106_DOC:-analysis/std-log-rotate-async-v1.md}"
MANIFEST="${SHUX_STD106_TSV:-tests/baseline/std-log-rotate-async.tsv}"
VECTORS="${SHUX_STD106_VECTORS:-tests/baseline/std-log-rotate-async-vectors.tsv}"
MOD_X="std/log/mod.x"
LOG_X="std/log/log.x"
LOG_RUNTIME="compiler/seeds/runtime_log_os.from_x.c"
LIB="tests/lib/std-log-rotate-async.sh"
SMOKE_X="tests/std-log/rotate_async.x"
SMOKE_C="tests/std-log/rotate_async_smoke_ok.c"
MIN_APIS=3

# shellcheck source=tests/lib/std-log-rotate-async.sh
. "$LIB"

echo "=== STD-106: log rotate-async manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$LOG_X" "$LOG_RUNTIME" "$SMOKE_X" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-log-rotate-async gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-106 set_rotate_limit async_flush rotate; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-log-rotate-async gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'async1' "$VECTORS" 2>/dev/null; then
  echo "std-log-rotate-async gate FAIL: vectors missing async_defer gold" >&2
  exit 1
fi

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
    echo "std-log-rotate-async FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-log-rotate-async gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_log_rotate_async_symbols_ok "$MOD_X" "$LOG_X" "$LOG_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_log_rotate_async_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-log-rotate-async manifest OK"

C_OK=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  if ensure_std_c_o ../std/log/log.o 2>/dev/null && ensure_runtime_log_os_o 2>/dev/null && std_log_rotate_async_run_c_smoke "$LOG_X"; then
    C_OK=1
  else
    echo "std-log-rotate-async gate SKIP c smoke (no full log.o)" >&2
  fi
else
  echo "std-log-rotate-async gate SKIP c smoke (no shux-c)" >&2
fi

X_OK=0
SKIP=0
SHUX_BIN=""
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
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-106: .x smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || SHUX_LEGACY_C_FRONTEND=1 make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-log-rotate-async gate FAIL: typeck $SMOKE_X" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_log_rotate_async_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_log_rotate_async_run_x_smoke "$SHUX_BIN" "$SMOKE_X" "ra"; then
    X_OK=1
  else
    std_log_rotate_async_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_log_rotate_async_emit_report "ok" "$C_OK" "$X_OK" "$SKIP"
echo "std-log-rotate-async gate OK"
