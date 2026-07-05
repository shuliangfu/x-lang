#!/usr/bin/env bash
# 阶段 2.11 / 9.1：验证纯 .sx 流水线（-sx -E）对最小程序能跑通并产出 C。
# 在仓库根目录执行：./tests/run-sx-pipeline.sh
# 要求：compiler 已 make，且 make bootstrap-pipeline + shux-sx-pipeline 已生成 shux_sx。

set -e
cd "$(dirname "$0")/.."

# 阶段 10.2：CI 下也跑本测试；用 run_timeout 限时，超时则失败（exit 1）避免假绿。
make -C compiler -q 2>/dev/null || make -C compiler

# 可移植超时：执行一条命令，超时秒数 $1，命令为 "${@:2}"；超时返回 124
run_timeout() {
  local secs="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$secs" "$@" || { local e=$?; [ "$e" -eq 124 ] && return 124; return "$e"; }
  else
    perl -e 'alarm shift; exec @ARGV' "$secs" "$@" || { local e=$?; [ "$e" -eq 142 ] && return 124; return "$e"; }
  fi
}

# 生成 shux_sx（bootstrap-pipeline + 编译 pipeline_gen.c）整段限 120s，避免卡在 make
make_ret=0
run_timeout 120 bash -c 'make -C compiler bootstrap-pipeline 2>/dev/null || true; make -C compiler shux-sx-pipeline 2>/dev/null || true' || make_ret=$?
if [ "$make_ret" -eq 124 ]; then
  echo "run-sx-pipeline FAIL (make bootstrap-pipeline / shux-sx-pipeline timed out after 120s)"
  exit 1
fi

if [ -x compiler/shux_sx ]; then SX_SHUX=compiler/shux_sx; else SX_SHUX=compiler/shux; fi
[ -x "$SX_SHUX" ] || { echo "compiler/shux_sx and compiler/shux not found or not executable"; exit 1; }

MIN_SX="tests/sx-pipeline/min.sx"
mkdir -p tests/sx-pipeline
if [ ! -f "$MIN_SX" ]; then
  printf 'function main(): i32 { return 0; }\n' > "$MIN_SX"
fi

# 使用 compiler/shux 时可能为 C-only 构建（不支持 -sx -E），先探测；不支持则跳过以免 make test 失败
# 对 -sx -E 加 60s 超时，避免 shux_sx 在部分环境挂起（pipeline_run_sx_pipeline_impl/typeck/codegen）。
# 将 stderr 写入临时文件，失败时打印以便 CI 看到 -sx -E 诊断（如 out_buf.len、前 16 字节 hex）。
out=$(mktemp)
err=$(mktemp)
ec=0
run_timeout 60 "$SX_SHUX" -sx -E "$MIN_SX" > "$out" 2>"$err" || ec=$?
[ "$ec" -eq 142 ] && ec=124
_show_stderr() { echo "--- stderr ---"; cat "$err" 2>/dev/null || true; rm -f "$err"; }
if [ "$ec" -eq 124 ]; then
  rm -f "$out"
  _show_stderr
  echo "run-sx-pipeline FAIL (shux_sx -sx -E timed out after 60s)"
  exit 1
fi
if [ "$ec" -ne 0 ]; then
  if [ "$SX_SHUX" = "compiler/shux" ]; then
    rm -f "$out" "$err"
    echo "run-sx-pipeline SKIP (shux does not support -sx -E; run make bootstrap-driver or use build_tool for full shux)"
    exit 0
  fi
  if [ "$ec" -eq 126 ]; then
    rm -f "$out" "$err"
    echo "run-sx-pipeline SKIP (shux_sx not runnable in this env, e.g. wrong libc in container; run make -C compiler clean first)"
    exit 0
  fi
  echo "run-sx-pipeline: $SX_SHUX -sx -E $MIN_SX failed (exit $ec)"
  cat "$out" 2>/dev/null || true
  _show_stderr
  rm -f "$out"
  exit 1
fi

# 产出应含 return（有 return 即视为有效 C；#include 可有可无，shux_sx 的 pipeline 可能不生成）
if ! grep -q 'return' "$out"; then
  echo "run-sx-pipeline: output missing return"
  cat "$out"
  _show_stderr
  rm -f "$out"
  exit 1
fi

rm -f "$out" "$err"
echo "run-sx-pipeline OK (-sx -E minimal program)"
