#!/usr/bin/env bash
# B-SIZE: xlang_asm stripped size track (ENG-002 advisory; default does not
# block CI).
#
# Honesty: soft XLANG_SIZE_FAIL:-0 overage still printed WARN then exit 0
# without obs= was portable false-green for B-SIZE. Missing xlang_asm soft
# SKIP→OK retired — refuse soft silence when the product binary is absent.
# Overage = obs (advisory residual; XLANG_SIZE_FAIL=1 still hard). Prefer
# product xlang_asm. Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-size-xlang-asm-gate.sh
#   XLANG_ASM=./compiler/xlang_asm ./tests/run-size-xlang-asm-gate.sh
# Env:
#   XLANG_SIZE_XLANG_ASM_MAX_BYTES — cap bytes (default 8388608 = 8MiB)
#   XLANG_SIZE_FAIL=1 — overage hard-fail (opt-in only; CI default 0)
# PLATFORM: SHARED archaeology (ENG-002; Ubuntu gold still required).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

XLANG_ASM="${XLANG_ASM:-./compiler/xlang_asm}"
MAX_BYTES="${XLANG_SIZE_XLANG_ASM_MAX_BYTES:-$((8 * 1024 * 1024))}"
BASELINE="tests/baseline/xlang-asm-size.tsv"
PREFIX="xlang: [XLANG_SIZE_XLANG_ASM]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "size gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

if [ ! -x "$XLANG_ASM" ]; then
  die "no xlang_asm at $XLANG_ASM (refuse soft SKIP→OK)"
fi

file_bytes() {
  local f="$1"
  if [ "$(uname -s)" = "Darwin" ]; then
    stat -f%z "$f" 2>/dev/null || wc -c <"$f"
  else
    stat -c%s "$f" 2>/dev/null || wc -c <"$f"
  fi
}

STRIPPED="$(mktemp /tmp/xlang_asm_stripped.XXXXXX)"
cp "$XLANG_ASM" "$STRIPPED"
if command -v strip >/dev/null 2>&1; then
  strip "$STRIPPED" 2>/dev/null || true
fi

SZ=$(file_bytes "$STRIPPED")
rm -f "$STRIPPED"
RUN_OK=1

echo "size gate: xlang_asm stripped=${SZ}B cap=${MAX_BYTES}B ($(awk -v s="$SZ" 'BEGIN { printf "%.2f", s/1048576 }')MiB)"

if [ "$SZ" -gt "$MAX_BYTES" ]; then
  # Advisory residual: report obs, do not soft-silence as plain OK.
  echo "size gate OBS: xlang_asm stripped ${SZ}B > cap ${MAX_BYTES}B (B-SIZE stretch ≤8MiB)" >&2
  OBS=1
  if [ "${XLANG_SIZE_FAIL:-0}" = "1" ]; then
    die "xlang_asm stripped ${SZ}B > cap ${MAX_BYTES}B (XLANG_SIZE_FAIL=1)"
  fi
else
  echo "size gate OK (≤8MiB)"
fi

if [ "${XLANG_PERF_UPDATE_SIZE_BASELINE:-0}" = "1" ]; then
  mkdir -p "$(dirname "$BASELINE")"
  {
    echo -e "# xlang_asm stripped bytes (B-SIZE)"
    echo -e "max_stripped_bytes\t${MAX_BYTES}"
    echo -e "stripped_bytes\t${SZ}"
  } >"$BASELINE"
  echo "size gate: updated $BASELINE"
fi

echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} stripped=${SZ} cap=${MAX_BYTES} host=$(ci_host_summary)"
exit 0
