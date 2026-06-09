#!/usr/bin/env bash
# DOD/SIMD 门禁：按宿主 OS 选择 compile/run 后端。
# Darwin 上 gen_driver hybrid 的 shu_asm 默认 asm 链产出 ELF .o / Mach-O 用户 exe 不完整；
# compile+run 走 -backend c，可执行链接优先 shu-c（与 run_shu_asm_smoke / bootstrap-link-shu 对齐）。
# 用法：source tests/lib/dod-host-backend.sh 后读取 DOD_BACKEND_ARGS、DOD_EXE_SHU。

# 返回 f32/SIMD asm 在 Darwin 上须走 C 后端时的参数（Darwin: -backend c；其它: 空）。
dod_host_f32_backend_args() {
  case "$(uname -s 2>/dev/null)" in
    Darwin) printf '%s' '-backend c' ;;
    *) printf '%s' '' ;;
  esac
}

# 返回 WPO/asm 门禁用的后端（Linux 等: -backend asm；Darwin: -backend c）。
dod_host_gate_backend_args() {
  case "$(uname -s 2>/dev/null)" in
    Darwin) printf '%s' '-backend c' ;;
    *) printf '%s' '-backend asm' ;;
  esac
}

# 返回用于 -o 可执行链接的编译器。
# Darwin：须 shu_asm + -backend c（shu-c 无 -backend，且 C 前端 f32 字面量未就绪）；其它：seed。
dod_host_exe_shu() {
  local seed="${1:-./compiler/shu_asm}"
  printf '%s' "$seed"
}

DOD_F32_BACKEND_ARGS="$(dod_host_f32_backend_args)"
DOD_GATE_BACKEND_ARGS="$(dod_host_gate_backend_args)"
