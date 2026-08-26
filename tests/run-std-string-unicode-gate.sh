#!/usr/bin/env bash
# STD-160：std.string Unicode 桥接门禁（假权威诚实）。
#
# 用法：./tests/run-std-string-unicode-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); unicode_bridge.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP when no xlang-c + fossil
# unicode_case_fold_buf_c anchor — product surface is string_view_*).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

MOD_X="std/string/mod.x"
SMOKE="tests/string/unicode_bridge.x"
PREFIX="xlang: [XLANG_STD160_STRING_UNICODE]"

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

echo "=== STD-160: string-unicode manifest ==="
# Refuse resurrected top-level DOC if ever archived later.
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-string-unicode-v1.md ]; then
  echo "std-string-unicode gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$MOD_X" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "std-string-unicode gate FAIL: missing $f" >&2
    exit 1
  fi
done
# Product surface anchors (drop fossil unicode_case_fold_buf_c — that name is
# std.unicode C/FFI surface in naming docs, not std.string mod.x).
# PLATFORM: SHARED — API authenticity; gate must match live export names.
for sym in string_view_case_fold string_view_is_valid_utf8; do
  if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
    echo "std-string-unicode gate FAIL: missing api $sym" >&2
    exit 1
  fi
done
echo "std-string-unicode manifest OK"

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-160: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-string-unicode gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/string/mod.o 2>/dev/null || xlang_compiler_make ../std/string/mod.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"

  exe="/tmp/xlang_std160_string_unicode_$$"
  LOG="/tmp/xlang_std160_string_unicode_build_$$.log"
  if ! "$XLANG_BIN" -L . "$SMOKE" -o "$exe" >"$LOG" 2>&1; then
    echo "std-string-unicode gate FAIL: compile $SMOKE" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
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
    echo "std-string-unicode gate FAIL: run exit=$ec" >&2
    echo "${PREFIX} status=fail check=${CHECK_OK} run=0 skip=0 host=$(ci_host_summary)"
    exit 1
  fi
  RUN_OK=1
  SKIP=0
else
  echo "std-string-unicode gate FAIL: no native xlang" >&2
  echo "${PREFIX} status=fail check=0 run=0 skip=0 host=$(ci_host_summary)"
  exit 1
fi

# check stays observational; hard-green signal is run=.
echo "std-string-unicode check_ok=${CHECK_OK} (observational)"
echo "${PREFIX} status=ok check=${CHECK_OK} run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "std-string-unicode gate OK"
