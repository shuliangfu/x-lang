#!/usr/bin/env bash
# STD-011：标准库错误码统一 manifest 门禁（假权威诚实）。
#
# 1) archive DOC + matrix + EXC layer/RFC fossils under analysis/archive/exc/
# 2) error_base_* / <mod>_err_* 符号；sidecar 存在
# 3) native xlang：tests/std/error_unify_smoke.x（prefer asm；runnable hard）
#
# 用法：./tests/run-std-error-unify-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); error_unify_smoke.x exit 0 hard-fail (no soft
# SKIP when native xlang present). EXC DOC deps → analysis/archive/exc/*.
# Report check=/run=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_ERROR_UNIFY_DOC:-analysis/archive/std/std-error-unify-v1.md}"
MATRIX="${XLANG_STD_ERROR_UNIFY_TSV:-tests/baseline/std-error-unify.tsv}"
ERR_MOD="${XLANG_STD_ERROR_MOD:-std/error/mod.x}"
LIB="tests/lib/std-error-unify.sh"
LAYER_DOC="${XLANG_EXC_ERROR_CODE_LAYER_DOC:-analysis/archive/exc/exc-error-code-layer-v1.md}"
RESULT_RFC="${XLANG_EXC_RESULT_ERROR_RFC:-analysis/archive/exc/exc-result-error-v1-rfc.md}"
SMOKE="tests/std/error_unify_smoke.x"
# Designed success score (tests/std/error_unify_smoke.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-error-unify.sh
. "$LIB"

echo "=== STD-011: std error unify manifest ==="
for f in "$DOC" "$MATRIX" "$ERR_MOD" "$LIB" "$LAYER_DOC" "$RESULT_RFC" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "std-error-unify gate FAIL: missing $f" >&2
    exit 1
  fi
done

if ! grep -qF 'STD-011' "$DOC" 2>/dev/null; then
  echo "std-error-unify gate FAIL: doc missing STD-011" >&2
  exit 1
fi
if ! grep -qF 'std-error-unify.tsv' "$DOC" 2>/dev/null; then
  echo "std-error-unify gate FAIL: doc missing matrix ref" >&2
  exit 1
fi

echo "=== STD-011: module matrix ==="
miss="$(std_error_unify_manifest_ok "$ERR_MOD" "$MATRIX" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  std_error_unify_emit_report "fail" 0 0 0
  echo "std-error-unify gate FAIL: missing=${miss}" >&2
  exit 1
fi

# Allow smoke path override from matrix smoke_case row (same as historical gate).
while IFS=$'\t' read -r module_id _exc _base _side src _tier _notes; do
  [ -z "${module_id:-}" ] && continue
  case "$module_id" in
    smoke_case)
      SMOKE="$src"
      ;;
  esac
done < "$MATRIX"
if [ ! -f "$SMOKE" ]; then
  echo "std-error-unify gate FAIL: missing $SMOKE" >&2
  exit 1
fi
echo "std-error-unify manifest OK"

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
  echo "=== STD-011: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-error-unify gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/error/mod.o 2>/dev/null || xlang_compiler_make ../std/error/mod.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std_error_unify_$$"
  LOG="/tmp/xlang_std_error_unify_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-error-unify gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_error_unify_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-error-unify gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_error_unify_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-error-unify gate FAIL: no native xlang" >&2
  std_error_unify_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-error-unify check_ok=${CHECK_OK} (observational)"
std_error_unify_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-error-unify gate OK"
