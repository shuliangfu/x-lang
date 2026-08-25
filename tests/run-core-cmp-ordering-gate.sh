#!/usr/bin/env bash
# CORE-005：core.cmp 三路比较与 Ordering 门禁（假权威诚实）。
#
# 用法：./tests/run-core-cmp-ordering-gate.sh
# wave honesty (2026-08-24 #11): DOC → analysis/archive/core/;
# check smoke observational SKIP (check gate paused 2026-08-05).
# 2026-08-25: runnable hard-green (formal_mod core/cmp/mod.o + labi g25);
# check stays observational.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_CMP_DOC:-analysis/archive/core/core-cmp-ordering-v1.md}"
MANIFEST="${XLANG_CORE_CMP_TSV:-tests/baseline/core-cmp-ordering.tsv}"
CMP_X="core/cmp/mod.x"
LIB="tests/lib/core-cmp-ordering.sh"
SMOKE="tests/cmp/main.x"

# shellcheck source=tests/lib/core-cmp-ordering.sh
. tests/lib/core-cmp-ordering.sh

echo "=== CORE-005: cmp/Ordering manifest (archive DOC) ==="
if [ -f analysis/core-cmp-ordering-v1.md ]; then
  echo "core-cmp-ordering gate FAIL: top-level DOC resurrected (live = archive/core/)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$CMP_X" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "core-cmp-ordering gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in Ordering cmp_i32 cmp_u8 cmp_ptr then; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-cmp-ordering gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(core_cmp_symbols_ok "$CMP_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_cmp_emit_report "fail" 0 0 0
  echo "core-cmp-ordering gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-cmp-ordering manifest OK"

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
  echo "=== CORE-005: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-cmp-ordering gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
  OUT="/tmp/xlang_core_cmp_$$"
  LOG="/tmp/xlang_core_cmp_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "core-cmp-ordering gate FAIL runnable exit=$exitcode" >&2
      core_cmp_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "core-cmp-ordering gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    core_cmp_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "core-cmp-ordering gate SKIP typeck (no native xlang)" >&2
fi

core_cmp_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "core-cmp-ordering gate OK"
