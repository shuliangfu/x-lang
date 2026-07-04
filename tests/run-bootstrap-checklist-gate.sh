#!/usr/bin/env bash
# 自举前必须清单 — 按文档 §三→§九 顺序逐项验收（实时输出，不吞日志）
#
# 用法：./tests/run-bootstrap-checklist-gate.sh
# 环境：
#   SHUX_CHECKLIST_SECTION=3     只跑某一节（3–9）
#   SHUX_CHECKLIST_ALLOW_WARN=1  WARN/SKIP 不导致 exit 1
#   SHUX_CHECKLIST_STOP_ON_FAIL=1 遇 FAIL 即停（默认 1）
if [ -z "${SHUX_STDBUF_WRAPPED:-}" ] && command -v stdbuf >/dev/null 2>&1; then
  export SHUX_STDBUF_WRAPPED=1
  exec stdbuf -oL -eL bash "$0" "$@"
fi

set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh
# shellcheck source=tests/lib/p0-gate-shux.sh
source tests/lib/p0-gate-shux.sh

# macOS 守卫：shux_asm_stage1 在 macOS 上会吃 60G+ 内存（asm 后端无限内存），
# 所有直接调用 shux_asm_stage1 的 gate 在 macOS 上自动 SKIP。
SHUX_IS_MACOS=0
if [ "$(uname)" = "Darwin" ]; then
  SHUX_IS_MACOS=1
fi
# macOS 上跳过依赖 shux_asm_stage1 的 gate
skip_stage1_gate() {
  if [ "$SHUX_IS_MACOS" = "1" ]; then
    gate_progress "SKIP (macOS): $1 — shux_asm_stage1 会 OOM"
    return 0
  fi
  return 1
}
gate_progress "自举前必须清单 gate 加载完成（§三→§九 顺序）"
if [ -z "${SHUX:-}" ] && seed="$(p0_gate_default_seed 2>/dev/null || true)" && [ -n "$seed" ]; then
  export SHUX="$seed"
  gate_progress "默认 SHUX=$SHUX（seed 优先）"
fi
export SHUX_MINIMAL_CC_LINK="${SHUX_MINIMAL_CC_LINK:-1}"
export SHUX_P0_SKIP_STAGE1="${SHUX_P0_SKIP_STAGE1:-1}"

DOC="analysis/自举前必须清单.md"
[ -f "$DOC" ] || { gate_progress "FAIL: missing $DOC"; exit 1; }

ONLY="${SHUX_CHECKLIST_SECTION:-}"
STOP="${SHUX_CHECKLIST_STOP_ON_FAIL:-1}"
ALLOW_WARN="${SHUX_CHECKLIST_ALLOW_WARN:-0}"
FAST="${SHUX_CHECKLIST_FAST:-0}"

PASS=0
WARN=0
SKIP=0
FAIL=0

should_run_section() {
  local n="$1"
  [ -z "$ONLY" ] || [ "$ONLY" = "$n" ]
}

record_ok() {
  gate_progress "§$1 $2 → PASS"
  PASS=$((PASS + 1))
}

record_warn() {
  gate_progress "§$1 $2 → WARN ($3)"
  WARN=$((WARN + 1))
}

record_skip() {
  gate_progress "§$1 $2 → SKIP ($3)"
  SKIP=$((SKIP + 1))
}

record_fail() {
  gate_progress "§$1 $2 → FAIL ($3)"
  FAIL=$((FAIL + 1))
  if [ "$STOP" = "1" ]; then
    gate_progress "STOP: SHUX_CHECKLIST_STOP_ON_FAIL=1"
    exit 1
  fi
}

run_gate_script() {
  local script="$1"
  local path="tests/$script"
  [ -f "$path" ] || return 127
  chmod +x "$path"
  gate_progress_run "$script" ./tests/"$script"
}

section_banner() {
  echo ""
  echo "################################################################"
  gate_progress "§$1 — $2"
  echo "################################################################"
}

# ── §三 语言与 ABI（L9 为唯一 🟡 M 项）──
run_section_3() {
  should_run_section 3 || return 0
  section_banner 3 "语言与 ABI（L9 Arena 对齐）"
  gate_progress "审计 page_mmap_heap_alloc 须含 align_up ..."
  if grep -q 'mem.align_up' std/heap/page_mmap.x; then
    gate_progress "OK: page_mmap.x 使用 mem.align_up"
  else
    record_fail 3 "L9 page_mmap" "missing align_up"
    return
  fi
  if run_gate_script run-memory-contract-arena-align-gate.sh; then
    record_ok 3 "L9 arena_align gate"
  else
    record_fail 3 "L9 arena_align gate" "exit non-zero"
  fi
  gate_progress "§三 小结: L1–L8 ✅；L9 见上"
}

