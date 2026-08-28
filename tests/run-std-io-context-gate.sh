#!/usr/bin/env bash
# STD-091: std.io ↔ std.context read_ctx/write_ctx gate — honesty residual
# XLANG fallthrough / auto-make / ensure rebuild / check=/run=/skip= →硬绿.
#
# Honesty: soft `xlang_compiler_make -q || xlang_compiler_make` +
# XLANG fallthrough (`for cand in "${XLANG:-}" ./compiler/xlang_asm …`
# continues past explicit-bad XLANG) + bootstrap-link wrap +
# `ensure_std_c_o` rebuild + extra CLI .o + report check=/run=/skip=
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit
# bad XLANG / missing native = hard die (refuse soft SKIP→OK / soft
# auto-make / prefer-c / XLANG fallthrough / soft ensure rebuild).
# check residual = obs (paused 2026-08-05). Host-C glue archaeology =
# obs (existing .o only; never rebuild). tests/io/context_read_write.x
# product -o exit0 = hard run. Report: run=/obs=/skip=. Live ensure_std
# family left. No DOC/TSV (mirror STD-092). PLATFORM: SHARED archaeology
# — Ubuntu gold still required.
# Usage: ./tests/run-std-io-context-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

MOD_X="std/io/mod.x"
SMOKE="tests/io/context_read_write.x"
PREFIX="xlang: [XLANG_STD091_IO_CTX]"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "io-context gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== STD-091: io-context manifest ==="
for f in "$MOD_X" "$SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done
for sym in timeout_from_ctx read_ctx write_ctx IO_CTX_MS_CANCELLED IO_CTX_MS_EXPIRED; do
  case "$sym" in
    IO_CTX_MS_*)
      grep -qF "const ${sym}:" "$MOD_X" 2>/dev/null || die "missing const $sym"
      ;;
    *)
      grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null || die "missing api $sym"
      ;;
  esac
done
echo "io-context manifest OK"

if [ "${XLANG_STD091_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  echo "std-io-context gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-091: smoke (XLANG=$XLANG_BIN; check/glue=obs; context_read_write.x product -o hard) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap / ensure_std_c_o.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

# check = obs (paused); refuse hard check as sole green.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std091_io_ctx_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "io-context OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Host-C glue archaeology = obs only; existing .o, no soft ensure/auto-make rebuild.
# Do not pass extra CLI .o (Darwin has_obj dup history). Product -o is the hard path.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
for o in compiler/runtime_atomic_glue.o compiler/runtime_time_os.o; do
  if [ ! -f "$o" ]; then
    echo "io-context OBS missing glue $o (no soft ensure; product -o still hard)" >&2
    OBS=$((OBS + 1))
  fi
done

# context_read_write.x product -o exit0 is the hard-green signal.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make.
exe="/tmp/xlang_std091_io_ctx_$$"
log="/tmp/xlang_std091_io_ctx_$$.log"
rm -f "$exe" "$log"
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  echo "io-context FAIL: compile $SMOKE" >&2
  tail -n 20 "$log" 2>/dev/null >&2 || true
  rm -f "$exe" "$log"
  die "product -o failed (refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
ec=$?
set -e
rm -f "$exe" "$log"
[ "$ec" -eq 0 ] || die "run exit=$ec (refuse soft SKIP→OK)"
RUN_OK=$((RUN_OK + 1))
echo "io-context OK: product context_read_write.x"

echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
echo "std-io-context gate OK"
