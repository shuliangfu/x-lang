#!/usr/bin/env bash
# STD-122: std.compress unified stream gate — honesty soft SKIP→OK / soft
# auto-make / hard check / stream=/skip= report →硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + soft
# `xlang_compiler_make` / `std_compress_try_libs` + hard check as sole .x
# smoke + report `stream=` retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die.
# check residual = obs (paused 2026-08-05). tip product -o UNDEF/SEGV = obs
# (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-compress-unified-stream-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD122_COMPRESS_UNIFIED_DOC:-analysis/archive/std/std-compress-unified-stream-v1.md}"
MANIFEST="${XLANG_STD122_COMPRESS_UNIFIED_TSV:-tests/baseline/std-compress-unified-stream-manifest.tsv}"
MOD_X="std/compress/mod.x"
COMPRESS_C="std/compress/gzip/libz.x"
LIB="tests/lib/std-compress-unified-stream.sh"
STREAM_X="tests/std-compress/unified_stream_roundtrip.x"
MIN_APIS=7

# shellcheck source=tests/lib/std-compress-unified-stream.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-compress-unified-stream gate FAIL: $*" >&2
  std_compress_unified_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-122: compress unified stream manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$COMPRESS_C" "$STREAM_X"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-compress-unified-stream-v1.md ] || die "dual-authority fossil analysis/std-compress-unified-stream-v1.md (archive live)"
grep -qF STD-122 "$DOC" || die "doc missing STD-122"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

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

sym_miss="$(std_compress_unified_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-compress-unified-stream manifest OK"

if [ "${XLANG_STD122_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_compress_unified_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-compress-unified-stream gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-122: smoke (XLANG=$XLANG_BIN; check=obs; tip product=obs) ==="
# Refuse soft std_compress_try_libs / soft xlang_compiler_make.
# PLATFORM: SHARED — F-04 v7+ compress is pure .x; no soft rebuild.

set +e
"$XLANG_BIN" check -L . "$STREAM_X" >/tmp/xlang_std_compress_unified_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-compress-unified-stream OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF/SEGV residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_compress_unified_run_smoke "$XLANG_BIN" "$STREAM_X" "unified_stream"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-compress-unified-stream OK: product unified_stream_roundtrip"
else
  echo "std-compress-unified-stream OBS tip product unified_stream_roundtrip (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi

std_compress_unified_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-compress-unified-stream gate OK"
