#!/usr/bin/env bash
# DOD/SIMD 门禁：按宿主 OS/架构选择 compile/run 后端。
# Darwin / Linux ARM64（refresh shu_asm 无本机 asm）：-backend c，避免 asm 产出 x86_64 ELF（EM:62）。
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

# 返回 WPO/asm 门禁用的后端。
dod_host_gate_backend_args() {
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-*|Linux-aarch64|Linux-arm64)
      printf '%s' '-backend c'
      ;;
    *)
      printf '%s' '-backend asm'
      ;;
  esac
}

# 返回用于 -o 可执行链接的编译器（Darwin 须 shu_asm + -backend c；其它用传入 shu_asm/shu）。
dod_host_exe_shu() {
  local seed="${1:-./compiler/shu_asm}"
  printf '%s' "$seed"
}

DOD_F32_BACKEND_ARGS="$(dod_host_f32_backend_args)"
DOD_GATE_BACKEND_ARGS="$(dod_host_gate_backend_args)"
