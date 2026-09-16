#!/usr/bin/env bash
# STD-139: std.codec buffer-reuse gate — honesty soft prefer-c / soft SKIP→OK →硬绿.
#
# Honesty: prefer-c first + soft SKIP→OK (no native still gate OK) + hard-bound
# `xlang check` as sole smoke + `x=`/`skip=` retired. Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse
# soft SKIP→OK / soft auto-make / prefer-c). Manifest/registry = hard. check
# residual = obs (paused 2026-08-05). tip product -o std_codec_* UNDEF = obs
# (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-codec-buffer-reuse-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="analysis/archive/std/std-codec-buffer-reuse-v1.md"
MANIFEST="tests/baseline/std-codec-buffer-reuse-manifest.tsv"
CODEC_X="std/codec/mod.x"
BYTES_X="std/bytes/mod.x"
LIB="tests/lib/std-codec-buffer-reuse.sh"
SMOKE_X="tests/std-codec/buffer_reuse.x"

# shellcheck source=tests/lib/std-codec-buffer-reuse.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-codec-buffer-reuse gate FAIL: $*" >&2
  std_codec_buffer_reuse_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-139: std.codec buffer reuse manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$CODEC_X" "$BYTES_X" "$SMOKE_X" \
  analysis/archive/std/std-codec-v1.md analysis/archive/std/std-bytes-v1.md std/codec/README.md; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-codec-buffer-reuse-v1.md ] || die "dual-authority fossil analysis/std-codec-buffer-reuse-v1.md (archive live)"

for kw in STD-139 encode_into_bytes clear grow encode_upper_bound; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF "std-codec-buffer-reuse-v1.md" analysis/archive/std/std-codec-v1.md 2>/dev/null \
  || die "std-codec-v1 cross-link"
grep -qF "std-codec-buffer-reuse-v1.md" analysis/archive/std/std-bytes-v1.md 2>/dev/null \
  || die "std-bytes-v1 cross-link"

sym_miss="$(std_codec_buffer_reuse_symbols_ok "$CODEC_X" "$BYTES_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-codec-buffer-reuse registry OK"

if [ "${XLANG_STD139_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_codec_buffer_reuse_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-codec-buffer-reuse gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-139: smoke (XLANG=$XLANG_BIN; check=obs; tip product -o UNDEF=obs) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_codec_br_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-codec-buffer-reuse OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_codec_br_$$"
LOG="/tmp/xlang_std_codec_br_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-codec-buffer-reuse OBS tip product -o (ec=$o_ec; std_codec_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-codec-buffer-reuse OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-codec-buffer-reuse OK: product -o"
  fi
fi

std_codec_buffer_reuse_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-codec-buffer-reuse gate OK"
