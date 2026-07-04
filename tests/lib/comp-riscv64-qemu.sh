#!/usr/bin/env bash
# comp-riscv64-qemu.sh — COMP-018 riscv64 QEMU 用户态烟测辅助
#
# 用法（source 后）：
#   comp_riscv64_qemu_probe
#   comp_riscv64_qemu_link_bin OBJ BIN
#   comp_riscv64_qemu_run_case SHUX_BIN SAMPLE EXPECT_EXIT
#   comp_riscv64_qemu_count MATRIX
#   comp_riscv64_qemu_emit_report status qemu_ok qemu_skip skip

COMP018_PREFIX="${SHUX_COMP018_PREFIX:-shux: [SHUX_COMP018_RISCV_QEMU]}"
RISCV_TARGET="${SHUX_RISCV_TARGET:-riscv64}"

# 探测本机是否安装 qemu-riscv64 用户态仿真器。
comp_riscv64_qemu_probe() {
  local q
  for q in qemu-riscv64 qemu-riscv64-static qemu-riscv64-linux-gnu; do
    if command -v "$q" >/dev/null 2>&1; then
      echo "$q"
      return 0
    fi
  done
  return 1
}

# 将 riscv64 .o 链接为可执行文件（供 QEMU 用户态运行）。
comp_riscv64_qemu_link_bin() {
  local o="$1"
  local bin="$2"
  local cxx ld
  rm -f "$bin" 2>/dev/null || true
  for cxx in riscv64-linux-gnu-gcc riscv64-unknown-linux-gnu-gcc; do
    if command -v "$cxx" >/dev/null 2>&1; then
      if "$cxx" -static -nostdlib -o "$bin" "$o" 2>/dev/null; then
        return 0
      fi
    fi
  done
  for ld in riscv64-linux-gnu-ld riscv64-unknown-elf-ld ld.lld; do
    if command -v "$ld" >/dev/null 2>&1; then
      if "$ld" -e _main -o "$bin" "$o" 2>/dev/null; then
        return 0
      fi
      if "$ld" -e main -o "$bin" "$o" 2>/dev/null; then
        return 0
      fi
    fi
  done
  return 1
}

# 单样例：编译 → 链接 → qemu 运行并校验 exit。
comp_riscv64_qemu_run_case() {
  local shux="$1"
  local sample="$2"
  local expect_exit="$3"
  local qemu="$4"
  local x o bin got ec
  # shellcheck source=tests/lib/comp-riscv64.sh
  . tests/lib/comp-riscv64.sh
  x="$(comp_riscv64_sample_path "$sample")" || return 1
  o="$(mktemp /tmp/shux_riscv_qemu.XXXXXX.o)"
  bin="$(mktemp /tmp/shux_riscv_qemu.XXXXXX)"
  rm -f "$o" "$bin" 2>/dev/null || true
  if ! "$shux" -backend asm -target "$RISCV_TARGET" -o "$o" "$x" 2>/dev/null; then
    rm -f "$o" "$bin"
    return 1
  fi
  if ! comp_riscv64_qemu_link_bin "$o" "$bin"; then
    rm -f "$o" "$bin"
    return 1
  fi
  set +e
  "$qemu" "$bin" >/dev/null 2>&1
  got=$?
  set -e
  rm -f "$o" "$bin"
  if [ "$got" -eq "$expect_exit" ]; then
    return 0
  fi
  echo "comp-riscv64-qemu FAIL: $sample exit=$got want=$expect_exit" >&2
  return 1
}

# 统计矩阵中 policy=qemu 的 case 数。
comp_riscv64_qemu_count() {
  local matrix="$1"
  local n=0
  local case_id _sample _check _expect policy
  while IFS=$'\t' read -r case_id _sample _check _expect policy _notes; do
    [ -z "${case_id:-}" ] && continue
    case "$case_id" in \#*|min_*) continue ;; esac
    [ "${policy:-}" = "qemu" ] && n=$((n + 1))
  done < "$matrix"
  echo "$n"
}

# 从 expect 字段解析期望 exit（exit_42 → 42）。
comp_riscv64_qemu_expect_exit() {
  local expect="$1"
  case "$expect" in
    exit_*) echo "${expect#exit_}" ;;
    *) echo "$expect" ;;
  esac
}

# 输出结构化报告行。
comp_riscv64_qemu_emit_report() {
  local status="$1"
  local qemu_ok="$2"
  local qemu_skip="$3"
  local skip="$4"
  echo "${COMP018_PREFIX} status=${status} qemu_ok=${qemu_ok} qemu_skip=${qemu_skip} skip=${skip}"
}
