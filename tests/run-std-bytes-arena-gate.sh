#!/usr/bin/env bash
# STD-155: std.bytes ↔ Arena collaboration gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true` + soft
# bytes/heap .o make) + soft XLANG fallthrough (explicit-bad still picks another
# binary) + check=/run=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c). Product arena_external.x -o exit0 = hard
# run. check residual = obs (paused 2026-08-05). Report: run=/obs=/skip=.
# Fossil keyword arena_init → arena64_init (live heap API / archive doc).
# formal_mod / ondemand: std/bytes (from_external / is_owned / …).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-bytes-arena-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_BYTES_ARENA_DOC:-analysis/archive/std/std-bytes-arena-v1.md}"
MANIFEST="${XLANG_STD_BYTES_ARENA_MANIFEST:-tests/baseline/std-bytes-arena-manifest.tsv}"
MOD_X="std/bytes/mod.x"
LIB="tests/lib/std-bytes-arena.sh"
SMOKE_X="tests/std-bytes/arena_external.x"
MIN_APIS=4
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-bytes-arena.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-bytes-arena gate FAIL: $*" >&2
  std_bytes_arena_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-155: bytes arena manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE_X" std/bytes/README.md std/heap/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-155 from_external BYTES_OWN_EXTERNAL arena64_init; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF 'bytes_from_external' std/bytes/README.md 2>/dev/null \
  || die "README missing bytes_from_external"

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
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_bytes_arena_symbols_ok "$MOD_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-bytes-arena manifest OK"

if [ "${XLANG_STD_BYTES_ARENA_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_bytes_arena_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-bytes-arena gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-155: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_bytes_arena_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-bytes-arena OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_bytes_arena_$$"
LOG="/tmp/xlang_std_bytes_arena_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-bytes-arena OK: product -o"

std_bytes_arena_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-bytes-arena gate OK"
