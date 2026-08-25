#!/usr/bin/env bash
# CORE-002/003：Option/Result 类型族与组合子门禁（假权威诚实）。
#
# 用法：./tests/run-core-option-result-gate.sh
# wave honesty (2026-08-24 #10): DOC → analysis/archive/core/;
# check smoke observational SKIP (check gate paused 2026-08-05).
# 2026-08-25: runnable hard-green (core/option/option.o + core/result/result.o surface);
# Prefer xlang_asm; option exit 102 + result exit 173 hard-fail (no soft SKIP).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_OR_DOC:-analysis/archive/core/core-option-result-combinators-v1.md}"
MANIFEST="${XLANG_CORE_OR_TSV:-tests/baseline/core-option-result.tsv}"
OPTION_X="core/option/mod.x"
RESULT_X="core/result/mod.x"
LIB="tests/lib/core-option-result.sh"
OPTION_SMOKE="tests/option/main.x"
RESULT_SMOKE="tests/result/main.x"
# Designed success scores (see tests/run-option.sh / run-result.sh).
OPTION_EXPECT=102
RESULT_EXPECT=173

# shellcheck source=tests/lib/core-option-result.sh
. tests/lib/core-option-result.sh

echo "=== CORE-002/003: Option/Result manifest (archive DOC) ==="
if [ -f analysis/core-option-result-combinators-v1.md ]; then
  echo "core-option-result gate FAIL: top-level DOC resurrected (live = archive/core/)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$OPTION_X" "$RESULT_X" "$OPTION_SMOKE" "$RESULT_SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "core-option-result gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in eager EXC-001 Option_ptr_u8 Result_u8 or_else_i32; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-option-result gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(core_or_symbols_ok "$OPTION_X" "$RESULT_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_or_emit_report "fail" 0 0 0
  echo "core-option-result gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-option-result manifest OK"

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
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

OPT_OK=0
RES_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== CORE-002/003: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$OPTION_SMOKE" >/dev/null 2>&1; then
    OPT_OK=1
  else
    echo "core-option-result gate SKIP check option (paused 2026-08-05)" >&2
  fi
  if "$XLANG_BIN" check -L . "$RESULT_SMOKE" >/dev/null 2>&1; then
    RES_OK=1
  else
    echo "core-option-result gate SKIP check result (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm). Avoid Darwin-arm64
  # bootstrap remap of xlang_asm → xlang-c that hides pure-asm UNDEF.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OPT_OUT="/tmp/xlang_core_or_option_$$"
  OPT_LOG="/tmp/xlang_core_or_option_build_$$.log"
  if $RUN_XLANG build -L . "$OPTION_SMOKE" -o "$OPT_OUT" 2>"$OPT_LOG"; then
    opt_ec=0
    "$OPT_OUT" >/dev/null 2>&1 || opt_ec=$?
    rm -f "$OPT_OUT"
    if [ "$opt_ec" -eq "$OPTION_EXPECT" ]; then
      OPT_OK=1
    else
      echo "core-option-result gate FAIL option exit=$opt_ec (expect $OPTION_EXPECT)" >&2
      core_or_emit_report "fail" 0 0 0
      exit 1
    fi
  else
    echo "core-option-result gate FAIL option link" >&2
    tail -20 "$OPT_LOG" 2>/dev/null >&2 || true
    core_or_emit_report "fail" 0 0 0
    exit 1
  fi

  RES_OUT="/tmp/xlang_core_or_result_$$"
  RES_LOG="/tmp/xlang_core_or_result_build_$$.log"
  if $RUN_XLANG build -L . "$RESULT_SMOKE" -o "$RES_OUT" 2>"$RES_LOG"; then
    res_ec=0
    "$RES_OUT" >/dev/null 2>&1 || res_ec=$?
    rm -f "$RES_OUT"
    if [ "$res_ec" -eq "$RESULT_EXPECT" ]; then
      RES_OK=1
      SKIP=0
    else
      echo "core-option-result gate FAIL result exit=$res_ec (expect $RESULT_EXPECT)" >&2
      core_or_emit_report "fail" "$OPT_OK" 0 0
      exit 1
    fi
  else
    echo "core-option-result gate FAIL result link" >&2
    tail -20 "$RES_LOG" 2>/dev/null >&2 || true
    core_or_emit_report "fail" "$OPT_OK" 0 0
    exit 1
  fi
else
  echo "core-option-result gate SKIP typeck (no native xlang)" >&2
fi

core_or_emit_report "ok" "$OPT_OK" "$RES_OK" "$SKIP"
echo "core-option-result gate OK"
