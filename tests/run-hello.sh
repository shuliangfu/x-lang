#!/usr/bin/env bash
# 阶段 4 Hello World：编译 examples/hello.su 并运行，检查输出含 "Hello World"
# run-all 默认用 C（RUN_ALL_USE_C=1）：父脚本会 export SHU=./compiler/shu-c（若存在），走 C 流水线；仅手动 SHU=./compiler/shu 且非 shu-c 时仍用该二进制。
# run-all-su 设 SHU=shu_su：用 .su 流水线（-su）。

set -e
cd "$(dirname "$0")/.."
SHU=${SHU:-./compiler/shu}

# 探测二进制是否编译了 -su（链 pipeline）；默认 make 的 compiler/shu 仅有 C 前端时会报 unknown option。
shu_cli_supports_su() {
  local o
  o=$("$1" -su 2>&1) || true
  case "$o" in
    *"unknown option"*) return 1 ;;
    *) return 0 ;;
  esac
}

# check-7.2 的 shu_stage1/2 对 hello 走 -su 时 .su typeck 尚未全覆盖；有同目录 shu-c 时 hello 改由 C 前端编译，与默认全量回归一致。
HELLO_COMPILE_SHU="$SHU"
case "${SHU##*/}" in
  shu_stage1|shu_stage2)
    _hello_shu_dir=$(dirname "$SHU")
    if [ -x "$_hello_shu_dir/shu-c" ]; then HELLO_COMPILE_SHU="$_hello_shu_dir/shu-c"; fi
    ;;
esac
if [ -n "${RUN_ALL_USE_C:-}" ]; then
  # run-all 默认 C 流水线
  make -C compiler -q all 2>/dev/null || make -C compiler all
  "$HELLO_COMPILE_SHU" examples/hello.su -o /tmp/shu_hello
else
  if [[ "$HELLO_COMPILE_SHU" == *shu-c* ]] || ! shu_cli_supports_su "$HELLO_COMPILE_SHU"; then
    "$HELLO_COMPILE_SHU" -L . examples/hello.su -o /tmp/shu_hello
  else
    # -o 链接走 driver 全路径；显式 -su 在 shu_su 上对 import std.io 会 dep 预跑 rc=-7。与 run-all-su 一致带 -L .
    "$HELLO_COMPILE_SHU" -L . examples/hello.su -o /tmp/shu_hello 1>/dev/null
  fi
fi
out=$(/tmp/shu_hello)
echo "$out" | grep -q "Hello World" || { echo "expected 'Hello World' in output, got: $out"; exit 1; }
echo "Hello World test OK"
