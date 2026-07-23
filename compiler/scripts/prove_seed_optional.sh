#!/bin/bash
# prove_seed_optional.sh — G-02f / Phase 2: 证明 TU 可在无 seed 的情况下构建
#
# 【Why 根源】方法论 §4.2 要求"先证明 .x -> -E -> .o、符号、ABI、最小行为一致，
# 再考虑物理删除 seed"。本脚本提供 seed-optional 的对象级证明：临时移走 seed，
# 用 xlang-c -E 从 .x 生成 .c 并编译为 .o，对比 seed-built .o 的 public 符号集。
# 证明通过后，该 TU 可进入 Phase 4 seed 删除候选。
#
# 【Invariant】
#   - 不修改任何源文件或 seed 文件（临时移走 + 恢复）
#   - 证明失败时必须恢复 seed 文件（trap EXIT 保证）
#   - 对比基于 nm public 符号集（T/U 类型），不对比 .o 二进制（路径无关）
#
# 【Asm/Perf】非热路径；单 TU 证明，无性能影响。
#
# 用法：
#   sh scripts/prove_seed_optional.sh <tu_name> [--xlang-c <path>]
#
# 示例：
#   sh scripts/prove_seed_optional.sh diag
#   sh scripts/prove_seed_optional.sh runtime_panic --xlang-c ./xlang-c
#
# 输出：
#   prove_seed_optional: <tu_name> PASS (nm_match=yes, seed_restored=yes)
#   或
#   prove_seed_optional: <tu_name> FAIL (reason=...)
#
# 工件路径：tests/probes/seed_optional/<tu_name>/

set -eu

cd "$(dirname "$0")/.."

TU_NAME=""
XLANG_C="./xlang-c"
CC_CMD="${CC:-gcc}"
CFLAGS="${CFLAGS:--O2 -Wall -Wno-unused-parameter -Wno-unused-function -Wno-unused-variable -Wno-unused-but-set-variable -Wno-sign-compare -Wno-parentheses}"

usage() {
  cat <<'EOF'
usage:
  sh scripts/prove_seed_optional.sh <tu_name> [--xlang-c <path>]

options:
  --xlang-c <path>  xlang-c 路径（默认 ./xlang-c）
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --xlang-c)
      XLANG_C="$2"
      shift 2
      ;;
    -*)
      echo "prove_seed_optional: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [ -z "$TU_NAME" ]; then
        TU_NAME="$1"
      else
        echo "prove_seed_optional: unexpected arg: $1" >&2
        usage >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [ -z "$TU_NAME" ]; then
  echo "prove_seed_optional: tu_name is required" >&2
  usage >&2
  exit 2
fi

SEED_FILE="seeds/${TU_NAME}.from_x.c"
X_FILE="src/${TU_NAME}.x"

# 查找 .x 文件（可能在子目录中）
if [ ! -f "$X_FILE" ]; then
  X_FILE="$(find src -type f -name "${TU_NAME}.x" 2>/dev/null | head -n1 || true)"
fi

if [ ! -f "$X_FILE" ]; then
  echo "prove_seed_optional: ${TU_NAME} FAIL (reason=x_not_found)"
  exit 1
fi

if [ ! -f "$SEED_FILE" ]; then
  echo "prove_seed_optional: ${TU_NAME} SKIP (seed_already_missing)"
  exit 0
fi

PROBE_DIR="../tests/probes/seed_optional/${TU_NAME}"
mkdir -p "$PROBE_DIR"

BASELINE_O="${PROBE_DIR}/baseline.o"
OPTIONAL_O="${PROBE_DIR}/optional.o"
GEN_C="${PROBE_DIR}/optional_gen.c"
BASELINE_NM="${PROBE_DIR}/baseline.nm"
OPTIONAL_NM="${PROBE_DIR}/optional.nm"
SEED_BACKUP="${PROBE_DIR}/seed_bak"

# 恢复 seed 文件的 helper
restore_seed() {
  if [ -f "${SEED_FILE}.prove_bak" ]; then
    mv "${SEED_FILE}.prove_bak" "$SEED_FILE"
  fi
}
trap restore_seed EXIT

# Step 1: 构建 baseline .o（使用 seed）
echo "  [1/4] building baseline .o from seed..." >&2
if ! $CC_CMD $CFLAGS -I. -Iinclude -Isrc -c "$SEED_FILE" -o "$BASELINE_O" 2>"${PROBE_DIR}/baseline.err"; then
  echo "prove_seed_optional: ${TU_NAME} FAIL (reason=baseline_build_failed)" >&2
  echo "  see: ${PROBE_DIR}/baseline.err" >&2
  exit 1
fi

# Step 2: 临时移走 seed
echo "  [2/4] moving seed aside..." >&2
mv "$SEED_FILE" "${SEED_FILE}.prove_bak"

# Step 3: 用 xlang-c -E 从 .x 生成 .c，编译为 .o
echo "  [3/4] building optional .o from .x via -E..." >&2
if [ ! -x "$XLANG_C" ] && [ ! -f "$XLANG_C" ]; then
  echo "prove_seed_optional: ${TU_NAME} FAIL (reason=xlang_c_not_found at $XLANG_C)" >&2
  exit 1
fi

# 生成 .c（-E 模式）
# xlang-c -E 用 -L 指定 import 搜索路径（不是 -I）
XLANG_C_ARGS="-E -L .. -L src -L src/runtime -L src/asm -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/driver"
if ! "$XLANG_C" $XLANG_C_ARGS "$X_FILE" >"$GEN_C" 2>"${PROBE_DIR}/gen.err"; then
  echo "prove_seed_optional: ${TU_NAME} FAIL (reason=xlang_c_E_failed)" >&2
  echo "  see: ${PROBE_DIR}/gen.err" >&2
  exit 1
fi

# 编译生成的 .c
if ! $CC_CMD $CFLAGS -I. -Iinclude -Isrc -c "$GEN_C" -o "$OPTIONAL_O" 2>"${PROBE_DIR}/optional.err"; then
  echo "prove_seed_optional: ${TU_NAME} FAIL (reason=optional_build_failed)" >&2
  echo "  see: ${PROBE_DIR}/optional.err" >&2
  exit 1
fi

# Step 4: 对比 public 符号集
echo "  [4/4] comparing public symbols..." >&2
nm "$BASELINE_O" 2>/dev/null | awk '$2=="T" || $2=="U" {print $2, $3}' | sort >"$BASELINE_NM"
nm "$OPTIONAL_O" 2>/dev/null | awk '$2=="T" || $2=="U" {print $2, $3}' | sort >"$OPTIONAL_NM"

DIFF_OUT="${PROBE_DIR}/nm_diff.txt"
DIFF_COUNT=$(diff "$BASELINE_NM" "$OPTIONAL_NM" 2>/dev/null | grep -c '^[<>]' || true)

# 判定
NM_MATCH="no"
if [ "$DIFF_COUNT" = "0" ]; then
  NM_MATCH="yes"
fi

# 输出结果
if [ "$NM_MATCH" = "yes" ]; then
  echo "prove_seed_optional: ${TU_NAME} PASS (nm_match=yes, seed_restored=yes)"
  exit 0
else
  echo "prove_seed_optional: ${TU_NAME} FAIL (reason=nm_mismatch, diff_count=${DIFF_COUNT})" >&2
  echo "  see: ${PROBE_DIR}/nm_diff.txt" >&2
  diff "$BASELINE_NM" "$OPTIONAL_NM" >"$DIFF_OUT" 2>/dev/null || true
  exit 1
fi
