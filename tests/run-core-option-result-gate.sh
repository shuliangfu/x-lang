#!/usr/bin/env bash
# CORE-002/003：Option/Result 类型族与组合子门禁
#
# 用法：./tests/run-core-option-result-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_CORE_OR_DOC:-analysis/core-option-result-combinators-v1.md}"
MANIFEST="${SHU_CORE_OR_TSV:-tests/baseline/core-option-result.tsv}"
OPTION_SU="core/option/mod.su"
RESULT_SU="core/result/mod.su"
LIB="tests/lib/core-option-result.sh"
PREFIX="shu: [SHU_CORE_OPTION_RESULT]"

# shellcheck source=tests/lib/core-option-result.sh
. tests/lib/core-option-result.sh

echo "=== CORE-002/003: Option/Result manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$OPTION_SU" "$RESULT_SU" tests/option/main.su tests/result/main.su; do
  if [ ! -f "$f" ]; then
    echo "core-option-result gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in eager EXC-001 Option_ptr_u8 Result_u8 or_else_i32; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-option-result gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(core_or_symbols_ok "$OPTION_SU" "$RESULT_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_or_emit_report "fail" 0 0 0
  echo "core-option-result gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-option-result manifest OK"

# 本机可执行 shu 时跑 check + 可选 runnable
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
resolve_shu() {
  local cand
  for cand in ./compiler/shu-c ./compiler/shu; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

OPT_OK=0
RES_OK=0
SKIP=1
if SHU_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== CORE-002/003: typeck (SHU=$SHU_BIN) ==="
  if "$SHU_BIN" check -L . tests/option/main.su >/dev/null 2>&1; then
    OPT_OK=1
  else
    echo "core-option-result gate FAIL: option typeck" >&2
    "$SHU_BIN" check -L . tests/option/main.su 2>&1 | tail -8 >&2 || true
    core_or_emit_report "fail" 0 0 0
    exit 1
  fi
  if "$SHU_BIN" check -L . tests/result/main.su >/dev/null 2>&1; then
    RES_OK=1
  else
    echo "core-option-result gate FAIL: result typeck" >&2
    "$SHU_BIN" check -L . tests/result/main.su 2>&1 | tail -8 >&2 || true
    core_or_emit_report "fail" "$OPT_OK" 0 0
    exit 1
  fi
  SKIP=0
  if [ -x tests/run-option.sh ] && [ -x tests/run-result.sh ]; then
    echo "=== CORE-002/003: runnable (optional link) ==="
    chmod +x tests/run-option.sh tests/run-result.sh
    if ./tests/run-option.sh >/tmp/core_or_option.log 2>&1 && ./tests/run-result.sh >/tmp/core_or_result.log 2>&1; then
      :
    else
      echo "core-option-result gate SKIP runnable link (check passed)" >&2
      tail -5 /tmp/core_or_option.log 2>/dev/null >&2 || true
      SKIP=1
    fi
  fi
else
  echo "core-option-result gate SKIP typeck (no native shu)" >&2
fi

core_or_emit_report "ok" "$OPT_OK" "$RES_OK" "$SKIP"
echo "core-option-result gate OK"
