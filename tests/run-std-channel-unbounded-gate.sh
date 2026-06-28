#!/usr/bin/env bash
# STD-044：std.channel 无界模式与关闭语义门禁
#
# 用法：./tests/run-std-channel-unbounded-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_CHANNEL_UNBOUNDED_DOC:-analysis/std-channel-unbounded-v1.md}"
MANIFEST="${SHUX_STD_CHANNEL_UNBOUNDED_TSV:-tests/baseline/std-channel-unbounded.tsv}"
MOD_SX="std/channel/mod.sx"
CHANNEL_RUNTIME="${SHUX_STD_CHANNEL_IMPL:-compiler/src/asm/runtime_channel_glue.c}"
LIB="tests/lib/std-channel-unbounded.sh"
UB_SX="tests/channel/unbounded_roundtrip.sx"
MAIN_SX="tests/channel/main.sx"
MIN_APIS=5

# shellcheck source=tests/lib/std-channel-unbounded.sh
. "$LIB"

echo "=== STD-044: channel unbounded manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$CHANNEL_RUNTIME" "$UB_SX" "$MAIN_SX"; do
  if [ ! -f "$f" ]; then
    echo "std-channel-unbounded gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-044 send_unbounded unbounded_close is_closed UNBOUNDED_INIT_CAP; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-channel-unbounded gate FAIL: doc missing '$kw'" >&2
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
        echo "std-channel-unbounded gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-channel-unbounded gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-channel-unbounded gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_channel_unbounded_symbols_ok "$MOD_SX" "$CHANNEL_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_channel_unbounded_emit_report "fail" 0 0 0
  echo "std-channel-unbounded gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-channel-unbounded manifest OK"

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

UB_OK=0
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
  echo "=== STD-044: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/channel/channel.o
  if ! "$SHUX_BIN" check -L . "$UB_SX" >/dev/null 2>&1; then
    echo "std-channel-unbounded gate FAIL: typeck $UB_SX" >&2
    "$SHUX_BIN" check -L . "$UB_SX" 2>&1 | tail -10 >&2 || true
    std_channel_unbounded_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_channel_unbounded_run_smoke "$SHUX_BIN" "$UB_SX" "unbounded"; then
    UB_OK=1
  else
    std_channel_unbounded_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_channel_unbounded_run_smoke "$SHUX_BIN" "$MAIN_SX" "main"; then
    MAIN_OK=1
  else
    std_channel_unbounded_emit_report "fail" "$UB_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-channel-unbounded gate SKIP smoke (no native shux)" >&2
fi

std_channel_unbounded_emit_report "ok" "$UB_OK" "$MAIN_OK" "$SKIP"
echo "std-channel-unbounded gate OK"
