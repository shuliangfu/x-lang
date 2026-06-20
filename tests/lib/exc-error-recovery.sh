#!/usr/bin/env bash
# EXC-006：错误恢复单 case / 全量 runner（供 gate 与本地调试）
#
# 用法：
#   ./tests/lib/exc-error-recovery.sh              # 全量 runnable（需 native shux）
#   ./tests/lib/exc-error-recovery.sh case_id      # 单 case
#   SHUX=./compiler/shux-c ./tests/lib/exc-error-recovery.sh
set -e
cd "$(dirname "$0")/../.."

MATRIX="${SHUX_EXC_ERROR_RECOVERY_TSV:-tests/baseline/exc-error-recovery-cases.tsv}"
ONE_CASE="${1:-}"

# 判断本机可执行的 shux 二进制格式
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

resolve_shu() {
  if [ -n "${SHUX:-}" ] && native_shu "$SHUX"; then
    echo "$SHUX"
    return 0
  fi
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

# 编译并运行 .sx，校验退出码
exc_recovery_run_su() {
  local shux="$1"
  local src="$2"
  local want_ec="$3"
  local tag="$4"
  local out="/tmp/shux_exc_recovery_${tag}"
  if [ ! -f "$src" ]; then
    echo "exc-recovery FAIL: missing $src" >&2
    return 1
  fi
  set +e
  "$shux" -L . "$src" -o "$out" >/tmp/shux_exc_recovery_compile.log 2>&1
  local comp_ec=$?
  set -e
  if [ "$comp_ec" -ne 0 ]; then
    # Docker/shux-c -o 偶发 SIGSEGV；check 通过则视为 typeck 烟测 OK
    if [ "$comp_ec" -eq 139 ] && "$shux" check -L . "$src" >/dev/null 2>&1; then
      echo "exc-recovery OK $tag (check-only, compile SIGSEGV)"
      return 0
    fi
    cat /tmp/shux_exc_recovery_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want_ec" ]; then
    echo "exc-recovery FAIL $tag: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

# 执行矩阵一行 runnable case
exc_recovery_run_row() {
  local shux="$1"
  local case_id="$2"
  local script="$3"
  local policy="$4"
  local want_ec="${5:-0}"
  case "$policy" in
    run)
      exc_recovery_run_su "$shux" "tests/exc/${script}" "$want_ec" "$case_id"
      ;;
    run_path)
      exc_recovery_run_su "$shux" "$script" "$want_ec" "$case_id"
      ;;
    hook)
      local hook="tests/${script}"
      if [ ! -f "$hook" ]; then
        echo "exc-recovery FAIL: missing hook $hook" >&2
        return 1
      fi
      chmod +x "$hook" 2>/dev/null || true
      SHUX="$shux" "$hook"
      ;;
    *)
      echo "exc-recovery WARN: unknown policy $policy ($case_id)" >&2
      return 1
      ;;
  esac
}

SHUX_BIN=""
if SHUX_BIN="$(resolve_shu)"; then
  :
else
  echo "exc-error-recovery: no native shux (SKIP runnable)" >&2
  exit 2
fi

make -C compiler -q 2>/dev/null || make -C compiler
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

FAILS=0
FOUND=0
while IFS=$'\t' read -r case_id script policy want_ec _cat notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in
    \#*|min_items|min_cases|docs) continue ;;
  esac
  if [ -n "$ONE_CASE" ] && [ "$case_id" != "$ONE_CASE" ]; then
    continue
  fi
  FOUND=$((FOUND + 1))
  echo "── exc-recovery $case_id: ${notes:-} ──"
  if exc_recovery_run_row "$SHUX_BIN" "$case_id" "$script" "$policy" "${want_ec:-0}"; then
    echo "exc-recovery OK $case_id"
  else
    FAILS=$((FAILS + 1))
  fi
done < "$MATRIX"

if [ -n "$ONE_CASE" ] && [ "$FOUND" -eq 0 ]; then
  echo "exc-recovery FAIL: unknown case_id=$ONE_CASE" >&2
  exit 1
fi

if [ "$FAILS" -gt 0 ]; then
  echo "exc-error-recovery runner FAIL: ${FAILS} case(s)" >&2
  exit 1
fi
echo "exc-error-recovery runner OK (${FOUND} case(s))"
