#!/usr/bin/env bash
# void main → process exit 0 (language contract; Zig-like).
# Cases: empty body fall-off; println (README / examples/hello.x shape).
set -e
cd "$(dirname "$0")/.."
SHUX=${SHUX:-./compiler/shux_asm}
if [ ! -x "$SHUX" ]; then
  SHUX=./compiler/shux
fi
if [ ! -x "$SHUX" ]; then
  echo "void-main gate FAIL: no shux_asm/shux" >&2
  exit 1
fi

run_one() {
  local src="$1"
  local tag="$2"
  local out="/tmp/shux_void_main_${tag}_$$"
  rm -f "$out"
  # Prefer C backend link path for stable process exit code.
  if "$SHUX" -backend c -L . "$src" -o "$out" 2>/tmp/void_main_${tag}_build.err; then
    :
  elif "$SHUX" -L . "$src" -o "$out" 2>/tmp/void_main_${tag}_build.err; then
    :
  else
    echo "void-main gate FAIL: build $tag ($src)" >&2
    cat /tmp/void_main_${tag}_build.err >&2 || true
    exit 1
  fi
  set +e
  local stdout_file="/tmp/void_main_${tag}_out_$$"
  "$out" >"$stdout_file" 2>/tmp/void_main_${tag}_stderr
  local rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    echo "void-main gate FAIL: $tag exit=$rc (want 0)" >&2
    exit 1
  fi
  if [ "$tag" = "hello" ]; then
    if ! grep -q "Hello World" "$stdout_file"; then
      echo "void-main gate FAIL: hello missing Hello World in stdout" >&2
      cat "$stdout_file" >&2 || true
      exit 1
    fi
  fi
  rm -f "$out" "$stdout_file"
  echo "void-main $tag OK (exit 0)"
}

run_one tests/void-main/main.x empty
run_one tests/void-main/hello.x hello
echo "void-main gate OK (empty + hello)"
