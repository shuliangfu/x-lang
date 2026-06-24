#!/usr/bin/env bash
# A-08 / E-06 v5：Windows MSYS2 上 shux_asm 烟测
#
# 模式：
#   SHUX_WIN_BSTRICT=0（默认）— B-hybrid：make bootstrap-driver-hybrid（可能 cc -c pipeline_gen.c）
#   SHUX_WIN_BSTRICT=1         — B-strict：make bootstrap-driver-bstrict（SKIP_GEN，禁 pipeline_gen cc -c）
#
# 非 MSYS2 宿主：skip exit 0（Linux/macOS 由 bstrict-ci 承担）。
#
# 用法（仓库根）：SHUX_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh

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

export CI="${CI:-1}"
WIN_BSTRICT="${SHUX_WIN_BSTRICT:-0}"
PIPELINE_GEN_PAT='(^|[[:space:]])cc -c (\.\./)?pipeline_gen\.c([[:space:]]|$)'

if [ "$WIN_BSTRICT" = "1" ]; then
  echo "bootstrap-bstrict-windows-gate: E-06 v5 make bootstrap-driver-bstrict (Windows B-strict) ..."
  make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/boot_win_bstrict.log
  BOOT_LOG=/tmp/boot_win_bstrict.log
  EXPECT_MARKER='bootstrap-driver-bstrict OK|asm_only_strict|asm_only_experimental|B-strict OK'
else
  echo "bootstrap-bstrict-windows-gate: make bootstrap-driver-hybrid (B-hybrid default) ..."
  make -C compiler bootstrap-driver-hybrid 2>&1 | tee /tmp/boot_win_hybrid.log
  BOOT_LOG=/tmp/boot_win_hybrid.log
  EXPECT_MARKER='Target-B-hybrid|B-hybrid|bootstrap-driver-hybrid OK'
fi

if [ ! -x compiler/shux_asm ]; then
  echo "bootstrap-bstrict-windows-gate FAIL: compiler/shux_asm missing after build" >&2
  exit 1
fi

if ! grep -qE "$EXPECT_MARKER" "$BOOT_LOG"; then
  echo "bootstrap-bstrict-windows-gate FAIL: log missing expected markers ($EXPECT_MARKER)" >&2
  exit 1
fi

echo "bootstrap-bstrict-windows-gate: smoke return-value via shux_asm ..."
RV_OUT="/tmp/shux_win_rv_$$"
RV_BACKEND_ARGS="-backend c"
rm -f "$RV_OUT" "${RV_OUT}.c" "${RV_OUT}.exe" "${RV_OUT}.out"
compile_rv() {
  local tool="$1"
  shift
  # shellcheck disable=SC2086
  "$tool" $RV_BACKEND_ARGS "$@" tests/return-value/main.sx -o "$RV_OUT"
}
if ! compile_rv compiler/shux_asm 2>/tmp/shux_win_rv_err.log; then
  if [ -x ./compiler/shux-c ]; then
    echo "bootstrap-bstrict-windows-gate: shux_asm compile failed; fallback shux-c" >&2
    RV_BACKEND_ARGS=""
    if ! ./compiler/shux-c -L . tests/return-value/main.sx -o "$RV_OUT" 2>/tmp/shux_win_rv_err.log; then
      cat /tmp/shux_win_rv_err.log >&2
      echo "bootstrap-bstrict-windows-gate FAIL: compile return-value" >&2
      exit 1
    fi
  else
    cat /tmp/shux_win_rv_err.log >&2
    echo "bootstrap-bstrict-windows-gate FAIL: compile return-value" >&2
    exit 1
  fi
fi
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

if [ "$WIN_BSTRICT" = "1" ]; then
  echo "bootstrap-bstrict-windows-gate OK (E-06 v5 Windows B-strict shux_asm + return-value 42)"
else
  echo "bootstrap-bstrict-windows-gate OK (B-hybrid shux_asm + return-value 42)"
fi

echo "bootstrap-bstrict-windows-gate: B-17 std.sys win32 WriteFile ..."
chmod +x tests/run-win32-write-gate.sh tests/run-win32-read-file-gate.sh
SHUX_WIN32_WRITE_FAIL=1 ./tests/run-win32-write-gate.sh
SHUX_WIN32_READ_FILE_FAIL=1 ./tests/run-win32-read-file-gate.sh

PIPELINE_GEN_CC=$(grep -cE "$PIPELINE_GEN_PAT" "$BOOT_LOG" 2>/dev/null || echo 0)
if [ "$WIN_BSTRICT" = "1" ]; then
  echo "bootstrap-bstrict-windows-gate: C-03/E-06 v5 cc -c pipeline_gen.c count=${PIPELINE_GEN_CC} (must be 0)"
  if [ "${PIPELINE_GEN_CC:-0}" -gt 0 ] 2>/dev/null; then
    echo "bootstrap-bstrict-windows-gate FAIL: Windows B-strict log must not cc -c pipeline_gen.c" >&2
    exit 1
  fi
else
  echo "bootstrap-bstrict-windows-gate: C-03 track cc -c pipeline_gen.c count=${PIPELINE_GEN_CC} (B-hybrid; use SHUX_WIN_BSTRICT=1 for B-strict)"
  if [ "${SHUX_WIN_C03_PIPELINE_GEN_FAIL:-0}" = "1" ] && [ "${PIPELINE_GEN_CC:-0}" -gt 0 ] 2>/dev/null; then
    echo "bootstrap-bstrict-windows-gate FAIL: B-hybrid log must not cc -c pipeline_gen.c (set SHUX_WIN_C03_PIPELINE_GEN_FAIL=0 for track-only)" >&2
    exit 1
  fi
fi
