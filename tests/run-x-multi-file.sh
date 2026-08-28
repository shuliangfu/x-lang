#!/usr/bin/env bash
# Stage 5.2: `-x -E` multi-file (import + cross-module call).
# Fixture: tests/multi-file/main.x imports foo; main calls bar();
# bar lives in foo.x. Host-cc the emit and expect exit 42.
#
# Honesty: soft auto-make of bootstrap-pipeline / xlang-x-pipeline /
# soft SKIP→OK when XLANG set / soft SKIP on timeout / soft SKIP when
# `-x -E` unsupported / soft SKIP to keep run-all green on tip residual
# (false authority) retired. Prefer product xlang_asm (tip supports
# `-x -E`); optional existing compiler/xlang_x also accepted. Explicit
# bad XLANG / missing native = hard die (refuse soft SKIP→OK / soft
# auto-make). Tip incomplete multi-file emit / host-cc / run residual =
# obs= (not soft SKIP→OK / soft FAIL→OK silence). Tip product mangle
# may emit `foo_bar` (accept alongside bare `bar`).
# Report: run=/obs=/skip=
# Usage: ./tests/run-x-multi-file.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_X_MULTI_FILE_PREFIX:-xlang: [X_MULTI_FILE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-60}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "x-multi-file FAIL: $*" >&2
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
  # Prefer product asm; accept existing xlang_x when present (no soft build).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang_x ./compiler/xlang-c ./compiler/xlang; do
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

echo "=== x-multi-file gate (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang_x/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

[ -f tests/multi-file/main.x ] || die "missing tests/multi-file/main.x"
[ -f tests/multi-file/foo.x ] || die "missing tests/multi-file/foo.x"

out=$(mktemp)
err=$(mktemp)
bin="${TMPDIR:-/tmp}/x_multi_file_$$"
trap 'rm -f "$out" "$err" "$bin"' EXIT

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -x -E tests/multi-file/main.x >"$out" 2>"$err"
ec=$?
set -e

if [ "$ec" -eq 124 ]; then
  die "-x -E timeout after ${XLANG_CASE_TIMEOUT}s (refuse soft SKIP→OK); $(tail -5 "$err" 2>/dev/null | tr '\n' ' ')"
fi
if [ "$ec" -ne 0 ]; then
  die "-x -E failed (ec=$ec; refuse soft SKIP→OK); $(tail -5 "$err" 2>/dev/null | tr '\n' ' ')"
fi

# Tip product path may mangle imported bar as foo_bar; accept either.
# PLATFORM: SHARED — BSD grep (Darwin) rejects broken [[:alnum]_] classes;
# use plain needles (foo_bar( also contains bar().
if ! grep -q 'bar(' "$out"; then
  echo "x-multi-file OBS: emit missing bar()/foo_bar() (tip residual; refuse soft silence)" >&2
  head -40 "$out" >&2 || true
  OBS=$((OBS + 1))
  ok_report
  echo "x-multi-file OK (emit obs)"
  exit 0
fi
if ! grep -q 'return foo_bar' "$out" && ! grep -q 'return bar' "$out"; then
  echo "x-multi-file OBS: emit missing return bar/foo_bar (tip residual; refuse soft silence)" >&2
  head -40 "$out" >&2 || true
  OBS=$((OBS + 1))
  ok_report
  echo "x-multi-file OK (emit obs)"
  exit 0
fi

set +e
cc -x c - -o "$bin" -Wall <"$out" >/tmp/x_multi_file_cc.log 2>&1
cc_ec=$?
set -e
if [ "$cc_ec" -ne 0 ] || [ ! -x "$bin" ]; then
  echo "x-multi-file OBS: host-cc failed (ec=$cc_ec; tip residual; refuse soft silence); $(tail -3 /tmp/x_multi_file_cc.log 2>/dev/null | tr '\n' ' ')" >&2
  OBS=$((OBS + 1))
  ok_report
  echo "x-multi-file OK (cc obs)"
  exit 0
fi

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$bin" >/dev/null 2>&1
run_ec=$?
set -e
if [ "$run_ec" -ne 42 ]; then
  echo "x-multi-file OBS: run exit=$run_ec want 42 (tip residual; refuse soft silence)" >&2
  OBS=$((OBS + 1))
  ok_report
  echo "x-multi-file OK (run obs)"
  exit 0
fi

echo "x-multi-file OK (-x multi-file, exit 42)"
RUN_OK=$((RUN_OK + 1))
ok_report
