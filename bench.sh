#!/usr/bin/env bash
# bench.sh — xlang 性能基准测试统一入口
#
# 用法：
#   ./bench.sh                  # 默认：P0+P1 矩阵 + 工具链矩阵（快速看数字，~2 分钟）
#   ./bench.sh --quick          # 极速：仅基础 4 case（r01/m03/r10/a01），~10 秒
#   ./bench.sh --all            # 全量：所有 perf 脚本 + 专项 gate，~10-30 分钟
#   ./bench.sh --p0             # 仅 P0+P1 矩阵（11 case × 3 语言）
#   ./bench.sh --toolchain      # 仅工具链指标（M05/B03/B05/BT02-05/L02-03）
#   ./bench.sh --gate           # 跑所有 perf gate 门禁（带断言）
#   ./bench.sh --dimension R    # 按维度过滤（R/M/B/BT/A/CC/I/S/L/E）
#   ./bench.sh --help           # 显示帮助
#
# 报告输出：
#   /tmp/xlang_p0_matrix_report.md          — P0+P1 运行时 median
#   /tmp/xlang_toolchain_report.md          — 工具链指标（RSS/体积/编译时间）
#   stdout — 实时进度 + 最终汇总表
set -u
cd "$(dirname "$0")"

# ── 颜色输出 ──
if [ -t 1 ]; then
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
  C_GREEN='\033[32m'
  C_YELLOW='\033[33m'
  C_RED='\033[31m'
  C_BLUE='\033[34m'
  C_DIM='\033[2m'
else
  C_RESET=''; C_BOLD=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_BLUE=''; C_DIM=''
fi

log_header() {
  printf '\n%s========== %s ==========%s\n' "$C_BOLD$C_BLUE" "$1" "$C_RESET"
}
log_step() {
  printf '%s  → %s%s\n' "$C_DIM" "$1" "$C_RESET"
}
log_ok() {
  printf '%s  ✓ %s%s\n' "$C_GREEN" "$1" "$C_RESET"
}
log_skip() {
  printf '%s  ⊘ %s (SKIP)%s\n' "$C_YELLOW" "$1" "$C_RESET"
}
log_fail() {
  printf '%s  ✗ %s (FAIL)%s\n' "$C_RED" "$1" "$C_RESET"
}

# ── 参数解析 ──
MODE="default"
DIMENSION_FILTER=""
for arg in "$@"; do
  case "$arg" in
    --quick)     MODE="quick" ;;
    --all)       MODE="all" ;;
    --p0)        MODE="p0" ;;
    --toolchain) MODE="toolchain" ;;
    --gate)      MODE="gate" ;;
    --help|-h)   MODE="help" ;;
    --dimension) MODE="dimension" ;;
    R|M|B|BT|A|CC|I|S|L|E)
      if [ "$MODE" = "dimension" ]; then
        DIMENSION_FILTER="$arg"
      fi
      ;;
    *)
      if [ "$MODE" = "dimension" ] && [ -z "$DIMENSION_FILTER" ]; then
        DIMENSION_FILTER="$arg"
      fi
      ;;
  esac
done

if [ "$MODE" = "help" ]; then
  cat << 'EOF'
xlang 性能基准测试统一入口

用法:
  ./bench.sh                  默认：P0+P1 矩阵 + 工具链矩阵（快速看数字）
  ./bench.sh --quick          极速：仅基础 4 case（r01/m03/r10/a01）
  ./bench.sh --all            全量：所有 perf 脚本 + 专项 gate
  ./bench.sh --p0             仅 P0+P1 矩阵（11 case × 3 语言）
  ./bench.sh --toolchain      仅工具链指标（M05/B03/B05/BT02-05/L02-03）
  ./bench.sh --gate           跑所有 perf gate 门禁（带断言）
  ./bench.sh --dimension R    按维度过滤（R/M/B/BT/A/CC/I/S/L/E）

维度编号:
  R  运行时计算（R01-R10）       P0
  M  内存 & 分配（M01-M05）      P0
  B  二进制体积（B01-B05）       P0
  BT 编译时间（BT01-BT05）       P0
  S  安全开销（S01-S05）         P1
  A  ABI & 调用（A01-A05）       P1
  CC 并发（CC01-CC05）           P1
  I  I/O & 异步（I01-I08）       P1
  L  语言实现级（L01-L03）       P2
  E  嵌入式（E01-E04）           P2

报告文件:
  /tmp/xlang_p0_matrix_report.md       P0+P1 运行时 median
  /tmp/xlang_toolchain_report.md       工具链指标（RSS/体积/编译时间）