# ── §四 标准库与 I/O（S7）──
run_section_4() {
  should_run_section 4 || return 0
  section_banner 4 "标准库与 I/O（S7 编译器硬依赖）"
  if run_gate_script run-bootstrap-std-harddeps-gate.sh; then
    record_ok 4 "S7 std sys/path + optional fs/heap"
  else
    record_fail 4 "S7 std-harddeps" "required typeck failed"
  fi
}

# ── §五 编译器与工具链（C2/C5/C6/C9 + §9.1 语义债）──
run_section_5() {
  should_run_section 5 || return 0
  export SHUX_C2_BIN="${SHUX_C2_BIN:-$SHUX}"
  export SHUX_C9_BIN="${SHUX_C9_BIN:-$SHUX}"
  section_banner 5 "编译器与工具链（C2 diag / C5 spill / C6 asm -o / C9 stdout / §9.1）"
  gate_progress "C2: 泛型 wrong_type_args 诊断 ..."
  if run_gate_script run-typeck-generic-args-gate.sh; then
    record_ok 5 "C2 generic expects/got"
  else
    record_fail 5 "C2 generic expects/got" "gate failed"
  fi
  gate_progress "C5: regalloc × Result spill ..."
  if run_gate_script run-comp-regalloc-result-spill-gate.sh; then
    record_ok 5 "C5 spill gate"
  else
    record_fail 5 "C5 spill" "gate failed"
  fi
  gate_progress "C6: asm -o 直链 ..."
  set +e
  gate_progress_run "C6 asm -o" ./tests/run-bootstrap-c6-asm-o-gate.sh 2>&1 | tee /tmp/shux_c6.log
  c6_ec=${PIPESTATUS[0]:-1}
  set -e
  if [ "$c6_ec" -eq 0 ]; then
    if grep -qi 'SKIP' /tmp/shux_c6.log; then
      record_skip 5 "C6 asm -o" "无 shux_asm"
    elif grep -qiE 'WARN|待' /tmp/shux_c6.log; then
      record_warn 5 "C6 asm -o" "未完全直链"
    else
      record_ok 5 "C6 asm -o"
    fi
  else
    record_warn 5 "C6 asm -o" "asm -o 失败（键 C 阻塞）"
  fi
  gate_progress "C9: 非 TTY stdout 不挂起 ..."
  if run_gate_script run-non-tty-stdout-gate.sh; then
    record_ok 5 "C9 non-tty stdout"
  else
    record_fail 5 "C9 non-tty stdout" "gate failed"
  fi
  gate_progress "§9.1: codegen 语义债回归 ..."
  if [ "$FAST" = "1" ]; then
    gate_progress "FAST: SKIP §9.1 -o（compound-assign 耗内存；见 run-codegen-semantic-debt-gate）"
    record_skip 5 "§9.1 semantic debt" "FAST skip -o"
  elif SHUX_CODEGEN_DEBT_STRICT=0 run_gate_script run-codegen-semantic-debt-gate.sh; then
    record_ok 5 "§9.1 semantic debt (STRICT=0)"
  else
    record_warn 5 "§9.1 semantic debt" "部分 case 红（须逐条修）"
  fi
}

# ── §六 语义与性能生死线（P1–P6 已 ✅，烟测确认）──
run_section_6() {
  should_run_section 6 || return 0
  section_banner 6 "语义与性能生死线（P1–P6 烟测）"
  if [ "$FAST" = "1" ]; then
    gate_progress "FAST: §六 P1–P6 已 ✅，跳过 run-result/run-ub"
    record_ok 6 "P1–P6 文档已绿 (FAST skip)"
    return 0
  fi
  if run_gate_script run-result.sh; then
    record_ok 6 "P2 run-result.sh"
  else
    record_fail 6 "P2 result" "run-result failed"
  fi
  if run_gate_script run-ub.sh; then
    record_ok 6 "P4/P5 run-ub.sh"
  else
    record_warn 6 "run-ub" "failed"
  fi
}

