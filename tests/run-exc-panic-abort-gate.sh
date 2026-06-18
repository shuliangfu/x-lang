#!/usr/bin/env bash
# EXC-002：panic/abort 与可恢复错误边界门禁
#
# 读取 tests/baseline/exc-panic-abort.tsv：
#   policy=run  — 编译运行 .su，须 expected_exit
#   policy=hook — 调用 tests/run-*.sh
#
# 用法：./tests/run-exc-panic-abort-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHU_EXC_PANIC_ABORT_TSV:-tests/baseline/exc-panic-abort.tsv}"

native_shu() {
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

echo "=== EXC-002: panic/abort boundary manifest ==="
for f in \
  analysis/exc-panic-abort-v1-rfc.md \
  analysis/exc-result-error-v1-rfc.md \
  "$MATRIX" \
  tests/exc/recoverable_result.su \
  tests/exc/layer_c_recoverable.su; do
  if [ ! -f "$f" ]; then
    echo "exc-panic-abort gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "exc-panic-abort manifest OK"

make -C compiler -q 2>/dev/null || make -C compiler

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ]; then
  echo "exc-panic-abort gate SKIP bench (no native shu)" >&2
  exit 0
fi

run_su_case() {
  local script="$1"
  local want_ec="$2"
  local src="tests/exc/${script}"
  local out="/tmp/shu_exc_${script%.su}"
  if [ ! -f "$src" ]; then
    echo "exc FAIL: missing $src" >&2
    return 1
  fi
  if ! "$SHU_BIN" -L . "$src" -o "$out" >/tmp/shu_exc_compile.log 2>&1; then
    cat /tmp/shu_exc_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want_ec" ]; then
    echo "exc FAIL $script: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

FAILS=0
echo "=== EXC-002: boundary smoke (SHU=$SHU_BIN) ==="

while IFS=$'\t' read -r case_id script policy want_ec notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in
    \#*) continue ;;
  esac
  echo "── $case_id: $notes ──"
  case "$policy" in
    run)
      if run_su_case "$script" "${want_ec:-0}"; then
        echo "exc OK $case_id"
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    hook)
      hook="tests/${script}"
      if [ ! -x "$hook" ]; then
        chmod +x "$hook" 2>/dev/null || true
      fi
      if SHU="$SHU_BIN" "$hook"; then
        echo "exc OK $case_id ($script)"
      else
        echo "exc FAIL $case_id ($script)" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    *)
      echo "exc WARN $case_id: unknown policy $policy" >&2
      ;;
  esac
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  echo "exc-panic-abort gate FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "exc-panic-abort gate OK"