环境变量:
  XLANG_PERF_MIN_RUNS=N        每个 case 采样次数（默认 3，--all 时 10）
  XLANG_PERF_WARMUP=N          预热次数（默认 1）
  XLANG_PERF_OUTLIER_3SIGMA=1  3σ 离群值剔除（默认开）
  XLANG_PERF_FAIL_ON_C_O2=1    硬门禁：xlang 必须 ≤ C -O2（默认关）

退出码:
  0  全部通过
  1  有失败（仅 --gate 模式有意义；默认模式只看数字不门禁）
EOF
  exit 0
fi

# ── 前置检查 ──
log_header "前置环境检查"
if ! command -v cc >/dev/null 2>&1; then
  log_fail "cc (C 编译器) 未找到"
  exit 1
fi
log_ok "cc: $(cc --version 2>&1 | head -1)"

if command -v zig >/dev/null 2>&1; then
  log_ok "zig: $(zig version 2>&1)"
else
  log_skip "zig 未安装（Zig 对照数据将缺失）"
fi

if [ -x ./compiler/xlang-c ]; then
  log_ok "xlang-c: ./compiler/xlang-c"
elif [ -x ./compiler/xlang ]; then
  log_ok "xlang: ./compiler/xlang"
else
  log_skip "xlang 编译器未构建（.x 数据将缺失，C/Zig 对照仍有效）"
fi

# 检查 perf-env.sh
if [ ! -f tests/lib/perf-env.sh ]; then
  log_fail "tests/lib/perf-env.sh 缺失"
  exit 1
fi
log_ok "perf-env.sh 就绪"

# ── 收集结果 ──
declare -a PASSED=()
declare -a FAILED=()
declare -a SKIPPED=()
TOTAL_START=$(date +%s)

run_script() {
  local label="$1"
  local script="$2"
  local args="${3:-}"
  if [ ! -f "$script" ]; then
    SKIPPED+=("$label (脚本不存在: $script)")
    log_skip "$label"
    return
  fi
  log_step "运行 $label ..."
  local t_start t_end rc
  t_start=$(date +%s)
  if [ -n "$args" ]; then
    bash "$script" $args 2>&1 | tail -5
  else
    bash "$script" 2>&1 | tail -5
  fi
  rc=${PIPESTATUS[0]}
  t_end=$(date +%s)
  local elapsed=$((t_end - t_start))
  if [ "$rc" = "0" ]; then
    PASSED+=("$label (${elapsed}s)")
    log_ok "$label (${elapsed}s)"
  else
    FAILED+=("$label (${elapsed}s, rc=$rc)")
    log_fail "$label (${elapsed}s, rc=$rc)"
  fi
}

# ── 默认模式：P0+P1 矩阵 + 工具链矩阵 ──
run_default() {
  log_header "默认模式：P0+P1 矩阵 + 工具链矩阵"

  log_step "P0+P1 运行时矩阵（11 case × 3 语言）"
  bash tests/run-perf-p0-matrix.sh 2>&1 | tail -20
  if [ -f /tmp/xlang_p0_matrix_report.md ]; then
    log_ok "P0+P1 报告: /tmp/xlang_p0_matrix_report.md"
  else
    log_fail "P0+P1 报告未生成"
  fi

  log_step "工具链指标（M05/B03/B05/BT02-05/L02-03）"
  bash tests/run-perf-toolchain-matrix.sh 2>&1 | tail -20
  if [ -f /tmp/xlang_toolchain_report.md ]; then
    log_ok "工具链报告: /tmp/xlang_toolchain_report.md"
  else
    log_fail "工具链报告未生成"
  fi
}

# ── 极速模式：仅基础 4 case ──
run_quick() {
  log_header "极速模式：基础 4 case"
  run_script "baseline (r01/m03/r10/a01)" tests/run-perf-baseline.sh "--bench"
}

# ── P0 模式 ──
run_p0() {
  log_header "P0+P1 矩阵模式"
  bash tests/run-perf-p0-matrix.sh 2>&1
  log_ok "报告: /tmp/xlang_p0_matrix_report.md"
}

# ── 工具链模式 ──
run_toolchain() {
  log_header "工具链指标模式"
  bash tests/run-perf-toolchain-matrix.sh 2>&1
  log_ok "报告: /tmp/xlang_toolchain_report.md"
}

