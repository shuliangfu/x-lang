#!/usr/bin/env bash
# STD-019：std.fmt 多参数 format 门禁（假权威诚实）。
#
# 用法：./tests/run-std-fmt-multi-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); format_multi.x exit 0 hard-fail (no soft SKIP
# when native xlang present). Report check=/run=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_FMT_MULTI_DOC:-analysis/archive/std/std-fmt-multi-v1.md}"
MANIFEST="${XLANG_STD_FMT_MULTI_TSV:-tests/baseline/std-fmt-multi.tsv}"
FMT_X="std/fmt/mod.x"
LIB="tests/lib/std-fmt-multi.sh"
SMOKE="tests/fmt-std/format_multi.x"
RUNNER="tests/run-fmt-std.sh"
# Designed success score (format_multi.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-fmt-multi.sh
. tests/lib/std-fmt-multi.sh

echo "=== STD-019: fmt multi manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$FMT_X" "$SMOKE" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "std-fmt-multi gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in 'usize, usize' 'i32, i32, i32' ptr_to_buf; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-fmt-multi gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-fmt-multi gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

sym_miss="$(std_fmt_multi_symbols_ok "$FMT_X" "$MANIFEST" "$DOC" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_fmt_multi_emit_report "fail" 0 0 0
  echo "std-fmt-multi gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-fmt-multi manifest OK"

if [ "${XLANG_STD_FMT_MULTI_MANIFEST_ONLY:-0}" = "1" ]; then
  std_fmt_multi_emit_report "ok" 0 0 1
  echo "std-fmt-multi gate OK (manifest only)"
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

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-019: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-fmt-multi gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std_fmt_multi_$$"
  LOG="/tmp/xlang_std_fmt_multi_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-fmt-multi gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_fmt_multi_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    if grep -qE "library 'zstd' not found|cannot find -lzstd" "$LOG" 2>/dev/null; then
      echo "std-fmt-multi gate FAIL: libzstd missing (install zstd or rebuild compress.o without XLANG_USE_ZSTD)" >&2
    else
      echo "std-fmt-multi gate FAIL runnable link" >&2
    fi
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_fmt_multi_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-fmt-multi gate FAIL: no native xlang" >&2
  std_fmt_multi_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-fmt-multi check_ok=${CHECK_OK} (observational)"
std_fmt_multi_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-fmt-multi gate OK"