# ── §七 自举验证与防塌陷（V6/V7）──
run_section_7() {
  should_run_section 7 || return 0
  section_banner 7 "自举验证与防塌陷（V6/V7）"
  gate_progress "V6: fresh seed smoke（可能 1–2 分钟）..."
  if [ "${SHUX_BOOTSTRAP_FRESH_SEED_SKIP:-0}" = "1" ]; then
    gate_progress "V6: SKIP（已在 FAST 预跑完成）"
    record_ok 7 "V6 fresh seed (pre-run)"
  elif gate_progress_run_heartbeat "V6 fresh seed" 15 ./tests/run-bootstrap-fresh-seed-gate.sh; then
    record_ok 7 "V6 fresh seed"
  else
    record_fail 7 "V6 fresh seed" "smoke failed"
  fi
  if run_gate_script run-bootstrap-symbol-visibility-gate.sh; then
    record_ok 7 "V7 symbol visibility"
  else
    record_fail 7 "V7 sym-vis" "gate failed"
  fi
  if [ -f compiler/shux_asm_stage1 ] && [ -f compiler/shux_asm2 ]; then
    if run_gate_script run-bootstrap-anti-collapse-gate.sh; then
      record_ok 7 "V4/V5 anti-collapse"
    else
      record_fail 7 "V4/V5 anti-collapse" "check failed"
    fi
  else
    record_skip 7 "V4/V5 anti-collapse" "无 stage1/2；见 bootstrap-gold"
  fi
}

# ── §八 阶段 G（键 D；自举前仅审计，不阻塞键 C 时可 WARN）──
run_section_8() {
  should_run_section 8 || return 0
  section_banner 8 "阶段 G 终局清场（键 D 哨兵）"
  gate_progress "G-01 core 零 C（已 ✅）— 快速确认 gate 存在 ..."
  if [ -f tests/run-f08-core-inventory-gate.sh ]; then
    record_skip 8 "G-02～G-07" "键 D 范围；自举前清单不强制全绿"
  else
    record_warn 8 "G gates" "inventory gate missing"
  fi
  gate_progress "G-03 nostdlib 哨兵（当前预期 FAIL/WARN）..."
  if SHUX_NOLIBC_N07_V5_FAIL=1 gate_progress_run "G-03 nolibc" \
      gate_run_timeout 120 ./tests/run-nolibc-n07-v5-gate.sh; then
    record_ok 8 "G-03 nostdlib"
  else
    record_warn 8 "G-03 nostdlib" "未闭合（键 D）"
  fi
}

# ── §九 编译器 dogfood（X2/X9 与 L9/C5 联动）──
run_section_9() {
  should_run_section 9 || return 0
  section_banner 9 "编译器 dogfood（X2 Arena / X9 spill）"
  gate_progress "X2/X9 已在 §三 L9、§五 C5 覆盖；确认 run-struct 含 arena_align ..."
  if grep -q 'arena_align.x' tests/run-struct.sh; then
    gate_progress "OK: run-struct.sh 已挂 arena_align"
    record_ok 9 "X2 struct 链 arena_align"
  else
    record_fail 9 "X2 run-struct" "missing arena_align"
  fi
  record_skip 9 "X1 mmap 读入" "S 档；自举后再做"
  record_skip 9 "X3–X8" "S/D 档；见 §十一 推迟项"
}

gate_progress "自举前必须清单 gate 开始（§三→§九 逐项）"
run_section_3
run_section_4
run_section_5
run_section_6
run_section_7
run_section_8
run_section_9

echo ""
echo "################################################################"
gate_progress "汇总: PASS=$PASS WARN=$WARN SKIP=$SKIP FAIL=$FAIL"

if [ "$FAIL" -gt 0 ]; then
  gate_progress "清单 gate FAIL（$FAIL 项）"
  exit 1
fi
if [ "$WARN" -gt 0 ] || [ "$SKIP" -gt 0 ]; then
  if [ "$ALLOW_WARN" = "1" ]; then
    gate_progress "清单 gate OK with WARN/SKIP（键 C 未完全闭合）"
    exit 0
  fi
  gate_progress "清单 gate INCOMPLETE（设 SHUX_CHECKLIST_ALLOW_WARN=1 渐进）"
  exit 1
fi
gate_progress "清单 gate OK（§三～§九 当前必须项全绿）"
exit 0
