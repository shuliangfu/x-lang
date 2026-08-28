#!/usr/bin/env bash
# STD-077: std.cli gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true` + soft
# mod.o/cli.o make) + soft XLANG fallthrough (explicit-bad still picks another
# binary) + check=/run=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c). Product roundtrip.x -o exit0 = hard run.
# check residual = obs (paused 2026-08-05). Host-C smoke remains observational
# archaeology (not hard green). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-cli-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_CLI_DOC:-analysis/archive/std/std-cli-v1.md}"
MANIFEST="${XLANG_STD_CLI_MANIFEST:-tests/baseline/std-cli-manifest.tsv}"
MOD_X="std/cli/mod.x"
CLI_IMPL="std/cli/cli.x"
LIB="tests/lib/std-cli.sh"
SMOKE_X="tests/std-cli/roundtrip.x"
SMOKE_C="tests/std-cli/cli_smoke_ok.c"
COOKBOOK="examples/cookbook/cli_subcommand.x"
MIN_APIS=6
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-cli.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-cli gate FAIL: $*" >&2
  std_cli_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-077: std.cli manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CLI_IMPL" "$SMOKE_X" "$SMOKE_C" "$COOKBOOK" std/cli/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-077 parse_from_iter subcommand write_usage args_iter; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
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

sym_miss="$(std_cli_symbols_ok "$MOD_X" "$CLI_IMPL" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-cli manifest OK"

if [ "${XLANG_STD_CLI_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_cli_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-cli gate OK (manifest only)"
  exit 0
fi

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is roundtrip.x via asm.
echo "=== STD-077: cli c smoke (observational) ==="
C_NOTE=0
xlang_compiler_make ../std/cli/cli.o >/dev/null 2>&1 || true
if cc -std=c11 -O1 -o /tmp/xlang_cli_smoke "$SMOKE_C" std/cli/cli.o 2>/dev/null; then
  if /tmp/xlang_cli_smoke >/dev/null 2>&1; then
    C_NOTE=1
    echo "std-cli c smoke OK (observational)"
  fi
  rm -f /tmp/xlang_cli_smoke
fi
if [ "$C_NOTE" -eq 0 ]; then
  echo "std-cli OBS c smoke (archaeology; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi
echo "std-cli c_smoke_note=${C_NOTE}"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-077: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_cli_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-cli OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_cli_$$"
LOG="/tmp/xlang_std_cli_build_$$.log"
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
echo "std-cli OK: product -o"

std_cli_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-cli gate OK"
