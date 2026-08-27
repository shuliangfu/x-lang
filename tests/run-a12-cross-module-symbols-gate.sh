#!/usr/bin/env bash
# A-12: B-strict xlang_asm strict-link cross-module symbol gate
# (arch_* / backend exports must not be nm U beyond baseline).
#
# Honesty: soft XLANG_A12_CROSS_MODULE_FAIL retired — new undefined beyond
# baseline was portable false-green (exit 0). Darwin remains platform N/A
# (Linux gold covers strict link) with skip=1 report.
#
# Usage: ./tests/run-a12-cross-module-symbols-gate.sh
# Env: XLANG_A12_COMPILER / XLANG_A12_UNDEFINED_TSV overrides.
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

COMPILER="${XLANG_A12_COMPILER:-compiler/xlang_asm}"
BASELINE="${XLANG_A12_UNDEFINED_TSV:-tests/baseline/a12-cross-module-undefined.tsv}"
PREFIX="xlang: [XLANG_A12]"

die() {
  echo "a12-cross-module-symbols-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail undef=${UNDEF_COUNT:-0} new=${NEW_COUNT:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

UNDEF_COUNT=0
NEW_COUNT=0
SKIP=1

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "a12-cross-module-symbols-gate: N/A on Darwin (Linux x86_64/arm64 covers strict link)"
  echo "${PREFIX} status=ok undef=0 new=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ ! -x "$COMPILER" ]; then
  die "no $COMPILER (soft SKIP retired on Linux gold)"
fi

# Cross-module backend/arch symbols must be defined (not nm U).
PATTERNS='arch_(arm64|x86_64|riscv64)|backend_asm_codegen|platform_elf'
UNDEF=$(nm "$COMPILER" 2>/dev/null | awk '/ U / { print $3 }' | grep -E "$PATTERNS" | LC_ALL=C sort -u || true)
UNDEF_COUNT=$(printf '%s\n' "$UNDEF" | sed '/^$/d' | wc -l | tr -d ' ')

echo "a12-cross-module-symbols-gate: $COMPILER arch/backend undefined count=${UNDEF_COUNT}"

if [ "${UNDEF_COUNT:-0}" -eq 0 ]; then
  SKIP=0
  echo "a12-cross-module-symbols-gate OK (no arch_/backend_asm undefined in $COMPILER)"
  echo "${PREFIX} status=ok undef=${UNDEF_COUNT} new=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

echo "a12-cross-module-symbols-gate: undefined symbols (first 12):" >&2
printf '%s\n' "$UNDEF" | head -12 >&2

[ -f "$BASELINE" ] || die "${UNDEF_COUNT} undefined and no baseline $BASELINE"

ALLOWED=$(awk -F'\t' '$1=="allowed_undefined" && $2 !~ /^#/ { print $2 }' "$BASELINE" | tr ' ' '\n' | sed '/^$/d' | LC_ALL=C sort -u)
NEW=""
while IFS= read -r sym; do
  [ -z "$sym" ] && continue
  if ! printf '%s\n' "$ALLOWED" | grep -qxF "$sym"; then
    NEW="${NEW} ${sym}"
  fi
done <<EOF
$UNDEF
EOF
NEW_COUNT=$(echo "$NEW" | tr -s ' ' '\n' | sed '/^$/d' | wc -l | tr -d ' ')
if [ "${NEW_COUNT:-0}" -eq 0 ]; then
  SKIP=0
  echo "a12-cross-module-symbols-gate OK (${UNDEF_COUNT} undefined; all in baseline allowlist)"
  echo "${PREFIX} status=ok undef=${UNDEF_COUNT} new=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

die "new undefined beyond baseline:${NEW}"
