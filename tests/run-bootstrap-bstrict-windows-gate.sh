#!/usr/bin/env bash
# A-08 / E-06 v5：Windows MSYS2 上 xlang_asm 烟测
#
# 模式：
#   XLANG_WIN_BSTRICT=0（默认）— B-hybrid：make bootstrap-driver-hybrid（可能 cc -c pipeline_gen.c）
#   XLANG_WIN_BSTRICT=1         — B-strict：make bootstrap-driver-bstrict（SKIP_GEN，禁 pipeline_gen cc -c）
#
# 非 MSYS2 宿主：skip exit 0（Linux/macOS 由 bstrict-ci 承担）。
#
# 用法（仓库根）：XLANG_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh

set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

if ! ci_is_windows_msys; then
  echo "bootstrap-bstrict-windows-gate: skip (host is not MSYS2)"
  exit 0
fi

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

if [ ! -x compiler/xlang ] && [ ! -x compiler/xlang-x ]; then
  echo "bootstrap-bstrict-windows-gate FAIL: need seed (make -C compiler OPT=1 all)" >&2
  exit 127
fi

export CI="${CI:-1}"
WIN_BSTRICT="${XLANG_WIN_BSTRICT:-0}"
PIPELINE_GEN_PAT='(^|[[:space:]])cc -c (\.\./)?pipeline_gen\.c([[:space:]]|$)'

if [ "$WIN_BSTRICT" = "1" ]; then
  echo "bootstrap-bstrict-windows-gate: E-06 v5 make bootstrap-driver-bstrict (Windows B-strict) ..."
  # Why: `make | tee` masks make's exit code with tee's (always 0). Without
  #      capturing PIPESTATUS a real make failure (e.g. relink-xlang Error 2
  #      from g05_relink_env unsupported host) is silently swallowed and the
  #      gate reports OK based only on log markers — a false green. This was
  #      the 2026-07-20 Windows gate state: make returned Error 2 but the gate
  #      exited 0. B-hybrid branch below already captures SEED_RC; B-strict
  #      must do the same for its single make call.
  set -o pipefail
  make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/boot_win_bstrict.log
  BOOT_RC=${PIPESTATUS[0]}
  set +o pipefail
  if [ "$BOOT_RC" -ne 0 ]; then
    echo "bootstrap-bstrict-windows-gate FAIL: make bootstrap-driver-bstrict rc=$BOOT_RC" >&2
    exit 1
  fi
  BOOT_LOG=/tmp/boot_win_bstrict.log
  EXPECT_MARKER='bootstrap-driver-bstrict OK|asm_only_strict|asm_only_experimental|B-strict OK'
else
  # Why: bootstrap-driver-hybrid depends on $(TARGET)=xlang, whose link rule
  #      (makefile L611-612) uses only $(OBJS_CORE)=14 .o in XLANG_LEGACY_C_FRONTEND=1
  #      mode — missing parse/typeck_module/preprocess/pipeline_*/codegen_* symbols.
  #      xlang must be built by bootstrap-driver-seed (full symbol set: 30+ .o
  #      including pipeline_x.o/parser_x.o/typeck_x.o/codegen_x.o/preprocess_x.o).
  #      On macOS/Linux xlang-x/xlang-c are seed copies; xlang itself is never
  #      built standalone. Without this prerequisite the hybrid link fails
  #      with 30+ undefined references. bootstrap-driver-bstrict already
  #      depends on bootstrap-driver-seed (L2580); B-hybrid does not.
  # Invariant: bootstrap-driver-seed is PHONY — always relinks xlang with the
  #            full DRIVER_SEED_PREREQS symbol set, then cp to xlang-x/xlang-c.
  #            Subsequent bootstrap-driver-hybrid sees xlang up-to-date and
  #            skips the 14-.o link rule, running only build_xlang_asm.sh.
  # PLATFORM: WINDOWS | MSYS | MINGW (script only runs on MSYS2 hosts; see
  #           ci_is_windows_msys guard above).
  echo "bootstrap-bstrict-windows-gate: make bootstrap-driver-seed (full symbol set) then bootstrap-driver-hybrid (B-hybrid default) ..."
  make -C compiler bootstrap-driver-seed 2>&1 | tee /tmp/boot_win_seed.log
  SEED_RC=${PIPESTATUS[0]}
  if [ "$SEED_RC" -ne 0 ]; then
    echo "bootstrap-bstrict-windows-gate FAIL: bootstrap-driver-seed rc=$SEED_RC" >&2
    exit 1
  fi
  make -C compiler bootstrap-driver-hybrid 2>&1 | tee /tmp/boot_win_hybrid.log
  BOOT_LOG=/tmp/boot_win_hybrid.log
  EXPECT_MARKER='Target-B-hybrid|B-hybrid|bootstrap-driver-hybrid OK'
fi

if [ ! -x compiler/xlang_asm ]; then
  echo "bootstrap-bstrict-windows-gate FAIL: compiler/xlang_asm missing after build" >&2
  exit 1
fi

