#!/usr/bin/env bash
# run-bootstrap-min-gate.sh — 自举最小验收（bootstrap-min）
#
# 范围：Stage D 金标准（可选）+ P0 typeck + compiler 源码路径语言烟测。
# 不含：run-all-bstrict 全量 std/asm 微测（net/vec/crypto 等见 staging）。
#
# 用法（仓库根，Linux x86_64 / Docker linux/amd64）：
#   SHUX_LINK_SHUX=./compiler/shux_asm ./tests/run-bootstrap-min-gate.sh
#
# 环境：
#   SHUX_BOOTSTRAP_MIN_SKIP_BUILD=1   跳过 make bootstrap-driver-bstrict
#   SHUX_BOOTSTRAP_MIN_SKIP_STAGE=1   跳过 d03/d04（仅跑语言+P0）
#   SHUX_BOOTSTRAP_MIN_FAIL=1         任一步失败即 exit 1（CI 用）

set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f compiler/shux_asm ] || [ ! -x compiler/shux_asm ]; then
  if [ -n "${SHUX_BOOTSTRAP_MIN_SKIP_BUILD:-}" ]; then
    echo "run-bootstrap-min-gate: missing compiler/shux_asm (unset SKIP_BUILD to build)" >&2
    exit 127
  fi
  echo "run-bootstrap-min-gate: make bootstrap-driver-bstrict ..."
  make -C compiler bootstrap-driver-bstrict
fi

export SHUX=./compiler/shux
export SHUX_SKIP_SUBSCRIPT_MAKE=1
export SHUX_BOOTSTRAP_MIN=1
# bootstrap-min 不设置 SHUX_RUN_ALL_BOOTSTRAP_SHUX，避免 run-parser 等强制覆盖为 shux_asm。
# bootstrap-min：-o 默认 shux_asm（staging 脚本可 source bootstrap-link 自行回退 gcc）
export SHUX_LINK_SHUX="${SHUX_LINK_SHUX:-./compiler/shux_asm}"

if [ -z "${SHUX_BOOTSTRAP_MIN_SKIP_BUILD:-}" ]; then
  cp -f compiler/shux_asm compiler/shux 2>/dev/null || true
fi

run_step() {
  local label="$1"
  shift
  echo "run-bootstrap-min-gate: === $label ==="
  "$@"
}

# --- Stage D 子集（金标准；须已有 gen1/gen2 或先跑 run-linux-a09-a11-gate-inner）---
if [ -z "${SHUX_BOOTSTRAP_MIN_SKIP_STAGE:-}" ]; then
  if [ -f compiler/shux_asm_stage1 ] && [ -f compiler/shux_asm2 ]; then
    run_step "A-09 Stage2 SHA256 (d03)" \
      env SHUX_STAGE2_HASH_STRICT=1 ./tests/run-d03-stage2-hash-gate.sh \
        compiler/shux_asm_stage1 compiler/shux_asm2
    run_step "D-04 portable diff (d04)" \
      ./tests/run-d04-stage2-portable-diff-gate.sh
  else
    echo "run-bootstrap-min-gate: skip d03/d04 (no shux_asm_stage1/2; run run-linux-a09-a11-gate-inner first)" >&2
  fi
fi

# --- P0 typeck（compiler 自身依赖；i64-ctfe / run-ub 见 bootstrap-gold / W3 inner）---
P0_SCRIPTS=(
  run-scope-borrow-gate.sh
  run-al06-gate.sh
  run-type-borrow-conflict-gate.sh
)

# --- 语言 + pipeline 烟测（compiler .sx 子集；不拉全 std）---
# 不含：run-preprocess（seed #if '?'）、run-result（seed asm SIGSEGV）、run-slice（core.slice 链 gold）。
LANG_SCRIPTS=(
  run-check.sh
  run-typeck.sh
  run-parser.sh
  run-hello.sh
  run-import.sh
  run-multi-file.sh
  run-struct.sh
  run-return-value.sh
  run-mem.sh
  run-string.sh
  run-option.sh
  run-match.sh
  run-for.sh
  run-while.sh
)

run_script() {
  local script="$1"
  local script_shu="${SHUX:-./compiler/shux}"
  local script_link="${SHUX_LINK_SHUX:-./compiler/shux_asm}"
  local min_wrap
  min_wrap="$(pwd)/tests/lib/shux-min-link.sh"
  if [ ! -f "tests/$script" ]; then
    echo "run-bootstrap-min-gate: missing tests/$script" >&2
    exit 1
  fi
  chmod +x "tests/$script"
  chmod +x "$min_wrap" 2>/dev/null || true
  # P0：优先 stage2 asm（borrow 等须新 typeck）。
  case "$script" in
    run-scope-borrow-gate.sh|run-al06-gate.sh|run-type-borrow-conflict-gate.sh)
      if [ -x ./compiler/shux_asm2 ]; then
        script_shu=./compiler/shux_asm2
        script_link=./compiler/shux_asm2
      fi
      ;;
  esac
  # 语言烟测：typeck/check 用 seed shux； -o 经 shux-min-link（内嵌 link_abi 缺 gcc 路径时 gcc 回退）。
  case "$script" in
    run-check.sh|run-typeck.sh|run-parser.sh|run-hello.sh|run-import.sh|\
    run-multi-file.sh|run-struct.sh|run-return-value.sh|run-mem.sh|\
    run-string.sh|run-option.sh|run-match.sh|run-for.sh|run-while.sh)
      export SHUX_MIN_LINK_REAL="$script_link"
      if [ -x "$min_wrap" ]; then
        script_link="$min_wrap"
      fi
      # std.io / print 烟测须 io 链接桩（容器内 -B 重编 -fPIE）。
      case "$script" in
        run-hello.sh|run-import.sh|run-string.sh|run-option.sh)
          export SHUX_MIN_LINK_IO=1
          ;;
      esac
      # run-parser / run-for / run-match 等直接用 $SHUX -o；与 RUN_SHUX 对齐走同一包装。
      case "$script" in
        run-parser.sh|run-for.sh|run-match.sh)
          script_shu="$min_wrap"
          ;;
      esac
      ;;
  esac
  if [ -x compiler/shux_asm2 ]; then
    cp -f compiler/shux_asm2 compiler/shux 2>/dev/null || true
  else
    cp -f compiler/shux_asm compiler/shux 2>/dev/null || true
  fi
  SHUX="$script_shu" SHUX_LINK_SHUX="$script_link" SHUX_BOOTSTRAP_MIN=1 ./tests/"$script"
}

for script in "${P0_SCRIPTS[@]}" "${LANG_SCRIPTS[@]}"; do
  run_step "$script" run_script "$script"
done

n_p0=${#P0_SCRIPTS[@]}
n_lang=${#LANG_SCRIPTS[@]}
echo "run-bootstrap-min-gate OK (P0=${n_p0} + lang=${n_lang}; staging std 见 run-all-bstrict.sh)"
