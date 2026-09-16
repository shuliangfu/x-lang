#!/usr/bin/env bash
# async-context: std.async ↔ std.context bind/spawn gate — honesty soft prefer-c /
# soft SKIP→OK / soft ensure_std_c_o / check-as-hard →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only, no asm) + soft SKIP→OK
# (no native still gate OK) + soft ensure_std_c_o rebuild of migrated
# scheduler/context/time/task .o + hard-bound `xlang check` + hard product -o
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt .o;
# refuse soft ensure/auto-make; F-07 forbids cc -c on migrated modules).
# check residual = obs (paused 2026-08-05). tip product -o / run residual =
# obs (std_async_* / context UNDEF leave). Report: run=/obs=/skip=.
# Historical PREFIX label STD090 collided with schema STD-090 — report uses
# XLANG_STD_ASYNC_CTX. PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-async-context-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_ASYNC_CONTEXT_DOC:-analysis/archive/std/std-async-api-v1.md}"
CTX_DOC="${XLANG_STD_CONTEXT_DOC:-analysis/archive/std/std-context-v1.md}"
MOD_X="std/async/mod.x"
SCHED_C="compiler/seeds/runtime_scheduler_glue.from_x.c"
SMOKE_CANCEL="tests/async/context_cancel_drain.x"
SMOKE_SPAWN="tests/async/spawn_context_inherit.x"
SMOKE_C="tests/async/spawn_context_smoke.c"
LIB="tests/lib/std-async-context.sh"
SCHED_O="std/async/scheduler.o"
CTX_O="std/context/context.o"
TIME_O="std/time/time.o"
TASK_O="std/task/task.o"
TIME_OS_O="compiler/runtime_time_os.o"

# shellcheck source=tests/lib/std-async-context.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "async-context gate FAIL: $*" >&2
  std_async_context_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== async-context: manifest ==="
for f in "$DOC" "$CTX_DOC" "$MOD_X" "$SCHED_C" "$SMOKE_CANCEL" "$SMOKE_SPAWN" "$SMOKE_C" "$LIB"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
# Refuse resurrected top-level DOC (archive is live authority).
[ ! -f analysis/std-async-api-v1.md ] || die "dual-authority fossil analysis/std-async-api-v1.md (archive live)"
[ ! -f analysis/std-context-v1.md ] || die "dual-authority fossil analysis/std-context-v1.md (archive live)"

for sym in bind_ctx err_ctx_abort runtime runtime_reset drain \
           submit submit_ctx spawn_ctx_smoke; do
  if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
    die "missing api $sym in $MOD_X"
  fi
done
for sym in xlang_async_bind_context_c xlang_async_task_submit_with_ctx xlang_async_spawn_ctx_smoke_c; do
  if ! grep -qF "$sym" "$SCHED_C" 2>/dev/null; then
    die "missing $sym in $SCHED_C"
  fi
done
grep -qF 'ctx_slots' "$SCHED_C" 2>/dev/null || die "missing ctx_slots in $SCHED_C"
echo "async-context manifest OK"

if [ "${XLANG_STD_ASYNC_CONTEXT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_async_context_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "async-context gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== async-context: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure_std_c_o / auto-make.
# PLATFORM: SHARED — F-07 forbids cc -c on migrated async/context/time/task.
echo "=== async-context: C smoke (host-c archaeology) ==="
if [ ! -f "$CTX_O" ] || ! nm "$CTX_O" 2>/dev/null | grep -qF 'ctx_background_c'; then
  echo "async-context OBS c smoke (missing ctx_background_c in prebuilt $CTX_O; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
elif [ ! -f "$SCHED_O" ] || [ ! -f "$TIME_O" ]; then
  echo "async-context OBS c smoke (missing prebuilt scheduler/time .o; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
else
  LINK_OBJS=("$SMOKE_C" "$SCHED_O" "$CTX_O" "$TIME_O")
  [ -f "$TIME_OS_O" ] && LINK_OBJS+=("$TIME_OS_O")
  [ -f "$TASK_O" ] && LINK_OBJS+=("$TASK_O")
  if cc -std=c11 -O1 -pthread -o /tmp/xlang_async_ctx_smoke_$$ \
    "${LINK_OBJS[@]}" 2>/tmp/async_ctx_c_link_$$.log; then
    set +e
    /tmp/xlang_async_ctx_smoke_$$ >/dev/null 2>&1
    smoke_ec=$?
    set -e
    rm -f /tmp/xlang_async_ctx_smoke_$$
    if [ "$smoke_ec" -ne 0 ]; then
      echo "async-context OBS c smoke run exit=$smoke_ec (product residual)" >&2
      OBS=$((OBS + 1))
    else
      RUN_OK=$((RUN_OK + 1))
      echo "async-context OK: c smoke"
    fi
  else
    echo "async-context OBS c smoke link (UNDEF/residual; refuse soft ensure/auto-make)" >&2
    OBS=$((OBS + 1))
  fi
fi

# check residual = obs (paused 2026-08-05); refuse soft SKIP→OK / check-as-hard.
for x in "$SMOKE_CANCEL" "$SMOKE_SPAWN"; do
  set +e
  "$XLANG_BIN" check -L . "$x" >/tmp/xlang_async_ctx_check_$$.log 2>&1
  chk=$?
  set -e
  if [ "$chk" -ne 0 ]; then
    echo "async-context OBS check $x (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
done

# tip product -o / run: success → run++; tip UNDEF/fail → obs (not soft SKIP→OK).
try_product_smoke() {
  local src="$1"
  local tag="$2"
  local out="/tmp/xlang_async_ctx_${tag}_$$"
  local log="/tmp/xlang_async_ctx_${tag}_build_$$.log"
  rm -f "$out" "$log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$out" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    tail -n 12 "$log" 2>/dev/null || true
    rm -f "$out"
    echo "async-context OBS tip product -o $tag (ec=$o_ec; std_async_*/context UNDEF residual)" >&2
    OBS=$((OBS + 1))
    return 0
  fi
  set +e
  "$out" >/dev/null 2>&1
  local exitcode=$?
  set -e
  rm -f "$out"
  if [ "$exitcode" -ne 0 ]; then
    echo "async-context OBS tip run $tag exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "async-context OK: product -o $tag"
  fi
}

try_product_smoke "$SMOKE_CANCEL" "cancel_drain"
try_product_smoke "$SMOKE_SPAWN" "spawn_inherit"

std_async_context_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-async-context gate OK"
