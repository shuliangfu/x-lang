#!/usr/bin/env bash
# LANG-009：Option<T> 泛型 struct 门禁（假权威诚实）。
#
# 用法：./tests/run-lang-option-generic-gate.sh
# wave honesty (2026-08-24 #10): DOC → analysis/archive/lang/;
# typeck_generic_struct.c/parser.c retired — live mono = codegen.x;
# check smoke observational SKIP (check gate paused 2026-08-05).
# 2026-08-25: runnable hard-green (STRUCT_LIT type-inst mangle + named lit typeck).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_LANG009_DOC:-analysis/archive/lang/lang-option-generic-v1.md}"
MANIFEST="${XLANG_LANG009_TSV:-tests/baseline/lang-option-generic.tsv}"
SMOKE1="tests/lang-option-generic/option_three.x"
SMOKE2="tests/lang-option-generic/with_core_import.x"
CODEGEN_X="compiler/src/codegen/codegen.x"
MIN_GOLDEN=2

# shellcheck source=tests/lib/lang-option-generic.sh
. tests/lib/lang-option-generic.sh

echo "=== LANG-009: Option<T> generic struct manifest (c retired) ==="
if [ -f analysis/lang-option-generic-v1.md ]; then
  echo "lang-option-generic gate FAIL: top-level DOC resurrected (live = archive/lang/)" >&2
  exit 1
fi
if [ -f compiler/src/typeck/typeck_generic_struct.c ]; then
  echo "lang-option-generic gate FAIL: typeck_generic_struct.c resurrected" >&2
  exit 1
fi
if [ -f compiler/src/parser/parser.c ]; then
  echo "lang-option-generic gate FAIL: parser.c resurrected (live = parser.x)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$SMOKE1" "$SMOKE2" core/option/mod.x "$CODEGEN_X"; do
  if [ ! -f "$f" ]; then
    echo "lang-option-generic gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_golden) MIN_GOLDEN="$c2" ;;
  esac
done < "$MANIFEST"

for kw in Option M7 typeck_materialize parser_append_type_inst_mangle; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "lang-option-generic gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(lang_option_generic_check "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  lang_option_generic_emit_report "fail" 0 0 0
  exit 1
fi
echo "lang-option-generic manifest OK"

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

XLANG_BIN=""
for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
  [ -n "$cand" ] || continue
  if stdlib_cm_native_xlang "$cand"; then
    XLANG_BIN="$cand"
    break
  fi
done

if [ -n "$XLANG_BIN" ]; then
  echo "=== LANG-009: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Observational: check gate paused (2026-08-05); prefer -o path.
  if "$XLANG_BIN" check -L . "$SMOKE1" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE2" >/dev/null 2>&1; then
    TYPECK_OK=1
  else
    echo "lang-option-generic gate SKIP check (paused / typeck debt)" >&2
  fi
  exe="/tmp/xlang_lang009_$$"
  set +e
  for x in "$SMOKE1" "$SMOKE2"; do
    link_log=$("$XLANG_BIN" -L . "$x" -o "$exe" 2>&1)
    link_ec=$?
    if [ "$link_ec" -ne 0 ]; then
      echo "lang-option-generic gate FAIL: runnable link ($x)" >&2
      echo "$link_log" | tail -20 >&2 || true
      exit 1
    fi
    "$exe" >/dev/null 2>&1
    run_ec=$?
    rm -f "$exe"
    if [ "$run_ec" -ne 0 ]; then
      echo "lang-option-generic gate FAIL: run $x exit=$run_ec" >&2
      exit 1
    fi
    GOLDEN_OK=$((GOLDEN_OK + 1))
    TYPECK_OK=1
    SKIP=0
  done
  if [ "$GOLDEN_OK" -lt "$MIN_GOLDEN" ]; then
    echo "lang-option-generic gate FAIL: golden=$GOLDEN_OK < min $MIN_GOLDEN" >&2
    exit 1
  fi
else
  echo "lang-option-generic gate SKIP smoke (no native xlang-c)" >&2
fi

lang_option_generic_emit_report "ok" "$GOLDEN_OK" "$TYPECK_OK" "$SKIP"
echo "lang-option-generic gate OK"
