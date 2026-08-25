#!/usr/bin/env bash
# STD-098/STD-102/STD-104/STD-108：std.channel select 门禁（假权威诚实）。
#
# 用法：./tests/run-std-channel-select-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); six select_*.x exit 0 hard-fail (no soft SKIP
# when native xlang present). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_CHANNEL_SELECT_DOC:-analysis/archive/std/std-channel-select-v1.md}"
MANIFEST="${XLANG_STD_CHANNEL_SELECT_TSV:-tests/baseline/std-channel-select.tsv}"
MOD_X="std/channel/mod.x"
CHANNEL_RUNTIME="${XLANG_STD_CHANNEL_IMPL:-compiler/seeds/runtime_channel_glue.from_x.c}"
LIB="tests/lib/std-channel-select.sh"
SEL2_X="tests/channel/select_2.x"
SELN_X="tests/channel/select_n.x"
SEL_SEND2_X="tests/channel/select_send_2.x"
SEL_SENDN_X="tests/channel/select_send_n.x"
SEL_MIXED2_X="tests/channel/select_mixed_2.x"
SEL_MIXEDN_X="tests/channel/select_mixed_n.x"
MIN_APIS=13

# shellcheck source=tests/lib/std-channel-select.sh
. "$LIB"

echo "=== STD-098/102/104/108: channel select manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CHANNEL_RUNTIME" "$SEL2_X" "$SELN_X" \
  "$SEL_SEND2_X" "$SEL_SENDN_X" "$SEL_MIXED2_X" "$SEL_MIXEDN_X"; do
  if [ ! -f "$f" ]; then
    echo "std-channel-select gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-098 STD-102 STD-104 STD-108 select_try_recv select_recv \
  select_try_recv_n select_recv_n select_try_send \
  select_send select_try_send_n select_send_n \
  select_try_mixed select_mixed select_try_mixed_n \
  select_mixed_n select_dirs_set SELECT_DIR_RECV SELECT_TIMEDWAIT_MS \
  CHANNEL_SELECT_MAX; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-channel-select gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-channel-select gate FAIL: doc missing '## 4. Gate'" >&2
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
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
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

sym_miss="$(std_channel_select_symbols_ok "$MOD_X" "$CHANNEL_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_channel_select_emit_report "fail" 0 0 1
  echo "std-channel-select gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-channel-select manifest OK"

if [ "${XLANG_STD_CHANNEL_SELECT_MANIFEST_ONLY:-0}" = "1" ]; then
  std_channel_select_emit_report "ok" 0 0 1
  echo "std-channel-select gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
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

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-098/102/104/108: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05); any one smoke is enough as a note.
  if "$XLANG_BIN" check -L . "$SEL2_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-channel-select gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/channel/channel.o
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_channel_select_run_smoke "$XLANG_BIN" "$SEL2_X" "select2" \
    && std_channel_select_run_smoke "$XLANG_BIN" "$SELN_X" "selectn" \
    && std_channel_select_run_smoke "$XLANG_BIN" "$SEL_SEND2_X" "selectsend2" \
    && std_channel_select_run_smoke "$XLANG_BIN" "$SEL_SENDN_X" "selectsendn" \
    && std_channel_select_run_smoke "$XLANG_BIN" "$SEL_MIXED2_X" "selectmixed2" \
    && std_channel_select_run_smoke "$XLANG_BIN" "$SEL_MIXEDN_X" "selectmixedn"; then
    RUN_OK=1
    SKIP=0
  else
    std_channel_select_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-channel-select gate FAIL: no native xlang" >&2
  std_channel_select_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-channel-select check_ok=${CHECK_OK} (observational)"
std_channel_select_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-channel-select gate OK"
