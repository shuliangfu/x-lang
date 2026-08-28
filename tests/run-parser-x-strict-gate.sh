#!/usr/bin/env bash
# Strict-chain parser live code lives in parser_x.o (-x -E). Gate checks
# symbols are defined (not U) and build_asm/parser.o second pass is non-empty.
#
# Honesty: soft Darwin "N/A" exit0 without skip= + soft SKIP→OK when no
# parser_x.o under FAIL≠1 (false authority) retired. Prefer product path
# honesty reporting. Explicit missing parser_x.o on Linux = hard die when
# XLANG_PARSER_X_STRICT_FAIL=1 (default). Darwin / non-Linux = skip=
# (platform N/A, not soft green). Report: run=/obs=/skip=
# Usage: ./tests/run-parser-x-strict-gate.sh
# Env: XLANG_PARSER_X_STRICT_FAIL=1 hard-fail (CI default)
# PLATFORM: LINUX|UBUNTU archaeology — Darwin skip=; Ubuntu gold.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

PREFIX="${XLANG_PARSER_X_STRICT_PREFIX:-xlang: [PARSER_X_STRICT]}"
RUN_OK=0
OBS=0
SKIP=0
FAIL=${XLANG_PARSER_X_STRICT_FAIL:-1}

die() {
  echo "parser-x-strict-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

PARSER_X="${XLANG_PARSER_X_O:-compiler/parser_x.o}"
PARSER_ASM="${XLANG_PARSER_ASM_O:-compiler/build_asm/parser.o}"

# PLATFORM: LINUX|UBUNTU — parser_x.o strict symbols are Linux gold only.
if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  SKIP=$((SKIP + 1))
  echo "parser-x-strict-gate: skip= (platform N/A on $(uname -s); not soft SKIP→OK)" >&2
  ok_report
  exit 0
fi

if [ ! -f "$PARSER_X" ]; then
  if [ "$FAIL" = "1" ]; then
    die "no $PARSER_X (refuse soft SKIP→OK / soft auto-make)"
  fi
  echo "parser-x-strict-gate OBS: no $PARSER_X (FAIL≠1; refuse soft silence)" >&2
  OBS=$((OBS + 1))
  ok_report
  exit 0
fi

MISSING=""
for sym in parser_parse_into_buf parser_parse_into_init parser_parse_into_set_main_index; do
  if ! nm "$PARSER_X" 2>/dev/null | grep -qE "[ Tt] .*${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done
if [ -n "$MISSING" ]; then
  if [ "$FAIL" = "1" ]; then
    die "$PARSER_X missing T:${MISSING}"
  fi
  echo "parser-x-strict-gate OBS: missing T:${MISSING} (FAIL≠1)" >&2
  OBS=$((OBS + 1))
  ok_report
  exit 0
fi
RUN_OK=$((RUN_OK + 1))

if [ -f "$PARSER_ASM" ]; then
  SZ=$(stat -c%s "$PARSER_ASM" 2>/dev/null || stat -f%z "$PARSER_ASM" 2>/dev/null || echo 0)
  if [ "${SZ:-0}" -lt 16 ] 2>/dev/null; then
    if [ "$FAIL" = "1" ]; then
      die "$PARSER_ASM too small (${SZ}B)"
    fi
    echo "parser-x-strict-gate OBS: $PARSER_ASM too small (${SZ}B)" >&2
    OBS=$((OBS + 1))
  else
    echo "parser-x-strict-gate OK: $PARSER_ASM size=${SZ}B"
    RUN_OK=$((RUN_OK + 1))
  fi
else
  echo "parser-x-strict-gate OBS: no $PARSER_ASM (symbol check still hard)" >&2
  OBS=$((OBS + 1))
fi

ok_report
echo "parser-x-strict-gate OK (parser_x.o parse symbols)"
