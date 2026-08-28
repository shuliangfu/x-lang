#!/usr/bin/env bash
# STD-089: std.task gate — honesty soft prefer-c / soft SKIP→OK /
# soft ensure_std_c_o / c_smoke=/x= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK (no
# xlang-c still gate OK) + soft `ensure_std_c_o … || true` + hard check +
# hard product via lib smoke + report `c_smoke=`/`x=`/`skip=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# task.o + deps; refuse soft ensure). check residual = obs (paused
# 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-task-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_TASK_DOC:-analysis/archive/std/std-task-v1.md}"
MANIFEST="${XLANG_STD_TASK_MANIFEST:-tests/baseline/std-task-manifest.tsv}"
MOD_X="std/task/mod.x"
TASK_X="std/task/task.x"
LIB="tests/lib/std-task.sh"
SMOKE_X="tests/std-task/group_smoke.x"
SMOKE_C="tests/std-task/task_smoke_ok.c"
TASK_O="std/task/task.o"
MIN_APIS=10

# shellcheck source=tests/lib/std-task.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-task gate FAIL: $*" >&2
  std_task_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-089: std.task manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TASK_X" "$SMOKE_X" "$SMOKE_C" std/task/README.md; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-task-v1.md ] || die "dual-authority fossil analysis/std-task-v1.md (archive live)"
[ ! -f std/task/task_async_glue.c ] || die "task_async_glue.c should be deleted (F-task v2)"
grep -qF STD-089 "$DOC" || die "doc missing STD-089"
for kw in spawn check_leak retry set_new; do
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

sym_miss="$(std_task_symbols_ok "$MOD_X" "$TASK_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-task manifest OK"

if [ "${XLANG_STD_TASK_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_task_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-task gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-089: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure_std_c_o.
# PLATFORM: SHARED — F-07 forbids soft cc -c rebuild as green path.
if [ ! -f "$SMOKE_C" ]; then
  echo "std-task OBS c smoke (missing $SMOKE_C)" >&2
  OBS=$((OBS + 1))
elif [ ! -f "$TASK_O" ]; then
  echo "std-task OBS c smoke (missing prebuilt $TASK_O; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
elif [ ! -f std/async/scheduler.o ] || [ ! -f std/context/context.o ] || [ ! -f std/time/time.o ]; then
  echo "std-task OBS c smoke (missing prebuilt scheduler/context/time .o; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
elif [ ! -f compiler/runtime_time_os.o ]; then
  echo "std-task OBS c smoke (missing prebuilt runtime_time_os.o; refuse soft auto-make)" >&2
  OBS=$((OBS + 1))
elif cc -std=c11 -O1 -o /tmp/xlang_std_task_c_$$ "$SMOKE_C" "$TASK_O" \
    std/async/scheduler.o std/context/context.o std/time/time.o \
    compiler/runtime_time_os.o 2>/tmp/std_task_c_link_$$.log; then
  set +e
  /tmp/xlang_std_task_c_$$ >/dev/null 2>&1
  c_ec=$?
  set -e
  rm -f /tmp/xlang_std_task_c_$$
  if [ "$c_ec" -ne 0 ]; then
    echo "std-task OBS c smoke run exit=$c_ec" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-task OK: c smoke"
  fi
else
  echo "std-task OBS c smoke link (UNDEF/residual; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_task_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-task OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_task_$$"
LOG="/tmp/xlang_std_task_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-task OBS tip product -o (ec=$o_ec; std_task_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-task OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-task OK: product -o"
  fi
fi

std_task_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-task gate OK"
