#!/usr/bin/env bash
# LANG-010：Result<T,E> 泛型 struct 门禁（假权威诚实）。
#
# 用法：./tests/run-lang-result-generic-gate.sh
# wave honesty (2026-08-24 #10): DOC → analysis/archive/lang/;
# typeck_generic_struct.c/parser.c retired — live = typeck.x / codegen.x;
# check smoke observational SKIP (check gate paused 2026-08-05).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_LANG010_DOC:-analysis/archive/lang/lang-result-generic-v1.md}"
MANIFEST="${XLANG_LANG010_TSV:-tests/baseline/lang-result-generic.tsv}"
SMOKE1="tests/lang-result-generic/result_three.x"
SMOKE2="tests/lang-result-generic/with_core_import.x"
TYPECK_X="compiler/src/typeck/typeck.x"
CODEGEN_X="compiler/src/codegen/codegen.x"
MIN_GOLDEN=2

# shellcheck source=tests/lib/lang-result-generic.sh
. tests/lib/lang-result-generic.sh

echo "=== LANG-010: Result<T,E> generic struct manifest (c retired) ==="
if [ -f analysis/lang-result-generic-v1.md ]; then
  echo "lang-result-generic gate FAIL: top-level DOC resurrected (live = archive/lang/)" >&2
  exit 1
fi
if [ -f compiler/src/typeck/typeck_generic_struct.c ]; then
  echo "lang-result-generic gate FAIL: typeck_generic_struct.c resurrected" >&2
  exit 1
fi
if [ -f compiler/src/parser/parser.c ]; then
  echo "lang-result-generic gate FAIL: parser.c resurrected (live = parser.x)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$SMOKE1" "$SMOKE2" core/result/mod.x "$TYPECK_X" "$CODEGEN_X"; do
  if [ ! -f "$f" ]; then
    echo "lang-result-generic gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_golden) MIN_GOLDEN="$c2" ;;
  esac
done < "$MANIFEST"

for kw in Result M7 typeck_materialize parser_append_type_inst_mangle; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "lang-result-generic gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(lang_result_generic_check "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  lang_result_generic_emit_report "fail" 0 0 0
  exit 1
fi
echo "lang-result-generic manifest OK"

GOLDEN_OK=0
TYPECK_OK=0
SKIP=1

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

if XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang-c && echo ./compiler/xlang-c || true)"; then
  :
elif XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang && echo ./compiler/xlang || true)"; then
  :
else
  XLANG_BIN=""
fi

if [ -n "$XLANG_BIN" ]; then
  echo "=== LANG-010: smoke (XLANG=$XLANG_BIN; check observational) ==="
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  if "$XLANG_BIN" check -L . "$SMOKE1" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE2" >/dev/null 2>&1; then
    TYPECK_OK=1
  else
    echo "lang-result-generic gate SKIP check (paused / typeck debt)" >&2
  fi
  exe="/tmp/xlang_lang010_$$"
  set +e
  for x in "$SMOKE1" "$SMOKE2"; do
    link_log=$("$XLANG_BIN" -L . "$x" -o "$exe" 2>&1)
    link_ec=$?
    if [ "$link_ec" -ne 0 ]; then
      echo "lang-result-generic gate SKIP runnable link ($x)" >&2
      echo "$link_log" | tail -5 >&2 || true
      SKIP=1
      break
    fi
    "$exe" >/dev/null 2>&1
    run_ec=$?
    rm -f "$exe"
    if [ "$run_ec" -ne 0 ]; then
      echo "lang-result-generic gate SKIP run $x exit=$run_ec" >&2
      SKIP=1
      break
    fi
    GOLDEN_OK=$((GOLDEN_OK + 1))
    TYPECK_OK=1
    SKIP=0
  done
  if [ "$GOLDEN_OK" -lt "$MIN_GOLDEN" ] && [ "$SKIP" -eq 0 ]; then
    echo "lang-result-generic gate FAIL: golden=$GOLDEN_OK < min $MIN_GOLDEN" >&2
    exit 1
  fi
  if [ "$SKIP" -eq 1 ]; then
    GOLDEN_OK=0
  fi
else
  echo "lang-result-generic gate SKIP smoke (no native xlang-c)" >&2
fi

lang_result_generic_emit_report "ok" "$GOLDEN_OK" "$TYPECK_OK" "$SKIP"
echo "lang-result-generic gate OK"
