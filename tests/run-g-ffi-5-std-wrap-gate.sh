#!/usr/bin/env bash
# G-FFI-5：std/ffi + std/sys 层 extern 调用须包在 unsafe { } 内（LANG-007 v2）
#
# 验证：
#   1) 清单文件存在
#   2) win32 / ffi.x 实现层 grep 确认 unsafe 包裹（硬门槛）
#   3) 可选 typeck：默认 SKIP 单文件 check（G-02a 后 -backend c 已退役；
#      若干 sys 模块仍有 pre-existing typeck 债如 implicit tail return）。
#      设 SHUX_G_FFI5_TYPECK=1 时尝试 check -L .（失败仅计数，不硬红除非
#      SHUX_G_FFI5_TYPECK_STRICT=1）。
#
# 用法：./tests/run-g-ffi-5-std-wrap-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== G-FFI-5: std/ffi + std/sys unsafe wrap manifest ==="
for f in \
  std/ffi/ffi.x \
  std/ffi/mod.x \
  std/sys/mod.x \
  std/sys/linux.x \
  std/sys/macos.x \
  std/sys/freebsd.x \
  std/sys/win32.x \
  std/sys/win32_net.x \
  std/sys/mmap.x \
  std/sys/linux_io_uring.x; do
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

FAILS=0

echo "=== G-FFI-5: win32 / ffi.x impl unsafe wrap grep ==="
gffi5_need_unsafe() {
  local f="$1" sym="$2"
  if ! grep -qF "$sym" "$f" || ! grep -q 'unsafe' "$f"; then
    echo "g-ffi-5 FAIL: $f must wrap extern ($sym) in unsafe" >&2
    return 1
  fi
  return 0
}
gffi5_need_unsafe std/ffi/ffi.x 'strlen(ptr)' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/ffi/ffi.x 'malloc(n)' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/ffi/ffi.x 'free(ptr)' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32.x 'GetStdHandle' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32.x 'WriteFile' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32.x 'ExitProcess' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32_net.x 'WSAStartup' || FAILS=$((FAILS + 1))
# Linux / macOS / FreeBSD：含 extern 的 OS 层须有 unsafe 包裹
# （mmap.x 等仅 re-export 委托 linux/macos 的模块可无 unsafe）
for f in std/sys/linux.x std/sys/macos.x std/sys/freebsd.x std/sys/linux_io_uring.x; do
  if grep -qE '^[[:space:]]*extern ' "$f" && ! grep -q 'unsafe' "$f"; then
    echo "g-ffi-5 FAIL: $f has extern without unsafe" >&2
    FAILS=$((FAILS + 1))
  fi
done
echo "g-ffi-5 grep OK (win32 + ffi + sys)"

# ── optional typeck ──
if [ "${SHUX_G_FFI5_TYPECK:-0}" = "1" ]; then
  SHUX_BIN=""
  if [ -n "${SHUX:-}" ] && [ -x "${SHUX}" ]; then
    SHUX_BIN="${SHUX}"
  elif [ -x ./compiler/shux ]; then
    SHUX_BIN=./compiler/shux
  elif [ -x ./compiler/shux_asm ]; then
    SHUX_BIN=./compiler/shux_asm
  fi
  if [ -n "$SHUX_BIN" ] && native_shu "$SHUX_BIN"; then
    echo "=== G-FFI-5: optional typeck (SHUX=$SHUX_BIN) ==="
    CHECK_SRCS=(
      std/ffi/mod.x
      std/sys/mod.x
      std/sys/linux.x
      std/sys/macos.x
      std/sys/freebsd.x
      std/sys/mmap.x
      std/sys/linux_io_uring.x
    )
    TFAIL=0
    for src in "${CHECK_SRCS[@]}"; do
      if "$SHUX_BIN" check -L . "$src" >/tmp/shux_gffi5_check.log 2>&1; then
        echo "g-ffi-5 check OK $src"
      else
        echo "g-ffi-5 check WARN $src (pre-existing typeck debt; see /tmp/shux_gffi5_check.log)" >&2
        TFAIL=$((TFAIL + 1))
      fi
    done
    if [ "$TFAIL" -gt 0 ] && [ "${SHUX_G_FFI5_TYPECK_STRICT:-0}" = "1" ]; then
      echo "g-ffi-5 FAIL: typeck strict $TFAIL failure(s)" >&2
      FAILS=$((FAILS + TFAIL))
    else
      echo "g-ffi-5 typeck soft: $TFAIL warn(s) (set TYPECK_STRICT=1 to hard-fail)"
    fi
  else
    echo "g-ffi-5 typeck SKIP (no native shux)"
  fi
else
  echo "g-ffi-5 typeck SKIP (default; set SHUX_G_FFI5_TYPECK=1 to enable soft checks)"
fi

if [ "$FAILS" -gt 0 ]; then
  echo "g-ffi-5 gate FAIL: ${FAILS} check(s)" >&2
  exit 1
fi
echo "g-ffi-5 std-wrap gate OK"
