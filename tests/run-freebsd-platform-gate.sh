#!/usr/bin/env bash
# B-21：FreeBSD 平台 #[cfg] / std.sys 烟测门禁（manifest + cross -target）。
#
# 用法：./tests/run-freebsd-platform-gate.sh
# 环境：SHUX_FREEBSD_PLATFORM_FAIL=1 失败时硬退出；非 FreeBSD 宿主仅验 manifest + cfg triple。
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_FREEBSD_PLATFORM_FAIL:-0}
DOC="analysis/platform-freebsd-v1.md"
FREEBSD_MOD="std/sys/freebsd.sx"
SMOKE="tests/sys/freebsd_posix_write_smoke.sx"
CFG_SX="tests/lexer/cfg_attribute_skip.sx"

echo "=== B-21: FreeBSD platform manifest ==="
for f in "$DOC" "$FREEBSD_MOD" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "freebsd-platform gate FAIL: missing $f" >&2
    exit 1
  fi
done
grep -q 'target_os = "freebsd"' std/sys/mod.sx || {
  echo "freebsd-platform gate FAIL: mod.sx missing freebsd cfg" >&2
  exit 1
}
grep -q 'freebsd' compiler/src/lexer/cfg_eval.sx || {
  echo "freebsd-platform gate FAIL: cfg_eval.sx missing freebsd" >&2
  exit 1
}
echo "freebsd-platform manifest OK"

SHUX="${SHUX:-./compiler/shux-c}"
if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "freebsd-platform gate SKIP runtime (no shux)"
  exit 0
fi

run_expect() {
  local triple="$1"
  local expect="$2"
  local out="/tmp/shux_freebsd_triple.$$.out"
  rm -f "$out" 2>/dev/null || true
  if ! "$SHUX" -target "$triple" -o "$out" "$CFG_SX" 2>/tmp/shux_freebsd_triple.log; then
    echo "freebsd-platform FAIL: compile -target $triple" >&2
    tail -n 6 /tmp/shux_freebsd_triple.log 2>/dev/null || true
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
if [ "$HOSTOS" = "FreeBSD" ] && "$SHUX" check -L . "$SMOKE" >/dev/null 2>&1 \
  && "$SHUX" "$SMOKE" -o /tmp/shux_freebsd_write_smoke 2>/dev/null \
  && [ -x /tmp/shux_freebsd_write_smoke ]; then
  set +e
  OUT=$(/tmp/shux_freebsd_write_smoke 2>/dev/null)
  EX=$?
  set -e
  rm -f /tmp/shux_freebsd_write_smoke
  EXPECTED=$(printf 'Hello Shu!\n')
  if [ "$EX" -ne 0 ] || [ "$OUT" != "$EXPECTED" ]; then
    echo "freebsd-platform FAIL: host run exit=$EX out='$OUT'" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  echo "freebsd-platform host posix write OK"
else
  echo "freebsd-platform SKIP host run (need FreeBSD + shux -o exe)"
fi

echo "freebsd-platform gate OK"
exit 0