# ── 全量模式：所有 perf 脚本 ──
run_all() {
  log_header "全量模式：所有 perf 脚本 + 专项 gate"

  # 1. P0+P1 矩阵
  run_script "P0+P1 矩阵" tests/run-perf-p0-matrix.sh

  # 2. 工具链矩阵
  run_script "工具链矩阵" tests/run-perf-toolchain-matrix.sh

  # 3. 基础线
  run_script "baseline 4 case" tests/run-perf-baseline.sh "--bench"

  # 4. R 系列
  run_script "R03 dod-soa" tests/run-perf-dod-soa.sh
  run_script "R04 simd-dot" tests/run-perf-simd-dot.sh
  run_script "R04 simd-shuffle-select" tests/run-perf-simd-shuffle-select.sh
  run_script "R04 simd-xlangffle-select" tests/run-perf-simd-xlangffle-select.sh
  run_script "R08 string-arena" tests/run-perf-string-arena.sh
  run_script "R08 regex-match" tests/run-perf-regex-match.sh

  # 5. M 系列
  run_script "M02/M03 alloc-hotspot" tests/run-perf-alloc-hotspot.sh
  run_script "M04 cache-miss" tests/run-perf-cache-miss-gate.sh

  # 6. B 系列
  run_script "B02 wpo-dce-text" tests/run-perf-wpo-dce-text.sh
  run_script "B02 wpo-dce-compiler-self-text" tests/run-perf-wpo-dce-compiler-self-text.sh
  run_script "B02 wpo-dce-xlang-asm-text" tests/run-perf-wpo-dce-xlang-asm-text.sh

  # 7. BT 系列
  run_script "BT04 compile-dogfood" tests/run-perf-compile-dogfood.sh

  # 8. A 系列
  run_script "A04 wpo-s2" tests/run-perf-wpo-s2.sh
  run_script "A05 syscall-batch" tests/run-perf-syscall-batch.sh

  # 9. I 系列
  run_script "I01/I05 io" tests/run-perf-io.sh
  run_script "I06 io-ring-ab" tests/run-perf-io-ring-ab.sh
  run_script "I03/I04 net" tests/run-perf-net.sh
  run_script "I07 net-zc" tests/run-perf-net-zc.sh
  run_script "I06 async" tests/run-perf-async.sh
  run_script "I08 http" tests/run-perf-http.sh
  run_script "I06 iocp" tests/run-perf-iocp.sh

  # 10. E 系列
  run_script "E01 coldstart" tests/run-perf-coldstart.sh

  # 11. L 系列
  run_script "L01 phase3-std-hotpath" tests/run-perf-phase3-gate.sh
  run_script "L01 sqlite-is-available" tests/run-perf-sqlite-gate.sh
}

# ── Gate 模式：所有 perf gate 门禁 ──
run_gate() {
  log_header "Gate 模式：所有 perf gate 门禁"
  local gate_scripts=(
    tests/run-perf-cache-miss-gate.sh
    tests/run-perf-alloc-hotspot-gate.sh
    tests/run-perf-coldstart-gate.sh
    tests/run-perf-syscall-batch-gate.sh
    tests/run-perf-net-zc-gate.sh
    tests/run-perf-net-zig-gate.sh
    tests/run-perf-io-zig-gate.sh
    tests/run-perf-flamegraph-gate.sh
    tests/run-perf-compile-dogfood-gate.sh
    tests/run-perf-phase3-gate.sh
    tests/run-perf-sqlite-gate.sh
    tests/run-perf-p1-gate.sh
    tests/run-perf-weekly-gate.sh
    tests/run-perf-zig-strategy-dashboard-gate.sh
  )
  for script in "${gate_scripts[@]}"; do
    local label
    label=$(basename "$script" .sh)
    run_script "$label" "$script"
  done
}

