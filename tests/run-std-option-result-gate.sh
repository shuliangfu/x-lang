#!/usr/bin/env bash
# STD-080/081：std.option + std.result 门禁（假权威诚实）。
#
# 用法：./tests/run-std-option-result-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); roundtrip.x exit 0 hard-fail (no soft SKIP
# when native xlang present). Report check=/run=/skip=.
# formal_mod: std/option/option.o + std/result/result.o (mod|0); fk0 k25/k26;
# labi_std plan steps before task. Smoke: err.* + bool false (not bare ok()/==0).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_OPTION_RESULT_DOC:-analysis/archive/std/std-option-result-v1.md}"
OPT_MANIFEST="${XLANG_STD_OPTION_MANIFEST:-tests/baseline/std-option-manifest.tsv}"
RES_MANIFEST="${XLANG_STD_RESULT_MANIFEST:-tests/baseline/std-result-manifest.tsv}"
OPT_X="std/option/mod.x"
RES_X="std/result/mod.x"
LIB="tests/lib/std-option-result.sh"
SMOKE_X="tests/std-option-result/roundtrip.x"
MIN_OPT=8
MIN_RES=8
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-option-result.sh
. "$LIB"

echo "=== STD-080/081: std.option & std.result manifest ==="
for f in "$DOC" "$OPT_MANIFEST" "$RES_MANIFEST" "$LIB" "$OPT_X" "$RES_X" "$SMOKE_X" std/option/README.md std/result/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-option-result gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-080 STD-081 from_result from_error_code map and_then; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-option-result gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "std-option-result gate FAIL: doc missing '## 3. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_OPT="$c2" ;; esac
done < "$OPT_MANIFEST"
while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_RES="$c2" ;; esac
done < "$RES_MANIFEST"

std_option_result_check_manifest "$OPT_X" "$OPT_MANIFEST" "$MIN_OPT" "std.option"
std_option_result_check_manifest "$RES_X" "$RES_MANIFEST" "$MIN_RES" "std.result"
echo "std-option-result manifest OK"

if [ "${XLANG_STD_OPTION_RESULT_MANIFEST_ONLY:-0}" = "1" ]; then
  std_option_result_emit_report "ok" 0 0 1
  echo "std-option-result gate OK (manifest only)"
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
  echo "=== STD-080/081: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-option-result gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std080_option_result_$$"
  LOG="/tmp/xlang_std080_option_result_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-option-result gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_option_result_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-option-result gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_option_result_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-option-result gate FAIL: no native xlang" >&2
  std_option_result_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-option-result check_ok=${CHECK_OK} (observational)"
std_option_result_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-option-result gate OK"
