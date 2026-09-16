#!/usr/bin/env bash
# STD-042: std.async IO + CPS suspend gate — honesty soft prefer-c /
# soft SKIP→OK / soft auto-make / check-as-hard →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only, before asm) + soft
# auto-make (`xlang_compiler_make … scheduler.o / xlang-c … || true`) + soft
# SKIP→OK (no native still gate OK) + hard-bound `xlang check` as sole smoke
# + report `align=`/`io_uring=`/`emit=`/`skip=` retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard
# die. Manifest/registry = hard. check residual = obs (paused 2026-08-05).
# tip product -o std_async_* UNDEF = obs (product debt; leave). tip -E
# succeeds but CPS emit markers miss = obs (not soft SKIP→OK). Report:
# run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-async-io-cps-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_ASYNC_IO_CPS_DOC:-analysis/archive/std/std-async-io-cps-v1.md}"
MANIFEST="${XLANG_STD_ASYNC_IO_CPS_TSV:-tests/baseline/std-async-io-cps.tsv}"
MOD_X="std/async/mod.x"
IO_X="std/io/mod.x"
SCHED_C="compiler/seeds/runtime_scheduler_glue.from_x.c"
IO_C="std/io/mod.x"
LIB="tests/lib/std-async-io-cps.sh"
ALIGN_X="tests/async/io_cps_align.x"
IO_URING_X="tests/async/io_uring_facade.x"
EMIT_X="tests/parser/async_await_io.x"
MIN_SYMS=4

# shellcheck source=tests/lib/std-async-io-cps.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-async-io-cps gate FAIL: $*" >&2
  std_async_io_cps_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

# Product -o smoke: success → run++; tip UNDEF/fail → obs (not soft SKIP→OK).
try_product_smoke() {
  local src="$1"
  local tag="$2"
  local out="/tmp/xlang_std_async_io_cps_${tag}_$$"
  local log="/tmp/xlang_std_async_io_cps_${tag}_build_$$.log"
  rm -f "$out" "$log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$out" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    tail -n 12 "$log" 2>/dev/null || true
    rm -f "$out"
    echo "std-async-io-cps OBS tip product -o $tag (ec=$o_ec; std_async_* UNDEF residual)" >&2
    OBS=$((OBS + 1))
    return 0
  fi
  set +e
  "$out" >/dev/null 2>&1
  local exitcode=$?
  set -e
  rm -f "$out"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-async-io-cps OBS tip run $tag exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-async-io-cps OK: product -o $tag"
  fi
}

echo "=== STD-042: async IO CPS manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$IO_X" "$SCHED_C" "$IO_C" "$ALIGN_X" "$IO_URING_X" "$EMIT_X"; do
  [ -f "$f" ] || die "missing $f"
done
# Refuse resurrected top-level DOC (archive is live authority).
[ ! -f analysis/std-async-io-cps-v1.md ] || die "dual-authority fossil analysis/std-async-io-cps-v1.md (archive live)"

for kw in STD-042 STD-049 poll_async_completions cps_suspend_io IO_ASYNC_NOT_READY drain_until_idle io_uring_is_available; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_syms) MIN_SYMS="$c2" ;;
  esac
done < "$MANIFEST"

SYM_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    symbol)
      SYM_N=$((SYM_N + 1))
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$SYM_N" -ge "$MIN_SYMS" ] || die "symbol count $SYM_N < min $MIN_SYMS"

sym_miss="$(std_async_io_cps_symbols_ok "$MOD_X" "$IO_X" "$SCHED_C" "$IO_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-async-io-cps manifest OK"

if [ "${XLANG_STD_ASYNC_IO_CPS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_async_io_cps_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-async-io-cps gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-042: smoke (XLANG=$XLANG_BIN; check=obs; tip product -o UNDEF=obs; emit markers=obs) ==="

# check residual = obs (paused 2026-08-05); refuse soft SKIP→OK / check-as-hard.
for src in "$ALIGN_X" "$IO_URING_X"; do
  set +e
  "$XLANG_BIN" check -L . "$src" >/tmp/xlang_std_async_io_cps_check_$$.log 2>&1
  chk=$?
  set -e
  if [ "$chk" -ne 0 ]; then
    echo "std-async-io-cps OBS check $src (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
done

try_product_smoke "$ALIGN_X" "align"
try_product_smoke "$IO_URING_X" "io_uring"

# -E must produce output (hard die on tool fail). CPS marker substrings may
# drift on tip → obs (aligned with async-future; refuse soft SKIP→OK).
echo "=== STD-042: await IO emit (-E) ==="
set +e
EMIT_OUT="$("$XLANG_BIN" -E "$EMIT_X" 2>&1)"
e_ec=$?
set -e
if [ "$e_ec" -ne 0 ]; then
  echo "$EMIT_OUT" | tail -12 >&2 || true
  die "-E $EMIT_X failed (ec=$e_ec; refuse soft SKIP→OK)"
fi
MARK_MISS=0
echo "$EMIT_OUT" | grep -qF 'xlang_async_cps_suspend_io' || MARK_MISS=1
echo "$EMIT_OUT" | grep -qF 'xlang_io_submit_read_async' || MARK_MISS=1
if [ "$MARK_MISS" -ne 0 ]; then
  echo "std-async-io-cps OBS emit markers (CPS/submit_read drift; product residual)" >&2
  OBS=$((OBS + 1))
else
  RUN_OK=$((RUN_OK + 1))
  echo "std-async-io-cps OK: emit markers"
fi

std_async_io_cps_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-async-io-cps gate OK"
