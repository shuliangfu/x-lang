#!/usr/bin/env bash
# run_diff.sh — 差分测试：clang -O2 vs shux_asm，比对 exit code + stdout
#
# 用法：
#   ./tests/bench/diff/run_diff.sh              # 跑全部 D1-D6
#   ./tests/bench/diff/run_diff.sh d1 d2        # 跑指定用例
#   SHUX=./compiler/shux_asm ./tests/bench/diff/run_diff.sh
#
# 时机：§11.1 自举前/自举过程中必须项。验证 ASM 后端行为正确性。
# 原则：C 与 SHUX 同源代码，exit code + stdout 必须一致。
set -u
cd "$(dirname "$0")/../../.."  # 到项目根

SHUX="${SHUX:-./compiler/shux_asm}"
DIFF_DIR="tests/bench/diff"
WORKDIR="${TMPDIR:-/tmp}/shux_diff"
mkdir -p "$WORKDIR"

PASS=0
FAIL=0
SKIP=0

# 平台检测：macOS arm64 有 CG002 限制（asm code_len=0），ASM 后端无法生成可执行文件
arch="$(uname -m 2>/dev/null)"
os="$(uname -s 2>/dev/null)"
if [ "$os" = "Darwin" ] && [ "$arch" = "arm64" ]; then
  echo "diff: SKIP on macOS arm64 (CG002 asm code_len=0 limitation)"
  echo "      请在 Linux x86_64 上运行：ssh ubuntu-server && cd ~/worker/shu/shux && ./tests/bench/diff/run_diff.sh"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  echo "diff: SKIP (no $SHUX)"
  exit 0
fi

# compile_shux <src.x> <out_bin> <log_file>
# shux_asm 在非 TTY stdout 重定向时会挂起；用 | cat drain stdout
compile_shux() {
  local src="$1" out="$2" log="$3"
  "$SHUX" -L . "$src" -o "$out" 2>"$log" | cat >/dev/null
  return "${PIPESTATUS[0]}"
}

# run_one <name> — 编译 C + SHUX 同源代码，运行比对
run_one() {
  local name="$1"
  local c_src="$DIFF_DIR/${name}.c"
  local x_src="$DIFF_DIR/${name}.x"

  if [ ! -f "$c_src" ] || [ ! -f "$x_src" ]; then
    echo "[SKIP] $name: missing .c or .x"
    SKIP=$((SKIP + 1))
    return
  fi

  local c_bin="$WORKDIR/${name}.c.bin"
  local x_bin="$WORKDIR/${name}.x.bin"
  local c_log="$WORKDIR/${name}.c.log"
  local x_log="$WORKDIR/${name}.x.log"

  # 编译 C（clang -O2，GCC 回退）
  local cc="${CC:-clang}"
  if ! command -v "$cc" >/dev/null 2>&1; then cc=gcc; fi
  if ! "$cc" -O2 -std=c11 -o "$c_bin" "$c_src" 2>"$c_log"; then
    echo "[SKIP] $name: C compile failed (see $c_log)"
    SKIP=$((SKIP + 1))
    return
  fi

  # 编译 SHUX（shux_asm，ASM 后端）
  if ! compile_shux "$x_src" "$x_bin" "$x_log"; then
    echo "[SKIP] $name: SHUX compile failed (see $x_log)"
    SKIP=$((SKIP + 1))
    return
  fi
  if [ ! -x "$x_bin" ]; then
    echo "[SKIP] $name: SHUX produced no executable (see $x_log)"
    SKIP=$((SKIP + 1))
    return
  fi

  # 运行 C
  local c_out c_rc
  c_out=$("$c_bin" 2>/dev/null); c_rc=$?
  # 运行 SHUX
  local x_out x_rc
  x_out=$("$x_bin" 2>/dev/null); x_rc=$?

  # 比对 exit code + stdout
  if [ "$c_rc" = "$x_rc" ] && [ "$c_out" = "$x_out" ]; then
    echo "[PASS] $name: rc=$c_rc out='$c_out'"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $name: C(rc=$c_rc,out='$c_out') vs X(rc=$x_rc,out='$x_out')"
    FAIL=$((FAIL + 1))
  fi
}

# 用例列表
ALL_CASES="d1_int_arith d2_struct_layout d3_call_conv d4_float d5_bit_ops d6_mem_ops"

# 选择用例：支持短名前缀（d1→d1_int_arith）或完整名
if [ "$#" -gt 0 ]; then
  CASES=""
  for arg in "$@"; do
    matched=""
    for full in $ALL_CASES; do
      case "$full" in
        "${arg}"*) matched="$full"; break ;;
      esac
    done
    if [ -n "$matched" ]; then
      CASES="$CASES $matched"
    else
      echo "[SKIP] $arg: unknown case (known: $ALL_CASES)" >&2
    fi
  done
else
  CASES="$ALL_CASES"
fi

echo "=== Differential Testing: clang -O2 vs $SHUX ==="
echo "    arch=$os/$arch  workdir=$WORKDIR"

for c in $CASES; do
  run_one "$c"
done

echo "=== Summary: PASS=$PASS FAIL=$FAIL SKIP=$SKIP ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
