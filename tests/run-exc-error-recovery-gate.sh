#!/usr/bin/env bash
# EXC-006：错误恢复测试集 manifest + runnable 门禁
#
# 1) analysis/exc-error-recovery-v1.md + exc-error-recovery-cases.tsv
# 2) 符号/章节 manifest 校验
# 3) native shu：tests/lib/exc-error-recovery.sh 全量 runnable
#
# 用法：./tests/run-exc-error-recovery-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_EXC_ERROR_RECOVERY_DOC:-analysis/exc-error-recovery-v1.md}"
MATRIX="${SHU_EXC_ERROR_RECOVERY_TSV:-tests/baseline/exc-error-recovery-cases.tsv}"
RUNNER="tests/lib/exc-error-recovery.sh"
MIN_CASES=30

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

echo "=== EXC-006: error recovery manifest ==="
for f in "$DOC" "$MATRIX" "$RUNNER" tests/exc/recovery; do
  if [ ! -e "$f" ]; then
    echo "exc-error-recovery gate FAIL: missing $f" >&2
    exit 1
  fi
done

# RFC 必含 gate 关键词
for kw in runnable report R1-unwrap-or R6-suite; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "exc-error-recovery gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_cases) MIN_CASES="${c2# }" ;;
  esac
done < "$MATRIX"

MISS=0
FOUND=0
echo "=== EXC-006: matrix walk ==="
while IFS=$'\t' read -r case_id script policy want_ec category notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in
    \#*) continue ;;
    min_cases|min_items) continue ;;
    docs)
      section="${want_ec:-}"
      if [ -n "$section" ] && ! grep -qF "$section" "$DOC" 2>/dev/null; then
        echo "exc-error-recovery FAIL: doc missing section '$section' (${notes:-})" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case_*)
      FOUND=$((FOUND + 1))
      case "$policy" in
        run)
          src="tests/exc/${script}"
          if [ ! -f "$src" ]; then
            echo "exc-error-recovery FAIL: missing $src ($case_id)" >&2
            MISS=$((MISS + 1))
          fi
          ;;
        run_path)
          if [ ! -f "$script" ]; then
            echo "exc-error-recovery FAIL: missing $script ($case_id)" >&2
            MISS=$((MISS + 1))
          fi
          ;;
        hook)
          hook="tests/${script}"
          if [ ! -f "$hook" ]; then
            echo "exc-error-recovery FAIL: missing hook $hook ($case_id)" >&2
            MISS=$((MISS + 1))
          fi
          ;;
        *)
          echo "exc-error-recovery FAIL: bad policy $policy ($case_id)" >&2
          MISS=$((MISS + 1))
          ;;
      esac
      ;;
  esac
done < "$MATRIX"

if [ "$FOUND" -lt "$MIN_CASES" ]; then
  echo "exc-error-recovery gate FAIL: cases=${FOUND} < min_cases=${MIN_CASES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "exc-error-recovery gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "exc-error-recovery manifest OK (cases=${FOUND})"

chmod +x "$RUNNER" 2>/dev/null || true

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
  echo "exc-error-recovery gate SKIP bench (no native shu)" >&2
  echo "exc-error-recovery gate OK"
  exit 0
fi

echo "=== EXC-006: runnable report (SHU=$SHU_BIN) ==="
if SHU="$SHU_BIN" "$RUNNER"; then
  echo "exc-error-recovery gate OK"
else
  echo "exc-error-recovery gate FAIL: runner" >&2
  exit 1
fi
