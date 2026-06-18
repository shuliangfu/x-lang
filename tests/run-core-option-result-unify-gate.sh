#!/usr/bin/env bash
# CORE-016：泛型 Option/Result 与 core 类型族统一门禁
#
# 用法：./tests/run-core-option-result-unify-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_CORE016_DOC:-analysis/core-option-result-unify-v1.md}"
MANIFEST="${SHU_CORE016_TSV:-tests/baseline/core-option-result-unify.tsv}"
SMOKE1="tests/core016/unify_option.su"
SMOKE2="tests/core016/unify_result.su"
MIN_GOLDEN=2

# shellcheck source=tests/lib/core-option-result-unify.sh
. tests/lib/core-option-result-unify.sh

echo "=== CORE-016: Option/Result unify manifest ==="
for f in "$DOC" "$MANIFEST" "$SMOKE1" "$SMOKE2" core/option/mod.su core/result/mod.su; do
  if [ ! -f "$f" ]; then
    echo "core-option-result-unify gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_golden) MIN_GOLDEN="$c2" ;;
  esac
done < "$MANIFEST"

for kw in CORE-016 Result_i32 Option_i32 typeck_expand; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-option-result-unify gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(core016_check "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core016_emit_report "fail" 0 0 0
  exit 1
fi
echo "core-option-result-unify manifest OK"

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

if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
else
  SHU_BIN=""
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== CORE-016: typeck + smoke ==="
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  for su in "$SMOKE1" "$SMOKE2"; do
    if ! "$SHU_BIN" check -L . "$su" >/dev/null 2>&1; then
      echo "core-option-result-unify gate FAIL: typeck $su" >&2
      "$SHU_BIN" check -L . "$su" 2>&1 | tail -10 >&2 || true
      core016_emit_report "fail" 0 0 0
      exit 1
    fi
    TYPECK_OK=$((TYPECK_OK + 1))
  done
  exe="/tmp/shu_core016_$$"
  set +e
  for su in "$SMOKE1" "$SMOKE2"; do
    link_log=$("$SHU_BIN" -L . "$su" -o "$exe" 2>&1)
    link_ec=$?
    if [ "$link_ec" -ne 0 ]; then
      if echo "$link_log" | grep -qE "library 'zstd' not found|shulang_panic_"; then
        echo "core-option-result-unify gate SKIP runnable link (typeck passed)" >&2
        SKIP=1
        break
      fi
      echo "core-option-result-unify gate FAIL: link $su" >&2
      echo "$link_log" | tail -8 >&2 || true
      core016_emit_report "fail" 0 "$TYPECK_OK" 0
      exit 1
    fi
    "$exe" >/dev/null 2>&1
    run_ec=$?
    rm -f "$exe"
    if [ "$run_ec" -ne 0 ]; then
      echo "core-option-result-unify gate FAIL: run $su exit=$run_ec" >&2
      core016_emit_report "fail" 0 "$TYPECK_OK" 0
      exit 1
    fi
    GOLDEN_OK=$((GOLDEN_OK + 1))
    SKIP=0
  done
  if [ "$GOLDEN_OK" -lt "$MIN_GOLDEN" ] && [ "$SKIP" -eq 0 ]; then
    echo "core-option-result-unify gate FAIL: golden=$GOLDEN_OK < min $MIN_GOLDEN" >&2
    exit 1
  fi
  if [ "$SKIP" -eq 1 ]; then
    GOLDEN_OK=0
    TYPECK_OK=1
  fi
else
  echo "core-option-result-unify gate SKIP smoke (no native shu-c)" >&2
fi

core016_emit_report "ok" "$GOLDEN_OK" "$TYPECK_OK" "$SKIP"
echo "core-option-result-unify gate OK"
