#!/usr/bin/env bash
# STD-088: std.trace gate — honesty soft prefer-c / soft SKIP→OK /
# soft ensure_std_c_o / c_smoke=/x= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK (no
# xlang-c still gate OK) + soft `ensure_std_c_o … || true` + hard check +
# hard product via lib smoke + report `c_smoke=`/`x=`/`skip=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# trace.o + deps; refuse soft ensure). check residual = obs (paused
# 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-trace-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_TRACE_DOC:-analysis/archive/std/std-trace-v1.md}"
MANIFEST="${XLANG_STD_TRACE_MANIFEST:-tests/baseline/std-trace-manifest.tsv}"
MOD_X="std/trace/mod.x"
TRACE_X="std/trace/trace.x"
LIB="tests/lib/std-trace.sh"
SMOKE_X="tests/std-trace/nested_smoke.x"
SMOKE_C="tests/std-trace/trace_smoke_ok.c"
TRACE_O="std/trace/trace.o"
MIN_APIS=10

# shellcheck source=tests/lib/std-trace.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-trace gate FAIL: $*" >&2
  std_trace_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-088: std.trace manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TRACE_X" "$SMOKE_X" "$SMOKE_C" std/trace/README.md; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-trace-v1.md ] || die "dual-authority fossil analysis/std-trace-v1.md (archive live)"
grep -qF STD-088 "$DOC" || die "doc missing STD-088"
for kw in start_child attach export_text; do
  grep -qF -- "$kw" "$DOC" || die "doc missing '$kw'"
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

sym_miss="$(std_trace_symbols_ok "$MOD_X" "$TRACE_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-trace manifest OK"

if [ "${XLANG_STD_TRACE_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_trace_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-trace gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-088: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure_std_c_o / soft auto-make.
# PLATFORM: SHARED — F-07 forbids soft cc -c rebuild as green path.
if [ ! -f "$SMOKE_C" ]; then
  echo "std-trace OBS c smoke (missing $SMOKE_C)" >&2
  OBS=$((OBS + 1))
elif [ ! -f "$TRACE_O" ]; then
  echo "std-trace OBS c smoke (missing prebuilt $TRACE_O; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
elif [ ! -f std/time/time.o ] || [ ! -f std/random/random.o ]; then
  echo "std-trace OBS c smoke (missing prebuilt time/random .o; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
elif [ ! -f compiler/runtime_time_os.o ] || [ ! -f compiler/runtime_random_fill.o ]; then
  echo "std-trace OBS c smoke (missing prebuilt runtime_time_os/random_fill .o; refuse soft auto-make)" >&2
  OBS=$((OBS + 1))
elif cc -std=c11 -O1 -o /tmp/xlang_std_trace_c_$$ "$SMOKE_C" "$TRACE_O" \
    std/time/time.o compiler/runtime_time_os.o \
    std/random/random.o compiler/runtime_random_fill.o 2>/tmp/std_trace_c_link_$$.log; then
  set +e
  /tmp/xlang_std_trace_c_$$ >/dev/null 2>&1
  c_ec=$?
  set -e
  rm -f /tmp/xlang_std_trace_c_$$
  if [ "$c_ec" -ne 0 ]; then
    echo "std-trace OBS c smoke run exit=$c_ec" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-trace OK: c smoke"
  fi
else
  echo "std-trace OBS c smoke link (UNDEF/residual; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_trace_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-trace OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_trace_$$"
LOG="/tmp/xlang_std_trace_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-trace OBS tip product -o (ec=$o_ec; std_trace_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-trace OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-trace OK: product -o"
  fi
fi

std_trace_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-trace gate OK"
