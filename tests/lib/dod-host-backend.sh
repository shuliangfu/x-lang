#!/usr/bin/env bash
# DOD/SIMD 门禁：按宿主 OS/架构选择 compile/run 后端。
# Darwin / Linux ARM64（refresh shu_asm lite）：-o 可执行走 shu-c（无 -backend；import 时 seed exec shu-c 会原样传 argv）。
# Linux x86_64：-backend asm（Neon/SSE 实锤由各自 job 承担）。
# 用法：source tests/lib/dod-host-backend.sh 后读取 DOD_F32_BACKEND_ARGS、DOD_GATE_BACKEND_ARGS、DOD_EXE_SHU。

# 是否 Linux ARM64/AArch64 宿主。
dod_host_is_linux_arm64() {
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Linux-aarch64|Linux-arm64) return 0 ;;
    *) return 1 ;;
  esac
}

# 返回 f32/SIMD 在须走 C 后端时的参数（Darwin + Linux ARM64 lite refresh shu_asm）。
dod_host_f32_backend_args() {
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-*|Linux-aarch64|Linux-arm64)
      printf '%s' '-backend c'
      ;;
    *)
      printf '%s' ''
      ;;
  esac
}

# 返回 WPO/asm 门禁用的后端；shu-c 路径勿传 -backend（import exec shu-c 会原样转发 argv）。
dod_host_gate_backend_args() {
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-*|Linux-aarch64|Linux-arm64)
      printf '%s' ''
      ;;
    *)
      printf '%s' '-backend asm'
      ;;
  esac
}

# 返回用于 -o 可执行链接的编译器；Darwin/ARM64 lite 用 shu-c，避免 seed asm EM:62 与 -backend 传给 shu-c 失败。
dod_host_exe_shu() {
  local seed="${1:-./compiler/shu_asm}"
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-*|Linux-aarch64|Linux-arm64)
      if [ -x ./compiler/shu-c ]; then
        printf '%s' './compiler/shu-c'
        return
      fi
      ;;
  esac
  printf '%s' "$seed"
}

# f32 可执行烟测是否在 -backend c 路径上记 N/A（gen_driver f32 C 后端 WIP；Linux x86_64 asm 仍跑）。
dod_host_f32_run_na() {
  [ -n "$(dod_host_f32_backend_args)" ]
}

# SIMD-S3 hw vec peel：refresh shu_asm 默认 asm 在 Darwin/Linux ARM64 上编译器 SIGSEGV；x86_64 承担。
dod_host_simd_s3_run_na() {
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-*|Linux-aarch64|Linux-arm64) return 0 ;;
    *) return 1 ;;
  esac
}

DOD_F32_BACKEND_ARGS="$(dod_host_f32_backend_args)"
DOD_GATE_BACKEND_ARGS="$(dod_host_gate_backend_args)"
