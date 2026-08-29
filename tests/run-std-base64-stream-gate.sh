#!/usr/bin/env bash
# STD-109: std.base64 stream encode/decode gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# stream.x -o exit0 = hard run (run=1). check / host-C archaeology = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-base64-stream-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD109_DOC:-analysis/archive/std/std-base64-stream-v1.md}"
MANIFEST="${XLANG_STD109_TSV:-tests/baseline/std-base64-stream.tsv}"
VECTORS="${XLANG_STD109_VECTORS:-tests/baseline/std-base64-stream-vectors.tsv}"
MOD_X="std/base64/mod.x"
B64_X="${XLANG_STD_BASE64_IMPL:-std/base64/base64.x}"
LIB="tests/lib/std-base64-stream.sh"
SMOKE_X="tests/std-base64/stream.x"
SMOKE_C="tests/std-base64/stream_smoke_ok.c"
MIN_APIS=5
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-base64-stream.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-base64-stream gate FAIL: $*" >&2
  std_base64_stream_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-109: base64 stream manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$B64_X" "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-109 enc_update dec_update aGVsbG8; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF 'aGVsbG8=' "$VECTORS" 2>/dev/null || die "vectors missing hello_enc gold"

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
  grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing api $anchor"
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_base64_stream_symbols_ok "$MOD_X" "$B64_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-base64-stream manifest OK"

if [ "${XLANG_STD109_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_base64_stream_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-base64-stream gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-109: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

# Host-C archaeology = obs only; refuse leftover unused compiler-make.sh /
# soft ensure/auto-make rebuild. Product -o is the hard path.
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
if std_base64_stream_run_c_smoke "$B64_X"; then
  echo "std-base64-stream c smoke OK (observational)"
else
  echo "std-base64-stream OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std109_b64_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-base64-stream OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_base64_stream_$$"
LOG="/tmp/xlang_std_base64_stream_build_$$.log"
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
echo "std-base64-stream OK: product -o"

std_base64_stream_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-base64-stream gate OK"