if ! grep -qE "$EXPECT_MARKER" "$BOOT_LOG"; then
  echo "bootstrap-bstrict-windows-gate FAIL: log missing expected markers ($EXPECT_MARKER)" >&2
  exit 1
fi

echo "bootstrap-bstrict-windows-gate: smoke return-value via xlang_asm ..."
# Why: bash direct exec of .exe under /tmp/ hits Windows Device Guard / Smart
#      App Control intermittently (Permission denied, exit 126). $TEMP (set to
#      C:/xlang_tmp short path in Windows build env) is reliable. POSIX falls
#      back to /tmp where Device Guard does not apply.
RV_OUT="${TEMP:-/tmp}/xlang_win_rv_$$"
RV_BACKEND_ARGS="-backend c"
rm -f "$RV_OUT" "${RV_OUT}.c" "${RV_OUT}.exe" "${RV_OUT}.out"
compile_rv() {
  local tool="$1"
  shift
  # shellcheck disable=SC2086
  "$tool" $RV_BACKEND_ARGS "$@" tests/return-value/main.x -o "$RV_OUT"
}
if ! compile_rv compiler/xlang_asm 2>/tmp/xlang_win_rv_err.log; then
  if [ -x ./compiler/xlang-c ]; then
    echo "bootstrap-bstrict-windows-gate: xlang_asm compile failed; fallback xlang-c" >&2
    RV_BACKEND_ARGS=""
    if ! ./compiler/xlang-c -L . tests/return-value/main.x -o "$RV_OUT" 2>/tmp/xlang_win_rv_err.log; then
      cat /tmp/xlang_win_rv_err.log >&2
      echo "bootstrap-bstrict-windows-gate FAIL: compile return-value" >&2
      exit 1
    fi
  else
    cat /tmp/xlang_win_rv_err.log >&2
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
# PLATFORM: WINDOWS | MSYS | MINGW — sign the compiled return-value .exe so
# Smart App Control (SAC) does not block it (Permission denied). No-op on POSIX.
if command -v powershell.exe >/dev/null 2>&1; then
  _rv_cert="${XLANG_CODESIGN_THUMBPRINT:-697D4125CC086F4BF683053A2BD6025B939D96FC}"
  _rv_win="$(cygpath -m "$RV_BIN" 2>/dev/null || echo "$RV_BIN")"
  powershell.exe -NoProfile -Command \
    "Set-AuthenticodeSignature -FilePath '$_rv_win' -Certificate (Get-Item \"Cert:\\LocalMachine\\My\\$_rv_cert\")" >/dev/null 2>&1 || true
fi
EX=0
"$RV_BIN" >/dev/null 2>&1 || EX=$?
rm -f "$RV_OUT" "${RV_OUT}.c" "${RV_OUT}.exe" "$RV_BIN"
if [ "$EX" -ne 42 ]; then
  echo "bootstrap-bstrict-windows-gate FAIL: expected exit 42, got $EX" >&2
  exit 1
fi

if [ "$WIN_BSTRICT" = "1" ]; then
  echo "bootstrap-bstrict-windows-gate OK (E-06 v5 Windows B-strict xlang_asm + return-value 42)"
else
  echo "bootstrap-bstrict-windows-gate OK (B-hybrid xlang_asm + return-value 42)"
fi

echo "bootstrap-bstrict-windows-gate: B-17 std.sys win32 WriteFile ..."
chmod +x tests/run-win32-write-gate.sh tests/run-win32-read-file-gate.sh
XLANG_WIN32_WRITE_FAIL=1 ./tests/run-win32-write-gate.sh
XLANG_WIN32_READ_FILE_FAIL=1 ./tests/run-win32-read-file-gate.sh

PIPELINE_GEN_CC=$(grep -E "$PIPELINE_GEN_PAT" "$BOOT_LOG" 2>/dev/null | grep -vE 'info:.*no cc -c pipeline_gen' | wc -l | tr -d '[:space:]')
if [ "$WIN_BSTRICT" = "1" ]; then
  echo "bootstrap-bstrict-windows-gate: C-03/E-06 v5 cc -c pipeline_gen.c count=${PIPELINE_GEN_CC} (must be 0)"
  if [ "${PIPELINE_GEN_CC:-0}" -gt 0 ] 2>/dev/null; then
    echo "bootstrap-bstrict-windows-gate FAIL: Windows B-strict log must not cc -c pipeline_gen.c" >&2
    exit 1
  fi
else
  echo "bootstrap-bstrict-windows-gate: C-03 track cc -c pipeline_gen.c count=${PIPELINE_GEN_CC} (B-hybrid; use XLANG_WIN_BSTRICT=1 for B-strict)"
  if [ "${XLANG_WIN_C03_PIPELINE_GEN_FAIL:-0}" = "1" ] && [ "${PIPELINE_GEN_CC:-0}" -gt 0 ] 2>/dev/null; then
    echo "bootstrap-bstrict-windows-gate FAIL: B-hybrid log must not cc -c pipeline_gen.c (set XLANG_WIN_C03_PIPELINE_GEN_FAIL=0 for track-only)" >&2
    exit 1
  fi
fi
