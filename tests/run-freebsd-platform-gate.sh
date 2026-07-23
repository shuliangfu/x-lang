#!/usr/bin/env bash
# B-21：FreeBSD 平台 #[cfg] / std.sys 烟测门禁（manifest + cross -target）。
#
# 用法：./tests/run-freebsd-platform-gate.sh
# 环境：XLANG_FREEBSD_PLATFORM_FAIL=1 失败时硬退出；非 FreeBSD 宿主仅验 manifest + cfg triple。
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_FREEBSD_PLATFORM_FAIL:-0}
DOC="analysis/platform-freebsd-v1.md"
FREEBSD_MOD="std/sys/freebsd.x"
SMOKE="tests/sys/freebsd_posix_write_smoke.x"
CFG_X="tests/lexer/cfg_attribute_skip.x"

echo "=== B-21: FreeBSD platform manifest ==="
for f in "$DOC" "$FREEBSD_MOD" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "freebsd-platform gate FAIL: missing $f" >&2
    exit 1
  fi
done
grep -q 'target_os = "freebsd"' std/sys/mod.x || {
  echo "freebsd-platform gate FAIL: mod.x missing freebsd cfg" >&2
  exit 1
}
grep -q 'freebsd' compiler/src/lexer/cfg_eval.x || {
  echo "freebsd-platform gate FAIL: cfg_eval.x missing freebsd" >&2
  exit 1
}
echo "freebsd-platform manifest OK"

XLANG="${XLANG:-./compiler/xlang-c}"
if [ ! -x "$XLANG" ]; then
  XLANG="./compiler/xlang"
fi
if [ ! -x "$XLANG" ]; then
  echo "freebsd-platform gate SKIP runtime (no xlang)"
  exit 0
fi

run_expect() {
  local triple="$1"
  local expect="$2"
  local out="/tmp/xlang_freebsd_triple.$$.out"
  rm -f "$out" 2>/dev/null || true
  if ! "$XLANG" -target "$triple" -o "$out" "$CFG_X" 2>/tmp/xlang_freebsd_triple.log; then
    echo "freebsd-platform FAIL: compile -target $triple" >&2
    tail -n 6 /tmp/xlang_freebsd_triple.log 2>/dev/null || true
    return 1
  fi
  if [ ! -x "$out" ]; then
    echo "freebsd-platform FAIL: no exe for -target $triple" >&2
    return 1
  fi
  local rc=0
  "$out" || rc=$?
  rm -f "$out" 2>/dev/null || true
  if [ "$rc" -ne "$expect" ]; then
    echo "freebsd-platform FAIL: -target $triple expected exit $expect, got $rc" >&2
    return 1
  fi
  echo "freebsd-platform OK (-target $triple -> exit $expect)"
  return 0
}

if ! run_expect "x86_64-unknown-freebsd14.0" 31; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! run_expect "aarch64-unknown-freebsd14.0" 20; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

HOSTOS="$(uname -s 2>/dev/null)"
if [ "$HOSTOS" = "FreeBSD" ] && "$XLANG" check -L . "$SMOKE" >/dev/null 2>&1 \
  && "$XLANG" "$SMOKE" -o /tmp/xlang_freebsd_write_smoke 2>/dev/null \
  && [ -x /tmp/xlang_freebsd_write_smoke ]; then
  set +e
  OUT=$(/tmp/xlang_freebsd_write_smoke 2>/dev/null)
  EX=$?
  set -e
  rm -f /tmp/xlang_freebsd_write_smoke
  EXPECTED=$(printf 'Hello Xlang!\n')
  if [ "$EX" -ne 0 ] || [ "$OUT" != "$EXPECTED" ]; then
    echo "freebsd-platform FAIL: host run exit=$EX out='$OUT'" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  echo "freebsd-platform host posix write OK"
else
  echo "freebsd-platform SKIP host run (need FreeBSD + xlang -o exe)"
fi

echo "freebsd-platform gate OK"
exit 0
