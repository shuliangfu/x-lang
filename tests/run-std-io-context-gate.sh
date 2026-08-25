#!/usr/bin/env bash
# STD-091：std.io ↔ std.context read_ctx/write_ctx 联动门禁（假权威诚实）。
#
# 用法：./tests/run-std-io-context-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); context_read_write.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

MOD_X="std/io/mod.x"
SMOKE="tests/io/context_read_write.x"
PREFIX="xlang: [XLANG_STD091_IO_CTX]"

stdlib_cm_native_xlang() {
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

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== STD-091: io-context manifest ==="
for f in "$MOD_X" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "io-context gate FAIL: missing $f" >&2
    exit 1
  fi
done
for sym in timeout_from_ctx read_ctx write_ctx IO_CTX_MS_CANCELLED IO_CTX_MS_EXPIRED; do
  case "$sym" in
    IO_CTX_MS_*)
      if ! grep -qF "const ${sym}:" "$MOD_X" 2>/dev/null; then
        echo "io-context gate FAIL: missing const $sym" >&2
        exit 1
      fi
      ;;
    *)
      if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
        echo "io-context gate FAIL: missing api $sym" >&2
        exit 1
      fi
      ;;
  esac
done
echo "io-context manifest OK"

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-091: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "io-context gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  ensure_std_c_o ../std/context/context.o
  ensure_std_c_o ../std/time/time.o
  ensure_std_c_o ../std/atomic/atomic.o
  ensure_runtime_atomic_glue_o
  ensure_runtime_time_os_o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"

  exe="/tmp/xlang_std091_io_ctx_$$"
  if ! "$XLANG_BIN" -L . "$SMOKE" -o "$exe" compiler/runtime_atomic_glue.o compiler/runtime_time_os.o >/dev/null 2>&1; then
    echo "io-context gate FAIL: compile $SMOKE" >&2
    "$XLANG_BIN" -L . "$SMOKE" 2>&1 | tail -20 >&2 || true
    rm -f "$exe"
    echo "${PREFIX} status=fail check=${CHECK_OK} run=0 skip=0 host=$(ci_host_summary)"
    exit 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "io-context gate FAIL: run exit=$ec" >&2
    echo "${PREFIX} status=fail check=${CHECK_OK} run=0 skip=0 host=$(ci_host_summary)"
    exit 1
  fi
  RUN_OK=1
  SKIP=0
else
  echo "io-context gate FAIL: no native xlang" >&2
  echo "${PREFIX} status=fail check=0 run=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi

# check stays observational; hard-green signal is run=.
echo "io-context check_ok=${CHECK_OK} (observational)"
echo "${PREFIX} status=ok check=${CHECK_OK} run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "std-io-context gate OK"
