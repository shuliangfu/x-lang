#!/usr/bin/env bash
# void main → process exit 0 (language contract; Zig-like).
# Cases: empty body fall-off; println (README / examples/hello.x shape).
#
# Honesty: leftover XLANG seed fallthrough (`if [ ! -x "$XLANG" ]; then
# XLANG=./compiler/xlang`) retired. Prefer xlang_asm; pin XLANG_LINK_XLANG.
# Explicit-bad XLANG / missing native = hard die. Compile/run failure stays
# hard. Optional XLANG_ALLOW_HOST_CC host-cc fallback is leftover (not this
# knife). G.7: complete existing resolve_shu; converge dod_native_exe.
#
# Usage: ./tests/run-void-main-gate.sh
# Report: run=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PREFIX="xlang: [XLANG_VOID_MAIN]"
RUN_OK=0
SKIP=1

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

die() {
  echo "void-main gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG seed fallthrough / soft SKIP→OK / soft auto-make)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG seed fallthrough / soft SKIP→OK / soft auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

run_one() {
  local src="$1"
  local tag="$2"
  local out="/tmp/xlang_void_main_${tag}_$$"
  rm -f "$out"
  # Prefer pure-asm product -o (host-cc banned without XLANG_ALLOW_HOST_CC).
  # PLATFORM: SHARED — dual-end pure-asm; optional -backend c only if allowed.
  if "$XLANG_BIN" build -L . "$src" -o "$out" 2>/tmp/void_main_${tag}_build.err; then
    :
  elif [ -n "${XLANG_ALLOW_HOST_CC:-}" ] \
    && "$XLANG_BIN" build -backend c -L . "$src" -o "$out" 2>/tmp/void_main_${tag}_build.err; then
    :
  else
    cat /tmp/void_main_${tag}_build.err >&2 || true
    die "build $tag ($src)"
  fi
  set +e
  local stdout_file="/tmp/void_main_${tag}_out_$$"
  "$out" >"$stdout_file" 2>/tmp/void_main_${tag}_stderr
  local rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    die "$tag exit=$rc (want 0)"
  fi
  if [ "$tag" = "hello" ]; then
    if ! grep -q "Hello World" "$stdout_file"; then
      cat "$stdout_file" >&2 || true
      die "hello missing Hello World in stdout"
    fi
  fi
  rm -f "$out" "$stdout_file"
  RUN_OK=$((RUN_OK + 1))
  echo "void-main $tag OK (exit 0)"
}

run_one tests/void-main/main.x empty
run_one tests/void-main/hello.x hello
SKIP=0
echo "void-main gate OK (empty + hello)"
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
