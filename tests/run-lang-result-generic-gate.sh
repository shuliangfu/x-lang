#!/usr/bin/env bash
# LANG-010：Result<T,E> 泛型 struct 门禁
#
# 用法：./tests/run-lang-result-generic-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_LANG010_DOC:-analysis/lang-result-generic-v1.md}"
MANIFEST="${SHUX_LANG010_TSV:-tests/baseline/lang-result-generic.tsv}"
SMOKE1="tests/lang-result-generic/result_three.x"
SMOKE2="tests/lang-result-generic/with_core_import.x"
MIN_GOLDEN=2

# shellcheck source=tests/lib/lang-result-generic.sh
. tests/lib/lang-result-generic.sh

echo "=== LANG-010: Result<T,E> generic struct manifest ==="
for f in "$DOC" "$MANIFEST" "$SMOKE1" "$SMOKE2" core/result/mod.x; do
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

stdlib_cm_native_shu() {
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

if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== LANG-010: typeck + smoke ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  TC_OK=0
  for x in "$SMOKE1" "$SMOKE2"; do
    if ! "$SHUX_BIN" check -L . "$x" >/dev/null 2>&1; then
      echo "lang-result-generic gate FAIL: typeck $x" >&2
      "$SHUX_BIN" check -L . "$x" 2>&1 | tail -10 >&2 || true
      lang_result_generic_emit_report "fail" 0 0 0
      exit 1
    fi
    TC_OK=$((TC_OK + 1))
  done
  TYPECK_OK=1
  exe="/tmp/shux_lang010_$$"
  set +e
  run_ec=0
  for x in "$SMOKE1" "$SMOKE2"; do
    link_log=$("$SHUX_BIN" -L . "$x" -o "$exe" 2>&1)
    link_ec=$?
    if [ "$link_ec" -ne 0 ]; then
      if echo "$link_log" | grep -qE "library 'zstd' not found|shux_panic_"; then
        echo "lang-result-generic gate SKIP runnable link (typeck passed)" >&2
        SKIP=1
        break
      fi
      echo "lang-result-generic gate FAIL: link $x" >&2
      echo "$link_log" | tail -8 >&2 || true
      lang_result_generic_emit_report "fail" 0 "$TYPECK_OK" 0
      exit 1
    fi
    "$exe" >/dev/null 2>&1
    run_ec=$?
    rm -f "$exe"
    if [ "$run_ec" -ne 0 ]; then
      echo "lang-result-generic gate FAIL: run $x exit=$run_ec" >&2
      lang_result_generic_emit_report "fail" 0 "$TYPECK_OK" 0
      exit 1
    fi
    GOLDEN_OK=$((GOLDEN_OK + 1))
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
  echo "lang-result-generic gate SKIP smoke (no native shux-c)" >&2
fi

lang_result_generic_emit_report "ok" "$GOLDEN_OK" "$TYPECK_OK" "$SKIP"
echo "lang-result-generic gate OK"
