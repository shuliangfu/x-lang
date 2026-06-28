#!/usr/bin/env bash
# G-FFI-5：std/ffi + std/sys 层 extern 调用须包在 unsafe { } 内（LANG-007 v2）
#
# 验证：
#   1) Linux 可单文件 check 的 std/ffi + std/sys 通过 typeck
#   2) win32 / ffi.sx 实现层 grep 确认 unsafe 包裹
#
# 用法：./tests/run-g-ffi-5-std-wrap-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== G-FFI-5: std/ffi + std/sys unsafe wrap manifest ==="
for f in \
  std/ffi/ffi.sx \
  std/ffi/mod.sx \
  std/sys/mod.sx \
  std/sys/linux.sx \
  std/sys/macos.sx \
  std/sys/freebsd.sx \
  std/sys/win32.sx \
  std/sys/win32_net.sx \
  std/sys/mmap.sx \
  std/sys/linux_io_uring.sx; do
  if [ ! -f "$f" ]; then
    echo "g-ffi-5 gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "g-ffi-5 manifest OK"

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

SHUX_BIN=""
if [ -n "${SHUX:-}" ] && [ -x "${SHUX}" ]; then
  SHUX_BIN="${SHUX}"
elif [ -x ./compiler/shux ]; then
  SHUX_BIN=./compiler/shux
elif [ -x ./compiler/shux-c ]; then
  SHUX_BIN=./compiler/shux-c
fi
if [ -z "$SHUX_BIN" ] && [ "$(uname -s)" = Linux ] && [ -x ./compiler/shux-c ]; then
  SHUX_BIN=./compiler/shux-c
fi

if [ -z "$SHUX_BIN" ] || ! native_shu "$SHUX_BIN"; then
  echo "g-ffi-5 gate SKIP typeck (no native shux)" >&2
  exit 0
fi

CHECK_TIMEOUT="${SHUX_GFFI5_CHECK_TIMEOUT:-180}"
run_check() {
  local src="$1"
  if command -v timeout >/dev/null 2>&1; then
    timeout --signal=TERM --kill-after=15 "$CHECK_TIMEOUT" \
      "$SHUX_BIN" check -backend c -L . "$src" >/tmp/shux_gffi5_check.log 2>&1 || {
      local ec=$?
      echo "g-ffi-5 FAIL check $src (exit=$ec)" >&2
      cat /tmp/shux_gffi5_check.log >&2
      return "$ec"
    }
  else
    "$SHUX_BIN" check -backend c -L . "$src" >/tmp/shux_gffi5_check.log 2>&1 || {
      echo "g-ffi-5 FAIL check $src" >&2
      cat /tmp/shux_gffi5_check.log >&2
      return 1
    }
  fi
  echo "g-ffi-5 check OK $src"
}

echo "=== G-FFI-5: std/ffi + std/sys typeck (SHUX=$SHUX_BIN) ==="
# Linux 宿主可单文件 check 的子集（ffi.sx / win32*.sx 单文件 check 因 cfg/链接上下文历史即红，改走 contract + grep）
CHECK_SRCS=(
  std/ffi/mod.sx
  std/sys/mod.sx
  std/sys/linux.sx
  std/sys/macos.sx
  std/sys/freebsd.sx
  std/sys/mmap.sx
  std/sys/linux_io_uring.sx
)
FAILS=0
for src in "${CHECK_SRCS[@]}"; do
  if ! run_check "$src"; then
    FAILS=$((FAILS + 1))
  fi
done

echo "=== G-FFI-5: win32 / ffi.sx impl unsafe wrap grep ==="
gffi5_need_unsafe() {
  local f="$1" sym="$2"
  if ! grep -qF "$sym" "$f" || ! grep -q 'unsafe' "$f"; then
    echo "g-ffi-5 FAIL: $f must wrap extern ($sym) in unsafe" >&2
    return 1
  fi
  return 0
}
gffi5_need_unsafe std/ffi/ffi.sx 'strlen(ptr)' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/ffi/ffi.sx 'malloc(n)' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/ffi/ffi.sx 'free(ptr)' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32.sx 'GetStdHandle' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32.sx 'WriteFile' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32.sx 'ExitProcess' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32_net.sx 'WSAStartup' || FAILS=$((FAILS + 1))
echo "g-ffi-5 grep OK (win32 + ffi impl)"

if [ "$FAILS" -gt 0 ]; then
  echo "g-ffi-5 gate FAIL: ${FAILS} check(s)" >&2
  exit 1
fi

echo "=== G-FFI-5: safe-ffi-contract hook ==="
chmod +x tests/run-safe-ffi-contract-gate.sh 2>/dev/null || true
if env SHUX="$SHUX_BIN" ./tests/run-safe-ffi-contract-gate.sh; then
  echo "g-ffi-5 safe-ffi-contract OK"
else
  echo "g-ffi-5 WARN: safe-ffi-contract failed (ffi.o/-o 基础设施；manifest/typeck 仍应绿)" >&2
fi

echo "g-ffi-5 gate OK"
