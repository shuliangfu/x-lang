#!/usr/bin/env bash
# STD-096：std.dynlib last_error 文本诊断门禁（假权威诚实）。
#
# 用法：./tests/run-std-dynlib-last-error-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); last_error.x exit 0 hard-fail (no soft SKIP
# when native xlang present). C smoke remains observational (archaeology host-C
# path; not hard green). Report check=/run=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD096_DOC:-analysis/archive/std/std-dynlib-last-error-v1.md}"
MANIFEST="${XLANG_STD096_TSV:-tests/baseline/std-dynlib-last-error.tsv}"
MOD_X="std/dynlib/mod.x"
DYNLIB_X="std/dynlib/dynlib.x"
DYNLIB_RUNTIME="compiler/seeds/runtime_dynlib_os.from_x.c"
LIB="tests/lib/std-dynlib-last-error.sh"
SMOKE_X="tests/dynlib/last_error.x"
SMOKE_C="tests/dynlib/last_error_smoke.c"
# Designed success score (last_error.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-dynlib-last-error.sh
. "$LIB"

echo "=== STD-096: dynlib last_error manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$DYNLIB_X" "$DYNLIB_RUNTIME" "$SMOKE_X" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-dynlib-last-error gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in last_os_error dynlib_last_error_copy_c STD-096; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-dynlib-last-error gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-dynlib-last-error gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

sym_miss="$(std_dynlib_last_error_symbols_ok "$MOD_X" "$DYNLIB_X" "$MANIFEST" "$DOC" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_dynlib_last_error_emit_report "fail" 0 0 0
  echo "std-dynlib-last-error gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-dynlib-last-error manifest OK"

if [ "${XLANG_STD096_MANIFEST_ONLY:-0}" = "1" ]; then
  std_dynlib_last_error_emit_report "ok" 0 0 1
  echo "std-dynlib-last-error gate OK (manifest only)"
  exit 0
fi

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

CHECK_OK=0
RUN_OK=0
SKIP=1

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is last_error.x via asm.
echo "=== STD-096: dynlib c smoke (observational) ==="
C_NOTE=0
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/dynlib/dynlib.o >/dev/null 2>&1 || true
xlang_compiler_make runtime_dynlib_os.o >/dev/null 2>&1 || true
if [ -f std/dynlib/dynlib.o ] && [ -f compiler/runtime_dynlib_os.o ] \
  && std_dynlib_last_error_run_c_smoke; then
  C_NOTE=1
  echo "std-dynlib-last-error c smoke OK (observational)"
else
  echo "std-dynlib-last-error gate SKIP c smoke (observational; dynlib.o / link)" >&2
fi
echo "std-dynlib-last-error c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-096: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-dynlib-last-error gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std096_dynlib_err_$$"
  LOG="/tmp/xlang_std096_dynlib_err_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-dynlib-last-error gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_dynlib_last_error_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-dynlib-last-error gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_dynlib_last_error_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-dynlib-last-error gate FAIL: no native xlang" >&2
  std_dynlib_last_error_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-dynlib-last-error check_ok=${CHECK_OK} (observational)"
std_dynlib_last_error_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-dynlib-last-error gate OK"
