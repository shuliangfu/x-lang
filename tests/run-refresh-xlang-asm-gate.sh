#!/usr/bin/env bash
# refresh-xlang-asm gate — honesty soft→硬绿.
#
# parser/typeck/codegen/ast .x 变更后：migrate-x gen 门禁 +（Linux/CI）relink
# xlang_asm + 烟测 import/hex + M-3 region / M-4 linear（X 路径）。
#
# Honesty: soft SKIP→OK (local non-Linux exit 0 with no run=/skip=) + soft
# auto-make (xlang_compiler_make) + hard-bind ./compiler/xlang + hard-bind
# `xlang check` as FAIL retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard (SHARED): migrate-x-gen markers; product -o import_std_async exit0;
#     product -E const_hex MAGIC; region + linear child gates
#   - hard (LINUX / CI): ./xbuild refresh-gate (migrate + g05 + xlang_asm overlay)
#   - skip (local non-Linux): refresh-gate body = skip=1 (platform N/A; still
#     run SHARED smokes on existing native — not soft silent OK)
#   - check const_hex = obs (paused). Report: run=/obs=/skip=
# Usage: ./tests/run-refresh-xlang-asm-gate.sh
# Env: XLANG_FORCE_REFRESH_ASM_GATE=1 forwarded to migrate-x-gen (FORCE rebuild;
#      still refuses soft auto-make inside that child).
# PLATFORM: SHARED archaeology / LINUX|CI refresh gold — Ubuntu gold required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_REFRESH_ASM_PREFIX:-xlang: [XLANG_REFRESH_ASM]}"
IMPORT_X="tests/parser/import_std_async.x"
HEX_X="tests/parser/const_hex.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "refresh-xlang-asm gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== refresh-xlang-asm (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
for f in "$IMPORT_X" "$HEX_X" tests/run-migrate-x-gen-gate.sh \
  tests/run-typeck-region.sh tests/run-typeck-linear.sh \
  compiler/scripts/refresh_xlang_asm_gate.sh; do
  [ -f "$f" ] || die "missing $f"
done

CALLER_XLANG="${XLANG:-}"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# SHARED: migrate-x-gen markers (child already honest; inspect-only default).
chmod +x tests/run-migrate-x-gen-gate.sh
XLANG_FORCE_REFRESH_ASM_GATE="${XLANG_FORCE_REFRESH_ASM_GATE:-0}" \
  ./tests/run-migrate-x-gen-gate.sh || die "migrate-x-gen child failed"
RUN_OK=$((RUN_OK + 1))

# PLATFORM: LINUX|CI — refresh-gate (migrate + g05 + xlang_asm overlay) is the
# gold relink body. Local non-Linux = intentional skip= (not soft silent OK).
# Refuse soft auto-make before refresh; require existing native (already resolved).
if ! ci_is_linux && [ -z "${CI:-}" ]; then
  echo "refresh-xlang-asm: skip refresh-gate body (local non-Linux; skip=1; SHARED smokes still hard)"
  SKIP=$((SKIP + 1))
else
  if ! ci_is_linux && [ -n "${CI:-}" ]; then
    echo "refresh-xlang-asm: CI non-Linux — Mach-O/PE single-platform relink"
  fi
  # wave734: G.7 body = scripts/refresh_xlang_asm_gate.sh (xbuild first-class)
  XLANG_BSTRICT_NO_REPLACE=1 ./xbuild refresh-gate \
    || die "xbuild refresh-gate failed (refuse soft SKIP→OK)"
  RUN_OK=$((RUN_OK + 1))
  # After overlay, prefer refreshed xlang_asm when caller did not pin XLANG.
  if [ -z "$CALLER_XLANG" ]; then
    unset XLANG
    XLANG_BIN="$(resolve_shu)" || die "no native after refresh-gate"
    export XLANG="$XLANG_BIN"
    export XLANG_LINK_XLANG="$XLANG_BIN"
    echo "XLANG(post-refresh)=$XLANG_BIN"
  fi
fi

# Product -o + run for import (main returns 0). Refuse fossil-only -E echo
# capture (huge C + echo is unreliable; live call = std_async_scheduler_reset).
echo "refresh-xlang-asm: product -o import std.async ..."
imp_exe="/tmp/xlang_refresh_import_$$"
trap 'rm -f "$imp_exe" /tmp/xlang_refresh_hex_$$.c' EXIT
set +e
"$XLANG_BIN" -L . "$IMPORT_X" -o "$imp_exe" >/tmp/xlang_refresh_import_o.log 2>&1
imp_ec=$?
set -e
if [ "$imp_ec" -ne 0 ] || [ ! -x "$imp_exe" ]; then
  tail -n 12 /tmp/xlang_refresh_import_o.log 2>/dev/null || true
  die "product -o import_std_async.x failed (ec=$imp_ec)"
fi
set +e
"$imp_exe" >/dev/null 2>&1
imp_run=$?
set -e
rm -f "$imp_exe"
[ "$imp_run" -eq 0 ] || die "import_std_async run exit=$imp_run (expect 0)"
RUN_OK=$((RUN_OK + 1))

# Observational check (paused) — never soft SKIP→OK / never soft auto-make.
set +e
"$XLANG_BIN" check -L . "$HEX_X" >/tmp/xlang_refresh_hex_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "refresh-xlang-asm OBS check const_hex (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Hex: -E to temp file + MAGIC needle (main returns MAGIC; 8-bit exit truncates
# so run-exit is NOT the authority). Refuse soft prefer-c xlang-c hard-bind.
echo "refresh-xlang-asm: product -E const_hex MAGIC ..."
hex_c="/tmp/xlang_refresh_hex_$$.c"
set +e
"$XLANG_BIN" -L . -E "$HEX_X" >"$hex_c" 2>/tmp/xlang_refresh_hex.err
hex_ec=$?
set -e
if [ "$hex_ec" -ne 0 ] || [ ! -s "$hex_c" ]; then
  tail -n 12 /tmp/xlang_refresh_hex.err 2>/dev/null || true
  die "product -E const_hex.x failed (ec=$hex_ec; refuse soft prefer-c xlang-c)"
fi
grep -q '1095980800' "$hex_c" || die "expected MAGIC 1095980800 (0x41535700) in -E emit"
rm -f "$hex_c"
RUN_OK=$((RUN_OK + 1))

echo "refresh-xlang-asm: M-3 region typeck (XLANG=$XLANG_BIN) ..."
chmod +x tests/run-typeck-region.sh
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
  ./tests/run-typeck-region.sh | tee /tmp/refresh_asm_region.log \
  || die "region typeck child failed"
grep -qE 'region typeck OK|status=ok' /tmp/refresh_asm_region.log \
  || die "region typeck missing OK marker"
RUN_OK=$((RUN_OK + 1))

echo "refresh-xlang-asm: M-4 linear typeck (XLANG=$XLANG_BIN) ..."
chmod +x tests/run-typeck-linear.sh
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
  ./tests/run-typeck-linear.sh | tee /tmp/refresh_asm_linear.log \
  || die "linear typeck child failed"
grep -qE 'linear typeck OK|status=ok' /tmp/refresh_asm_linear.log \
  || die "linear typeck missing OK marker"
RUN_OK=$((RUN_OK + 1))

echo "refresh-xlang-asm gate OK"
ok_report
