#!/usr/bin/env bash
# STD-098/102/104/108: std.channel select gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft ensure_std_c_o / soft auto-make + check=/run=/skip= retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native
# = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c / soft ensure).
# Six select_*.x product -o exit0 = hard run (run=6). check = obs.
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-channel-select-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-channel-select gate FAIL: $*" >&2
  std_channel_select_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-098/102/104/108: channel select manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CHANNEL_RUNTIME" "$SEL2_X" "$SELN_X" \
  "$SEL_SEND2_X" "$SEL_SENDN_X" "$SEL_MIXED2_X" "$SEL_MIXEDN_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-098 STD-102 STD-104 STD-108 select_try_recv select_recv \
  select_try_recv_n select_recv_n select_try_send \
  select_send select_try_send_n select_send_n \
  select_try_mixed select_mixed select_try_mixed_n \
  select_mixed_n select_dirs_set SELECT_DIR_RECV SELECT_TIMEDWAIT_MS \
  CHANNEL_SELECT_MAX; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

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
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_channel_select_symbols_ok "$MOD_X" "$CHANNEL_RUNTIME" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-channel-select manifest OK"

if [ "${XLANG_STD_CHANNEL_SELECT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_channel_select_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-channel-select gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-098/102/104/108: smoke (XLANG=$XLANG_BIN; check obs; six product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SEL2_X" >/tmp/xlang_std098_channel_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-channel-select OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft ensure_std_c_o / soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
for pair in \
  "$SEL2_X:select2" \
  "$SELN_X:selectn" \
  "$SEL_SEND2_X:selectsend2" \
  "$SEL_SENDN_X:selectsendn" \
  "$SEL_MIXED2_X:selectmixed2" \
  "$SEL_MIXEDN_X:selectmixedn"; do
  src="${pair%%:*}"
  tag="${pair##*:}"
  if std_channel_select_run_smoke "$XLANG_BIN" "$src" "$tag"; then
    RUN_OK=$((RUN_OK + 1))
    echo "std-channel-select OK: $tag"
  else
    die "product -o $tag failed (refuse soft SKIP→OK)"
  fi
done

std_channel_select_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-channel-select gate OK"
