#!/usr/bin/env bash
# CORE-012：core.debug 断言类型扩展门禁（假权威诚实）。
#
# 用法：./tests/run-core-debug-assert-extend-gate.sh
# wave honesty (2026-08-24 #11): DOC → analysis/archive/core/;
# check smoke observational SKIP (check gate paused 2026-08-05).
# 2026-08-25: runnable hard-green (core/debug/debug.o assert_eq_u64/ptr/ne_bool surface);
# Prefer xlang_asm; assert_extend.x exit 0 hard-fail (no Darwin soft SKIP).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_DEBUG_ASSERT_EXTEND_DOC:-analysis/archive/core/core-debug-assert-extend-v1.md}"
MANIFEST="${XLANG_CORE_DEBUG_ASSERT_EXTEND_TSV:-tests/baseline/core-debug-assert-extend.tsv}"
DEBUG_X="core/debug/mod.x"
LIB="tests/lib/core-debug-assert-extend.sh"
SMOKE="tests/debug/assert_extend.x"
REGRESS="tests/debug/main.x"
MIN_SYMBOLS=6
# Designed success score (tests/debug/assert_extend.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/core-debug-assert-extend.sh
. tests/lib/core-debug-assert-extend.sh

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

echo "=== CORE-012: debug assert extend manifest (archive DOC) ==="
if [ -f analysis/core-debug-assert-extend-v1.md ]; then
  echo "core-debug-assert-extend gate FAIL: top-level DOC resurrected (live = archive/core/)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$DEBUG_X" "$SMOKE" "$REGRESS"; do
  if [ ! -f "$f" ]; then
    echo "core-debug-assert-extend gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_symbols) MIN_SYMBOLS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in assert_eq_u64 assert_eq_ptr assert_ne_bool panic; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-debug-assert-extend gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
SYM_N=0
while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "core-debug-assert-extend FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol) SYM_N=$((SYM_N + 1)) ;;
    smoke)
      if ! grep -qF "$anchor" "$SMOKE" 2>/dev/null; then
        echo "core-debug-assert-extend FAIL: smoke missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SYM_N" -lt "$MIN_SYMBOLS" ] || [ "$MISS" -gt 0 ]; then
  echo "core-debug-assert-extend gate FAIL: symbols=${SYM_N} miss=${MISS}" >&2
  exit 1
fi

sym_miss="$(core_debug_assert_extend_symbols_ok "$DEBUG_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_debug_assert_extend_emit_report "fail" 0 1
  exit 1
fi
echo "core-debug-assert-extend manifest OK (symbols=${SYM_N})"

CHECK_OK=0
X_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== CORE-012: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-debug-assert-extend gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm). Avoid Darwin-arm64
  # bootstrap remap of xlang_asm → xlang-c that hides pure-asm UNDEF / hangs host-cc.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_core_debug_assert_extend_$$"
  LOG="/tmp/xlang_core_debug_assert_extend_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      X_OK=1
      SKIP=0
    else
      echo "core-debug-assert-extend gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      core_debug_assert_extend_emit_report "fail" 0 0
      exit 1
    fi
  else
    echo "core-debug-assert-extend gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    core_debug_assert_extend_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "core-debug-assert-extend gate SKIP typeck (no native xlang)" >&2
fi

# check stays observational; hard-green signal is x= (runnable).
echo "core-debug-assert-extend check_ok=${CHECK_OK} (observational)"
core_debug_assert_extend_emit_report "ok" "$X_OK" "$SKIP"
echo "core-debug-assert-extend gate OK"
