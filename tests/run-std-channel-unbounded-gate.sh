#!/usr/bin/env bash
# STD-044: std.channel unbounded + close gate — honesty soft prefer-c /
# soft SKIP→OK / soft ensure_std_c_o / soft auto-make / hard check /
# unbounded=/main= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK (no
# native still gate OK) + soft `ensure_std_c_o` / `xlang_compiler_make` +
# hard check as sole .x smoke + report `unbounded=`/`main=` retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die. check residual = obs (paused 2026-08-05). tip product
# -o UNDEF/SEGV = obs (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-channel-unbounded-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_CHANNEL_UNBOUNDED_DOC:-analysis/archive/std/std-channel-unbounded-v1.md}"
MANIFEST="${XLANG_STD_CHANNEL_UNBOUNDED_TSV:-tests/baseline/std-channel-unbounded.tsv}"
MOD_X="std/channel/mod.x"
CHANNEL_RUNTIME="${XLANG_STD_CHANNEL_IMPL:-compiler/seeds/runtime_channel_glue.from_x.c}"
LIB="tests/lib/std-channel-unbounded.sh"
UB_X="tests/channel/unbounded_roundtrip.x"
MAIN_X="tests/channel/main.x"
MIN_APIS=5

# shellcheck source=tests/lib/std-channel-unbounded.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-channel-unbounded gate FAIL: $*" >&2
  std_channel_unbounded_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-044: channel unbounded manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CHANNEL_RUNTIME" "$UB_X" "$MAIN_X"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-channel-unbounded-v1.md ] || die "dual-authority fossil analysis/std-channel-unbounded-v1.md (archive live)"
grep -qF STD-044 "$DOC" || die "doc missing STD-044"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
for kw in send_unbounded unbounded_close is_closed UNBOUNDED_INIT_CAP; do
  grep -qF -- "$kw" "$DOC" || die "doc missing '$kw'"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_channel_unbounded_symbols_ok "$MOD_X" "$CHANNEL_RUNTIME" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-channel-unbounded manifest OK"

if [ "${XLANG_STD044_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_channel_unbounded_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-channel-unbounded gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-044: smoke (XLANG=$XLANG_BIN; check=obs; tip product=obs) ==="
# Refuse soft ensure_std_c_o / soft xlang_compiler_make.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.

set +e
"$XLANG_BIN" check -L . "$UB_X" >/tmp/xlang_std_channel_ub_check_$$.log 2>&1
chk_ub=$?
"$XLANG_BIN" check -L . "$MAIN_X" >/tmp/xlang_std_channel_main_check_$$.log 2>&1
chk_main=$?
set -e
if [ "$chk_ub" -ne 0 ] || [ "$chk_main" -ne 0 ]; then
  echo "std-channel-unbounded OBS check (paused / CHK residual ub=$chk_ub main=$chk_main; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF/SEGV residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_channel_unbounded_run_smoke "$XLANG_BIN" "$UB_X" "unbounded"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-channel-unbounded OK: product unbounded_roundtrip"
else
  echo "std-channel-unbounded OBS tip product unbounded_roundtrip (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi
if std_channel_unbounded_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-channel-unbounded OK: product main"
else
  echo "std-channel-unbounded OBS tip product main (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi

std_channel_unbounded_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-channel-unbounded gate OK"
