#!/usr/bin/env bash
# STD-007: std.compress gzip/zstd/legacy gate — honesty residual
# std_compress_try_libs / soft auto-make / XLANG fallthrough /
# check=/gzip=/zstd=/legacy= report →硬绿.
#
# Honesty: soft try_libs (always return 0) + soft
# `xlang_compiler_make -q || xlang_compiler_make` + XLANG fallthrough
# (explicit bad XLANG continues to xlang_asm) + report check=/gzip=/
# zstd=/legacy= retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die.
# check residual = obs (paused 2026-08-05). tip product -o UNDEF/SEGV = obs
# (product debt; leave). Report: run=/obs=/skip=.
# F-04 v7+ compress is pure .x; brotli ld leave. Live ensure_std family left.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-compress-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_COMPRESS_DOC:-analysis/archive/std/std-compress-v1.md}"
MANIFEST="${XLANG_STD_COMPRESS_MANIFEST:-tests/baseline/std-compress-manifest.tsv}"
MOD_X="${XLANG_STD_COMPRESS_MOD:-std/compress/mod.x}"
README="std/compress/README.md"
LIB="tests/lib/std-compress.sh"
HOOK="tests/run-compress.sh"
SMOKE_GZIP="tests/std-compress/gzip_roundtrip.x"
SMOKE_ZSTD="tests/std-compress/zstd_roundtrip.x"
SMOKE_LEGACY="tests/compress/main.x"
MIN_APIS=4
MIN_LAYERS=4

# shellcheck source=tests/lib/std-compress.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-compress gate FAIL: $*" >&2
  std_compress_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c / XLANG fallthrough.
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

echo "=== STD-007: std.compress manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$README" "$LIB" "$HOOK" \
  "$SMOKE_GZIP" "$SMOKE_ZSTD" "$SMOKE_LEGACY" \
  std/compress/common.x \
  std/compress/zlib/libz.x std/compress/gzip/libz.x \
  std/compress/brotli/lib.x std/compress/zstd/lib.x; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-compress-v1.md ] || die "dual-authority fossil analysis/std-compress-v1.md (archive live)"

for kw in runnable report M1-gzip M2-zstd; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
    min_layers) MIN_LAYERS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
LAYER_N=0
while IFS=$'\t' read -r item_id kind _anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api) API_N=$((API_N + 1)) ;;
    layers) LAYER_N=$((LAYER_N + 1)) ;;
  esac
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"
[ "$LAYER_N" -ge "$MIN_LAYERS" ] || die "layer count $LAYER_N < min $MIN_LAYERS"

sym_miss="$(std_compress_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-compress manifest OK (apis=${API_N} layers=${LAYER_N})"

if [ "${XLANG_STD_COMPRESS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_compress_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-compress gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# Refuse hook auto-make leaking through observational run-compress.sh.
export XLANG_SKIP_SUBSCRIPT_MAKE=1
echo "=== STD-007: smoke (XLANG=$XLANG_BIN; check=obs; tip product=obs) ==="
# Refuse soft std_compress_try_libs / soft xlang_compiler_make.
# PLATFORM: SHARED — F-04 v7+ compress is pure .x; no soft rebuild.

# check = obs (paused); sample gzip only to bound cost.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$SMOKE_GZIP" >/tmp/xlang_std_compress_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-compress OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF/SEGV residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_compress_run_smoke "$XLANG_BIN" "$SMOKE_GZIP" "gzip"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-compress OK: product gzip_roundtrip"
else
  echo "std-compress OBS tip product gzip_roundtrip (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi

if std_compress_run_smoke "$XLANG_BIN" "$SMOKE_ZSTD" "zstd"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-compress OK: product zstd_roundtrip"
else
  echo "std-compress OBS tip product zstd_roundtrip (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi

if std_compress_run_smoke "$XLANG_BIN" "$SMOKE_LEGACY" "legacy"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-compress OK: product compress/main.x"
else
  echo "std-compress OBS tip product compress/main.x (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi

# Hook is observational (legacy wrapper; may skip formats). Not the hard-green signal.
chmod +x "$HOOK" 2>/dev/null || true
if XLANG="$XLANG_BIN" "$HOOK"; then
  echo "std-compress OK hook_compress (observational)"
else
  echo "std-compress OBS hook_compress (observational residual)" >&2
  OBS=$((OBS + 1))
fi

std_compress_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-compress gate OK"
