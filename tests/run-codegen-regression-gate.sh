#!/usr/bin/env bash
# COMP-003：codegen 稳定性回归门禁
#
# 读取 tests/baseline/codegen-regression-matrix.tsv：
#   policy=run  — 编译运行 .x
#   policy=hook — 调用 tests/run-*.sh
#
# 用法：./tests/run-codegen-regression-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHUX_CODEGEN_REGRESSION_TSV:-tests/baseline/codegen-regression-matrix.tsv}"

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

arch_ok() {
  local want="$1"
  case "$want" in
    any) return 0 ;;
    x86_64) ci_is_x86_64_host ;;
    arm64) ci_is_arm64_host ;;
    !docker) ! ci_is_docker ;;
    *) return 0 ;;
  esac
}

echo "=== COMP-003: codegen regression manifest ==="
for f in \
  analysis/comp-codegen-regression-v1.md \
  "$MATRIX"; do
  if [ ! -f "$f" ]; then
    echo "codegen-regression gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "codegen-regression manifest OK (host=$(ci_host_summary))"

make -C compiler -q 2>/dev/null || make -C compiler

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ]; then
  echo "codegen-regression gate SKIP bench (no native shux)" >&2
  exit 0
fi

run_x_case() {
  local src="$1"
  local want_ec="$2"
  local out="/tmp/shux_codegen_${src##*/}"
  out="${out%.x}"
  if [ ! -f "$src" ]; then
    echo "codegen-regression FAIL: missing $src" >&2
    return 1
  fi
  if ! "$SHUX_BIN" -L . "$src" -o "$out" >/tmp/shux_codegen_compile.log 2>&1; then
    cat /tmp/shux_codegen_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want_ec" ]; then
    echo "codegen-regression FAIL $src: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

FAILS=0
echo "=== COMP-003: codegen smoke (SHUX=$SHUX_BIN) ==="

while IFS=$'\t' read -r case_id src arch policy want_ec notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in \#*) continue ;; esac
  if ! arch_ok "$arch"; then
    echo "codegen-regression SKIP $case_id ($arch on $(ci_host_summary))"
    continue
  fi
  echo "── $case_id: $notes ──"
  case "$policy" in
    run)
      if run_x_case "$src" "${want_ec:-0}"; then
        echo "codegen-regression OK $case_id"
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    hook)
      # asm hook 优先 shux_asm
      hook_shu="$SHUX_BIN"
      if [ "$src" = "run-asm-73-gate.sh" ] && [ -x ./compiler/shux_asm ] && native_shu ./compiler/shux_asm; then
        hook_shu=./compiler/shux_asm
      fi
      hook="tests/${src}"
      chmod +x "$hook" 2>/dev/null || true
      if SHUX="$hook_shu" "$hook"; then
        echo "codegen-regression OK $case_id ($src)"
      else
        echo "codegen-regression FAIL $case_id ($src)" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    *)
      echo "codegen-regression WARN: unknown policy $policy" >&2
      ;;
  esac
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  echo "codegen-regression gate FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "codegen-regression gate OK"
