#!/usr/bin/env bash
# STD-015：std.set Set_u64 / Set_str 扩展门禁
#
# 用法：./tests/run-std-set-extend-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_SET_EXTEND_DOC:-analysis/std-set-extend-v1.md}"
MANIFEST="${SHU_STD_SET_EXTEND_TSV:-tests/baseline/std-set-extend.tsv}"
SET_SU="std/set/mod.su"
LIB="tests/lib/std-set-extend.sh"
SMOKE="tests/set/extend.su"

# shellcheck source=tests/lib/std-set-extend.sh
. tests/lib/std-set-extend.sh

echo "=== STD-015: set extend manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$SET_SU" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "std-set-extend gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in Set_u64 Set_str hash_bytes set_str_key_cap; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-set-extend gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_set_extend_symbols_ok "$SET_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_set_extend_emit_report "fail" 0 0 0
  echo "std-set-extend gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-set-extend manifest OK"

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

CHECK_OK=0
RUN_OK=0
SKIP=1
if SHU_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-015: typeck (SHU=$SHU_BIN) ==="
  if "$SHU_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-set-extend gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    std_set_extend_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
  # shellcheck source=tests/lib/bootstrap-link-shu.sh
  . "$(dirname "$0")/lib/bootstrap-link-shu.sh"
  if $RUN_SHU -L . "$SMOKE" -o /tmp/shu_std_set_extend 2>/tmp/shu_std_set_extend_build.log; then
    exitcode=0
    /tmp/shu_std_set_extend >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
    else
      echo "std-set-extend gate FAIL: runnable exit=$exitcode" >&2
      std_set_extend_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-set-extend gate SKIP runnable link (check passed)" >&2
    tail -5 /tmp/shu_std_set_extend_build.log 2>/dev/null >&2 || true
    SKIP=1
  fi
else
  echo "std-set-extend gate SKIP typeck (no native shu)" >&2
fi

std_set_extend_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-set-extend gate OK"
