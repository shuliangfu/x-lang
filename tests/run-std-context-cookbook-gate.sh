#!/usr/bin/env bash
# STD-156：std.context Cookbook 扩展示例门禁（假权威诚实）。
#
# 用法：./tests/run-std-context-cookbook-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; cookbook recipe exit 0 hard-fail (no soft SKIP /
# no hard check). check smoke observational SKIP (check gate paused 2026-08-05).
# cookbook expand DOC → analysis/archive/doc/ (refuse top-level resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD156_DOC:-analysis/archive/std/std-context-cookbook-v1.md}"
MANIFEST="${XLANG_STD156_TSV:-tests/baseline/std-context-cookbook.tsv}"
COOKBOOK_DOC="${XLANG_DOC_COOKBOOK_EXPAND:-analysis/archive/doc/doc-cookbook-expand-v1.md}"
MOD_X="std/context/mod.x"
LIB="tests/lib/std-context-cookbook.sh"
RECIPE="examples/cookbook/context_cancel_deadline.x"
MIN_REC=1
# Designed success score (context_cancel_deadline.x returns 0 on all checks).
RECIPE_EXPECT=0

# shellcheck source=tests/lib/std-context-cookbook.sh
. "$LIB"

echo "=== STD-156: context cookbook manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$RECIPE" "$COOKBOOK_DOC"; do
  if [ ! -f "$f" ]; then
    echo "std-context-cookbook gate FAIL: missing $f" >&2
    exit 1
  fi
done

# Refuse top-level DOC resurrection (portable fake-red / dual authority).
# PLATFORM: SHARED archaeology — live expand DOC lives under analysis/archive/doc/.
if [ -f analysis/doc-cookbook-expand-v1.md ]; then
  echo "std-context-cookbook gate FAIL: top-level DOC resurrected (analysis/doc-cookbook-expand-v1.md; use archive)" >&2
  exit 1
fi

for kw in STD-156 CTX-01 with_timeout is_cancelled; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-context-cookbook gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "$RECIPE" "$COOKBOOK_DOC" 2>/dev/null; then
  echo "std-context-cookbook gate FAIL: cookbook doc missing recipe ref" >&2
  exit 1
fi

REC_N=0
sym_miss="$(std_context_cookbook_symbols_ok "$MOD_X" "$MANIFEST" || true)"
while IFS=$'\t' read -r item_id kind _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "recipe" ] && REC_N=$((REC_N + 1))
done < "$MANIFEST"

if [ "$REC_N" -lt "$MIN_REC" ]; then
  echo "std-context-cookbook gate FAIL: recipes=$REC_N < min $MIN_REC" >&2
  exit 1
fi
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_context_cookbook_emit_report "fail" 0 0 0
  echo "std-context-cookbook gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-context-cookbook manifest OK"

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
  echo "=== STD-156: cookbook (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$RECIPE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-context-cookbook gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/context/mod.o 2>/dev/null || xlang_compiler_make ../std/context/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/context/context.o 2>/dev/null || xlang_compiler_make ../std/context/context.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std_context_cookbook_$$"
  LOG="/tmp/xlang_std_context_cookbook_build_$$.log"
  if $RUN_XLANG build -L . "$RECIPE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$RECIPE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-context-cookbook gate FAIL runnable exit=$exitcode (expect $RECIPE_EXPECT)" >&2
      std_context_cookbook_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-context-cookbook gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_context_cookbook_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-context-cookbook gate FAIL: no native xlang" >&2
  std_context_cookbook_emit_report "fail" 0 0 0
  exit 1
fi

std_context_cookbook_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-context-cookbook gate OK"
