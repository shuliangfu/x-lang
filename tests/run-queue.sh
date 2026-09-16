#!/usr/bin/env bash
# std.queue gate: Queue_i32 push/pop/len/deinit — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true`) + soft
# default `./compiler/xlang` + bootstrap-link prefer-c wrap (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product -o main.x exit0 = hard run. Prebuilt heap.o/queue.o: hard require
# existing .o or hard make (no soft || true on xlang-c). Leave ensure_std
# family alone (this gate does not call ensure_std_*).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-queue.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

PREFIX="${XLANG_QUEUE_PREFIX:-xlang: [XLANG_QUEUE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "queue test FAIL: $*" >&2
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
  for cand in compiler/xlang_asm compiler/xlang-c compiler/xlang; do
    abs="$root/$cand"
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== queue gate (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# link_only contract: user C externs std_queue_*; prefer existing .o, else hard
# make (not soft || true on xlang-c). Refuse soft auto-make of the compiler.
# PLATFORM: SHARED — objs must exist or hard-build; no soft SKIP→OK.
if [ ! -f std/heap/heap.o ] || [ ! -f std/queue/queue.o ]; then
  xlang_compiler_make ../std/heap/heap.o ../std/queue/queue.o \
    || die "hard make heap.o/queue.o failed (refuse soft SKIP→OK)"
fi
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_runtime_panic_o || die "ensure_runtime_panic_o failed"

SRC="tests/queue/main.x"
[ -f "$SRC" ] || die "missing $SRC"
exe="/tmp/xlang_queue_$$"
log="/tmp/xlang_queue_$$.log"
rm -f "$exe" "$log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -L . "$SRC" -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  die "product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
fi
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$exe" "$log"
if [ "$r_ec" -eq 124 ]; then
  die "run timeout"
elif [ "$r_ec" -ne 0 ]; then
  die "expected exit 0, got $r_ec"
fi
RUN_OK=$((RUN_OK + 1))
echo "queue OK: main exit=0"

echo "queue test OK"
ok_report
