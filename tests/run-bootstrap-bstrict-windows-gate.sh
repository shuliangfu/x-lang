#!/usr/bin/env bash
# A-08：Windows MSYS2 上 B-hybrid 构建 shux_asm 烟测
#
# 验收：make bootstrap-driver-hybrid 产出 shux_asm；return-value exit 42。
# 非 MSYS2 宿主：skip exit 0（Linux/macOS 由 bstrict-ci 承担）。
#
# 用法（仓库根）：./tests/run-bootstrap-bstrict-windows-gate.sh
# Windows CI：ci.yml windows job 在 make all 之后调用本脚本。

set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

if ! ci_is_windows_msys; then
  echo "bootstrap-bstrict-windows-gate: skip (host is not MSYS2)"
  exit 0
fi

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

if [ ! -x compiler/shux ] && [ ! -x compiler/shux-sx ]; then
  echo "bootstrap-bstrict-windows-gate FAIL: need seed (make -C compiler OPT=1 all)" >&2
  exit 127
fi

# 与 build_shux_asm.sh 一致：Windows CI 走 experimental bootstrap，勿强制 SKIP_GEN strict。
export CI="${CI:-1}"

echo "bootstrap-bstrict-windows-gate: make bootstrap-driver-hybrid ..."
make -C compiler bootstrap-driver-hybrid 2>&1 | tee /tmp/boot_win_hybrid.log

if [ ! -x compiler/shux_asm ]; then
  echo "bootstrap-bstrict-windows-gate FAIL: compiler/shux_asm missing after hybrid build" >&2
  exit 1
fi

if ! grep -qE 'Target-B-hybrid|B-hybrid|bootstrap-driver-hybrid OK' /tmp/boot_win_hybrid.log; then
  echo "bootstrap-bstrict-windows-gate FAIL: log missing B-hybrid markers" >&2
  exit 1
fi

echo "bootstrap-bstrict-windows-gate: smoke return-value via shux_asm ..."
RV_OUT="/tmp/shux_win_rv_$$"
# MSYS：shux_asm 默认 asm 链不完整；与 run_shux_asm_smoke 一致走 -backend c。
RV_BACKEND_ARGS="-backend c"
rm -f "$RV_OUT" "${RV_OUT}.c" "${RV_OUT}.exe"
# shellcheck disable=SC2086
compiler/shux_asm $RV_BACKEND_ARGS tests/return-value/main.sx -o "$RV_OUT" || {
  echo "bootstrap-bstrict-windows-gate FAIL: compile return-value" >&2
  exit 1
}
chmod +x "$RV_OUT" 2>/dev/null || true
RV_BIN="$RV_OUT"
if [ ! -x "$RV_BIN" ] && [ -f "${RV_OUT}.c" ]; then
  cc -std=gnu11 -o "$RV_BIN" "${RV_OUT}.c" 2>/dev/null || cc -std=gnu11 -o "$RV_BIN" "$RV_OUT" || {
    echo "bootstrap-bstrict-windows-gate FAIL: cc link return-value" >&2
    exit 1
  }
fi
if [ ! -x "$RV_BIN" ] && [ -f "$RV_OUT" ]; then
  cc -std=gnu11 -o "${RV_BIN}.exe" "$RV_OUT" 2>/dev/null && RV_BIN="${RV_BIN}.exe" || true
fi
EX=0
"$RV_BIN" >/dev/null 2>&1 || EX=$?
rm -f "$RV_OUT" "${RV_OUT}.c" "${RV_OUT}.exe" "$RV_BIN"
if [ "$EX" -ne 42 ]; then
  echo "bootstrap-bstrict-windows-gate FAIL: expected exit 42, got $EX" >&2
  exit 1
fi

echo "bootstrap-bstrict-windows-gate OK (B-hybrid shux_asm + return-value 42)"

echo "bootstrap-bstrict-windows-gate: B-17 std.sys win32 WriteFile ..."
chmod +x tests/run-win32-write-gate.sh tests/run-win32-read-file-gate.sh
SHUX_WIN32_WRITE_FAIL=1 ./tests/run-win32-write-gate.sh
SHUX_WIN32_READ_FILE_FAIL=1 ./tests/run-win32-read-file-gate.sh

# C-03 Windows track-only：B-hybrid 仍可能 cc -c pipeline_gen.c；SHUX_WIN_C03_PIPELINE_GEN_FAIL=1 收紧。
PIPELINE_GEN_CC=$(grep -cE '(^|[[:space:]])cc -c (\.\./)?pipeline_gen\.c([[:space:]]|$)' /tmp/boot_win_hybrid.log 2>/dev/null || echo 0)
echo "bootstrap-bstrict-windows-gate: C-03 track cc -c pipeline_gen.c count=${PIPELINE_GEN_CC} (B-strict N/A on MSYS2; target 0 when Windows B-strict lands)"
if [ "${SHUX_WIN_C03_PIPELINE_GEN_FAIL:-0}" = "1" ] && [ "${PIPELINE_GEN_CC:-0}" -gt 0 ] 2>/dev/null; then
  echo "bootstrap-bstrict-windows-gate FAIL: B-hybrid log must not cc -c pipeline_gen.c (set SHUX_WIN_C03_PIPELINE_GEN_FAIL=0 for track-only)" >&2
  exit 1
fi
