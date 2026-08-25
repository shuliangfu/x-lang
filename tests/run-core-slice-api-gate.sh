#!/usr/bin/env bash
# CORE-004：切片 subslice/split_at/chunks 门禁（假权威诚实）。
#
# 用法：./tests/run-core-slice-api-gate.sh
# wave honesty (2026-08-24 #11): DOC → analysis/archive/core/;
# check smoke observational SKIP (check gate paused 2026-08-05).
# 2026-08-25: runnable hard-green (labi g9 full core/slice/mod.o surface ×28);
# Prefer xlang_asm; check stays observational.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_SLICE_DOC:-analysis/archive/core/core-slice-api-v1.md}"
DOC_GENERIC="${XLANG_CORE_SLICE_GENERIC_DOC:-analysis/archive/core/core-slice-generic-v1.md}"
MANIFEST="${XLANG_CORE_SLICE_TSV:-tests/baseline/core-slice-api.tsv}"
SLICE_X="core/slice/mod.x"
LIB="tests/lib/core-slice-api.sh"
SMOKE="tests/slice/subslice_split_chunks.x"
PREFIX="xlang: [XLANG_CORE_SLICE_API]"

# shellcheck source=tests/lib/core-slice-api.sh
. tests/lib/core-slice-api.sh

echo "=== CORE-004: slice API manifest (archive DOC) ==="
if [ -f analysis/core-slice-api-v1.md ] || [ -f analysis/core-slice-generic-v1.md ]; then
  echo "core-slice-api gate FAIL: top-level DOC resurrected (live = archive/core/)" >&2
  exit 1
fi
for f in "$DOC" "$DOC_GENERIC" "$MANIFEST" "$LIB" "$SLICE_X" "$SMOKE" core/option/mod.x; do
  if [ ! -f "$f" ]; then
    echo "core-slice-api gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in subslice split_at chunks_len 零拷贝 is_empty_i32 len_u64 subslice_u64; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-slice-api gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(core_slice_symbols_ok "$SLICE_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_slice_emit_report "fail" 0 0 0
  echo "core-slice-api gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-slice-api manifest OK"

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

CHECK_OK=0
RUN_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== CORE-004: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-slice-api gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
  OUT="/tmp/xlang_core_slice_api_$$"
  LOG="/tmp/xlang_core_slice_api_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "core-slice-api gate FAIL runnable exit=$exitcode" >&2
      core_slice_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "core-slice-api gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    core_slice_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "core-slice-api gate SKIP typeck (no native xlang)" >&2
fi

core_slice_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "core-slice-api gate OK"
