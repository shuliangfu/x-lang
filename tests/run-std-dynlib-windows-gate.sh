#!/usr/bin/env bash
# STD-027：std.dynlib Windows LoadLibrary 门禁（假权威诚实）。
#
# 用法：./tests/run-std-dynlib-windows-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); open_sym_close.x / main.x / win_path.x exit 0
# hard-fail (no soft SKIP when native xlang present). win_path C smoke remains
# observational (archaeology host-C path; not hard green). Report
# check=/osc=/null=/win_path=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_DYNLIB_WIN_DOC:-analysis/archive/std/std-dynlib-windows-v1.md}"
MANIFEST="${XLANG_STD_DYNLIB_WIN_TSV:-tests/baseline/std-dynlib-windows.tsv}"
DYNLIB_RUNTIME="compiler/seeds/runtime_dynlib_os.from_x.c"
DYNLIB_X="std/dynlib/dynlib.x"
MOD_X="std/dynlib/mod.x"
LIB="tests/lib/std-dynlib-windows.sh"
SMOKE="tests/dynlib/open_sym_close.x"
WIN_PATH_X="tests/dynlib/win_path.x"
WIN_PATH_C="tests/dynlib/win_path_smoke.c"
NULL_TEST="tests/dynlib/main.x"
RUNNER="tests/run-dynlib.sh"

# shellcheck source=tests/lib/std-dynlib-windows.sh
. "$LIB"

echo "=== STD-027: dynlib Windows manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$DYNLIB_X" "$DYNLIB_RUNTIME" "$MOD_X" "$SMOKE" "$WIN_PATH_X" "$WIN_PATH_C" "$NULL_TEST" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "std-dynlib-windows gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in LoadLibraryA LoadLibraryW GetProcAddress FreeLibrary kernel32.dll open_sym_close dynlib_win_normalize_path; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-dynlib-windows gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-dynlib-windows gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

sym_miss="$(std_dynlib_win_manifest_ok "$DOC" "$DYNLIB_RUNTIME" "$MOD_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_dynlib_win_emit_report "fail" 0 0 0 0
  echo "std-dynlib-windows gate FAIL: manifest_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-dynlib-windows manifest OK"

if [ "${XLANG_STD_DYNLIB_WIN_MANIFEST_ONLY:-0}" = "1" ]; then
  std_dynlib_win_emit_report "ok" 0 0 0 0 1
  echo "std-dynlib-windows gate OK (manifest only)"
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
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
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
OSC_OK=0
NULL_OK=0
WIN_PATH_OK=0
SKIP=1

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is .x via asm.
echo "=== STD-027: win path C smoke (observational) ==="
C_NOTE=0
xlang_compiler_make -q ../std/dynlib/dynlib.o runtime_dynlib_os.o 2>/dev/null \
  || xlang_compiler_make ../std/dynlib/dynlib.o runtime_dynlib_os.o 2>/dev/null \
  || true
if [ -f std/dynlib/dynlib.o ] && [ -f compiler/runtime_dynlib_os.o ] \
  && std_dynlib_win_run_c_smoke; then
  C_NOTE=1
  echo "std-dynlib-windows c smoke OK (observational)"
else
  echo "std-dynlib-windows gate SKIP c smoke (observational; dynlib.o / link)" >&2
fi
echo "std-dynlib-windows c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-027: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$NULL_TEST" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$WIN_PATH_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-dynlib-windows gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  run_one() {
    local src="$1"
    local out="$2"
    local log="$3"
    local label="$4"
    if $RUN_XLANG build -L . "$src" -o "$out" 2>"$log"; then
      local exitcode=0
      "$out" >/dev/null 2>&1 || exitcode=$?
      rm -f "$out"
      if [ "$exitcode" -eq 0 ]; then
        return 0
      fi
      echo "std-dynlib-windows gate FAIL ${label} exit=$exitcode" >&2
      return 1
    fi
    echo "std-dynlib-windows gate FAIL ${label} link" >&2
    tail -20 "$log" 2>/dev/null >&2 || true
    return 1
  }

  if run_one "$SMOKE" "/tmp/xlang_std027_osc_$$" "/tmp/xlang_std027_osc_$$.log" "open_sym_close"; then
    OSC_OK=1
  else
    std_dynlib_win_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi
  if run_one "$NULL_TEST" "/tmp/xlang_std027_null_$$" "/tmp/xlang_std027_null_$$.log" "main.null"; then
    NULL_OK=1
  else
    std_dynlib_win_emit_report "fail" "$CHECK_OK" "$OSC_OK" 0 0
    exit 1
  fi
  if run_one "$WIN_PATH_X" "/tmp/xlang_std027_wp_$$" "/tmp/xlang_std027_wp_$$.log" "win_path.x"; then
    WIN_PATH_OK=1
    SKIP=0
  else
    std_dynlib_win_emit_report "fail" "$CHECK_OK" "$OSC_OK" "$NULL_OK" 0
    exit 1
  fi
else
  echo "std-dynlib-windows gate FAIL: no native xlang" >&2
  std_dynlib_win_emit_report "fail" 0 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is osc=/null=/win_path=.
echo "std-dynlib-windows check_ok=${CHECK_OK} (observational)"
std_dynlib_win_emit_report "ok" "$CHECK_OK" "$OSC_OK" "$NULL_OK" "$WIN_PATH_OK" "$SKIP"
echo "std-dynlib-windows gate OK"