# ── 维度过滤模式 ──
run_dimension() {
  local dim="$DIMENSION_FILTER"
  log_header "维度过滤模式：$dim 系列"
  case "$dim" in
    R)
      run_script "R01 baseline loop_i32" tests/run-perf-baseline.sh "--bench"
      run_script "R03 dod-soa" tests/run-perf-dod-soa.sh
      run_script "R04 simd-dot" tests/run-perf-simd-dot.sh
      run_script "R04 simd-shuffle" tests/run-perf-simd-shuffle-select.sh
      run_script "R04 simd-xlangffle" tests/run-perf-simd-xlangffle-select.sh
      run_script "R08 string-arena" tests/run-perf-string-arena.sh
      run_script "R08 regex-match" tests/run-perf-regex-match.sh
      echo ""
      echo "R02/R05/R06/R07/R09 在 P0 矩阵中，运行: ./bench.sh --p0"
      ;;
    M)
      run_script "M02/M03 alloc-hotspot" tests/run-perf-alloc-hotspot.sh
      run_script "M04 cache-miss-gate" tests/run-perf-cache-miss-gate.sh
      echo ""
      echo "M01/M05 在工具链矩阵中，运行: ./bench.sh --toolchain"
      ;;
    B)
      run_script "B02 wpo-dce-text" tests/run-perf-wpo-dce-text.sh
      run_script "B02 wpo-dce-compiler-self" tests/run-perf-wpo-dce-compiler-self-text.sh
      run_script "B02 wpo-dce-xlang-asm" tests/run-perf-wpo-dce-xlang-asm-text.sh
      echo ""
      echo "B01/B03/B05 在工具链矩阵中，运行: ./bench.sh --toolchain"
      ;;
    BT)
      run_script "BT04 compile-dogfood" tests/run-perf-compile-dogfood.sh
      echo ""
      echo "BT01/BT02/BT03/BT05 在工具链矩阵中，运行: ./bench.sh --toolchain"
      ;;
    A)
      run_script "A01 baseline call_boundary" tests/run-perf-baseline.sh "--bench"
      run_script "A04 wpo-s2" tests/run-perf-wpo-s2.sh
      run_script "A05 syscall-batch" tests/run-perf-syscall-batch.sh
      echo ""
      echo "A02/A03 在 P0 矩阵中，运行: ./bench.sh --p0"
      ;;
    CC)
      echo "CC01-CC05 在 P0 矩阵中，运行: ./bench.sh --p0"
      ;;
    I)
      run_script "I01/I05 io" tests/run-perf-io.sh
      run_script "I06 io-ring-ab" tests/run-perf-io-ring-ab.sh
      run_script "I03/I04 net" tests/run-perf-net.sh
      run_script "I07 net-zc" tests/run-perf-net-zc.sh
      run_script "I06 async" tests/run-perf-async.sh
      run_script "I08 http" tests/run-perf-http.sh
      run_script "I06 iocp" tests/run-perf-iocp.sh
      echo ""
      echo "I02 在 P0 矩阵中，运行: ./bench.sh --p0"
      ;;
    S)
      echo "S01-S05 在 P0 矩阵中，运行: ./bench.sh --p0"
      ;;
    L)
      run_script "L01 phase3-std-hotpath" tests/run-perf-phase3-gate.sh
      run_script "L01 sqlite-is-available" tests/run-perf-sqlite-gate.sh
      echo ""
      echo "L02/L03 在工具链矩阵中，运行: ./bench.sh --toolchain"
      ;;
    E)
      run_script "E01 coldstart" tests/run-perf-coldstart.sh
      echo ""
      echo "E02/E04 无 libc gate 不在 perf 范畴"
      ;;
    *)
      echo "未知维度: $dim"
      echo "可用维度: R M B BT A CC I S L E"
      exit 1
      ;;
  esac
}

# ── 执行 ──
case "$MODE" in
  quick)     run_quick ;;
  p0)        run_p0 ;;
  toolchain) run_toolchain ;;
  all)       export XLANG_PERF_MIN_RUNS="${XLANG_PERF_MIN_RUNS:-10}"; run_all ;;
  gate)      run_gate ;;
  dimension) run_dimension ;;
  default)   run_default ;;
esac

# ── 汇总 ──
TOTAL_END=$(date +%s)
TOTAL_ELAPSED=$((TOTAL_END - TOTAL_START))

log_header "汇总"
echo "总耗时: ${TOTAL_ELAPSED}s"
echo "通过: ${#PASSED[@]}"
if [ ${#PASSED[@]} -gt 0 ]; then
  for p in "${PASSED[@]}"; do log_ok "$p"; done
fi
echo "失败: ${#FAILED[@]}"
if [ ${#FAILED[@]} -gt 0 ]; then
  for f in "${FAILED[@]}"; do log_fail "$f"; done
fi
echo "跳过: ${#SKIPPED[@]}"
if [ ${#SKIPPED[@]} -gt 0 ]; then
  for s in "${SKIPPED[@]}"; do log_skip "$s"; done
fi

echo ""
echo "报告文件:"
[ -f /tmp/xlang_p0_matrix_report.md ] && echo "  - /tmp/xlang_p0_matrix_report.md"
[ -f /tmp/xlang_toolchain_report.md ] && echo "  - /tmp/xlang_toolchain_report.md"

if [ ${#FAILED[@]} -gt 0 ]; then
  exit 1
fi
exit 0
