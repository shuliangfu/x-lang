#!/usr/bin/env bash
# STD-098/STD-102/STD-104/STD-108：std.channel select 门禁
#
# 用法：./tests/run-std-channel-select-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_CHANNEL_SELECT_DOC:-analysis/std-channel-select-v1.md}"
MANIFEST="${SHUX_STD_CHANNEL_SELECT_TSV:-tests/baseline/std-channel-select.tsv}"
MOD_SX="std/channel/mod.sx"
CHANNEL_RUNTIME="${SHUX_STD_CHANNEL_IMPL:-compiler/src/asm/runtime_channel_glue.c}"
LIB="tests/lib/std-channel-select.sh"
SEL2_SX="tests/channel/select_2.sx"
SELN_SX="tests/channel/select_n.sx"
SEL_SEND2_SX="tests/channel/select_send_2.sx"
SEL_SENDN_SX="tests/channel/select_send_n.sx"
SEL_MIXED2_SX="tests/channel/select_mixed_2.sx"
SEL_MIXEDN_SX="tests/channel/select_mixed_n.sx"
MIN_APIS=13

# shellcheck source=tests/lib/std-channel-select.sh
. "$LIB"

echo "=== STD-098/102/104/108: channel select manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$CHANNEL_RUNTIME" "$SEL2_SX" "$SELN_SX" \
  "$SEL_SEND2_SX" "$SEL_SENDN_SX" "$SEL_MIXED2_SX" "$SEL_MIXEDN_SX"; do
  if [ ! -f "$f" ]; then
    echo "std-channel-select gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-098 STD-102 STD-104 STD-108 channel_select_try_recv_2 channel_select_recv_2 \
  channel_select_try_recv_n channel_select_recv_n channel_select_try_send_2 \
  channel_select_send_2 channel_select_try_send_n channel_select_send_n \
  channel_select_try_mixed_2 channel_select_mixed_2 channel_select_try_mixed_n \
  channel_select_mixed_n channel_select_dirs_set SELECT_DIR_RECV SELECT_TIMEDWAIT_MS \
  CHANNEL_SELECT_MAX; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-channel-select gate FAIL: doc missing '$kw'" >&2
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
        echo "std-channel-select gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-channel-select gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-channel-select gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_channel_select_symbols_ok "$MOD_SX" "$CHANNEL_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_channel_select_emit_report "fail" 0 0
  echo "std-channel-select gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-channel-select manifest OK"

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

SEL_OK=0
SKIP=1
SHUX_BIN=""
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-098/102/104/108: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/channel/channel.o
  for sx in "$SEL2_SX" "$SELN_SX" "$SEL_SEND2_SX" "$SEL_SENDN_SX" "$SEL_MIXED2_SX" "$SEL_MIXEDN_SX"; do
    if ! "$SHUX_BIN" check -L . "$sx" >/dev/null 2>&1; then
      echo "std-channel-select gate FAIL: typeck $sx" >&2
      "$SHUX_BIN" check -L . "$sx" 2>&1 | tail -10 >&2 || true
      std_channel_select_emit_report "fail" 0 0
      exit 1
    fi
  done
  if std_channel_select_run_smoke "$SHUX_BIN" "$SEL2_SX" "select2" \
    && std_channel_select_run_smoke "$SHUX_BIN" "$SELN_SX" "selectn" \
    && std_channel_select_run_smoke "$SHUX_BIN" "$SEL_SEND2_SX" "selectsend2" \
    && std_channel_select_run_smoke "$SHUX_BIN" "$SEL_SENDN_SX" "selectsendn" \
    && std_channel_select_run_smoke "$SHUX_BIN" "$SEL_MIXED2_SX" "selectmixed2" \
    && std_channel_select_run_smoke "$SHUX_BIN" "$SEL_MIXEDN_SX" "selectmixedn"; then
    SEL_OK=1
  else
    std_channel_select_emit_report "fail" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-channel-select gate SKIP smoke (no native shux)" >&2
fi

std_channel_select_emit_report "ok" "$SEL_OK" "$SKIP"
echo "std-channel-select gate OK"
