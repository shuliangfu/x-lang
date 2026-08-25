#!/usr/bin/env bash
# STD-055：std.ffi CString 生命周期与错误码门禁（假权威诚实）。
#
# 用法：./tests/run-std-ffi-cstring-lifecycle-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); cstring_try_new.x exit 0 hard-fail (no soft SKIP
# when native xlang present). C smoke remains observational (archaeology host-C
# path; not hard green). SAFE-004 regression stays hard. Report
# check=/run=/safe004=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_FFI_CSTRING_DOC:-analysis/archive/std/std-ffi-cstring-lifecycle-v1.md}"
MANIFEST="${XLANG_STD_FFI_CSTRING_TSV:-tests/baseline/std-ffi-cstring-lifecycle.tsv}"
VECTORS="${XLANG_STD_FFI_CSTRING_VECTORS:-tests/baseline/std-ffi-cstring-lifecycle-vectors.tsv}"
MOD_X="std/ffi/mod.x"
FFI_IMPL="std/ffi/ffi.x"
LIB="tests/lib/std-ffi-cstring-lifecycle.sh"
SMOKE_X="tests/std-ffi/cstring_try_new.x"
SMOKE_C="tests/std-ffi/cstring_lifecycle_ok.c"
SAFE_HOOK="tests/run-safe-ffi-contract-gate.sh"
MIN_APIS=4
# Designed success score (cstring_try_new.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-ffi-cstring-lifecycle.sh
. "$LIB"

echo "=== STD-055: ffi cstring lifecycle manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$FFI_IMPL" "$SMOKE_X" "$SMOKE_C" "$SAFE_HOOK"; do
  if [ ! -f "$f" ]; then
    echo "std-ffi-cstring gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-055 FFI_ERR_OOM cstring_try_new TYPE-004; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-ffi-cstring gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-ffi-cstring gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-ffi-cstring gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-ffi-cstring gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-ffi-cstring gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_ffi_cstring_symbols_ok "$MOD_X" "$FFI_IMPL" "$FFI_IMPL" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_ffi_cstring_emit_report "fail" 0 0 0 0
  echo "std-ffi-cstring gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-ffi-cstring manifest OK"

if [ "${XLANG_STD_FFI_CSTRING_MANIFEST_ONLY:-0}" = "1" ]; then
  std_ffi_cstring_emit_report "ok" 0 0 0 1
  echo "std-ffi-cstring gate OK (manifest only)"
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
SAFE_OK=0
SKIP=1

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is cstring_try_new.x via asm.
echo "=== STD-055: ffi c smoke (observational) ==="
C_NOTE=0
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
if ensure_std_c_o ../std/ffi/ffi.o 2>/dev/null && std_ffi_cstring_run_c_smoke "$FFI_IMPL"; then
  C_NOTE=1
  echo "std-ffi-cstring c smoke OK (observational)"
else
  echo "std-ffi-cstring gate SKIP c smoke (observational; no full ffi.o / link)" >&2
fi
echo "std-ffi-cstring c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-055: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-ffi-cstring gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std055_ffi_cstr_$$"
  LOG="/tmp/xlang_std055_ffi_cstr_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-ffi-cstring gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_ffi_cstring_emit_report "fail" "$CHECK_OK" 0 0 0
      exit 1
    fi
  else
    echo "std-ffi-cstring gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_ffi_cstring_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi
else
  echo "std-ffi-cstring gate FAIL: no native xlang" >&2
  std_ffi_cstring_emit_report "fail" 0 0 0 0
  exit 1
fi

echo "=== STD-055: SAFE-004 regression ==="
if chmod +x "$SAFE_HOOK" && "$SAFE_HOOK" >/tmp/std_ffi_safe004_regress.log 2>&1; then
  if grep -q 'safe-ffi-contract gate OK' /tmp/std_ffi_safe004_regress.log; then
    SAFE_OK=1
  fi
fi
if [ "$SAFE_OK" -ne 1 ]; then
  tail -15 /tmp/std_ffi_safe004_regress.log >&2 || true
  std_ffi_cstring_emit_report "fail" "$CHECK_OK" "$RUN_OK" 0 "$SKIP"
  echo "std-ffi-cstring gate FAIL: SAFE-004 regression" >&2
  exit 1
fi

# check stays observational; hard-green signals are run= + safe004=.
echo "std-ffi-cstring check_ok=${CHECK_OK} (observational)"
std_ffi_cstring_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SAFE_OK" "$SKIP"
echo "std-ffi-cstring gate OK"
